import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:coach_life/view/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingSettingsScreen extends StatelessWidget {
  const BookingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                AppText(
                  text: "Booking Settings".tr,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),


            const Divider(),
            Expanded(
              child: GetBuilder<CoachController>(
                builder: (controller) {
                  // three options for enable or disable booking types [chat, video call, voice call]
                  return Obx((){
                      if (controller.getCoachAttributesLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  text: "Chat".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                Switch(
                                  value: controller.chatEnabled.value,
                                  onChanged: (value) {
                                    controller.chatEnabled.value = value;
                                    controller.updateCoachSchedule();
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  text: "Video Call".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                Switch(
                                  value: controller.videoCallEnabled.value,
                                  onChanged: (value) {
                                    controller.videoCallEnabled.value = value;
                                    controller.updateCoachSchedule();
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  text: "Voice Call".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                Switch(
                                  value: controller.voiceCallEnabled.value,
                                  onChanged: (value) {
                                    controller.voiceCallEnabled.value = value;
                                    controller.updateCoachSchedule();
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          // AppText(
                          //   text: "Booking Price".tr,
                          //   fontSize: 16,
                          //   fontWeight: FontWeight.w400,
                          // ),
                          // AppTextField(
                          //   hintText: "Price".tr,
                          //   controller: TextEditingController()
                          //     ..text = controller.coachSchedule.bookingPrice.toString(),
                          //   keyboardType: TextInputType.number,
                          //   onChanged: (value) {
                          //     controller.coachSchedule.bookingPrice = int.parse(value);
                          //   },
                          // ),
                          // swbmit button to update the booking settings
                          AppButton(
                            title: "Update".tr,
                            onTap: () {
                              controller.updateCoachDetailsFun();
                              // Utils.showSnackBar("Booking settings updated successfully".tr);
                            }, 
                            background: AppColors.primaryColor,
                            showArrowIcon: false,
                            contentCenter: true,
                            isLoading: controller.updateCoachDetails.value,
                          ),
                        ],
                      );
                    }
                  );
                }
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}