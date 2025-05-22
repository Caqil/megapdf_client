import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB); // Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Green
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Background Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Feature Specific Colors
  static const Color compressColor = Color(0xFF8B5CF6); // Purple
  static const Color splitColor = Color(0xFF06B6D4); // Cyan
  static const Color mergeColor = Color(0xFF10B981); // Green
  static const Color watermarkColor = Color(0xFFF59E0B); // Amber
  static const Color convertColor = Color(0xFFEF4444); // Red
  static const Color protectColor = Color(0xFF8B5CF6); // Purple
  static const Color unlockColor = Color(0xFF10B981); // Green
  static const Color rotateColor = Color(0xFF06B6D4); // Cyan
  static const Color pageNumbersColor = Color(0xFFF59E0B); // Amber

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}
