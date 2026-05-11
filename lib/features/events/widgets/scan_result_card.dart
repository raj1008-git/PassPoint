// lib/features/events/widgets/scan_result_card.dart

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_invite_model.dart';

/// Displays a scanned invitee's details inside the check-in confirmation
/// bottom sheet (Scan 1).
///
/// Shows: avatar, name, branch/phone, PMLIL badge, assigned gifts list.
/// Action buttons (Cancel / Check In) are provided by the caller via
/// [primaryLabel], [onPrimary], and [onCancel] so this widget stays
/// presentational and reusable.
///
/// Usage:
/// ```dart
/// ScanResultCard(
///   invite: invite,
///   primaryLabel: 'Check In',
///   primaryColor: AppTheme.success,
///   onPrimary: () { ... },
///   onCancel: () { ... },
/// )
/// ```
class ScanResultCard extends StatelessWidget {
  final EventInviteModel invite;
  final String primaryLabel;
  final Color primaryColor;
  final VoidCallback onPrimary;
  final VoidCallback onCancel;

  /// Optional subtitle shown below name (overrides auto-generated subtitle).
  final String? subtitleOverride;

  const ScanResultCard({
    Key? key,
    required this.invite,
    required this.primaryLabel,
    required this.primaryColor,
    required this.onPrimary,
    required this.onCancel,
    this.subtitleOverride,
  }) : super(key: key);

  String get _subtitle {
    if (subtitleOverride != null) return subtitleOverride!;
    if (invite.isPmlilStaff) {
      final parts = <String>[];
      if (invite.branchName != null) parts.add(invite.branchName!);
      if (invite.departmentName != null) parts.add(invite.departmentName!);
      return parts.isNotEmpty ? parts.join(' · ') : invite.phone;
    }
    return invite.phone;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 500;

        return Container(
          padding: EdgeInsets.all(isTablet ? 28 : 20),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.greyLight,
                  borderRadius: AppTheme.radiusSmall,
                ),
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // ── Avatar ────────────────────────────────────────────────
              CircleAvatar(
                radius: isTablet ? 36 : 30,
                backgroundColor:
                const Color(0xFF7B1FA2).withOpacity(0.12),
                child: Text(
                  invite.name.isNotEmpty
                      ? invite.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: const Color(0xFF7B1FA2),
                    fontSize: isTablet ? 28 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 14 : 10),

              // ── Name ──────────────────────────────────────────────────
              Text(
                invite.name,
                style: AppTheme.h3.copyWith(
                  fontSize: isTablet ? 22 : 18,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // ── Subtitle (branch / phone) ─────────────────────────────
              Text(
                _subtitle,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              // ── PMLIL badge ───────────────────────────────────────────
              if (invite.isPmlilStaff) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFF7B1FA2).withOpacity(0.1),
                    borderRadius: AppTheme.radiusSmall,
                    border: Border.all(
                      color:
                      const Color(0xFF7B1FA2).withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'PMLIL Employee',
                    style: TextStyle(
                      color: Color(0xFF7B1FA2),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              SizedBox(height: isTablet ? 20 : 16),
              const Divider(height: 1),
              SizedBox(height: isTablet ? 16 : 12),

              // ── Gifts list ────────────────────────────────────────────
              if (invite.assignedGifts.isEmpty)
                Text(
                  'No gifts assigned',
                  style:
                  AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                )
              else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Assigned Gifts (${invite.assignedGifts.length})',
                    style: AppTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 8),
                ...invite.assignedGifts.map(
                      (g) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.card_giftcard_outlined,
                          size: 15,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          g.giftName,
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: isTablet ? 24 : 20),

              // ── Action buttons ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusMedium),
                        side: const BorderSide(
                            color: AppTheme.greyLight),
                        foregroundColor: AppTheme.textSecondary,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onPrimary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: AppTheme.white,
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusMedium),
                        elevation: 0,
                      ),
                      child: Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom safe area padding
              SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 4),
            ],
          ),
        );
      },
    );
  }
}