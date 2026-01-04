import 'package:coach_life/controller/cart_controller.dart';
import 'package:coach_life/utils/asstes/images_manager.dart';
import 'package:coach_life/utils/dimensions/media_query_values.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'.tr),
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
      ),
      body: GetBuilder<CartController>(
        initState: (state) => Get.find<CartController>().initCart(),
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05, vertical: 10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.lightScaffoldColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grayColor.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: Offset(0, 0)
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.grayColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Image.network(
                                  controller.cartItems[index].image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: controller.cartItems[index].title,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontColor: AppColors.blackColor
                                    ),
                                    SizedBox(height: 5,),
                                    AppText(
                                      text: "السعر: ${controller.cartItems[index].price} ",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontColor: AppColors.grayColor,
                                      isPrice: true,
                                    ),
                                    SizedBox(height: 5,),
                                    AppText(
                                      text: controller.cartItems[index].coachDetails.name ?? "",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontColor: AppColors.grayColor
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await controller.removeFromCart(
                                    int.parse(controller.cartItems[index].id),
                                  );
                                  MessagesManager.showSuccessMessage(
                                    "Course removed from cart".tr,
                                  );
                                },
                                icon: Icon(Icons.delete),
                                color: AppColors.errorColor,
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.grayColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grayColor.withOpacity(0.3))
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: "Service Fee".tr,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        AppText(
                          text: "${controller.amount.value} ",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          isPrice: true,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: "Tax".tr,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        AppText(
                          text: "${controller.tax.value} ",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          isPrice: true,
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: "Total".tr,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        AppText(
                          text: "${controller.amount.value + controller.tax.value} ",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          isPrice: true,
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    AppButton(
                      title: 'Checkout'.tr,
                      onTap: () async {
                        Get.bottomSheet(
                          // will pay with card or wallet
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightScaffoldColor,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.grayColor.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 50,
                                  offset: const Offset(0, 3), // changes position of shadow
                                ),
                              ]
                            ),
                            height: Get.height * 0.65,
                            // color: AppColors.lightScaffoldColor,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: AppText(
                                    text: "Select Payment Method".tr,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                ),
                                const Divider(),
                                SizedBox(
                                  height: Get.height * 0.45,
                                  width: Get.width,
                                  child: ListView(
                                    scrollDirection: Axis.vertical,
                                    children: [
                                      SizedBox(
                                        width: Get.width * 0.3,
                                        child: AppButton(
                                          onTap: () {
                                            Get.back();
                                            controller.initialisePayment();
                                          },
                                          title: "Pay with Card".tr,
                                          background: AppColors.secondaryColor,
                                          showArrowIcon: false,
                                          contentCenter: true,

                                          // isLoading: bookController.isLoading.value,
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      // TabbyPresentationSnippet(
                                      //   price: controller.amount.value.toString(),
                                      //   currency: Currency.sar,
                                      //   lang: Get.locale!.languageCode == 'ar' ? Lang.ar : Lang.en,
                                      // ),
                                      // const SizedBox(height: 10,),
                                      // SizedBox(
                                      //   width: Get.width * 0.3,
                                      //   child: AppButton(
                                      //     onTap: () {
                                      //       Get.back();
                                      //       controller.payWithTapy(context);
                                      //     },
                                      //     title: "Pay in 4. No interest, no fees".tr,
                                      //     background: const Color(0xFF39FFBF),
                                      //     showArrowIcon: false,
                                      //     contentCenter: true,
                                      //     textColor: AppColors.blackColor,
                                      //     icon: Image.asset(
                                      //       ImagesManager.tabbyIcon,
                                      //       width: 20,
                                      //       height: 20,
                                      //     ),
                                      //     // isLoading: bookController.isLoading.value,
                                      //   ),
                                      // ),
                                      // SizedBox( height: 10,),

                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        );
                      },
                      background: Colors.green,
                      isGradient: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondaryColor,
                          AppColors.primaryColor
                        ],
                        transform: GradientRotation(0.2)
                      ),
                      showArrowIcon: false,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,)
            ],
          );
        },
      )
    );
  }
}
