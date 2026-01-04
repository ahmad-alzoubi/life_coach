import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/dimensions/font_sizes.dart';
import '../../utils/dimensions/screen_dimensions.dart';
import '../../utils/theme/app_colors.dart';
import 'app_text.dart';

class AppButton extends StatelessWidget {
  final String title;
  final Color background;
  final bool? isGradient;
  final Gradient? gradient;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final void Function()? onTap;
  final bool showArrowIcon;
  final double buttonHeight;
  final bool isLoading;
  final bool? contentCenter;
  final Border? border;
  final double fontSize;
  final FontWeight? fontWeight;
  final bool? isTransparent;
  final Widget? icon;

  const AppButton({
    required this.background,
    required this.title,
    this.textColor,
    this.onTap,
    super.key,
    this.padding,
    this.showArrowIcon = true,
    this.contentPadding,
    this.buttonHeight = 60,
    this.isLoading = false,
    this.contentCenter = false,
    this.border,
    this.fontSize = FontSizes.extraSmallFontSize + 2,
    this.isTransparent = false,
    this.icon,
    this.isGradient = false,
    this.gradient,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: ScreenDimensions.defaultHorizontalPadding),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Center( // Center the button to respect fixed size in loading state
          child: Container(
            width: isLoading ? 60 : double.infinity,
            height: isLoading ? 60 : buttonHeight,
            padding: isLoading ? null : contentPadding ?? EdgeInsets.all(ScreenDimensions.defaultHorizontalPadding),
            decoration: BoxDecoration(
              color: isTransparent == true ? Colors.transparent : isGradient == true ? null : background,
              borderRadius: BorderRadius.circular(ScreenDimensions.buttonBorderRadius),
              border: border,
              gradient: isGradient == true ? gradient : null,
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: CircularProgressIndicator(
                          color: textColor ?? AppColors.lightTextColor,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: contentCenter == true ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon ?? const SizedBox(),
                      AppText(
                        text: title,
                        fontColor: textColor ?? AppColors.lightTextColor,
                        textAlign: TextAlign.center,
                        fontWeight: fontWeight ?? FontWeight.w600,
                        fontSize: fontSize,
                        lineHeight: 1,
                        mainAxisAlignment: contentCenter == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                      ),
                      showArrowIcon
                          ? RotatedBox(
                              quarterTurns: Get.locale!.languageCode == "ar" ? 0 : 90,
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                color: textColor ?? AppColors.lightTextColor,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}