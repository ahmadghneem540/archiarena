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
            ),
            onPressed: () => Get.back(),
          ),
          title: Text('create_account'.tr),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'what_describes_you'.tr,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'helps_customize_content'.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Obx(
                  () => Column(
                    children: [
                      RadioOption<UserType>(
                        value: UserType.hobbyist,
                        groupValue: controller.selectedType.value,
                        label: 'hobbyist'.tr,
                        onChanged: (v) => controller.selectType(v!),
                      ),
                      RadioOption<UserType>(
                        value: UserType.engineer,
                        groupValue: controller.selectedType.value,
                        label: 'engineer'.tr,
                        onChanged: (v) => controller.selectType(v!),
                      ),
                      RadioOption<UserType>(
                        value: UserType.advancedStudies,
                        groupValue: controller.selectedType.value,
                        label: 'advanced_studies'.tr,
                        onChanged: (v) => controller.selectType(v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'upload_certificates'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'upload_certificates_desc'.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _uploadArea(context),
                const SizedBox(height: 16),
                ArchiButton(
                  label: 'upload'.tr,
                  height: 44,
                  fontSize: 16,
                  onPressed: controller.pickCertificate,
                ),
                const SizedBox(height: 24),
                ArchiButton(label: 'next'.tr, onPressed: controller.next),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.alreadyHaveAccount,
                  child: Text('have_account'.tr),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _uploadArea(BuildContext context) {
    return Obx(() {
      final file = controller.certificateFile.value;
      return InkWell(
        onTap: controller.pickCertificate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(
              color: context.themeBorder,
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
