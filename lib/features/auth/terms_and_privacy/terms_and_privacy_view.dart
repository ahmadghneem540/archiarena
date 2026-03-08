import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'terms_and_privacy_controller.dart';

class TermsAndPrivacyView extends GetView<TermsAndPrivacyController> {
  const TermsAndPrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const Text('الشروط والخصوصية'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'إنهاء التسجيل',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 20),
                RichText(
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                    children: [
                      const TextSpan(text: 'بالضغط على '),
                      const TextSpan(text: 'تسجيل'),
                      const TextSpan(text: ' أنت توافق على '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'الشروط',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' و'),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'سياسة البيانات',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' و'),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'سياسة ملفات تعريف الارتباط',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => ArchiButton(
                    label: controller.isLoading.value ? 'جاري التسجيل...' : 'تسجيل',
                    onPressed: () {
                      if (!controller.isLoading.value) controller.signUp();
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Obx(
                    () => TextButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.signUpWithoutUpdatingContact,
                      child: const Text(
                        'تسجيل دون تحديث جهات اتصالي',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'أركي أرينا منصة للتصميم المعماري. سياسة البيانات وشروط الخدمة لدينا سارية. تعرّف على المزيد حول رؤيتنا.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
