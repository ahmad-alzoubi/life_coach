import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:coach_life/view/widgets/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/dimensions/screen_dimensions.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
                  text: "Wallet".tr,
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
                  if(controller.isWalletLoading.isTrue) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(controller.wallet.value == null) {
                    return EmptyWidget(title: "No Wallet Found".tr);
                  }
                  return Column(
                    children: [
                      Container(
                        width: context.screenWidth,
                        height: context.screenHeight * 0.13,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(ScreenDimensions.defaultBorderRadius),
                          color: AppColors.primaryColor,
                        ),
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(
                              text: "Balance".tr,
                              fontColor: AppColors.lightTextColor,
                              fontSize: 16,
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                            AppText(
                              text: controller.wallet.value!.balance.toString() + " ",
                              fontColor: AppColors.lightTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              mainAxisAlignment: MainAxisAlignment.center,
                              isPrice: true,
                            ),
                          ],
                        )
                      )
                    ],
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