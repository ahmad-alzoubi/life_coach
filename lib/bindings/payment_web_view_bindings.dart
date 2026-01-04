import 'package:get/get.dart';

import '../controller/payment_web_view_controller.dart';

class PaymentWebViewBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentWebViewController>(
      () => PaymentWebViewController(),
    );
  }
}
