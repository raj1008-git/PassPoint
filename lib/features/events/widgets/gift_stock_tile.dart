// lib/features/events/widgets/gift_stock_tile.dart

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_gift_model.dart';

/// Displays a single gift type with its stock levels and a progress bar.
/// Used in gift_inventory_screen.
///
/// Usage:
/// ```dart
/// GiftStockTile(
///   gift: gift,
///   onEdit: () { ... },
///   onDelete: () { ... },
/// )
/// ```
class GiftStockTile extends StatelessWidget {
  final EventGiftModel gift;

  /// Called when edit is tapped. If null, edit button hidden.
  final VoidCallback? onEdit;

  /// Called when delete is tapped. If null, delete button hidden.
  /// Repository guards against deletion when assignedCount > 0.
  final VoidCallback? onDelete;

  const GiftStockTile({
    Key? key,
    required this.gift,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  // ---------------------------------------------------------------------------
  // Stock level colour
  // ---------------------------------------------------------------------------

  Color get _barColor {
    if (gift.stockFraction > 0.5) return AppTheme.success;
    if (gift.stockFraction > 0.2) return AppTheme.warning;
    return AppTheme.error;
  }

  String get _stockLabel {
    if (gift.isOutOfStock) return 'Out of stock';
    if (gift.isLowStock) return 'Low stock';
    return 'In stock';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 500;

        return Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: AppTheme.radiusLarge,
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: AppTheme.greyLight.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ───────────────────────────────────────────
              Row(
                children: [
                  // Gift icon
                  Container(
                    width: isTablet ? 40 : 34,
                    height: isTablet ? 40 : 34,
                    decoration: BoxDecoration(
                      color: _barColor.withOpacity(0.1),
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    child: Icon(
                      Icons.card_giftcard_outlined,
                      color: _barColor,
                      size: isTablet ? 22 : 18,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Name + stock label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gift.name,
                          style: AppTheme.labelLarge.copyWith(
                            fontSize: isTablet ? 16 : 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _stockLabel,
                          style: TextStyle(
                            color: _barColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit / delete — only when nothing assigned yet
                  if (gift.assignedCount == 0) ...[
                    if (onEdit != null)
                      _IconAction(
                        icon: Icons.edit_outlined,
                        color: AppTheme.textSecondary,
                        onTap: onEdit!,
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
                      _IconAction(
                        icon: Icons.delete_outline_rounded,
                        color: AppTheme.error,
                        onTap: onDelete!,
                      ),
                    ],
                  ] else
                  // Lock icon when stock is already assigned
                    Tooltip(
                      message: 'Cannot edit — gifts already assigned',
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Stock numbers ─────────────────────────────────────────
              Row(
                children: [
                  _StockChip(
                    label: 'Remaining',
                    value: gift.remainingStock,
                    color: _barColor,
                  ),
                  const SizedBox(width: 8),
                  _StockChip(
                    label: 'Assigned',
                    value: gift.assignedCount,
                    color: AppTheme.info,
                  ),
                  const Spacer(),
                  Text(
                    '${gift.totalStock} total',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Progress bar ──────────────────────────────────────────
              ClipRRect(
                borderRadius: AppTheme.radiusSmall,
                child: LinearProgressIndicator(
                  value: gift.stockFraction,
                  backgroundColor: AppTheme.greyLight,
                  color: _barColor,
                  minHeight: isTablet ? 8 : 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _StockChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StockChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.radiusSmall,
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}