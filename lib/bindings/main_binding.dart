import 'package:coach_life/controller/appointment_controller.dart';
import 'package:coach_life/controller/audio_player_manager.dart';
import 'package:coach_life/controller/auth_controller.dart';
import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/cart_controller.dart';
import 'package:coach_life/controller/chat_controller.dart';
import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/controller/intro_controller.dart';
import 'package:coach_life/controller/splash_controller.dart';
import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/services/auth_manager.dart';
import 'package:coach_life/services/cart_manager.dart';
import 'package:coach_life/services/socket_service.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:get/get.dart';

class MainBinding extends Bindings {
  @override
  Future<void> dependencies() async{
    Get.lazyPut<AuthManager>(() => AuthManager(), fenix: true);
    Get.lazyPut<SharedPreferencesManager>(() => SharedPreferencesManager(), fenix: true);
    Get.lazyPut<CartManager>(() => CartManager(), fenix: true);
    Get.lazyPut<SocketService>(() => SocketService(), fenix: true);
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<IntroController>(() => IntroController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<AppointmentController>(() => AppointmentController(), fenix: true);
    Get.lazyPut<ApiService>(() => ApiService(ApiRoutes.baseUrl), fenix: true);
    Get.lazyPut<CoachController>(() => CoachController(), fenix: true);
    Get.lazyPut<BookingController>(() => BookingController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
    Get.lazyPut<AudioPlayerManager>(() => AudioPlayerManager(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}