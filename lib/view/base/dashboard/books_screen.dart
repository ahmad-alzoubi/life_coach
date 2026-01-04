import 'package:coach_life/controller/cart_controller.dart' show CartController;
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;

    return SafeArea(
      child: GetBuilder<DashboardController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              // يمكنك إضافة منطق تحديث الكورسات هنا
            },
            color: AppColors.secondaryColor,
            strokeWidth: 2,
            child: Column(
              children: [
                // رأس الصفحة (شريط العنوان)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: "Courses".tr,
                        fontSize: 24, // زيادة حجم العنوان
                        fontWeight: FontWeight.w900, // خط سميك جداً
                        fontColor: AppColors.darkScaffoldColor,
                      ),
                      if (controller.config.value.blockUsersPhone == null ||
                          !(controller.config.value.blockUsersPhone!.contains(
                            controller.user.value.phone,
                          )))
                        GetX<CartController>(
                          init: Get.find<CartController>(),
                          builder: (cartCtrl) {
                            final int cartCount = cartCtrl.cartItems.length;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  onPressed:
                                      () => Get.toNamed(AppRoutes.cartScreen),
                                  icon: Icon(
                                    Icons.shopping_cart_outlined,
                                    color: AppColors.primaryColor,
                                    size: 26,
                                  ),
                                ),
                                if (cartCount > 0)
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        cartCount.toString(),
                                        style: TextStyle(
                                          color: AppColors.lightTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // قائمة الكورسات
                Expanded(
                  child: Container(
                    width: screenWidth,
                    // إزالة الخلفية الرمادية للحصول على مظهر أكثر بساطة ونظافة
                    // color: AppColors.grayColor.withOpacity(0.15),
                    decoration: BoxDecoration(
                      color: AppColors.lightScaffoldColor, // خلفية نظيفة
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      itemCount: controller.courses.length,
                      itemBuilder: (context, index) {
                        final course = controller.courses[index];
                        final isPurchased = course.isPurchased ?? false;

                        return InkWell(
                          onTap: () {
                            controller.setSelectedCourse(course);
                            Get.toNamed(AppRoutes.courssDetailsScreen);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: 10,
                            ),
                            padding: const EdgeInsets.all(
                              0,
                            ), // إزالة البادينج الداخلي
                            decoration: BoxDecoration(
                              color:
                                  isPurchased
                                      ? AppColors.primaryColor.withOpacity(
                                        0.05,
                                      ) // تمييز الكورسات المشتراة بلون خفيف
                                      : AppColors.lightScaffoldColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.grayColor.withOpacity(
                                    0.1,
                                  ), // ظل أخف وأنظف
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // --- 1. صورة الكورس (بزاوية حادة) ---
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    course.image,
                                    height: 120, // زيادة ارتفاع الصورة قليلاً
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // --- 2. تفاصيل الكورس ---
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // العنوان
                                        AppText(
                                          text: course.title,
                                          fontSize: 18, // حجم أكبر
                                          fontWeight: FontWeight.w800, // خط قوي
                                          fontColor:
                                              AppColors.darkScaffoldColor,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),

                                        // اسم المدرب (بخط خفيف)
                                        AppText(
                                          text: course.coachDetails.name ?? "",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontColor: Colors.grey.shade600,
                                        ),
                                        const SizedBox(height: 10),

                                        // --- السعر/حالة الشراء (القسم الأسفل) ---
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // السعر
                                            AppText(
                                              text:
                                                  isPurchased
                                                      ? "Purchased"
                                                          .tr // نص مختصر للمشتراة
                                                      : course.price,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontColor:
                                                  isPurchased
                                                      ? AppColors
                                                          .secondaryColor // لون مختلف للمشتراة
                                                      : AppColors.primaryColor,
                                              isPrice:
                                                  !isPurchased, // تطبيق تنسيق العملة فقط إذا لم يكن تم الشراء
                                            ),

                                            // أيقونة للتوجه (سهم)
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: AppColors.grayColor
                                                  .withOpacity(0.5),
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ), // مسافة على اليمين لليستو
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
