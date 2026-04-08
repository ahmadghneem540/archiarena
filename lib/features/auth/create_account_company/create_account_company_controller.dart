import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class CreateAccountCompanyController extends GetxController {
  final companyNameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  final establishmentDate = DateTime(2000, 1, 1).obs;
  late final FixedExtentScrollController dayController;
  late final FixedExtentScrollController monthController;
  late final FixedExtentScrollController yearController;

  @override
  void onInit() {
    super.onInit();
    dayController = FixedExtentScrollController(
      initialItem: establishmentDate.value.day - 1,
    );
    monthController = FixedExtentScrollController(
      initialItem: establishmentDate.value.month - 1,
    );
    final currentYear = DateTime.now().year;
    yearController = FixedExtentScrollController(
      initialItem: currentYear - establishmentDate.value.year,
    );
  }

  @override
  void onClose() {
    companyNameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    emailController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.onClose();
  }

  void setDate(DateTime date) {
    establishmentDate.value = date;
  }

  int get yearsSinceEstablishment {
    final now = DateTime.now();
    int years = now.year - establishmentDate.value.year;
    if (now.month < establishmentDate.value.month ||
        (now.month == establishmentDate.value.month && now.day < establishmentDate.value.day)) {
      years--;
    }
    return years;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void next() {
    final companyName = companyNameController.text.trim();
    final phone = mobileController.text.trim();
    final password = passwordController.text;
    final email = emailController.text.trim();

    if (companyName.isEmpty) {
      Get.snackbar(
        'alert'.tr,
        'please_fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (phone.isEmpty) {
      Get.snackbar(
        'alert'.tr,
        'please_fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password.isEmpty || password.length < 6) {
      Get.snackbar(
        'alert'.tr,
        'password_min_length'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (email.isEmpty) {
      Get.snackbar(
        'alert'.tr,
        'please_fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!_isValidEmail(email)) {
      Get.snackbar(
        'alert'.tr,
        'invalid_email'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(AppRoutes.createAccountCompanyDescribe, arguments: {
      'isCompany': true,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'password': password,
      'establishmentDate':
          '${establishmentDate.value.year}-${establishmentDate.value.month.toString().padLeft(2, '0')}-${establishmentDate.value.day.toString().padLeft(2, '0')}',
    });
  }
}
