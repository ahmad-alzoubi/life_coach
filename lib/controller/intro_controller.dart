import 'package:coach_life/model/intro.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:get/get.dart';

class IntroController extends GetxController {
  
  List<Intro> introList = [
    Intro(
      title: 'Welcome to Coach Life'.tr,
      description: 'Coach Life is a platform that connects you with the best coaches in the world. You can find a coach for any area of your life, from fitness to business.'.tr,
      image: 'assets/images/intro1.png',
    ),
    Intro(
      title: 'Find the Perfect Coach'.tr,
      description: 'With Coach Life, you can search for coaches based on your needs and preferences. You can also read reviews and ratings from other users to help you make the best decision.'.tr,
      image: 'assets/images/intro2.png',
    ),
    Intro(
      title: 'Book a Session'.tr,
      description: 'Once you find the perfect coach, you can book a session with them directly through the app. You can choose the date, time, and location that works best for you.'.tr,
      image: 'assets/images/intro3.png',
    ),
  ];

  RxInt currentIndex = 0.obs;
  RxBool functionCalled = false.obs;

  void next() {
    if (currentIndex.value < introList.length - 1) {
      currentIndex.value++;
      update();
    }
  }

  void back() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      update();
    }
  }

  void finish() async {
    await SharedPreferencesManager.instance!.setBool(Utils.buseTutorial, true);
    Get.offAllNamed(AppRoutes.loginScreen);
  }

  void setFunctionCalled(bool value) {
    functionCalled.value = value;
    update();
  }

}