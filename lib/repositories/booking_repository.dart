import 'dart:convert';
import 'dart:io';

import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BookingRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<http.Response> getBookings() async {
    try {
      final response = await _apiService.getRequest(
        ApiRoutes.getBookings,
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> checkBookingTime(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postRequest(
        ApiRoutes.checkBookingTime,
        data,
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postRequest(
        ApiRoutes.createBooking,
        data,
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> payWithWallet(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postRequest(
        ApiRoutes.payWithWallet,
        data,
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> getConversations() async {
    try {
      final response = await _apiService.getRequest(
        ApiRoutes.getConversations,
        hasAuthToken: true,
      );
      if (kDebugMode) {
        print(response.body.toString());
        print('conversations === >>> ');
      }
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> checkBookingWillStart() async {
    try {
      final response = await _apiService.getRequest(
        ApiRoutes.checkBookingWillStart,
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> acceptCall(String bookingId) async {
    try {
      final response = await _apiService.postRequest(ApiRoutes.acceptCall, {
        "booking_id": bookingId,
      }, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> quitCall(String bookingId) async {
    try {
      final response = await _apiService.postRequest(ApiRoutes.quitCall, {
        "booking_id": bookingId,
      }, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> checkBookingStatus(String bookingId) async {
    try {
      final response = await _apiService.getRequest(
        ApiRoutes.checkBookingStatus(bookingId),
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> userLeftCall(
    String userId,
    String formatedTime,
    String bookingId,
    String reason,
  ) async {
    try {
      final response = await _apiService.postRequest(ApiRoutes.userLeftCall, {
        "user_id": userId,
        "formated_time": formatedTime,
        "booking_id": bookingId,
        "reason": reason,
      }, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> getBookingRemainingTime(String bookingId) async {
    try {
      final response = await _apiService.getRequest(
        ApiRoutes.getBookingRemainingTime(bookingId),
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return http.Response('Error', 500);
  }

  Future<String> getNewToken(String bookingId) async {
    try {
      final response = await _apiService.getRequest(
        ApiRoutes.getNewToken(bookingId),
        hasAuthToken: true,
      );
      return response.body;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return '';
  }

  // ----------------- NEW: in-call helpers -----------------

  /// Send a push/in-app notification to the other participant (role = 'coach' | 'user')
  Future<http.Response> sendInCallNotification(
    String bookingId,
    String role,
  ) async {
    try {
      final response = await _apiService.postRequest(
        ApiRoutes.sendInCallNotification,
        {"booking_id": bookingId, "role": role},
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print('sendInCallNotification error: $e');
    }
    return http.Response('Error', 500);
  }

  /// Send an in-call chat message (message can contain text + optional attachmentUrl)
  Future<http.Response> sendInCallMessage(
    String bookingId,
    Map<String, dynamic> message,
  ) async {
    try {
      final response = await _apiService.postRequest(
        ApiRoutes.sendInCallMessage,
        {"booking_id": bookingId, "message": message},
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print('sendInCallMessage error: $e');
    }
    return http.Response('Error', 500);
  }

  /// Upload a file for in-call chat. This implementation encodes file as Base64 and sends JSON.
  /// Server should accept {"booking_id","filename","file": "<base64>"} and return JSON with uploaded file URL.
  Future<http.Response> uploadInCallFile(String bookingId, File file) async {
    try {
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      final filename = file.path.split(Platform.pathSeparator).last;
      final response = await _apiService.postRequest(
        ApiRoutes.uploadInCallFile,
        {"booking_id": bookingId, "filename": filename, "file": b64},
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print('uploadInCallFile error: $e');
    }
    return http.Response('Error', 500);
  }

  /// Open a support ticket / send message to support (used by support modal)
  Future<http.Response> openSupportTicket(String bookingId, String text) async {
    try {
      final response = await _apiService.postRequest(
        ApiRoutes.openSupportTicket,
        {"booking_id": bookingId, "message": text},
        hasAuthToken: true,
      );
      return response;
    } catch (e) {
      if (kDebugMode) print('openSupportTicket error: $e');
    }
    return http.Response('Error', 500);
  }

  /// Refund booking (used in no-show flow). server API should accept booking_id and amount.
  Future<http.Response> refundBooking(
    String bookingIdLocal,
    double refundAmount,
  ) async {
    try {
      final response = await _apiService.postRequest(ApiRoutes.refundBooking, {
        "booking_id": bookingIdLocal,
        "amount": refundAmount,
      }, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) print('refundBooking error: $e');
    }
    return http.Response('Error', 500);
  }
}
