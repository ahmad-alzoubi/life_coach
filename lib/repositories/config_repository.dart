import 'dart:io';

import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ConfigRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<http.Response> getConfig(Map<String, dynamic> data) async {
    final http.Response response = await _apiService.postRequest(
      ApiRoutes.getConfig,
      data,
      hasAuthToken: true
    );
    return response;
  }
}