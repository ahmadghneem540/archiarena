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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const Text('إنشاء حساب'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Image.asset(
                  'assets/joinus.png',
                  width: 400,
                  height: 400,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  'انضم إلينا',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'سنُساعدك في إنشاء حساب جديد في خطوات بسيطة.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                ArchiButton(label: 'التالي', onPressed: controller.next),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.alreadyHaveAccount,
                  child: const Text('لديك حساب بالفعل؟'),
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
