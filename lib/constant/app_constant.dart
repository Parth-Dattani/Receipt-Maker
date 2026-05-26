
import 'dart:ui';
import 'package:get/get.dart';
import '../utils/shared_preferences_helper.dart';

class AppConstants {
   static String userId = "";
   static String companyId = "";
   static String companyName = "";
   static String spreadsheetId = "";

   /// Active financial year (e.g. "2024-25"). Each FY has its own Google Sheet.
   static final activeFy = "2026-27".obs;

   /// Web-only: OAuth 2.0 Web client ID.
   static String googleWebClientId = "710899897768-5v9fst3j5ol287cmk5mro5q14jmdp3g4.apps.googleusercontent.com";

   static String appName = "Noor Receipt";
   static final isGujarati = false.obs; // Language toggle
   static var isWhatsappDirectShare = false.obs;

   /// Digits after decimal point for amounts (e.g. 2 → 350.00).
   static int decimalPlaces = 2;

   /// Format amount with company's decimal places.
   static String formatAmount(double amount) => amount.toStringAsFixed(decimalPlaces);

   /// 🔹 Load everything from SharedPreferences into memory
   static Future<void> loadFromPrefs() async {
      userId = await sharedPreferencesHelper.getPrefData("userId") ?? "";
      companyId = await sharedPreferencesHelper.getPrefData("companyId") ?? "";
      companyName = await sharedPreferencesHelper.getPrefData("companyName") ?? "";
      spreadsheetId = await sharedPreferencesHelper.getPrefData("spreadsheetId") ?? "";

      String savedFY = await sharedPreferencesHelper.getPrefData("active_fy") ?? "2026-27";

      // Normalize FY format
      if (savedFY.length == 9 && savedFY.contains('-')) {
         List<String> parts = savedFY.split('-');
         if (parts[1].length == 4) {
            savedFY = "${parts[0]}-${parts[1].substring(2)}";
            await sharedPreferencesHelper.storePrefData("active_fy", savedFY);
         }
      }
      activeFy.value = savedFY;

      isGujarati.value = await sharedPreferencesHelper.retrievePrefBoolData("isGujarati") ?? false;

      // Apply saved language
      if (isGujarati.value) {
         Get.updateLocale(const Locale('gu', 'IN'));
      } else {
         Get.updateLocale(const Locale('en', 'US'));
      }

      decimalPlaces = int.tryParse(await sharedPreferencesHelper.getPrefData("decimalPlaces") ?? "2") ?? 2;
      isWhatsappDirectShare.value = await sharedPreferencesHelper.retrievePrefBoolData("isWhatsappDirectShare") ?? false;
   }

   /// 🔹 Update + persist decimalPlaces
   static Future<void> setDecimalPlaces(int value) async {
      decimalPlaces = value.clamp(0, 6);
      await sharedPreferencesHelper.storePrefData("decimalPlaces", decimalPlaces.toString());
   }

   /// Toggle and persist language
   static Future<void> setLanguage(bool isGuj) async {
      isGujarati.value = isGuj;
      await sharedPreferencesHelper.storeBoolPrefData("isGujarati", isGuj);

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

   /// 🔹 Update + persist spreadsheetId
   static Future<void> setSpreadsheetId(String id) async {
      spreadsheetId = id;
      await sharedPreferencesHelper.storePrefData("spreadsheetId", id);
   }

   /// 🔹 Update + persist activeFy (e.g. "2024-25")
   static Future<void> setActiveFy(String fy) async {
      activeFy.value = fy;
      await sharedPreferencesHelper.storePrefData("active_fy", fy);
   }

   /// 🔹 Update + persist companyId
   static Future<void> setCompanyId(String id) async {
      companyId = id;
      await sharedPreferencesHelper.storePrefData("companyId", id);
   }

   /// 🔹 Update + persist companyName
   static Future<void> setCompanyName(String name) async {
      companyName = name;
      await sharedPreferencesHelper.storePrefData("companyName", name);
      print("💾 Company Name Saved to Prefs: $name");
   }

   static Future<void> setIsWhatsappDirectShare(bool val) async {
      isWhatsappDirectShare.value = val;
      await sharedPreferencesHelper.storeBoolPrefData("isWhatsappDirectShare", val);
      print("💾 WhatsApp Direct Share Saved: $val");
   }
}

class AppStrings {
   static const String appName = 'Noor Education Trust';
   static const String trustName = 'Noor Education Trust - Jamnagar';
   static const String trustReg1 = 'Registered Under Section 80 (G) of the Income Tax Act 1961';
   static const String trustReg2 = 'Regn. No. CIT (Exemption), Ahmedabad / 80 G / 2019-20/A/11023';
   static const String trustReg3 = 'Registered Under the Bombay Public Trust Act 1956';
   static const String trustRegNo = 'Reg. No. E/4326/Jamnagar';
   static const String trustAddress = 'Office Address: Nr. Bus Stand, Darbargadh, Jamnagar   M.: 98248 68786';
   static const String bankName = 'PUNJAB NATIONAL BANK';
   static const String bankAcNo = '04912413000575';
   static const String bankIfsc = 'PUNB0049110';
   static const String taxNote = 'Donation are Qualified for Deduction\nFrom Income Tax Under 80 (G) (50%)';
}
