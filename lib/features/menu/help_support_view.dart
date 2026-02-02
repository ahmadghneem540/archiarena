import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة المساعدة والدعم.
class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'المساعدة والدعم',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primaryDark.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'كيف نساعدك؟',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تصفح الأسئلة الشائعة أو تواصل مع فريق الدعم للحصول على مساعدة سريعة.',
                    style: TextStyle(fontSize: 14, color: AppColors.grey700, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildLink(
              icon: Icons.help_outline_rounded,
              title: 'الأسئلة الشائعة',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildLink(
              icon: Icons.mail_outline_rounded,
              title: 'تواصل معنا',
              subtitle: 'support@archiarena.com',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildLink(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'الدردشة المباشرة',
              subtitle: 'متاحة من 9 صباحاً - 6 مساءً',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildLink(
              icon: Icons.description_outlined,
              title: 'مركز المساعدة',
              onTap: () {},
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLink({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.grey600)),
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
