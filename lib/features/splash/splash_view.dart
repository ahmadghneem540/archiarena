import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Scaffold(
      backgroundColor: context.themeSurface,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            isDark ? 'assets/app_logo_removebg.png' : 'assets/app_logo.png',
            width: 240, // تكبير الشعار
            height: 280,
            fit: BoxFit.contain,
            colorBlendMode: BlendMode.difference, // لمسة جمالية بسيطة
          ),
        ),
      ),
    );
  }
}
