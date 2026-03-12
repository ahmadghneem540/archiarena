import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../data/services/auth_api_service.dart';

class ChangePasswordController extends GetxController {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscureCurrent = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentVisibility() => obscureCurrent.value = !obscureCurrent.value;
  void toggleNewVisibility() => obscureNew.value = !obscureNew.value;
  void toggleConfirmVisibility() => obscureConfirm.value = !obscureConfirm.value;

  Future<void> changePassword() async {
    final current = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (current.isEmpty) {
      Get.snackbar(
        'alert'.tr,
        'change_password_enter_current'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPass.isEmpty || newPass.length < 6) {
      Get.snackbar(
        'alert'.tr,
        'password_min_length'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPass == current) {
      Get.snackbar(
        'alert'.tr,
        'change_password_same_as_current'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPass != confirm) {
      Get.snackbar(
        'alert'.tr,
        'passwords_do_not_match'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      debugPrint('[ChangePassword] Calling API: ${ApiEndpoints.authChangePassword}');
      final res = await AuthApiService.changePassword(
        currentPassword: current,
        newPassword: newPass,
      );

      if (res.isSuccess) {
        Get.snackbar(
          'success'.tr,
          'change_password_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        Get.back();
      } else {
        debugPrint('[ChangePassword] API Error - Status: ${res.status}, Message: ${res.message}');
        Get.snackbar(
          'error'.tr,
          res.message ?? 'change_password_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
