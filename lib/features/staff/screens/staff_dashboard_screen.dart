import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/services/staff_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../admin/widgets/stat_card.dart';
import '../../admin/widgets/visitor_log_tile.dart';
import '../../export/utils/file_writer.dart';
import '../widgets/change_password_dialog.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late TabController _tabController;
  String? _staffEmail;
  String? _staffName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStaffInfo();
  }

  Future<void> _loadStaffInfo() async {
    _staffEmail = await StaffService.getStaffEmail();
    final profile = await StaffService.getStaffProfile();
    if (profile != null) {
      setState(() {
        _staffName = profile['name'] as String?;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _visitorStream() {
    if (_staffEmail == null) return const Stream.empty();

    // Filter visitors where toMeet matches staff email or name
    return FirebaseFirestore.instance
        .collection('visitors')
        .where('toMeet', isEqualTo: _staffName ?? _staffEmail)
        .orderBy('checkInTime', descending: true)
        .snapshots();
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StaffService.signOut();
      devLog('Staff signed out');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  Future<void> _changePassword() async {
    await showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  Future<void> _exportAllAsCsv(List<QueryDocumentSnapshot> docs) async {
    final rows = docs.map((d) => d.data() as Map<String, dynamic>).toList();
    try {
      final path = await FileWriter.writeCsv(
        rows,
        filename: 'my_visitors_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported CSV to: $path'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportAllAsJson(List<QueryDocumentSnapshot> docs) async {
    final rows = docs.map((d) => d.data() as Map<String, dynamic>).toList();
    try {
      final path = await FileWriter.writeJson(
        rows,
        filename: 'my_visitors_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported JSON to: $path'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  List<QueryDocumentSnapshot> _filterDocs(
    List<QueryDocumentSnapshot> docs,
    String statusFilter,
  ) {
    final q = _query.trim().toLowerCase();
    final filtered = docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();
      final phone = (data['phone'] ?? '').toString().toLowerCase();
      final dept = (data['departmentName'] ?? '').toString().toLowerCase();
      final status = (data['status'] ?? '').toString().toLowerCase();

      if (q.isNotEmpty) {
        final matchesQuery =
            name.contains(q) || phone.contains(q) || dept.contains(q);
        if (!matchesQuery) return false;
      }

      if (statusFilter == 'pending' && status != 'pending') return false;
      if (statusFilter == 'checked_in' && status != 'checked_in') return false;
      if (statusFilter == 'checked_out' && status != 'checked_out')
        return false;
      if (statusFilter == 'rejected' && status != 'rejected') return false;

      return true;
    }).toList();

    return filtered;
  }

  Map<String, int> _calculateStats(List<QueryDocumentSnapshot> docs) {
    int pending = 0;
    int checkedIn = 0;
    int checkedOut = 0;
    int rejected = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString().toLowerCase();
      if (status == 'pending') pending++;
      if (status == 'checked_in') checkedIn++;
      if (status == 'checked_out') checkedOut++;
      if (status == 'rejected') rejected++;
    }

    return {
      'pending': pending,
      'checked_in': checkedIn,
      'checked_out': checkedOut,
      'rejected': rejected,
      'total': docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _visitorStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}', style: AppTheme.bodyLarge),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final stats = _calculateStats(docs);

            return LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;

                return CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverToBoxAdapter(
                      child: Container(
                        color: AppTheme.white,
                        padding: EdgeInsets.all(isTablet ? 24 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back),
                                  color: AppTheme.dark,
                                  tooltip: 'Back to Home',
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: isTablet ? 48 : 40,
                                  height: isTablet ? 48 : 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.info,
                                    borderRadius: AppTheme.radiusSmall,
                                  ),
                                  child: Icon(
                                    Icons.people_alt,
                                    color: AppTheme.white,
                                    size: isTablet ? 24 : 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Staff Dashboard',
                                        style: isTablet
                                            ? AppTheme.h2
                                            : AppTheme.h3,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Welcome, ${_staffName ?? _staffEmail ?? "Staff"}',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (context) {
                                        return Container(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Export My Visitors',
                                                style: AppTheme.h3,
                                              ),
                                              const SizedBox(height: 20),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.table_chart,
                                                  color: AppTheme.success,
                                                ),
                                                title: const Text(
                                                  'Export as CSV',
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _exportAllAsCsv(docs);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.code,
                                                  color: AppTheme.info,
                                                ),
                                                title: const Text(
                                                  'Export as JSON',
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _exportAllAsJson(docs);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text('Export'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.dark,
                                    side: const BorderSide(
                                      color: AppTheme.greyLight,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 16 : 12,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _changePassword,
                                  icon: const Icon(Icons.lock_reset, size: 18),
                                  label: const Text('Change Password'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.info,
                                    side: const BorderSide(
                                      color: AppTheme.greyLight,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 16 : 12,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _signOut,
                                  icon: const Icon(Icons.logout, size: 18),
                                  label: const Text('Logout'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.error,
                                    side: const BorderSide(
                                      color: AppTheme.greyLight,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 16 : 12,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stats Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        child: isTablet
                            ? Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.schedule,
                                      title: 'Pending',
                                      subtitle: 'Awaiting approval',
                                      count: stats['pending']!,
                                      backgroundColor: AppTheme.pendingOrange,
                                      iconColor: AppTheme.pendingOrangeIcon,
                                      borderColor: AppTheme.pendingOrangeBorder,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.how_to_reg,
                                      title: 'Checked In',
                                      subtitle: 'Meeting you',
                                      count: stats['checked_in']!,
                                      backgroundColor: AppTheme.checkedInGreen,
                                      iconColor: AppTheme.checkedInGreenIcon,
                                      borderColor:
                                          AppTheme.checkedInGreenBorder,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.exit_to_app,
                                      title: 'Checked Out',
                                      subtitle: 'Completed',
                                      count: stats['checked_out']!,
                                      backgroundColor: AppTheme.checkedOutBlue,
                                      iconColor: AppTheme.checkedOutBlueIcon,
                                      borderColor:
                                          AppTheme.checkedOutBlueBorder,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.block,
                                      title: 'Rejected',
                                      subtitle: 'Denied',
                                      count: stats['rejected']!,
                                      backgroundColor: AppTheme.rejectedRed,
                                      iconColor: AppTheme.rejectedRedIcon,
                                      borderColor: AppTheme.rejectedRedBorder,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.trending_up,
                                      title: 'Total',
                                      subtitle: 'All visitors',
                                      count: stats['total']!,
                                      backgroundColor: AppTheme.totalPurple,
                                      iconColor: AppTheme.totalPurpleIcon,
                                      borderColor: AppTheme.totalPurpleBorder,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: StatCard(
                                          icon: Icons.schedule,
                                          title: 'Pending',
                                          subtitle: 'Awaiting',
                                          count: stats['pending']!,
                                          backgroundColor:
                                              AppTheme.pendingOrange,
                                          iconColor: AppTheme.pendingOrangeIcon,
                                          borderColor:
                                              AppTheme.pendingOrangeBorder,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: StatCard(
                                          icon: Icons.how_to_reg,
                                          title: 'Checked In',
                                          subtitle: 'Meeting',
                                          count: stats['checked_in']!,
                                          backgroundColor:
                                              AppTheme.checkedInGreen,
                                          iconColor:
                                              AppTheme.checkedInGreenIcon,
                                          borderColor:
                                              AppTheme.checkedInGreenBorder,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: StatCard(
                                          icon: Icons.exit_to_app,
                                          title: 'Checked Out',
                                          subtitle: 'Completed',
                                          count: stats['checked_out']!,
                                          backgroundColor:
                                              AppTheme.checkedOutBlue,
                                          iconColor:
                                              AppTheme.checkedOutBlueIcon,
                                          borderColor:
                                              AppTheme.checkedOutBlueBorder,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: StatCard(
                                          icon: Icons.block,
                                          title: 'Rejected',
                                          subtitle: 'Denied',
                                          count: stats['rejected']!,
                                          backgroundColor: AppTheme.rejectedRed,
                                          iconColor: AppTheme.rejectedRedIcon,
                                          borderColor:
                                              AppTheme.rejectedRedBorder,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  StatCard(
                                    icon: Icons.trending_up,
                                    title: 'Total Visitors',
                                    subtitle: 'All time',
                                    count: stats['total']!,
                                    backgroundColor: AppTheme.totalPurple,
                                    iconColor: AppTheme.totalPurpleIcon,
                                    borderColor: AppTheme.totalPurpleBorder,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search by name, phone, or department...',
                            hintStyle: TextStyle(
                              color: AppTheme.grey.withOpacity(0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.grey,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppTheme.white,
                            border: OutlineInputBorder(
                              borderRadius: AppTheme.radiusMedium,
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Tabs and List
                    SliverFillRemaining(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: AppTheme.radiusLarge,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTheme.greyLight,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: !isTablet,
                                labelColor: AppTheme.dark,
                                unselectedLabelColor: AppTheme.grey,
                                labelStyle: AppTheme.labelLarge,
                                indicatorColor: AppTheme.info,
                                indicatorWeight: 3,
                                tabs: [
                                  Tab(text: 'Pending (${stats['pending']})'),
                                  Tab(
                                    text: 'Checked In (${stats['checked_in']})',
                                  ),
                                  Tab(
                                    text:
                                        'Checked Out (${stats['checked_out']})',
                                  ),
                                  Tab(text: 'Rejected (${stats['rejected']})'),
                                  Tab(text: 'All (${stats['total']})'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildList(context, docs, 'pending'),
                                  _buildList(context, docs, 'checked_in'),
                                  _buildList(context, docs, 'checked_out'),
                                  _buildList(context, docs, 'rejected'),
                                  _buildList(context, docs, 'all'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
    String filter,
  ) {
    final filtered = _filterDocs(docs, filter);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text('No visitors found', style: AppTheme.h3),
            const SizedBox(height: 8),
            Text(
              filter == 'rejected'
                  ? 'Rejected visitors will appear here'
                  : 'Visitors wanting to meet you will appear here',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = filtered[index];
        return VisitorLogTile(document: doc);
      },
    );
  }
}
