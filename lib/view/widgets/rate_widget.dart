import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:coach_life/view/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RateWidget extends StatelessWidget {
  final Function(int) onRatingChanged;
  final int rating;
  final TextEditingController commentController;
  final Function()? onSubmit;
  final bool isSubmitting;

  const RateWidget({Key? key, required this.onRatingChanged, required this.rating, 
  this.onSubmit,
  required this.commentController,
  this.isSubmitting = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.66,
      child: Column(
        children: [
          AppText(
            text: "Rate".tr,
            fontWeight: FontWeight.bold,
            mainAxisAlignment: MainAxisAlignment.center,
            fontSize: 16,
          ),
          const Divider(),
          AppText(
            text: "Thank you for using our services. We would love to hear about your experience with the trainer.".tr,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            mainAxisAlignment: MainAxisAlignment.center,
            fullWidth: true,
            width: Get.width * 0.65,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          AppText(
            text: "${"Please rate the trainer using the stars from 1 to 5 and write a short comment if you wish".tr}:",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            mainAxisAlignment: MainAxisAlignment.center,
            fullWidth: true,
            width: Get.width * 0.65,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => onRatingChanged(index + 1),
              ),
            ),
          ),
          AppTextField(
            hint: "Write a short comment".tr,
            maxLines: 3,
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: 10,
            controller: commentController,
          ),
          const SizedBox(height: 10),
          AppButton(
            background: AppColors.primaryColor,
            textColor: AppColors.lightTextColor,
            title: "Submit".tr,
            showArrowIcon: false,
            contentCenter: true,
            onTap: onSubmit,
            isLoading: isSubmitting,
          )
        ],
      ),
    );
  }
}