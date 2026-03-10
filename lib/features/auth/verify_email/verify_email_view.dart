import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'verify_email_controller.dart';

/// صفحة احترافية لإدخال رمز التحقق — تظهر بعد الشروط والخصوصية للأفراد والشركات
class VerifyEmailView extends GetView<VerifyEmailController> {
  const VerifyEmailView({super.key});

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
            'verify_email'.tr,
            style: TextStyle(
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
                const SizedBox(height: 24),
                Text(
                  'verify_email'.tr,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'verify_code_sent_long'.tr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.grey600,
                        height: 1.5,
                      ),
                ),
                if (controller.email.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildEmailCard(context),
                ],
                const SizedBox(height: 32),
                _buildOtpInput(context),
                const SizedBox(height: 24),
                Obx(
                  () => ArchiButton(
                    label: controller.isLoading.value
                        ? 'loading_verify'.tr
                        : 'verify_code_btn'.tr,
                    onPressed: () {
                      if (!controller.isLoading.value) controller.verify();
                    },
                    height: 52,
                  ),
                ),
                const SizedBox(height: 24),
                _buildResendSection(context),
                const SizedBox(height: 40),
                Text(
                  'verify_email_sent_note'.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.grey600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.authLogin),
                    child: Text(
                      'have_account_login'.tr,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
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

  Widget _buildEmailCard(BuildContext context) {
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
            Icons.mark_email_read_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'email'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.email,
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

  Widget _buildOtpInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'verify_code_label'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: AppColors.onSurface,
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

  Widget _buildResendSection(BuildContext context) {
    return Obx(
      () => Center(
        child: controller.resendCooldown.value > 0
            ? Text(
                '${'resend_in_seconds'.tr} ${controller.resendCooldown.value} ${'seconds'.tr}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey600,
                ),
              )
            : TextButton(
                onPressed: controller.resendCode,
                child: Text(
                  'resend_code_link'.tr,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
      ),
    );
  }
}

