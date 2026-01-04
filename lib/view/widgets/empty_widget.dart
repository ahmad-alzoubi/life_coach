import 'package:coach_life/utils/asstes/images_manager.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  const EmptyWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            ImagesManager.emptyBoxIcon,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 10),
          AppText(
            text: title,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      ),
    );
  }
}