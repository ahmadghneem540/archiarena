import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'change_password_controller.dart';

/// صفحة تغيير كلمة المرور للمستخدم المسجّل دخوله
class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_back_ios_new : Icons.arrow_back_ios,
              size: 20,
              color: context.theme.colorScheme.onSurface,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'change_password'.tr,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
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
                const SizedBox(height: 24),
                _buildHeader(context),
                const SizedBox(height: 28),
                _buildFormCard(context),
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
            Icons.key_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'change_password_title'.tr,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'change_password_desc'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
        color: context.theme.cardColor,
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
          _buildPasswordField(
            context: context,
            label: 'current_password'.tr,
            controller: controller.currentPasswordController,
            obscure: controller.obscureCurrent,
            toggle: controller.toggleCurrentVisibility,
            hint: 'current_password_hint'.tr,
            isRtl: isRtl,
          ),
          const SizedBox(height: 20),
          _buildPasswordField(
            context: context,
            label: 'new_password'.tr,
            controller: controller.newPasswordController,
            obscure: controller.obscureNew,
            toggle: controller.toggleNewVisibility,
            hint: 'new_password_hint'.tr,
            isRtl: isRtl,
          ),
          const SizedBox(height: 20),
          _buildPasswordField(
            context: context,
            label: 'confirm_new_password'.tr,
            controller: controller.confirmPasswordController,
            obscure: controller.obscureConfirm,
            toggle: controller.toggleConfirmVisibility,
            hint: 'confirm_new_password_hint'.tr,
            isRtl: isRtl,
          ),
          const SizedBox(height: 28),
          Obx(
                () => ArchiButton(
              label: controller.isLoading.value
                  ? 'loading_save'.tr
                  : 'change_password_btn'.tr,
              onPressed: () {
                if (!controller.isLoading.value) controller.changePassword();
              },
              height: 52,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required RxBool obscure,
    required VoidCallback toggle,
    required String hint,
    required bool isRtl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
              () => TextField(
            controller: controller,
            obscureText: obscure.value,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              border: UnderlineInputBorder(
                borderSide:
                BorderSide(color: context.theme.dividerColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: context.theme.dividerColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: AppColors.primary, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: context.theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
                onPressed: toggle,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: TextStyle(
              fontSize: 16,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}