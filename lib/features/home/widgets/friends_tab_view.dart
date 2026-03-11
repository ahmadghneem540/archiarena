import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';
import '../models/friend_request_model.dart';
import '../models/user_profile_model.dart';
import 'other_user_profile_page.dart';
import 'shimmer_loading.dart';

/// شاشة التاب الثالث — الأصدقاء وطلبات الصداقة.
class FriendsTabView extends StatelessWidget {
  const FriendsTabView({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Text(
            'الأصدقاء',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          _buildTabs(context),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isSuggestionsLoading.value) {
              return Column(
                children: List.generate(4, (_) => const ShimmerListTile(leadingSize: 48, titleWidth: 140, subtitleWidth: 80)),
              );
            }
            return _buildSuggestionsSection(context);
          }),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.isFriendRequestsLoading.value) {
              return Column(
                children: List.generate(3, (_) => const ShimmerListTile(leadingSize: 56, titleWidth: 120, subtitleWidth: 60)),
              );
            }
            return _buildFriendRequestsSection(context);
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'اقتراحات',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'أصدقاؤك',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    final list = controller.suggestionUsers;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'no_suggestions'.tr,
            style: TextStyle(fontSize: 15, color: AppColors.grey600),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اقتراحات أصدقاء',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final user = list[index];
            return _SuggestionCard(
              user: user,
              onTap: () {
                controller.loadOtherUserProfile(user.id);
                controller.loadOtherUserPosts(user.id);
                Get.to(
                  () => OtherUserProfilePage(
                    controller: controller,
                    user: user,
                    fromRequest: false,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFriendRequestsSection(BuildContext context) {
    final count = controller.friendRequests.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'طلبات الصداقة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (count > 0)
              TextButton(onPressed: () {}, child: Text('show_all'.tr)),
          ],
        ),
        const SizedBox(height: 16),
        if (count == 0)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'no_friend_requests'.tr,
                style: TextStyle(fontSize: 15, color: AppColors.grey600),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: count,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = controller.friendRequests[index];
              final profileUserId = request.senderUserId ?? request.id;
              final user = UserProfileModel(
                id: profileUserId,
                name: request.name,
                mutualCount: request.mutualCount,
                profilePicture: request.avatarPath,
              );
              return _FriendRequestCard(
                controller: controller,
                request: request,
                user: user,
                onConfirm: () => controller.acceptFriendRequest(request.id),
                onDelete: () => controller.rejectFriendRequest(request.id),
              );
            },
          ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.user, required this.onTap});

  final UserProfileModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0] : '؟';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
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
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (user.mutualCount > 0)
                    Text(
                      user.mutualCount == 1
                          ? 'mutual_friend'.tr
                          : '${user.mutualCount} ${'mutual_friends'.tr}',
                      style: TextStyle(fontSize: 13, color: AppColors.grey600),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: AppColors.grey500),
          ],
        ),
      ),
    );
  }
}

class _FriendRequestCard extends StatelessWidget {
  const _FriendRequestCard({
    required this.controller,
    required this.request,
    required this.user,
    required this.onConfirm,
    required this.onDelete,
  });

  final HomeController controller;
  final FriendRequestModel request;
  final UserProfileModel user;
  final VoidCallback onConfirm;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initial = request.name.isNotEmpty ? request.name[0] : '؟';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          controller.loadOtherUserProfile(user.id);
          controller.loadOtherUserPosts(user.id);
          Get.to(
            () => OtherUserProfilePage(
              controller: controller,
              user: user,
              fromRequest: true,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: (request.avatarPath != null && request.avatarPath!.isNotEmpty)
                  ? NetworkImage(request.avatarPath!)
                  : null,
              child: (request.avatarPath == null || request.avatarPath!.isEmpty)
                  ? Text(
                      initial.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.mutualCount == 0
                        ? 'no_mutual_friends'.tr
                        : request.mutualCount == 1
                        ? 'mutual_friend'.tr
                        : '${request.mutualCount} ${'mutual_friends'.tr}',
                    style: TextStyle(fontSize: 13, color: AppColors.grey600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ArchiButton(
                            label: 'accept'.tr,
                            height: 38,
                            fontSize: 14,
                            onPressed: onConfirm,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.grey700,
                          side: BorderSide(color: AppColors.grey400),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          minimumSize: const Size(0, 38),
                        ),
                        child: Text('reject'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  request.timeAgo,
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
                const SizedBox(height: 4),
                Text(
                  'عرض الملف',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
