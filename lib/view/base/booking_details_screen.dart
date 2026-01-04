import 'package:cached_network_image/cached_network_image.dart';
import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/routes/app_routes.dart'; // افترضنا وجود هذا المسار
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/utils/utlis.dart'; // افترضنا وجود دالة getStatusColor و convertTime24To12
import 'package:coach_life/view/widgets/app_text.dart'; // افترضنا وجود هذا الـ Widget
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  // 🧱 بناء بطاقة تفاصيل
  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.grayColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero, // لا نريد هوامش إضافية من الـ Card
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(text: title, fontSize: 16, fontWeight: FontWeight.w700),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  // 🧾 صف تفاصيل
  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText(
              text: label,
              fontColor: Colors.grey[700],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              // onTap: isLink ? () => Utils.openUrl(value) : null,
              child: Align(
                alignment: Alignment.centerRight,
                child: AppText(
                  text: value,
                  fontWeight: FontWeight.w600,
                  fontColor: valueColor ?? Colors.black87,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 زر الانضمام إلى المكالمة
  Widget _buildJoinButton(BookingController controller) {
    final booking = controller.selectedBooking.value;
    final status = booking?.status;
    final connectType = booking?.connectType;
    final normalizedStatus = status?.toLowerCase().trim() ?? '';
    final normalizedConnectStatus =
        booking?.connectStatus?.toLowerCase().trim() ?? '';
    const endedIndicators = <String>[
      'complete',
      'completed',
      'done',
      'finished',
      'ended',
      'cancel',
      'no_show',
      'noshow',
      'expired',
    ];
    final isEnded = endedIndicators.any(
      (indicator) =>
          normalizedStatus.contains(indicator) ||
          normalizedConnectStatus.contains(indicator),
    );

    if (isEnded) {
      return const SizedBox.shrink();
    }

    // يظهر الزر إذا كانت الحالة "مؤكدة" أو "قادمة" (Confirmed/Upcoming)
    if (normalizedStatus != 'confirmed' && normalizedStatus != 'upcoming') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        child: ElevatedButton.icon(
          icon: Icon(
            connectType == 'video' ? Icons.videocam : Icons.call,
            color: Colors.white,
          ),
          label: AppText(
            text:
                connectType == 'video'
                    ? "Join Video Call".tr
                    : "Join Audio Call".tr,
            fontSize: 18,
            fontColor: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          onPressed: () {
            // يفترض أن هذا المسار يؤدي إلى شاشة الإعدادات المسبقة ثم المكالمة
            // يجب أن يقوم الكنترولر بالتحقق من الوقت قبل الانتقال
            Get.toNamed(AppRoutes.preCallSetup);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            textStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // 🧑‍🏫 بطاقة تفاصيل المدرب الجديدة
  Widget _buildCoachCard(BookingController controller, context) {
    final coach = controller.selectedBooking.value!.coach;
    if (coach == null) return const SizedBox.shrink();

    // رابط الصورة الافتراضي أو الموجود
    final imageUrl =
        coach.media?.isNotEmpty == true
            ? coach.media!.first.originalUrl ?? ''
            : 'https://via.placeholder.com/100';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.grayColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 الصورة
            ClipRRect(
              borderRadius: BorderRadius.circular(12), // مربع بزوايا مستديرة
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 80,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                errorWidget:
                    (c, u, e) => Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            // 📝 التفاصيل
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: "Coach".tr,
                    fontSize: 14,
                    fontColor: Colors.grey[700],
                  ),
                  const SizedBox(height: 2),
                  // الاسم
                  AppText(
                    text: coach.name ?? "Unknown Coach".tr,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontColor: AppColors.primaryColor,
                  ),

                  const SizedBox(height: 8),
                  // السيرة الذاتية (Bio)
                  if (coach.bio != null && coach.bio!.isNotEmpty)
                    SizedBox(
                      child: Text(
                        coach.bio!,
                        style: const TextStyle(
                          fontStyle: FontStyle.normal,
                          fontFamily: "Cairo",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor.withOpacity(0.98),
      body: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'Cairo'),
        ),
        child: GetBuilder<BookingController>(
          builder: (controller) {
            final booking = controller.selectedBooking.value;

            if (booking == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: Column(
                children: [
                  // 🔙 العنوان مع زر العودة
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lightScaffoldColor,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: () => Get.back(),
                          ),
                        ),
                        const Spacer(),
                        AppText(
                          text: "Booking Details".tr,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        const Spacer(),
                        const SizedBox(
                          width: 48,
                        ), // مسافة للحفاظ على تمركز العنوان
                      ],
                    ),
                  ),

                  // زر الانضمام
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildJoinButton(controller),
                  ),

                  // تفاصيل الحجز الرئيسية
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // 🧑‍🏫 بطاقة المدرب الجديدة
                          _buildCoachCard(controller, context),
                          const SizedBox(height: 20),

                          // 📅 معلومات الجلسة (تاريخ + وقت + المدة + نوع الاتصال)
                          _buildDetailCard(
                            title: "Session Info".tr,
                            children: [
                              _detailRow("Date".tr, booking.date ?? "-"),
                              _detailRow(
                                "Time".tr,
                                Utils.convertTime24To12(booking.time ?? ""),
                              ),
                              if (booking.duration != null)
                                _detailRow(
                                  "Duration".tr,
                                  "${booking.duration} ${"min".tr}",
                                ),
                              _detailRow(
                                "Connect Type".tr,
                                booking.connectType?.capitalizeFirst ?? "-",
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 💳 معلومات الدفع
                          _buildDetailCard(
                            title: "Payment Info".tr,
                            children: [
                              _detailRow(
                                "Amount".tr,
                                "${booking.amount ?? '0'} ${booking.currency ?? ''}",
                                valueColor: AppColors.primaryColor,
                              ),
                              _detailRow(
                                "Payment Method".tr,
                                booking.paymentMethod?.capitalizeFirst ?? "-",
                              ),
                              _detailRow(
                                "Payment Status".tr,
                                booking.paymentStatus?.capitalizeFirst ?? "-",
                                valueColor:
                                    (booking.paymentStatus == 'paid' ||
                                            booking.paymentStatus ==
                                                'completed')
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 📊 حالة الحجز
                          _buildDetailCard(
                            title: "Booking Status".tr,
                            children: [
                              _detailRow(
                                "Status".tr,
                                booking.status?.capitalizeFirst ?? "-",
                                valueColor: Utils.getStatusColor(
                                  booking.status ?? "",
                                ),
                              ),
                              if (booking.connectUrl != null &&
                                  booking.connectUrl!.isNotEmpty)
                                _detailRow(
                                  "Meeting Link".tr,
                                  booking.connectUrl!,
                                  isLink: true,
                                ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
