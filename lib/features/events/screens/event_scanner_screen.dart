// lib/features/events/screens/event_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_invite_model.dart';
import '../../../data/repositories/event_gift_repository.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/repositories/invite_repository.dart';

class EventScannerScreen extends StatefulWidget {
  const EventScannerScreen({Key? key}) : super(key: key);

  @override
  State<EventScannerScreen> createState() => _EventScannerScreenState();
}

class _EventScannerScreenState extends State<EventScannerScreen> {
  final MobileScannerController _scannerController =
  MobileScannerController();
  final InviteRepository _inviteRepository = InviteRepository(
    eventRepository: EventRepository(),
    giftRepository: EventGiftRepository(),
  );

  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) return;

    setState(() => _isProcessing = true);
    await _scannerController.stop();

    devLog('EventScannerScreen: scanned', params: {'token': raw});

    try {
      final invite = await _inviteRepository.resolveQrToken(raw.trim());
      if (!mounted) return;

      if (invite.isCheckedIn) {
        // Scan 2 — go to gift confirmation
        await Navigator.of(context).pushNamed(
          '/gift-confirmation',
          arguments: {'invite': invite},
        );
      } else {
        // Scan 1 — show check-in confirmation card
        await _showCheckInSheet(invite);
      }
    } catch (e) {
      devLog(
        'EventScannerScreen: scan error',
        params: {'error': e.toString()},
      );
      if (mounted) _showErrorSheet(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        await _scannerController.start();
      }
    }
  }

  Future<void> _showCheckInSheet(EventInviteModel invite) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckInConfirmSheet(
        invite: invite,
        onConfirm: () async {
          Navigator.pop(context);
          await _inviteRepository.confirmCheckIn(invite.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${invite.name} checked in ✓'),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium),
              ),
            );
          }
        },
      ),
    );
  }

  void _showErrorSheet(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ErrorSheet(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppTheme.white,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _torchOn ? Colors.amber : AppTheme.white,
            ),
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Overlay
          _buildScanOverlay(),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.65;
        final top = (constraints.maxHeight - size) / 2.5;
        final left = (constraints.maxWidth - size) / 2;

        return Stack(
          children: [
            // Dimmed background with cutout
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.55),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    top: top,
                    left: left,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: AppTheme.radiusLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Corner brackets
            Positioned(
              top: top,
              left: left,
              child: _ScanFrame(size: size),
            ),

            // Instruction text
            Positioned(
              top: top + size + 24,
              left: 0,
              right: 0,
              child: const Text(
                'Point camera at invitee\'s QR code',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Scan frame decorative corners
// ---------------------------------------------------------------------------

class _ScanFrame extends StatelessWidget {
  final double size;
  const _ScanFrame({required this.size});

  @override
  Widget build(BuildContext context) {
    const stroke = 3.0;
    const len = 24.0;
    const color = Color(0xFFAB47BC);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
            stroke: stroke, len: len, color: color, radius: 16),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double stroke;
  final double len;
  final Color color;
  final double radius;

  _CornerPainter({
    required this.stroke,
    required this.len,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
        Offset(radius, 0), Offset(len + radius, 0), paint);
    canvas.drawLine(
        Offset(0, radius), Offset(0, len + radius), paint);
    canvas.drawArc(Rect.fromLTWH(0, 0, radius * 2, radius * 2),
        3.14159, 0.5 * 3.14159, false, paint);

    // Top-right
    canvas.drawLine(
        Offset(size.width - len - radius, 0),
        Offset(size.width - radius, 0),
        paint);
    canvas.drawLine(Offset(size.width, radius),
        Offset(size.width, len + radius), paint);
    canvas.drawArc(
        Rect.fromLTWH(
            size.width - radius * 2, 0, radius * 2, radius * 2),
        1.5 * 3.14159,
        0.5 * 3.14159,
        false,
        paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - len - radius),
        Offset(0, size.height - radius), paint);
    canvas.drawLine(
        Offset(radius, size.height),
        Offset(len + radius, size.height),
        paint);
    canvas.drawArc(
        Rect.fromLTWH(
            0, size.height - radius * 2, radius * 2, radius * 2),
        0.5 * 3.14159,
        0.5 * 3.14159,
        false,
        paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - len - radius),
        Offset(size.width, size.height - radius), paint);
    canvas.drawLine(
        Offset(size.width - len - radius, size.height),
        Offset(size.width - radius, size.height),
        paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width - radius * 2,
            size.height - radius * 2, radius * 2, radius * 2),
        0,
        0.5 * 3.14159,
        false,
        paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ---------------------------------------------------------------------------
// Check-in confirmation bottom sheet
// ---------------------------------------------------------------------------

class _CheckInConfirmSheet extends StatelessWidget {
  final EventInviteModel invite;
  final VoidCallback onConfirm;

  const _CheckInConfirmSheet({
    required this.invite,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.greyLight,
              borderRadius: AppTheme.radiusSmall,
            ),
          ),
          const SizedBox(height: 20),

          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor:
            const Color(0xFF7B1FA2).withOpacity(0.12),
            child: Text(
              invite.name.isNotEmpty ? invite.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color(0xFF7B1FA2),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            invite.name,
            style: AppTheme.h3,
            textAlign: TextAlign.center,
          ),

          if (invite.isPmlilStaff && invite.branchName != null) ...[
            const SizedBox(height: 4),
            Text(
              invite.branchName!,
              style: AppTheme.bodyMedium,
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Gifts preview
          if (invite.assignedGifts.isNotEmpty) ...[
            Text(
              'Assigned Gifts (${invite.assignedGifts.length})',
              style: AppTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            ...invite.assignedGifts.map(
                  (g) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard_outlined,
                        size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(g.giftName, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Text(
              'No gifts assigned',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
          ],

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusMedium),
                    side: const BorderSide(color: AppTheme.greyLight),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusMedium),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Check In',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error bottom sheet
// ---------------------------------------------------------------------------

class _ErrorSheet extends StatelessWidget {
  final String message;
  const _ErrorSheet({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.greyLight,
              borderRadius: AppTheme.radiusSmall,
            ),
          ),
          const SizedBox(height: 20),
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.error,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Scan Failed',
            style: AppTheme.h3.copyWith(color: AppTheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium),
                elevation: 0,
              ),
              child: const Text('Try Again'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}