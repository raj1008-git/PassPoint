import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class BrandingCard extends StatelessWidget {
  final bool compact;

  const BrandingCard({Key? key, required this.compact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pass Point Logo Card
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 24 : 32,
            vertical: compact ? 16 : 20,
          ),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: AppTheme.radiusLarge,
            boxShadow: AppTheme.elevatedShadow,
            border: Border.all(
              color: AppTheme.primaryRed.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 48 : 56,
                height: compact ? 48 : 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
                  ),
                  borderRadius: BorderRadius.circular(compact ? 12 : 14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRed.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.business,
                  color: AppTheme.white,
                  size: compact ? 28 : 32,
                ),
              ),
              SizedBox(width: compact ? 16 : 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pass Point',
                    style: TextStyle(
                      fontSize: compact ? 22 : 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Visitor Management System',
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: compact ? 12 : 16),

        // Powered by Nexora AI Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 20,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.dark.withOpacity(0.9),
                AppTheme.darkLight.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(compact ? 24 : 28),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: AppTheme.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: compact ? 16 : 18,
                  color: AppTheme.white,
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
              Text(
                'Powered by ',
                style: TextStyle(
                  color: AppTheme.white.withOpacity(0.8),
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppTheme.primaryRed,
                    AppTheme.info,
                    AppTheme.success,
                  ],
                ).createShader(bounds),
                child: Text(
                  'Nexora AI',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: compact ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
