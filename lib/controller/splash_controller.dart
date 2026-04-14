import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GetYourInvoice/constant/app_constant.dart';
import 'package:GetYourInvoice/controller/controller.dart';
import 'package:GetYourInvoice/screen/screen.dart';
import 'package:GetYourInvoice/screen/order/order_screen.dart';
import 'package:GetYourInvoice/services/remote_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../utils/financial_year_helper.dart';
import '../utils/utils.dart';

class SplashController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
   // goToNext();
  }

  // void goToNext() async {
  //   final startTime = DateTime.now();
  //   // Show splash for minimum 2 seconds
  //  // await Future.delayed(const Duration(seconds: 2));
  //
  //   // ✅ Public route bypass: allow /order on web without login
  //   if (kIsWeb) {
  //     final frag = Uri.base.fragment;
  //     if (frag.contains('/order')) {
  //       print("Public order route detected → OrderScreen (no auth)");
  //       Get.offAllNamed(OrderScreen.pageId);
  //       return;
  //     }
  //   }
  //
  //   final user = _auth.currentUser;
  //
  //   // ✅ Step 1: User not logged in
  //   if (user == null) {
  //     print("No user logged in → AuthScreen");
  //     Get.offAllNamed(AuthScreen.pageId);
  //     return;
  //   }
  //
  //   // ✅ Save userId
  //   await AppConstants.setUserId(user.uid);
  //   print("Logged-in User: ${user.uid} | Email: ${user.email}");
  //
  //   try {
  //     // ✅ Fetch user doc and companies in parallel (one less round trip)
  //     final results = await Future.wait([
  //       _firestore.collection("users").doc(user.uid).get(),
  //       _firestore
  //           .collection("users")
  //           .doc(user.uid)
  //           .collection("companies")
  //           .where('isActive', isEqualTo: true)
  //           .limit(1)
  //           .get(),
  //     ]);
  //
  //     final userDoc = results[0] as DocumentSnapshot;
  //     final companiesQuery = results[1] as QuerySnapshot;
  //
  //     // Demo status from user doc
  //     if (userDoc.exists) {
  //       final userData = userDoc.data() as Map<String, dynamic>? ?? {};
  //       await AppConstants.setDemoMode(userData['isDemo'] == true);
  //     } else {
  //       await AppConstants.setDemoMode(false);
  //     }
  //
  //     // ✅ Step 2: Check if company exists
  //     if (companiesQuery.docs.isEmpty) {
  //       print("No company found → CompanyRegistrationScreen");
  //       Get.offAllNamed(CompanyRegistrationScreen.pageId);
  //       return;
  //     }
  //
  //     final companyDoc = companiesQuery.docs.first;
  //     final companyId = companyDoc.id;
  //     final companyData = companyDoc.data() as Map<String, dynamic>;
  //
  //     await AppConstants.setCompanyId(companyId);
  //     print("Company found → ID: $companyId");
  //
  //     String fetchedCompanyName = companyData['companyName'] ?? "";
  //     if (fetchedCompanyName.isNotEmpty) {
  //       await AppConstants.setCompanyName(fetchedCompanyName);
  //     }
  //
  //     // ✅ Load company settings from already fetched data
  //     await loadCompanySettingsFromData(companyData);
  //
  //     // ✅ Step 3: Check spreadsheet (from same user doc we already have)
  //     if (!userDoc.exists) {
  //       print("User document missing → CompanyRegistrationScreen");
  //       Get.offAllNamed(CompanyRegistrationScreen.pageId);
  //       return;
  //     }
  //
  //     final userData = userDoc.data() as Map<String, dynamic>? ?? {};
  //     // Resolve spreadsheet for active financial year (each FY has separate sheet)
  //     String? resolvedSpreadsheetId = userData['spreadsheetId'] as String?;
  //     String? activeFy = userData['activeFy'] as String?;
  //     final spreadsheetIdsByFy = userData['spreadsheetIdsByFy'];
  //     Map<String, String>? fyMap;
  //     if (spreadsheetIdsByFy is Map) {
  //       fyMap = Map<String, String>.from(
  //         spreadsheetIdsByFy.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
  //       );
  //     }
  //     if (fyMap != null && fyMap.isNotEmpty && activeFy != null && activeFy.isNotEmpty) {
  //       resolvedSpreadsheetId = fyMap[activeFy] ?? resolvedSpreadsheetId;
  //     }
  //     // Migrate: if we have sheet but no FY data, set current FY and one entry
  //     if (resolvedSpreadsheetId != null &&
  //         resolvedSpreadsheetId.isNotEmpty &&
  //         (activeFy == null || activeFy.isEmpty || fyMap == null || fyMap.isEmpty)) {
  //       final currentFy = FinancialYearHelper.currentFy();
  //       activeFy = currentFy;
  //       fyMap = {currentFy: resolvedSpreadsheetId};
  //       try {
  //         await _firestore.collection('users').doc(user.uid).update({
  //           'activeFy': currentFy,
  //           'spreadsheetIdsByFy': {currentFy: resolvedSpreadsheetId},
  //         });
  //       } catch (_) {}
  //     }
  //
  //     final spreadsheetId = resolvedSpreadsheetId;
  //
  //     if (spreadsheetId != null && spreadsheetId.isNotEmpty) {
  //       await AppConstants.setSpreadsheetId(spreadsheetId);
  //       if (activeFy != null && activeFy.isNotEmpty) {
  //         await AppConstants.setActiveFy(activeFy);
  //       }
  //
  //       print("✅ Spreadsheet found → $spreadsheetId${activeFy != null ? " (FY $activeFy)" : ""}");
  //
  //       // Ensure Item, Customer, Invoice etc. tabs exist (required before Dashboard)
  //       try {
  //         await GoogleSheetService.ensureSheetsExist();
  //       } catch (e) {
  //         print("⚠️ ensureSheetsExist on splash: $e");
  //       }
  //
  //       // Only test access before navigate; heavy validation runs in background
  //       final hasAccess = await GoogleSheetService.testSpreadsheetAccess();
  //       if (!hasAccess) {
  //         _printSheetsAccessInstructions();
  //         return;
  //       }
  //
  //       // Run full validation in background (don't block opening Dashboard)
  //       _runSheetValidationInBackground();
  //
  //       // Go to dashboard immediately
  //       print("✅ Navigating to Dashboard");
  //       Get.offAllNamed(DashboardScreen.pageId);
  //     }
  //     else {
  //       print("Company exists but no Spreadsheet → CompanyRegistrationScreen");
  //       Get.offAllNamed(CompanyRegistrationScreen.pageId);
  //     }
  //
  //   } catch (e) {
  //     print("Error checking company or user data: $e");
  //     Get.offAllNamed(CompanyRegistrationScreen.pageId);
  //   }
  // }

  void goToNext() async {
    final startTime = DateTime.now();

    // ૧. પબ્લિક રૂટ ચેક (વેબ માટે)
    if (kIsWeb) {
      final frag = Uri.base.fragment;
      if (frag.contains('/order')) {
        Get.offAllNamed(OrderScreen.pageId);
        return;
      }
    }

    final user = _auth.currentUser;

    // ૨. લોગિન ચેક
    if (user == null) {
      Get.offAllNamed(AuthScreen.pageId);
      return;
    }

    await AppConstants.setUserId(user.uid);

    try {
      // Parallel data fetching 🚀
      final results = await Future.wait([
        _firestore.collection("users").doc(user.uid).get(),
        _firestore.collection("users").doc(user.uid).collection("companies")
            .where('isActive', isEqualTo: true).limit(1).get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot;
      final companiesQuery = results[1] as QuerySnapshot;

      if (!userDoc.exists) {
        Get.offAllNamed(AuthScreen.pageId);
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>? ?? {};

      // ડેમો મોડ સેટ કરો
      await AppConstants.setDemoMode(userData['isDemo'] == true);

      // ૩. કંપની ચેક
      if (companiesQuery.docs.isEmpty) {
        Get.offAllNamed(CompanyRegistrationScreen.pageId);
        return;
      }

      final companyDoc = companiesQuery.docs.first;
      // ✅ એરર ફિક્સ: data() ને Map માં કાસ્ટ કર્યું
      final companyData = companyDoc.data() as Map<String, dynamic>? ?? {};

      await AppConstants.setCompanyId(companyDoc.id);

      // કંપનીનું નામ સેટ કરો
      String fetchedCompanyName = companyData['companyName'] ?? "";
      if (fetchedCompanyName.isNotEmpty) {
        await AppConstants.setCompanyName(fetchedCompanyName);
      }

      // સેટિંગ્સ લોડ કરો
      await loadCompanySettingsFromData(companyData);

      // ૪. સ્પ્રેડશીટ આઈડી મેળવો
      String? spreadsheetId = userData['spreadsheetId'];
      String? activeFy = userData['activeFy'];

      if (spreadsheetId != null && spreadsheetId.isNotEmpty) {
        await AppConstants.setSpreadsheetId(spreadsheetId);
        if (activeFy != null) await AppConstants.setActiveFy(activeFy);

        // 🔥 બધું હેવી કામ બેકગ્રાઉન્ડમાં મોકલી દીધું
        _runAllSheetTasksInBackground();

        // સ્પ્લેશ મિનિમમ ૧.૫ થી ૨ સેકન્ડ બતાવવા માટે
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        if (elapsed < 1500) {
          await Future.delayed(Duration(milliseconds: 1500 - elapsed));
        }

        print("✅ Fast Entry to Dashboard");
        Get.offAllNamed(DashboardScreen.pageId);
      } else {
        Get.offAllNamed(CompanyRegistrationScreen.pageId);
      }

    } catch (e) {
      print("Splash Error: $e");
      Get.offAllNamed(CompanyRegistrationScreen.pageId);
    }
  }

// ✅ આ ફંક્શન પણ તારી ક્લાસમાં નીચે એડ કરી દેજે
  void _runAllSheetTasksInBackground() {
    Future(() async {
      try {
        print("⏳ Background: Running sheet validations...");
        await GoogleSheetService.ensureSheetsExist();
        await GoogleSheetService.testSpreadsheetAccess();
        await GoogleSheetService.validateAndUpdateAllSheets();
        print("✅ Background: Sheet tasks finished.");
      } catch (e) {
        print("⚠️ Background Error: $e");
      }
    });
  }

  void _printSheetsAccessInstructions() {
    print("");
    print("=" * 70);
    print("⚠️ SETUP REQUIRED - GOOGLE SHEETS ACCESS");
    print("=" * 70);
    print("1. Open: https://docs.google.com/spreadsheets/d/${AppConstants.spreadsheetId}/edit");
    print("2. Click 'Share' button");
    print("3. Add as Editor: ${AppConstants.serviceAccountEmailForDisplay}");
    print("4. Restart app");
    print("=" * 70);
    print("");
  }

  /// Runs validateAndUpdateAllSheets in background so first open is faster.
  /// printInvoiceSheetColumns is skipped here to avoid extra read quota (429).
  void _runSheetValidationInBackground() {
    Future(() async {
      try {
        await GoogleSheetService.validateAndUpdateAllSheets();
        print("✅ Background sheet validation completed");
      } catch (e, st) {
        final is429 = e.toString().contains('429') || e.toString().toLowerCase().contains('quota exceeded');
        if (is429) {
          print("⚠️ Sheet validation quota exceeded; retrying once after 60s...");
          await Future.delayed(const Duration(seconds: 60));
          try {
            await GoogleSheetService.validateAndUpdateAllSheets();
            print("✅ Background sheet validation completed (after retry)");
          } catch (e2) {
            print("⚠️ Sheet validation skipped (quota); will retry on next app open.");
          }
          return;
        }
        print("⚠️ Background sheet validation error: $e");
        print("$st");
      }
    });
  }

  // ✅ Load settings from company data
  Future<void> loadCompanySettingsFromData(Map<String, dynamic> data) async {
    try {
      final isChallanEnabled = data['isChallanEnabled'] ?? false;
      final isCashMemoEnabled = data['isCashMemoEnabled'] ?? false;
      final isGstEnabled = data['isGstEnabled'] ?? false;
      final businessType = data['businessType'] ?? 'Trading';
      final isDueDateEnabled = data['isDueDateEnabled'] ?? false;
      final dueDateDays = data['dueDateDays'] ?? 0;

      // Store in SharedPreferences
      await sharedPreferencesHelper.storeBoolPrefData('isChallanEnabled', isChallanEnabled);
      await sharedPreferencesHelper.storeBoolPrefData('isCashMemoEnabled', isCashMemoEnabled);
      await sharedPreferencesHelper.storeBoolPrefData('isGstEnabled', isGstEnabled);
      await AppConstants.setBusinessType(businessType);
      if (businessType.toString().trim() == 'Trading') {
        await AppConstants.setEnablePurchaseFeature(
            data['enablePurchaseFeature'] != false);
      }
      await AppConstants.setDueDateEnabled(isDueDateEnabled);
      await AppConstants.setDueDateDays(dueDateDays is int ? dueDateDays : int.tryParse(dueDateDays.toString()) ?? 0);

      // Update AppConstants
      AppConstants.isChallan.value = isChallanEnabled;
      AppConstants.isCashMemo.value = isCashMemoEnabled;
      AppConstants.withGST.value = isGstEnabled;

      print("✅ Settings Loaded → Challan=$isChallanEnabled | CashMemo=$isCashMemoEnabled | GST=$isGstEnabled | Type=$businessType");
    } catch (e) {
      print("Error loading company settings: $e");
    }
  }

  // ✅ Fallback method
  Future<void> loadCompanySettings(String companyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId)
          .get();

      if (!doc.exists) return;

      final data = doc.data() ?? {};
      await loadCompanySettingsFromData(data);
    } catch (e) {
      print("Error loading company settings: $e");
    }
  }
}


