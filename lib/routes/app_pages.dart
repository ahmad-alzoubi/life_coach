import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/view/base/booking_details_screen.dart';
import 'package:coach_life/view/base/call_screen.dart';
import 'package:coach_life/view/base/call_summary_screen.dart';
import 'package:coach_life/view/base/cart_screen.dart';
import 'package:coach_life/view/base/chat_screen.dart';
import 'package:coach_life/view/base/coach/booking_settings_screen.dart';
import 'package:coach_life/view/base/coach/register_screen.dart';
import 'package:coach_life/view/base/coach/scheduel_screen.dart';
import 'package:coach_life/view/base/coach_screen.dart';
import 'package:coach_life/view/base/complete_profile_screen.dart';
import 'package:coach_life/view/base/course_details_screen.dart';
import 'package:coach_life/view/base/dashboard/dashboard_screen.dart';
import 'package:coach_life/view/base/intro_screen.dart';
import 'package:coach_life/view/base/notifications_screen.dart';
import 'package:coach_life/view/base/otp_screen.dart';
import 'package:coach_life/view/base/pre_call_screen.dart';
import 'package:coach_life/view/base/select_booking_time.dart';
import 'package:coach_life/view/base/session_booking_screen.dart';
import 'package:coach_life/view/base/signin_screen.dart';
import 'package:coach_life/view/base/update_profile_screen.dart';
import 'package:coach_life/view/base/waiting_payment_screen.dart';
import 'package:coach_life/view/base/wallet_screen.dart';
import 'package:get/get.dart';

import '../bindings/payment_web_view_bindings.dart';
import '../view/base/payment_web_view.dart';
import '../view/base/select_connection_type_booking.dart';
import '../view/base/splash_screen.dart';

class AppPages {
  static List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.introScreen, page: () => const IntroScreen()),
    GetPage(name: AppRoutes.loginScreen, page: () => const SigninScreen()),
    GetPage(name: AppRoutes.registerScreen, page: () => const RegisterScreen()),
    GetPage(name: AppRoutes.enterOtpScreen, page: () => const OtpScreen()),
    GetPage(
      name: AppRoutes.dashboardScreen,
      page: () => const DashboardScree(),
    ),
    GetPage(
      name: AppRoutes.coachDetailsScreen,
      page: () => const CoachScreen(),
    ),
    GetPage(
      name: AppRoutes.bookingScreen,
      page: () => const SessionBookingScreen(),
    ),
    GetPage(
      name: AppRoutes.selectBookingTimeScreen,
      page: () => const SelectBookingTimeScreen(),
    ),
    GetPage(
      name: AppRoutes.selectConnectionTypeBookingScreen,
      page: () => const SelectConnectionTypeBookingScreen(),
    ),
    GetPage(name: AppRoutes.chatScreen, page: () => const ChatScreen()),
    GetPage(name: AppRoutes.callSreen, page: () => const CallScreen()),
    GetPage(
      name: AppRoutes.callSummaryScreen,
      page: () => const CallSummaryScreen(),
    ),
    GetPage(
      name: AppRoutes.notificationsScreen,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: AppRoutes.updateProfileScreen,
      page: () => const UpdateProfileScreen(),
    ),
    GetPage(name: AppRoutes.walletScreen, page: () => const WalletScreen()),
    GetPage(name: AppRoutes.scheduelScreen, page: () => const ScheduelScreen()),
    GetPage(
      name: AppRoutes.bookingDetails,
      page: () => const BookingDetailsScreen(),
    ),

    GetPage(
      name: AppRoutes.paymentWebView,
      page: () => const PaymentWebView(),
      binding: PaymentWebViewBindings(),
    ),
    GetPage(
      name: AppRoutes.completeProfileScreen,
      page: () => const CompleteProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.bookingSettingsScreen,
      page: () => const BookingSettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.courssDetailsScreen,
      page: () => const CourseDetailsScreen(),
    ),
    GetPage(name: AppRoutes.cartScreen, page: () => const CartScreen()),
    GetPage(
      name: AppRoutes.waitingPaymentScreen,
      page: () => const WaitingPaymentScreen(),
    ),
  ];
}
