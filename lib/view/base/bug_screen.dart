import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BugWidget extends StatelessWidget {
  String error;
  BugWidget({Key? key, required this.error}) : super(key: key);
  final String email = 'support@lifecoach.com.sa';
  final String subject = 'Bug Report';
  final String body = 'Please describe the bug here:';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bug_report,
                color: AppColors.primaryColor,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Something went wrong'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please contact us to solve the problem as soon as possible'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _sendEmail(),
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 16),
              AppButton(
                title: "Contact support".tr,
                onTap: () => _sendEmail(),
                background: AppColors.primaryColor,
                showArrowIcon: false,
                contentCenter: true,
                fontSize: 20,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': '$body\n\n$error',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint('Could not launch $emailUri');
    }
  }
}