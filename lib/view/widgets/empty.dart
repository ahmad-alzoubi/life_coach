import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/asstes/images_manager.dart';
import '../../utils/dimensions/font_sizes.dart';
import 'app_text.dart';


class Empty extends StatelessWidget {
  final String? text;
  final double fontSize;
  final double? imageWidth;
  const Empty({
    super.key,
    this.text,
    this.fontSize = FontSizes.bigFontSize,
    this.imageWidth
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(ImagesManager.emptyImage, width: imageWidth ?? context.screenWidth * 0.4,),
        AppText(
          text: text ?? "No Items Found".tr,
          mainAxisAlignment: MainAxisAlignment.center,
          fontSize: fontSize,
        )
      ],
    );
  }
}
