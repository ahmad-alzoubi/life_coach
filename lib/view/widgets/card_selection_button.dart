import 'package:coach_life/utils/dimensions/font_sizes.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardSelectionButton extends StatelessWidget {
  final Function() onTap;
  final bool isSelected;
  final String text;

  const CardSelectionButton({
    super.key,
    required this.onTap,
    required this.isSelected,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? AppColors.secondaryColor : Colors.transparent,
          border: Border.all(color: AppColors.grayColor.withOpacity(0.5)),
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: AppText(
          text: text,
          fontSize: FontSizes.extraSmallFontSize + 1,
          fontColor: isSelected ? AppColors.lightTextColor : AppColors.blackColor,
          textAlign: TextAlign.center,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}