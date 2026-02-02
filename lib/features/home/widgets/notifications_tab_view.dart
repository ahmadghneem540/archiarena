import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';
import '../models/notification_model.dart';

/// شاشة التاب الخامس — الإشعارات (التفاعلات، التعليقات، قبول الصداقات).
class NotificationsTabView extends StatelessWidget {
  const NotificationsTabView({super.key, required this.controller});

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
          const SizedBox(height: 24),
          Obx(() => _buildNotificationsList(context)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'الإشعارات',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.search, color: AppColors.onSurface, size: 26),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    final list = controller.notifications;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'لا توجد إشعارات جديدة',
            style: TextStyle(fontSize: 15, color: AppColors.grey600),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'جديد',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final notification = list[index];
            return _NotificationTile(notification: notification);
          },
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final initial = notification.senderName.isNotEmpty
        ? notification.senderName[0]
        : '؟';
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.senderName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey700,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(fontSize: 12, color: AppColors.grey500),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_horiz, color: AppColors.grey600, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
      ),
    );
  }
}
