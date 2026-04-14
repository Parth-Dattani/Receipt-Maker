
import 'dart:ui';

import 'package:get/get.dart';

import '../utils/shared_preferences_helper.dart';

class AppConstants{

   static String  userId = "";
   static String  companyId = "";
   static String  companyName = "";
   static String appId = "";
   static String spreadsheetId = "";
   static String googleAccessToken = "";
   /// Active financial year (e.g. "2024-25"). Each FY has its own Google Sheet.
   static String activeFy = "";
   /// Service Account JSON in assets/ — GetYourInvoice project key (Sheets/Drive).
   static String serviceAccountJsonPath = "getyourinvoice-8f128-3dfb21843bde.json";
   /// "Share sheet with" message માં દેખાડવાનો email — JSON ના client_email જેવો જ રાખો.
   static String serviceAccountEmailForDisplay = "getyourinvoice-sheet-access@getyourinvoice-8f128.iam.gserviceaccount.com";
   /// Web-only: paste Firebase Authentication → Google → Web SDK configuration → Web client ID (for Google Sign-In on web).
   /// On Android, same ID is used as serverClientId so Firebase accepts the token. Use your project's Web client ID.
   static String googleWebClientId = "134369591951-51gsni8h3hgeihrpgu3og7t0n42slbb8.apps.googleusercontent.com";
   static String accessKey = "";
   static String businessType = "Trading";
   /// Purchase, stock, challan menus apply only when [businessType] is exactly `Trading`.
   static bool get isTradingCompany => businessType.trim() == 'Trading';
   static String appName = "Invoice Sathi";
   static final isChallan = false.obs; //isChallanEnabled
   static final isCashMemo = false.obs; // isCashMemoEnabled
   static final withGST = false.obs; //isGstEnabled
   static final isGujarati = false.obs; //Language toggle
   static final isDemo = false.obs;
   static final isDueDateEnabled = false.obs;
   static int dueDateDays = 0;
   static final RxBool isExtraNotesEnabled = false.obs;
   static bool allowDuplicateItems = false;
   static final RxBool enableCustomerOrderFeature = false.obs;
   /// When false (Firestore), Payment / Receipt menu is hidden. Missing field = enabled.
   static final RxBool enablePaymentReceiptFeature = true.obs;
   /// When false (Firestore), Purchase menu is hidden (Trading). Missing field = enabled.
   static final RxBool enablePurchaseFeature = true.obs;
   static var isWhatsappDirectShare = false.obs;

   /// Digits after decimal point for amounts (e.g. 2 → 350.00, 0 → 350).
   static int decimalPlaces = 2;


   /// Format amount with company's decimal places.
   static String formatAmount(double amount) => amount.toStringAsFixed(decimalPlaces);

   /// 🔹 Load everything from SharedPreferences into memory
   static Future<void> loadFromPrefs() async {
      userId = await sharedPreferencesHelper.getPrefData("userId") ?? "";
      companyId = await sharedPreferencesHelper.getPrefData("companyId") ?? "";
      companyName = await sharedPreferencesHelper.getPrefData("companyName") ?? ""; // ✅ Load Company Name
      appId = await sharedPreferencesHelper.getPrefData("appId") ?? "";
      spreadsheetId = await sharedPreferencesHelper.getPrefData("spreadsheetId") ?? "";
      activeFy = await sharedPreferencesHelper.getPrefData("activeFy") ?? "";
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
      decimalPlaces = int.tryParse(await sharedPreferencesHelper.getPrefData("decimalPlaces") ?? "2") ?? 2;
      allowDuplicateItems = await sharedPreferencesHelper.retrievePrefBoolData("allowDuplicateItems") ?? false;

      enableCustomerOrderFeature.value = await sharedPreferencesHelper.retrievePrefBoolData("enableCustomerOrderFeature") ?? false;

      enablePaymentReceiptFeature.value =
          await sharedPreferencesHelper.retrievePrefBoolData("enablePaymentReceiptFeature") ?? true;
      enablePurchaseFeature.value =
          await sharedPreferencesHelper.retrievePrefBoolData("enablePurchaseFeature") ?? true;

      // Non-Trading (e.g. Service) never uses Purchase — avoid stale true from prefs.
      if (!isTradingCompany) {
        enablePurchaseFeature.value = false;
        await sharedPreferencesHelper.storeBoolPrefData("enablePurchaseFeature", false);
      }

      isWhatsappDirectShare.value = await sharedPreferencesHelper.retrievePrefBoolData("isWhatsappDirectShare") ?? false;
   }

   /// 🔹 Update + persist decimalPlaces (digits after decimal point)
   static Future<void> setDecimalPlaces(int value) async {
      decimalPlaces = value.clamp(0, 6);
      await sharedPreferencesHelper.storePrefData("decimalPlaces", decimalPlaces.toString());
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

   /// 🔹 Update + persist spreadsheetId (used for current FY sheet)
   static Future<void> setSpreadsheetId(String id) async {
      spreadsheetId = id;
      await sharedPreferencesHelper.storePrefData("spreadsheetId", id);
   }

   /// 🔹 Update + persist activeFy (e.g. "2024-25")
   static Future<void> setActiveFy(String fy) async {
      activeFy = fy;
      await sharedPreferencesHelper.storePrefData("activeFy", fy);
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
      if (!isTradingCompany) {
         await setEnablePurchaseFeature(false);
      }
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


   static Future<void> setAllowDuplicateItems(bool value) async {
      allowDuplicateItems = value;
      await sharedPreferencesHelper.storeBoolPrefData("allowDuplicateItems", value);
   }

   static Future<void> setEnableCustomerOrderFeature(bool val) async {
      enableCustomerOrderFeature.value = val;
      await sharedPreferencesHelper.storeBoolPrefData("enableCustomerOrderFeature", val);
   }

   static Future<void> setEnablePaymentReceiptFeature(bool val) async {
      enablePaymentReceiptFeature.value = val;
      await sharedPreferencesHelper.storeBoolPrefData("enablePaymentReceiptFeature", val);
   }

   static Future<void> setEnablePurchaseFeature(bool val) async {
      enablePurchaseFeature.value = val;
      await sharedPreferencesHelper.storeBoolPrefData("enablePurchaseFeature", val);
   }

   static Future<void> setIsWhatsappDirectShare(bool val) async {
      isWhatsappDirectShare.value = val;
      await sharedPreferencesHelper.storeBoolPrefData("isWhatsappDirectShare", val);
      print("💾 WhatsApp Direct Share Saved: $val");
   }
}