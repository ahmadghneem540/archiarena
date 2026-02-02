import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class LoginController extends GetxController {
  final phoneOrEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  @override
  void onClose() {
    phoneOrEmailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void login() {
    final phoneOrEmail = phoneOrEmailController.text.trim();
    final password = passwordController.text;
    if (phoneOrEmail.isEmpty || password.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى إدخال الهاتف أو البريد وكلمة المرور.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.offAllNamed(AppRoutes.home);
  }

  void forgotPassword() {
    Get.snackbar(
      'نسيت كلمة المرور',
      'سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void createNewAccount() {
    Get.offAllNamed(AppRoutes.createAccountIntro);
  }
}
