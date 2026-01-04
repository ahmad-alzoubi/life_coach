import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CoachsRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<http.Response> getAllCoaches() async {
    try {
      final response = await _apiService.getRequest(ApiRoutes.getAllCoachs, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> getSchedules() async {
    try {
      final response = await _apiService.getRequest(ApiRoutes.getSchedules, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> updateSchedule(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.putRequest(ApiRoutes.updateSchedule, data, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  Future deleteSchedule(String id) async {
    try {
      final response = await _apiService.deleteRequest(ApiRoutes.deleteSchedule(id), hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<http.Response> getCoachSchedules(String id, String duration) async {
    try {
      final response = await _apiService.getRequest('${ApiRoutes.getCoachSchedules(id)}?duration=$duration',
        hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> createSchedule(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postRequest(ApiRoutes.createSchedule, data, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> rateCoach(int rate, String comment, String coachId, {bool isChat = false}) async {
    Map<String, dynamic> data = {
      "rate": rate,
      "comment": comment,
      "is_chat": isChat
    };
    try {
      final response = await _apiService.postRequest(ApiRoutes.rateCoach(coachId), data, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> updateCoachDetails(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postRequest(ApiRoutes.updateProfile, data, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> getCoachAttributes() async {
    try {
      final response = await _apiService.getRequest(ApiRoutes.getCoachAttributes, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

}