import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/const_data.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/services.dart';
import '../../../data/services/auth_api_service.dart';

class TermsAndPrivacyController extends GetxController {
  final isLoading = false.obs;

  Future<void> signUp() async {
    await _performSignUp(updateContact: true);
  }

  Future<void> signUpWithoutUpdatingContact() async {
    await _performSignUp(updateContact: false);
  }

  Future<void> _performSignUp({required bool updateContact}) async {
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final isCompany = arguments['isCompany'] == true;

    if (isCompany) {
      await _registerCompany(arguments);
    } else {
      await _registerCustomer(arguments);
    }
  }

  Future<void> _registerCustomer(Map<String, dynamic> data) async {
    final email = data['email'] as String? ?? '';
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final phone = data['phone'] as String? ?? '';
    final password = data['password'] as String? ?? '';
    final customerBirth = data['birthDate'] as String?;
    final gender = data['gender'] as String?;
    final descriptionType = data['descriptionType'] as String? ?? 'engineer';

    if (email.isEmpty || firstName.isEmpty || lastName.isEmpty ||
        phone.isEmpty || password.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى التأكد من ملء جميع الحقول المطلوبة.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await AuthApiService.registerCustomer(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        customerBirth: customerBirth,
        gender: gender,
        descriptionType: descriptionType,
      );

      if (res.isSuccess) {
        await MyServices.saveStringValue(ConstData.keyIsCompany, '0');
        Get.offAllNamed(AppRoutes.verifyEmail, arguments: {'email': email});
      } else {
        _showRegistrationError(res.message ?? 'حدث خطأ أثناء التسجيل');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showRegistrationError(String message) {
    final isEmailUsed = message.toLowerCase().contains('مستخدم') ||
        message.toLowerCase().contains('already') ||
        message.toLowerCase().contains('exists') ||
        message.toLowerCase().contains('مسجل');

    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEmailUsed ? 'email_used'.tr : 'registration_failed'.tr),
          content: Text(message),
          actions: [
            if (isEmailUsed) ...[
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed(AppRoutes.authLogin);
                },
                child: Text('login'.tr),
              ),
            ],
            TextButton(
              onPressed: () => Get.back(),
              child: Text('ok'.tr),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _registerCompany(Map<String, dynamic> data) async {
    final email = data['email'] as String? ?? '';
    final companyName = data['companyName'] as String? ?? '';
    final phone = data['phone'] as String? ?? '';
    final password = data['password'] as String? ?? '';
    final companyFoundation = data['establishmentDate'] as String?;
    final licenseFile = data['licenseFile'] as File?;

    if (email.isEmpty || companyName.isEmpty || phone.isEmpty ||
        password.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى التأكد من ملء جميع الحقول المطلوبة.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await AuthApiService.registerCompany(
        companyName: companyName,
        email: email,
        phone: phone,
        password: password,
        companyFoundation: companyFoundation,
        licenseFile: licenseFile,
      );

      if (res.isSuccess) {
        await MyServices.saveStringValue(ConstData.keyIsCompany, '1');
        Get.offAllNamed(
          AppRoutes.verifyEmail,
          arguments: {'email': email, 'isCompany': true},
        );
      } else {
        _showRegistrationError(res.message ?? 'حدث خطأ أثناء التسجيل');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
