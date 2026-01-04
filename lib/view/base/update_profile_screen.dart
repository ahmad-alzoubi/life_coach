import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/utils/dimensions/screen_dimensions.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:coach_life/view/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                AppText(
                  text: "Update Profile".tr,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: GetBuilder<DashboardController>(
                builder: (controller) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        AppTextField(
                          label: "Name".tr,
                          controller: controller.nameController,
                          hint: "Name".tr,
                          backgroundColor: AppColors.grayColor.withOpacity(0.4),
                        ),
                        const SizedBox(height: 20),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: AppColors.grayColor.withOpacity(0.4),
                        //       borderRadius: BorderRadius.circular(ScreenDimensions.buttonBorderRadius),
                        //     ),
                        //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        //     child: Row(
                        //       children: [
                        //         Column(
                        //           children: [
                        //             // AppText(
                        //             //     text: controller.country.flagEmoji,
                        //             //     fontSize: 25,
                        //             //   ),
                        //               AppText(
                        //                 text: "+${controller.country.phoneCode}",
                        //                 fontSize: 16,
                        //                 fontColor: AppColors.blackColor.withOpacity(0.6),
                        //               ),
                        //           ],
                        //         ),
                        //         const SizedBox(width: 10),
                        //         Expanded(
                        //           child: AppTextField(
                        //             controller: controller.phoneController,
                        //             keyboardType: TextInputType.phone,
                        //             hint: "Phone".tr,
                        //             // decoration: InputDecoration(
                        //             //   hintText: "Phone".tr,
                        //             //   hintStyle: TextStyle(
                        //             //     color: AppColors.blackColor.withOpacity(0.6),
                        //             //     fontFamily: "Cairo",
                        //             //     fontSize: FontSizes.defaultFontSize
                        //             //   ),
                        //             //   border: InputBorder.none,
                        //             // ),
                        //             //input accept only numbers
                        //             inputFormatters: [
                        //               FilteringTextInputFormatter.digitsOnly,
                        //             ],
                        //             maxInputDigits: 9,
                        //             padding: EdgeInsets.zero,
                        //             fieldPadding: EdgeInsets.zero,
                        //             backgroundColor: Colors.transparent,
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: controller.user.value.type == "coach" ? 0 : 15,
                        // ),
                        controller.user.value.type == "coach" ? Column(
                          children: [
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: controller.bioController,
                              hint: "Bio".tr,
                              backgroundColor: AppColors.grayColor.withOpacity(0.4),
                              label: "Bio".tr,
                              maxLines: 5,
                            ),
                            // const SizedBox(height: 20),
                            // AppTextField(
                            //   controller: controller.priceController,
                            //   hint: "Price".tr,
                            //   backgroundColor: AppColors.grayColor.withOpacity(0.4),
                            //   inputFormatters: [
                            //     FilteringTextInputFormatter.digitsOnly,
                            //   ],
                            //   label: "Price".tr,
                            // ),
                            // const SizedBox(height: 20),
                          ],
                        ) : const SizedBox.shrink(),
                        const SizedBox(height: 20),

                        GetBuilder<DashboardController>(
                          builder: (dController) {
                            return Column(
                              children: [
                                AppButton(
                                  title: "Update".tr,
                                  onTap: () {
                                    controller.updateProfile();
                                  },
                                  background: AppColors.accentColor,
                                  textColor: AppColors.lightTextColor,
                                  contentCenter: true,
                                  showArrowIcon: false,
                                  isLoading: dController.isProfileUpdateLoading.isTrue,
                                ),
                                const SizedBox(height: 20),
                                AppButton(
                                  title: "Delete Account".tr,
                                  onTap: () {
                                    Get.bottomSheet(
                                      Container(
                                        color: AppColors.lightScaffoldColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                        child: Column(
                                          children: [
                                            AppText(
                                              text: "Are you sure you want to delete your account?".tr,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              fontColor: AppColors.blackColor,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: AppButton(
                                                    title: "Cancel".tr,
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    background: AppColors.grayColor,
                                                    textColor: AppColors.lightTextColor,
                                                    contentCenter: true,
                                                    showArrowIcon: false,
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: AppButton(
                                                    title: "Delete".tr,
                                                    onTap: () {
                                                      controller.deleteAccount();
                                                    },
                                                    background: AppColors.errorColor,
                                                    textColor: AppColors.lightTextColor,
                                                    contentCenter: true,
                                                    showArrowIcon: false,
                                                    isLoading: dController.isDeleteAccountLoading.isTrue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  background: AppColors.errorColor,
                                  textColor: AppColors.lightTextColor,
                                  contentCenter: true,
                                  showArrowIcon: false,
                                  isLoading: dController.isDeleteAccountLoading.isTrue,
                                ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

}