import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

enum Gender { female, male, custom }

class CreateAccountNameController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  final birthDate = DateTime(1996, 11, 19).obs;
  late final FixedExtentScrollController dayController;
  late final FixedExtentScrollController monthController;
  late final FixedExtentScrollController yearController;

  final Rx<Gender> selectedGender = Gender.male.obs;

  @override
  void onInit() {
    super.onInit();
    dayController = FixedExtentScrollController(
      initialItem: birthDate.value.day - 1,
    );
    monthController = FixedExtentScrollController(
      initialItem: birthDate.value.month - 1,
    );
    yearController = FixedExtentScrollController(
      initialItem: 2010 - birthDate.value.year,
    );
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.onClose();
  }

  void setDate(DateTime date) {
    birthDate.value = date;
  }

  int get age {
    final now = DateTime.now();
    int a = now.year - birthDate.value.year;
    if (now.month < birthDate.value.month ||
        (now.month == birthDate.value.month && now.day < birthDate.value.day)) {
      a--;
    }
    return a;
  }

  void selectGender(Gender g) {
    selectedGender.value = g;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void next() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = mobileController.text.trim();
    final password = passwordController.text;
    final email = emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
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

    Get.toNamed(AppRoutes.createAccountDescribe, arguments: {
      'isCompany': false,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'birthDate': '${birthDate.value.year}-${birthDate.value.month.toString().padLeft(2, '0')}-${birthDate.value.day.toString().padLeft(2, '0')}',
      'gender': selectedGender.value == Gender.male ? 'male' : 'female',
    });
  }
}
