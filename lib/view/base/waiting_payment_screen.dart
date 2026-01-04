import 'dart:async';
import 'dart:convert';

import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/model/booking.dart';
import 'package:coach_life/repositories/booking_repository.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaitingPaymentScreen extends StatefulWidget {
  const WaitingPaymentScreen({Key? key}) : super(key: key);

  @override
  State<WaitingPaymentScreen> createState() => _WaitingPaymentScreenState();
}

class _WaitingPaymentScreenState extends State<WaitingPaymentScreen> {
  Timer? _timer;
  int _remaining = 30;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startCountdownAndPolling();
  }

  void _startCountdownAndPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      setState(() {
        _remaining = (_remaining - 1).clamp(0, 30);
      });

      // Poll every 2 seconds
      if (_remaining > 0 && _remaining % 2 == 0) {
        await _checkPaymentStatus();
      }

      if (_remaining <= 0) {
        _finishWithFailure();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final bookingController = Get.find<BookingController>();
      final paymentId = bookingController.bookingRequest.value.paymentId;
      if (paymentId == null || paymentId.isEmpty) {
        return;
      }

      final response = await BookingRepository().getBookings();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final bookings = Booking.listFromJson(data);

        Booking? matched;
        for (final b in bookings) {
          if (b.paymentId == paymentId) {
            matched = b;
            break;
          }
        }

        if (matched != null) {
          final status = (matched.paymentStatus ?? '').toLowerCase();
          // Treat authorized/authorised/success/succeeded/paid as success
          const successStatuses = {
            'authorized',
            'authorised',
            'success',
            'succeeded',
            'paid',
          };
          const failureStatuses = {
            'failed',
            'cancelled',
            'declined',
            'error',
          };
          if (successStatuses.contains(status)) {
            _timer?.cancel();
            bookingController.successBooking(matched);
            return;
          }
          if (failureStatuses.contains(status)) {
            _timer?.cancel();
            MessagesManager.showErrorMessage('Payment not completed'.tr);
            Get.offAllNamed(AppRoutes.dashboardScreen);
            return;
          }
        }
      }
    } catch (_) {
      // Ignore errors during polling
    } finally {
      _isChecking = false;
    }
  }

  void _finishWithFailure() {
    _timer?.cancel();
    if (!mounted) return;
    MessagesManager.showErrorMessage('Payment not completed'.tr);
    Get.offAllNamed(AppRoutes.dashboardScreen);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_remaining / 30).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text: 'Waiting for Payment'.tr,
          textAlign: TextAlign.center,
          mainAxisAlignment: MainAxisAlignment.center,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        actions: const [
          SizedBox(width: 0, height: 0,)
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppText(
              text: 'Your payment is being processed. Please wait...'.tr,
              textAlign: TextAlign.center,
              mainAxisAlignment: MainAxisAlignment.center,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    strokeWidth: 7,
                  ),
                ),
                Positioned.fill(
                  child: AppText(
                    text: '$_remaining ${'s'.tr}',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    mainAxisAlignment: MainAxisAlignment.center,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}