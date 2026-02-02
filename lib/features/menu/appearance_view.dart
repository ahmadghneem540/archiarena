import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/menu_page_scaffold.dart';

/// صفحة المظهر (فاتح / داكن / تلقائي).
class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  static const String _current = 'فاتح';

  @override
  Widget build(BuildContext context) {
    final options = [
      ('فاتح', Icons.light_mode_rounded),
      ('داكن', Icons.dark_mode_rounded),
      ('تلقائي', Icons.brightness_auto_rounded),
    ];
    return MenuPageScaffold(
      title: 'المظهر',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختر مظهر التطبيق',
              style: TextStyle(fontSize: 14, color: AppColors.grey600, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: options.asMap().entries.map((e) {
                  final isSelected = e.value.$1 == _current;
                  final isLast = e.key == options.length - 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(e.value.$2, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  e.value.$1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) Divider(height: 1, thickness: 1, color: AppColors.border, indent: 70, endIndent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
