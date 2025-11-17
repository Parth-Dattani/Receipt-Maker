
import 'dart:ui';

import 'package:get/get.dart';

import '../utils/shared_preferences_helper.dart';

class AppConstants{

   static String  userId = "";
   static String  companyId = "";
   static String appId = "";
   static String spreadsheetId = "";
   static String accessKey = "";
   static String businessType = "Trading";
   static final isChallan = false.obs; //isChallanEnabled
   static final withGST = false.obs; //isGstEnabled
   static final isGujarati = false.obs; //Language toggle
   static final isDemo = false.obs;

   /// 🔹 Load everything from SharedPreferences into memory
   static Future<void> loadFromPrefs() async {
      userId = await sharedPreferencesHelper.getPrefData("userId") ?? "";
      companyId = await sharedPreferencesHelper.getPrefData("companyId") ?? "";
      appId = await sharedPreferencesHelper.getPrefData("appId") ?? "";
      spreadsheetId = await sharedPreferencesHelper.getPrefData("spreadsheetId") ?? "";
      accessKey = await sharedPreferencesHelper.getPrefData("accessKey") ?? "";
      businessType = await sharedPreferencesHelper.getPrefData("businessType") ?? "Trading"; // 🆕 Load businessType

      isChallan.value = await sharedPreferencesHelper.retrievePrefBoolData("isChallanEnabled") ?? false;
      withGST.value = await sharedPreferencesHelper.retrievePrefBoolData("isGstEnabled") ?? false;
      isGujarati.value = await sharedPreferencesHelper.retrievePrefBoolData("isGujarati") ?? false;
      isDemo.value = await sharedPreferencesHelper.retrievePrefBoolData("isDemo") ?? false; // 🆕 Load demo status

      // 🔹 Apply saved language
      if (isGujarati.value) {
         Get.updateLocale(const Locale('gu', 'IN'));
      } else {
         Get.updateLocale(const Locale('en', 'US'));
      }

   }

   /// Toggle and persist language
   static Future<void> setLanguage(bool isGuj) async {
      isGujarati.value = isGuj;
      await sharedPreferencesHelper.storeBoolPrefData("isGujarati", isGuj);

      // Update GetX locale
      if (isGuj) {
         Get.updateLocale(const Locale('gu', 'IN'));
      } else {
         Get.updateLocale(const Locale('en', 'US'));
      }
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

   /// 🔹 Update + persist businessType
   static Future<void> setBusinessType(String type) async {
      businessType = type;
      await sharedPreferencesHelper.storePrefData("businessType", type);
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

   static Future<void> setDemoMode(bool value) async {
      isDemo.value = value;
      await sharedPreferencesHelper.storeBoolPrefData("isDemo", value);
   }
}