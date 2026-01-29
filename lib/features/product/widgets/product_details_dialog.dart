import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../model/product_model.dart';

class ProductDetailsDialog extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsDialog({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(),
                    _getStatusColor().withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registration #${product.registrationNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusLabel(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Photo
                    if (product.productPhotoUrl != null) ...[
                      ClipRRect(
                        borderRadius: AppTheme.radiusMedium,
                        child: Image.network(
                          product.productPhotoUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: AppTheme.greyLight,
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Registration Details
                    _buildSection('Registration Details', Icons.edit_document, [
                      _buildDetailRow(
                        'Registration Number',
                        product.registrationNumber,
                      ),
                      _buildDetailRow(
                        'Registration Date',
                        DateFormat(
                          'yyyy-MM-dd',
                        ).format(product.registrationDate.toDate()),
                      ),
                      _buildDetailRow(
                        'Received Letter Number',
                        product.receivedLetterNumber,
                      ),
                      _buildDetailRow(
                        'Received Letter Date',
                        DateFormat(
                          'yyyy-MM-dd',
                        ).format(product.receivedLetterDate.toDate()),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Product Details
                    _buildSection('Product Details', Icons.inventory, [
                      _buildDetailRow(
                        'Sender Office',
                        product.senderOfficeName,
                      ),
                      _buildDetailRow('Subject/Description', product.subject),
                    ]),

                    const SizedBox(height: 20),

                    // Routing Information
                    _buildSection('Routing Information', Icons.route, [
                      _buildDetailRow(
                        'Target Department',
                        product.targetDepartmentName,
                      ),
                      _buildDetailRow(
                        'Target Person',
                        product.targetPersonName,
                      ),
                      if (product.currentDepartmentName != null)
                        _buildDetailRow(
                          'Current Department',
                          product.currentDepartmentName!,
                        ),
                      if (product.currentPersonName != null)
                        _buildDetailRow(
                          'Current Person',
                          product.currentPersonName!,
                        ),
                    ]),

                    const SizedBox(height: 20),

                    // Delivery Person (if available)
                    if (product.deliveryPersonName != null ||
                        product.deliveryPersonContact != null) ...[
                      _buildSection('Delivery Person', Icons.person, [
                        if (product.deliveryPersonName != null)
                          _buildDetailRow('Name', product.deliveryPersonName!),
                        if (product.deliveryPersonContact != null)
                          _buildDetailRow(
                            'Contact',
                            product.deliveryPersonContact!,
                          ),
                      ]),
                      const SizedBox(height: 20),
                    ],

                    // Status Timeline
                    _buildSection('Status Timeline', Icons.timeline, []),
                    const SizedBox(height: 12),
                    _buildTimeline(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.info),
            const SizedBox(width: 8),
            Text(title, style: AppTheme.h3.copyWith(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.greyLight.withOpacity(0.3),
            borderRadius: AppTheme.radiusMedium,
            border: Border.all(color: AppTheme.greyLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: product.statusHistory.length,
      itemBuilder: (context, index) {
        final history = product.statusHistory[index];
        final isLast = index == product.statusHistory.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isLast ? _getStatusColor() : AppTheme.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(history['status']),
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 60, color: AppTheme.greyLight),
              ],
            ),
            const SizedBox(width: 16),

            // Timeline content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLast
                      ? _getStatusColor().withOpacity(0.1)
                      : AppTheme.greyLight.withOpacity(0.3),
                  borderRadius: AppTheme.radiusSmall,
                  border: Border.all(
                    color: isLast
                        ? _getStatusColor().withOpacity(0.3)
                        : AppTheme.greyLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history['action'] ?? 'Status updated',
                      style: AppTheme.labelLarge.copyWith(
                        color: isLast
                            ? _getStatusColor()
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By: ${history['performedBy'] ?? 'System'}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (history['department'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Department: ${history['department']}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    if (history['toDepartment'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Forwarded to: ${history['toDepartment']} - ${history['toPerson']}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (history['feedback'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: AppTheme.radiusSmall,
                        ),
                        child: Text(
                          history['feedback'],
                          style: AppTheme.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format((history['timestamp'] as Timestamp).toDate()),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor() {
    switch (product.currentStatus) {
      case 'submitted':
        return AppTheme.warning;
      case 'received_by_reception':
        return AppTheme.checkedInGreenIcon;
      case 'forwarded':
        return AppTheme.info;
      case 'completed':
        return AppTheme.success;
      default:
        return AppTheme.grey;
    }
  }

  String _getStatusLabel() {
    switch (product.currentStatus) {
      case 'submitted':
        return 'Awaiting Reception';
      case 'received_by_reception':
        return 'Received by Reception';
      case 'forwarded':
        return 'In Transit';
      case 'completed':
        return 'Completed';
      default:
        return product.currentStatus;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'submitted':
        return Icons.send;
      case 'received_by_reception':
        return Icons.check_circle;
      case 'forwarded':
        return Icons.forward;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.circle;
    }
  }
}
