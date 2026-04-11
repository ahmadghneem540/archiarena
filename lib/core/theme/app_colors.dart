import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---- Light theme ----
  static const Color primary = Color(0xFF198090); // teal
  static const Color primaryDark = Color(0xFF6ECDDB); // dark blue

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

  // ---- Dark theme ----
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceContainer = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color darkInputBackground = Color(0xFF2C2C2C);

  static const Color darkOnSurface = Color(0xFFE8E8E8);
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0B0);

  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkBorderLight = Color(0xFF4A4A4A);

  static const Color darkGrey300 = Color(0xFF404040);
  static const Color darkGrey400 = Color(0xFF606060);
  static const Color darkGrey500 = Color(0xFF808080);
  static const Color darkGrey600 = Color(0xFF9E9E9E);
  static const Color darkGrey700 = Color(0xFFB0B0B0);

  static const Color darkPlaceholder1 = Color(0xFF2A2826);
  static const Color darkPlaceholder2 = Color(0xFF1E2C2C);
  static const Color darkPlaceholder3 = Color(0xFF2C2620);

  static Color get darkShadowLight => Colors.black.withValues(alpha: 0.3);

  /// Theme-aware colors: use these in widgets so light/dark switch correctly.
  static Color surfaceBy(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;
  static Color cardBackgroundBy(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardBackground : cardBackground;
  static Color onSurfaceBy(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkOnSurface : onSurface;
  static Color onSurfaceVariantBy(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkOnSurfaceVariant : onSurfaceVariant;
  static Color borderBy(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;
  static Color grey600By(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkGrey600 : grey600;
  static Color grey700By(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkGrey700 : grey700;
  static Color grey300By(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkGrey300 : grey300;
  static Color grey400By(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkGrey400 : grey400;
  static Color grey500By(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkGrey500 : grey500;
  static Color placeholder1By(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPlaceholder1 : placeholder1;
  static Color shadowLightBy(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkShadowLight : shadowLight;
  static Color inputBackgroundBy(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkInputBackground : inputBackground;
}

/// Extension for theme-aware colors in build methods.
extension ThemeColorsExtension on BuildContext {
  Color get themeSurface => AppColors.surfaceBy(this);
  Color get themeCardBackground => AppColors.cardBackgroundBy(this);
  Color get themeOnSurface => AppColors.onSurfaceBy(this);
  Color get themeOnSurfaceVariant => AppColors.onSurfaceVariantBy(this);
  Color get themeBorder => AppColors.borderBy(this);
  Color get themeGrey300 => AppColors.grey300By(this);
  Color get themeGrey400 => AppColors.grey400By(this);
  Color get themeGrey500 => AppColors.grey500By(this);
  Color get themeGrey600 => AppColors.grey600By(this);
  Color get themeGrey700 => AppColors.grey700By(this);
  Color get themePlaceholder1 => AppColors.placeholder1By(this);
  Color get themeShadowLight => AppColors.shadowLightBy(this);
  Color get themeInputBackground => AppColors.inputBackgroundBy(this);

  /// ألوان من [ColorScheme] — تتبع الفاتح/الداكن تلقائياً.
  Color get themePrimary => Theme.of(this).colorScheme.primary;
  Color get themeError => Theme.of(this).colorScheme.error;
  Color get themeOnError => Theme.of(this).colorScheme.onError;

  /// خلفية فقاعة رسالة واردة — في الوضع الليلي رمادي واضح وليس أسود الخلفية.
  Color get themeChatBubbleReceived {
    if (Theme.of(this).brightness == Brightness.dark) {
      return AppColors.darkCardBackground;
    }
    return Theme.of(this).colorScheme.surfaceContainerHighest;
  }
}
