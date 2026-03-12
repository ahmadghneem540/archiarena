import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/auth_api_service.dart';

class ForgotPasswordResetController extends GetxController {
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading = false.obs;

  String? get email => Get.arguments?['email'] as String?;
  String? get phone => Get.arguments?['phone'] as String?;

  String get identifier => email ?? phone ?? '';

  @override
  void onClose() {
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> resetPassword() async {
    final code = codeController.text.replaceAll(' ', '').trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (code.isEmpty || code.length < 6) {
      Get.snackbar(
        'alert'.tr,
        'forgot_password_invalid_code'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword.isEmpty || newPassword.length < 6) {
      Get.snackbar(
        'alert'.tr,
        'password_min_length'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'alert'.tr,
        'passwords_do_not_match'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (identifier.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'forgot_password_missing_identifier'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await AuthApiService.resetPassword(
        email: email,
        phone: phone,
        code: code,
        newPassword: newPassword,
      );

      if (res.isSuccess) {
        Get.snackbar(
          'success'.tr,
          'forgot_password_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        Get.offAllNamed(AppRoutes.authLogin);
      } else {
        Get.snackbar(
          'error'.tr,
          res.message ?? 'forgot_password_reset_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
