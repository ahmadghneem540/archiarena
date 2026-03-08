import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/services/services.dart';
import 'bindings/app_bindings.dart';
import 'core/translations/app_translation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => MyServices().init());
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
      translations: AppTranslations(),
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      initialRoute: AppRoutes.splash,
      getPages: AppBindings.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
