import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../model/product_model.dart';

class ProductListTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final Widget? actionButton;

  const ProductListTile({
    Key? key,
    required this.product,
    required this.onTap,
    this.actionButton,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (product.currentStatus) {
      case 'submitted':
        return AppTheme.pendingOrangeIcon;
      case 'received_by_reception':
        return AppTheme.checkedInGreenIcon;
      case 'forwarded':
        return AppTheme.info;
      case 'completed':
        return AppTheme.totalPurpleIcon;
      default:
        return AppTheme.grey;
    }
  }

  Color _getStatusBgColor() {
    switch (product.currentStatus) {
      case 'submitted':
        return AppTheme.pendingOrange;
      case 'received_by_reception':
        return AppTheme.checkedInGreen;
      case 'forwarded':
        return AppTheme.checkedOutBlue;
      case 'completed':
        return AppTheme.totalPurple;
      default:
        return AppTheme.greyLight;
    }
  }

  String _getStatusLabel() {
    switch (product.currentStatus) {
      case 'submitted':
        return 'Submitted';
      case 'received_by_reception':
        return 'Received';
      case 'forwarded':
        return 'Forwarded';
      case 'completed':
        return 'Completed';
      default:
        return product.currentStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final regDate = DateFormat(
      'yyyy-MM-dd',
    ).format(product.registrationDate.toDate());

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: AppTheme.greyLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Registration Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.numbers,
                        size: 14,
                        color: AppTheme.primaryRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.registrationNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Subject
            Text(
              product.subject,
              style: AppTheme.labelLarge.copyWith(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Details Row 1: Sender Office
            Row(
              children: [
                const Icon(Icons.business, size: 14, color: AppTheme.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'From: ${product.senderOfficeName}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Details Row 2: Target
            Row(
              children: [
                const Icon(Icons.arrow_forward, size: 14, color: AppTheme.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'To: ${product.targetDepartmentName} - ${product.targetPersonName}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Details Row 3: Current Location (if forwarded)
            if (product.currentStatus == 'forwarded' ||
                product.currentStatus == 'received_by_reception')
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppTheme.info),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Current: ${product.currentDepartmentName ?? 'N/A'} - ${product.currentPersonName ?? 'N/A'}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.info,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 6),

            // Details Row 4: Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppTheme.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'Registered: $regDate',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            // Action Button
            if (actionButton != null) ...[
              const SizedBox(height: 12),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
