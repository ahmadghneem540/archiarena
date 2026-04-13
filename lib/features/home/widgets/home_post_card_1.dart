import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constant/const_data.dart';
import '../../../core/utils/post_published_at_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/fullscreen_image_viewer.dart';
import '../../../widget/gradient_button.dart';
import '../../../widget/safe_circle_avatar.dart';
import '../home_controller.dart';
import '../models/post_model.dart';
import 'countdown_timer.dart';
import 'home_interaction_row.dart';

class HomePostCard1 extends StatelessWidget {
  const HomePostCard1({
    super.key,
    required this.controller,
    required this.post,
    this.isInWorks = false,
  });

  final HomeController controller;
  final PostModel post;
  final bool isInWorks;

  String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = ConstData.API_BASE;
    final path = url.startsWith('/') ? url : '/$url';
    return base.endsWith('/') ? '$base${path.substring(1)}' : '$base$path';
  }

  @override
  Widget build(BuildContext context) {
    final authorInitial = (post.authorName?.isNotEmpty == true)
        ? post.authorName!.substring(0, 1).toUpperCase()
        : 'A';
    final myProfileId = controller.myProfile.id;
    final isMe = post.authorId != null &&
        (post.authorId == myProfileId || post.authorId == 'me');
    final avatarUrl = post.authorAvatar != null && post.authorAvatar!.isNotEmpty
        ? _fullImageUrl(post.authorAvatar)
        : (isMe &&
                controller.myProfile.profilePicture != null &&
                controller.myProfile.profilePicture!.isNotEmpty
            ? controller.myProfile.profilePicture
            : null);
    final imageUrl = _fullImageUrl(post.imageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.themeCardBackground, // ⭐ أصبح رمادي في الداكن
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SafeCircleAvatar(
                    radius: 16,
                    imageUrl: imageUrl,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    fallback: Text(
                      authorInitial,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName ?? post.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: context.themeOnSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (post.createdAt != null &&
                            post.createdAt!.trim().isNotEmpty)
                          Text(
                            formatPostPublishedAt(post.createdAt),
                            style: TextStyle(
                              fontSize: 13,
                              color: context.themeGrey600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (post.category != null && post.category!.isNotEmpty)
                    Text(
                      post.category!,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.themeGrey700,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.placeholder1,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl.isNotEmpty
                    ? GestureDetector(
                        onTap: () =>
                            FullscreenImageViewer.open(context, imageUrl),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (_, __) => Container(
                            color: AppColors.placeholder1,
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    post.authorName ?? post.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: context.themeOnSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.description ?? post.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.themeGrey700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((post.budget != null && post.budget!.isNotEmpty) ||
                      (post.deadline != null && post.deadline!.isNotEmpty) ||
                      post.hasDealTimer) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.budget != null && post.budget!.isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'project_cost'.tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.themeGrey600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        post.budget!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.themeOnSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (post.deadline != null && post.deadline!.isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'project_deadline_remaining'.tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.themeGrey600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                CountdownTimer(
                                  deadline: post.deadline,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),
                        if (post.hasDealTimer)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'deal_timer'.tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.themeGrey600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (post.isDealExpired)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event_busy_outlined,
                                        size: 18,
                                        color: context.themeGrey600,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'project_time_ended'.tr,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: context.themeGrey600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                else if (post.timerEndsAt != null)
                                  CountdownTimer(
                                    deadlineAt: post.timerEndsAt,
                                    iconSize: 18,
                                  )
                                else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule_outlined,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          post.projectTimer!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: context.themeOnSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: HomeInteractionRow(
                          likesCount: post.likesCount,
                          commentsCount: post.commentsCount,
                          isLikedValue: post.isLiked,
                          onLike: () => controller.togglePostLike(post.id),
                          onComment: () =>
                              controller.openCommentsSheet(post.id),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: isInWorks && post.isDealExpired
                            ? const SizedBox(height: 44)
                            : ArchiButton(
                                label: isInWorks
                                    ? 'upload_project'.tr
                                    : 'details_and_plans'.tr,
                                height: 44,
                                fontSize: 14,
                                onPressed: isInWorks
                                    ? () => controller.openUploadPage(post: post)
                                    : () => controller.openPostDetailsSheet(post),
                              ),
                      ),
                      if (isInWorks) ...[
                        const SizedBox(width: 8),
                        Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final snackBg = context.themeCardBackground;
                              final confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  title: Text('remove_from_works'.tr),
                                  content: Text('remove_from_works_confirm'.tr),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: Text('cancel'.tr),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: Text('remove_from_works'.tr),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final removed = await controller.removePostFromWorks(post.id);
                                if (removed) {
                                  Get.snackbar(
                                    'success'.tr,
                                    'removed_from_works'.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: snackBg,
                                    margin: const EdgeInsets.all(12),
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.delete_outline,
                                size: 24,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.placeholder1,
      child: Icon(
        Icons.image_not_supported,
        color: AppColors.grey400,
        size: 48,
      ),
    );
  }
}