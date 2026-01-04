import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_manager.dart';
import '../messages/messages_manager.dart';
import '../utlis.dart';
import 'api_exeptions.dart';

class ExceptionHandler {
  static void handle(Object error) {
    if (error is ApiException) {
      // Handle API exceptions
      handleApiException(error);
    } else if (error is OfflineException) {
      // Handle offline exceptions
      handleOfflineException();
    } else if (error is NotFoundException) {
      // Handle not found exceptions
      handleNotFoundException();
    } else if(error is DioException) {
      handleDioApiException(error);
    } else {
      // Handle other exceptions
      handleOtherException(error);
    }
  }
  static void handleApiException(ApiException error) {
    // Handle API exceptions based on the status code
    final AuthManager authManager = Get.find();
    switch (error.statusCode) {
      case 400:
      // Handle bad request
        MessagesManager.showErrorMessage('Bad request');
        break;
      case 401:
      // Handle unauthorized request
        MessagesManager.showErrorMessage('Unauthorized');
        Get.offAllNamed(AppRoutes.startScreen);
        Utils.prefs!.clear();
        authManager.clearTokens();
        break;
      case 403:
      // Handle forbidden request
        MessagesManager.showErrorMessage('Forbidden');
        break;
      case 404:
      // Handle not found request
        MessagesManager.showErrorMessage('Not found');
        break;
      case 500:
      // Handle internal server error
        MessagesManager.showErrorMessage('Internal server error');
        break;
      default:
      // Handle other status codes
        MessagesManager.showErrorMessage('Unknown error');
        break;
    }
  }

  static void handleDioApiException(DioException error) {
    // Handle API exceptions based on the status code
    final AuthManager authManager = Get.find();
    switch (error.response != null ? error.response!.statusCode : 500) {
      case 400:
      // Handle bad request
        MessagesManager.showErrorMessage(error.response == null ? 'Bad request' : error.response!.data['message']);
        break;
      case 401:
      // Handle unauthorized request
        MessagesManager.showErrorMessage('Unauthorized');
        Get.offAllNamed(AppRoutes.startScreen);
        Utils.prefs!.clear();
        authManager.clearTokens();
        break;
      case 403:
      // Handle forbidden request
        MessagesManager.showErrorMessage('Forbidden');
        break;
      case 404:
      // Handle not found request
        MessagesManager.showErrorMessage('Not found');
        break;
      case 500:
      // Handle internal server error
        MessagesManager.showErrorMessage('Internal server error');
        break;
      default:
      // Handle other status codes
        MessagesManager.showErrorMessage('Unknown error');
        break;
    }
  }

  static void handleOfflineException() {
    // Handle offline exceptions
    MessagesManager.showErrorMessage('You are offline');
  }

  static void handleNotFoundException() {
    // Handle not found exceptions
    MessagesManager.showErrorMessage('Resource not found');
  }

  static void handleOtherException(Object error) {
    // Handle other exceptions
    MessagesManager.showErrorMessage('An unknown error occurred');
    log(error.toString()); // Log the error for debugging purposes
  }
}