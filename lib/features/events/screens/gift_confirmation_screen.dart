// lib/features/events/screens/gift_confirmation_screen.dart

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_invite_model.dart';
import '../../../data/repositories/event_gift_repository.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/repositories/invite_repository.dart';

class GiftConfirmationScreen extends StatefulWidget {
  const GiftConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<GiftConfirmationScreen> createState() =>
      _GiftConfirmationScreenState();
}

class _GiftConfirmationScreenState extends State<GiftConfirmationScreen> {
  final InviteRepository _repository = InviteRepository(
    eventRepository: EventRepository(),
    giftRepository: EventGiftRepository(),
  );

  late EventInviteModel _invite;

  // giftId → received toggle (all ON by default)
  late Map<String, bool> _receivedToggles;

  // giftId → reason text if toggled OFF
  final Map<String, String> _reasons = {};
  final Map<String, TextEditingController> _reasonControllers = {};

  bool _isSubmitting = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments
      as Map<String, dynamic>;
      _invite = args['invite'] as EventInviteModel;

      // All gifts ON by default
      _receivedToggles = {
        for (final g in _invite.assignedGifts) g.giftId: true,
      };

      for (final g in _invite.assignedGifts) {
        _reasonControllers[g.giftId] = TextEditingController();
      }

      _initialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in _reasonControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);

    try {
      final outcomes = <String, ({bool received, String? reason})>{};

      for (final gift in _invite.assignedGifts) {
        final received = _receivedToggles[gift.giftId] ?? true;
        final reason = received
            ? null
            : _reasonControllers[gift.giftId]?.text.trim().isNotEmpty == true
            ? _reasonControllers[gift.giftId]!.text.trim()
            : 'Declined';

        outcomes[gift.giftId] = (received: received, reason: reason);
      }

      await _repository.confirmGiftCollectionAndCheckOut(
        inviteId: _invite.id,
        giftOutcomes: outcomes,
      );

      devLog('GiftConfirmationScreen: checkout complete');

      if (mounted) {
        final receivedCount =
            outcomes.values.where((o) => o.received).length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Checked out — $receivedCount gift(s) collected',
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusMedium),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      devLog(
        'GiftConfirmationScreen: error',
        params: {'error': e.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusMedium),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Gift Collection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 32 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Invitee card
                      _buildInviteeCard(isTablet),

                      SizedBox(height: isTablet ? 24 : 20),

                      // Gifts section
                      Text(
                        'Confirm Gift Collection',
                        style: AppTheme.h3.copyWith(
                          fontSize: isTablet ? 20 : 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toggle OFF any gift not collected. All are ON by default.',
                        style: AppTheme.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      if (_invite.assignedGifts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: AppTheme.radiusMedium,
                          ),
                          child: const Text(
                            'No gifts assigned to this invitee.',
                            style: AppTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ..._invite.assignedGifts.map(
                              (gift) => _buildGiftToggleRow(gift, isTablet),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom confirm bar
              _buildConfirmBar(isTablet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInviteeCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
            color: const Color(0xFF7B1FA2).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 28 : 24,
            backgroundColor:
            const Color(0xFF7B1FA2).withOpacity(0.12),
            child: Text(
              _invite.name.isNotEmpty
                  ? _invite.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: const Color(0xFF7B1FA2),
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _invite.name,
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 16 : 15,
                  ),
                ),
                if (_invite.isPmlilStaff &&
                    _invite.branchName != null) ...[
                  const SizedBox(height: 2),
                  Text(_invite.branchName!, style: AppTheme.bodySmall),
                ],
                const SizedBox(height: 2),
                Text(_invite.phone, style: AppTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.checkedInGreen,
              borderRadius: AppTheme.radiusSmall,
              border: Border.all(color: AppTheme.checkedInGreenBorder),
            ),
            child: const Text(
              'Checked In',
              style: TextStyle(
                color: AppTheme.checkedInGreenIcon,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftToggleRow(AssignedGift gift, bool isTablet) {
    final isOn = _receivedToggles[gift.giftId] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: isOn
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.card_giftcard_outlined,
                  size: 20,
                  color: isOn ? AppTheme.success : AppTheme.textTertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    gift.giftName,
                    style: AppTheme.labelLarge.copyWith(
                      fontSize: isTablet ? 15 : 14,
                      color: isOn
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                Switch(
                  value: isOn,
                  onChanged: (val) {
                    setState(() {
                      _receivedToggles[gift.giftId] = val;
                      if (val) _reasonControllers[gift.giftId]?.clear();
                    });
                  },
                  activeColor: AppTheme.success,
                  inactiveThumbColor: AppTheme.error,
                  inactiveTrackColor: AppTheme.error.withOpacity(0.3),
                ),
              ],
            ),
          ),

          // Reason field — visible only when toggled OFF
          if (!isOn)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: TextFormField(
                controller: _reasonControllers[gift.giftId],
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Reason not collected (optional)',
                  hintStyle: AppTheme.bodySmall,
                  filled: true,
                  fillColor: AppTheme.background,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: AppTheme.radiusSmall,
                    borderSide: BorderSide(
                        color: AppTheme.error.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppTheme.radiusSmall,
                    borderSide: BorderSide(
                        color: AppTheme.error.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppTheme.radiusSmall,
                    borderSide:
                    const BorderSide(color: AppTheme.error),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmBar(bool isTablet) {
    final receivedCount =
        _receivedToggles.values.where((v) => v).length;
    final total = _invite.assignedGifts.length;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 16,
        12,
        isTablet ? 32 : 16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$receivedCount of $total gift(s) to be collected',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (receivedCount == 0)
                Text(
                  'No gifts',
                  style: AppTheme.bodySmall
                      .copyWith(color: AppTheme.warning),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: isTablet ? 52 : 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
                foregroundColor: AppTheme.white,
                disabledBackgroundColor: AppTheme.greyLight,
                shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.white,
                ),
              )
                  : const Text(
                'Confirm & Check Out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}