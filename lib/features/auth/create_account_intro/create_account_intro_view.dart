import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/const_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/services.dart';
import '../../../widget/gradient_button.dart';
import 'create_account_intro_controller.dart';

class CreateAccountIntroView extends GetView<CreateAccountIntroController> {
  const CreateAccountIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Get.locale?.languageCode == 'ar'
                  ? Icons.arrow_back_ios_new
                  : Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text('create_account'.tr),
          actions: [
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language, size: 26),
              tooltip: 'choose_language'.tr,
              offset: const Offset(0, 50),
              onSelected: (locale) async {
                Get.updateLocale(locale);
                await MyServices.saveStringValue(
                    ConstData.keyLocale, locale.languageCode);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: const Locale('ar'),
                  child: Row(
                    children: [
                      const Text('🇸🇦', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text('lang_arabic'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: const Locale('de'),
                  child: Row(
                    children: [
                      const Text('🇩🇪', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text('lang_german'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: const Locale('en'),
                  child: Row(
                    children: [
                      const Text('🇬🇧', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text('lang_english'.tr),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),

                /// حل overflow: الصورة أصبحت مرنة
                Flexible(
                  child: Image.asset('assets/joinus.png', fit: BoxFit.contain),
                ),

                const SizedBox(height: 24),

                Text(
                  'join_us'.tr,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  'create_account_desc'.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                ArchiButton(label: 'personal'.tr, onPressed: controller.next),
                const SizedBox(height: 16),

                ArchiButton(label: 'companies'.tr, onPressed: controller.nextCompany),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: controller.alreadyHaveAccount,
                  child: Text('have_account'.tr),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
