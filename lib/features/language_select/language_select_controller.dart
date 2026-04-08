import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/const_data.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/services.dart';

class LanguageSelectController extends GetxController {
  Future<void> selectLanguage(String languageCode) async {
    await MyServices.saveStringValue(ConstData.keyLocale, languageCode);
    Get.updateLocale(Locale(languageCode));
    Get.offAllNamed(AppRoutes.splash);
  }
}
