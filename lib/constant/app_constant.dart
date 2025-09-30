
import 'package:get/get.dart';

import '../utils/shared_preferences_helper.dart';

class AppConstants{

   static String  userId = "";
   static String  companyId = "";
   static String appId = "";
   static String spreadsheetId = "";
   static String accessKey = "";
   static final isChallan = false.obs; //isChallanEnabled
   static final withGST = false.obs; //isGstEnabled


   /// 🔹 Load everything from SharedPreferences into memory
   static Future<void> loadFromPrefs() async {
      userId = await sharedPreferencesHelper.getPrefData("userId") ?? "";
      companyId = await sharedPreferencesHelper.getPrefData("companyId") ?? "";
      appId = await sharedPreferencesHelper.getPrefData("appId") ?? "";
      spreadsheetId = await sharedPreferencesHelper.getPrefData("spreadsheetId") ?? "";
      accessKey = await sharedPreferencesHelper.getPrefData("accessKey") ?? "";

      isChallan.value = await sharedPreferencesHelper.retrievePrefBoolData("isChallanEnabled") ?? false;
      withGST.value = await sharedPreferencesHelper.retrievePrefBoolData("isGstEnabled") ?? false;


   }

   /// 🔹 Update + persist userId
   static Future<void> setUserId(String id) async {
      userId = id;
      await sharedPreferencesHelper.storePrefData("userId", id);
   }

   /// 🔹 Update + persist companyId
   static Future<void> setCompanyId(String id) async {
      companyId = id;
      await sharedPreferencesHelper.storePrefData("companyId", id);
   }

   /// 🔹 Update + persist isChallanEnabled
   static Future<void> setChallanEnabled(bool value) async {
      isChallan.value = value;
      await sharedPreferencesHelper.storeBoolPrefData("isChallanEnabled", value);
   }

   /// 🔹 Update + persist isGstEnabled
   static Future<void> setGstEnabled(bool value) async {
      withGST.value = value;
      await sharedPreferencesHelper.storeBoolPrefData("isGstEnabled", value);
   }
}