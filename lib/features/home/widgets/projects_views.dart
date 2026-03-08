import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';
import 'home_interaction_row.dart';

class HomePostCard extends StatelessWidget {
  const HomePostCard({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
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
                        'A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'شركة زيرو للتصميم',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'منذ ساعتين',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'تصميم داخلي',
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
                child: Image.asset(
                  'assets/post1.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.placeholder1,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey400,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'شركة زيرو للتصميم',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'مكتب هندسي مساحة تقريبية 80-120 م، تقسم إلى منطقة استقبال وعرض بمساحة 15 م لعرض المشاريع واستقبال العملاء، منطقة عمل مفتوحة للفريق بمساحة 35-45 م',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: HomeInteractionRow(
                          likes: controller.post1Likes,
                          comments: controller.post1Comments,
                          isLiked: controller.post1IsLiked,
                          onLike: controller.togglePost1Like,
                          onComment: controller.addPost1Comment,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ArchiButton(
                          label: 'رفع المشروع ',
                          height: 44,
                          fontSize: 14,
                          onPressed: () {
                            controller.openUploadPage();
                          },
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
}
