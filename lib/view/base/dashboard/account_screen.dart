import 'package:cached_network_image/cached_network_image.dart';
import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark
    ));
    return GetBuilder<DashboardController>(
      builder: (controller) {
        return Container(
          height: context.screenHeight,
          width: context.screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF845EF3),
                AppColors.primaryColor,
              ],
              transform: const GradientRotation(0.7),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: (controller.user.value.media == null || controller.user.value.media!.isEmpty) ? Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryColor,
                      ) : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: controller.user.value.media!.first.originalUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(color: AppColors.primaryColor,),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.errorColor,
                          ),
                          fadeInCurve: Curves.easeIn,
                          fadeInDuration: const Duration(milliseconds: 500),
                          fadeOutCurve: Curves.easeOut,
                          fadeOutDuration: const Duration(milliseconds: 500),
                        )
                      )
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          controller.selectImageFromGallery();
                        },
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.primaryColor,
                          child: controller.isUpdateProfileLoading.isTrue ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator()) : const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppText(
                  text: controller.user.value.name ?? "",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontColor: AppColors.lightTextColor,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: context.screenWidth,
                    decoration: BoxDecoration(
                      color: AppColors.lightScaffoldColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Get.toNamed(AppRoutes.updateProfileScreen);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "edit_profile".tr,
                                    fontSize: 20,

                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          controller.user.value.type == "coach" ? InkWell(
                            onTap: () {
                              Get.find<CoachController>().getWeeklySchedule();
                              Get.toNamed(AppRoutes.scheduelScreen);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "scheduel".tr,
                                    fontSize: 20,

                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios
                                  )
                                ],
                              ),
                            ),
                          ) : const SizedBox(),

                          SizedBox(height: controller.user.value.type == "coach" ? 20 : 0),

                          controller.user.value.type == "coach" ? InkWell(
                            onTap: () {
                              Get.find<CoachController>().getCoachAttributes();
                              Get.toNamed(AppRoutes.bookingSettingsScreen);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "Booking Settings".tr,
                                    fontSize: 20,

                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios
                                  )
                                ],
                              ),
                            ),
                          ) : const SizedBox(),

                          SizedBox(height: controller.user.value.type == "coach" ? 20 : 0),
                          InkWell(
                            onTap: () {
                              controller.getWallet();
                              Get.toNamed(AppRoutes.walletScreen);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "wallet".tr,
                                    fontSize: 20,

                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Get.bottomSheet(
                                //show languages en, ar
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightScaffoldColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Utils.changeLanguage(const Locale('en'));
                                          Get.back();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(Get.locale!.languageCode == "en" ? 15 : 0),
                                            color: Get.locale!.languageCode == "en" ? AppColors.primaryColor : null,
                                          ),
                                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          child: AppText(
                                            text: "English".tr,
                                            fontSize: 20,

                                            fontColor: Get.locale!.languageCode == "en" ? Colors.white : null,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Utils.changeLanguage(const Locale('ar'));
                                          Get.back();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(Get.locale!.languageCode == "ar" ? 15 : 0),
                                            color: Get.locale!.languageCode == "ar" ? AppColors.primaryColor : null,
                                          ),
                                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          child: AppText(
                                            text: "Arabic".tr,
                                            fontSize: 20,

                                            fontColor: Get.locale!.languageCode == "ar" ? Colors.white : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "language".tr,
                                    fontSize: 20,

                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Get.toNamed(AppRoutes.notificationsScreen);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "notifications".tr,
                                    fontSize: 20,

                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios
                                  )
                                ],
                              ),
                            ),
                          ),
                          // privacy policy
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () async{
                              await launchUrl(Uri.parse("https://lifecoach.com.sa/privacy-policy.html"));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "privacy_policy".tr,
                                    fontSize: 20,

                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios
                                  )
                                ],
                              ),
                            ),
                          ),
                          // terms and conditions
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () async {
                              await launchUrl(Uri.parse("https://lifecoach.com.sa/terms-conditions.html"));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "terms_and_conditions".tr,
                                    fontSize: 20,

                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            title: "logout".tr,
                            onTap: () {
                              controller.logout();
                              Get.back();
                            },
                            showArrowIcon: false,
                            contentCenter: true,
                            background: AppColors.errorColor,
                            fontSize: 15,
                            buttonHeight: 54,
                            isTransparent: true,
                            textColor: AppColors.errorColor,
                            padding: EdgeInsets.zero,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            isTransparent: true,
                            title: "WhatsApp".tr,
                            onTap: () async {
                              // launch WhatsApp url
                              await launchUrl(Uri.parse("https://wa.me/+966549698188"));
                            },
                            showArrowIcon: false,
                            contentCenter: true,
                            background: AppColors.successColor,
                            fontSize: 15,
                            buttonHeight: 54,
                            textColor: AppColors.successColor,
                            padding: EdgeInsets.zero,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ]
                      ),
                    ),
                  ),

                )
              ],
            ),
          ),
        );
      }
    );
  }
}
