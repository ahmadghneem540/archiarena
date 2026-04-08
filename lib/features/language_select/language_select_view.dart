import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'language_select_controller.dart';

/// الواجهة الأولى — اختيار اللغة (عربي، ألماني، إنجليزي)
class LanguageSelectView extends GetView<LanguageSelectController> {
  const LanguageSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/app_logo.png',
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.architecture,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'choose_language'.tr,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'choose_language_desc'.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey600,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildLanguageOption('العربية', 'ar', '🇸🇦'),
              const SizedBox(height: 12),
              _buildLanguageOption('Deutsch', 'de', '🇩🇪'),
              const SizedBox(height: 12),
              _buildLanguageOption('English', 'en', '🇬🇧'),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildLanguageOption(String label, String code, String flag) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => controller.selectLanguage(code),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
