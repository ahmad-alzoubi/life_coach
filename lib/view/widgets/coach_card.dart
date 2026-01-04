import 'package:cached_network_image/cached_network_image.dart';
import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/model/coach.dart';
import 'package:coach_life/utils/dimensions/font_sizes.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class CoachCard extends StatelessWidget {
  final DashboardController controller;
  final Coach coach;

  const CoachCard({super.key, required this.coach, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Get.find<CoachController>().setSelectedCoach(coach);
          Get.toNamed(AppRoutes.coachDetailsScreen);
        },
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.lightScaffoldColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // صورة المدرب
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12), 
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        (coach.media != null && coach.media!.isNotEmpty)
                            ? coach.media!.first.originalUrl
                            : "https://www.thermaxglobal.com/wp-content/uploads/2020/05/image-not-found.jpg",
                    fit: BoxFit.cover,
                    height: 140,
                    width: double.infinity,
                    placeholder:
                        (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // اسم المدرب والسعر
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        text: Utils.displayName(coach.name ?? ""),
                        fontSize: FontSizes.mediumFontSize,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (coach.price != null)
                      AppText(
                        text: "\$${coach.price}",
                        fontSize: FontSizes.mediumFontSize,
                        fontWeight: FontWeight.bold,
                        fontColor: AppColors.primaryColor,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // تقييم المدرب والطلبات
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    AppText(
                      text:
                          "${coach.rating ?? 0} | ${coach.totalBookings ?? 0} ${"order".tr}",
                      fontSize: FontSizes.smallFontSize,
                      fontColor: AppColors.grayColor,
                    ),
                  ],
                ),
              ),

              // بايو المدرب
            ],
          ),
        ),
      ),
    );
  }
}
