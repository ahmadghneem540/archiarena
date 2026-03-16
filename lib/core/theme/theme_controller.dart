import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/const_data.dart';
import '../services/services.dart';

/// يتحكم بوضع المظهر (فاتح / داكن / تلقائي) ويحفظ الاختيار.
class ThemeController extends GetxController {
  ThemeController({ThemeMode? initialMode}) {
    themeMode = (initialMode ?? ThemeMode.system).obs;
  }

  late final Rx<ThemeMode> themeMode;

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _stringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await MyServices.saveStringValue(ConstData.keyThemeMode, _stringFromThemeMode(mode));
  }

  /// للعرض في القائمة: "فاتح" / "داكن" / "تلقائي"
  String get currentThemeLabel {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'light'.tr;
      case ThemeMode.dark:
        return 'dark'.tr;
      case ThemeMode.system:
        return 'auto'.tr;
    }
  }

  static Future<ThemeMode> loadSavedThemeMode() async {
    final saved = await MyServices.getStringValue(ConstData.keyThemeMode);
    return _themeModeFromString(saved);
  }
}
