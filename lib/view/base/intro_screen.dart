import 'package:coach_life/controller/intro_controller.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app_text.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<IntroController>(
        builder: (controller) {
          return Center(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // skip button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 45.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: Colors.transparent,
                          ),
                          onPressed: () {
                            controller.finish();
                          },
                          child: AppText(
                            text: 'Skip'.tr,
                            fontColor: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Image.asset(
                      controller.introList[controller.currentIndex.value].image,
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    AppText(
                      text: controller.introList[controller.currentIndex.value].title,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    const SizedBox(height: 20),
                    AppText(
                      text: controller.introList[controller.currentIndex.value].description,
                      fontSize: 16,
                      textAlign: TextAlign.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      fullWidth: true,
                    ),
                    const Spacer(),
                    //indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.introList.length,
                        (index) => Container(
                          margin: const EdgeInsets.all(2),
                          width: controller.currentIndex.value == index ? 15 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: controller.currentIndex.value == index ? AppColors.primaryColor : Colors.grey.withOpacity(0.6),
                            shape: controller.currentIndex.value == index ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: controller.currentIndex.value == index ? BorderRadius.circular(5) : null,
                          ),
                        )
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      title: controller.currentIndex.value == controller.introList.length - 1 ? 'Get Started'.tr : 'Next'.tr,
                      background: controller.currentIndex.value == controller.introList.length - 1 ? AppColors.accentColor : Colors.white,
                      onTap: () {
                        if(controller.currentIndex.value == controller.introList.length - 1) {
                          controller.finish();
                        }else{
                          controller.next();
                        }
                      },
                      border: controller.currentIndex.value == controller.introList.length - 1 ? null : Border.all(color: AppColors.primaryColor),
                      textColor: controller.currentIndex.value == controller.introList.length - 1 ? Colors.white : AppColors.primaryColor,
                      showArrowIcon: false,
                      contentCenter: true,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),

                // Inside the GestureDetector
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // If the function has already been called, return early
                    if (controller.functionCalled.value) return;

                    // Determine the direction of the scroll
                    if (details.primaryDelta! > 0) {
                      controller.back();
                    } else if (details.primaryDelta! < 0) {
                      controller.next();
                    }

                    // Set the flag to true to indicate that the function has been called
                    controller.setFunctionCalled(true);
                  },
                  // When the touch event ends, reset the flag
                  onHorizontalDragEnd: (_) {
                    controller.setFunctionCalled(false);
                  },
                ),

              ],
            )
          );
        
        },
      )
    );
  }
}