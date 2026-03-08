import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/auth_api_service.dart';

class LoginController extends GetxController {
  final phoneOrEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    phoneOrEmailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
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

    final arguments = Get.arguments;
    final isCompany = arguments != null && arguments['isCompany'] == true;

    isLoading.value = true;
    try {
      final res = await AuthApiService.login(
        identifier: phoneOrEmail,
        password: password,
      );

      if (res.isSuccess) {
        Get.offAllNamed(AppRoutes.home, arguments: {'isCompany': isCompany});
      } else {
        Get.snackbar(
          'فشل تسجيل الدخول',
          res.message ?? 'بيانات الدخول غير صحيحة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
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
