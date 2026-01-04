import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'record_message.dart';

class ChatMessageWidget extends StatelessWidget {
  ChatMessageWidget({
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.isRead,
    this.isSender = false,
    required this.type,
    this.recordUrl,
    super.key,
  });

  final String conversationId;
  final String senderId;
  final String message;
  final bool isRead;
  bool isSender = false;
  final String type;
  String? recordUrl;

  @override
  Widget build(BuildContext context) {
    isSender = senderId == Get.find<DashboardController>().user.value.id;
    return Row(
      mainAxisAlignment: isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double maxWidth = Get.width * 0.7; // Calculate 70% of the maximum width available
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: !isSender ? const Radius.circular(0) : const Radius.circular(15),
                  bottomRight: !isSender ? const Radius.circular(15) : const Radius.circular(0),
                ),
                color: isSender ? null : AppColors.grayColor.withOpacity(0.6),
                gradient: isSender
                    ? LinearGradient(
                        colors: [
                          AppColors.secondaryColor,
                          AppColors.primaryColor,
                        ],
                      )
                    : null,
              ),
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth, // Enforcing the maximum width calculated
                  ),
                  child: type == 'text'
                      ? Text(
                          message,
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSender ? AppColors.lightTextColor : AppColors.blackColor,
                          ),
                          maxLines: 30,
                        )
                      : recordUrl != null
                          ? RecordMessage(
                              url: recordUrl!,
                              isSentByMe: isSender,
                              width: maxWidth,
                            )
                          : Text(
                              'Unsupported message type',
                              style: TextStyle(
                                fontFamily: "Cairo",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightTextColor,
                              ),
                            ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
