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

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _onlyPending = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _visitorStream() {
    // Always return ordered snapshots from Firestore and perform
    // pending/search filtering client-side to avoid needing composite indexes.
    final coll = FirebaseFirestore.instance
        .collection('visitors')
        .orderBy('checkInTime', descending: true);
    return coll.snapshots();
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
      devLog('Export CSV saved', params: {'path': path});
    } catch (e) {
      devLog('Export CSV failed', params: {'error': e.toString()});
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
      devLog('Export JSON saved', params: {'path': path});
    } catch (e) {
      devLog('Export JSON failed', params: {'error': e.toString()});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reception Dashboard'),
        actions: [
          IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by name or phone',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Text('Pending only'),
                    Switch(
                      value: _onlyPending,
                      onChanged: (v) => setState(() => _onlyPending = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _visitorStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  devLog(
                    'Visitor stream error',
                    params: {'error': snapshot.error},
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;

                // Client-side search & pending-only filter
                final filtered = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;

                  // pending-only filter
                  if (_onlyPending) {
                    final status = (data['status'] ?? '')
                        .toString()
                        .toLowerCase();
                    if (status != 'pending') return false;
                  }

                  // search query filter (name or phone)
                  if (_query.trim().isEmpty) return true;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final phone = (data['phone'] ?? '').toString().toLowerCase();
                  final q = _query.toLowerCase();
                  return name.contains(q) || phone.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No visitors'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
