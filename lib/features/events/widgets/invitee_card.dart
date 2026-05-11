// lib/features/events/widgets/invitee_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_invite_model.dart';

/// Full invitee card displayed in the event_detail_screen invitee list.
/// Shows name, branch/phone, attendance status, QR email state,
/// gift count, and an optional delete action.
///
/// Usage:
/// ```dart
/// InviteeCard(
///   invite: invite,
///   onDelete: () => bloc.add(DeleteInvite(invite.id)),
/// )
/// ```
class InviteeCard extends StatelessWidget {
  final EventInviteModel invite;

  /// Called when the delete icon is tapped. If null, delete icon is hidden.
  final VoidCallback? onDelete;

  /// If true, renders a slightly more compact layout.
  final bool compact;

  const InviteeCard({
    Key? key,
    required this.invite,
    this.onDelete,
    this.compact = false,
  }) : super(key: key);

  // ---------------------------------------------------------------------------
  // Status helpers
  // ---------------------------------------------------------------------------

  Color get _statusColor {
    switch (invite.attendanceStatus) {
      case 'checked_in':
        return AppTheme.checkedInGreenIcon;
      case 'checked_out':
        return AppTheme.checkedOutBlueIcon;
      default:
        return AppTheme.pendingOrangeIcon;
    }
  }

  Color get _statusBg {
    switch (invite.attendanceStatus) {
      case 'checked_in':
        return AppTheme.checkedInGreen;
      case 'checked_out':
        return AppTheme.checkedOutBlue;
      default:
        return AppTheme.pendingOrange;
    }
  }

  String get _statusLabel {
    switch (invite.attendanceStatus) {
      case 'checked_in':
        return 'Checked In';
      case 'checked_out':
        return 'Checked Out';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 500;

        return Container(
          padding: EdgeInsets.all(compact ? 10 : (isTablet ? 16 : 12)),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: AppTheme.radiusMedium,
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: AppTheme.greyLight.withOpacity(0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: compact ? 16 : (isTablet ? 22 : 18),
                backgroundColor:
                const Color(0xFF7B1FA2).withOpacity(0.12),
                child: Text(
                  invite.name.isNotEmpty
                      ? invite.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: const Color(0xFF7B1FA2),
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 12 : (isTablet ? 16 : 13),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Main info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invite.name,
                            style: AppTheme.labelLarge.copyWith(
                              fontSize: compact
                                  ? 13
                                  : (isTablet ? 15 : 14),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StatusBadge(
                          label: _statusLabel,
                          color: _statusColor,
                          bg: _statusBg,
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Branch or phone
                    Text(
                      invite.isPmlilStaff && invite.branchName != null
                          ? invite.branchName!
                          : invite.phone,
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (!compact) ...[
                      const SizedBox(height: 6),
                      _buildMetaRow(isTablet),
                    ],
                  ],
                ),
              ),

              // Delete button — only when deletable
              if (onDelete != null &&
                  !invite.isCheckedIn &&
                  !invite.isCheckedOut) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppTheme.error.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaRow(bool isTablet) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        // QR email status
        _MetaChip(
          icon: invite.qrEmailSent
              ? Icons.mark_email_read_outlined
              : Icons.email_outlined,
          label: invite.qrEmailSent ? 'QR Sent' : 'QR Pending',
          color: invite.qrEmailSent
              ? AppTheme.success
              : AppTheme.textTertiary,
        ),

        // Gifts
        _MetaChip(
          icon: Icons.card_giftcard_outlined,
          label: '${invite.assignedGifts.length} gift(s)',
          color: AppTheme.textSecondary,
        ),

        // Check-in time
        if (invite.checkInTime != null)
          _MetaChip(
            icon: Icons.login_rounded,
            label: DateFormat('HH:mm')
                .format(invite.checkInTime!.toDate()),
            color: AppTheme.checkedInGreenIcon,
          ),

        // Check-out time
        if (invite.checkOutTime != null)
          _MetaChip(
            icon: Icons.logout_rounded,
            label: DateFormat('HH:mm')
                .format(invite.checkOutTime!.toDate()),
            color: AppTheme.checkedOutBlueIcon,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTheme.radiusSmall,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}