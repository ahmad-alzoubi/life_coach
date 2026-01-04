import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../controller/payment_web_view_controller.dart';
import '../../utils/theme/app_colors.dart';

class PaymentWebView extends StatelessWidget {
  const PaymentWebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PaymentWebViewController paymentWebViewController =
        Get.put(PaymentWebViewController());
    return WillPopScope(
      onWillPop: () async {
        // return await
        // showDialog(context: context, builder: (context) => AlertDialog(
        //   title: Text("Are you sure?".tr),
        //   content: Text("Do you want to cancel the payment?".tr),
        //   actions: [
        //     TextButton(onPressed: () async {
        //       await paymentWebViewController.deleteReservation().then((value) {
        //         Get.back();
        //         Get.back();
        //       });
        //     }, child: Text("yes".tr)),
        //     TextButton(onPressed: () {
        //       Get.back();
        //     }, child: Text("no".tr)),
        //   ],
        // ));
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.grey[200],
          body: SafeArea(
              child: Stack(
                children: [
                  WebViewWidget(
                    controller: paymentWebViewController.webController,
                      // initialUrl: paymentWebViewController.data['url'] ?? "",
                      // javascriptMode: JavascriptMode.unrestricted,
                      // debuggingEnabled: true,
                      // onPageFinished: (_) {
                      //   Logger().d("WTF -- >  onPageFinished $_");
                      //       paymentWebViewController.readResponse();
                      // },
                      // javascriptChannels: {
                      //       JavascriptChannel(
                      //           name: 'messageHandler',
                      //           onMessageReceived: (JavascriptMessage message) {
                      //             var jsonData = jsonDecode(message.message);
                      //             Logger().d("WTF -- >  $jsonData");
                      //             if (jsonData['status'] == 'CANCELLED') {
                      //             } else if (jsonData['status'] == 'SUCCESS') {}
                      //           })
                      // },
                      // onWebViewCreated: (WebViewController webViewController) {
                      //       paymentWebViewController.webController = webViewController;
                      // }
                  ),
                  Positioned(
                    top: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      height: 50,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                showDialog(context: context, builder: (context) => AlertDialog(
                                  title: Text("Are you sure?".tr),
                                  content: Text("Do you want to cancel the payment?".tr),
                                  actions: [
                                    TextButton(onPressed: () async {
                                      //await paymentWebViewController.deleteReservation().then((value) {
                                        Get.back();
                                        Get.back();
                                     // });
                                    }, child: Text("yes".tr)),
                                    TextButton(onPressed: () {
                                      Get.back();
                                    }, child: Text("no".tr)),
                                  ],
                                ));
                              },
                              icon: const Icon(Icons.arrow_back, color: Colors.white,)),
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
