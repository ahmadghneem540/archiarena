import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(
        const Duration(seconds: AppConstants.splashDelaySeconds),
        () => Get.offAllNamed(AppRoutes.createAccountIntro),
      );
    });
  }
}
