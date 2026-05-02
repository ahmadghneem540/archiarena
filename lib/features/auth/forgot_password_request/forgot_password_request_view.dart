import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'forgot_password_request_controller.dart';

class ForgotPasswordRequestView extends GetView<ForgotPasswordRequestController> {
  const ForgotPasswordRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : context.themeSurface,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF121212) : context.themeSurface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_back_ios_new : Icons.arrow_back_ios,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'forgot_password'.tr,
            style: TextStyle(
              color: isDark ? Colors.white : context.themeOnSurface,
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
                _buildHeader(context, isDark),
                const SizedBox(height: 32),
                _buildFormCard(context, isDark),
                const SizedBox(height: 24),
                _buildBackToLogin(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
            color: isDark ? Colors.white : context.themeOnSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'forgot_password_desc'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.white70 : context.themeGrey600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context, bool isDark) {
    final isRtl = Get.locale?.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : context.themeBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.04),
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
                    context: context,
                    label: 'email'.tr,
                    selected: controller.useEmail.value,
                    isDark: isDark,
                    onTap: () {
                      if (!controller.useEmail.value) controller.toggleInputType();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleChip(
                    context: context,
                    label: 'phone_number'.tr,
                    selected: !controller.useEmail.value,
                    isDark: isDark,
                    onTap: () {
                      if (controller.useEmail.value) controller.toggleInputType();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /// TextField
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
                hintStyle: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.grey500,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF555555) : Colors.transparent,
                prefixIcon: Icon(
                  controller.useEmail.value
                      ? Icons.email_outlined
                      : Icons.phone_outlined,
                  color: isDark ? Colors.white70 : AppColors.grey500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// Button
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
    required BuildContext context,
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.15)
          : (isDark ? const Color(0xFF555555) : AppColors.inputBackgroundBy(context)),
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
              color: selected
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : context.themeGrey600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: TextButton(
        onPressed: () => Get.back(),
        child:  Text(
          'have_account_login'.tr,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}