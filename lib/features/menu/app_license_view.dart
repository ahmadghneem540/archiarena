import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/menu_page_scaffold.dart';

class AppLicenseView extends StatelessWidget {
  const AppLicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'app_license'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            /// Card المحتوى الرئيسي
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.themeCardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.themeBorder),
              ),
              child: Text(
                'app_license_body'.tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: context.themeGrey700,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

//   /// نص الترخيص (يمكن تغييره أو ربطه بترجمة لاحقًا)
//   static const String _licenseText = '''
// هذا التطبيق مرخّص للاستخدام الشخصي فقط.
//
// يُمنع إعادة نشر أو نسخ أو توزيع أي جزء من التطبيق بدون إذن مسبق من المطور.
//
// يتم توفير التطبيق "كما هو" بدون أي ضمانات صريحة أو ضمنية.
//
// لا يتحمل المطور أي مسؤولية عن أي أضرار ناتجة عن استخدام التطبيق.
//
// باستخدامك لهذا التطبيق فأنت توافق على جميع الشروط المذكورة أعلاه.
// ''';
 }