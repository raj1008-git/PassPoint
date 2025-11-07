import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/dev.log.dart';
import '../../export/utils/file_writer.dart';
import '../widgets/visitor_log_tile.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _visitorStream() {
    return FirebaseFirestore.instance
        .collection('visitors')
        .orderBy('checkInTime', descending: true)
        .snapshots();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    devLog('Admin signed out');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _exportAllAsCsv(List<QueryDocumentSnapshot> docs) async {
    final rows = docs.map((d) => d.data() as Map<String, dynamic>).toList();
    try {
      final path = await FileWriter.writeCsv(
        rows,
        filename:
            'visitors_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported CSV to: $path')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _exportAllAsJson(List<QueryDocumentSnapshot> docs) async {
    final rows = docs.map((d) => d.data() as Map<String, dynamic>).toList();
    try {
      final path = await FileWriter.writeJson(
        rows,
        filename:
            'visitors_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported JSON to: $path')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
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
      final toMeet = (data['toMeet'] ?? '').toString().toLowerCase();
      final status = (data['status'] ?? '').toString().toLowerCase();

      // If query present, require match in name/phone/department/toMeet
      if (q.isNotEmpty) {
        final matchesQuery =
            name.contains(q) ||
            phone.contains(q) ||
            dept.contains(q) ||
            toMeet.contains(q);
        if (!matchesQuery) return false;
      }

      // Status filter logic
      if (statusFilter == 'pending' && status != 'pending') return false;
      if (statusFilter == 'checked_in' && status != 'checked_in') return false;

      return true;
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reception Dashboard'),
        actions: [
          IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Checked-In'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name, phone, department or person',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _visitorStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(context, docs, 'all'),
                    _buildList(context, docs, 'pending'),
                    _buildList(context, docs, 'checked_in'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
    String filter,
  ) {
    // Always apply the same filter function so search works in all tabs
    final filtered = _filterDocs(docs, filter);

    if (filtered.isEmpty) {
      return const Center(child: Text('No visitors'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _exportAllAsCsv(filtered),
                icon: const Icon(Icons.download),
                label: const Text('Export CSV'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _exportAllAsJson(filtered),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export JSON'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final doc = filtered[index];
              return VisitorLogTile(document: doc);
            },
          ),
        ),
      ],
    );
  }
}
