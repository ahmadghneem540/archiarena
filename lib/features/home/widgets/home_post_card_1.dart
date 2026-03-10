import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/const_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';
import '../models/post_model.dart';
import 'home_interaction_row.dart';

class HomePostCard1 extends StatelessWidget {
  const HomePostCard1({
    super.key,
    required this.controller,
    required this.post,
  });

  final HomeController controller;
  final PostModel post;

  String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = ConstData.API_BASE;
    return base.endsWith('/') ? '$base$url' : '$base/$url';
  }

  @override
  Widget build(BuildContext context) {
    final authorInitial = (post.authorName?.isNotEmpty == true)
        ? post.authorName!.substring(0, 1).toUpperCase()
        : 'A';
    final imageUrl = _fullImageUrl(post.imageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        authorInitial,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.createdAt ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.category != null && post.category!.isNotEmpty)
                    Text(
                      post.category!,
                      style: TextStyle(fontSize: 13, color: AppColors.grey700),
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
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.placeholder1,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.description ?? post.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((post.budget != null && post.budget!.isNotEmpty) ||
                      (post.deadline != null && post.deadline!.isNotEmpty)) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (post.budget != null && post.budget!.isNotEmpty)
                          Expanded(
                            child: Row(
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
                                      color: AppColors.grey700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (post.deadline != null && post.deadline!.isNotEmpty)
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    post.deadline!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                        child: ArchiButton(
                          label: 'details_and_plans'.tr,
                          height: 44,
                          fontSize: 14,
                          onPressed: controller.openPost1DetailsSheet,
                        ),
                      ),
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
