import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../localization/app_translations.dart';
import '../services/settings/settings_service.dart';
import 'bindings/initial_binding.dart';
import 'config/app_config.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

class PennyFlowApp extends StatelessWidget {
  const PennyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();

    return Obx(
      () => GetMaterialApp(
        title: AppConfig.instance.displayName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(settings.themeVariant.value),
        darkTheme: AppTheme.dark(settings.themeVariant.value),
        themeMode: settings.themeMode.value,
        translations: AppTranslations(),
        locale: Locale(settings.localeCode.value),
        fallbackLocale: const Locale('en', 'US'),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ur', 'PK'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialBinding: InitialBinding(),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        builder: (context, child) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child ?? const SizedBox.shrink(),
          );
        },
        unknownRoute: GetPage(
          name: '/not-found',
          page: () => Scaffold(
            appBar: AppBar(title: const Text(AppConstants.appName)),
            body: const Center(child: Text('Page not found')),
          ),
        ),
      ),
    );
  }
}
