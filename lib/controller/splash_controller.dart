import 'dart:io';

import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/repositories/config_repository.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../services/shared_preferances_manager.dart';
import '../utils/utlis.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Get.find<DashboardController>().getConfig();
    // });
    //after 3 seconds navigate to the home page
    Future.delayed(Duration(seconds: 2), () {
      // SharedPreferencesManager.instance!.clear();
      checkRoute();
    });
  }

  void checkRoute() async {
    bool isLoggedIn = SharedPreferencesManager.instance!.getBool(Utils.usedLoggedInKey) ?? false;
    bool useTutorial = SharedPreferencesManager.instance!.getBool(Utils.buseTutorial) ?? false;
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboardScreen);
    } else if (useTutorial) {
      getConfig();
      Get.offAllNamed(AppRoutes.loginScreen);
    } else {
      getConfig();
      Get.offAllNamed(AppRoutes.introScreen);
    }
  }

    void getConfig() async {
      // setIsConfigLoading(true);
      if(kDebugMode){
        print("Get Config");
      }
      String uuid = await Utils.getDeviceUUID();
      Position currentLocation = await Utils.getCurrentLocation();
      await ConfigRepository().getConfig(
        {
          "device_id": uuid,
          "device_type": Platform.isAndroid ? "android" : "ios",
          "app_version": Get.parameters['app_version'] ?? "1.0.0",
          "language": Get.locale!.languageCode,
          "location": {
            "lat": currentLocation.latitude,
            "lng": currentLocation.longitude,
          }
        }
      );
      // setIsConfigLoading(false);
    }
  
}