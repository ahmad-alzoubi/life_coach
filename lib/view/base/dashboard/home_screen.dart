import 'package:carousel_slider/carousel_slider.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/asstes/images_manager.dart';
import 'package:coach_life/utils/dimensions/font_sizes.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/coach_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:get/get.dart';
import '../../widgets/app_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = context.screenHeight; // Screen height
    double screenWidth = context.screenWidth;  // Screen width

    return SafeArea(
      child: GetBuilder<DashboardController>(
        builder: (controller) {

          return RefreshIndicator(
            onRefresh: () async {
              controller.onInit();
            },
            color: AppColors.secondaryColor,
            strokeWidth: 2,
            child: Stack(
              children: [
                Container(
                  color: AppColors.lightScaffoldColor,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Greeting Row
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05, // 5% padding
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                text:
                                    "${"hello".tr}, ${controller.user.value.name}",
                                fontSize: FontSizes.largeFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_active,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  Get.toNamed(AppRoutes.notificationsScreen);
                                },
                              ),
                            ],
                          ),
                        ),

                        const Divider(thickness: 0.3),

                        CarouselSlider(
                          items: [
                             // Banner
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.05), // 5% padding
                              child: SizedBox(
                                height: screenHeight * 0.2, // 20% of screen height
                                width: screenWidth, // Full screen width
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    ImagesManager.banner,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // Banner
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.05), // 5% padding
                              child: SizedBox(
                                height: screenHeight * 0.2, // 20% of screen height
                                width: screenWidth, // Full screen width
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    ImagesManager.banner2,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),

                            // Banner
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.05), // 5% padding
                              child: SizedBox(
                                height: screenHeight * 0.2, // 20% of screen height
                                width: screenWidth, // Full screen width
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    ImagesManager.banner3,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          options: CarouselOptions(
                              height: screenHeight * 0.2,
                              aspectRatio: 1,
                              viewportFraction: 1,
                              initialPage: 0,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 3),
                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.3,
                              // onPageChanged: callbackFunction,
                              scrollDirection: Axis.horizontal,
                          )
                        ),

                        Obx(() {
                            if (controller.isDataLoading.isTrue) {
                              return _buildSkeletonLoader();
                            }

                            return Column(
                              children: [
                                // All Coaches Section
                                _buildSectionTitle(
                                  title: "all_coaches".tr,
                                  padding: screenWidth * 0.05,
                                ),
                                _buildGrid(
                                  items: controller.mostPopularCoachs,
                                    // heightFactor: screenHeight * 0.18, // 15% of screen height
                                  itemCount: controller.mostPopularCoachs.length > 2
                                      ? controller.mostPopularCoachs.length - 2
                                      : controller.mostPopularCoachs.length,
                                  controller: controller,
                                  itemOffset: 2,
                                ),

                                // Most Popular Section
                                _buildSectionTitle(
                                  title: "most_popular".tr,
                                  padding: screenWidth * 0.05,
                                ),
                                _buildGrid(
                                  items: controller.mostPopularCoachs,
                                  // heightFactor: screenHeight * 0.19, // 15% of screen height
                                  itemCount:
                                      controller.mostPopularCoachs.length > 2 ? 2 : controller.mostPopularCoachs.length,
                                  controller: controller,
                                  itemOffset: 0,
                                ),
                              ],
                            );
                        })
                      ],
                    ),
                  ),
                ),

                // Booking Notification
                Obx(() => controller.haveBookingWillStart.isTrue &&
                        controller.countdownTime.value <= 300
                    ?
                    _buildBookingBottomSheet(
                        context: context,
                        controller: controller,
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      )
                    : const SizedBox())
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required double padding,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: AppText(
        text: title,
        fontSize: FontSizes.mediumFontSize,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildGrid({
    required List items,
    required int itemCount,
    required DashboardController controller,
    required int itemOffset,
  }) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(6),
      itemBuilder: (context, index) {
        return CoachCard(
          coach: items[index + itemOffset],
          controller: controller,
        );
      },
    );
  }

  Widget _buildBookingBottomSheet({
    required BuildContext context,
    required DashboardController controller,
    required double screenHeight,
    required double screenWidth,
  }) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: BottomSheet(
        onClosing: () {},
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        shadowColor: Colors.black,
        elevation: 30,
        builder: (context) {
          return SizedBox(
            height: screenHeight * 0.2, // 20% of screen height
            width: screenWidth, // Full screen width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.grayColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            controller.setHaveBookingWillStart(false);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                AppText(
                  text: "You have a booking will start soon".tr,
                  fontSize: FontSizes.largeFontSize,
                  fontWeight: FontWeight.w700,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                Obx(() => AppText(
                  text: "${"Time remaining".tr}: ${_formatTime(controller.countdownTime.value)}",
                  fontSize: FontSizes.largeFontSize,
                  fontWeight: FontWeight.w700,
                  fontColor: AppColors.secondaryColor,
                  mainAxisAlignment: MainAxisAlignment.center,
                ))

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: [
        _buildSectionTitle(
          title: "all_coaches".tr,
          padding: 10,
        ),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4, // Placeholder item count
          itemBuilder: (context, index) {
            return _skiltonCoachCard(context);
          },
        ),
        _buildSectionTitle(
          title: "most_popular".tr,
          padding: 10,
        ),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2, // Placeholder item count
          itemBuilder: (context, index) {
            return _skiltonCoachCard(context);
          },
        ),
      ],
    );
  }

  Widget _skiltonCoachCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.lightScaffoldColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 20,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SkeletonAvatar(
                style: SkeletonAvatarStyle(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.3,
                  borderRadius: BorderRadius.circular(15)
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonParagraph(
                    style: const SkeletonParagraphStyle(
                      lines: 1,
                      spacing: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: SkeletonParagraph(
                      style: const SkeletonParagraphStyle(
                        lines: 1,
                        spacing: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int countdownTime) {
    final minutes = (countdownTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdownTime % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
