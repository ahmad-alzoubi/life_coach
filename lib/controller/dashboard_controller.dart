import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:coach_life/controller/chat_controller.dart';
import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/model/coach.dart';
import 'package:coach_life/model/config.dart';
import 'package:coach_life/model/conversation.dart';
import 'package:coach_life/model/course.dart';
import 'package:coach_life/model/user.dart';
import 'package:coach_life/model/wallet.dart';
import 'package:coach_life/repositories/auth_repository.dart';
import 'package:coach_life/repositories/booking_repository.dart';
import 'package:coach_life/repositories/coachs_repository.dart';
import 'package:coach_life/repositories/config_repository.dart';
import 'package:coach_life/repositories/courses_repository.dart';
import 'package:coach_life/repositories/notification_repository.dart';
import 'package:coach_life/repositories/user_repository.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/base/coach/coach_home_screen.dart';
import 'package:coach_life/view/base/dashboard/account_screen.dart';
import 'package:coach_life/view/base/dashboard/books_screen.dart';
import 'package:coach_life/view/base/dashboard/chats_screen.dart';
import 'package:coach_life/view/base/dashboard/home_screen.dart';
import 'package:coach_life/view/base/dashboard/old_appointments_screen.dart';
import 'package:country_picker/country_picker.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../model/booking.dart';
import '../model/notification.dart';
import '../utils/messages/messages_manager.dart';

class DashboardController extends GetxController {
  List<Widget> screens = [];
  final RxBool isDataLoading = false.obs;
  final RxList<Coach> mostPopularCoachs = <Coach>[].obs;
  final RxList<Coach> mostRatedCoachs = <Coach>[].obs;
  final Rx<Coach> selectedCoach = Coach().obs;
  final Rx<User> user = User().obs;
  final List<Conversation> conversations = [];
  final RxBool isChatLoading = false.obs;
  List<Booking> appointments = [];
  final RxBool isAppointmentsLoading = false.obs;
  final RxBool isUpdateProfileLoading = false.obs;
  final Rx<File> image = File("").obs;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxBool isNotificationLoading = false.obs;
  final Rx<Config> config = Config().obs;
  final RxBool isConfigLoading = false.obs;
  final Rxn<Booking> bookingWillStart = Rxn<Booking>();
  final RxBool getCoachScheduleLoading = false.obs;

  final RxInt countdownTime = 0.obs;
  Timer? _countdown; // use a plain Timer, don't keep it in an Rx

  void startCountdown(int seconds) {
    final start = seconds < 0 ? 0 : seconds;

    // 1) Cancel any previous timer so we only ever have one running
    _countdown?.cancel();

    // 2) Set initial value
    countdownTime.value = start;

    // 3) If you use GetBuilder (not Obx), uncomment the next line:
    // update(['countdown']);  // or just update();

    // 4) Start ticking
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdownTime.value <= 1) {
        countdownTime.value = 0;
        t.cancel();
      } else {
        countdownTime.value--;
      }

      // If you use GetBuilder, notify:
      // update(['countdown']);
    });
  }

  @override
  void onClose() {
    _countdown?.cancel();
    super.onClose();
  }

  Country country = Country(
    phoneCode: "966",
    name: "Saudi Arabia",
    e164Key: "SA",
    e164Sc: 966,
    displayName: "Saudi Arabia (العربية السعوديه)",
    displayNameNoCountryCode: "Saudi Arabia",
    level: 1,
    example: "055 123 4567",
    countryCode: "SA",
    geographic: true,
  );

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final RxBool isProfileUpdateLoading = false.obs;

  final RxInt currentIndex = 0.obs;

  final Rxn<Wallet> wallet = Rxn<Wallet>();
  final RxBool isWalletLoading = false.obs;
  final RxBool haveBookingWillStart = false.obs;
  final Rx<Timer> timer = Timer(const Duration(seconds: 0), () {}).obs;
  final RxBool isDeleteAccountLoading = false.obs;
  final RxList<Course> courses = <Course>[].obs;
  final Rx<Course?> selectedCourse = Rx<Course?>(null);
  final RxBool isCoursesLoading = false.obs;
  final RxBool isCourseLoading = false.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
    update();
  }

  void setSelectedCoach(Coach value) {
    selectedCoach.value = value;
    update();
  }

  void setIsChatLoading(bool value) {
    isChatLoading.value = value;
    update();
  }

  void setIsAppointmentsLoading(bool value) {
    isAppointmentsLoading.value = value;
    update();
  }

  void setIsUpdateProfileLoading(bool value) {
    isUpdateProfileLoading.value = value;
    update();
  }

  void setIsNotificationLoading(bool value) {
    isNotificationLoading.value = value;
    update();
  }

  void setIsConfigLoading(bool value) {
    isConfigLoading.value = value;
    update();
  }

  void setIsWalletLoading(bool value) {
    isWalletLoading.value = value;
    update();
  }

  void setIsProfileUpdateLoading(bool value) {
    isProfileUpdateLoading.value = value;
    update();
  }

  void setSelectedCourse(Course? value) {
    selectedCourse.value = value;
    update();
  }

  void setIsCoarseLoading(bool value) {
    isCourseLoading.value = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    init();
    FacebookAppEvents()
        .logViewContent(
          type: "dashboard",
          content: {"content_type": "dashboard"},
          id: "dashboard",
        )
        .then((value) {
          if (kDebugMode) {
            print("FacebookAppEvents().logViewContent");
          }
        });
    // changeIndex(1);
    // Get.dialog(AlertDialog(content: RateWidget(onRatingChanged: (n){}, rating: 0),));
  }

  void init() async {
    var localUserKey = SharedPreferencesManager.instance!.getString(
      Utils.localUserKey,
    );
    if (localUserKey == null) {
      await SharedPreferencesManager.instance!.clear();
      // Defer navigation to avoid calling it during the build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.splashScreen);
      });
      return;
    }
    user.value = User.fromJson(
      jsonDecode(
        SharedPreferencesManager.instance!.getString(Utils.localUserKey) ?? "",
      ),
    );
    screens =
        user.value.type == "user"
            ? [
              const HomeScreen(),
              const BooksScreen(),
              const OldAppointmentsScreen(),
              const ChatsScreen(),
              const AccountScreen(),
            ]
            : [
              const CoachHomeScreen(),
              const ChatsScreen(),
              const AccountScreen(),
            ];
    //check if subscriped to notification topic "user_{user.value.id}"
    if (kDebugMode) {
      print("Will subscribe to topic user_${user.value.id}");
    }

    Utils.subscribeToTopic("user_${user.value.id}");
    // initSocket(Get.context!);
    // if(user.value.type == "coach") {
    // }
    nameController.text = user.value.name!;
    phoneController.text = user.value.phone!.replaceAll(country.phoneCode, "");
    bioController.text = user.value.bio ?? "";
    priceController.text = user.value.price ?? "0";
    getAllCoachs();
    getCourses();
    getConversations();
    fetchAppointments();
    getNotifications(true);
    checkBookingWillStart();
    getConfig();
    try {
      await Utils.identifyTikTokUser(
        user.value.id ?? "",
        user.value.name ?? "",
        user.value.phone ?? "",
        user.value.email ?? "",
      );
      Utils.logEvent("page_view", {"page_name": "dashboard"});
      Utils.logTikTokEvent("view_content");
    } catch (e) {
      if (kDebugMode) {
        print("Error identifying TikTok user: $e");
      }
    }
  }

  void setIsDataLoadin(bool value) {
    isDataLoading.value = value;
    update();
  }

  void getAllCoachs() async {
    setIsDataLoadin(true);
    final response = await CoachsRepository().getAllCoaches();
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['most_popular'] != null) {
        mostPopularCoachs.value =
            jsonDecode(
              response.body,
            )['most_popular'].map<Coach>((e) => Coach.fromJson(e)).toList();
      }
      if (jsonDecode(response.body)['most_rating'] != null) {
        mostRatedCoachs.value =
            jsonDecode(
              response.body,
            )['most_rating'].map<Coach>((e) => Coach.fromJson(e)).toList();
      }
    }
    setIsDataLoadin(false);
  }

  Future<void> getConversations() async {
    setIsChatLoading(true);
    final response = await BookingRepository().getConversations();
    if (response.statusCode == 200) {
      conversations.clear();
      conversations.addAll(
        jsonDecode(
          response.body,
        ).map<Conversation>((e) => Conversation.fromJson(e)).toList(),
      );
    }

    setIsChatLoading(false);
  }

  void fetchAppointments() async {
    setIsAppointmentsLoading(true);
    final response = await BookingRepository().getBookings();
    if (response.statusCode == 200) {
      appointments = Booking.listFromJson(jsonDecode(response.body));
    } else {
      MessagesManager.showErrorMessage("Failed to fetch appointments");
    }
    //check if booking date + time == current date + time and type is video pr audio go to call screen
    if (appointments.isNotEmpty) {
      for (Booking booking in appointments) {}
    }
    setIsAppointmentsLoading(false);
  }

  void selectImageFromGallery() async {
    final imageFile = await Utils.pickImageFromGallery();
    image.value = imageFile;
    uploadImage();
  }

  void uploadImage() async {
    setIsUpdateProfileLoading(true);
    final response = await AuthRepository().updateProfile(
      user.value.toJson(),
      image.value,
    );
    if (response.statusCode == 200) {
      print(response.body);
      await SharedPreferencesManager.instance!.setString(
        Utils.localUserKey,
        jsonEncode(jsonDecode(response.body)['user']).toString(),
      );
      user.value = User.fromJson(
        jsonDecode(
          SharedPreferencesManager.instance!.getString(Utils.localUserKey) ??
              "",
        ),
      );
      MessagesManager.showSuccessMessage("Profile updated successfully");
    } else {
      MessagesManager.showErrorMessage("Failed to update profile");
    }
    setIsUpdateProfileLoading(false);
  }

  void logout() async {
    await Utils.firebaseMessaging.unsubscribeFromTopic("user_${user.value.id}");
    await SharedPreferencesManager.instance!.clear();
    Get.offAllNamed(AppRoutes.splashScreen);
  }

  void getNotifications(bool withRelode) async {
    if (withRelode) {
      setIsNotificationLoading(true);
    }
    final response = await NotificationRepository().getNotifications();
    if (response.statusCode == 200) {
      notifications.value =
          jsonDecode(
            response.body,
          ).map<AppNotification>((e) => AppNotification.fromJson(e)).toList();
    }
    if (withRelode) {
      setIsNotificationLoading(false);
    }
  }

  void getConfig() async {
    // setIsConfigLoading(true);
    if (kDebugMode) {
      print("Get Config");
    }
    String uuid = await Utils.getDeviceUUID();
    Position currentLocation = await Utils.getCurrentLocation();
    final response = await ConfigRepository().getConfig({
      "device_id": uuid,
      "device_type": Platform.isAndroid ? "android" : "ios",
      "app_version": Get.parameters['app_version'] ?? "1.0.0",
      "language": Get.locale!.languageCode,
      "location": {
        "lat": currentLocation.latitude,
        "lng": currentLocation.longitude,
      },
    });
    if (response.statusCode == 200) {
      config.value = Config.fromJson(jsonDecode(response.body));
      if (kDebugMode) {
        print("Config: ${config.value.toJson()}");
      }
    }
    // setIsConfigLoading(false);
  }

  void checkBookingWillStart() async {
    try {
      final response = await BookingRepository().checkBookingWillStart();
      if (response.statusCode == 200 && jsonDecode(response.body).length > 0) {
        bookingWillStart.value = Booking.fromJson(
          jsonDecode(response.body)[0]['booking'],
        );
        int remainingTime = int.parse(
          jsonDecode(
            response.body,
          )[0]['booking_remaining_time'].toString().split(".")[0],
        );
        if (remainingTime <= 300) {
          haveBookingWillStart.value = true;
        } else {
          haveBookingWillStart.value = false;
        }
        startCountdown(remainingTime);
        Future.delayed(
          Duration(
            seconds: int.parse(
              jsonDecode(
                response.body,
              )[0]['booking_remaining_time'].toString().split(".")[0],
            ),
          ),
          () {
            if (bookingWillStart.value!.connectType == "video" ||
                bookingWillStart.value!.connectType == "audio") {
              // Get.toNamed(AppRoutes.callSreen);
              // Get.find<BookingController>().initAgoraCall(
              //   bookingWillStart.value!.connectId!,
              //   bookingWillStart.value!.connectType!,
              //   bookingWillStart.value!.id!,
              //   int.parse(bookingWillStart.value!.duration ?? "0"),
              // );
            } else {
              if (user.value.type == "user") {
                currentIndex.value = 2;
              } else {
                currentIndex.value = 1;
              }
              getConversations().then((value) {
                if (conversations.isNotEmpty &&
                    conversations
                            .indexWhere(
                              (element) =>
                                  element.bookingId ==
                                  bookingWillStart.value!.id!,
                            )
                            .toString() !=
                        "null") {
                  Get.find<ChatController>().initSocket(
                    Get.context!,
                    conversations
                        .where(
                          (element) =>
                              element.bookingId == bookingWillStart.value!.id!,
                        )
                        .first,
                  );
                }
              });
              MessagesManager.showSuccessMessage(
                "Go to chat screen to start chat with your coach",
              );
            }
          },
        );
      }
    } catch (e) {
      log("Error checking booking will start: $e");
      haveBookingWillStart.value = false;
    }
  }

  var _lastCountdownStart = -1;
  void startCountdownIfChanged(int seconds) {
    if (seconds != _lastCountdownStart) {
      _lastCountdownStart = seconds;
      startCountdown(seconds);
    }
  }

  void setHaveBookingWillStart(bool value) {
    haveBookingWillStart.value = value;
    update();
  }

  Future<void> getWallet() async {
    setIsWalletLoading(true);
    final response = await UserRepository().getWallet();
    if (response.statusCode == 200) {
      wallet.value = Wallet.fromJson(jsonDecode(response.body));
    }
    setIsWalletLoading(false);
  }

  void updateProfile() async {
    setIsProfileUpdateLoading(true);
    final userJson = user.value.toJson();
    userJson['phone'] = country.phoneCode + phoneController.text;
    userJson['name'] = nameController.text;
    userJson['bio'] = bioController.text;
    userJson['price'] = priceController.text;
    final response = await AuthRepository().updateProfile(userJson, null);
    if (response.statusCode == 200) {
      await SharedPreferencesManager.instance!.setString(
        Utils.localUserKey,
        jsonEncode(jsonDecode(response.body)['user']).toString(),
      );
      user.value = User.fromJson(
        jsonDecode(
          SharedPreferencesManager.instance!.getString(Utils.localUserKey) ??
              "",
        ),
      );
      MessagesManager.showSuccessMessage("Profile updated successfully".tr);
    } else {
      MessagesManager.showErrorMessage("Failed to update profile".tr);
    }
    setIsProfileUpdateLoading(false);
  }

  void getCoachSchedule(String coachId) async {
    getCoachScheduleLoading.value = true;
    // update();
    Utils.logEvent("view_content", {
      "content_type": "coach_schedule",
      "content_id": coachId,
    });
    Get.find<CoachController>()
        .getCoachSchedules(
          coachId != "" ? coachId : selectedCoach.value.id ?? "",
        )
        .then((value) {
          getCoachScheduleLoading.value = false;
          // update();
        });
  }

  void deleteAccount() async {
    isDeleteAccountLoading.value = true;
    update();
    final response = await UserRepository().deleteAccount();
    if (response.statusCode == 200) {
      await SharedPreferencesManager.instance!.clear();
      Get.offAllNamed(AppRoutes.splashScreen);
    } else {
      MessagesManager.showErrorMessage("Failed to delete account".tr);
    }
    isDeleteAccountLoading.value = false;
    update();
  }

  void getCourses() async {
    try {
      isCoursesLoading.value = true;
      final response = await CoursesRepository().getCourses();
      if (response.statusCode == 200) {
        courses.value =
            jsonDecode(
              response.body,
            ).map<Course>((e) => Course.fromJson(e)).toList();
      }
      isCoursesLoading.value = false;
    } catch (e) {
      isCoursesLoading.value = false;
      print(e);
    }
  }

  void getNewNotification() {
    init();
  }
}
