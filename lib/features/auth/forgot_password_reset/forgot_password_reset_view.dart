import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'forgot_password_reset_controller.dart';

/// صفحة إدخال الرمز وكلمة المرور الجديدة (نسيان كلمة المرور - الخطوة 2)
class ForgotPasswordResetView extends GetView<ForgotPasswordResetController> {
  const ForgotPasswordResetView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          backgroundColor: context.themeSurface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_back_ios_new : Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'reset_password'.tr,
            style: TextStyle(
              color: context.themeOnSurface,
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
                if (controller.identifier.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildIdentifierCard(context),
                ],
                const SizedBox(height: 28),
                _buildCodeInput(context),
                const SizedBox(height: 20),
                _buildNewPasswordField(context),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(context),
                const SizedBox(height: 28),
                Obx(
                  () => ArchiButton(
                    label: controller.isLoading.value
                        ? 'loading_save'.tr
                        : 'reset_password_btn'.tr,
                    onPressed: () {
                      if (!controller.isLoading.value) {
                        controller.resetPassword();
                      }
                    },
                    height: 52,
                  ),
                ),
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
        Text(
          'reset_password_title'.tr,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.themeOnSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'reset_password_desc'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.themeGrey600,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildIdentifierCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            controller.email != null ? Icons.email_outlined : Icons.phone_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.email != null ? 'email'.tr : 'phone_number'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.identifier,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInput(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'verify_code_label'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.themeOnSurface,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.inputBackgroundBy(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.themeBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller.codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: context.themeOnSurface,
            ),
            decoration: const InputDecoration(
              hintText: '••••••',
              hintStyle: TextStyle(
                color: AppColors.grey400,
                letterSpacing: 8,
              ),
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordField(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'new_password'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.themeOnSurface,
              ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller.newPasswordController,
            obscureText: controller.obscureNewPassword.value,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            decoration: InputDecoration(
              hintText: 'new_password_hint'.tr,
              hintStyle: TextStyle(color: context.themeGrey600, fontSize: 16),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.themeBorder),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.themeBorder),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureNewPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: context.themeGrey600,
                ),
                onPressed: controller.toggleNewPasswordVisibility,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: TextStyle(fontSize: 16, color: context.themeOnSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'confirm_new_password'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.themeOnSurface,
              ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller.confirmPasswordController,
            obscureText: controller.obscureConfirmPassword.value,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            decoration: InputDecoration(
              hintText: 'confirm_new_password_hint'.tr,
              hintStyle: TextStyle(color: context.themeGrey600, fontSize: 16),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.themeBorder),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.themeBorder),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: context.themeGrey600,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: TextStyle(fontSize: 16, color: context.themeOnSurface),
          ),
        ),
      ],
    );
  }
}
