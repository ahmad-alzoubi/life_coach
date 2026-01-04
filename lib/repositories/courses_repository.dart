import 'package:coach_life/model/course.dart';
import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CoursesRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<http.Response> getCourses() async {
    try {
      final response = await _apiService.getRequest(ApiRoutes.getCourses, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

  Future<http.Response> buyCourses(List<Course> courses) async {
    try {
      List<String> ids = courses.map((e) => e.id).toList();
      final response = await _apiService.postRequest(ApiRoutes.buyCourses, {'ids': ids}, hasAuthToken: true);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return http.Response('Error', 500);
  }

}