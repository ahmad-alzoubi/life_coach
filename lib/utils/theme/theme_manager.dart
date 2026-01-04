import 'package:flutter/material.dart';

import 'app_colors.dart';

class ThemeManager {
  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.lightScaffoldColor,
    fontFamily: 'Cairo',
    textTheme: const TextTheme(

    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.darkScaffoldColor,
    fontFamily: 'Cairo',
    textTheme: const TextTheme(
      
    ),
  );
}