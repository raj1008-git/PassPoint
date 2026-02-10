import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  void _handleReceptionistAccess(BuildContext context) {
    devLog('Receptionist button pressed');
    Navigator.of(context).pushNamed('/receptionist-login');
  }

  void _handleHQStaffAccess(BuildContext context) {
    devLog('HQ Staff button pressed');
    Navigator.of(context).pushNamed('/staff-auth', arguments: {'isHQ': true});
  }

  void _handleBranchStaffAccess(BuildContext context) {
    devLog('Branch Staff button pressed');
    Navigator.of(context).pushNamed('/staff-auth', arguments: {'isHQ': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 48 : 24,
                    vertical: isTablet ? 40 : 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Branding
                      _buildBranding(isTablet),

                      SizedBox(height: isTablet ? 48 : 40),

                      // Title
                      Text(
                        'Who are you?',
                        style: TextStyle(
                          fontSize: isTablet ? 32 : 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isTablet ? 12 : 8),

                      Text(
                        'Select your role to continue',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isTablet ? 56 : 48),

                      // PHASE 3: 3 Role Cards
                      if (isLandscape && isTablet)
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleCard(
                                context: context,
                                title: 'Reception',
                                subtitle: 'KAMALADI HQ only',
                                icon: Icons.business_center,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryRed,
                                    AppTheme.primaryRedDark,
                                  ],
                                ),
                                onTap: () => _handleReceptionistAccess(context),
                                isTablet: true,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildRoleCard(
                                context: context,
                                title: 'HQ Staff',
                                subtitle: 'KAMALADI with departments',
                                icon: Icons.apartment,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.info,
                                    AppTheme.info.withOpacity(0.8),
                                  ],
                                ),
                                onTap: () => _handleHQStaffAccess(context),
                                isTablet: true,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildRoleCard(
                                context: context,
                                title: 'Branch Staff',
                                subtitle: '140 branches across Nepal',
                                icon: Icons.location_city,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.success,
                                    AppTheme.success.withOpacity(0.8),
                                  ],
                                ),
                                onTap: () => _handleBranchStaffAccess(context),
                                isTablet: true,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildRoleCard(
                              context: context,
                              title: 'Reception',
                              subtitle: 'KAMALADI HQ only',
                              icon: Icons.business_center,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryRed,
                                  AppTheme.primaryRedDark,
                                ],
                              ),
                              onTap: () => _handleReceptionistAccess(context),
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isTablet ? 24 : 20),
                            _buildRoleCard(
                              context: context,
                              title: 'HQ Staff',
                              subtitle: 'KAMALADI with departments',
                              icon: Icons.apartment,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.info,
                                  AppTheme.info.withOpacity(0.8),
                                ],
                              ),
                              onTap: () => _handleHQStaffAccess(context),
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isTablet ? 24 : 20),
                            _buildRoleCard(
                              context: context,
                              title: 'Branch Staff',
                              subtitle: '140 branches across Nepal',
                              icon: Icons.location_city,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.success,
                                  AppTheme.success.withOpacity(0.8),
                                ],
                              ),
                              onTap: () => _handleBranchStaffAccess(context),
                              isTablet: isTablet,
                            ),
                          ],
                        ),

                      SizedBox(height: isTablet ? 48 : 40),

                      // Footer
                      Text(
                        '© 2025 PassPoint. All rights reserved.',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBranding(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: isTablet ? 96 : 80,
          height: isTablet ? 96 : 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
            ),
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRed.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.business,
            color: AppTheme.white,
            size: isTablet ? 48 : 40,
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text(
          'Pass Point',
          style: TextStyle(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isTablet ? 8 : 6),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 10 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.dark.withOpacity(0.95), AppTheme.darkLight],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: isTablet ? 16 : 14,
                color: AppTheme.white,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Powered by ',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: AppTheme.white.withOpacity(0.8),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppTheme.primaryRed,
                    AppTheme.info,
                    AppTheme.success,
                  ],
                ).createShader(bounds),
                child: Text(
                  'Nexora AI',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 32 : 28),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          boxShadow: AppTheme.elevatedShadow,
          border: Border.all(
            color: AppTheme.greyLight.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: isTablet ? 96 : 80,
              height: isTablet ? 96 : 80,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppTheme.white,
                size: isTablet ? 48 : 40,
              ),
            ),

            SizedBox(height: isTablet ? 24 : 20),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 12 : 8),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 24 : 20),

            // Tap indicator
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 10 : 8,
              ),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tap to Continue',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.white,
                    size: isTablet ? 20 : 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
