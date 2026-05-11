// lib/features/events/screens/event_export_screen.dart

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_invite_model.dart';
import '../../../data/repositories/invite_repository.dart';
import '../../../data/repositories/event_gift_repository.dart';
import '../../../data/repositories/event_repository.dart';

class EventExportScreen extends StatefulWidget {
  const EventExportScreen({Key? key}) : super(key: key);

  @override
  State<EventExportScreen> createState() => _EventExportScreenState();
}

class _EventExportScreenState extends State<EventExportScreen> {
  final InviteRepository _repository = InviteRepository(
    eventRepository: EventRepository(),
    giftRepository: EventGiftRepository(),
  );

  bool _isLoading = false;
  bool _isExporting = false;
  List<EventInviteModel>? _invites;
  String? _error;
  late String _eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments
    as Map<String, dynamic>;
    _eventId = args['eventId'] as String;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final invites = await _repository.getInvitesOnce(_eventId);
      setState(() => _invites = invites);
    } catch (e) {
      devLog('EventExportScreen: load error', params: {'error': e.toString()});
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportAttendance() async {
    if (_invites == null) return;
    setState(() => _isExporting = true);

    try {
      final rows = <List<dynamic>>[
        [
          'Name',
          'Phone',
          'Email',
          'Branch',
          'Department',
          'PMLIL Staff',
          'Attendance Status',
          'Check-In Time',
          'Check-Out Time',
          'QR Email Sent',
          'Total Gifts Assigned',
          'Total Gifts Received',
        ],
        ..._invites!.map((inv) => [
          inv.name,
          inv.phone,
          inv.email,
          inv.branchName ?? '',
          inv.departmentName ?? '',
          inv.isPmlilStaff ? 'Yes' : 'No',
          inv.attendanceStatus,
          inv.checkInTime != null
              ? DateFormat('yyyy-MM-dd HH:mm')
              .format(inv.checkInTime!.toDate())
              : '',
          inv.checkOutTime != null
              ? DateFormat('yyyy-MM-dd HH:mm')
              .format(inv.checkOutTime!.toDate())
              : '',
          inv.qrEmailSent ? 'Yes' : 'No',
          inv.assignedGifts.length,
          inv.receivedGiftCount,
        ]),
      ];

      await _writeCsv(rows, 'attendance_${_eventId.substring(0, 8)}.csv');
    } catch (e) {
      devLog('EventExportScreen: export error', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusMedium),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportGifts() async {
    if (_invites == null) return;
    setState(() => _isExporting = true);

    try {
      final rows = <List<dynamic>>[
        [
          'Invitee Name',
          'Phone',
          'Branch',
          'Gift Name',
          'Received',
          'Received At',
          'Not Received Reason',
        ],
      ];

      for (final inv in _invites!) {
        for (final gift in inv.assignedGifts) {
          rows.add([
            inv.name,
            inv.phone,
            inv.branchName ?? '',
            gift.giftName,
            gift.received ? 'Yes' : 'No',
            gift.receivedAt != null
                ? DateFormat('yyyy-MM-dd HH:mm')
                .format(gift.receivedAt!.toDate())
                : '',
            gift.notReceivedReason ?? '',
          ]);
        }
      }

      await _writeCsv(rows, 'gifts_${_eventId.substring(0, 8)}.csv');
    } catch (e) {
      devLog('EventExportScreen: gifts export error',
          params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusMedium),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _writeCsv(
      List<List<dynamic>> rows, String filename) async {
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(csv);

    devLog('EventExportScreen: CSV written', params: {'path': file.path});

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: filename,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Export Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppTheme.error),
                  const SizedBox(height: 12),
                  Text('Failed to load data',
                      style: AppTheme.h3
                          .copyWith(color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B1FA2),
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusMedium),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final invites = _invites ?? [];
          final checkedIn =
              invites.where((i) => !i.isPending).length;
          final checkedOut =
              invites.where((i) => i.isCheckedOut).length;
          final totalGifts = invites.fold<int>(
            0,
                (sum, i) => sum + i.receivedGiftCount,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary cards
                _buildSummaryGrid(
                  invites.length,
                  checkedIn,
                  checkedOut,
                  totalGifts,
                  isTablet,
                ),

                SizedBox(height: isTablet ? 32 : 24),

                Text(
                  'Export Options',
                  style: AppTheme.h3
                      .copyWith(fontSize: isTablet ? 20 : 17),
                ),
                const SizedBox(height: 16),

                // Attendance export
                _buildExportCard(
                  context: context,
                  title: 'Attendance Report',
                  subtitle:
                  'Name, phone, branch, check-in/out times for all ${invites.length} invitees',
                  icon: Icons.people_outline_rounded,
                  onTap: _isExporting ? null : _exportAttendance,
                  isTablet: isTablet,
                ),

                const SizedBox(height: 12),

                // Gift distribution export
                _buildExportCard(
                  context: context,
                  title: 'Gift Distribution Report',
                  subtitle:
                  'Per-gift breakdown: received, declined, reasons',
                  icon: Icons.card_giftcard_outlined,
                  onTap: _isExporting ? null : _exportGifts,
                  isTablet: isTablet,
                ),

                if (_isExporting) ...[
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  const Text(
                    'Preparing export…',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryGrid(
      int total,
      int attended,
      int checkedOut,
      int gifts,
      bool isTablet,
      ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: isTablet ? 2.2 : 1.8,
      children: [
        _buildSummaryCard('Total Invited', total,
            AppTheme.totalPurpleIcon, isTablet),
        _buildSummaryCard(
            'Attended', attended, AppTheme.success, isTablet),
        _buildSummaryCard(
            'Checked Out', checkedOut, AppTheme.info, isTablet),
        _buildSummaryCard(
            'Gifts Given', gifts, AppTheme.warning, isTablet),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, int value, Color color, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: AppTheme.cardShadow,
          border:
          Border.all(color: AppTheme.greyLight.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: isTablet ? 52 : 44,
              height: isTablet ? 52 : 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7B1FA2).withOpacity(0.1),
                borderRadius: AppTheme.radiusMedium,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7B1FA2),
                size: isTablet ? 26 : 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.labelLarge
                        .copyWith(fontSize: isTablet ? 15 : 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.download_rounded,
              color: onTap != null
                  ? const Color(0xFF7B1FA2)
                  : AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}