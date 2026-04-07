import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة حول التطبيق.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'حول archiarena',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Text(
                    'archiarena',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'archiarena',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(fontSize: 14, color: context.themeGrey600),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.themeCardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.themeBorder),
              ),
              child: Text(
                'منصة archiarena تجمع المهندسين المعماريين والمصممين لعرض المشاريع، مشاركة الأفكار، والتواصل مع العملاء والزملاء في مجال العمارة والتصميم.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: context.themeGrey700, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            _buildRow(context, 'الشروط والأحكام', () {}),
            const SizedBox(height: 10),
            _buildRow(context, 'سياسة الخصوصية', () {}),
            const SizedBox(height: 10),
            _buildRow(context, 'ترخيص التطبيق', () {}),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.themeCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.themeBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.themeOnSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: context.themeGrey600, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
