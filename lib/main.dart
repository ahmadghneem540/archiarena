import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/constant/const_data.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/routes/app_routes.dart';
import 'core/services/services.dart';
import 'core/services/fcm_service.dart';
import 'bindings/app_bindings.dart';
import 'core/translations/app_translation.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  await Get.putAsync(() => MyServices().init());
  await FcmService.init();
  final savedLocale = await MyServices.getStringValue(ConstData.keyLocale);
  String localeCode = savedLocale ?? '';
  if (localeCode.isEmpty) {
    final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode.toLowerCase();
    localeCode = ['ar', 'en', 'de'].contains(deviceLang) ? deviceLang : 'de';
  }
  final savedTheme = await MyServices.getStringValue(ConstData.keyThemeMode);
  ThemeMode initialThemeMode = ThemeMode.system;
  if (savedTheme == 'light') {
    initialThemeMode = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    initialThemeMode = ThemeMode.dark;
  }

  Get.put(ThemeController(initialMode: initialThemeMode));

  runApp(MyApp(initialLocale: localeCode));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialLocale});

  final String? initialLocale;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() => GetMaterialApp(
      title: 'archarena',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode.value,
      translations: AppTranslations(),
      locale: initialLocale != null && initialLocale!.isNotEmpty
          ? Locale(initialLocale!)
          : const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('de'),
        Locale('en'),
      ],
      initialRoute: AppRoutes.splash,
      getPages: AppBindings.pages,
      defaultTransition: Transition.cupertino,
    ));
  }
}
