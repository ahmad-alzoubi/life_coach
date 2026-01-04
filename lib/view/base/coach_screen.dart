import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/model/booking.dart';
import 'package:coach_life/model/schedule.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:coach_life/view/widgets/empty_widget.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../utils/theme/app_colors.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark
    ));
    print(jsonEncode(Get.find<CoachController>().selectedCoach.value.bio.toString()));
    return Scaffold(
      body: GetBuilder<DashboardController>(
        // initState: (state) => state.controller?.getCoachSchedule(state.controller?.selectedCoach.value.id ?? ""),
        // on open page get the coach schedule
        didChangeDependencies: (state) {
          Get.find<DashboardController>().getCoachSchedule(Get.find<CoachController>().selectedCoach.value.id ?? "");
        },
        builder: (controller) {
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: context.screenHeight * 0.4,
                    child: Stack(
                      children: [
                        Container(
                          height: context.screenHeight * 0.3,
                          width: context.screenWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.secondaryColor,
                                AppColors.primaryColor,
                              ],
                              transform: const GradientRotation(0.7),
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                        ),
                                            // back button
                        Positioned(
                          top: context.screenHeight * 0.05,
                          right: Get.locale?.languageCode == 'ar' ? 5 : null,
                          left: Get.locale?.languageCode == 'en' ? 5 : null,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 20,
                            left: 20,
                            top: context.screenHeight * 0.08,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: context.screenHeight * 0.2,
                                width: context.screenWidth * 0.35,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: (Get.find<CoachController>().selectedCoach.value.media != null && Get.find<CoachController>().selectedCoach.value.media!.isNotEmpty) ? Get.find<CoachController>().selectedCoach.value.media!.first.originalUrl : "",
                                    height: context.screenHeight * 0.2,
                                    width: context.screenWidth * 0.35,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppText(
                                      text: Get.find<CoachController>().selectedCoach.value.name.toString().tr,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontColor: Colors.white,
                                      // padding: EdgeInsets.only(left: Get.locale?.languageCode == 'ar' ? 0 : 20, right: Get.locale?.languageCode == 'en' ? 0 : 10),
                                    ),
                                    // AppText(
                                    //   text: Utils.displayBio(Get.find<CoachController>().selectedCoach.value.bio.toString()),
                                    //   fontSize: 16,
                                    //   fontWeight: FontWeight.normal,
                                    //   fontColor: Colors.white,
                                    //   padding: const EdgeInsets.only(left: 20),
                                    //   maxLines: 1,
                                    //   fullWidth: true,
                                    //   width: context.screenWidth - (context.screenWidth * 0.5),
                                    // ),
                                    // const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 16,
                                            ),
                                            AppText(
                                              text: Get.find<CoachController>().selectedCoach.value.rating.toString(),
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              fontColor: Colors.white,
                                              padding: const EdgeInsets.only(left: 5),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        // Row(
                                        //   children: [
                                        //     const Icon(
                                        //       Icons.currency_rupee_outlined,
                                        //       color: Colors.white,
                                        //       size: 16,
                                        //     ),
                                        //     AppText(
                                        //       text: Get.find<CoachController>().selectedCoach.value.price ?? "",
                                        //       fontSize: 12,
                                        //       fontWeight: FontWeight.normal,
                                        //       fontColor: Colors.white,
                                        //       padding: const EdgeInsets.only(left: 5),
                                        //     ),
                                        //   ],
                                        // ),
                                        // const SizedBox(width: 10),
                                        // Row(
                                        //   children: [
                                        //     const Icon(
                                        //       Icons.location_on,
                                        //       color: Colors.white,
                                        //       size: 16,
                                        //     ),
                                        //     AppText(
                                        //       text: "Cairo",
                                        //       fontSize: 12,
                                        //       fontWeight: FontWeight.normal,
                                        //       fontColor: Colors.white,
                                        //       padding: const EdgeInsets.only(left: 5),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        AppText(
                          text: "bio".tr,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          text: Get.find<CoachController>().selectedCoach.value.bio.toString() == "null" ? "No Bio Found".tr : Get.find<CoachController>().selectedCoach.value.bio.toString().tr,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          maxLines: 10,
                          width: context.screenWidth * 0.9,
                          fullWidth: true,
                        ),
                        AppText(
                          text: "comments".tr,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        const SizedBox(height: 10),
                        (Get.find<CoachController>().selectedCoach.value.coachRates == null || Get.find<CoachController>().selectedCoach.value.coachRates!.isEmpty) ? EmptyWidget(title: "No Comments".tr) : ListView.builder(
                          itemCount: Get.find<CoachController>().selectedCoach.value.coachRates != null ? Get.find<CoachController>().selectedCoach.value.coachRates!.length : 0,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.lightScaffoldColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      AppText(
                                        text: Get.find<CoachController>().selectedCoach.value.coachRates![index].user!.name ?? '',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const Spacer(),
                                      //five stars
                                      Row(
                                        children: List.generate(
                                          5,
                                          (index) => const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 16,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  AppText(
                                    text: Get.find<CoachController>().selectedCoach.value.coachRates![index].comment ?? "",
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    maxLines: 10,
                                    fullWidth: true,
                                    width: context.screenWidth * 0.8,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: context.screenHeight * 0.15),
                      ],
                    ),
                  ),
                  
                ],
              ),
              Obx(() =>Positioned(
                bottom: 20,
                left: controller.getCoachScheduleLoading.isFalse ? 0 : context.screenWidth * 0.37,
                right: controller.getCoachScheduleLoading.isFalse ? 0 : context.screenWidth * 0.37,
                child: AppButton(
                  title: Get.find<BookingController>().selectedSchedule.value.slots != null && Get.find<BookingController>().selectedSchedule.value.slots!.isEmpty ? "No times available".tr : "select time".tr,
                  onTap: () {
                    if(Get.find<BookingController>().selectedSchedule.value.slots != null && Get.find<BookingController>().selectedSchedule.value.slots!.isEmpty) {
                      MessagesManager.showErrorMessage("No times available".tr);
                      return;
                    }
                    // Reinitialize the booking controller
                    Get.find<BookingController>().setSelectedBooking(Booking());
                    Get.find<BookingController>().setSelectedConnectionType('', 30);
                    Get.find<BookingController>().setSelectedSchedule(Schedule());
                    Get.find<CoachController>().setDuration(30);
                    Get.find<BookingController>().setSelectedSlot(Slot());
                    Get.find<BookingController>().setCoachId(Get.find<CoachController>().selectedCoach.value.id ?? "", Get.find<CoachController>().selectedCoach.value);
                    // Schedule event
                    FacebookAppEvents().logEvent(name: "Schedule", parameters: {
                      "coach_id": Get.find<CoachController>().selectedCoach.value.id ?? "",
                      "coach_name": Get.find<CoachController>().selectedCoach.value.name ?? "",
                    });
                    Get.toNamed(AppRoutes.bookingScreen);
                  },
                  // background: AppColors.primaryColor,
                  showArrowIcon: false,
                  contentCenter: true,
                  background: Get.find<BookingController>().selectedSchedule.value.slots != null && Get.find<BookingController>().selectedSchedule.value.slots!.isEmpty ? AppColors.grayColor : AppColors.primaryColor,
                  textColor: Get.find<BookingController>().selectedSchedule.value.slots != null && Get.find<BookingController>().selectedSchedule.value.slots!.isEmpty ? AppColors.secondaryColor : AppColors.lightScaffoldColor,
                  isLoading: controller.getCoachScheduleLoading.isTrue,
                  
                )),
              ),
            ],
          );
        }
      ),
    );
  }
}
