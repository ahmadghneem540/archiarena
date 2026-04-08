import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    _buildHeader(context),

                    /// الجزء السفلي
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 0),
                            _buildLogo(),
                            const SizedBox(height: 12),

                            /// كارد الحقول
                            _buildFormCard(context),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// الصورة العلوية (صغرناها لرفع المحتوى)
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.36,
      width: double.infinity,
      child: Image.asset('assets/bg_login.png', fit: BoxFit.cover),
    );
  }

  /// اللوغو (ارتفع للأعلى)
  Widget _buildLogo() {
    return Transform.translate(
      offset: const Offset(0, -70),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          'assets/app_logo.png',
          height: 140,
          width: 190,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// كارد يحتوي الحقول والأزرار
  Widget _buildFormCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPhoneOrEmailField(context),
          const SizedBox(height: 16),
          _buildPasswordField(context),
          const SizedBox(height: 22),
          _buildLoginButton(context),
          const SizedBox(height: 16),
          _buildForgotPassword(context),
          const SizedBox(height: 8),
          _buildCreateAccountLink(context),
        ],
      ),
    );
  }

  Widget _buildPhoneOrEmailField(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller.phoneOrEmailController,
      keyboardType: TextInputType.emailAddress,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        hintText: 'login_or_email'.tr,
        hintStyle: TextStyle(
          color: isDark ? Colors.white70 : AppColors.grey500,
          fontSize: 16,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF555555) : Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : AppColors.onSurface,
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(
      () => TextField(
        controller: controller.passwordController,
        obscureText: controller.obscurePassword.value,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        decoration: InputDecoration(
          hintText: 'password'.tr,
          hintStyle: TextStyle(
            color: isDark ? Colors.white70 : AppColors.grey500,
            fontSize: 16,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF555555) : Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isDark ? Colors.white70 : AppColors.grey500,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => ArchiButton(
          label: controller.isLoading.value ? 'loading_login'.tr : 'login'.tr,
          onPressed: () {
            if (!controller.isLoading.value) controller.login();
          },
          height: 52,
        ),
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return TextButton(
      onPressed: controller.forgotPassword,
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
      child: Text(
        'forgot_password'.tr,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCreateAccountLink(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextButton(
      onPressed: controller.createNewAccount,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : AppColors.grey700,
          ),
          children: [
            TextSpan(text: 'no_account_question'.tr),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'create_account'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
