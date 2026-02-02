import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../../../widget/radio_option.dart';
import 'create_account_describe_controller.dart';

class CreateAccountDescribeView
    extends GetView<CreateAccountDescribeController> {
  const CreateAccountDescribeView({super.key});

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'ما الذي يصفك بشكل أفضل؟',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'هذا يساعدنا في تخصيص المحتوى لك.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Obx(
                  () => Column(
                    children: [
                      RadioOption<UserType>(
                        value: UserType.hobbyist,
                        groupValue: controller.selectedType.value,
                        label: 'هواة',
                        onChanged: (v) => controller.selectType(v!),
                      ),
                      RadioOption<UserType>(
                        value: UserType.engineer,
                        groupValue: controller.selectedType.value,
                        label: 'مهندس',
                        onChanged: (v) => controller.selectType(v!),
                      ),
                      RadioOption<UserType>(
                        value: UserType.advancedStudies,
                        groupValue: controller.selectedType.value,
                        label: 'دراسات متقدمة',
                        onChanged: (v) => controller.selectType(v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'رفع الشهادات',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'يمكنك رفع شهاداتك التعليمية ومؤهلاتك.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _uploadArea(),
                const SizedBox(height: 16),
                ArchiButton(
                  label: 'رفع',
                  height: 44,
                  fontSize: 16,
                  onPressed: controller.pickCertificate,
                ),
                const SizedBox(height: 24),
                ArchiButton(label: 'التالي', onPressed: controller.next),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.alreadyHaveAccount,
                  child: const Text('لديك حساب بالفعل؟'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _uploadArea() {
    return Obx(() {
      final file = controller.certificateFile.value;
      return InkWell(
        onTap: controller.pickCertificate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: file != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(file, fit: BoxFit.cover),
                )
              : Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
        ),
      );
    });
  }
}
