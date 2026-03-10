import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GetYourInvoice/constant/app_constant.dart';
import 'package:GetYourInvoice/controller/controller.dart';
import 'package:GetYourInvoice/screen/screen.dart';
import 'package:GetYourInvoice/services/remote_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../screen/auth/ConnectAppSheetScreen.dart';
import '../utils/utils.dart';

class SplashController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    goToNext();
  }

  void goToNext() async {
    // Show splash for minimum 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    final user = _auth.currentUser;

    // ✅ Step 1: User not logged in
    if (user == null) {
      print("No user logged in → AuthScreen");
      Get.offAllNamed(AuthScreen.pageId);
      return;
    }

    // ✅ Save userId
    await AppConstants.setUserId(user.uid);
    print("Logged-in User: ${user.uid} | Email: ${user.email}");

    try {
      // ✅ Step 1.5: Check and load demo status
      await _checkAndLoadDemoStatus(user.uid);

      // ✅ Step 2: Check if company exists
      final companies = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (companies.docs.isEmpty) {
        print("No company found → CompanyRegistrationScreen");
        Get.offAllNamed(CompanyRegistrationScreen.pageId);
        return;
      }

      final companyDoc = companies.docs.first;
      final companyId = companyDoc.id;
      final companyData = companyDoc.data();

      await AppConstants.setCompanyId(companyId);
      print("Company found → ID: $companyId");

      // ============================================================
      // ✅ NEW: GET, PRINT AND SAVE COMPANY NAME
      // ============================================================
      String fetchedCompanyName = companyData['companyName'] ?? "";

      print("🏢-----------------------------------");
      print("🏢 FETCHED COMPANY NAME: $fetchedCompanyName");
      print("🏢-----------------------------------");

      if (fetchedCompanyName.isNotEmpty) {
        await AppConstants.setCompanyName(fetchedCompanyName);
      }
      // ============================================================

      // ✅ Load company settings
      await loadCompanySettingsFromData(companyData);

      // ✅ Step 3: Check spreadsheet
      final userDoc = await _firestore.collection("users").doc(user.uid).get();

      if (!userDoc.exists) {
        print("User document missing → CompanyRegistrationScreen");
        Get.offAllNamed(CompanyRegistrationScreen.pageId);
        return;
      }

      final userData = userDoc.data() ?? {};
      final spreadsheetId = userData['spreadsheetId'] as String?;

      if (spreadsheetId != null && spreadsheetId.isNotEmpty) {
        await sharedPreferencesHelper.storePrefData("spreadsheetId", spreadsheetId);
        AppConstants.spreadsheetId = spreadsheetId;

        print("✅ Spreadsheet found → $spreadsheetId");

        // Ensure Item, Customer, Invoice etc. tabs exist (auto-create if only Sheet1)
        try {
          await GoogleSheetService.ensureSheetsExist();
        } catch (e) {
          print("⚠️ ensureSheetsExist on splash: $e");
        }

        // ✅ CRITICAL: Validate and print columns
        await _validateAndPrintColumns();

        // Go to dashboard
        print("✅ Navigating to Dashboard");
        Get.offAllNamed(DashboardScreen.pageId);
      }
      else {
        print("Company exists but no Spreadsheet → CompanyRegistrationScreen");
        Get.offAllNamed(CompanyRegistrationScreen.pageId);
      }

    } catch (e) {
      print("Error checking company or user data: $e");
      Get.offAllNamed(CompanyRegistrationScreen.pageId);
    }
  }

  // ✅ NEW: Validate and print all Invoice columns
  Future<void> _validateAndPrintColumns() async {
    try {
      print("");
      print("🔧 Starting sheet validation and column check...");

      // Test access first
      bool hasAccess = await GoogleSheetService.testSpreadsheetAccess();

      if (!hasAccess) {
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
        return;
      }

      print("✅ Google Sheets access confirmed");

      // ✅ STEP 1: Print current columns
      print("");
      print("📋 STEP 1: Checking current Invoice sheet columns...");
      await GoogleSheetService.printInvoiceSheetColumns();

      // ✅ STEP 2: Run validation and add missing columns
      print("");
      print("📋 STEP 2: Running validation to add missing columns...");
      await GoogleSheetService.validateAndUpdateAllSheets();

      // ✅ STEP 3: Print columns again to verify
      print("");
      print("📋 STEP 3: Verifying columns after validation...");
      await GoogleSheetService.printInvoiceSheetColumns();

      print("✅ Sheet validation completed successfully");

    } catch (e, stackTrace) {
      print("⚠️ Error during sheet validation: $e");
      print("Stack trace: $stackTrace");
    }
  }

  // 🆕 Check and load demo status
  Future<void> _checkAndLoadDemoStatus(String userId) async {
    try {
      final userDoc = await _firestore
          .collection("users")
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        final isDemoUser = userData['isDemo'] == true;

        await AppConstants.setDemoMode(isDemoUser);

        if (isDemoUser) {
          print("🔒 Demo mode activated for user");
        } else {
          print("✅ Regular user mode");
        }
      }
    } catch (e) {
      print("Error checking demo status: $e");
      await AppConstants.setDemoMode(false);
    }
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

// class SplashController extends BaseController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void onInit() {
//     super.onInit();
//     goToNext();
//   }
//
//   void goToNext() async {
//     // Show splash for minimum 2 seconds (reduced from 3)
//     await Future.delayed(const Duration(seconds: 2));
//
//     final user = _auth.currentUser;
//
//     // ✅ Step 1: User not logged in
//     if (user == null) {
//       print("No user logged in → AuthScreen");
//       Get.offAllNamed(AuthScreen.pageId);
//       return;
//     }
//
//     // ✅ Save userId
//     await AppConstants.setUserId(user.uid);
//     print("Logged-in User: ${user.uid} | Email: ${user.email}");
//
//     try {
//       // ✅ Step 1.5: Check and load demo status from user document
//       await _checkAndLoadDemoStatus(user.uid);
//
//       // ✅ Step 2: Check if company exists with active filter
//       final companies = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .where('isActive', isEqualTo: true)
//           .limit(1)
//           .get();
//
//       if (companies.docs.isEmpty) {
//         print("No company found → CompanyRegistrationScreen");
//         Get.offAllNamed(CompanyRegistrationScreen.pageId);
//         return;
//       }
//
//       final companyDoc = companies.docs.first;
//       final companyId = companyDoc.id;
//       final companyData = companyDoc.data();
//
//       await AppConstants.setCompanyId(companyId);
//       print("Company found → ID: $companyId");
//
//       // ✅ Load company settings from the already fetched document
//       await loadCompanySettingsFromData(companyData);
//
//       // ✅ Step 3: Check spreadsheet (fetch user doc in parallel if needed)
//       final userDoc = await _firestore.collection("users").doc(user.uid).get();
//
//       if (!userDoc.exists) {
//         print("User document missing → CompanyRegistrationScreen");
//         Get.offAllNamed(CompanyRegistrationScreen.pageId);
//         return;
//       }
//
//       final userData = userDoc.data() ?? {};
//       final spreadsheetId = userData['spreadsheetId'] as String?;
//
//       if (spreadsheetId != null && spreadsheetId.isNotEmpty) {
//         await sharedPreferencesHelper.storePrefData("spreadsheetId", spreadsheetId);
//         AppConstants.spreadsheetId = spreadsheetId;
//
//         print("✅ Spreadsheet found → $spreadsheetId");
//
//         /// ✅ Initialize sheets in background (don't wait for it)
//         //_initializeSheetsInBackground();
//
//         // ✅ NEW: Validate and update all sheets with missing columns
//         await _validateAndInitializeSheets();
//
//         // Go to dashboard immediately
//         print("✅ Navigating to Dashboard");
//         Get.offAllNamed(DashboardScreen.pageId);
//       }
//       else {
//         print("Company exists but no Spreadsheet → CompanyRegistrationScreen");
//         Get.offAllNamed(CompanyRegistrationScreen.pageId);
//       }
//
//
//     } catch (e) {
//       print("Error checking company or user data: $e");
//       Get.offAllNamed(CompanyRegistrationScreen.pageId);
//     }
//   }
//
//   // ✅ NEW: Validate and initialize all sheets with complete logging
//   Future<void> _validateAndInitializeSheets() async {
//     try {
//       print("");
//       print("🔧 Starting sheet validation process...");
//
//       // Test access first
//       bool hasAccess = await GoogleSheetService.testSpreadsheetAccess();
//
//       if (!hasAccess) {
//         print("");
//         print("=" * 70);
//         print("⚠️ SETUP REQUIRED - GOOGLE SHEETS ACCESS");
//         print("=" * 70);
//         print("1. Open: https://docs.google.com/spreadsheets/d/${AppConstants.spreadsheetId}/edit");
//         print("2. Click 'Share' button");
//         print("3. Add as Editor: invoicesathi@invoicesathi.iam.gserviceaccount.com");
//         print("4. Restart app");
//         print("=" * 70);
//         print("");
//         return;
//       }
//
//       print("✅ Google Sheets access confirmed");
//
//       // ✅ Run comprehensive validation and update
//       await GoogleSheetService.validateAndUpdateAllSheets();
//
//       print("✅ Sheet validation completed successfully");
//
//     } catch (e, stackTrace) {
//       print("⚠️ Error during sheet validation: $e");
//       print("Stack trace: $stackTrace");
//
//       // Don't block app launch on validation errors
//       // Just log them for debugging
//     }
//   }
//
//
//   // 🆕 NEW: Check and load demo status
//   Future<void> _checkAndLoadDemoStatus(String userId) async {
//     try {
//       final userDoc = await _firestore
//           .collection("users")
//           .doc(userId)
//           .get();
//
//       if (userDoc.exists) {
//         final userData = userDoc.data() ?? {};
//         final isDemoUser = userData['isDemo'] == true;
//
//         await AppConstants.setDemoMode(isDemoUser);
//
//         if (isDemoUser) {
//           print("🔒 Demo mode activated for user");
//         } else {
//           print("✅ Regular user mode");
//         }
//       }
//     } catch (e) {
//       print("Error checking demo status: $e");
//       // Default to non-demo if error occurs
//       await AppConstants.setDemoMode(false);
//     }
//   }
//
//
//   // ✅ NEW: Initialize sheets in background without blocking navigation
//   void _initializeSheetsInBackground() async {
//     try {
//       print("🔧 Testing Google Sheets access in background...");
//       bool hasAccess = await GoogleSheetService.testSpreadsheetAccess();
//
//       if (!hasAccess) {
//         print("");
//         print("=" * 60);
//         print("⚠️ SETUP REQUIRED:");
//         print("=" * 60);
//         print("1. Open this URL:");
//         print("   https://docs.google.com/spreadsheets/d/${AppConstants.spreadsheetId}/edit");
//         print("");
//         print("2. Click 'Share' button");
//         print("");
//         print("3. Add this email as Editor:");
//         print("   invoicesathi@invoicesathi.iam.gserviceaccount.com");
//         print("");
//         print("4. Restart the app");
//         print("=" * 60);
//       } else {
//         print("✅ Access confirmed, initializing sheets...");
//         await GoogleSheetService.initializeAllSheets();
//         print("✅ Sheets initialized successfully");
//       }
//     } catch (e) {
//       print("⚠️ Error initializing sheets: $e");
//     }
//   }
//
//   // ✅ NEW: Load settings from already fetched company data
//   Future<void> loadCompanySettingsFromData(Map<String, dynamic> data) async {
//     try {
//       final isChallanEnabled = data['isChallanEnabled'] ?? false;
//       final isGstEnabled = data['isGstEnabled'] ?? false;
//       final businessType = data['businessType'] ?? 'Trading';
//       final isDueDateEnabled = data['isDueDateEnabled'] ?? false;
//       final dueDateDays = data['dueDateDays'] ?? 0;
//
//
//       // Store in SharedPreferences
//       await sharedPreferencesHelper.storeBoolPrefData('isChallanEnabled', isChallanEnabled);
//       await sharedPreferencesHelper.storeBoolPrefData('isGstEnabled', isGstEnabled);
//       await AppConstants.setBusinessType(businessType);
//       await AppConstants.setDueDateEnabled(isDueDateEnabled);
//       await AppConstants.setDueDateDays(dueDateDays is int ? dueDateDays : int.tryParse(dueDateDays.toString()) ?? 0);
//
//
//       // Update AppConstants
//       AppConstants.isChallan.value = isChallanEnabled;
//       AppConstants.withGST.value = isGstEnabled;
//
//       print("✅ Settings Loaded → Challan=$isChallanEnabled | GST=$isGstEnabled | Type=$businessType");
//     } catch (e) {
//       print("Error loading company settings: $e");
//     }
//   }
//
//   // ✅ Keep original method as fallback (if needed elsewhere)
//   Future<void> loadCompanySettings(String companyId) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       final doc = await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('companies')
//           .doc(companyId)
//           .get();
//
//       if (!doc.exists) return;
//
//       final data = doc.data() ?? {};
//       await loadCompanySettingsFromData(data);
//     } catch (e) {
//       print("Error loading company settings: $e");
//     }
//   }
// }

