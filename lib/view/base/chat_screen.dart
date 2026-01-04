import 'package:cached_network_image/cached_network_image.dart';
import 'package:coach_life/controller/chat_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app_text.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: GetBuilder<ChatController>(
        builder: (controller) {
          return SizedBox(
            height: context.screenHeight,
            child: Column(
              children: [
                Container(
                  color: AppColors.secondaryColor,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controller.socket.disconnect();
                                      Get.back();
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_ios_new_sharp,
                                      color: AppColors.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: CachedNetworkImageProvider(
                                      Get.find<DashboardController>()
                                                  .user
                                                  .value
                                                  .type ==
                                              "user"
                                          ? (controller
                                                      .currentConversetion
                                                      .value
                                                      .coach
                                                      ?.media
                                                      ?.isNotEmpty ==
                                                  true
                                              ? controller
                                                  .currentConversetion
                                                  .value
                                                  .coach!
                                                  .media!
                                                  .first
                                                  .originalUrl
                                              : "https://app.lifecoach.com.sa/storage/user.png")
                                          : (controller
                                                      .currentConversetion
                                                      .value
                                                      .user
                                                      ?.media
                                                      ?.isNotEmpty ==
                                                  true
                                              ? controller
                                                  .currentConversetion
                                                  .value
                                                  .user!
                                                  .media!
                                                  .first
                                                  .originalUrl
                                              : "https://app.lifecoach.com.sa/storage/user.png"),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppText(
                                    text:
                                        controller
                                                    .currentConversetion
                                                    .value
                                                    .name !=
                                                null
                                            ? (Get.find<DashboardController>()
                                                        .user
                                                        .value
                                                        .type ==
                                                    "user"
                                                ? controller
                                                        .currentConversetion
                                                        .value
                                                        .coach!
                                                        .name ??
                                                    controller
                                                        .currentConversetion
                                                        .value
                                                        .name ??
                                                    ""
                                                : controller
                                                        .currentConversetion
                                                        .value
                                                        .user!
                                                        .name ??
                                                    controller
                                                        .currentConversetion
                                                        .value
                                                        .name ??
                                                    "")
                                            : "",
                                    fontWeight: FontWeight.w600,
                                    fontColor: AppColors.lightTextColor,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                            ),
                            color: AppColors.lightScaffoldColor,
                          ),
                          child: ListView.builder(
                            controller: controller.scrollController,
                            itemCount: controller.chatMessages.length,
                            itemBuilder: (context, index) {
                              return controller.chatMessages[index];
                            },
                          ),
                        ),
                      ),
                      Divider(color: AppColors.secondaryColor),
                      Container(
                        color: AppColors.lightScaffoldColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 16,
                                  ),
                                  child:
                                      controller.isRecording.isFalse
                                          ? AppTextField(
                                            controller:
                                                controller.textController,
                                            isDense: true,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  163,
                                                  244,
                                                  244,
                                                  244,
                                                ),
                                            padding: EdgeInsets.zero,
                                            // textColor: AppColors.lightTextColor,
                                            fieldPadding: const EdgeInsets.all(
                                              0,
                                            ),
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                controller.setShowRecording(
                                                  false,
                                                );
                                              } else {
                                                controller.setShowRecording(
                                                  true,
                                                );
                                              }
                                            },
                                            border: Border.all(
                                              color: AppColors.grayColor
                                                  .withOpacity(0.5),
                                              width: 0.5,
                                            ),
                                            borderRadius: 8,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 8,
                                            ),
                                            isEnabled:
                                                controller.isSending.isFalse,
                                          )
                                          : AppText(
                                            text: _formatDuration(
                                              Duration(
                                                seconds:
                                                    controller
                                                        .recordingDuration,
                                              ),
                                            ),
                                            // text: "${DateTime.fromMillisecondsSinceEpoch(controller.recordingDuration * 1000).minute}:${DateTime.fromMillisecondsSinceEpoch(controller.recordingDuration * 1000).second}",
                                            fontColor: AppColors.blackColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                ),
                              ),
                              controller.showRecording.isFalse
                                  ? GestureDetector(
                                    onTap: () {
                                      controller.sendMessage();
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      // padding: const EdgeInsets.all(16),
                                      child:
                                          controller.isSending.isFalse
                                              ? const Icon(
                                                Icons.send,
                                                color: Colors.white,
                                                size: 15,
                                              )
                                              : const CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                    ),
                                  )
                                  : const SizedBox(),
                              controller.showRecording.isTrue
                                  ? GestureDetector(
                                    onTap: () {
                                      if (controller.isRecording.isTrue) {
                                        controller.stopRecording();
                                      } else {
                                        controller.startRecording();
                                      }
                                    },
                                    child: Obx(
                                      () => Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              controller.isRecording.isTrue
                                                  ? Colors.red
                                                  : AppColors.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        // padding: const EdgeInsets.all(16),
                                        child:
                                            controller.isSending.isTrue
                                                ? const CircularProgressIndicator()
                                                : controller.isRecording.isTrue
                                                ? const Icon(
                                                  Icons.stop,
                                                  color: Colors.white,
                                                  size: 20,
                                                )
                                                : const Icon(
                                                  Icons.mic,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                      ),
                                    ),
                                  )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
