import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_direction.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة حول التطبيق.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'about_app'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Text(
                      'archiarena',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'archiarena',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.themeOnSurface,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'app_version'.tr.replaceAll('{version}', '1.0.0'),
                  style: TextStyle(fontSize: 14, color: context.themeGrey600),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.themeCardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.themeBorder),
                ),
                child: Text(
                  'about_app_desc'.tr,
                  textAlign: TextAlign.center,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(fontSize: 15, color: context.themeGrey700, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              _buildRow(context, 'terms_and_conditions'.tr, () => Get.toNamed(AppRoutes.menuTermsPrivacy)),
              const SizedBox(height: 10),
              _buildRow(context, 'privacy_policy'.tr, () => Get.toNamed(AppRoutes.menuTermsPrivacy)),
              const SizedBox(height: 10),
              _buildRow(context, 'app_license'.tr, () =>Get.toNamed(AppRoutes.menuLicense)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.themeCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.themeBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.themeOnSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.themeGrey600, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
