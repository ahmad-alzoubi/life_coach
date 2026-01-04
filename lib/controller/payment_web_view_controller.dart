import 'dart:convert';
import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/cart_controller.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_clickpay_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_clickpay_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_clickpay_bridge/PaymentSdkLocale.dart';
import 'package:flutter_clickpay_bridge/flutter_clickpay_bridge.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../view/base/payment_status_page.dart';

class PaymentWebViewController extends GetxController {

  RxBool isLoading = false.obs;

  late WebViewController webController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {
          Logger().d("WTF -- >  onPageStarted $url");
        },
        onPageFinished: (String url) {
          Logger().d("WTF -- >  onPageFinished $url");
          readResponse();
        },
        onWebResourceError: (WebResourceError error) {
          Logger().d("WTF -- >  onWebResourceError $error");
        },
        onNavigationRequest: (NavigationRequest request) {
          Logger().d("WTF -- >  onNavigationRequest $request");
          if (request.url.startsWith(data['url'] ?? "")) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..addJavaScriptChannel("messageHandler",
        onMessageReceived: (JavaScriptMessage message) {
      var jsonData = jsonDecode(message.message);
      Logger().d("WTF -- >  $jsonData");
      if (jsonData['status'] == 'CANCELLED') {
      } else if (jsonData['status'] == 'SUCCESS') {}
    })
    ..loadRequest(Uri.parse(data['url'] ?? ""));
  dynamic data = Get.arguments;

  var billingDetails = BillingDetails("billing name", "billing email",
      "billing phone", "address line", "country", "city", "state", "zip code");

  var shippingDetails = ShippingDetails("shipping name", "shipping email",
      "shipping phone", "address line", "country", "city", "state", "zip code");

  readResponse() async {
    try {
      final response = await webController
          .runJavaScriptReturningResult("document.documentElement.innerHTML");
      Logger().d(response);

      if (response.toString().contains("Transaction successful") || response.toString().contains("معاملة ناجحة")) {
        // Get.back();
        // await Get.to(const PaymentStatusPage("Transaction successful", true));
        if (response.toString().contains("Transaction successful") || response.toString().contains("معاملة ناجحة")) {
          String product = Get.arguments['product'];
          isLoading.value = true;
          update();
          if(product == "booking") {
            await Get.find<BookingController>().book("success", "paymentId", "onlinePaymentCard");
            Utils.logEvent("purchase", {});
          }else if(product == "buy_course") {
            await Get.find<CartController>().buyCourse();
            Utils.logEvent("purchase", {});
          }
          isLoading.value = false;
          update();
        }
      }
      //
      // final json = GetPlatform.isAndroid
      //     ? jsonDecode(jsonDecode(response))
      //     : jsonDecode(response);
      // Logger().d(json);
      // bool? success = json['success'];
      // String message = json['message'] ?? "";
      // if (success != null) {
      //   Get.back();
      //   await Get.to(PaymentStatusPage(message, success));
      //   if (success) {
      //     final data = (json['data'] ?? {});
      //     //var id = (data['reservationDetails'] ?? {})['id'] ?? "-1";
      //     var id = data['reservationDetails'] != null
      //         ? data['reservationDetails']['id']
      //         : data['id'] ?? "-1";
      //     Get.offAllNamed(AppRoutes.home);
      //     Get.toNamed(AppRoutes.bookingDetails, arguments: {
      //       "id": id,
      //     });
      //   }
      // }
    } catch (ex) {
      Logger().d("readResponse Error  => $ex");
    }
  }

  void initializePaymentSdk() async {
    try {
      var configuration = PaymentSdkConfigurationDetails(
          profileId: "45032",
          serverKey: "S9JNMB6GH6-JJJMKTTZDG-WBWMLDJNWJ",
          clientKey: "CNKMTN-92KG66-6NK779-TH6P69",
          cartId: "life-coach-123",
          cartDescription: "Description of the items/services",
          merchantName: "Life Coach",
          screentTitle: "debit-card".tr,
          billingDetails: billingDetails,
          shippingDetails: shippingDetails,
          locale: PaymentSdkLocale.AR,
          amount: 10.0,
          currencyCode: "SAR",
          showBillingInfo: false,
          showShippingInfo: false,
          merchantCountryCode: "SA");
      FlutterPaymentSdkBridge.startCardPayment(configuration, (event) {
        if (event["status"] == "success") {
          // Handle transaction details here.
          var transactionDetails = event["data"];
          print(transactionDetails);
        } else if (event["status"] == "error") {
          // Handle error here.
        } else if (event["status"] == "event") {
          // Handle events here.
        }
      });
    } catch (e) {
      Logger().d("intializePaymentSdk Error  => $e");
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    print("data $data");
  }
}
