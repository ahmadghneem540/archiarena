import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'create_account_company_describe_controller.dart';

class CreateAccountCompanyDescribeView
    extends GetView<CreateAccountCompanyDescribeController> {
  const CreateAccountCompanyDescribeView({super.key});

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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('create_company_account'.tr),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'upload_company_license'.tr,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'upload_company_license_desc'.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _uploadArea(context),
                const SizedBox(height: 16),
                ArchiButton(
                  label: 'upload'.tr,
                  height: 44,
                  fontSize: 16,
                  onPressed: controller.pickLicenseFile,
                ),
                const SizedBox(height: 32),
                ArchiButton(label: 'next'.tr, onPressed: controller.next),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.alreadyHaveAccount,
                  child: Text('already_have_account_question'.tr),
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
      final file = controller.licenseFile.value;
      return InkWell(
        onTap: controller.pickLicenseFile,
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
                    Icons.description,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
        ),
      );
    });
  }
}
