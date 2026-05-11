// lib/features/events/widgets/gift_toggle_row.dart

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_invite_model.dart';

/// A single gift row used in gift_confirmation_screen.
/// Shows gift name, a received/not-received toggle, and an optional
/// reason text field when the gift is toggled OFF.
///
/// All state (toggle + reason) lives in the parent screen —
/// this widget is purely presentational and calls back via [onToggle]
/// and [onReasonChanged].
///
/// Usage:
/// ```dart
/// GiftToggleRow(
///   gift: assignedGift,
///   isReceived: _receivedToggles[gift.giftId] ?? true,
///   reasonController: _reasonControllers[gift.giftId],
///   onToggle: (val) => setState(() => _receivedToggles[gift.giftId] = val),
///   onReasonChanged: (text) => _reasons[gift.giftId] = text,
/// )
/// ```
class GiftToggleRow extends StatelessWidget {
  final AssignedGift gift;
  final bool isReceived;
  final TextEditingController? reasonController;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String>? onReasonChanged;

  const GiftToggleRow({
    Key? key,
    required this.gift,
    required this.isReceived,
    this.reasonController,
    required this.onToggle,
    this.onReasonChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 500;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: AppTheme.radiusMedium,
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: isReceived
                  ? AppTheme.success.withOpacity(0.35)
                  : AppTheme.error.withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Toggle row ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Status icon
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isReceived
                            ? Icons.check_circle_rounded
                            : Icons.cancel_outlined,
                        key: ValueKey(isReceived),
                        size: isTablet ? 22 : 20,
                        color: isReceived
                            ? AppTheme.success
                            : AppTheme.error.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Gift name
                    Expanded(
                      child: Text(
                        gift.giftName,
                        style: AppTheme.labelLarge.copyWith(
                          fontSize: isTablet ? 15 : 14,
                          color: isReceived
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Received / Not received label
                    Text(
                      isReceived ? 'Received' : 'Not received',
                      style: TextStyle(
                        fontSize: 11,
                        color: isReceived
                            ? AppTheme.success
                            : AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Toggle switch
                    Switch(
                      value: isReceived,
                      onChanged: onToggle,
                      activeColor: AppTheme.success,
                      inactiveThumbColor: AppTheme.error,
                      inactiveTrackColor:
                      AppTheme.error.withOpacity(0.25),
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),

              // ── Reason field — only when toggled OFF ─────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: !isReceived
                    ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: TextFormField(
                    controller: reasonController,
                    textInputAction: TextInputAction.done,
                    onChanged: onReasonChanged,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText:
                      'Reason not collected (optional)',
                      hintStyle: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppTheme.background,
                      isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppTheme.radiusSmall,
                        borderSide: BorderSide(
                          color: AppTheme.error.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppTheme.radiusSmall,
                        borderSide: BorderSide(
                          color: AppTheme.error.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppTheme.radiusSmall,
                        borderSide: const BorderSide(
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}