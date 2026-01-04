import 'package:coach_life/controller/splash_controller.dart';
import 'package:coach_life/utils/asstes/images_manager.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: GetBuilder<SplashController>(
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  ImagesManager.appLogo,
                  width: 240,
                  height: 240,
                ),
                // const SizedBox(height: 20),
                // AppText(
                //   text: 'coach life'.tr,
                //   fontSize: 24,
                //   fontWeight: FontWeight.bold,
                //   textAlign: TextAlign.center,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   fullWidth: true,
                // )
              ],
            )
          );
        }
      ),
    );
  }
}