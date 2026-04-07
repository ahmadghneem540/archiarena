import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة إرسال ملاحظات.
class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'إرسال ملاحظات',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'نود سماع رأيك لتحسين archiarena. اكتب ملاحظاتك أو اقتراحاتك أدناه.',
              style: TextStyle(
                fontSize: 14,
                color: context.themeGrey700,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'نوع الملاحظة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.themeGrey600,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: context.themeCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.themeBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'اقتراح أو فكرة',
                    style: TextStyle(
                      fontSize: 15,
                      color: context.themeGrey700,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.themeGrey600,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'الملاحظات',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.themeGrey600,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              height: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.themeCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.themeBorder),
              ),
              child: TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'اكتب ملاحظاتك هنا...',
                  hintStyle: TextStyle(
                    color: context.themeGrey600,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: TextStyle(
                  fontSize: 15,
                  color: context.themeOnSurface,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('إرسال الملاحظات'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}