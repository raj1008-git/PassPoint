import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;

  const StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.backgroundColor,
    required this.iconColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 200;

        return Container(
          padding: EdgeInsets.all(isCompact ? 12 : 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppTheme.radiusMedium,
            border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isCompact ? 40 : 48,
                    height: isCompact ? 40 : 48,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: isCompact ? 20 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            count.toString(),
                            style: AppTheme.h2.copyWith(
                              color: iconColor,
                              fontSize: isCompact ? 24 : 28,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTheme.labelLarge.copyWith(
                  fontSize: isCompact ? 14 : 15,
                  color: AppTheme.dark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
