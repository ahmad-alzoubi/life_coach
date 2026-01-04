import 'dart:convert';
import 'dart:io';

import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<http.Response> getConversations() async {
    try {
      final response = await _apiService.getRequest(ApiRoutes.getConversations, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  // Future<http.Response> getMessages(String conversationId) async {
  //   try {
  //     final response = await _apiService.getRequest('${ApiRoutes.getMessages}/$conversationId', hasAuthToken: true);
  //     return response;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  //   return http.Response('Error', 500);
  // }



  Future<http.Response> sendTextMessage(Map<String, dynamic> data) async {
    final url = Uri.parse(ApiRoutes.sendTextMessage);

    // Pretty JSON for logs
    String prettyJson(Object o) =>
        const JsonEncoder.withIndent('  ').convert(o);

    // Log request
    if (kDebugMode) {
      debugPrint('➡️ POST $url');
      debugPrint('➡️ Body:\n${prettyJson(data)}');
    }

    try {
      final response = await _apiService.postRequest(
        ApiRoutes.sendTextMessage,
        data,
        hasAuthToken: true,
      );

      // Log response
      if (kDebugMode) {
        debugPrint('⬅️ [${response.statusCode}] $url');
        debugPrint('⬅️ Headers: ${response.headers}');
        final bodyText = () {
          try {
            return prettyJson(json.decode(response.body));
          } catch (_) {
            return response.body; // not JSON
          }
        }();
        debugPrint('⬅️ Body:\n$bodyText');
      }

      return response;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ POST $url failed: $e');
        debugPrint(st.toString());
      }
      // keep your existing behavior:
      return http.Response('Error', 500);
    }
  }


  Future<http.Response> sendAudioMessage(Map<String, String> data, File audioFile) async {
    try {
      final response = await _apiService.sendDataWithFile(ApiRoutes.sendAudioMessage, data, audioFile, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }
}
