import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/app_direction.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة المظهر (فاتح / داكن / تلقائي).
class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final options = [
      (ThemeMode.light, 'light'.tr, Icons.light_mode_rounded),
      (ThemeMode.dark, 'dark'.tr, Icons.dark_mode_rounded),
      (ThemeMode.system, 'auto'.tr, Icons.brightness_auto_rounded),
    ];
    return MenuPageScaffold(
      title: 'appearance'.tr,
      child: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'choose_appearance'.tr,
                style: TextStyle(fontSize: 14, color: context.themeGrey600, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: context.themeCardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.themeBorder),
                  boxShadow: [BoxShadow(color: context.themeShadowLight, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Obx(() {
                  final current = themeController.themeMode.value;
                  return Column(
                    children: options.asMap().entries.map((e) {
                      final mode = e.value.$1;
                      final label = e.value.$2;
                      final icon = e.value.$3;
                      final isSelected = current == mode;
                      final isLast = e.key == options.length - 1;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () async {
                              await themeController.setThemeMode(mode);
                              Get.back();
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(icon, color: AppColors.primary, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected ? AppColors.primary : context.themeOnSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast) Divider(height: 1, thickness: 1, color: context.themeBorder, indent: 70, endIndent: 16),
                        ],
                      );
                    }).toList(),
                  );
                }),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
