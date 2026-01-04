import 'dart:io';

import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<http.Response> getNotifications() async {
    final http.Response response = await _apiService.getRequest(ApiRoutes.getNotifications, hasAuthToken: true);
    return response;
  }
}