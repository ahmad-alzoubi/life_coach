import 'dart:io';

import 'package:coach_life/model/register.dart';
import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UserRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<http.Response> getWallet() async {
    final http.Response response = await _apiService.getRequest(ApiRoutes.getWallet, hasAuthToken: true);
    return response;
  }

  Future<http.Response> getProfile() async {
    final http.Response response = await _apiService.getRequest(ApiRoutes.getProfile, hasAuthToken: true);
    return response;
  }

  Future<http.Response> deleteAccount() async {
    final http.Response response = await _apiService.postRequest(ApiRoutes.deleteAccount, {}, hasAuthToken: true);
    return response;
  }
}