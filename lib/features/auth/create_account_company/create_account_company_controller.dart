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

  void next() {
    Get.toNamed(AppRoutes.createAccountCompanyDescribe, arguments: {
      'isCompany': true,
      'companyName': companyNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': mobileController.text.trim(),
      'password': passwordController.text,
      'establishmentDate':
          '${establishmentDate.value.year}-${establishmentDate.value.month.toString().padLeft(2, '0')}-${establishmentDate.value.day.toString().padLeft(2, '0')}',
    });
  }
}
