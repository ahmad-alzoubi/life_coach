import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/dimensions/font_sizes.dart';
import '../../utils/dimensions/screen_dimensions.dart';
import '../../utils/theme/app_colors.dart';
import 'app_text.dart';


class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final double fontSize;
  final FontWeight fontWeight;
  final FontWeight? inputFontWeight;
  final double? inputFontSize;
  final Widget? icon;
  final Color? iconColor;
  final Widget? suffixIcon;
  final Color? suffixIconColor;
  final bool isError;
  final String? error;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final int? maxInputDigits;
  final int? maxLines;
  final bool? isEnabled;
  final String? label;
  final BoxBorder? border;
  final EdgeInsetsGeometry? fieldPadding;
  final bool? isDense;
  final double? borderRadius;
  final Color? backgroundColor;
  final TextInputType? keyboardType;
  final bool? isPassword;
  final TextAlign textAlign;
  final Color? textColor;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.fontSize = FontSizes.defaultFontSize,
    this.fontWeight = FontWeight.normal,
    this.inputFontSize,
    this.inputFontWeight,
    this.icon,
    this.iconColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.error,
    this.isError = false,
    this.padding,
    this.margin,
    this.maxInputDigits,
    this.maxLines,
    this.isEnabled,
    this.label,
    this.border,
    this.fieldPadding,
    this.isDense,
    this.borderRadius,
    this.backgroundColor,
    this.keyboardType,
    this.isPassword,
    this.textAlign = TextAlign.start,
    this.textColor,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: ScreenDimensions.defaultHorizontalPadding),
      child: Column(
        children: [
          label != null ? AppText(
            text: label!,
            fontWeight: FontWeight.w700,
            fontSize: FontSizes.mediumFontSize,
            padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.01, vertical: context.screenHeight * 0.01),
          ) : SizedBox(),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? (isError ? AppColors.errorColor : AppColors.lightScaffoldColor),
                borderRadius:  BorderRadius.circular(borderRadius ?? ScreenDimensions.buttonBorderRadius),
                border: border,
              ),
              padding: margin,
              child: TextField(
                maxLength: maxInputDigits,
                controller: controller,
                maxLines: maxLines,
                enabled: isEnabled,
                textAlign: textAlign,
                cursorColor: AppColors.primaryColor,
                inputFormatters: inputFormatters,
                onChanged: onChanged,
                style: TextStyle(
                    fontWeight: inputFontWeight ?? FontWeight.normal,
                    fontSize:  inputFontSize ?? FontSizes.defaultFontSize,
                    fontFamily: "Cairo",
                    color: textColor
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      fontStyle: FontStyle.normal,
                      fontFamily: "Cairo",
                      color: isError ? AppColors.lightTextColor : AppColors.blackColor.withOpacity(0.6),
                      
                  ),
                  border: InputBorder.none,
                  icon: icon,
                  iconColor: iconColor,
                  suffixIcon: suffixIcon,
                  suffixIconColor: isError ? AppColors.lightTextColor : suffixIconColor,
                  contentPadding: fieldPadding ?? EdgeInsets.all(ScreenDimensions.defaultHorizontalPadding),
                  counter: SizedBox(),
                  isDense: isDense,
                ),
                keyboardType: keyboardType,
                obscureText: isPassword == true ? true : false,
                enableSuggestions: isPassword == false ? true : false,
                autocorrect: isPassword == false ? true : false,
              ),
            ),
          ),
          isError ? Column(
            children: [
              ScreenDimensions.appSpace(verticalSpace: 10),
              AppText(
                text: error.toString(),
                fontColor: AppColors.errorColor,
                fontWeight: FontWeight.bold,
                padding: EdgeInsets.symmetric(horizontal: ScreenDimensions.defaultHorizontalPadding),
              ),
            ],
          ) : const SizedBox()
        ],
      ),
    );
  }
}
