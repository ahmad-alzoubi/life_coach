import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences? get instance {
    if (_preferences == null) {
      throw Exception("SharedPreferences not initialized. Call SharedPreferencesManager.init() first.");
    }
    return _preferences;
  }
}