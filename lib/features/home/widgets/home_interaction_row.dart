import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class HomeInteractionRow extends StatelessWidget {
  const HomeInteractionRow({
    super.key,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
  });

  final RxInt likes;
  final RxInt comments;
  final RxBool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: onLike,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLiked.value
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 22,
                        color: isLiked.value
                            ? AppColors.primary
                            : AppColors.grey600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${likes.value}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isLiked.value
                              ? AppColors.primary
                              : AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: AppColors.grey300),
          Expanded(
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: onComment,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 22,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${comments.value}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
