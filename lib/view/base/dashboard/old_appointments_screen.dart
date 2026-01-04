// lib/view/old_appointments_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/model/booking.dart';
import 'package:coach_life/model/coach.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/base/pre_call_screen.dart';
import 'package:coach_life/view/widgets/empty_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../widgets/app_text.dart';

class OldAppointmentsScreen extends StatelessWidget {
  const OldAppointmentsScreen({super.key});

  bool _isConnectable(
    String? connectType,
    String? status, {
    String? connectStatus,
  }) {
    if (connectType == null) return false;
    final lowerType = connectType.toLowerCase();
    final lowerStatus = status?.toLowerCase() ?? '';
    final lowerConnectStatus = connectStatus?.toLowerCase() ?? '';
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
    final hasEnded = endedIndicators.any(
      (indicator) =>
          lowerStatus.contains(indicator) ||
          lowerConnectStatus.contains(indicator),
    );
    if (hasEnded) return false;
    return lowerType == 'audio' || lowerType == 'video';
  }

  Color _statusColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('cancel')) return Colors.red.shade600;
    if (s.contains('complete') || s.contains('completed') || s.contains('done'))
      return Colors.green.shade600;
    if (s.contains('pending') || s.contains('pending_payment'))
      return Colors.orange.shade600;
    return Colors.grey.shade600;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMd(Get.locale?.languageCode ?? 'en').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatAmount(String? amount, String? currency) {
    if (amount == null || amount.isEmpty) return '-';
    final a = double.tryParse(amount) ?? 0.0;
    final c = (currency?.toUpperCase() ?? 'SAR');
    return '${a.toStringAsFixed(a.truncateToDouble() == a ? 0 : 2)} $c';
  }

  String? _extractCoachImageUrl(Coach? coach) {
    try {
      if (coach == null) return null;
      final medias = coach.media;
      if (medias == null || medias.isEmpty) return null;
      final m = medias.firstWhere(
        (x) => x.originalUrl.trim().isNotEmpty,
        orElse: () => medias.first,
      );
      return m.originalUrl;
    } catch (_) {
      return null;
    }
  }

  Widget _fallbackAvatar(String name, double size, BuildContext context) {
    final initials =
        (name.trim().isNotEmpty)
            ? name
                .trim()
                .split(' ')
                .map((s) => s.isNotEmpty ? s[0] : '')
                .take(2)
                .join()
                .toUpperCase()
            : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.36,
          ),
        ),
      ),
    );
  }

  Widget _leadingAvatar(Booking appt, double size, BuildContext context) {
    final coach = appt.coach;
    final name = coach?.name ?? appt.user?.name ?? '';
    final url = _extractCoachImageUrl(coach);
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _fallbackAvatar(name, size, context),
      );
    }
    return _fallbackAvatar(name, size, context);
  }

  TextStyle _cairoTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Cairo',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  Widget _ratingStars(double? rating) {
    final r = (rating ?? 0.0).clamp(0.0, 5.0);
    final full = r.floor();
    final half = (r - full) >= 0.5;
    final empty = 5 - full - (half ? 1 : 0);
    final stars = <Widget>[];
    for (var i = 0; i < full; i++)
      stars.add(const Icon(Icons.star, size: 14, color: Colors.amber));
    if (half)
      stars.add(const Icon(Icons.star_half, size: 14, color: Colors.amber));
    for (var i = 0; i < empty; i++)
      stars.add(const Icon(Icons.star_border, size: 14, color: Colors.amber));
    return Row(children: stars);
  }

  // --- Logic for navigation updated here ---
  void _navigateToNextScreen(
    Booking appt,
    BookingController bookingCtrl,
    bool isConnectable,
  ) {
    bookingCtrl.setSelectedBooking(appt);
    if (isConnectable) {
      // Determine the next route based on connection type
      final connectType = appt.connectType?.toLowerCase() ?? 'audio';
      if (connectType == 'video') {
        // *** Navigate to Pre-Call Setup Screen for Video Calls ***
        Get.to(
          () => PreCallSetupScreen(connectType: appt.connectType ?? 'audio'),
        );
      } else if (connectType == 'audio') {
        // Directly initialize and go to Call Screen for Audio Calls

        Get.to(
          () => PreCallSetupScreen(connectType: appt.connectType ?? 'audio'),
        );
      }
      return;
    }
    // For non-connectable appointments (or cancelled/completed)
    Get.toNamed(AppRoutes.bookingDetails);
  }

  @override
  Widget build(BuildContext context) {
    final bookingCtrl = Get.find<BookingController>();

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: AppText(
                    text: "Old Appointments".tr,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    try {
                      Get.find<DashboardController>().fetchAppointments();
                      Get.snackbar(
                        'appointments_refresh_title'.tr,
                        'appointments_refresh_message'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    } catch (e) {
                      if (kDebugMode) print('refresh error: $e');
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          GetBuilder<DashboardController>(
            builder: (controller) {
              if (controller.isAppointmentsLoading.value) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final appointments = controller.appointments;
              if (appointments.isEmpty) {
                return Expanded(
                  child: EmptyWidget(title: "No Appointments".tr),
                );
              }

              return Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    final isConnectable = _isConnectable(
                      appt.connectType,
                      appt.status,
                      connectStatus: appt.connectStatus,
                    );
                    final titleText =
                        controller.user.value.type == "user"
                            ? (appt.coach?.name == null ||
                                    appt.coach!.name == "null"
                                ? "No name".tr
                                : appt.coach!.name!)
                            : (appt.user?.name == null ||
                                    appt.user!.name == "null"
                                ? "No name".tr
                                : appt.user!.name!);

                    final subTime = Utils.convertTime24To12(appt.time ?? '');
                    final dateText = _formatDate(appt.date);
                    final durationText =
                        (appt.duration != null && appt.duration!.isNotEmpty)
                            ? '${appt.duration} ${'min'.tr}'
                            : '-';
                    final amountText = _formatAmount(
                      appt.amount,
                      appt.currency,
                    );
                    return Material(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      elevation: 2,
                      child: InkWell(
                        onTap:
                            () => _navigateToNextScreen(
                              appt,
                              bookingCtrl,
                              isConnectable,
                            ),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final availableWidth = constraints.maxWidth;
                              double imageSide;
                              if (availableWidth.isFinite &&
                                  availableWidth > 0) {
                                imageSide = (availableWidth * 0.4).clamp(
                                  64.0,
                                  availableWidth,
                                );
                                if (imageSide > 150.0) {
                                  imageSide = 150.0;
                                }
                              } else {
                                imageSide = 120.0;
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: imageSide,
                                    height: imageSide,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _leadingAvatar(
                                        appt,
                                        imageSide,
                                        context,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // name + rating + status chip
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                titleText,
                                                style: _cairoTextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (appt.coach?.rating != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: _ratingStars(
                                                  appt.coach!.rating,
                                                ),
                                              ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _statusColor(
                                                  appt.status,
                                                ).withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                (appt.status ?? '').isNotEmpty
                                                    ? appt.status!.toUpperCase()
                                                    : '—',
                                                style: _cairoTextStyle(
                                                  color: _statusColor(
                                                    appt.status,
                                                  ),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // date/time row
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              dateText,
                                              style: _cairoTextStyle(
                                                color: Colors.black87,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              subTime,
                                              style: _cairoTextStyle(
                                                color: Colors.black87,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // meta row: duration and amount and type
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 8,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.06),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.timer,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    durationText,
                                                    style: _cairoTextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.06),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.payments,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    amountText,
                                                    style: _cairoTextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(
                                                  0.06,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    appt.connectType
                                                                ?.toLowerCase() ==
                                                            'video'
                                                        ? Icons.videocam
                                                        : Icons.call,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    (appt.connectType ?? '-')
                                                        .toUpperCase(),
                                                    style: _cairoTextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // actions (Join / Details)
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 8,
                                          children: [
                                            if (isConnectable)
                                              ElevatedButton(
                                                onPressed:
                                                    () => _navigateToNextScreen(
                                                      appt,
                                                      bookingCtrl,
                                                      isConnectable,
                                                    ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      appt.connectType
                                                                  ?.toLowerCase() ==
                                                              'video'
                                                          ? const Color.fromARGB(
                                                            255,
                                                            81,
                                                            25,
                                                            210,
                                                          )
                                                          : Colors
                                                              .green
                                                              .shade700,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 10,
                                                      ),
                                                  textStyle: _cairoTextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      appt.connectType
                                                                  ?.toLowerCase() ==
                                                              'video'
                                                          ? Icons.videocam
                                                          : Icons.call,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'appointments_join_button'
                                                          .tr,
                                                      style: _cairoTextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              OutlinedButton(
                                                onPressed:
                                                    () => _navigateToNextScreen(
                                                      appt,
                                                      bookingCtrl,
                                                      isConnectable,
                                                    ),
                                                style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10,
                                                      ),
                                                  textStyle: _cairoTextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.info_outline,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'appointments_view_details'
                                                          .tr,
                                                      style: _cairoTextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
