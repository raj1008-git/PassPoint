import 'package:flutter/material.dart';

class AppTheme {
  // Primary Brand Color
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color primaryRedLight = Color(0xFFEF5350);
  static const Color primaryRedDark = Color(0xFFC62828);

  // Status Colors
  static const Color pendingOrange = Color(0xFFFFF3E0);
  static const Color pendingOrangeBorder = Color(0xFFFFB74D);
  static const Color pendingOrangeIcon = Color(0xFFFF9800);

  static const Color checkedInGreen = Color(0xFFE8F5E9);
  static const Color checkedInGreenBorder = Color(0xFF66BB6A);
  static const Color checkedInGreenIcon = Color(0xFF4CAF50);

  static const Color checkedOutBlue = Color(0xFFE3F2FD);
  static const Color checkedOutBlueBorder = Color(0xFF64B5F6);
  static const Color checkedOutBlueIcon = Color(0xFF2196F3);

  static const Color totalPurple = Color(0xFFF3E5F5);
  static const Color totalPurpleBorder = Color(0xFFBA68C8);
  static const Color totalPurpleIcon = Color(0xFF9C27B0);

  // Neutral Colors
  static const Color dark = Color(0xFF2C3E50);
  static const Color darkLight = Color(0xFF34495E);
  static const Color grey = Color(0xFF95A5A6);
  static const Color greyLight = Color(0xFFECF0F1);
  static const Color greyDark = Color(0xFF7F8C8D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);

  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // Border Radius
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(
    Radius.circular(20),
  );

  // Spacing
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;

  // Text Styles
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textTertiary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );
}
