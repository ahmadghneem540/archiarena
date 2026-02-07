import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
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
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('create_account'.tr),
          actions: [
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language),
              onSelected: (locale) => Get.updateLocale(locale),
              itemBuilder: (context) => const [
                PopupMenuItem(value: Locale('ar'), child: Text('العربية')),
                PopupMenuItem(value: Locale('en'), child: Text('English')),
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
