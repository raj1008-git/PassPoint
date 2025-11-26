import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/pin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../admin/widgets/pin_dialog.dart';
import 'checkin_screen.dart';

class VisitorWelcomeScreen extends StatelessWidget {
  const VisitorWelcomeScreen({Key? key}) : super(key: key);

  Future<void> _handleAdminAccess(BuildContext context) async {
    devLog('Admin button pressed');
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!context.mounted) return;

    final enteredPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PinDialog(),
    );

    if (enteredPin == null || enteredPin.isEmpty) return;

    final isValidPin = await PinService.verifyPin(enteredPin);
    if (!context.mounted) return;

    if (!isValidPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect PIN code'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (isLoggedIn) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    } else {
      Navigator.of(context).pushNamed('/admin-login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                final isLandscape = orientation == Orientation.landscape;

                final maxWidth = isTablet ? 600.0 : constraints.maxWidth * 0.9;

                if (isLandscape && isTablet) {
                  // ===============================
                  // LANDSCAPE MODE (Tablet)
                  // ===============================
                  return Row(
                    children: [
                      // LEFT SIDE = Logo + text (compact)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRed,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.elevatedShadow,
                                ),
                                child: const Icon(
                                  Icons.business,
                                  size: 40,
                                  color: AppTheme.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'VisitorEase',
                                style: AppTheme.h2.copyWith(
                                  color: AppTheme.primaryRed,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Streamlined visitor management\nfor modern organizations',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // RIGHT SIDE = Main Card + Features
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
                          child: Center(
                            child: Container(
                              width: maxWidth,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 32,
                              ),
                              child: Column(
                                children: [
                                  // ----------- MAIN CARD ------------
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      borderRadius: AppTheme.radiusLarge,
                                      boxShadow: AppTheme.elevatedShadow,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryRed,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person_add,
                                            size: 36,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Welcome to Our Office',
                                          style: AppTheme.h3,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Please check in to notify your host of your arrival',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 28),

                                        // BUTTON
                                        SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              devLog('Check In Now pressed');
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const CheckInScreen(),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppTheme.primaryRed,
                                              foregroundColor: AppTheme.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    AppTheme.radiusMedium,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.login, size: 22),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Check In Now',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // ------------ FEATURES STACKED -----------
                                  // ------------ FEATURES HORIZONTAL -----------
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Expanded(
                                        child: _FeatureCard(
                                          icon: Icons.schedule,
                                          iconColor: AppTheme.info,
                                          title: 'Quick Process',
                                          subtitle:
                                              'Complete check-in in under 2 minutes',
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _FeatureCard(
                                          icon: Icons.notifications_active,
                                          iconColor: AppTheme.success,
                                          title: 'Instant Notification',
                                          subtitle:
                                              'Your host will be notified immediately',
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _FeatureCard(
                                          icon: Icons.security,
                                          iconColor: AppTheme.totalPurpleIcon,
                                          title: 'Secure & Private',
                                          subtitle:
                                              'Your data is protected and encrypted',
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 30),

                                  // FOOTER
                                  Column(
                                    children: [
                                      Text(
                                        '© 2025 VisitorEase. All rights reserved.',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.textTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _handleAdminAccess(context),
                                        icon: const Icon(
                                          Icons.shield_outlined,
                                          size: 18,
                                        ),
                                        label: const Text('Admin Dashboard'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppTheme.dark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // ===========================
                // PORTRAIT MODE (Original UI)
                // ===========================
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isTablet ? 60 : 40),

                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.elevatedShadow,
                            ),
                            child: const Icon(
                              Icons.business,
                              size: 50,
                              color: AppTheme.white,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'VisitorEase',
                            style: AppTheme.h2.copyWith(
                              color: AppTheme.primaryRed,
                              fontSize: 28,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Streamlined visitor management for modern organizations',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 60),

                          // Main Card
                          Center(
                            child: Container(
                              width: maxWidth,
                              padding: EdgeInsets.all(isTablet ? 48 : 32),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: AppTheme.radiusLarge,
                                boxShadow: AppTheme.elevatedShadow,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryRed,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.person_add,
                                      size: 40,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Welcome to Our Office',
                                    style: AppTheme.h3,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Please check in to notify your host of your arrival',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        devLog('Check In Now button pressed');
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CheckInScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryRed,
                                        foregroundColor: AppTheme.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppTheme.radiusMedium,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.login, size: 24),
                                          SizedBox(width: 12),
                                          Text(
                                            'Check In Now',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Features Row
                          Container(
                            width: maxWidth,
                            child: Row(
                              children: const [
                                Expanded(
                                  child: _FeatureCard(
                                    icon: Icons.schedule,
                                    iconColor: AppTheme.info,
                                    title: 'Quick Process',
                                    subtitle:
                                        'Complete check-in in under 2 minutes',
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _FeatureCard(
                                    icon: Icons.notifications_active,
                                    iconColor: AppTheme.success,
                                    title: 'Instant Notification',
                                    subtitle:
                                        'Your host will be notified immediately',
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _FeatureCard(
                                    icon: Icons.security,
                                    iconColor: AppTheme.totalPurpleIcon,
                                    title: 'Secure & Private',
                                    subtitle:
                                        'Your data is protected and encrypted',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isTablet ? 60 : 40),

                          // Footer
                          Column(
                            children: [
                              Text(
                                '© 2025 VisitorEase. All rights reserved.',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () => _handleAdminAccess(context),
                                icon: const Icon(
                                  Icons.shield_outlined,
                                  size: 18,
                                ),
                                label: const Text('Admin Dashboard'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.dark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTheme.labelLarge, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
