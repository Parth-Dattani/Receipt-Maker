import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/constant/app_constant.dart';
import 'package:demo_prac_getx/controller/controller.dart';
import 'package:demo_prac_getx/screen/screen.dart';
import 'package:demo_prac_getx/services/remote_service.dart';
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
    // Show splash for minimum 2 seconds (reduced from 3)
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
      // ✅ Step 1.5: Check and load demo status from user document
      await _checkAndLoadDemoStatus(user.uid);

      // ✅ Step 2: Check if company exists with active filter
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

      // ✅ Load company settings from the already fetched document
      await loadCompanySettingsFromData(companyData);

      // ✅ Step 3: Check spreadsheet (fetch user doc in parallel if needed)
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

        // ✅ Initialize sheets in background (don't wait for it)
        _initializeSheetsInBackground();

        // Go to dashboard immediately
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

  // 🆕 NEW: Check and load demo status
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
      // Default to non-demo if error occurs
      await AppConstants.setDemoMode(false);
    }
  }


  // ✅ NEW: Initialize sheets in background without blocking navigation
  void _initializeSheetsInBackground() async {
    try {
      print("🔧 Testing Google Sheets access in background...");
      bool hasAccess = await GoogleSheetService.testSpreadsheetAccess();

      if (!hasAccess) {
        print("");
        print("=" * 60);
        print("⚠️ SETUP REQUIRED:");
        print("=" * 60);
        print("1. Open this URL:");
        print("   https://docs.google.com/spreadsheets/d/${AppConstants.spreadsheetId}/edit");
        print("");
        print("2. Click 'Share' button");
        print("");
        print("3. Add this email as Editor:");
        print("   invoicesathi@invoicesathi.iam.gserviceaccount.com");
        print("");
        print("4. Restart the app");
        print("=" * 60);
      } else {
        print("✅ Access confirmed, initializing sheets...");
        await GoogleSheetService.initializeAllSheets();
        print("✅ Sheets initialized successfully");
      }
    } catch (e) {
      print("⚠️ Error initializing sheets: $e");
    }
  }

  // ✅ NEW: Load settings from already fetched company data
  Future<void> loadCompanySettingsFromData(Map<String, dynamic> data) async {
    try {
      final isChallanEnabled = data['isChallanEnabled'] ?? false;
      final isGstEnabled = data['isGstEnabled'] ?? false;
      final businessType = data['businessType'] ?? 'Trading';
      final isDueDateEnabled = data['isDueDateEnabled'] ?? false;
      final dueDateDays = data['dueDateDays'] ?? 0;


      // Store in SharedPreferences
      await sharedPreferencesHelper.storeBoolPrefData('isChallanEnabled', isChallanEnabled);
      await sharedPreferencesHelper.storeBoolPrefData('isGstEnabled', isGstEnabled);
      await AppConstants.setBusinessType(businessType);
      await AppConstants.setDueDateEnabled(isDueDateEnabled);
      await AppConstants.setDueDateDays(dueDateDays is int ? dueDateDays : int.tryParse(dueDateDays.toString()) ?? 0);


      // Update AppConstants
      AppConstants.isChallan.value = isChallanEnabled;
      AppConstants.withGST.value = isGstEnabled;

      print("✅ Settings Loaded → Challan=$isChallanEnabled | GST=$isGstEnabled | Type=$businessType");
    } catch (e) {
      print("Error loading company settings: $e");
    }
  }

  // ✅ Keep original method as fallback (if needed elsewhere)
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

/// working but Some Flow Chage for AppConst + S.p 26-09   4:07
// class SplashController extends BaseController{
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void onInit() {
//     super.onInit();
//     goToNext();
//   }
//
//   // void goToNext() async {
//   //   await Future.delayed(const Duration(seconds: 3)); // splash delay
//   //
//   //   // Get userId from shared preferences
//   //   String? userId = await sharedPreferencesHelper.getPrefData("userId");
//   //
//   //   print("---------usrID: ------- ${userId}");
//   //   if (userId != null && userId.isNotEmpty) {
//   //     // User already logged in → go to Home
//   //     Get.offAllNamed(CompanyRegistrationScreen.pageId);
//   //   } else {
//   //     // Not logged in → go to Auth
//   //     Get.offAllNamed(AuthScreen.pageId);
//   //   }
//   // }
//
//   ///After QE
//   // void goToNext2() async {
//   //   await Future.delayed(const Duration(seconds: 3));
//   //
//   //   final user = FirebaseAuth.instance.currentUser;
//   //
//   //   // Check if user is null FIRST before using it
//   //   if (user == null) {
//   //     print("No user logged in, going to auth screen");
//   //     Get.offAllNamed(AuthScreen.pageId);
//   //     return;
//   //   }
//   //
//   //   print("-=-=-========:User:----${user.uid}----");
//   //   String userId = user.uid;
//   //   String useremail = user.email!;
//   //   AppConstants.userId = userId;
//   //   print("-=-=-========:User:-Email--$useremail----");
//   //
//   //   try {
//   //     // Check if company exists - using the correct collection structure
//   //     final companies = await FirebaseFirestore.instance
//   //         .collection("users")
//   //         .doc(user.uid)
//   //         .collection("companies")
//   //         .limit(1)
//   //         .get();
//   //     print("Companies query result: ${companies.docs.length} companies found");
//   //
//   //     if (companies.docs.isEmpty) {
//   //       // No company → go to company registration
//   //       print("No company found, going to company registration");
//   //       Get.offAllNamed(CompanyRegistrationScreen.pageId);
//   //       return;
//   //     }
//   //
//   //     final companyId = companies.docs.first.id;
//   //     final companyData = companies.docs.first.data();
//   //
//   //     await sharedPreferencesHelper.storePrefData("CompanyId", companyId);
//   //     print("----Cmp Id---Splash: ${companyId}");
//   //
//   //     // Check if user already has an AppSheet ID
//   //     final userDoc = await FirebaseFirestore.instance
//   //         .collection("users")
//   //         .doc(user.uid)
//   //         .get();
//   //
//   //     final hasAppSheetId = userDoc.exists && userDoc.data()?.containsKey('appSheetAppId') == true;
//   //
//   //     if (hasAppSheetId) {
//   //       // User already has AppSheet connected → go to dashboard
//   //       print("AppSheet already connected, going to dashboard");
//   //       Get.offAllNamed(DashboardScreen.pageId);
//   //     } else {
//   //       // User needs to connect AppSheet
//   //       print("No AppSheet connection found, redirecting to ConnectAppSheetScreen");
//   //       Get.offAll(() => ConnectAppSheetScreen());
//   //     }
//   //   } catch (e) {
//   //     print("Error checking company: $e");
//   //     // If there's an error (like permission denied), go to company registration
//   //     Get.offAllNamed(CompanyRegistrationScreen.pageId);
//   //   }
//   // }
//   //
//   ///
//   void goToNext2009() async {
//     await Future.delayed(const Duration(seconds: 3));
//
//     final user = FirebaseAuth.instance.currentUser;
//
//     // Check if user is null FIRST before using it
//     if (user == null) {
//       print("No user logged in, going to auth screen");
//       Get.offAllNamed(AuthScreen.pageId);
//       return;
//     }
//
//     print("-=-=-========:User:----${user.uid}----");
//     String userId = user.uid;
//     String useremail = user.email!;
//     AppConstants.userId = userId;
//     print("-=-=-========:User:-Email--$useremail----");
//
//
//     // if(useremail == null){
//     //   print("Nio Usseer0000");
//     //   throw Exception('No user logged in');
//     // }
//     // String? appId = await RemoteService.getUserAppId(useremail);
//     //
//     // print("apppapapa ID: -----------${appId}");
//     // // If not found locally, try to get from backend
//     // if (appId == null) {
//     //   //appId = await UserAppIdService.getUserAppId(currentUser);
//     //
//     //   if (appId != null) {
//     //     // Cache it locally for faster access
//     //     await RemoteService.saveUserAppId(useremail, appId);
//     //   }
//     // }
//
//     try {
//       // Check if company exists - using the correct collection structure
//       final companies = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .limit(1)
//           .get();
//       print("Companies query result: ${companies.docs.length} companies found");
//
//       if (companies.docs.isEmpty) {
//         // No company → go to company registration
//         print("No company found, going to company registration");
//         Get.offAllNamed(CompanyRegistrationScreen.pageId);
//         return;
//       }
//
//       final companyId = companies.docs.first.id;
//       final companyData = companies.docs.first.data();
//
//       await sharedPreferencesHelper.storePrefData("CompanyId", companyId);
//       print("----Cmp Id---Splash: ${companyId}");
//
//
//       // Check if user has AppSheet credentials in their document
//       final userDoc = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .get();
//
//
//       loadCompanySettings(companyId);
//
//       if (userDoc.exists) {
//         final userData = userDoc.data()!;
//         // final hasAppId = userData.containsKey('appId') &&
//         //     userData['appId'] != null;
//         // final hasAccessKey = userData.containsKey('accessKey') &&
//         //     userData['accessKey'] != null;
//         final hasSpreadsheetId = userData.containsKey('spreadsheetId') &&
//             userData['spreadsheetId'] != null;
//
//         // print("User has AppSheet App ID: $hasAppId");
//         // print("User has AppSheet Access Key: $hasAccessKey");
//         print("User has AppSheet SpreadsheetId  Key: $hasSpreadsheetId");
//
//         if (hasSpreadsheetId) {
//           // Store AppSheet credentials in shared preferences for easy access
//           await sharedPreferencesHelper.storePrefData(
//               "appSheetAppId", userData['appId']);
//           await sharedPreferencesHelper.storePrefData(
//               "appSheetAccessKey", userData['accessKey']);
//
//           await sharedPreferencesHelper.storePrefData(
//               "spreadsheetId", userData['spreadsheetId']);
//
//           AppConstants.appId =  userData['appId'].toString();
//           AppConstants.accessKey = userData['accessKey'].toString();
//           AppConstants.spreadsheetId = userData['spreadsheetId'].toString();
//
//
//           // Both company and AppSheet credentials exist → go to dashboard
//           print("Company and AppSheet credentials found, going to dashboard:--- ${AppConstants.appId}-----${AppConstants.accessKey}");
//           Get.offAllNamed(DashboardScreen.pageId);
//         }
//         else {
//           // Company exists but no AppSheet credentials → go to AppSheet connection screen
//           print("Company found but no AppSheet credentials, redirecting to ConnectAppSheetScreen");
//
//           ///Get.offAll(() => ConnectAppSheetScreen());
//         }
//         // Both company exists → go to dashboard
//         print("Company found, going to dashboard");
//         Get.offAllNamed(DashboardScreen.pageId);
//       } } catch (e) {
//       print("Error checking company: $e");
//       // If there's an error (like permission denied), go to company registration
//       Get.offAllNamed(CompanyRegistrationScreen.pageId);
//     }
//   }
//
//   void goToNext() async {
//     await Future.delayed(const Duration(seconds: 3));
//
//     final user = FirebaseAuth.instance.currentUser;
//
//     // ✅ Step 1: User not logged in → go to Auth screen
//     if (user == null) {
//       print("No user logged in, going to auth screen");
//       Get.offAllNamed(AuthScreen.pageId);
//       return;
//     }
//
//     print("Logged-in User: ${user.uid} | Email: ${user.email}");
//     AppConstants.userId = user.uid;
//
//     try {
//       // ✅ Step 2: Check if company exists
//       final companies = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .limit(1)
//           .get();
//
//       if (companies.docs.isEmpty) {
//         print("No company found, going to company registration");
//         Get.offAllNamed(CompanyRegistrationScreen.pageId);
//         return;
//       }
//
//       final companyId = companies.docs.first.id;
//       await sharedPreferencesHelper.storePrefData("CompanyId", companyId);
//       print("Company found → ID: $companyId");
//
//       /// Load company settings (like challan flag)
//       await loadCompanySettings(companyId);
//
//       /// ✅ Step 3: Check if user has AppSheet credentials
//       final userDoc = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .get();
//
//       if (!userDoc.exists) {
//         print("User document missing → go to ConnectAppSheetScreen");
//         //Get.offAll(() => ConnectAppSheetScreen());
//         return;
//       }
//
//       final userData = userDoc.data() ?? {};
//       final hasSpreadsheetId = userData['spreadsheetId'] != null;
//
//       if (hasSpreadsheetId) {
//         // Save AppSheet credentials in local storage
//         // await sharedPreferencesHelper.storePrefData("appSheetAppId", userData['appId']);
//         // await sharedPreferencesHelper.storePrefData("appSheetAccessKey", userData['accessKey']);
//         await sharedPreferencesHelper.storePrefData("spreadsheetId", userData['spreadsheetId']);
//
//         // AppConstants.appId = userData['appId'].toString();
//         // AppConstants.accessKey = userData['accessKey'].toString();
//         AppConstants.spreadsheetId = userData['spreadsheetId'].toString();
//
//         print("✅ Company + AppSheet credentials found → going to Dashboard");
//         print("SperdSheetID----: ${AppConstants.spreadsheetId}");
//         Get.offAllNamed(DashboardScreen.pageId);
//       } else {
//         print("Company exists but no AppSheet credentials → redirecting to ConnectAppSheetScreen");
//        // Get.offAll(() => ConnectAppSheetScreen());
//       }
//     } catch (e) {
//       print("Error checking company or user data: $e");
//       Get.offAllNamed(CompanyRegistrationScreen.pageId);
//     }
//   }
//
//
//   // Future<void> loadCompanySettings(String companyId) async {
//   //   print("-------------cmpyID:-------${companyId}");
//   //   try {
//   //     final user = FirebaseAuth.instance.currentUser;
//   //     if (user != null) {
//   //       final doc = await FirebaseFirestore.instance
//   //           .collection('users')
//   //           .doc(user.uid)
//   //           .collection('companies')
//   //           .doc(companyId)
//   //           .get();
//   //
//   //       if (doc.exists) {
//   //         final data = doc.data();
//   //         if (data != null) {
//   //           final isChallanEnabled = data['isChallanEnabled'] ?? false;
//   //
//   //
//   //           // Update SharedPreferences and AppConstants
//   //           final prefs = await sharedPreferencesHelper.getSharedPreferencesInstance();
//   //           await prefs.storeBoolPrefData('isChallanEnabled', isChallanEnabled);
//   //           AppConstants.isChallan.value = isChallanEnabled;
//   //           print("IsssChallN-------------${isChallanEnabled}");
//   //         }
//   //         print("IsssChallN-------ccc------${AppConstants.isChallan.value}");
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print('Error loading company settings: $e');
//   //   }
//   // }
//   Future<void> loadCompanySettings(String companyId) async {
//     print("-------------cmpyID:-------${companyId}");
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('companies')
//             .doc(companyId)
//             .get();
//
//         if (doc.exists) {
//           final data = doc.data();
//           print("------------Data===============:$data");
//           if (data != null) {
//             final isChallanEnabled = data['isChallanEnabled'] ?? false;
//
//             // Use the helper method instead of getting the instance
//             await sharedPreferencesHelper.storeBoolPrefData('isChallanEnabled', isChallanEnabled);
//             AppConstants.isChallan.value = isChallanEnabled;
//             print("IsssChallN-------------${isChallanEnabled}");
//
//
//             // ✅ Get GST setting
//             final isGstEnabled = data['isGstEnabled'] ?? false;
//             await sharedPreferencesHelper.storeBoolPrefData('isGstEnabled', isGstEnabled);
//             AppConstants.withGST.value = isGstEnabled;
//             print("IsssGST-------------$isGstEnabled");
//           }
//           print("Final Challan Value ------ ${AppConstants.isChallan.value}");
//           print("Final GST Value ---------- ${AppConstants.withGST.value}");
//         }
//       }
//     } catch (e) {
//       print('Error loading company settings: $e');
//     }
//   }
//
// }

