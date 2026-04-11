import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/chat_inbox_view.dart';
import '../home_controller.dart';

class _HomeHeaderMessagesButton extends StatelessWidget {
  const _HomeHeaderMessagesButton({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'chat_inbox_title'.tr,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openChatInbox(),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: scheme.primary,
                  size: 28,
                ),
                Obx(() {
                  final count = controller.chatUnreadMessageCount.value;
                  if (count <= 0) return const SizedBox.shrink();
                  final label = count > 99 ? '99+' : '$count';
                  return Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: BoxDecoration(
                        color: scheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: scheme.onError,
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
        ),
      ),
    );
  }
}

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _HomeHeaderMessagesButton(controller: controller),
              Text(
                'app_brand_name'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: Obx(() {
            final _ = controller.currentTab.value;
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
                // أيقونة الطلبات — للشركات فقط
                Obx(() {
                  if (!controller.isCompany.value) return const SizedBox.shrink();
                  return Expanded(
                    child: _HomeOrderTabIcon(controller: controller),
                  );
                }),
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
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => controller.selectTab(tab),
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Icon(
          isSelected ? icon : iconOutlined,
          color: isSelected ? scheme.primary : context.themeGrey600,
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
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => controller.selectTab(HomeTab.orders),
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Image.asset(
          isSelected ? 'assets/order_icon.png' : 'assets/order_icon_out.png',
          width: 24,
          height: 24,
          color: isSelected ? scheme.primary : context.themeGrey600,
          errorBuilder: (context, error, stackTrace) {
            // في حالة عدم وجود الصورة، استخدم أيقونة بديلة
            return Icon(
              isSelected ? Icons.receipt_long : Icons.receipt_long_outlined,
              color: isSelected ? scheme.primary : context.themeGrey600,
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
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => controller.selectTab(HomeTab.groups),
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isSelected ? Icons.groups_rounded : Icons.groups_outlined,
              color: isSelected ? scheme.primary : context.themeGrey600,
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
                  decoration: BoxDecoration(
                    color: scheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: scheme.onError,
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
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => controller.selectTab(HomeTab.notifications),
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isSelected ? Icons.notifications : Icons.notifications_none,
              color: isSelected ? scheme.primary : context.themeGrey600,
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
                  decoration: BoxDecoration(
                    color: scheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: scheme.onError,
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
