import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'terms_and_privacy_controller.dart';

class TermsAndPrivacyView extends GetView<TermsAndPrivacyController> {
  const TermsAndPrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_back_ios_new : Icons.arrow_back_ios,
              size: 20,
              color: context.themeOnSurface,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'terms_and_privacy'.tr,
            style: TextStyle(color: context.themeOnSurface),
          ),
          backgroundColor: context.themeSurface,
          elevation: 0,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 32),

                Text(
                  'finish_registration'.tr,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: context.themeOnSurface,
                  ),
                ),

                const SizedBox(height: 20),

                RichText(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.themeOnSurface,
                    ),
                    children: [
                      TextSpan(text: '${'by_clicking_register'.tr} '),

                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'condition'.tr,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const TextSpan(text: ' '),

                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'privacy_policy'.tr,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const TextSpan(text: ' '),

                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'cookie_policy'.tr,
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
                    label: controller.isLoading.value
                        ? 'loading_register'.tr
                        : 'register'.tr,
                    onPressed: () {
                      if (!controller.isLoading.value) {
                        controller.signUp();
                      }
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
                      child: Text(
                        'register_without_contacts'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.themeGrey600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'archarena_vision'.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: context.themeGrey700,
                  ),
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