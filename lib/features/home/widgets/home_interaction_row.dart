import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class HomeInteractionRow extends StatelessWidget {
  const HomeInteractionRow({
    super.key,
    this.likes,
    this.comments,
    this.isLiked,
    this.likesCount,
    this.commentsCount,
    this.isLikedValue,
    required this.onLike,
    required this.onComment,
  }) : assert(
          (likes != null && comments != null && isLiked != null) ||
              (likesCount != null && commentsCount != null && isLikedValue != null),
          'Provide either Rx values or static values',
        );

  final RxInt? likes;
  final RxInt? comments;
  final RxBool? isLiked;
  final int? likesCount;
  final int? commentsCount;
  final bool? isLikedValue;
  final VoidCallback onLike;
  final VoidCallback onComment;

  int get _likes => likes?.value ?? likesCount ?? 0;
  int get _comments => comments?.value ?? commentsCount ?? 0;
  bool get _isLiked => isLiked?.value ?? isLikedValue ?? false;

  Widget _buildRow() {
    return Row(
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
                      _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 22,
                      color: _isLiked ? AppColors.primary : AppColors.grey600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_likes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _isLiked ? AppColors.primary : AppColors.grey700,
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
                      '$_comments',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (likes != null || comments != null || isLiked != null) {
      return Obx(_buildRow);
    }
    return _buildRow();
  }
}
