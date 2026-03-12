import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';

/// شاشة التاب السادس — القائمة (الإعدادات والخيارات).
class MenuTabView extends StatelessWidget {
  const MenuTabView({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 28),
          _buildSectionTitle('الحساب'),
          const SizedBox(height: 8),
          _buildMenuCard(
            context,
            children: [
              _MenuItem(
                icon: Icons.person_outline_rounded,
                title: 'تعديل الملف الشخصي',
                onTap: () => controller.selectTab(HomeTab.profile),
              ),
              _MenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'الخصوصية والأمان',
                onTap: () => Get.toNamed(AppRoutes.menuPrivacySecurity),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('التفضيلات'),
          const SizedBox(height: 8),
          _buildMenuCard(
            context,
            children: [
              _MenuItem(
                icon: Icons.language_rounded,
                title: 'language'.tr,
                subtitle: _currentLanguageSubtitle(),
                onTap: () => Get.toNamed(AppRoutes.menuLanguage),
              ),
              _MenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'المظهر',
                subtitle: 'فاتح',
                onTap: () => Get.toNamed(AppRoutes.menuAppearance),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('الدعم'),
          const SizedBox(height: 8),
          _buildMenuCard(
            context,
            children: [
              _MenuItem(
                icon: Icons.help_outline_rounded,
                title: 'المساعدة والدعم',
                onTap: () => Get.toNamed(AppRoutes.menuHelpSupport),
              ),
              _MenuItem(
                icon: Icons.feedback_outlined,
                title: 'إرسال ملاحظات',
                onTap: () => Get.toNamed(AppRoutes.menuFeedback),
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                title: 'الشروط وسياسة الخصوصية',
                onTap: () => Get.toNamed(AppRoutes.termsAndPrivacy),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('حول التطبيق'),
          const SizedBox(height: 8),
          _buildMenuCard(
            context,
            children: [
              _MenuItem(
                icon: Icons.info_outline_rounded,
                title: 'حول archiarena',
                subtitle: 'الإصدار 1.0.0',
                onTap: () => Get.toNamed(AppRoutes.menuAbout),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _currentLanguageSubtitle() {
    final code = Get.locale?.languageCode ?? 'ar';
    if (code == 'ar') return 'lang_arabic'.tr;
    if (code == 'de') return 'lang_german'.tr;
    return 'lang_english'.tr;
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'القائمة',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.grey600,
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          final isLast = index == children.length - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                  indent: 56,
                  endIndent: 12,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.logout(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
              const SizedBox(width: 8),
              const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.grey500,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
