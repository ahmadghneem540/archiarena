import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// سقالة موحدة لصفحات القائمة الفرعية — شريط علوي وعرض RTL. تتكيف مع الوضع النهاري/الليلي.
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
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          backgroundColor: context.themeSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: context.themeOnSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.themeOnSurface,
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
