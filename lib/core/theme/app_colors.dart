import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static Color primary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFF3333) : const Color(0xFFFF0000);
  static Color primaryLight(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFF6666) : const Color(0xFFFF4D4D);
  static Color primaryDark(BuildContext context) =>
      _isDark(context) ? const Color(0xFF990000) : const Color(0xFFB30000);

  // Secondary Colors
  static Color secondary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFF8080) : const Color(0xFFFF6666);
  static Color secondaryLight(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFFB3B3) : const Color(0xFFFF9999);
  static Color secondaryDark(BuildContext context) =>
      _isDark(context) ? const Color(0xFFCC3333) : const Color(0xFFCC3333);

  // Text Colors
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFE6E6E6) : const Color(0xFF1F1F1F);
  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFB3B3B3) : const Color(0xFF666666);
  static Color textMuted(BuildContext context) =>
      _isDark(context) ? const Color(0xFF808080) : const Color(0xFF999999);

  // Background Colors
  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1A1A1A) : const Color(0xFFFFF5F5);
  static Color surface(BuildContext context) =>
      _isDark(context) ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF);
  static Color surfaceVariant(BuildContext context) =>
      _isDark(context) ? const Color(0xFF3D2D2D) : const Color(0xFFFFE6E6);

  // Border Colors
  static Color border(BuildContext context) =>
      _isDark(context) ? const Color(0xFF5C3D3D) : const Color(0xFFFFB3B3);
  static Color borderLight(BuildContext context) =>
      _isDark(context) ? const Color(0xFF805050) : const Color(0xFFFFD9D9);

  // Status Colors
  static Color success(BuildContext context) =>
      const Color(0xFF4CAF50); // Consistent across themes
  static Color warning(BuildContext context) => const Color(0xFFFFA726);
  static Color error(BuildContext context) => const Color(0xFFEF4444);
  static Color info(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFF8080) : const Color(0xFFFF6666);

  // Feature-Specific Colors
  static Color compressColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFF6666) : const Color(0xFFFF4D4D);
  static Color splitColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFF8080) : const Color(0xFFFF8080);
  static Color mergeColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFFB3B3) : const Color(0xFFFF6666);
  static Color watermarkColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFFA726) : const Color(0xFFFFA726);
  static Color convertColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFEF4444) : const Color(0xFFEF4444);
  static Color protectColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF990000) : const Color(0xFFB30000);
  static Color unlockColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFF8080) : const Color(0xFFFF6666);
  static Color rotateColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFFB3B3) : const Color(0xFFFF8080);
  static Color pageNumbersColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFFA726) : const Color(0xFFFFA726);

  // Gradients
  static LinearGradient primaryGradient(BuildContext context) => LinearGradient(
        colors: [
          primary(context),
          primaryLight(context),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient successGradient(BuildContext context) => LinearGradient(
        colors: [
          success(context),
          const Color(0xFF66BB6A),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Shadow Colors
  static Color shadow(BuildContext context) => const Color(0x1A000000);
  static Color shadowLight(BuildContext context) => const Color(0x0D000000);

  // Helper to check if dark mode is active
  static bool _isDark(BuildContext context) =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;
}
