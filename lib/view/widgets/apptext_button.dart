import 'package:flutter/material.dart';
import '../../utils/dimensions/font_sizes.dart';
import '../../utils/theme/app_colors.dart';
import 'app_text.dart';


class AppTextButton extends StatelessWidget {
  final String title;
  final Color? textColor;
  final void Function()? onTap;
  final double fontSize;
  final FontWeight fontWeight;
  final MainAxisAlignment mainAxisAlignment;
  const AppTextButton({
    super.key,
    this.title = "",
    this.fontWeight = FontWeight.w500,
    this.onTap,
    this.fontSize = FontSizes.defaultFontSize,
    this.textColor,
    this.mainAxisAlignment = MainAxisAlignment.start
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AppText(
        text: title,
        mainAxisAlignment: mainAxisAlignment,
        fontColor: textColor ?? AppColors.blackColor,
        fontWeight: fontWeight,
        fontSize: fontSize,
      ),
    );
  }
}
