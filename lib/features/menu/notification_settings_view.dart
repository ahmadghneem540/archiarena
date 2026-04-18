import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/services/fcm_service.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة إعدادات الإشعارات.
class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'notification_settings'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection('posts_and_interactions'.tr, [
              _SwitchRow(title: 'likes'.tr, value: true, onChanged: (_) {}),
              _SwitchRow(title: 'comments'.tr, value: true, onChanged: (_) {}),
              _SwitchRow(title: 'replies_to_comments'.tr, value: true, onChanged: (_) {}),
              _SwitchRow(title: 'mentions'.tr, value: false, onChanged: (_) {}),
            ]),
            const SizedBox(height: 20),
            _buildSection('friendships_and_follow'.tr, [
              _SwitchRow(title: 'friend_requests'.tr, value: true, onChanged: (_) {}),
              _SwitchRow(title: 'accept_friend_request'.tr, value: true, onChanged: (_) {}),
              _SwitchRow(title: 'follow_requests'.tr, value: false, onChanged: (_) {}),
            ]),
            const SizedBox(height: 20),
            _buildSection('projects_and_work'.tr, [
              _SwitchRow(title: 'project_comments'.tr, value: true, onChanged: (_) {}),
              _SwitchRow(title: 'job_offers_messages'.tr, value: true, onChanged: (_) {}),
            ]),
            const SizedBox(height: 20),
            _buildSection('general'.tr, [
              _SwitchRow(title: 'sound_notifications'.tr, value: false, onChanged: (_) {}),
              _SwitchRow(title: 'vibration'.tr, value: true, onChanged: (_) {}),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
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
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  e.value,
                  if (!isLast) Divider(height: 1, thickness: 1, color: AppColors.border, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.value, required this.onChanged});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.onSurface),
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}
