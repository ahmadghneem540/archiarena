import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'bindings/app_bindings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'archiarena',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      initialRoute: AppRoutes.splash,
      getPages: AppBindings.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
