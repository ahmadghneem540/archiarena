import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00A79E); // teal
  static const Color primaryDark = Color(0xFF1A237E); // dark blue

  static const Color surface = Colors.white;
  static const Color inputBackground = Color(0xFFF2F2F7);
  static const Color cardBackground = Color(0xFFF8F8F8);

  static const Color onSurface = Color(0xFF1C1C1E);
  static const Color onSurfaceVariant = Color(0xFF8E8E93);

  static const Color border = Color(0xFFE5E5EA);
  static const Color borderLight = Color(0xFFC7C7CC);

  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  static const Color placeholder1 = Color(0xFFE8E4DF);
  static const Color placeholder2 = Color(0xFFE0EDED);
  static const Color placeholder3 = Color(0xFFF5E6D3);

  static const Color error = Colors.red;
  static const Color onPrimary = Colors.white;
  static const Color transparent = Colors.transparent;

  static const Color link = Color(0xFF007AFF);

  static Color get shadowLight => Colors.black.withValues(alpha: 0.06);
}
