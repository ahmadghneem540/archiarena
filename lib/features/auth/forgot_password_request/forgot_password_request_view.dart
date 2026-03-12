import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'forgot_password_request_controller.dart';

/// صفحة طلب إعادة تعيين كلمة المرور (نسيان كلمة المرور - الخطوة 1)
class ForgotPasswordRequestView extends GetView<ForgotPasswordRequestController> {
  const ForgotPasswordRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_back_ios_new : Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'forgot_password'.tr,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildFormCard(context),
                const SizedBox(height: 24),
                _buildBackToLogin(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'forgot_password_title'.tr,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'forgot_password_desc'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.grey600,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildToggleChip(
                    label: 'email'.tr,
                    selected: controller.useEmail.value,
                    onTap: () {
                      if (!controller.useEmail.value) controller.toggleInputType();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleChip(
                    label: 'phone_number'.tr,
                    selected: !controller.useEmail.value,
                    onTap: () {
                      if (controller.useEmail.value) controller.toggleInputType();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => TextField(
              controller: controller.emailOrPhoneController,
              keyboardType: controller.useEmail.value
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(
                hintText: controller.useEmail.value
                    ? 'email'.tr
                    : 'phone_number'.tr,
                hintStyle: TextStyle(color: AppColors.grey500, fontSize: 16),
                prefixIcon: Icon(
                  controller.useEmail.value
                      ? Icons.email_outlined
                      : Icons.phone_outlined,
                  color: AppColors.grey500,
                  size: 22,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 16, color: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => ArchiButton(
              label: controller.isLoading.value
                  ? 'loading_send'.tr
                  : 'send_reset_code'.tr,
              onPressed: () {
                if (!controller.isLoading.value) controller.sendCode();
              },
              height: 52,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.15)
          : AppColors.inputBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.grey600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          'have_account_login'.tr,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
