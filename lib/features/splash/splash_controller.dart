import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/const_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/services.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final savedLocale = await MyServices.getStringValue(ConstData.keyLocale);
      if (savedLocale != null && savedLocale.isNotEmpty) {
        Get.updateLocale(Locale(savedLocale));
      }
      Timer(
        const Duration(seconds: AppConstants.splashDelaySeconds),
        () async {
          final token = await MyServices.getStringValue(ConstData.keyToken);
          if (token != null && token.isNotEmpty) {
            final isCompany =
                (await MyServices.getStringValue(ConstData.keyIsCompany)) == '1';
            Get.offAllNamed(AppRoutes.home, arguments: {'isCompany': isCompany});
          } else {
            Get.offAllNamed(AppRoutes.createAccountIntro);
          }
        },
      );
    });
  }
}
