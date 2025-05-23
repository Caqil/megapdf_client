import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFFFF0000), // AppColors.Light.primary
    scaffoldBackgroundColor:
        const Color(0xFFFFF5F5), // AppColors.Light.background
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF0000),
      secondary: Color(0xFFFF6666),
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFEF4444),
      onPrimary: Color(0xFF1F1F1F),
      onSecondary: Color(0xFF666666),
      onSurface: Color(0xFF1F1F1F),
      onError: Color(0xFF1F1F1F),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1F1F1F)),
      bodyMedium: TextStyle(color: Color(0xFF666666)),
      bodySmall: TextStyle(color: Color(0xFF999999)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF0000),
        foregroundColor: const Color(0xFF1F1F1F),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF0000),
      foregroundColor: Color(0xFF1F1F1F),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFFFF3333), // AppColors.Dark.primary
    scaffoldBackgroundColor:
        const Color(0xFF1A1A1A), // AppColors.Dark.background
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF3333),
      secondary: Color(0xFFFF8080),
      surface: Color(0xFF2D2D2D),
      error: Color(0xFFEF4444),
      onPrimary: Color(0xFFE6E6E6),
      onSecondary: Color(0xFFB3B3B3),
      onSurface: Color(0xFFE6E6E6),
      onError: Color(0xFFE6E6E6),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE6E6E6)),
      bodyMedium: TextStyle(color: Color(0xFFB3B3B3)),
      bodySmall: TextStyle(color: Color(0xFF808080)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF3333),
        foregroundColor: const Color(0xFFE6E6E6),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF3333),
      foregroundColor: Color(0xFFE6E6E6),
    ),
  );
}
