import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/color.dart';

class MyDialogs {
  static void success({required String msg}) {
    Get.snackbar('Success'.tr, msg, colorText: Colors.white);
  }

  static void error({required String msg}) {
    Get.snackbar('Error'.tr, msg,
        colorText: Colors.white, backgroundColor: Colors.redAccent);
  }

  static void info({required String msg}) {
    Get.snackbar('Info'.tr, msg, colorText: Colors.white);
  }

  static void showProgress() {
    Get.dialog(Center(
        child: CupertinoActivityIndicator(
      radius: 10,
      color: AppColor.white,
    )));
  }
}
