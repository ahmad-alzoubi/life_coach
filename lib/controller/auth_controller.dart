import 'dart:convert';
import 'dart:io';

import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/model/register.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  Country country = Country(
    phoneCode: "966",
    name: "Saudi Arabia",
    e164Key: "SA",
    e164Sc: 966,
    displayName: "Saudi Arabia (العربية السعوديه)",
    displayNameNoCountryCode: "Saudi Arabia",
    level: 1,
    example: "055 123 4567",
    countryCode: "SA",
    geographic: true,
  );
  
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final Rx<File> image = File("").obs;
  final RxBool isLoading = false.obs;
  final RxBool isRegisterLoading = false.obs;
  final RxBool isNewUser = false.obs;
  final RxString phone = "".obs;

  void setCountry(Country country) {
    this.country = country;
    update();
  }

  void setIsRegisterLoading(bool value) {
    isRegisterLoading.value = value;
    update();
  }

  void setIsLoading(bool value) {
    isLoading.value = value;
    update();
  }

  void selectImageFromGallery() async {
    final imageFile = await Utils.pickImageFromGallery();
    image.value = imageFile;
    update();
  }

  Future<bool?> verifyPhoneNumber(bool isWhatsapp, {bool withNavigate = true}) async {
    setIsLoading(true);
    try {
      if (withNavigate && phoneController.text.isEmpty) {
        MessagesManager.showErrorMessage("Please enter a valid phone number".tr);
        setIsLoading(false);
        return false;
      }

      final phoneNumber = withNavigate ? "${country.phoneCode}${phoneController.text}" : phone.value;
      final response = await AuthRepository().login(
        phoneNumber,
        otpStatus: 0,
        isWhatsapp: isWhatsapp,
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == 'success') {
        if (withNavigate) {
          phone.value = phoneNumber;
          Get.toNamed(AppRoutes.enterOtpScreen);
        }
        setIsLoading(false);
        return true;
      } else {
        final errorMessage = body['message'] ?? "An unknown error occurred";
        MessagesManager.showErrorMessage(errorMessage.tr);
        setIsLoading(false);
        return false;
      }
    } catch (e) {
      if (kDebugMode) print(e);
      MessagesManager.showErrorMessage("An error occurred. Please try again.".tr);
      setIsLoading(false);
      return false;
    }
  }

  void verifyOtp() async {
    setIsLoading(true);
    try {
      final response = await AuthRepository().login(
        phone.value,
        otpStatus: 1,
        otp: otpController.text,
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == 'success') {
        await SharedPreferencesManager.instance!.setBool(Utils.usedLoggedInKey, true);
        await SharedPreferencesManager.instance!.setString(Utils.accessTokenKey, body['data']['token']);
        await SharedPreferencesManager.instance!.setString(Utils.localUserKey, jsonEncode(body['data']['user']).toString());
        Utils.logTikTokEvent(
          "login",
        );

        isNewUser.value = body['data']['isNewUser'] == true;
        if (isNewUser.value) {
          Get.toNamed(AppRoutes.completeProfileScreen);
        } else {
          Get.offAllNamed(AppRoutes.dashboardScreen);
        }
      } else {
        final errorMessage = body['message'].tr ?? "Invalid OTP.".tr;
        MessagesManager.showErrorMessage(errorMessage);
        // Get.offAllNamed(AppRoutes.loginScreen);
      }
    } catch (e) {
      if (kDebugMode) print(e);
      MessagesManager.showErrorMessage("An error occurred. Please try again.".tr);
    } finally {
      setIsLoading(false);
    }
  }

  void register() async {
    setIsRegisterLoading(true);
    try {
      if (nameController.text.isEmpty || phoneController.text.isEmpty || bioController.text.isEmpty || priceController.text.isEmpty
          || image.value.path.isEmpty
      ) {
        MessagesManager.showErrorMessage("Please fill all the fields".tr);
        setIsRegisterLoading(false);
        return;
      }

      final data = Register(
        image: image.value,
        name: nameController.text,
        phone: "${country.phoneCode}${phoneController.text}",
        bio: bioController.text,
        price: double.parse(priceController.text),
      );

      final response = await AuthRepository().register(data);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == 'success') {
        phoneController.clear();
        nameController.clear();
        priceController.clear();
        bioController.clear();
        otpController.clear();
        Get.offAndToNamed(AppRoutes.loginScreen);
        MessagesManager.showSuccessMessage("Registered successfully".tr);
      } else {
        final errorMessage = body['message'].tr ?? "Failed to register.".tr;
        MessagesManager.showErrorMessage(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) print(e);
      MessagesManager.showErrorMessage("An error occurred. Please try again.".tr);
    } finally {
      setIsRegisterLoading(false);
    }
  }
}
