import 'package:flutter/painting.dart';

class AppColors {

  static Color primaryColor = hexColor("#3C32A4");
  static Color secondaryColor = hexColor("#845EF3");
  static Color accentColor = hexColor("#845EF3");
  static Color grayColor = hexColor("#CCCCCD");
  static Color darkGreyColor = hexColor("#617D79");
  static Color darkBlueColor = hexColor("#173430");
  static Color accentDarkBlueColor = hexColor("#617D79");
  static Color lightScaffoldColor = hexColor("#ffffff");
  static Color lightTextColor = hexColor("#ffffff");
  static Color darkScaffoldColor = hexColor("#2F2F2F");
  static Color darkGrayColor = hexColor("#D5D5D5");
  static Color blackColor = hexColor("#000000");
  static Color errorColor = hexColor("#FF395D");
  static Gradient successGradientColor = RadialGradient(
    colors: [
      hexColor("#3C32A4"),
      hexColor("#3C32A4")
    ]
  );
  static Color successColor = hexColor("#91B457");
  static Color underWeightBmiColor = hexColor("#FDC944");
  static Color normalBmiColor = hexColor("#9DD030");
  static Color overWeightBmiColor = hexColor("#FDC944");
  static Color firstObesityBmiColor = hexColor("#FF8C39");
  static Color secondObesityBmiColor = hexColor("#FF395D");
  static Color orangeColor = hexColor("#FF8C39");
  static Color pinkColor = hexColor("#FF395D");
  static Color rateColor = hexColor("#FDC944");
  static Color splashScreenBackground = hexColor("#8EAB52");
  static Color rate1 = hexColor("#FF395D");
  static Color rate2 = hexColor("#19B888");
  static Color rate3 = hexColor("#FDC944");
  static Color rate4 = hexColor("#FF8C39");
  static Color rate5 = hexColor("#9DD030");
  static Color whatsappColor = hexColor("#25D366");

}

Color hexColor(String color) {
  String newColor = color.replaceAll("#", "0xFF");
  return Color(int.parse(newColor));
}