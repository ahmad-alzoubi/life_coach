import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentStatusPage extends StatelessWidget {
  final String message;
  final bool success;

  const PaymentStatusPage(this.message, this.success, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  success
                      ? "assets/images/payment-success.gif"
                      : "assets/images/payment-failed.gif",
                  width: Get.width / 2,
                  height: Get.width / 2,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(style: const TextStyle(), message.tr),
                const SizedBox(height: 20),
                // Button(
                //   text: "ok".tr,
                //   onPressed: () {
                //     Get.back();
                //   },
                // ),
              ],
            )),
      ),
    );
  }
}
