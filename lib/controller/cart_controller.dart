import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/model/course.dart';
import 'package:coach_life/repositories/courses_repository.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/services/cart_manager.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class CartController extends GetxController {
  final RxList<Course> cartItems = <Course>[].obs;
  final CartManager _cartManager = CartManager();
  final RxDouble amount = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initCart();
  }

  void setIsLoading(bool value) {
    isLoading.value = value;
    update();
  }

  Future<void> initCart() async {
    final List<Course> items = await _cartManager.getCartItems();
    double totalAmount = 0;
    for (var element in items) {
      totalAmount += double.parse(element.price);
    }
    amount.value = totalAmount;
    cartItems.assignAll(items);
    update();
  }

  Future<void> addToCart(Course item) async {
    await _cartManager.addToCart(item);
    await initCart();
  }

  Future<void> removeFromCart(int itemId) async {
    await _cartManager.removeFromCart(itemId);
    await initCart();
  }

  Future<void> clearCart() async {
    await _cartManager.clearCart();
    await initCart();
  }

    void payWithTapy(BuildContext context) async {
    setIsLoading(true);
    String uuid = Utils.generateUuid();
    final mockPayload = Payment(
        amount: amount.value.toString(),
        currency: Currency.sar,
        buyer: Buyer(
          email: '',
          phone: Get.find<DashboardController>().user.value.phone ?? "",
          name: Get.find<DashboardController>().user.value.name ?? "",
          // dob: '2000-08-24',
        ),
        buyerHistory: BuyerHistory(
          loyaltyLevel: 1,
          registeredSince: DateTime.now().toIso8601String(),
          // wishlistCount: 0,
        ),
        shippingAddress: null,
        order: Order(
          referenceId: uuid, 
          items: [
          OrderItem(
            title: 'buy course',
            // description: '',
            quantity: 1,
            unitPrice: amount.value.toString(),
            // referenceId: uuid,
            // productUrl: "https://lifecoach.com.sa",
            category: 'buy course',
          )
        ]),
        orderHistory: [
          // OrderHistoryItem(
            // purchasedAt: DateTime.now().toIso8601String(),
            // amount: (Get.find<BookingController>().amount.value + Get.find<BookingController>().tax.value +  Get.find<BookingController>().timeAmount.value).toString(),
            // paymentMethod: OrderHistoryItemPaymentMethod.card,
            // status: OrderHistoryItemStatus.newOne,
          // )
        ],
      );

      final session = await TabbySDK().createSession(TabbyCheckoutPayload(
        merchantCode: 'Life coachsau', // pay attention, this might be different for different merchants
        lang: Get.locale!.languageCode == 'ar' ? Lang.ar : Lang.en,
        payment: mockPayload,
      ));

      print(session);

      TabbyWebView.showWebView(
      context: context,
      webUrl: session.availableProducts.installments?.webUrl ?? '',
      onResult: (WebViewResult resultCode) {
        print("Result code: ${resultCode.name}");
        if(resultCode.name == "authorized") {
          Get.back();
          MessagesManager.showSuccessMessage('Payment successful'.tr);
          // apply the buyer's order
          buyCourse();
        } else if(resultCode.name == "canceled" || resultCode.name == "close") {
          Get.back();
          MessagesManager.showErrorMessage('You aborted the payment. Please retry or choose another payment method.'.tr);
        } else if(resultCode.name == "rejected") {
          Get.back();
          MessagesManager.showErrorMessage('Sorry, Tabby is unable to approve this purchase. Please use an alternative payment method for your order'.tr);
        }
        else{
          Get.back();
          MessagesManager.showErrorMessage('Payment failed'.tr);
        }
        // TODO: Process resultCode
      },
    );
    setIsLoading(false);
  }

    void initialisePayment() async {
    setIsLoading(true);
      Utils.logEvent("add_payment_info", {
        "amount": amount.value,
        "currency": "SAR",
        "value": "0",
        "payment_type": "credit_card",
      });
      FacebookAppEvents().logEvent(name: "add_payment_info", parameters: {
        "amount": amount.value,
        "value": "0",
        "payment_type": "credit_card",
      });
      await Utils.initializePayWithCardSdk(amount.value, "life_coach@lifecoach.com.sa", Get.find<DashboardController>().user.value.phone ?? "", false, product: "buy_course");

    setIsLoading(false);
  }

  Future<void> buyCourse() async {
    setIsLoading(true);
    List<Course> courses = await _cartManager.getCartItems();
    final response = await CoursesRepository().buyCourses(courses);
    if (response.statusCode == 200) {
      await clearCart();
      // MessagesManager.showSuccessMessage('Courses purchased successfully'.tr);
    } else {
      MessagesManager.showErrorMessage('Failed to purchase courses'.tr);
    }
    Get.find<DashboardController>().getCourses();
    Get.toNamed(AppRoutes.dashboardScreen);
    Get.find<DashboardController>().changeIndex(1);
    setIsLoading(false);
  }
}
