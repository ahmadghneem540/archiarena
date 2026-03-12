import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/profile_api_service.dart';
import '../../features/home/home_controller.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة الخصوصية والأمان.
class PrivacySecurityView extends StatelessWidget {
  const PrivacySecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return MenuPageScaffold(
      title: 'privacy_security'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'account'.tr,
              items: [
                Obx(() => _SwitchItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'private_account'.tr,
                  subtitle: 'private_account_desc'.tr,
                  value: controller.isProfileLocked.value,
                  onChanged: (v) => _onVisibilityChanged(controller, v),
                )),
              ],
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'security'.tr,
              items: [
                _TapItem(
                  icon: Icons.key_rounded,
                  title: 'change_password'.tr,
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _onVisibilityChanged(HomeController controller, bool isLocked) async {
    final res = await ProfileApiService.updateVisibility(isProfileLocked: isLocked);
    if (res.isSuccess) {
      controller.isProfileLocked.value = isLocked;
      controller.myProfile = controller.myProfile.copyWith(isProfileLocked: isLocked);
      Get.snackbar(
        'success'.tr,
        isLocked ? 'private_account_enabled'.tr : 'private_account_disabled'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } else {
      Get.snackbar('error'.tr, res.message ?? 'error_occurred'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.items});

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: _separated(items),
          ),
        ),
      ],
    );
  }

  List<Widget> _separated(List<Widget> list) {
    final out = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      out.add(list[i]);
      if (i < list.length - 1) {
        out.add(Divider(height: 1, thickness: 1, color: AppColors.border, indent: 56, endIndent: 12));
      }
    }
    return out;
  }
}

class _SwitchItem extends StatelessWidget {
  const _SwitchItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: TextStyle(fontSize: 13, color: AppColors.grey600)),
                ],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _TapItem extends StatelessWidget {
  const _TapItem({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: TextStyle(fontSize: 13, color: AppColors.grey600)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: AppColors.grey500, size: 24),
          ],
        ),
      ),
    );
  }
}

Widget _iconBox(IconData icon) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: AppColors.primary, size: 22),
  );
}
