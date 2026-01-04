import 'dart:io';

import 'package:coach_life/model/register.dart';
import 'package:coach_life/services/api_manager.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/api_routes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class AuthRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<http.Response> login(String phone, {int otpStatus = 0, String otp = "", bool isWhatsapp = false}) async {
    /// otpStatus = 0 means will Send otp to user
    /// otpStatus = 1 means will verify otp
    final http.Response response;
    if(otpStatus == 0){
      response = await _apiService.postRequest(ApiRoutes.login, {
        'phone': phone,
        // 'password': password,
        'otp_status': otpStatus,
        'is_whatsapp': isWhatsapp,
      });
    }else{
      response = await _apiService.postRequest(ApiRoutes.login, {
        'phone': phone,
        // 'password': password,
        'otp_status': otpStatus,
        'otp': otp,
        'is_whatsapp': isWhatsapp,
      });
    }
    return response;
  }

  Future logout() async {
    // Add the logout logic here
  }

  Future<http.Response> updateProfile(Map<String, dynamic> data, File? image) async {
    // Create multipart request
    var uri = Uri.parse("${_apiService.baseUrl}/${ApiRoutes.updateProfile}");
    var request = http.MultipartRequest('POST', uri);

    // Optionally add headers if needed
    request.headers.addAll({
      'Authorization': 'Bearer ${SharedPreferencesManager.instance!.getString('access_token')}',
    });

    // Add text fields
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add the file
    if (image != null) {
      var stream = http.ByteStream(image.openRead());
      stream.cast();
      var length = await image.length();
      var multipartFile = http.MultipartFile('image', stream, length,
          filename: basename(image.path));
      request.files.add(multipartFile);
    }

    // Send the request
    var response = await request.send();

    // Get the response from the server
    if (response.statusCode == 200) {
      return http.Response.fromStream(response);
    } else {
      throw Exception('Failed to update profile. Status code: ${response.statusCode}');
    }
  }

  Future<http.Response> register(Register data) async {
    // Create multipart request
    var uri = Uri.parse("${_apiService.baseUrl}/${ApiRoutes.register}");
    var request = http.MultipartRequest('POST', uri);

    // Add text fields
    request.fields['name'] = data.name;
    request.fields['phone'] = data.phone;
    request.fields['bio'] = data.bio;
    request.fields['price'] = data.price.toString();

    // Add the file
    var stream = http.ByteStream(data.image.openRead());
    stream.cast();
    var length = await data.image.length();
    var multipartFile = http.MultipartFile('image', stream, length,
        filename: basename(data.image.path));
    request.files.add(multipartFile);

    // Send the request
    var response = await request.send();

    // Get the response from the server
    if (response.statusCode == 200) {
      return http.Response.fromStream(response);
    } else {
      String body = await response.stream.bytesToString();
      throw Exception('Failed to register. Status code: ${response.statusCode}, Reaseon: ${response.reasonPhrase}, Body: $body');
    }
  }

}