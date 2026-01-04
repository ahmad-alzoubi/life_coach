import 'package:coach_life/controller/auth_controller.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/dimensions/font_sizes.dart';
import '../../../utils/dimensions/screen_dimensions.dart';
import '../../widgets/app_text.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //image, name, phone, bio, price
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: context.screenHeight * 0.1),
                AppText(
                  text: "SignUp".tr,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  fontColor: AppColors.primaryColor,
                ),
                SizedBox(height: context.screenHeight * 0.03),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: (controller.image.value.path == "") ? Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryColor,
                      ) : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          controller.image.value,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
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
                          child: const Icon(
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
                  controller: controller.nameController,
                  hint: "Name".tr,
                  backgroundColor: AppColors.grayColor.withOpacity(0.4),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.grayColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(ScreenDimensions.buttonBorderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            // AppText(
                            //     text: controller.country.flagEmoji,
                            //     fontSize: 25,
                            //   ),
                              AppText(
                                text: "+${controller.country.phoneCode}",
                                fontSize: 16,
                                fontColor: AppColors.blackColor.withOpacity(0.6),
                              ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppTextField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            hint: "Phone".tr,
                            // decoration: InputDecoration(
                            //   hintText: "Phone".tr,
                            //   hintStyle: TextStyle(
                            //     color: AppColors.blackColor.withOpacity(0.6),
                            //     fontFamily: "Cairo",
                            //     fontSize: FontSizes.defaultFontSize
                            //   ),
                            //   border: InputBorder.none,
                            // ),
                            //input accept only numbers
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            // maxInputDigits: 9,
                            padding: EdgeInsets.zero,
                            fieldPadding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: controller.bioController,
                  hint: "Bio".tr,
                  backgroundColor: AppColors.grayColor.withOpacity(0.4),
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
                ),
                const SizedBox(height: 20),
                AppButton(
                  title: "Register".tr,
                  onTap: () {
                    controller.register();
                  },
                  background: AppColors.accentColor,
                  textColor: AppColors.lightTextColor,
                  contentCenter: true,
                  showArrowIcon: false,
                  isLoading: controller.isRegisterLoading.isTrue,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}