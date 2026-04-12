import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../chat/chat_inbox_view.dart';
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
          _buildHeader(context),
          const SizedBox(height: 28),
          _buildSectionTitle(context, 'account'.tr),
          const SizedBox(height: 8),
          _buildMenuCard(
            context,
            children: [
              Obx(() {
                final n = controller.chatPendingRequestCount.value;
                return _MenuItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'chat_inbox_title'.tr,
                  badgeCount: n > 0 ? n : null,
                  onTap: openChatInbox,
                );
              }),
              _MenuItem(
                icon: Icons.person_outline_rounded,
                title: 'edit_profile_title'.tr,
                onTap: () => controller.selectTab(HomeTab.profile),
              ),
              _MenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'privacy_security'.tr,
                onTap: () => Get.toNamed(AppRoutes.menuPrivacySecurity),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'preferences'.tr),
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
              Obx(() => _MenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'appearance'.tr,
                subtitle: Get.find<ThemeController>().currentThemeLabel,
                onTap: () => Get.toNamed(AppRoutes.menuAppearance),
              )),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'support'.tr),
          const SizedBox(height: 8),
          _buildMenuCard(
            context,
            children: [
              _MenuItem(
                icon: Icons.help_outline_rounded,
                title: 'support'.tr,
                onTap: () => Get.toNamed(AppRoutes.menuHelpSupport),
              ),
              _MenuItem(
                icon: Icons.feedback_outlined,
                title: 'send_feedback'.tr,
                onTap: () => Get.toNamed(AppRoutes.menuFeedback),
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                title: 'terms_and_privacy_policy'.tr,
                onTap: () => Get.toNamed(AppRoutes.menuTermsPrivacy),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'about_app'.tr),
          const SizedBox(height: 8),
          _buildMenuCard(
            context,
            children: [
              _MenuItem(
                icon: Icons.info_outline_rounded,
                title: 'about_app'.tr,
                subtitle: 'الإصدار 1.0.0'.tr,
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'menu'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.themeOnSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.themeGrey600,
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
        color: context.themeCardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.themeBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.themeShadowLight,
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
                  color: context.themeBorder,
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
               Text(
                'logout'.tr,
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
    this.badgeCount,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int? badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grey500 = isDark ? AppColors.darkGrey500 : AppColors.grey500;
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.themeOnSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.themeGrey600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badgeCount != null && badgeCount! > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsetsDirectional.only(end: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                  child: Center(
                    child: Text(
                      badgeCount! > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              Icon(
                Icons.chevron_left_rounded,
                color: grey500,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
