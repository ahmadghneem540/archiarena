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

  void next() {
    Get.toNamed(AppRoutes.createAccountDescribe);
  }
}
