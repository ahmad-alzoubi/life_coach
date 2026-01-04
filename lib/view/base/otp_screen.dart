import 'dart:async';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../controller/auth_controller.dart';
import '../../utils/theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? _timer;
  int _start = 60;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _isTimerActive = true;
    _start = 60;
    _timer?.cancel(); // Cancel any existing timer
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_start == 0) {
        setState(() {
          _isTimerActive = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _showResendOptionsBottomSheet(AuthController controller) {
    Get.bottomSheet(
      GetBuilder<AuthController>(
        builder: (authController) {
          if (authController.isLoading.isTrue) {
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
                  onTap: () async {
                    if (controller.isLoading.isTrue) {
                      return;
                    }
                    try {
                      bool? status = await controller.verifyPhoneNumber(false, withNavigate: false);
                      if (status == true) {
                        Get.back();
                        _startTimer();
                      }
                    } catch (e) {
                      // Handle error gracefully
                      print('Error sending SMS: $e');
                    }
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
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Row(
                      children: [
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
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (controller.isLoading.isTrue) {
                      return;
                    }
                    try {
                      bool? status = await controller.verifyPhoneNumber(true, withNavigate: false);
                      if (status == true) {
                        Get.back();
                        _startTimer();
                      }
                    } catch (e) {
                      // Handle error gracefully
                      print('Error sending WhatsApp: $e');
                    }
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
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Row(
                      children: [
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AppButton(
                  title: "Change Number".tr,
                  onTap: () {
                    Get.offAllNamed(AppRoutes.loginScreen);
                  },
                  background: AppColors.errorColor,
                  contentCenter: true,
                  showArrowIcon: false,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: context.screenHeight * 0.15),
                  AppText(
                    text: "enter otp".tr,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    fontColor: AppColors.primaryColor,
                  ),
                  SizedBox(height: context.screenHeight * 0.05),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 4,
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 50,
                        textStyle: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grayColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.accentColor,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        controller.otpController.text = value;
                        controller.update();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isTimerActive
                      ? AppText(
                          text: "${"Resend code in".tr} $_start ${"seconds".tr}",
                          fontSize: 14,
                          fontColor: AppColors.blackColor.withOpacity(0.6),
                          mainAxisAlignment: MainAxisAlignment.center,
                        )
                      : TextButton(
                          onPressed: () {
                            _showResendOptionsBottomSheet(controller);
                          },
                          child: AppText(
                            text: "Resend OTP".tr,
                            fontSize: 14,
                            fontColor: AppColors.primaryColor,
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ),
                  const Spacer(),
                  AppButton(
                    title: "continue".tr,
                    onTap: () {
                      controller.verifyOtp();
                    },
                    background: AppColors.accentColor,
                    textColor: AppColors.lightTextColor,
                    contentCenter: true,
                    showArrowIcon: false,
                    // isLoading: controller.isLoading.value,
                    
                  ),
                  const SizedBox(height: 40),
                ],
              ),
              Obx(() {
                if(controller.isLoading.isTrue) {
                  return Container(
                    width: context.screenWidth,
                    height: context.screenHeight,
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightScaffoldColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: CircularProgressIndicator()),
                    ),
                  );
                }
                return const SizedBox();
              }),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}