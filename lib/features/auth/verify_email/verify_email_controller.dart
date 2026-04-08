import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constant/const_data.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/services.dart';
import '../../../data/services/auth_api_service.dart';

class VerifyEmailController extends GetxController {
  final codeController = TextEditingController();
  final isLoading = false.obs;
  final resendCooldown = 0.obs;

  String get email => Get.arguments?['email'] as String? ?? '';
  bool get isCompany => Get.arguments?['isCompany'] == true;

  String get code => codeController.text.replaceAll(' ', '').trim();

  Timer? _resendTimer;

  @override
  void onClose() {
    _resendTimer?.cancel();
    codeController.dispose();
    super.onClose();
  }

  Future<void> verify() async {
    final codeValue = code;
    if (codeValue.isEmpty || codeValue.length < 6) {
      Get.snackbar(
        'تنبيه',
        'يرجى إدخال رمز التحقق المكوّن من 6 أرقام',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (email.isEmpty) {
      Get.snackbar(
        'خطأ',
        'لم يتم العثور على البريد الإلكتروني',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await AuthApiService.verifyEmail(
        email: email,
        code: codeValue,
      );
      if (res.isSuccess) {
        // إذا رجع الـ API توكناً (تسجيل تلقائي) انتقل للرئيسية مباشرة
        final token = await MyServices.getStringValue(ConstData.keyToken);
        if (token != null && token.isNotEmpty) {
          ApiClient.reset();
          Get.snackbar(
            'تم بنجاح',
            'تم التحقق من بريدك الإلكتروني.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );
          Get.offAllNamed(AppRoutes.home, arguments: {'isCompany': isCompany});
        } else {
          Get.snackbar(
            'تم بنجاح',
            'تم التحقق من بريدك الإلكتروني. يمكنك تسجيل الدخول الآن.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );
          Get.offAllNamed(AppRoutes.authLogin);
        }
      } else {
        Get.snackbar(
          'فشل التحقق',
          res.message ?? 'رمز التحقق غير صحيح',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void resendCode() {
    if (resendCooldown.value > 0) return;
    resendCooldown.value = 60;
    Get.snackbar(
      'تم الإرسال',
      'تم إرسال رمز جديد إلى بريدك الإلكتروني',
      snackPosition: SnackPosition.BOTTOM,
    );
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      resendCooldown.value = (resendCooldown.value - 1).clamp(0, 60);
      if (resendCooldown.value == 0) _resendTimer?.cancel();
    });
  }
}
