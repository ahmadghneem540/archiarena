import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onPrimary,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 17,
      ),
    ),
  );
}
