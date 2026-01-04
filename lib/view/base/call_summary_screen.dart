import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallSummaryScreen extends StatelessWidget {
  const CallSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        Get.arguments is Map<String, dynamic>
            ? Get.arguments as Map<String, dynamic>
            : null;

    final String title =
        (args?['title'] as String?) ?? 'call_summary_generic_title'.tr;
    final String message =
        (args?['message'] as String?) ?? 'call_summary_generic_message'.tr;

    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.secondaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.headset_mic,
                  color: Colors.white,
                  size: 54,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGreyColor,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.dashboardScreen);
                  },
                  child: Text(
                    'call_summary_primary_action'.tr,
                    style: TextStyle(
                      color: AppColors.lightTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.notificationsScreen);
                },
                child: Text(
                  'notifications'.tr,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
