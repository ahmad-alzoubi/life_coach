import 'package:coach_life/controller/cart_controller.dart';
import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/view/base/video_player_screen.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../utils/theme/app_colors.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  bool get isBlocked {
    final blockedPhones =
        Get.find<DashboardController>().config.value.blockUsersPhone ?? [];
    final userPhone = Get.find<DashboardController>().user.value.phone;
    return blockedPhones.contains(userPhone);
  }

  @override
  Widget build(BuildContext context) {
    // Transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final dashboardController = Get.find<DashboardController>();
    final courseController = Get.find<DashboardController>();
    final controller = Get.find<CoachController>();

    final selectedCourse = dashboardController.selectedCourse.value!;

    return Scaffold(
      body: GetBuilder<DashboardController>(
        builder: (_) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    /// HEADER IMAGE & TITLE
                    Container(
                      height: context.screenHeight * 0.42,
                      width: context.screenWidth,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: Get.back,
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: AppText(
                                    text: "Course Details".tr,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontColor: Colors.black,
                                  ),
                                ),
                                if (!isBlocked)
                                  GetX<CartController>(
                                    init: Get.find<CartController>(),
                                    builder: (cartCtrl) {
                                      final int cartCount =
                                          cartCtrl.cartItems.length;
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Get.toNamed(AppRoutes.cartScreen);
                                            },
                                            icon: Icon(
                                              Icons.shopping_cart_outlined,
                                              color: AppColors.darkScaffoldColor,
                                            ),
                                          ),
                                          if (cartCount > 0)
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  cartCount.toString(),
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.lightTextColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),

                          /// COURSE IMAGE & TITLE CARD
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.bottomCenter,
                                radius: 2.3,
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  const Color(0xFFB19CD9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.grayColor
                                      .withOpacity(0.1),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      selectedCourse.image.toString(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                AppText(
                                  text: selectedCourse.title.toString(),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontColor: Colors.black,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// DESCRIPTION
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.screenWidth * 0.05,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Description".tr,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontColor: AppColors.blackColor,
                          ),
                          const SizedBox(height: 10),
                          AppText(
                            text: selectedCourse.description.toString(),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontColor: AppColors.grayColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// COACH SECTION
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.screenWidth * 0.05,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1.5,
                                  color: AppColors.grayColor.withOpacity(0.5),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: AppText(
                                  text: "Coach".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontColor: AppColors.darkGreyColor,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1.5,
                                  color: AppColors.grayColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.lightScaffoldColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.grayColor.withOpacity(0.2),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      selectedCourse
                                          .coachDetails
                                          .media!
                                          .first
                                          .originalUrl
                                          .toString(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppText(
                                    text:
                                        selectedCourse.coachDetails.name
                                            .toString(),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontColor: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// ADD TO CART OR OPEN COURSE BUTTON
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.screenWidth * 0.05,
                      ),
                      child: AppButton(
                        title:
                            selectedCourse.isPurchased || isBlocked
                                ? "Open the course".tr
                                : "Add to Cart".tr,
                        background: AppColors.accentColor,
                        showArrowIcon: false,
                        isGradient: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.secondaryColor,
                            AppColors.primaryColor,
                          ],
                        ),
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        onTap: () async {
                          if (selectedCourse.isPurchased || isBlocked) {
                            if (selectedCourse.contentType == "mp4") {
                              Get.to(
                                VideoPlayerScreen(
                                  videoUrl: selectedCourse.contentPath,
                                ),
                              );
                            } else {
                              Get.bottomSheet(
                                isScrollControlled: true,
                                Container(
                                  height: context.screenHeight,
                                  width: context.screenWidth,
                                  color: AppColors.lightScaffoldColor,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: Get.back,
                                            icon: Icon(
                                              Icons.arrow_back_ios,
                                              color: AppColors.darkGreyColor,
                                            ),
                                          ),
                                          Expanded(
                                            child: AppText(
                                              text: "Course".tr,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontColor:
                                                  AppColors.darkGreyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: SfPdfViewer.network(
                                          selectedCourse.contentPath,
                                          canShowPaginationDialog: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        }
                      } else {
                        final cartController = Get.find<CartController>();
                        await cartController.addToCart(selectedCourse);
                        MessagesManager.showSuccessMessage(
                          "Course added to cart".tr,
                        );
                      }
                    },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              /// LOADING OVERLAY
              Obx(() {
                if (controller.isLoading.isTrue) {
                  return Container(
                    color: Colors.black.withOpacity(0.5),
                    height: context.screenHeight,
                    width: context.screenWidth,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          );
        },
      ),
    );
  }
}
