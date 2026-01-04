import 'dart:convert';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/chat_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../enums/languages.dart';
import '../main.dart';
import '../routes/app_routes.dart';
import '../services/shared_preferances_manager.dart';

class Utils {
  static const Map<Languages, Locale> languages = {
    Languages.arabic: Locale("ar"),
    Languages.english: Locale("en"),
  };

  static const platform = MethodChannel('tiktok_events');

  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static AppsflyerSdk appsflyerSdk = AppsflyerSdk(
    AppsFlyerOptions(
      afDevKey:
          GetPlatform.isAndroid
              ? "odrueYnn2jnZCzw27ALv5A"
              : "odrueYnn2jnZCzw27ALv5A",
      appId: '6499420390', // Only required for iOS
      showDebug: true, // Enable debugging during development
    ),
  );

  static Future<bool?> flyersLogEvent(
    String eventName,
    Map? eventValues,
  ) async {
    bool? result;
    try {
      result = await appsflyerSdk.logEvent(eventName, eventValues);
    } on Exception catch (e) {}
    print("Result logEvent: $result");
  }

  static void logFirstOpenEvent() {
    analytics.logEvent(
      name: 'first_openـ${GetPlatform.isAndroid ? 'android' : 'ios'}',
      parameters: {'platform': GetPlatform.isAndroid ? 'android' : 'ios'},
    );
    flyersLogEvent("first_openـ${GetPlatform.isAndroid ? 'android' : 'ios'}", {
      'platform': GetPlatform.isAndroid ? 'android' : 'ios',
    });
    // analytics.logEvent(
    //   name: 'install',
    //   parameters: {'platform': GetPlatform.isAndroid ? 'android' : 'ios'},
    // );
  }

  static void logInAppPurchaseEvent(String itemId, double value) {
    analytics.logEvent(
      name: 'purchase_${GetPlatform.isAndroid ? 'android' : 'ios'}',
      parameters: {'item_id': itemId, 'value': value, 'currency': 'SAR'},
    );
    flyersLogEvent("purchase_${GetPlatform.isAndroid ? 'android' : 'ios'}", {
      'item_id': itemId,
      'value': value,
      'currency': 'SAR',
    });
  }

  static void logEvent(String eventName, Map<String, Object>? parameters) {
    analytics.logEvent(name: eventName, parameters: parameters);
  }

  // logErrorEvent
  static void logErrorEvent(String error) {
    analytics.logEvent(name: 'error', parameters: {'error': error});
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isFlutterLocalNotificationsInitialized = false;

  static const Duration appNavigationDuration = Duration(milliseconds: 250);

  static String currentUuid = const Uuid().v4();

  // static const FlutterSecureStorage storage = FlutterSecureStorage();
  static SharedPreferences? prefs = SharedPreferencesManager.instance;

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static String agoraAppId = "1f2ae0c2da82447392f9ed3df73a59eb";

  static const String usedLoggedInKey = "user_logged_in";
  static const String localUserKey = "user_data";
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String languageKey = 'language';
  static const String buseTutorial = 'buse_tutorial';

  static String path = Directory.current.path;

  String convertTimeStamp(int timestamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String convertedDateTime =
        "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}-${dateTime.minute.toString().padLeft(2, '0')}";
    return convertedDateTime;
  }

  static String displayBio(String? bio) {
    if (bio != null && bio.length > 30) {
      return '${bio.substring(0, 30)}...'; // Adds an ellipsis to indicate truncation
    } else {
      return bio ?? ''; // Return the bio as is or an empty string if it is null
    }
  }

  static String displayName(String name) {
    if (name.length > 11) {
      return '${name.substring(0, 11)}..'; // Adds an ellipsis to indicate truncation
    } else {
      return name; // Return the bio as is or an empty string if it is null
    }
  }

  static String convertTime24To12(String time, {bool removeSeconds = false}) {
    // Splitting the input time into components
    final parts = time.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final second = parts.length > 2 ? int.parse(parts[2]) : 0;

    // Determining the period (AM/PM)
    final period = hour < 12 ? 'AM'.tr : 'PM'.tr;

    // Converting hour to 12-hour format
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    // Formatting the hour, minute, and second with leading zeros if needed
    final hour12Str = hour12.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    final secondStr = second.toString().padLeft(2, '0');

    // Creating the formatted time string
    final formattedTime =
        removeSeconds == true
            ? "$hour12Str:$minuteStr $period"
            : "$hour12Str:$minuteStr:$secondStr $period";

    return formattedTime;
  }

  static String addMinutesToTime(String time, int minutes) {
    final hour = int.parse(time.split(":")[0]);
    final minute = int.parse(time.split(":")[1]);
    final newMinute = minute + minutes;
    if (newMinute >= 60) {
      return "${hour + 1}:${newMinute - 60}";
    } else {
      return "$hour:$newMinute";
    }
  }

  static Future<File> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return File(image!.path);
  }

  static void showLocalNotification(String title, String body, int hashCode) {
    flutterLocalNotificationsPlugin.show(
      hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launch_background',
        ),
      ),
    );
  }

  static void showIncomingCall(
    String bookingId,
    String channelName,
    String callTitle,
    String connectType,
    String minutes,
  ) async {
    print("Call Title: $callTitle");
    CallKitParams callKitParams = CallKitParams(
      id: const Uuid().v4(), // Unique UUID per call [[1]]
      nameCaller: callTitle, // Displayed caller name
      appName: 'Life Coach', // Must match your app's display name [[7]]
      type: 1, // 0=audio, 1=video (if your app supports video calls)
      textAccept: 'قبول', // Localized button text
      textDecline: 'رفض',
      duration: 60000, // Timeout duration (ms) before auto-decline [[3]]
      extra: {'bookingId': bookingId}, // Pass critical data via `extra`
      // avatar: 'https://i.pravatar.cc/100',
      // handle: '0123456789',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: AppColors.primaryColor.toString(),
        // backgroundUrl: 'https://i.pravatar.cc/500',
        actionColor: AppColors.secondaryColor.toString(),
        textColor: AppColors.lightTextColor.toString(),
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        isShowCallID: false,
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'voiceChat',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      switch (event!.event) {
        case Event.actionCallIncoming:
          if (kDebugMode) {
            print('Incoming call');
          }
          break;
        case Event.actionCallStart:
          if (kDebugMode) {
            print('Start call');
          }
          break;
        case Event.actionCallAccept:
          if (kDebugMode) {
            print('Accept call');
          }
          BookingController controller;
          if (Get.isRegistered<BookingController>()) {
            controller = Get.find<BookingController>();
          } else {
            controller = Get.put(BookingController());
          }
          final bool callAlreadyActive =
              (controller.callStarted.value && controller.client != null);
          if (callAlreadyActive) {
            if (kDebugMode) {
              print('Accept call ignored — call already active');
            }
            break;
          }
          if (Get.currentRoute != AppRoutes.callSreen) {
            Get.toNamed(AppRoutes.callSreen);
          }
          controller.initAgoraCall(
            channelName,
            connectType,
            bookingId,
            int.parse(minutes),
          );
          break;
        case Event.actionCallDecline:
          if (kDebugMode) {
            print('Decline call');
          }
          break;
        case Event.actionCallEnded:
          if (kDebugMode) {
            print('End call');
          }
          break;
        case Event.actionCallTimeout:
          if (kDebugMode) {
            print('Timeout call');
          }
          break;
        case Event.actionCallCallback:
          if (kDebugMode) {
            print('Callback call');
          }
          break;
        case Event.actionCallToggleHold:
          if (kDebugMode) {
            print('Toggle hold call');
          }
          break;
        case Event.actionCallToggleMute:
          if (kDebugMode) {
            print('Toggle mute call');
          }
          break;
        case Event.actionCallToggleDmtf:
          if (kDebugMode) {
            print('Toggle dmtf call');
          }
          break;
        case Event.actionCallToggleGroup:
          if (kDebugMode) {
            print('Toggle group call');
          }
          break;
        case Event.actionCallToggleAudioSession:
          if (kDebugMode) {
            print('Toggle audio session call');
          }
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          if (kDebugMode) {
            print('Update device push token voip');
          }
          break;
        case Event.actionCallCustom:
          if (kDebugMode) {
            print('Custom call');
          }
          break;

        default:
          if (kDebugMode) {
            print('Unknown event: ${event.event}');
          }
          break;
      }
    });
    print("will show callkit incoming");
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: Get.context!,
      builder:
          (BuildContext context) => CupertinoAlertDialog(
            title: Text(title ?? ''),
            content: Text(body ?? ''),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  if (kDebugMode) {
                    print('payload: $payload');
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'booking_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          // onDidReceiveLocalNotification: onDidReceiveLocalNotification
        );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        if (notificationResponse.payload != null) {
          if (kDebugMode) {
            print('notification payload: ${notificationResponse.payload}');
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    final notificationSettings = await firebaseMessaging.requestPermission(
      provisional: true,
    );
    // await firebaseMessaging.setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );

    // await FirebaseMessaging.instance.getToken().then((onValue)
    //  {
    //  print("fcm =====>>>> $onValue");

    //  });
    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      if (kDebugMode) {
        print("New Notification With data: ${message.data}");
        print("Notification Body: ${message.data['chid']}");
        print("Notification Title: ${message.notification!.title}");
      }

      // Parsing the chid field if it is a string
      var chidData = message.data['chid'];
      Map<String, dynamic>? chid;
      if (chidData is String) {
        try {
          chid = jsonDecode(chidData);
        } catch (e) {
          if (kDebugMode) {
            print("Failed to parse chid data: $chidData");
          }
          chid = null;
        }
      } else if (chidData is Map<String, dynamic>) {
        chid = chidData;
      }

      if (message.notification!.title == "Booking alert") {
        if (kDebugMode) {
          print("Subscribing to topic Booking${notification.title}");
        }
        showLocalNotification(notification.title!.tr, notification.body!.tr, 0);
      } else if (message.notification!.title == "Incoming call") {
        if (kDebugMode) {
          print("Subscribing to topic ${notification.title}");
        }
        // Show incoming call screen
        if (chid != null &&
            chid.containsKey('bookingId') &&
            chid.containsKey('callTitle')) {
          // showIncomingCall(chid['bookingId'].toString(), chid['channelName'], chid['callTitle'], chid['connectType'], chid['minutes'].toString());
        } else {
          if (kDebugMode) {
            print("Invalid chid data: ${message.data['chid']}");
          }
        }
        showLocalNotification(
          notification.title!.tr,
          "${"Call from".tr} ${chid!['callTitle']} ${"Please open the app to start the call".tr}",
          0,
        );
      } else if (message.data['Incoming chat'] != null &&
          message.data['Incoming chat'] == 'true') {
        if (kDebugMode) {
          print("Subscribing to topic ${notification.title}");
        }
        // Show incoming chat screen
        showLocalNotification(notification.title!.tr, notification.body!.tr, 0);
      } else if (message.notification!.title == "New booking") {
        if (chid != null && chid.containsKey('bookingId')) {
          if (kDebugMode) {
            print("Subscribing to topic bookingId${chid['bookingId']}");
          }
          showLocalNotification(
            notification.title!.tr,
            notification.body!.tr,
            0,
          );
          // subscribeToTopic(chid['bookingId']);
        } else {
          if (kDebugMode) {
            print("Invalid chid data: ${message.data['chid']}");
          }
        }
      } else {
        if (kDebugMode) {
          print("From else");
        }
        // Optionally show local notification
        print('inChatNow===> ${Get.find<ChatController>().inChatNow.value}');
        if (!Get.find<ChatController>().inChatNow.value) {
          showLocalNotification(
            notification.title!.tr,
            notification.body!.tr,
            0,
          );
        }
      }
    }
  }

  static void subscribeToTopic(String topic) async {
    print('topic === >>> $topic');
    try {
      if (kDebugMode) {
        print("Subscribing to topic $topic");
      }
      if (GetPlatform.isIOS) {
        String? apnsToken =
            await FirebaseMessaging.instance.getAPNSToken(); //Await the token
        if (apnsToken != null) {
          await firebaseMessaging.unsubscribeFromTopic(topic);
          await firebaseMessaging.subscribeToTopic(topic);
        }
      } else {
        await firebaseMessaging.unsubscribeFromTopic(topic);
        await firebaseMessaging.subscribeToTopic(topic);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error subscribing to topic $topic: $e");
      }
    }
  }

  static void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
    prefs!.setString(languageKey, locale.languageCode);
  }

  static Future<void> initializePayWithCardSdk(
    double price,
    String mail,
    String phone,
    bool createReservation, {
    String product = "booking",
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse(
          Get.find<DashboardController>().config.value.paymentGatewayUrl!,
        ),
        body: jsonEncode({
          "profile_id":
              Get.find<DashboardController>()
                  .config
                  .value
                  .paymentGatewayProfileId!,
          "tran_type": "sale",
          "tran_class": "ecom",
          "cart_description": "Description of the items/services",
          "cart_id": "cart_${DateTime.now().millisecondsSinceEpoch}",
          "cart_currency": "SAR",
          "cart_amount": price,
          "hide_shipping": true,
          "hide_customer": true,
          "tokenise": "2",
          "show_save_card": true,
          "customer_details": {
            "name": " ",
            "email": mail,
            "phone": phone,
            "street1": "Saudi Arabia",
            "city": "riyadh",
            "state": "riyadh",
            "country": "SA",
            "zip": "121212",
          },
        }),
        headers: {
          "authorization":
              Get.find<DashboardController>().config.value.paymentGatewayKey!,
          "content-type": "application/json",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        Logger().d("initializePayWithCardSdk  => ${response.body}");
        Get.toNamed(
          AppRoutes.paymentWebView,
          arguments: {
            "url": json['redirect_url'],
            "transaction_type": "create",
            "product": product,
            //"id": id.toString(),
          },
        );
      } else {
        Logger().d("initializePayWithCardSdk  => ${response.body}");
      }
    } catch (e) {
      Logger().d("intializePaymentSdk Error  => $e");
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "cancelled":
        return Colors.red;
      case "completed":
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  static String generateUuid() {
    return const Uuid().v4();
  }

  static Future<String> getDeviceUUID() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor!;
    }

    return "unknown_device";
  }

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // throw Exception('Location services are disabled.');
      return Future<Position>(
        () => Position(
          latitude: 0,
          longitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future<Position>(
          () => Position(
            latitude: 0,
            longitude: 0,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          ),
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future<Position>(
        () => Position(
          latitude: 0,
          longitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<void> logTikTokEvent(String eventName, {properties}) async {
    try {
      await platform.invokeMethod('trackEvent', {
        'event': eventName,
        'properties': properties?.toJson(),
      });
      print("Event tracked successfully: $eventName");
    } on PlatformException catch (e) {
      print("Failed to track event: '${e.message}'.");
    }
  }

  static Future<void> identifyTikTokUser(
    String userId,
    String userName,
    String phoneNumber,
    String email,
  ) async {
    try {
      await platform.invokeMethod('identify', {
        'userId': userId,
        'userName': userName,
        'phoneNumber': phoneNumber,
        'email': email,
      });
      print("User identified successfully");
    } on PlatformException catch (e) {
      print("Failed to identify user: '${e.message}'.");
    }
  }
}
