import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/auth_api_service.dart';

class ForgotPasswordRequestController extends GetxController {
  final emailOrPhoneController = TextEditingController();
  final isLoading = false.obs;
  final useEmail = true.obs;

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    super.onClose();
  }

  void toggleInputType() {
    useEmail.value = !useEmail.value;
    emailOrPhoneController.clear();
  }

  bool _isValidEmail(String s) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(s);
  }

  bool _isValidPhone(String s) {
    return RegExp(r'^[0-9]{9,15}$').hasMatch(s.replaceAll(RegExp(r'\s'), ''));
  }

  Future<void> sendCode() async {
    final value = emailOrPhoneController.text.trim();
    if (value.isEmpty) {
      Get.snackbar(
        'alert'.tr,
        'forgot_password_enter_email_phone'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (useEmail.value && !_isValidEmail(value)) {
      Get.snackbar(
        'alert'.tr,
        'invalid_email'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!useEmail.value && !_isValidPhone(value)) {
      Get.snackbar(
        'alert'.tr,
        'invalid_phone'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = useEmail.value
          ? await AuthApiService.requestForgotPassword(email: value)
          : await AuthApiService.requestForgotPassword(phone: value);

      if (res.isSuccess) {
        Get.snackbar(
          'success'.tr,
          'forgot_password_code_sent'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        Get.toNamed(
          AppRoutes.forgotPasswordReset,
          arguments: {
            'email': useEmail.value ? value : null,
            'phone': useEmail.value ? null : value,
          },
        );
      } else {
        Get.snackbar(
          'error'.tr,
          res.message ?? 'forgot_password_request_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
