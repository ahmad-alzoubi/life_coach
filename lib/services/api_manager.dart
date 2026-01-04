import 'dart:convert';
import 'dart:io';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiService extends GetxService {
  final String baseUrl;

  ApiService(this.baseUrl) {
    if (kDebugMode) {
      print("API Service Initialized with Base URL: $baseUrl");
    }
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      if (kDebugMode) {
        print("Unauthorized (401): Logging out user.");
      }
      SharedPreferencesManager.instance!.clear();
      Get.offAllNamed(AppRoutes.loginScreen);
    }
    return await response;
  }

  Future<http.Response> getRequest(String endpoint, {bool? hasAuthToken}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    if (kDebugMode) {
      print("GET Request: $url");
    }
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${(hasAuthToken == true) ? SharedPreferencesManager.instance!.get(Utils.accessTokenKey) : ''}',
      'User-Agent': GetPlatform.isAndroid ? 'Android' : 'IOS',
    });
    if (kDebugMode) {
      print("GET Response: ${response.body}");
    }
    return _handleResponse(response);
  }

  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data, {bool? hasAuthToken}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    if (kDebugMode) {
      print("POST Request: $url");
    }
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${(hasAuthToken == true) ? SharedPreferencesManager.instance!.get(Utils.accessTokenKey) : ''}',
          'User-Agent': GetPlatform.isAndroid ? 'Android' : 'IOS',
        },
        body: jsonEncode(data));
    if (kDebugMode) {
      print("POST Response: ${response.body}");
    }
    return _handleResponse(response);
  }

  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> data, {bool? hasAuthToken}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    if (kDebugMode) {
      print("PUT Request: $url");
    }
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${(hasAuthToken == true) ? SharedPreferencesManager.instance!.get(Utils.accessTokenKey) : ''}',
          'User-Agent': GetPlatform.isAndroid ? 'Android' : 'IOS',
        },
        body: jsonEncode(data));
    if (kDebugMode) {
      print("PUT Response: ${response.body}");
    }
    return _handleResponse(response);
  }

  Future<http.Response> deleteRequest(String endpoint, {bool? hasAuthToken}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    if (kDebugMode) {
      print("DELETE Request: $url");
    }
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${(hasAuthToken == true) ? SharedPreferencesManager.instance!.get(Utils.accessTokenKey) : ''}',
      'User-Agent': GetPlatform.isAndroid ? 'Android' : 'IOS',
    });
    if (kDebugMode) {
      print("DELETE Response: ${response.body}");
    }
    return _handleResponse(response);
  }

  Future<http.Response> sendDataWithFile(String endpoint, Map<String, String> data, File file, {bool? hasAuthToken}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    if (kDebugMode) {
      print("POST Request with File: $url");
    }
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${(hasAuthToken == true) ? SharedPreferencesManager.instance!.get(Utils.accessTokenKey) : ''}'
      ..fields.addAll(data)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseString = await response.stream.bytesToString();
    if (kDebugMode) {
      print("POST Response: $responseString");
    }
    return _handleResponse(http.Response(responseString, response.statusCode));
  }
}
