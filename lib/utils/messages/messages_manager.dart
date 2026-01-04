
import 'package:coach_life/utils/dimensions/screen_dimensions.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesManager {

  static showErrorMessage(String text) {
    return Get.showSnackbar(
        GetSnackBar(
          message: text,
          backgroundColor: AppColors.errorColor,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.symmetric(horizontal: 20),
          borderRadius: ScreenDimensions.buttonBorderRadius - 10,
        )
    );
  }
  static showSuccessMessage(String text) {
    return Get.showSnackbar(
        GetSnackBar(
          message: text,
          backgroundGradient: AppColors.successGradientColor,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.symmetric(horizontal: 20),
          borderRadius: ScreenDimensions.buttonBorderRadius - 10,
        )
    );
  }

}