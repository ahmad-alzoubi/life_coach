import 'package:flutter/cupertino.dart';

class ScreenDimensions {

  static Widget appSpace({double? horizontalSpace, double? verticalSpace}) => SizedBox(height: verticalSpace ?? 50, width: horizontalSpace ?? 50,);

  static double defaultBorderRadius = 30.0;

  static double buttonBorderRadius = 25.0;

  static double defaultIconSize = 20.0;

  static double defaultHorizontalPadding = 20.0;
}