import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:coach_life/view/widgets/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                  text: "Notifications".tr,
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
                  if (controller.isNotificationLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }else if(controller.notifications.isEmpty) {
                    return EmptyWidget(title: "No Notifications".tr);
                  }
                  return ListView.builder(
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey
                          ),
                        ),
                        title: AppText(
                          text: controller.notifications[index].title!,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: AppText(
                          text: controller.notifications[index].message!.substring(0, 20),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.primaryColor,
                        ),
                      );
                    },
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