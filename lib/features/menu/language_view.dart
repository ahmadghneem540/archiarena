import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/const_data.dart';
import '../../core/services/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_direction.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة اختيار اللغة.
class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  static const List<({String label, String code})> _options = [
    (label: 'ar', code: 'ar'),
    (label: 'en', code: 'en'),
    (label: 'de', code: 'de'),
  ];

  Future<void> _selectLanguage(String code) async {
    await MyServices.saveStringValue(ConstData.keyLocale, code);
    Get.updateLocale(Locale(code));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = Get.locale?.languageCode ?? 'ar';
    final locale = Get.locale?.languageCode ?? 'en';

    final isRTL = locale == 'ar';
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,

      child: MenuPageScaffold(
        title: 'language'.tr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'choose_app_language'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.themeGrey600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: context.themeCardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.themeBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: _options.asMap().entries.map((e) {
                      final opt = e.value;
                      final isSelected = opt.code == currentCode;
                      final isLast = e.key == _options.length - 1;

                      final label = opt.code == 'ar'
                          ? 'lang_arabic'.tr
                          : opt.code == 'de'
                          ? 'lang_german'.tr
                          : 'lang_english'.tr;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => _selectLanguage(opt.code),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primary
                                            : context.themeOnSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          if (!isLast)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: context.themeBorder,
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}