import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة اختيار اللغة.
class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    final options = ['lang_arabic'.tr, 'lang_english'.tr, 'lang_german'.tr];
    final currentLanguage = Get.locale?.languageCode == 'ar'
        ? 'lang_arabic'.tr
        : Get.locale?.languageCode == 'de'
            ? 'lang_german'.tr
            : 'lang_english'.tr;
    return MenuPageScaffold(
      title: 'language'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'choose_app_language'.tr,
              style: TextStyle(fontSize: 14, color: AppColors.grey600, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: options.asMap().entries.map((e) {
                  final isSelected = e.value == currentLanguage;
                  final isLast = e.key == options.length - 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) Divider(height: 1, thickness: 1, color: AppColors.border, indent: 16, endIndent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
