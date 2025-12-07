import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class WelcomeCard extends StatelessWidget {
  final bool compact;
  final VoidCallback onCheckIn;

  const WelcomeCard({Key? key, required this.compact, required this.onCheckIn})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 28 : 36),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.elevatedShadow,
        border: Border.all(color: AppTheme.greyLight, width: 1),
      ),
      child: Column(
        children: [
          // Icon Container
          Container(
            width: compact ? 80 : 96,
            height: compact ? 80 : 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
              ),
              borderRadius: BorderRadius.circular(compact ? 20 : 24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.person_add,
              size: compact ? 40 : 48,
              color: AppTheme.white,
            ),
          ),

          SizedBox(height: compact ? 20 : 28),

          // Welcome Title
          Text(
            'Welcome to Our Office',
            style: TextStyle(
              fontSize: compact ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: compact ? 10 : 14),

          // Subtitle
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 24,
              vertical: compact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.info.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: compact ? 16 : 18,
                  color: AppTheme.info,
                ),
                SizedBox(width: compact ? 6 : 8),
                Flexible(
                  child: Text(
                    'Check in to notify your host',
                    style: TextStyle(
                      color: AppTheme.info,
                      fontSize: compact ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: compact ? 24 : 32),

          // Check In Button
          SizedBox(
            width: double.infinity,
            height: compact ? 56 : 64,
            child: ElevatedButton(
              onPressed: onCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(compact ? 14 : 16),
                ),
                elevation: 0,
                shadowColor: AppTheme.primaryRed.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: compact ? 24 : 28),
                  SizedBox(width: compact ? 12 : 14),
                  Text(
                    'Check In Now',
                    style: TextStyle(
                      fontSize: compact ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 10),
                  Icon(Icons.arrow_forward, size: compact ? 20 : 22),
                ],
              ),
            ),
          ),

          SizedBox(height: compact ? 16 : 20),

          // Feature Tags
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureTag(
                icon: Icons.speed,
                label: 'Quick & Easy',
                color: AppTheme.success,
                compact: compact,
              ),
              _buildFeatureTag(
                icon: Icons.notifications_active,
                label: 'Instant Alert',
                color: AppTheme.info,
                compact: compact,
              ),
              _buildFeatureTag(
                icon: Icons.verified_user,
                label: 'Secure',
                color: AppTheme.totalPurpleIcon,
                compact: compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag({
    required IconData icon,
    required String label,
    required Color color,
    required bool compact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
