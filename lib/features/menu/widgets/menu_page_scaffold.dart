import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// سقالة موحدة لصفحات القائمة الفرعية — شريط علوي وعرض RTL.
class MenuPageScaffold extends StatelessWidget {
  const MenuPageScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
