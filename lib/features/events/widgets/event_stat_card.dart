// lib/features/events/widgets/event_stat_card.dart

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A compact stat card used on event dashboards and detail screens.
/// Shows an icon, a numeric value, and a label.
///
/// Usage:
/// ```dart
/// EventStatCard(
///   label: 'Checked In',
///   value: 42,
///   icon: Icons.how_to_reg_outlined,
///   color: AppTheme.success,
/// )
/// ```
class EventStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  /// If true, renders in a more compact form (smaller font, less padding).
  final bool compact;

  const EventStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 140;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: AppTheme.radiusMedium,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: compact ? 16 : (isTablet ? 22 : 18),
                    color: color,
                  ),
                  Text(
                    '$value',
                    style: TextStyle(
                      color: color,
                      fontSize: compact
                          ? 18
                          : (isTablet ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 4 : 6),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.85),
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w500,
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