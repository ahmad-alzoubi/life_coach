import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/dimensions/font_sizes.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/dimensions/screen_dimensions.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/analyse_item.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_text.dart';
import '../../widgets/empty_widget.dart';

class CoachHomeScreen extends StatelessWidget {
  const CoachHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<DashboardController>(
        builder: (controller) {
          if (controller.isDataLoading.isTrue ||
              controller.isConfigLoading.isTrue) {
            return const Center(child: CircularProgressIndicator());
          }
          return Obx(
            () => RefreshIndicator(
              //on refresh will reinitialize the data
              onRefresh: () async {
                controller.init();
              },
              child: Container(
                color: AppColors.lightScaffoldColor,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: "${"hello".tr},${controller.user.value.name}",
                          padding: const EdgeInsets.only(right: 20),
                          fontSize: FontSizes.largeFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_active),
                          onPressed: () {
                            Get.toNamed(AppRoutes.notificationsScreen);
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Container(
                      width: context.screenWidth,
                      // height: context.screenHeight * 0.13,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ScreenDimensions.defaultBorderRadius,
                        ),
                        color: AppColors.primaryColor,
                      ),
                      margin: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AnalyseItem(
                            title: "Today's booking".tr,
                            count:
                                controller
                                    .config
                                    .value
                                    .currentDayBookingsCount ??
                                "0",
                          ),
                          // AnalyseItem(title: "Today's profit".tr, count: controller.config.value.currentDayProfit ?? "0"),
                          // AnalyseItem(title: "Month profit".tr, count: controller.config.value.currentMonthProfit ?? "0"),
                          AnalyseItem(
                            title: "Average of rates".tr,
                            count: double.parse(
                              controller.config.value.averageRating ?? "0",
                            ).toStringAsFixed(2),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        AppText(
                          text: "Today's booking".tr,
                          padding: const EdgeInsets.only(right: 20),
                          fontSize: FontSizes.largeFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: hexColor("#F9F9F9"),
                          border: Border.all(color: hexColor("#EDEDED")),
                        ),
                        margin: const EdgeInsets.all(20),
                        child:
                            controller.config.value.currentDayBookings !=
                                        null &&
                                    controller
                                        .config
                                        .value
                                        .currentDayBookings!
                                        .isEmpty
                                ? EmptyWidget(
                                  title: "You don't have bookings now".tr,
                                )
                                : ListView.builder(
                                  itemCount:
                                      controller
                                          .config
                                          .value
                                          .currentDayBookings
                                          ?.length ??
                                      0,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        SizedBox(height: index == 0 ? 6 : 0),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: hexColor("#EBEBEB"),
                                            border: Border.all(
                                              color: hexColor("#D8D8D8"),
                                            ),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          child: Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // AppText(
                                                  //   text: "${"Name".tr}: ${controller.config.value.currentDayBookings?[index].user?.name ?? ""}",
                                                  //   padding: const EdgeInsets.only(right: 20),
                                                  //   fontSize: FontSizes.largeFontSize,
                                                  //   fontWeight: FontWeight.w500,
                                                  // ),
                                                  AppText(
                                                    text:
                                                        "${"Appointment".tr}: ${Utils.convertTime24To12(controller.config.value.currentDayBookings?[index].time ?? "")}",
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 20,
                                                        ),
                                                    fontSize:
                                                        FontSizes.largeFontSize,
                                                    fontWeight: FontWeight.w500,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                  ),
                                                  // type
                                                  AppText(
                                                    text:
                                                        "${"Type".tr}: ${controller.config.value.currentDayBookings?[index].connectType ?? ""}",
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 20,
                                                        ),
                                                    fontSize:
                                                        FontSizes.largeFontSize,
                                                    fontWeight: FontWeight.w500,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              if (controller
                                                          .config
                                                          .value
                                                          .currentDayBookings?[index]
                                                          .status ==
                                                      "pending" ||
                                                  controller
                                                          .config
                                                          .value
                                                          .currentDayBookings?[index]
                                                          .status ==
                                                      "running")
                                                SizedBox(
                                                  width:
                                                      context.screenWidth * 0.2,
                                                  child: AppButton(
                                                    background:
                                                        AppColors.primaryColor,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 8,
                                                        ),
                                                    title: "Start".tr,
                                                    showArrowIcon: false,
                                                    contentCenter: true,
                                                    onTap: () {
                                                      // show dialog to confirm start booking
                                                      Get.dialog(
                                                        AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                          content: AppText(
                                                            text:
                                                                "Are you sure you want to start this booking?"
                                                                    .tr,
                                                            fontSize:
                                                                FontSizes
                                                                    .mediumFontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            fullWidth: true,
                                                            width:
                                                                context
                                                                    .screenWidth *
                                                                0.6,
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                          actions: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      context
                                                                          .screenWidth *
                                                                      0.3,
                                                                  child: AppButton(
                                                                    onTap: () {
                                                                      Get.back();
                                                                    },
                                                                    title:
                                                                        "Cancel"
                                                                            .tr,
                                                                    background:
                                                                        AppColors
                                                                            .errorColor,
                                                                    showArrowIcon:
                                                                        false,
                                                                    buttonHeight:
                                                                        50,
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8,
                                                                        ),
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      context
                                                                          .screenWidth *
                                                                      0.3,
                                                                  child: AppButton(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      if (controller
                                                                              .config
                                                                              .value
                                                                              .currentDayBookings?[index]
                                                                              .connectType ==
                                                                          "chat") {
                                                                        MessagesManager.showSuccessMessage(
                                                                          "Please go to chat screen to start the chat"
                                                                              .tr,
                                                                        );
                                                                        return;
                                                                      }
                                                                      final bookingController =
                                                                          Get.find<
                                                                            BookingController
                                                                          >();
                                                                      final booking =
                                                                          controller
                                                                              .config
                                                                              .value
                                                                              .currentDayBookings?[index];
                                                                      bookingController
                                                                          .setSelectedBooking(
                                                                            booking,
                                                                          );
                                                                      if (!bookingController
                                                                          .canStartCallNow()) {
                                                                        return;
                                                                      }
                                                                      Get.toNamed(
                                                                        AppRoutes
                                                                            .callSreen,
                                                                      );
                                                                      bookingController.initAgoraCall(
                                                                        booking?.connectId ??
                                                                            "",
                                                                        booking?.connectType ??
                                                                            "",
                                                                        booking?.id ??
                                                                            "",
                                                                        int.parse(
                                                                          booking?.duration ??
                                                                              "0",
                                                                        ),
                                                                      );
                                                                    },
                                                                    title:
                                                                        "Start"
                                                                            .tr,
                                                                    background:
                                                                        AppColors
                                                                            .successColor,
                                                                    showArrowIcon:
                                                                        false,
                                                                    buttonHeight:
                                                                        50,
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8,
                                                                        ),
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              if (controller
                                                          .config
                                                          .value
                                                          .currentDayBookings?[index]
                                                          .status ==
                                                      "cancelled" ||
                                                  controller
                                                          .config
                                                          .value
                                                          .currentDayBookings?[index]
                                                          .status ==
                                                      "completed")
                                                // show green text with completed or cancelled with red
                                                AppText(
                                                  text:
                                                      controller
                                                                  .config
                                                                  .value
                                                                  .currentDayBookings?[index]
                                                                  .status ==
                                                              "cancelled"
                                                          ? "cancelled".tr
                                                          : "completed".tr,
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 20,
                                                      ),
                                                  fontSize:
                                                      FontSizes.largeFontSize,
                                                  fontWeight: FontWeight.w500,
                                                  fontColor:
                                                      controller
                                                                  .config
                                                                  .value
                                                                  .currentDayBookings?[index]
                                                                  .status ==
                                                              "cancelled"
                                                          ? AppColors.errorColor
                                                          : AppColors
                                                              .successColor,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
