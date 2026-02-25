
import 'dart:ui';

import 'package:get/get.dart';

import '../utils/shared_preferences_helper.dart';

class AppConstants{

   static String  userId = "";
   static String  companyId = "";
   static String  companyName = "";
   static String appId = "";
   static String spreadsheetId = "";
   static String accessKey = "";
   static String businessType = "Trading";
   static final isChallan = false.obs; //isChallanEnabled
   static final isCashMemo = false.obs; // isCashMemoEnabled
   static final withGST = false.obs; //isGstEnabled
   static final isGujarati = false.obs; //Language toggle
   static final isDemo = false.obs;
   static final isDueDateEnabled = false.obs;
   static int dueDateDays = 0;
   static final RxBool isExtraNotesEnabled = false.obs;

   /// 🔹 Load everything from SharedPreferences into memory
   static Future<void> loadFromPrefs() async {
      userId = await sharedPreferencesHelper.getPrefData("userId") ?? "";
      companyId = await sharedPreferencesHelper.getPrefData("companyId") ?? "";
      companyName = await sharedPreferencesHelper.getPrefData("companyName") ?? ""; // ✅ Load Company Name
      appId = await sharedPreferencesHelper.getPrefData("appId") ?? "";
      spreadsheetId = await sharedPreferencesHelper.getPrefData("spreadsheetId") ?? "";
      accessKey = await sharedPreferencesHelper.getPrefData("accessKey") ?? "";
      businessType = await sharedPreferencesHelper.getPrefData("businessType") ?? "Trading"; // 🆕 Load businessType

      isChallan.value = await sharedPreferencesHelper.retrievePrefBoolData("isChallanEnabled") ?? false;
      isCashMemo.value = await sharedPreferencesHelper.retrievePrefBoolData("isCashMemoEnabled") ?? false;
      withGST.value = await sharedPreferencesHelper.retrievePrefBoolData("isGstEnabled") ?? false;
      isGujarati.value = await sharedPreferencesHelper.retrievePrefBoolData("isGujarati") ?? false;
      isDemo.value = await sharedPreferencesHelper.retrievePrefBoolData("isDemo") ?? false; // 🆕 Load demo status

      // 🔹 Apply saved language
      if (isGujarati.value) {
         Get.updateLocale(const Locale('gu', 'IN'));
      } else {
         Get.updateLocale(const Locale('en', 'US'));
      }

      isDueDateEnabled.value = await sharedPreferencesHelper.retrievePrefBoolData("isDueDateEnabled") ?? false;
      dueDateDays = int.tryParse(await sharedPreferencesHelper.getPrefData("dueDateDays") ?? "0") ?? 0;


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

   /// 🔹 Update + persist companyName (✅ Add this method)
   static Future<void> setCompanyName(String name) async {
      companyName = name;
      await sharedPreferencesHelper.storePrefData("companyName", name);
      print("💾 Company Name Saved to Prefs: $name");
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

   /// 🔹 Update + persist isCashMemoEnabled
   static Future<void> setCashMemoEnabled(bool value) async {
      isCashMemo.value = value;
      await sharedPreferencesHelper.storeBoolPrefData("isCashMemoEnabled", value);
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

   /// 🔹 Update + persist isDueDateEnabled
   static Future<void> setDueDateEnabled(bool value) async {
      isDueDateEnabled.value = value;
      await sharedPreferencesHelper.storeBoolPrefData("isDueDateEnabled", value);
   }

   /// 🔹 Update + persist dueDateDays
   static Future<void> setDueDateDays(int days) async {
      dueDateDays = days;
      await sharedPreferencesHelper.storePrefData("dueDateDays", days.toString());
   }


   static Future<void> setExtraNotesEnabled(bool value) async {
      isExtraNotesEnabled.value = value;
      await sharedPreferencesHelper.storeBoolPrefData('isExtraNotesEnabled', value);
   }

   static Future<bool> getExtraNotesEnabled() async {
      // final prefs = await SharedPreferences.getInstance();
      return await sharedPreferencesHelper.retrievePrefBoolData('isExtraNotesEnabled') ?? false;
   }
}