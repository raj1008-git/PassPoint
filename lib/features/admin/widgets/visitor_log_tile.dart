import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class VisitorLogTile extends StatelessWidget {
  final QueryDocumentSnapshot document;

  const VisitorLogTile({super.key, required this.document});

  String _fmt(Timestamp? ts) {
    if (ts == null) return '-';
    final dt = ts.toDate();
    return DateFormat('MM/dd/yyyy hh:mm a').format(dt);
  }

  Future<void> _updateStatus(String id, Map<String, dynamic> updates) async {
    devLog('Updating Visitor Status', params: {'id': id, 'updates': updates});
    await FirebaseFirestore.instance
        .collection('visitors')
        .doc(id)
        .update(updates);
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    final id = (data['id'] as String?) ?? document.id;
    final name = (data['name'] as String?) ?? 'Unknown';
    final phone = (data['phone'] as String?) ?? 'N/A';
    final email = (data['email'] as String?) ?? 'N/A';
    final dept = (data['departmentName'] as String?) ?? '—';
    final toMeet = (data['toMeet'] as String?) ?? '';
    final purpose = (data['purpose'] as String?) ?? '';
    final status = (data['status'] as String?) ?? 'pending';
    final photoUrl = (data['photoUrl'] as String?) ?? '';
    final signatureUrl = (data['signatureUrl'] as String?) ?? '';
    final checkInTime = data['checkInTime'] as Timestamp?;
    final checkOutTime = data['checkOutTime'] as Timestamp?;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.arrow_back, size: 20),
                              label: const Text('Back to Dashboard'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.dark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: Photo and Actions
                                  SizedBox(
                                    width: 280,
                                    child: Column(
                                      children: [
                                        _buildPhotoSection(
                                          photoUrl,
                                          status,
                                          dialogContext,
                                          id,
                                          name,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  // Right: Details
                                  Expanded(
                                    child: _buildDetailsSection(
                                      name,
                                      phone,
                                      email,
                                      dept,
                                      toMeet,
                                      purpose,
                                      checkInTime,
                                      checkOutTime,
                                      signatureUrl,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildPhotoSection(
                                    photoUrl,
                                    status,
                                    dialogContext,
                                    id,
                                    name,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildDetailsSection(
                                    name,
                                    phone,
                                    email,
                                    dept,
                                    toMeet,
                                    purpose,
                                    checkInTime,
                                    checkOutTime,
                                    signatureUrl,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoSection(
    String photoUrl,
    String status,
    BuildContext dialogContext,
    String id,
    String name,
  ) {
    return Column(
      children: [
        // Photo
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: AppTheme.greyLight,
            borderRadius: AppTheme.radiusMedium,
          ),
          clipBehavior: Clip.antiAlias,
          child: photoUrl.isNotEmpty
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, st) => const Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 80,
                      color: AppTheme.grey,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 80,
                    color: AppTheme.grey,
                  ),
                ),
        ),

        const SizedBox(height: 16),

        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: status == 'pending'
                ? AppTheme.pendingOrange
                : status == 'checked_in'
                ? AppTheme.checkedInGreen
                : AppTheme.checkedOutBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status == 'pending'
                ? 'Pending Approval'
                : status == 'checked_in'
                ? 'Checked In'
                : 'Checked Out',
            style: AppTheme.labelLarge.copyWith(
              color: status == 'pending'
                  ? AppTheme.pendingOrangeIcon
                  : status == 'checked_in'
                  ? AppTheme.checkedInGreenIcon
                  : AppTheme.checkedOutBlueIcon,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Action Buttons
        if (status == 'pending')
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _updateStatus(id, {'status': 'checked_in'});
                devLog('Checked in from dialog', params: {'id': id});
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Approve & Check In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusSmall,
                ),
              ),
            ),
          ),
        if (status == 'checked_in')
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _updateStatus(id, {
                  'status': 'checked_out',
                  'checkOutTime': Timestamp.now(),
                });
                devLog('Checked out from dialog', params: {'id': id});
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Check Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusSmall,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(
    String name,
    String phone,
    String email,
    String dept,
    String toMeet,
    String purpose,
    Timestamp? checkInTime,
    Timestamp? checkOutTime,
    String signatureUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Visitor Details', style: AppTheme.h3),
        const SizedBox(height: 24),

        // Personal Information
        _buildSectionHeader(Icons.person, 'Personal Information'),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildCleanInfoRow('Full Name', name),
          _buildCleanInfoRow('Phone Number', phone),
          _buildCleanInfoRow('Email Address', email),
        ]),

        const SizedBox(height: 20),

        // Visit Information
        _buildSectionHeader(Icons.business, 'Visit Information'),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildCleanInfoRow('Department', dept),
          _buildCleanInfoRow('Person to Meet', toMeet),
          _buildCleanInfoRow('Purpose of Visit', purpose),
        ]),

        const SizedBox(height: 20),

        // Timeline
        _buildSectionHeader(Icons.schedule, 'Timeline'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: AppTheme.radiusSmall,
            border: Border.all(color: AppTheme.greyLight, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineItem('Request Submitted', _fmt(checkInTime), true),
              if (checkOutTime != null) ...[
                Container(
                  margin: const EdgeInsets.only(left: 11, top: 8, bottom: 8),
                  width: 2,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.greyLight,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                _buildTimelineItem('Checked Out', _fmt(checkOutTime), true),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Signature Section
        if (signatureUrl.isNotEmpty) ...[
          _buildSectionHeader(Icons.draw, 'Signature'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: AppTheme.radiusSmall,
              border: Border.all(color: AppTheme.greyLight, width: 1),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: AppTheme.radiusSmall,
                  child: Container(
                    color: AppTheme.white,
                    padding: const EdgeInsets.all(8),
                    child: Image.network(
                      signatureUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, st) => const Center(
                        child: Text(
                          'Signature unavailable',
                          style: AppTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Contact Department Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.05),
            borderRadius: AppTheme.radiusSmall,
            border: Border.all(
              color: AppTheme.primaryRed.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_outlined,
                  color: AppTheme.primaryRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Department',
                      style: AppTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Before checking in the visitor, contact $toMeet in the $dept department',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusSmall,
        border: Border.all(color: AppTheme.greyLight, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildCleanInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.dark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isActive) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.success.withOpacity(0.1)
                : AppTheme.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppTheme.success : AppTheme.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.success : AppTheme.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryRed),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.labelLarge.copyWith(
            fontSize: 16,
            color: AppTheme.primaryRed,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = document.data() as Map<String, dynamic>;
    final id = data['id'] as String? ?? document.id;
    final name = data['name'] as String? ?? 'Unknown';
    final phone = data['phone'] ?? 'N/A';
    final toMeet = data['toMeet'] ?? 'Staff';
    final status = data['status'] ?? 'pending';
    final checkInTime = data['checkInTime'] as Timestamp?;
    final photoUrl = data['photoUrl'] ?? '';
    final deptName = data['departmentName'] ?? '—';

    return InkWell(
      onTap: () {
        devLog('Tile tapped, opening details', params: {'id': id});
        _showDetailsDialog(context, data);
      },
      borderRadius: AppTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: AppTheme.greyLight, width: 1),
        ),
        child: Row(
          children: [
            // Photo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.greyLight,
                borderRadius: AppTheme.radiusSmall,
              ),
              clipBehavior: Clip.antiAlias,
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.person_outline,
                              size: 32,
                              color: AppTheme.grey,
                            ),
                          ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 32,
                        color: AppTheme.grey,
                      ),
                    ),
            ),

            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTheme.labelLarge.copyWith(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'pending'
                              ? AppTheme.warning.withOpacity(0.15)
                              : status == 'checked_in'
                              ? AppTheme.success.withOpacity(0.15)
                              : AppTheme.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status == 'pending'
                              ? 'Pending'
                              : status == 'checked_in'
                              ? 'Checked In'
                              : 'Checked Out',
                          style: AppTheme.bodySmall.copyWith(
                            color: status == 'pending'
                                ? AppTheme.warning
                                : status == 'checked_in'
                                ? AppTheme.success
                                : AppTheme.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Department: $deptName',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Meeting: $toMeet',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Phone: $phone',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Time and Action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _fmt(checkInTime).split(' ')[0],
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
                Text(
                  _fmt(checkInTime).split(' ').skip(1).join(' '),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                if (status == 'pending')
                  ElevatedButton(
                    onPressed: () async {
                      await _updateStatus(id, {'status': 'checked_in'});
                      devLog('Visitor checked in', params: {'id': id});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 16),
                        const SizedBox(width: 4),
                        const Text('Check In', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
