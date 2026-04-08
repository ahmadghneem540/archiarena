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
          Text(
            'friends'.tr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.themeOnSurface,
            ),
          ),
          const SizedBox(height: 24),
          _buildMyFriendsSection(context),
          const SizedBox(height: 24),
          _buildFriendRequestsSection(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMyFriendsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'my_friends'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.themeOnSurface,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isMyFriendsLoading.value) {
            return Column(
              children: List.generate(
                4,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ShimmerListTile(leadingSize: 56, titleWidth: 140, subtitleWidth: 80),
                ),
              ),
            );
          }
          final list = controller.myFriends;
          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: context.themeCardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.themeBorder),
              ),
              child: Column(
                children: [
                  Icon(Icons.people_outline_rounded, size: 48, color: AppColors.grey400),
                  const SizedBox(height: 12),
                  Text(
                    'no_friends_yet'.tr,
                    style: TextStyle(fontSize: 15, color: context.themeGrey600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: context.themeCardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.themeBorder),
              boxShadow: [
                BoxShadow(
                  color: context.themeShadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                color: context.themeBorder,
                indent: 72,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final friend = list[index];
                final user = UserProfileModel(
                  id: friend.senderUserId ?? friend.id,
                  name: friend.name,
                  mutualCount: friend.mutualCount,
                  profilePicture: friend.avatarPath,
                );
                return _FriendCard(
                  friend: friend,
                  onTap: () {
                    controller.loadMyFriends();
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
          );
        }),
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
                Text(
                  'friend_requests_title'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.themeOnSurface,
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
          ],
        ),
        const SizedBox(height: 16),
        if (count == 0)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'no_friend_requests'.tr,
                style: TextStyle(fontSize: 15, color: context.themeGrey600),
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

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend, required this.onTap});

  final FriendRequestModel friend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = friend.name.isNotEmpty ? friend.name[0] : '؟';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundImage: (friend.avatarPath != null && friend.avatarPath!.isNotEmpty)
                    ? NetworkImage(friend.avatarPath!)
                    : null,
                child: (friend.avatarPath == null || friend.avatarPath!.isEmpty)
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.themeOnSurface,
                      ),
                    ),
                    if (friend.mutualCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        friend.mutualCount == 1
                            ? 'mutual_friend'.tr
                            : '${friend.mutualCount} ${'mutual_friends'.tr}',
                        style: TextStyle(fontSize: 13, color: context.themeGrey600),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: AppColors.grey500, size: 24),
            ],
          ),
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
        color: context.themeCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.themeBorder),
        boxShadow: [
          BoxShadow(
            color: context.themeShadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: InkWell(
        onTap: () {
          controller.loadMyFriends();
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
                      style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                        color: context.themeOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.mutualCount == 0
                        ? 'no_mutual_friends'.tr
                        : request.mutualCount == 1
                        ? 'mutual_friend'.tr
                        : '${request.mutualCount} ${'mutual_friends'.tr}',
                      style: TextStyle(fontSize: 13, color: context.themeGrey600),
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
                        foregroundColor: context.themeGrey700,
                        side: BorderSide(color: context.themeBorder),
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
                  style: TextStyle(fontSize: 12, color: context.themeGrey600),
                ),
                const SizedBox(height: 4),
                Text(
                  'show_file'.tr,
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
