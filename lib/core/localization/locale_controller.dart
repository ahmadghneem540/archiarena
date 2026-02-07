import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/services.dart';

class LocaleController extends GetxController {
  Locale? language;

  MyServices myServices = Get.find();

  changeLang(String codelang) {
    Locale locale = Locale(codelang);
    myServices.sharedPreferences.setString("lang", codelang);
    Get.updateLocale(locale);
  }

  @override
  void onInit() {
    String? sharedPrefLang = myServices.sharedPreferences.getString("lang");
    if (sharedPrefLang == "ar") {
      language = const Locale("ar");
    } else if (sharedPrefLang == "en") {
      language = const Locale("en");
    } else {
      language = const Locale("ar");
    }
    super.onInit();
  }
}
