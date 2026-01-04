import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/model/schedule.dart';
import 'package:coach_life/utils/asstes/images_manager.dart';
import 'package:coach_life/utils/dimensions/font_sizes.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/app_button.dart';
import 'package:coach_life/view/widgets/app_text.dart';
import 'package:coach_life/view/widgets/card_selection_button.dart';
import 'package:coach_life/view/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

import '../../controller/coach_controller.dart';

class SessionBookingScreen extends StatelessWidget {
  const SessionBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: SafeArea(
        child: GetBuilder<BookingController>(
          builder: (bookingController) {
            return GetBuilder<CoachController>(
              builder: (controller) {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                print(bookingController.selectedCoach.value.id);
                return Stack(
                  children: [
                    Column(
                      children: [
                        AppText(
                          text: "Booking Session".tr,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        const Divider(),
                        AppText(
                          text:
                              "Select the type of connection you want to make with the coach"
                                  .tr,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          mainAxisAlignment: MainAxisAlignment.center,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bookingController
                                          .selectedCoach
                                          .value
                                          .coachAttributes
                                          ?.enableChat ==
                                      true
                                  ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: CardSelectionButton(
                                      text: "Chat".tr,
                                      onTap: () {
                                        bookingController
                                            .setSelectedConnectionType(
                                              'chat',
                                              controller.duration.value,
                                            );
                                      },
                                      isSelected:
                                          bookingController
                                              .selectedConnectionType
                                              .value ==
                                          "chat",
                                    ),
                                  )
                                  : Container(),
                              const SizedBox(height: 8),
                              bookingController
                                          .selectedCoach
                                          .value
                                          .coachAttributes
                                          ?.enableAudio ==
                                      true
                                  ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: CardSelectionButton(
                                      text: "Voice Call".tr,
                                      onTap: () {
                                        bookingController
                                            .setSelectedConnectionType(
                                              'audio',
                                              controller.duration.value,
                                            );
                                      },
                                      isSelected:
                                          bookingController
                                              .selectedConnectionType
                                              .value ==
                                          "audio",
                                    ),
                                  )
                                  : Container(),
                              const SizedBox(height: 8),
                              bookingController
                                          .selectedCoach
                                          .value
                                          .coachAttributes
                                          ?.enableVideo ==
                                      true
                                  ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: CardSelectionButton(
                                      text: "Video Call".tr,
                                      onTap: () {
                                        bookingController
                                            .setSelectedConnectionType(
                                              'video',
                                              controller.duration.value,
                                            );
                                      },
                                      isSelected:
                                          bookingController
                                              .selectedConnectionType
                                              .value ==
                                          "video",
                                    ),
                                  )
                                  : Container(),
                            ],
                          ),
                        ),
                        const Divider(),
                        AppText(
                          text: "Select session duration".tr,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          mainAxisAlignment: MainAxisAlignment.center,
                          fullWidth: true,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color:
                                    controller.duration.value == 30
                                        ? AppColors.secondaryColor
                                        : Colors.transparent,
                                border: Border.all(
                                  color: AppColors.grayColor.withOpacity(0.5),
                                ),
                              ),
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              child: InkWell(
                                onTap: () {
                                  controller.setDuration(30);
                                  bookingController.setSelectedSlot(null);
                                },
                                child: AppText(
                                  text: "30 min".tr,
                                  fontSize: FontSizes.largeFontSize,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  fontColor:
                                      controller.duration.value == 30
                                          ? AppColors.lightTextColor
                                          : AppColors.blackColor,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color:
                                    controller.duration.value == 60
                                        ? AppColors.secondaryColor
                                        : Colors.transparent,
                                border: Border.all(
                                  color: AppColors.grayColor.withOpacity(0.5),
                                ),
                              ),
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              child: InkWell(
                                onTap: () {
                                  // if(!Get.isRegistered<CoachController>()) {
                                  //   Get.lazyPut(() => CoachController());
                                  // }
                                  controller.setDuration(60);
                                  bookingController.setSelectedSlot(null);
                                },
                                child: AppText(
                                  text: "60 min".tr,
                                  fontSize: FontSizes.largeFontSize,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  fontColor:
                                      controller.duration.value == 60
                                          ? AppColors.lightTextColor
                                          : AppColors.blackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        AppText(
                          text: "Select Time".tr,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          mainAxisAlignment: MainAxisAlignment.center,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap:
                              controller.isSlotsLoading.isFalse
                                  ? () {
                                    Get.bottomSheet(
                                      bookingController
                                                      .selectedSchedule
                                                      .value
                                                      .slots !=
                                                  null &&
                                              bookingController
                                                  .selectedSchedule
                                                  .value
                                                  .slots!
                                                  .isNotEmpty
                                          ? SizedBox(
                                            height: Get.height * 0.6,
                                            child: ListView.builder(
                                              itemCount:
                                                  bookingController
                                                              .selectedSchedule
                                                              .value
                                                              .slots !=
                                                          null
                                                      ? bookingController
                                                          .selectedSchedule
                                                          .value
                                                          .slots!
                                                          .length
                                                      : 0,
                                              itemBuilder: (context, index) {
                                                final slot =
                                                    bookingController
                                                                .selectedSchedule
                                                                .value
                                                                .slots !=
                                                            null
                                                        ? bookingController
                                                            .selectedSchedule
                                                            .value
                                                            .slots![index]
                                                        : null;
                                                if (slot == null) {
                                                  return const SizedBox();
                                                }
                                                return InkWell(
                                                  onTap: () {
                                                    if (slot.booked == false) {
                                                      bookingController
                                                          .setSelectedSlot(
                                                            slot,
                                                          );
                                                      Get.back();
                                                    }
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(8),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          bookingController
                                                                      .selectedSlot
                                                                      .value ==
                                                                  slot
                                                              ? AppColors
                                                                  .secondaryColor
                                                              : slot.booked ==
                                                                  true
                                                              ? AppColors
                                                                  .grayColor
                                                                  .withOpacity(
                                                                    0.5,
                                                                  )
                                                              : Colors
                                                                  .transparent,
                                                      border: Border.all(
                                                        color: AppColors
                                                            .grayColor
                                                            .withOpacity(0.5),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        AppText(
                                                          text:
                                                              Utils.convertTime24To12(
                                                                slot.time
                                                                    .toString(),
                                                                removeSeconds:
                                                                    true,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize:
                                                              FontSizes
                                                                  .largeFontSize,
                                                          fontColor:
                                                              bookingController
                                                                          .selectedSlot
                                                                          .value ==
                                                                      slot
                                                                  ? AppColors
                                                                      .lightTextColor
                                                                  : slot.booked ==
                                                                      false
                                                                  ? AppColors
                                                                      .blackColor
                                                                  : AppColors
                                                                      .blackColor,
                                                        ),
                                                        AppText(
                                                          text: Utils.convertTime24To12(
                                                            Utils.addMinutesToTime(
                                                              slot.time
                                                                  .toString(),
                                                              controller
                                                                  .duration
                                                                  .value,
                                                            ),
                                                            removeSeconds: true,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize:
                                                              FontSizes
                                                                  .largeFontSize,
                                                          fontColor:
                                                              bookingController
                                                                          .selectedSlot
                                                                          .value ==
                                                                      slot
                                                                  ? AppColors
                                                                      .lightTextColor
                                                                  : slot.booked ==
                                                                      false
                                                                  ? AppColors
                                                                      .blackColor
                                                                  : AppColors
                                                                      .blackColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                          : SizedBox(
                                            height: Get.height * 0.6,
                                            child: Center(
                                              child: Empty(
                                                text: "No times available".tr,
                                              ),
                                            ),
                                          ),
                                      backgroundColor:
                                          AppColors.lightScaffoldColor,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                      ),
                                    );
                                  }
                                  : null,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.grayColor.withOpacity(0.1),
                              border: Border.all(
                                color: AppColors.grayColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                controller.isSlotsLoading.isTrue
                                    ? AppText(
                                      text: "Slots Is Loading....".tr,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    )
                                    : AppText(
                                      text:
                                          bookingController
                                                      .selectedSlot
                                                      .value
                                                      .time ==
                                                  null
                                              ? "Select Time".tr
                                              : "${DateFormat('hh:mm').format(DateTime.parse('${bookingController.selectedSchedule.value.date} ${bookingController.selectedSlot.value.time}'))} ${DateFormat('a').format(DateTime.parse('${bookingController.selectedSchedule.value.date} ${bookingController.selectedSlot.value.time}')).toUpperCase() == 'AM' ? 'AM'.tr : 'PM'.tr} - ${DateFormat('hh:mm').format(DateTime.parse('${bookingController.selectedSchedule.value.date} ${bookingController.selectedSlot.value.time}').add(Duration(minutes: controller.duration.value)))} ${DateFormat('a').format(DateTime.parse('${bookingController.selectedSchedule.value.date} ${bookingController.selectedSlot.value.time}').add(Duration(minutes: controller.duration.value))).toUpperCase() == 'AM' ? 'AM'.tr : 'PM'.tr}",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  size: 20,
                                  color: AppColors.blackColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: -1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightScaffoldColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grayColor.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 50,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            (Get.find<DashboardController>()
                                                .config
                                                .value
                                                .blockUsersPhone ??
                                            [])
                                        .isNotEmpty &&
                                    (Get.find<DashboardController>()
                                                .config
                                                .value
                                                .blockUsersPhone ??
                                            [])
                                        .contains(
                                          Get.find<DashboardController>()
                                              .user
                                              .value
                                              .phone,
                                        )
                                ? const SizedBox()
                                : AppText(
                                  text: "You Will Pay".tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                            (Get.find<DashboardController>()
                                                .config
                                                .value
                                                .blockUsersPhone ??
                                            [])
                                        .isNotEmpty &&
                                    (Get.find<DashboardController>()
                                                .config
                                                .value
                                                .blockUsersPhone ??
                                            [])
                                        .contains(
                                          Get.find<DashboardController>()
                                              .user
                                              .value
                                              .phone,
                                        )
                                ? const SizedBox()
                                : Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.grayColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.grayColor.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppText(
                                            text: "Service Fee".tr,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          AppText(
                                            text:
                                                "${Get.find<BookingController>().amount.value + Get.find<BookingController>().timeAmount.value} ",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            isPrice: true,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AppText(
                                            text: "Includes tax".tr,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          // AppText(
                                          //   text: "Tax".tr,
                                          //   fontSize: 16,
                                          //   fontWeight: FontWeight.w400,
                                          // ),
                                          // AppText(
                                          //   text: "${Get.find<BookingController>().tax.value} ${"SAR".tr}",
                                          //   fontSize: 16,
                                          //   fontWeight: FontWeight.w400,
                                          // )
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppText(
                                            text: "Total".tr,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          AppText(
                                            text:
                                                "${Get.find<BookingController>().amount.value + Get.find<BookingController>().tax.value + Get.find<BookingController>().timeAmount.value} ",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            isPrice: true,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            // TabbyPresentationSnippet(
                            //   price: (Get.find<BookingController>().amount.value + Get.find<BookingController>().tax.value +  Get.find<BookingController>().timeAmount.value).toString(),
                            //   currency: Currency.sar,
                            //   lang: Get.locale!.languageCode == 'ar' ? Lang.ar : Lang.en,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: GetBuilder<BookingController>(
                                    builder: (bookController) {
                                      if ((Get.find<DashboardController>()
                                                      .config
                                                      .value
                                                      .blockUsersPhone ??
                                                  [])
                                              .isNotEmpty &&
                                          (Get.find<DashboardController>()
                                                      .config
                                                      .value
                                                      .blockUsersPhone ??
                                                  [])
                                              .contains(
                                                Get.find<DashboardController>()
                                                    .user
                                                    .value
                                                    .phone,
                                              )) {
                                        return AppButton(
                                          onTap:
                                              bookingController
                                                              .selectedConnectionType
                                                              .value !=
                                                          "" &&
                                                      controller
                                                              .duration
                                                              .value !=
                                                          0 &&
                                                      bookingController
                                                              .selectedSlot
                                                              .value !=
                                                          Slot()
                                                  ? () {
                                                    bookController.book(
                                                      "success",
                                                      "paymentId",
                                                      "appleAccount",
                                                    );
                                                  }
                                                  : () {
                                                    MessagesManager.showErrorMessage(
                                                      "Please Select All Failds"
                                                          .tr,
                                                    );
                                                  },
                                          title: "Book now".tr,
                                          background: AppColors.primaryColor,
                                          showArrowIcon: false,
                                          contentCenter: true,
                                          isLoading:
                                              bookController.isLoading.value,
                                        );
                                      }
                                      if (bookController.isLoading.value) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return AppButton(
                                        onTap:
                                            bookingController
                                                            .selectedConnectionType
                                                            .value !=
                                                        "" &&
                                                    controller.duration.value !=
                                                        0 &&
                                                    bookingController
                                                            .selectedSlot
                                                            .value !=
                                                        Slot()
                                                ? () async {
                                                  // bookController.book();
                                                  if (bookController
                                                          .selectedSlot
                                                          .value
                                                          .booked ==
                                                      null) {
                                                    MessagesManager.showErrorMessage(
                                                      'Please select time'.tr,
                                                    );
                                                    return;
                                                  }
                                                  Get.bottomSheet(
                                                    // will pay with card or wallet
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors
                                                                .lightScaffoldColor,
                                                        borderRadius:
                                                            const BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    15,
                                                                  ),
                                                              topRight:
                                                                  Radius.circular(
                                                                    15,
                                                                  ),
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: AppColors
                                                                .grayColor
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                            spreadRadius: 5,
                                                            blurRadius: 50,
                                                            offset: const Offset(
                                                              0,
                                                              3,
                                                            ), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      height: Get.height * 0.65,
                                                      // color: AppColors.lightScaffoldColor,
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 8.0,
                                                                ),
                                                            child: AppText(
                                                              text:
                                                                  "Select Payment Method"
                                                                      .tr,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                            ),
                                                          ),
                                                          const Divider(),
                                                          SizedBox(
                                                            height:
                                                                Get.height *
                                                                0.45,
                                                            width: Get.width,
                                                            child: ListView(
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              children: [
                                                                AppButton(
                                                                  onTap: () {
                                                                    Get.back();
                                                                    bookController
                                                                        .initialisePayment();
                                                                  },
                                                                  title:
                                                                      "Pay with Card"
                                                                          .tr,
                                                                  background:
                                                                      AppColors
                                                                          .secondaryColor,
                                                                  showArrowIcon:
                                                                      false,
                                                                  contentCenter:
                                                                      true,

                                                                  // isLoading: bookController.isLoading.value,
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                GetBuilder<
                                                                  DashboardController
                                                                >(
                                                                  builder: (
                                                                    controller,
                                                                  ) {
                                                                    return AppButton(
                                                                      onTap: () async {
                                                                        // Get.back();
                                                                        // Get.toNamed(AppRoutes.walletScreen);
                                                                        await controller
                                                                            .getWallet();
                                                                        if (controller.wallet.value !=
                                                                                null &&
                                                                            double.parse(
                                                                                  controller.wallet.value!.balance,
                                                                                ) ==
                                                                                0) {
                                                                          MessagesManager.showErrorMessage(
                                                                            'You do not have enough balance in your wallet'.tr,
                                                                          );
                                                                          return;
                                                                        } else {
                                                                          Get.back();
                                                                          bookController
                                                                              .payWithWallet();
                                                                        }
                                                                      },
                                                                      title:
                                                                          "Pay with Wallet"
                                                                              .tr,
                                                                      background:
                                                                          AppColors
                                                                              .secondaryColor,
                                                                      showArrowIcon:
                                                                          false,
                                                                      contentCenter:
                                                                          true,
                                                                      isLoading:
                                                                          controller
                                                                              .isWalletLoading
                                                                              .value,
                                                                    );
                                                                  },
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                // const SizedBox(height: 10,),
                                                                Get.find<
                                                                              DashboardController
                                                                            >()
                                                                            .config
                                                                            .value
                                                                            .tabbyEnabled ==
                                                                        true
                                                                    ? SizedBox(
                                                                      width:
                                                                          Get.width *
                                                                          0.3,
                                                                      child: AppButton(
                                                                        onTap: () {
                                                                          Get.back();
                                                                          bookController.payWithTapy(
                                                                            context,
                                                                          );
                                                                        },
                                                                        title:
                                                                            "Pay in 4. No interest, no fees".tr,
                                                                        background:
                                                                            const Color(
                                                                              0xFF39FFBF,
                                                                            ),
                                                                        showArrowIcon:
                                                                            false,
                                                                        contentCenter:
                                                                            true,
                                                                        textColor:
                                                                            AppColors.blackColor,
                                                                        icon: Image.asset(
                                                                          ImagesManager
                                                                              .tabbyIcon,
                                                                          width:
                                                                              20,
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        // isLoading: bookController.isLoading.value,
                                                                      ),
                                                                    )
                                                                    : const SizedBox.shrink(),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                                : () {
                                                  MessagesManager.showErrorMessage(
                                                    "Please Select All Failds"
                                                        .tr,
                                                  );
                                                },
                                        title: "Pay Now".tr,
                                        background: AppColors.secondaryColor,
                                        showArrowIcon: false,
                                        contentCenter: true,
                                        // isLoading: bookController.isLoading.value,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DottedArrowPainter extends CustomPainter {
  DottedArrowPainter({this.color = Colors.black});

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    const double gap = 4;
    const double dashLength = 4;
    double startX = 0;

    while (startX < size.width) {
      path.moveTo(startX, size.height / 2);
      path.lineTo(startX + dashLength, size.height / 2);
      startX += dashLength + gap;
    }

    canvas.drawPath(path, paint);

    // Draw arrow head
    final arrowHeadPath =
        Path()
          ..moveTo(size.width, size.height / 2)
          ..lineTo(size.width - 6, size.height / 2 - 6)
          ..moveTo(size.width, size.height / 2)
          ..lineTo(size.width - 6, size.height / 2 + 6);

    canvas.drawPath(arrowHeadPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
