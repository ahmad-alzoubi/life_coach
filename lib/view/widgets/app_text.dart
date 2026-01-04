import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:flutter/material.dart';
import '../../utils/dimensions/font_sizes.dart';

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? fontColor;
  final EdgeInsetsGeometry padding;
  final MainAxisAlignment mainAxisAlignment;
  final bool fullWidth;
  final double? width;
  final TextAlign? textAlign;
  final TextDecoration? textDecoration;
  final double? lineHeight;
  final void Function()? onTap;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool isPrice;
  const AppText({
    super.key,
    required this.text,
    this.fontSize = FontSizes.defaultFontSize,
    this.fontWeight = FontWeight.normal,
    this.fontColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.padding = const EdgeInsets.all(0),
    this.fullWidth = false,
    this.width,
    this.textAlign,
    this.textDecoration,
    this.lineHeight,
    this.onTap,
    this.overflow,
    this.maxLines,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            fullWidth ? SizedBox(
              width: width ?? context.screenWidth * 0.9,
              child: Text(
                text,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    fontStyle: FontStyle.normal,
                    fontFamily: "Cairo",
                    color: fontColor,
                    decoration: textDecoration,
                    height: lineHeight
                ),
                textAlign: textAlign,
                maxLines: maxLines,
              ),
            ) : Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                fontStyle: FontStyle.normal,
                fontFamily: "Cairo",
                color: fontColor,
                decoration: textDecoration,
                height: lineHeight,
              ),
              textAlign: textAlign,
              overflow: overflow,
              maxLines: maxLines,
            ),

            // if isPrice, show the currency symbol
            if (isPrice)
              Image.network(
                "https://app.lifecoach.com.sa/storage/sar.png",
                width: 15,
                height: 15,
                color: fontColor,
              ),
          ],
        ),
      ),
    );
  }
}
