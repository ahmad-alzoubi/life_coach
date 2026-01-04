import 'dart:io';
import 'package:coach_life/utils/dimensions/media_query_values.dart';

import '../../utils/dimensions/font_sizes.dart';
import '../../utils/dimensions/screen_dimensions.dart';
import '../../utils/theme/app_colors.dart';
import 'app_text.dart';

import 'package:flutter/cupertino.dart' as cuortino;
import 'package:flutter/material.dart';

class DropdownItem {
  final String text;
  final String value;

  DropdownItem({required this.text, required this.value});
}

class AppDropdown extends StatelessWidget {
  final List<DropdownItem> items;
  final String? value;
  final void Function(String?)? onChanged;
  final String? hint;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets? padding;
  final bool isError;
  final String? error;
  final EdgeInsetsGeometry? fieldPadding;
  final double? borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final bool? isDense;
  final String? label;

  const AppDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.padding,
    this.isError = false,
    this.error,
    this.fieldPadding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.isDense,
    this.label,
  }) : super(key: key);

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
          Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? (isError ? AppColors.errorColor : AppColors.grayColor),
              borderRadius:  BorderRadius.circular(borderRadius ?? ScreenDimensions.buttonBorderRadius),
              // border: border,
            ),
            child: Platform.isAndroid ? DropdownButton(
              value: value,
              items: items.map((e) => DropdownItem(text: e.text, value: e.value)).map((item){
                return DropdownMenuItem(
                    value: item.value,
                    child: AppText(
                    text: item.text,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSizes.mediumFontSize,
                    padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.01, vertical: context.screenHeight * 0.01),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              isDense: false,
              underline: SizedBox(),
              menuMaxHeight: context.screenHeight * 0.25,
              isExpanded: true,
            ) : SizedBox(
              child: InkWell(
                onTap: () {
                  _showDialog(
                    cuortino.CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 32,
                      // This sets the initial item.
                      scrollController: FixedExtentScrollController(
                        initialItem: (value != null && items.where((e) => e.value == value).isNotEmpty) ? items.indexOf(items.where((e) => e.value.toString() == value.toString()).first) : 0,
                      ),
                      // This is called when selected item is changed.
                      onSelectedItemChanged: (int selectedIndex) {
                        // Assuming 'items' is a list of objects with a 'value' property
                        String? selectedItemValue = items[selectedIndex].value;
                        onChanged!(selectedItemValue); // Call onChanged with the new value
                      },
                      children:
                      List<Widget>.generate(items.length, (int index) {
                        return Center(child: Text(items[index].text));
                      }),
                  ), context);
                },
                child: cuortino.Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: (value != null && items.where((e) => e.value == value).isNotEmpty) ? items.where((e) => e.value.toString() == value.toString()).first.text : "",
                        fontWeight: FontWeight.w700,
                        fontSize: FontSizes.mediumFontSize
                      ),
                      const Icon(
                        Icons.arrow_drop_down
                      )
                    ],
                  ),
                ),
              ),
            ),
            // child: DropdownButtonFormField<String>(
            //   value: value,
            //   items: items.map((item) {
            //     return DropdownMenuItem<String>(
            //       value: item.value,
            //       child: AppText(
            //         text: item.text,
            //         fontWeight: FontWeight.w700,
            //         fontSize: FontSizes.mediumFontSize,
            //         padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.01, vertical: context.screenHeight * 0.01),
            //       ),
            //     );
            //   }).toList(),
            //   onChanged: onChanged,
            //   decoration: InputDecoration(
            //       hintText: hint,
            //       hintStyle: TextStyle(
            //           fontSize: fontSize,
            //           fontWeight: fontWeight,
            //           fontStyle: FontStyle.normal,
            //           fontFamily: "Zen Kaku Gothic Antique",
            //           color: isError ? AppColors.lightTextColor : AppColors.primaryColor.withOpacity(0.8)
            //       ),
            //       border: InputBorder.none,
            //       // icon: icon,
            //       // iconColor: iconColor,
            //       // suffixIcon: suffixIcon,
            //       // suffixIconColor: isError ? AppColors.lightTextColor : suffixIconColor,
            //       contentPadding: fieldPadding ?? EdgeInsets.all(ScreenDimensions.defaultHorizontalPadding),
            //       counter: SizedBox(),
            //       isDense: isDense
            //   ),
            //   isDense: true,
            // ),
          ),
          isError
              ? Column(
            children: [
              ScreenDimensions.appSpace(verticalSpace: 10),
              AppText(
                text: error.toString(),
                fontColor: AppColors.errorColor,
                fontWeight: FontWeight.bold,
                padding: EdgeInsets.symmetric(horizontal: ScreenDimensions.defaultHorizontalPadding),
              ),
            ],
          )
              : const SizedBox(),
        ],
      ),
    );
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child, BuildContext context) {
    cuortino.showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) =>
          Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            // The Bottom margin is provided to align the popup above the system navigation bar.
            margin: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
            ),
            // Provide a background color for the popup.
            color: cuortino.CupertinoColors.systemBackground.resolveFrom(
                context),
            // Use a SafeArea widget to avoid system overlaps.
            child: SafeArea(
              top: false,
              child: child,
            ),
          ),
    );
  }
}
