import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';

class AnalyseItem extends StatelessWidget {
  final String title;
  final String count;
  const AnalyseItem({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20,),
        AppText(
          text: title,
          fontColor: AppColors.lightTextColor,
        ),
        const SizedBox(height: 20,),
        CircleAvatar(
          backgroundColor: AppColors.secondaryColor.withOpacity(0.5),
          radius: 20,
          child: AppText(
            text: count,
            fontColor: AppColors.lightTextColor,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        const SizedBox(height: 20,),
      ],
    );
  }
}