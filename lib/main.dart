import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/constant/const_data.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/services/services.dart';
import 'bindings/app_bindings.dart';
import 'core/translations/app_translation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => MyServices().init());
  final savedLocale = await MyServices.getStringValue(ConstData.keyLocale);
  runApp(MyApp(initialLocale: savedLocale));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialLocale});

  final String? initialLocale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'archiarena',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      translations: AppTranslations(),
      locale: initialLocale != null
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
    );
  }
}
