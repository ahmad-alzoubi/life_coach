import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../routes/app_pages.dart';
import '../routes/app_routes.dart';
import '../utils/lang/translation_manager.dart';
import '../utils/utlis.dart';

class MainApp extends StatelessWidget {
  final String locale;
  const MainApp({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark
    ));

    return GetMaterialApp(
      translations: TranslationManager(),
      locale: Locale(locale),
      fallbackLocale: Locale(locale),
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      enableLog: kDebugMode,
      defaultTransition: Transition.fadeIn,
      opaqueRoute: Get.isOpaqueRouteDefault,
      popGesture: Get.isPopGestureEnable,
      transitionDuration: Utils.appNavigationDuration,
      initialRoute: AppRoutes.splashScreen,
      getPages: AppPages.pages,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        useMaterial3: false
      ),
      onUnknownRoute: (_) {
        Get.to(AppRoutes.error404);
        return null;
      },
      supportedLocales: TranslationManager.supportedLocales,
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      // showPerformanceOverlay: true,
    );
  }
}
