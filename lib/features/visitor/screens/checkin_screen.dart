import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/repositories/visitor_repository.dart';
import '../widgets/checkin_form.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  Future<void> _handleSubmit({
    required BuildContext context,
    required String name,
    required String phone,
    String? email,
    required String toMeet,
    required String purpose,
    required File photoFile,
    String? departmentId,
    String? departmentName,
  }) async {
    final repo = VisitorRepository();

    try {
      devLog(
        'Starting createVisitor flow',
        params: {'name': name, 'department': departmentName},
      );

      await repo.createVisitor(
        name: name,
        phone: phone,
        email: email,
        toMeet: toMeet,
        purpose: purpose,
        photoFile: photoFile,
        departmentId: departmentId,
        departmentName: departmentName,
      );

      devLog('Visitor created, showing confirmation');

      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 50,
                      color: AppTheme.success,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Check-In Submitted!',
                    style: AppTheme.h3,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Welcome, $name',
                    style: AppTheme.h3.copyWith(
                      fontSize: 20,
                      color: AppTheme.dark,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Your check-in request has been received',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.business,
                          label: 'Department',
                          value: departmentName ?? 'N/A',
                          color: AppTheme.primaryRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.person,
                          label: 'Meeting With',
                          value: toMeet,
                          color: AppTheme.info,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // What's Next
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.greyLight.withOpacity(0.5),
                      borderRadius: AppTheme.radiusSmall,
                      border: Border.all(color: AppTheme.greyLight),
                    ),
                    child: Column(
                      children: [
                        const Text('What\'s Next?', style: AppTheme.labelLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Please have a seat in the reception area. Our receptionist will verify your details and check you in shortly.',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your host has been notified',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusSmall,
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      devLog('Error in _handleSubmit', params: {'error': e.toString()});
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.dark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Visitor Check-In',
          style: TextStyle(color: AppTheme.dark),
        ),
      ),
      body: CheckInForm(
        onSubmit:
            ({
              required String name,
              required String phone,
              String? email,
              required String toMeet,
              required String purpose,
              required File photoFile,
              String? departmentId,
              String? departmentName,
            }) async {
              await _handleSubmit(
                context: context,
                name: name,
                phone: phone,
                email: email,
                toMeet: toMeet,
                purpose: purpose,
                photoFile: photoFile,
                departmentId: departmentId,
                departmentName: departmentName,
              );
            },
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: AppTheme.radiusSmall,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.labelMedium.copyWith(color: AppTheme.dark),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
