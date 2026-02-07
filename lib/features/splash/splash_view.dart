import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/app_logo.png',
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
