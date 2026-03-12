import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'archiarena',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: Obx(() {
            final _ = controller.currentTab.value;
            final isCompany = controller.isCompany.value;
            return Row(
              children: [
                Expanded(
                  child: _HomeTabIcon(
                    controller: controller,
                    tab: HomeTab.home,
                    icon: Icons.home_rounded,
                    iconOutlined: Icons.home_outlined,
                  ),
                ),
                Expanded(
                  child: _HomeTabIcon(
                    controller: controller,
                    tab: HomeTab.work,
                    icon: Icons.work_rounded,
                    iconOutlined: Icons.work_outline,
                  ),
                ),
                // أيقونة الطلبات (فقط للشركات)
                if (isCompany)
                  Expanded(
                    child: _HomeOrderTabIcon(controller: controller),
                  ),
                Expanded(
                  child: _HomeGroupsTabIcon(controller: controller),
                ),
                Expanded(
                  child: _HomeTabIcon(
                    controller: controller,
                    tab: HomeTab.profile,
                    icon: Icons.person_rounded,
                    iconOutlined: Icons.person_outline,
                  ),
                ),
                Expanded(
                  child: _HomeNotificationTabIcon(controller: controller),
                ),
                Expanded(
                  child: _HomeTabIcon(
                    controller: controller,
                    tab: HomeTab.menu,
                    icon: Icons.menu,
                    iconOutlined: Icons.menu,
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _HomeTabIcon extends StatelessWidget {
  const _HomeTabIcon({
    required this.controller,
    required this.tab,
    required this.icon,
    required this.iconOutlined,
  });

  final HomeController controller;
  final HomeTab tab;
  final IconData icon;
  final IconData iconOutlined;

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.currentTab.value == tab;
    return InkWell(
      onTap: () => controller.selectTab(tab),
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Icon(
          isSelected ? icon : iconOutlined,
          color: isSelected ? AppColors.primary : AppColors.grey600,
          size: 28,
        ),
      ),
    );
  }
}

class _HomeOrderTabIcon extends StatelessWidget {
  const _HomeOrderTabIcon({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.currentTab.value == HomeTab.orders;
    return InkWell(
      onTap: () => controller.selectTab(HomeTab.orders),
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Image.asset(
          isSelected ? 'assets/order_icon.png' : 'assets/order_icon_out.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            // في حالة عدم وجود الصورة، استخدم أيقونة بديلة
            return Icon(
              isSelected ? Icons.receipt_long : Icons.receipt_long_outlined,
              color: isSelected ? AppColors.primary : AppColors.grey600,
              size: 24,
            );
          },
        ),
      ),
    );
  }
}

class _HomeGroupsTabIcon extends StatelessWidget {
  const _HomeGroupsTabIcon({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.currentTab.value == HomeTab.groups;
    return InkWell(
      onTap: () => controller.selectTab(HomeTab.groups),
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isSelected ? Icons.groups_rounded : Icons.groups_outlined,
              color: isSelected ? AppColors.primary : AppColors.grey600,
              size: 28,
            ),
            Obx(() {
              final count = controller.friendRequestCount.value;
              if (count <= 0) return const SizedBox.shrink();
              return Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HomeNotificationTabIcon extends StatelessWidget {
  const _HomeNotificationTabIcon({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.currentTab.value == HomeTab.notifications;
    return InkWell(
      onTap: () => controller.selectTab(HomeTab.notifications),
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isSelected ? Icons.notifications : Icons.notifications_none,
              color: isSelected ? AppColors.primary : AppColors.grey600,
              size: 28,
            ),
            Obx(() {
              final count = controller.notificationCount.value;
              if (count <= 0) return const SizedBox.shrink();
              return Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
