import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Profile".tr),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: GetBuilder<DashboardController>(
        builder: (controller) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryColor,
                      ),
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
                          child:
                              controller.isUpdateProfileLoading.isTrue
                                  ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(),
                                  )
                                  : const Icon(
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
                AppTextField(
                  label: "Name".tr,
                  controller: controller.nameController,
                  hint: "Name".tr,
                  backgroundColor: AppColors.grayColor.withOpacity(0.4),
                ),
                SizedBox(
                  height: controller.user.value.type == "coach" ? 0 : 15,
                ),
                controller.user.value.type == "coach"
                    ? Column(
                      children: [
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: controller.bioController,
                          hint: "Bio".tr,
                          backgroundColor: AppColors.grayColor.withOpacity(0.4),
                          label: "Bio".tr,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: controller.priceController,
                          hint: "Price".tr,
                          backgroundColor: AppColors.grayColor.withOpacity(0.4),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          label: "Price".tr,
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                    : const SizedBox.shrink(),
                GetBuilder<DashboardController>(
                  builder: (dController) {
                    return AppButton(
                      title: "Update".tr,
                      onTap: () {
                        controller.updateProfile();
                        Get.offAllNamed(AppRoutes.dashboardScreen);
                      },
                      background: AppColors.accentColor,
                      textColor: AppColors.lightTextColor,
                      contentCenter: true,
                      showArrowIcon: false,
                      isLoading: dController.isProfileUpdateLoading.isTrue,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
