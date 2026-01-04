import 'package:coach_life/controller/chat_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/empty_widget.dart';
import 'package:coach_life/view/widgets/rate_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/asstes/images_manager.dart';
import '../../widgets/app_text.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppText(
            text: "Chats".tr,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          const Divider(),
          Expanded(
            child: GetBuilder<DashboardController>(
              builder: (controller) {
                if (controller.isChatLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }else if(controller.conversations.isEmpty) {
                  return EmptyWidget(title: "No Chats".tr);
                }
                return ListView.builder(
                  itemCount: controller.conversations.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {

                        Get.find<ChatController>().initSocket(context, controller.conversations[index]);
                      },
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey
                        ),
                      ),
                      title: AppText(
                        text: controller.conversations[index].name!,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      subtitle: AppText(
                        text: controller.conversations[index].messages!.isNotEmpty ? controller.conversations[index].messages!.last.message! : "No messages".tr,
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
    );
  }
}