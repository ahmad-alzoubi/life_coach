import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/asstes/images_manager.dart';

class DashboardScree extends StatelessWidget {
  const DashboardScree({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.lightScaffoldColor,
          body: controller.screens[controller.currentIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            selectedItemColor: AppColors.primaryColor,
            onTap: (index) {
              controller.changeIndex(index);
            },
            selectedLabelStyle: const TextStyle(fontFamily: "Cairo"),
            unselectedLabelStyle: const TextStyle(fontFamily: "Cairo"),
            items:
                controller.user.value.type == "user"
                    ? [
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          ImagesManager.homeIcon,
                          colorFilter:
                              controller.currentIndex.value == 0
                                  ? ColorFilter.mode(
                                    AppColors.primaryColor,
                                    BlendMode.srcIn,
                                  )
                                  : null,
                        ),
                        label: 'Home'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          ImagesManager.booksIcon,
                          // colorFilter: controller.currentIndex.value == 1 ? ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn) : ColorFilter.mode(AppColors.grayColor, BlendMode.srcIn)
                          width: 35,
                          height: 35,
                          color:
                              controller.currentIndex.value == 1
                                  ? AppColors.primaryColor
                                  : AppColors.darkGrayColor,
                        ),
                        label: 'Courses'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          ImagesManager.historyIcon,
                          colorFilter:
                              controller.currentIndex.value == 2
                                  ? ColorFilter.mode(
                                    AppColors.primaryColor,
                                    BlendMode.srcIn,
                                  )
                                  : null,
                        ),
                        label: 'Old Appointments'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          ImagesManager.messagesIcon,
                          colorFilter:
                              controller.currentIndex.value == 3
                                  ? ColorFilter.mode(
                                    AppColors.primaryColor,
                                    BlendMode.srcIn,
                                  )
                                  : null,
                        ),
                        label: 'Chats'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          ImagesManager.userIcon,
                          colorFilter:
                              controller.currentIndex.value == 4
                                  ? ColorFilter.mode(
                                    AppColors.primaryColor,
                                    BlendMode.srcIn,
                                  )
                                  : null,
                        ),
                        label: 'Account'.tr,
                      ),
                    ]
                    : [
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          ImagesManager.homeIcon,
                          colorFilter:
                              controller.currentIndex.value == 0
                                  ? ColorFilter.mode(
                                    AppColors.primaryColor,
                                    BlendMode.srcIn,
                                  )
                                  : null,
                        ),
                        label: 'Home'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          ImagesManager.messagesIcon,
                          colorFilter:
                              controller.currentIndex.value == 1
                                  ? ColorFilter.mode(
                                    AppColors.primaryColor,
                                    BlendMode.srcIn,
                                  )
                                  : null,
                        ),
                        label: 'Chats'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          ImagesManager.userIcon,
                          colorFilter:
                              controller.currentIndex.value == 2
                                  ? ColorFilter.mode(
                                    AppColors.primaryColor,
                                    BlendMode.srcIn,
                                  )
                                  : null,
                        ),
                        label: 'Account'.tr,
                      ),
                    ],
          ),
          // floating action button for aboutus button to open bottomsheet
          floatingActionButton:
              controller.currentIndex.value != 4
                  ? FloatingActionButton(
                    onPressed: () async {
                      // launch WhatsApp url
                      await launchUrl(Uri.parse("https://wa.me/+966549698188"));
                    },
                    backgroundColor: AppColors.successColor,
                    child: Image.asset(
                      ImagesManager.whatsappIcon,
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                  )
                  : null,
        );
      },
    );
  }
}
