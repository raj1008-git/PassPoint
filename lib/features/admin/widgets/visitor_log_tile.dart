import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/dev.log.dart';

class VisitorLogTile extends StatelessWidget {
  final QueryDocumentSnapshot document;
  VisitorLogTile({super.key, required this.document});

  String _fmt(Timestamp? ts) {
    if (ts == null) return '-';
    final dt = ts.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  Future<void> _updateStatus(String id, Map<String, dynamic> updates) async {
    devLog('Updating Visitor Status', params: {'id': id, 'updates': updates});
    await FirebaseFirestore.instance
        .collection('visitors')
        .doc(id)
        .update(updates);
  }

  Widget _buildActionButton(
    BuildContext context,
    String status,
    String id,
    String name,
  ) {
    if (status == 'pending') {
      return ElevatedButton.icon(
        label: const Text('Verify/ Check In'),
        icon: const Icon(Icons.check, size: 18),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Confirm Check-In'),
              content: Text('Mark "$name" as Checked In?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await _updateStatus(id, {'status': 'checked_in'});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visitor checked in!')),
            );
          }
        },
      );
    }
    if (status == 'checked_in') {
      return ElevatedButton.icon(
        icon: const Icon(Icons.time_to_leave, size: 18),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
        ),
        label: const Text('Check Out'),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Confirm Check-Out'),
              content: Text('Checkout "$name" now?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await _updateStatus(id, {
              'status': 'checked_out',
              'checkOutTime': Timestamp.now(),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visitor checked Out')),
            );
          }
        },
      );
    }
    return const Chip(
      label: Text('Completed', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = document.data() as Map<String, dynamic>;
    final id = data['id'] as String? ?? document.id;
    final name = data['name'] as String? ?? 'Unknown';
    final phone = data['phone'] ?? 'N/A';
    final toMeet = data['toMeet'] ?? 'Staff';
    final purpose = data['purpose'] ?? 'Unspecified';
    final status = data['status'] ?? 'pending';
    final checkInTime = data['checkInTime'] as Timestamp?;
    final checkOutTime = data['checkOutTime'] as Timestamp?;
    final photoUrl = data['photoUrl'] ?? '';

    // NEW: department display (falls back to '—' if missing)
    final deptName = data['departmentName'] ?? '—';

    Color tileColor = switch (status) {
      'pending' => Colors.orange.shade50,
      'checked_in' => Colors.green.shade50,
      _ => Colors.grey.shade50,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      color: tileColor,
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: photoUrl.isNotEmpty
              ? Image.network(
                  photoUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.person, size: 30, color: Colors.blueGrey),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 30,
                    color: Colors.blueGrey,
                  ),
                ),
        ),
        title: Text(
          '$name • $phone',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Department line
            Text(
              'Department: $deptName',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'To: $toMeet (${purpose})',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'IN: ${_fmt(checkInTime)} | OUT: ${_fmt(checkOutTime)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: _buildActionButton(context, status, id, name),
      ),
    );
  }
}
