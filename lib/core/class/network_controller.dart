import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  bool isOffline = false;

  @override
  void onInit() {
    super.onInit();

    _connectivity.onConnectivityChanged.listen((result) async {
      bool hasInternet = await InternetConnectionChecker().hasConnection;

      if (!hasInternet) {
        if (!isOffline) {
          isOffline = true;
          _showNoInternetMessage();
        }
      } else {
        if (isOffline) {
          isOffline = false;
          _showInternetMessage();
        }
      }
    });
  }

  void _showNoInternetMessage() {
    Get.snackbar(
      "خطأ في الاتصال",
      "لا يوجد اتصال بالإنترنت",
      backgroundColor: const Color.fromARGB(255, 255, 80, 80),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
    );
  }

  void _showInternetMessage() {
    Get.snackbar(
      "تم استعادة الاتصال",
      "✅ عاد الاتصال بالإنترنت",
      backgroundColor: const Color.fromARGB(255, 64, 239, 170),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
