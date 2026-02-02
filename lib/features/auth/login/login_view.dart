import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'login_controller.dart';

/// شاشة تسجيل الدخول — تصميم مطابق للمرفق (خلفية، لوجو، حقول، أزرار).
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildLogo(),
                            const SizedBox(height: 32),
                            _buildPhoneOrEmailField(context),
                            const SizedBox(height: 20),
                            _buildPasswordField(context),
                            const SizedBox(height: 28),
                            _buildLoginButton(context),
                            const SizedBox(height: 16),
                            _buildForgotPassword(context),
                            const SizedBox(height: 24),
                            _buildOrDivider(),
                            const SizedBox(height: 24),
                            _buildCreateAccountButton(context),
                            const SizedBox(height: 32),
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

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      // width: double.infinity,
      child: SafeArea(child: Image.asset('assets/bg_login.png', fit: BoxFit.cover)),
    );
  }

  Widget _buildLogo() {
    return Transform.translate(
      offset: const Offset(0, -36),
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
          height: 72,
          width: 72,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPhoneOrEmailField(BuildContext context) {
    return TextField(
      controller: controller.phoneOrEmailController,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: 'الهاتف أو البريد الإلكتروني',
        hintStyle: TextStyle(color: AppColors.grey500, fontSize: 16),
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
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Obx(
      () => TextField(
        controller: controller.passwordController,
        obscureText: controller.obscurePassword.value,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'كلمة المرور',
          hintStyle: TextStyle(color: AppColors.grey500, fontSize: 16),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.grey500,
              size: 22,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(fontSize: 16, color: AppColors.onSurface),
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
      child: ArchiButton(
        label: 'تسجيل الدخول',
        onPressed: controller.login,
        height: 52,
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return TextButton(
      onPressed: controller.forgotPassword,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: const Text(
        'نسيت كلمة المرور؟',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: controller.createNewAccount,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'إنشاء حساب جديد',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
