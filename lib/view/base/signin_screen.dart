import 'package:coach_life/controller/auth_controller.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return Column(
            children: [
              SizedBox(height: context.screenHeight * 0.15),
              AppText(
                text: "enter phone number".tr,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
                mainAxisAlignment: MainAxisAlignment.center,
                fontColor: AppColors.primaryColor,
              ),
              SizedBox(height: context.screenHeight * 0.05),
              
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grayColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          onSelect: (Country country) => controller.setCountry(country),
                          countryListTheme: CountryListThemeData(
                            flagSize: 25,
                            textStyle: TextStyle(
                              color: AppColors.blackColor.withOpacity(0.6),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            )
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "country or region".tr,
                                fontSize: 16,
                                fontColor: AppColors.blackColor.withOpacity(0.6),
                                mainAxisAlignment: MainAxisAlignment.start,
                              ),
                              Row(
                                children: [
                                  AppText(
                                    text: controller.country.flagEmoji,
                                    fontSize: 25,
                                  ),
                                  const SizedBox(width: 10),
                                  AppText(
                                    text: controller.country.name.tr,
                                    fontSize: 16,
                                  )
                                ],
                              )
                            ],
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_outlined,
                          )
                        ],
                      ),
                    ),
                    Divider(
                      color: AppColors.lightTextColor,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "phone number".tr,
                              hintStyle: TextStyle(
                                color: AppColors.blackColor.withOpacity(0.6),
                                fontFamily: "Cairo"
                              ),
                              border: InputBorder.none,
                              // counter: null,
                              counterText: "",
                            ),
                            maxLength: 12 - controller.country.phoneCode.length,
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppText(
                          text: "${controller.country.phoneCode}+",
                          fontSize: 16,
                          fontColor: AppColors.blackColor.withOpacity(0.6),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // show hint for accepting terms and conditions and privacy policy when user clicks on the continue button
              SizedBox(
                width: context.screenWidth * 0.9,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppText(
                        text: "by continuing you agree to our".tr,
                        fontSize: 14,
                        fontColor: AppColors.blackColor.withOpacity(0.6),
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async{
                                      await launchUrl(Uri.parse("https://lifecoach.com.sa/terms-conditions.html"));
                                    },
                            child: AppText(
                              text: "terms_and_conditions".tr,
                              fontSize: 14,
                              fontColor: AppColors.primaryColor,
                            ),
                          ),
                          AppText(
                            text: " & ".tr,
                            fontSize: 14,
                            fontColor: AppColors.blackColor.withOpacity(0.6),
                          ),
                          InkWell(
                            onTap: () async{
                                      await launchUrl(Uri.parse("https://lifecoach.com.sa/privacy-policy.html"));
                                    },
                            child: AppText(
                              text: "privacy_policy".tr,
                              fontSize: 14,
                              fontColor: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                title: "continue".tr,
                onTap: () {
                  Get.bottomSheet(
                    GetBuilder<AuthController>(
                      builder: (authController) {
                        if(authController.isLoading.isTrue) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Container(
                          height: context.screenHeight * 0.55,
                          
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: AppColors.lightScaffoldColor,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.grayColor.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: AppText(
                                      text: "verify way".tr,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              AppText(
                                text: "We will send you a verification code to this number".tr,
                                fontSize: 16,
                                textAlign: TextAlign.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                fullWidth: true,
                              ),
                              const SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  controller.verifyPhoneNumber(false);
                                  // Get.toNamed(AppRoutes.enterOtpScreen);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: AppColors.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                  child: Row(children: [
                                    Icon(
                                      Icons.message_outlined,
                                      color: AppColors.primaryColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "Send via sms".tr,
                                          fontSize: 15,
                                          fontColor: AppColors.primaryColor,
                                        ),
                                        AppText(
                                          text: "Check your sms messages".tr,
                                          fontSize: 12,
                                          fontColor: AppColors.blackColor.withOpacity(0.6),
                                        )
                                      ],
                                    )
                                  ],),
                                ),
                              ),
                              // const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  controller.verifyPhoneNumber(true);
                                  // Get.toNamed(AppRoutes.enterOtpScreen);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: AppColors.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                  child: Row(children: [
                                    Image.asset(
                                      "assets/images/whatsapp.png",
                                      width: 25,
                                      height: 25,
                                      color: AppColors.primaryColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "Send via whatsapp".tr,
                                          fontSize: 15,
                                          fontColor: AppColors.primaryColor,
                                        ),
                                        AppText(
                                          text: "Check your whatsapp messages".tr,
                                          fontSize: 12,
                                          fontColor: AppColors.blackColor.withOpacity(0.6),
                                        )
                                      ],
                                    )
                                  ],),
                                ),
                              ),
                              // AppButton(
                              //   title: "Send via whatsapp".tr,
                              //   onTap: () {
                              //     controller.verifyPhoneNumber(true);
                              //     // Get.toNamed(AppRoutes.enterOtpScreen);
                              //   },
                              //   background: AppColors.accentColor,
                              //   textColor: AppColors.darkGreyColor,
                              //   contentCenter: true,
                              //   showArrowIcon: false,
                              //   isLoading: false,
                              //   border: Border.all(
                              //     color: AppColors.successColor,
                              //     width: 2,
                              //   ),
                              //   isTransparent: true,
                              // ),
                              const SizedBox(height: 10),
                              AppButton(
                                title: "Change Number".tr,
                                onTap: () {
                                  Get.back();
                                },
                                background: AppColors.errorColor,
                                contentCenter: true,
                                showArrowIcon: false,
                              )
                            ],
                          ),
                        );
                      }
                    )
                  );
                },
                background: AppColors.accentColor,
                textColor: AppColors.lightTextColor,
                contentCenter: true,
                showArrowIcon: false,
                isLoading: controller.isLoading.value,
              ),
              // AppTextButton(
              //   title: "don't have an account? create account".tr,
              //   onTap: () {
              //     Get.toNamed(AppRoutes.registerScreen);
              //   },
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   fontSize: 16,
              // ),
              const SizedBox(height: 40),
            ],
          );
        }
      ),
    );
  }
}