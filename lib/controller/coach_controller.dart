import 'dart:convert';

import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/model/coach.dart';
import 'package:coach_life/model/schedule.dart';
import 'package:coach_life/model/weakly_schedule.dart';
import 'package:coach_life/repositories/coachs_repository.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoachController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSlotsLoading = false.obs;
  final RxList<Coach> coachs = <Coach>[].obs;
  final RxList<Schedule> schedules = <Schedule>[].obs;
  final Rx<Coach> selectedCoach = Coach().obs;
  final RxList<WeeklySchedule> coachWeeklySchedule = RxList<WeeklySchedule>([]);
  final RxBool isCoachScheduleLoading = false.obs;
  final TextEditingController startTime = TextEditingController();
  final TextEditingController endTime = TextEditingController();
  final Rxn<TimeOfDay> startTimeOfDay = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> endTimeOfDay = Rxn<TimeOfDay>();
  final RxString selectedDay = ''.obs;
  final RxBool isAddTimeLoading = false.obs;
  final RxBool isUpdateScheduleLoading = false.obs;
  final RxBool isDeleteScheduleLoading = false.obs;
  final RxInt duration = 30.obs;
  final RxString currentCoachId = ''.obs;
  final RxBool chatEnabled = false.obs;
  final RxBool videoCallEnabled = false.obs;
  final RxBool voiceCallEnabled = false.obs;
  final RxBool updateCoachDetails = false.obs;
  final RxBool getCoachAttributesLoading = false.obs;

  void setSelectedCoach(Coach coach) {
    selectedCoach.value = coach;
    update();
    FacebookAppEvents().logViewContent(
      content: {
        "content_type": "coach page",
        "content": {
          "id": coach.id,
          "title": coach.name,
          "description": coach.bio,
          "image_link":
              coach.media!.isNotEmpty ? coach.media!.first.originalUrl : '',
          "price": coach.price,
          "currency": "USD",
        },
      },
    );
  }

  void setIsLoading(bool value) {
    isLoading.value = value;
    update();
  }

  void setIsSlotsLoading(bool value) {
    isSlotsLoading.value = value;
    update();
  }

  void setIsAddTimeLoading(bool value) {
    isAddTimeLoading.value = value;
    update();
  }

  void setIsCoachScheduleLoading(bool value) {
    isCoachScheduleLoading.value = value;
    update();
  }

  void setIsUpdateScheduleLoading(bool value) {
    isUpdateScheduleLoading.value = value;
    update();
  }

  void setIsDeleteScheduleLoading(bool value) {
    isDeleteScheduleLoading.value = value;
    update();
  }

  void updateCoachSchedule() {
    update();
  }

  void setGetCoachAttributesLoading(bool value) {
    getCoachAttributesLoading.value = value;
    update();
  }

  void setStartTime(TimeOfDay value, BuildContext context) {
    startTime.text = value.format(context);
    startTimeOfDay.value = value;
    update();
  }

  void setEndTime(TimeOfDay value, BuildContext context) {
    endTime.text = value.format(context);
    endTimeOfDay.value = value;
    update();
  }

  void setSelectedDay(String value) {
    selectedDay.value = value;
    update();
  }

  void setDuration(int value) {
    duration.value = value;
    getCoachSchedules(currentCoachId.value);
    // update();
  }

  void setUpdateCoachDetails(bool value) {
    updateCoachDetails.value = value;
    update();
  }

  Future<void> getCoachSchedules(String coachId) async {
    schedules.clear();
    currentCoachId.value = coachId;
    // print('Coach ID: $coachId');
    setIsSlotsLoading(true);
    final response = await CoachsRepository().getCoachSchedules(
      coachId,
      duration.value.toString(),
    );
    if (response.statusCode == 200) {
      schedules.add(Schedule.fromJson(jsonDecode(response.body)));
      // print(schedules.first.toJson());
      print(Schedule.fromJson(jsonDecode(response.body)));
      Get.find<BookingController>().setSelectedSchedule(schedules.first);
    } else {
      // print(response.body);
      Get.back();
      MessagesManager.showErrorMessage('Failed to get schedules');
    }
    setIsSlotsLoading(false);
    // update();
  }

  void getWeeklySchedule() async {
    setIsCoachScheduleLoading(true);
    final response = await CoachsRepository().getSchedules();
    if (response.statusCode == 200) {
      coachWeeklySchedule.clear();
      coachWeeklySchedule.addAll(
        WeeklySchedule.fromJsonList(jsonDecode(response.body)),
      );
    } else {
      MessagesManager.showErrorMessage('Failed to get weekly schedule');
    }
    setIsCoachScheduleLoading(false);
    update();
  }

  void addTime() async {
    if (selectedDay.value.isEmpty ||
        startTimeOfDay.value == null ||
        endTimeOfDay.value == null) {
      MessagesManager.showErrorMessage('Please fill all fields');
      return;
    }
    setIsAddTimeLoading(true);
    final response = await CoachsRepository().createSchedule({
      //formate start time to 24 hours H:i
      "start_time":
          startTimeOfDay.value!.hour < 10
              ? '0${startTimeOfDay.value!.hour}:${startTimeOfDay.value!.minute < 10 ? '0${startTimeOfDay.value!.minute}' : startTimeOfDay.value!.minute}'
              : '${startTimeOfDay.value!.hour}:${startTimeOfDay.value!.minute < 10 ? '0${startTimeOfDay.value!.minute}' : startTimeOfDay.value!.minute}',
      "end_time":
          endTimeOfDay.value!.hour < 10
              ? '0${endTimeOfDay.value!.hour}:${endTimeOfDay.value!.minute < 10 ? '0${endTimeOfDay.value!.minute}' : endTimeOfDay.value!.minute}'
              : '${endTimeOfDay.value!.hour}:${endTimeOfDay.value!.minute < 10 ? '0${endTimeOfDay.value!.minute}' : endTimeOfDay.value!.minute}',
      "day": selectedDay.value,
      "status": "active",
    });
    if (response.statusCode == 200) {
      Get.back();
      MessagesManager.showSuccessMessage('Time added successfully');
      getWeeklySchedule();
    } else {
      MessagesManager.showErrorMessage('Failed to add time');
    }
    setIsAddTimeLoading(false);
  }

  void updateSchedule(String id) async {
    if (selectedDay.value.isEmpty ||
        startTimeOfDay.value == null ||
        endTimeOfDay.value == null) {
      MessagesManager.showErrorMessage('Please fill all fields');
      return;
    }
    setIsUpdateScheduleLoading(true);
    final response = await CoachsRepository().updateSchedule({
      "start_time":
          startTimeOfDay.value!.hour < 10
              ? '0${startTimeOfDay.value!.hour}:${startTimeOfDay.value!.minute < 10 ? '0${startTimeOfDay.value!.minute}' : startTimeOfDay.value!.minute}'
              : '${startTimeOfDay.value!.hour}:${startTimeOfDay.value!.minute}',
      "end_time":
          endTimeOfDay.value!.hour < 10
              ? '0${endTimeOfDay.value!.hour}:${endTimeOfDay.value!.minute < 10 ? '0${endTimeOfDay.value!.minute}' : endTimeOfDay.value!.minute}'
              : '${endTimeOfDay.value!.hour}:${endTimeOfDay.value!.minute}',
      "day": selectedDay.value,
      "status": "active",
      "id": id,
    });
    if (response.statusCode == 200) {
      Get.back();
      MessagesManager.showSuccessMessage('Time updated successfully');
      getWeeklySchedule();
    } else {
      MessagesManager.showErrorMessage('Failed to update time');
    }
    setIsUpdateScheduleLoading(false);
  }

  void deleteSchedule(String id) async {
    setIsDeleteScheduleLoading(true);
    final response = await CoachsRepository().deleteSchedule(id);
    if (response.statusCode == 200) {
      // Get.back();
      MessagesManager.showSuccessMessage('Time deleted successfully');
      getWeeklySchedule();
    } else {
      MessagesManager.showErrorMessage('Failed to delete time');
    }
    setIsDeleteScheduleLoading(false);
  }

  void updateCoachDetailsFun() async {
    updateCoachDetails.value = true;
    final response = await CoachsRepository().updateCoachDetails({
      "chat_enabled": chatEnabled.value,
      "video_call_enabled": videoCallEnabled.value,
      "voice_call_enabled": voiceCallEnabled.value,
    });
    if (response.statusCode == 200) {
      MessagesManager.showSuccessMessage('Coach details updated successfully');
    } else {
      MessagesManager.showErrorMessage('Failed to update coach details');
    }
    updateCoachDetails.value = false;
  }

  void getCoachAttributes() async {
    setGetCoachAttributesLoading(true);
    final response = await CoachsRepository().getCoachAttributes();
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      chatEnabled.value = data['attributes']['enable_chat'].toString() == '1';
      videoCallEnabled.value =
          data['attributes']['enable_video'].toString() == '1';
      voiceCallEnabled.value =
          data['attributes']['enable_audio'].toString() == '1';
    } else {
      MessagesManager.showErrorMessage('Failed to get coach attributes');
    }
    setGetCoachAttributesLoading(false);
  }
}
