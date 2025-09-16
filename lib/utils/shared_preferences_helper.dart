import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferences? prefs;


  Future getSharedPreferencesInstance() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future storeBoolPrefData(String key, bool res) async {
    await prefs?.setBool(key, res);
  }

  Future storePrefData(String key, String res) async {
    await prefs?.setString(key, res);
  }

  Future<String?> getPrefData(String key) async {
    return prefs?.getString(key);
  }

  Future<bool> retrievePrefBoolData(String key) async {
    return prefs?.getBool(key) ?? false;
  }

  Future clearPrefData() async {
    await prefs?.clear();
  }

  Future clearPrefDataByKey(String key) async {
    await prefs?.remove(key);
  }
}

SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
