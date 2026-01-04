import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:coach_life/view/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduelScreen extends StatelessWidget {
  const ScheduelScreen({super.key});

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
                  text: "Schedule".tr,
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
                  if (controller.isCoachScheduleLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Stack(
                    children: [
                      controller.isDeleteScheduleLoading.isTrue ? const Center(child: CircularProgressIndicator()) : const SizedBox(),
                      ListView.builder(
                        itemCount: controller.coachWeeklySchedule.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
                              color: AppColors.grayColor.withOpacity(0.1)
                            ),
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    AppText(
                                      text: controller.coachWeeklySchedule[index].name.tr,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: context.width * 0.4,
                                      child: AppButton(
                                        title: "Add Time".tr,
                                        onTap: () {
                                          controller.setSelectedDay(controller.coachWeeklySchedule[index].name);
                                          // Add time
                                          Get.bottomSheet(
                                            GetBuilder<CoachController>(
                                              builder: (coachController) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.lightScaffoldColor,
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(20),
                                                      topRight: Radius.circular(20)
                                                    )
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(height: 10),
                                                          Container(
                                                            width: 50,
                                                            height: 5,
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey.withOpacity(0.5),
                                                              borderRadius: BorderRadius.circular(10)
                                                            ),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          AppText(
                                                            text: "Add Time".tr,
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                          ),
                                                          const SizedBox(height: 10),
                                                          AppText(
                                                            text: "Start time".tr,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                          const SizedBox(height: 10),
                                                          //time picker
                                                          InkWell(
                                                            onTap: () {
                                                              // show time picker
                                                              showTimePicker(
                                                                context: context,
                                                                initialTime: TimeOfDay.now()
                                                              ).then((value) {
                                                                if (value != null) {
                                                                  controller.setStartTime(value, context);
                                                                }
                                                              });
                                                            },
                                                            child: AppTextField(
                                                              hint: "Start time".tr,
                                                              controller: controller.startTime,
                                                              keyboardType: TextInputType.datetime,
                                                              isEnabled: false,
                                                              borderRadius: 10,
                                                              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
                                                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          AppText(
                                                            text: "End time".tr,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                          const SizedBox(height: 10),
                                                          //time picker
                                                          InkWell(
                                                            onTap: () {
                                                              // show time picker
                                                              showTimePicker(
                                                                context: context,
                                                                initialTime: TimeOfDay.now()
                                                              ).then((value) {
                                                                if (value != null) {
                                                                  controller.setEndTime(value, context);
                                                                }
                                                              });
                                                            },
                                                            child: AppTextField(
                                                              hint: "End time".tr,
                                                              controller: controller.endTime,
                                                              keyboardType: TextInputType.datetime,
                                                              isEnabled: false,
                                                              borderRadius: 10,
                                                              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
                                                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          AppButton(
                                                            title: "Add".tr,
                                                            onTap: () {
                                                              controller.addTime();
                                                            },
                                                            // buttonHeight: 40,
                                                            fontSize: 16,
                                                            contentCenter: true,
                                                            background: AppColors.primaryColor,
                                                            showArrowIcon: false,
                                                            isLoading: coachController.isAddTimeLoading.value,
                                                          ),
                                                          const SizedBox(height: 10),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            )
                                          );
                                        },
                                        background: AppColors.primaryColor,
                                        showArrowIcon: false,
                                        contentCenter: true,
                                        buttonHeight: 40,
                                        fontSize: 13,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    )
                                  ],
                                ),
                                const Divider(),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.coachWeeklySchedule[index].schedules.length,
                                  itemBuilder: (context, i) {
                                    return Container(
                                      margin: const EdgeInsets.all(5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
                                        color: AppColors.grayColor.withOpacity(0.1)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppText(
                                            text: controller.coachWeeklySchedule[index].schedules[i].day!.tr,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              AppText(
                                                text: "${Utils.convertTime24To12(controller.coachWeeklySchedule[index].schedules[i].startTime.toString(), removeSeconds: true)} - ${Utils.convertTime24To12(controller.coachWeeklySchedule[index].schedules[i].endTime.toString(), removeSeconds: true)}",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  // delete schedule
                                                  controller.deleteSchedule(controller.coachWeeklySchedule[index].schedules[i].id!);
                                                },
                                                icon: const Icon(Icons.delete),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
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
