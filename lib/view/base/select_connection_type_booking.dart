import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/theme/app_colors.dart';

class SelectConnectionTypeBookingScreen extends StatelessWidget {
  const SelectConnectionTypeBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<BookingController>(
          builder: (controller) {
            return Column(
              children: [
                AppText(
                  text: "Select Connection Type".tr,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                const Divider(),
                AppText(
                  text:
                      "Select the type of connection you want to make with the coach"
                          .tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  mainAxisAlignment: MainAxisAlignment.center,
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                controller.selectedCoach.value.coachAttributes?.enableChat ==
                        true
                    ? AppButton(
                      onTap: () {
                        // controller.setSelectedConnectionType('chat');
                      },
                      title: "Chat".tr,
                      background:
                          controller.selectedConnectionType.value == "chat"
                              ? AppColors.secondaryColor
                              : AppColors.grayColor.withOpacity(0.3),
                      showArrowIcon: false,
                      textColor:
                          controller.selectedConnectionType.value == "chat"
                              ? AppColors.lightTextColor
                              : AppColors.blackColor,
                      border: Border.all(
                        color: AppColors.grayColor.withOpacity(0.5),
                      ),
                    )
                    : Container(),
                const SizedBox(height: 8),
                controller.selectedCoach.value.coachAttributes?.enableVideo ==
                        true
                    ? AppButton(
                      onTap: () {
                        // controller.setSelectedConnectionType('video');
                      },
                      title: "Video Call".tr,
                      background:
                          controller.selectedConnectionType.value == "video"
                              ? AppColors.secondaryColor
                              : AppColors.grayColor.withOpacity(0.3),
                      showArrowIcon: false,
                      textColor:
                          controller.selectedConnectionType.value == "video"
                              ? AppColors.lightTextColor
                              : AppColors.blackColor,
                      border: Border.all(
                        color: AppColors.grayColor.withOpacity(0.5),
                      ),
                    )
                    : Container(),
                const SizedBox(height: 8),
                controller.selectedCoach.value.coachAttributes?.enableAudio ==
                        true
                    ? AppButton(
                      onTap: () {
                        // controller.setSelectedConnectionType('audio');
                      },
                      title: "Voice Call".tr,
                      background:
                          controller.selectedConnectionType.value == "audio"
                              ? AppColors.secondaryColor
                              : AppColors.grayColor.withOpacity(0.3),
                      showArrowIcon: false,
                      textColor:
                          controller.selectedConnectionType.value == "audio"
                              ? AppColors.lightTextColor
                              : AppColors.blackColor,
                      border: Border.all(
                        color: AppColors.grayColor.withOpacity(0.5),
                      ),
                    )
                    : Container(),
                const Divider(),
                (Get.find<DashboardController>().config.value.blockUsersPhone ??
                                [])
                            .isNotEmpty &&
                        Get.find<DashboardController>()
                            .config
                            .value
                            .blockUsersPhone!
                            .contains(
                              Get.find<DashboardController>().user.value.phone,
                            )
                    ? const SizedBox()
                    : AppText(
                      text: "You Will Pay".tr,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                (Get.find<DashboardController>().config.value.blockUsersPhone ??
                                [])
                            .isNotEmpty &&
                        Get.find<DashboardController>()
                            .config
                            .value
                            .blockUsersPhone!
                            .contains(
                              Get.find<DashboardController>().user.value.phone,
                            )
                    ? const SizedBox()
                    : Container(
                      decoration: BoxDecoration(
                        color: AppColors.grayColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.grayColor.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                text: "Service Fee".tr,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              AppText(
                                text: "${controller.amount.value} ",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                isPrice: true,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                text: "Tax".tr,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              AppText(
                                text: "${controller.tax.value} ",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                isPrice: true,
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                text: "Total".tr,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              AppText(
                                text:
                                    "${controller.amount.value + controller.tax.value} ",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                isPrice: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                // TabbyPresentationSnippet(
                //   price: (Get.find<BookingController>().amount.value + Get.find<BookingController>().tax.value +  Get.find<BookingController>().timeAmount.value).toString(),
                //   currency: Currency.sar,
                //   lang: Get.locale!.languageCode == 'ar' ? Lang.ar : Lang.en,
                // ),
                AppButton(
                  onTap: () {
                    if (controller.selectedConnectionType.value == "") {
                      MessagesManager.showErrorMessage(
                        "Please select connection type".tr,
                      );
                      return;
                    }
                    Get.find<CoachController>().getCoachSchedules(
                      controller.coachId.value.toString(),
                    );
                    FacebookAppEvents().logEvent(
                      name: "Schedule",
                      parameters: {
                        "coach_id":
                            Get.find<CoachController>()
                                .selectedCoach
                                .value
                                .id ??
                            "",
                        "coach_name":
                            Get.find<CoachController>()
                                .selectedCoach
                                .value
                                .name ??
                            "",
                      },
                    );
                    Get.toNamed(AppRoutes.selectBookingTimeScreen);
                  },
                  title: "Next".tr,
                  background: AppColors.secondaryColor,
                  showArrowIcon: false,
                  textColor: AppColors.lightTextColor,
                  contentCenter: true,
                  isLoading: controller.isLoading.value,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
