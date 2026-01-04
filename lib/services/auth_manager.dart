// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../utils/utlis.dart';

class AuthManager extends GetxService {

  // Function to get the access token
  Future<String?> getAccessToken() async {
    // return await Utils.storage.read(key: Utils.accessTokenKey);
    return Utils.prefs?.getString(Utils.accessTokenKey);
  }

  // Function to set the access token
  Future<void> setAccessToken(String accessToken) async {
    // await Utils.storage.write(key: Utils.accessTokenKey, value: accessToken);
    Utils.prefs?.setString(Utils.accessTokenKey, accessToken);
  }

  // Function to get the refresh token
  Future<String?> getRefreshToken() async {
    // return await Utils.storage.read(key: Utils.refreshTokenKey);
    return Utils.prefs?.getString(Utils.refreshTokenKey);
  }

  // Function to set the refresh token
  Future<void> setRefreshToken(String refreshToken) async {
    // await Utils.storage.write(key: Utils.refreshTokenKey, value: refreshToken);
    Utils.prefs?.setString(Utils.refreshTokenKey, refreshToken);
  }

  // Function to clear the access token and refresh token
  Future<void> clearTokens() async {
    // await Utils.storage.delete(key: Utils.accessTokenKey);
    // await Utils.storage.delete(key: Utils.refreshTokenKey);
    await Utils.prefs?.setString(Utils.accessTokenKey, "");
    await Utils.prefs?.setString(Utils.refreshTokenKey, "");

  }
}