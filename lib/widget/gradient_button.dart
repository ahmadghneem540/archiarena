import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// زر متدرج موحد لجميع أزرار التطبيق (إنشاء حساب، التفاصيل، تحميل المخطط، إلخ).
class ArchiButton extends StatelessWidget {
  const ArchiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.fontSize = 17,
    this.icon,
    this.iconSize = 22,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final double fontSize;

  /// أيقونة اختيارية تظهر بجانب النص (مثل أيقونة المستند لزر التحميل).
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: icon != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon!, color: AppColors.onPrimary, size: iconSize),
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
