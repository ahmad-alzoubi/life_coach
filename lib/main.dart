import 'dart:async';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/base/bug_screen.dart';
import 'package:coach_life/view/main_app.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'bindings/main_binding.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Utils().showFlutterNotification(message);
  print('Handling a background message ${message.messageId}');
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    print('notification payload: ${notificationResponse.payload}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  try {
    // }else{
    //   await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform,
    //   );
    // }
    if (!kIsWeb) {
      await Utils().setupFlutterNotifications();
    }
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.setAnalyticsCollectionEnabled(true);
    MainBinding mainBinding = MainBinding();
    await mainBinding.dependencies();
    await SharedPreferencesManager.init();
    Utils.logFirstOpenEvent();
    String locale = Utils.prefs!.getString(Utils.languageKey) ?? "ar";
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   Utils().showFlutterNotification(message);
    //   if (message.notification != null) {
    //     Get.find<DashboardController>().getNewNotification();
    //   }
    // });
    TabbySDK().setup(
      withApiKey:
          'pk_test_0192426b-b548-ba07-8012-67d326c1fddf', // Put here your Api key, given by the Tabby integrations team
    );
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Customize the error screen
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      // print(details.toString());
      return Material(
        color: Colors.white,
        child: BugWidget(error: details.toString()),
      );
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey:
          GetPlatform.isAndroid
              ? "odrueYnn2jnZCzw27ALv5A"
              : "odrueYnn2jnZCzw27ALv5A",
      appId: '6499420390', // Only required for iOS
      showDebug: true, // Enable debugging during development
    );

    Utils.appsflyerSdk = AppsflyerSdk(options);
    await Utils.appsflyerSdk.initSdk(
      registerConversionDataCallback: true, // Enable conversion data callback
      registerOnAppOpenAttributionCallback:
          true, // Enable deep linking callback
    );

    FacebookAppEvents().setAutoLogAppEventsEnabled(true);

    // Utils.subscribeToTopic("all");

    runApp(MainApp(locale: locale));
  } catch (e) {
    // TODO: Handle any exceptions that occur during initialization
    if (kDebugMode) {
      print("Error initializing Firebase: $e");
    }
  }

  // Catch Dart errors
  // runZonedGuarded<Future<void>>(() async {

  // }, (Object error, StackTrace stackTrace) {
  //   send error to crashlytics
  //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
  // });
}
