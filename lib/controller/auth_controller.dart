import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GetYourInvoice/constant/app_colors.dart';
import 'package:GetYourInvoice/controller/bash_controller.dart';
import 'package:GetYourInvoice/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constant/constant.dart';
import '../utils/financial_year_helper.dart';
import 'dashboard_controller.dart';
import '../screen/screen.dart';
import '../services/remote_service.dart';
import '../widgets/custom_snackbar.dart';


class AuthController extends BaseController with GetSingleTickerProviderStateMixin {
  var currentTabIndex = 0.obs;
  var _isDisposed = false;

  late TabController tabController;

  // Login form controllers
  final TextEditingController loginUsernameController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  var isPasswordHidden = true.obs;
  var rememberMe = false.obs;

  // Registration form controllers
  final TextEditingController regUsernameController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regMobile1Controller = TextEditingController();
  final TextEditingController regMobile2Controller = TextEditingController();
  final TextEditingController regAddressController = TextEditingController();
  final TextEditingController regCityController = TextEditingController();
  // final TextEditingController regStateController = TextEditingController();
  // final TextEditingController regCountryController = TextEditingController();
  final TextEditingController regAltEmailController = TextEditingController();

  // Add AppSheet URL controller
  final TextEditingController appSheetUrlController = TextEditingController();
  var selectedCountry = ''.obs;
  var selectedState = ''.obs;
  var isDemo = false.obs;

  /// Financial year list and active FY (for Settings screen).
  var fyList = <String>[].obs;
  var activeFyValue = ''.obs;
  var isLoadingFy = false.obs;

  final RxInt tapCount = 0.obs;
  final RxBool showFormFields = false.obs;
  Timer? _tapTimer;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      //if (!_isDisposed) {
        currentTabIndex.value = tabController.index;
     // }
    });
  }

  @override
  void onClose() {
    _isDisposed = true;
    appSheetUrlController.dispose();
    // tabController.removeListener(() {});
     tabController.dispose();
    // Dispose all controllers
    loginUsernameController.dispose();
    loginPasswordController.dispose();
    regUsernameController.dispose();
    regEmailController.dispose();
    regMobile1Controller.dispose();
    regMobile2Controller.dispose();
    regAddressController.dispose();
    regCityController.dispose();
    // regStateController.dispose();
    // regCountryController.dispose();
    regAltEmailController.dispose();
    _tapTimer?.cancel();
    super.onClose();
  }

  // Add these lists for dropdown data
  final List<String> countries = ['USA', 'Canada', 'India', 'UK', 'Australia'];

  final Map<String, List<String>> countryStates = {
    'India': [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
      'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
      'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
      'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi',
      'Jammu and Kashmir', 'Ladakh',
    ],
    'United States': [
      'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
      'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
      'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
      'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
      'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
      'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
      'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
      'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
      'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
      'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming',
    ],
    'United Kingdom': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
    'Canada': [
      'Alberta', 'British Columbia', 'Manitoba', 'New Brunswick',
      'Newfoundland and Labrador', 'Northwest Territories', 'Nova Scotia',
      'Nunavut', 'Ontario', 'Prince Edward Island', 'Quebec',
      'Saskatchewan', 'Yukon',
    ],
    'Australia': [
      'New South Wales', 'Victoria', 'Queensland', 'Western Australia',
      'South Australia', 'Tasmania', 'Australian Capital Territory',
      'Northern Territory',
    ],
  };

  // Add this method to get states for selected country
  List<String> getStatesForCountry() {
    if (selectedCountry.value.isEmpty) {
      return [];
    }
    return countryStates[selectedCountry.value] ?? [];
  }

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";

  void handleRegisterTabTap() {
    tabController.animateTo(1);
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // AppSheet connection method
  Future<void> connectAppSheet() async {
    final String url = appSheetUrlController.text.trim();
    final String? appId = _extractAppIdFromUrl(url);

    if (appId == null) {
      showCustomSnackbar(
        title: "Error===========",
        message: "Could not find an App ID in this URL. Please check the link.",
        baseColor: AppColors.errorColor,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Validate the App ID (optional but recommended)
      final bool isValid = await _validateAppId(appId);

      if (!isValid) {
        showCustomSnackbar(
          title: "Error,,,,,,",
          message: "This App ID appears to be invalid or inaccessible.",
          baseColor: AppColors.errorColor,
          icon: Icons.error_outline,
        );
        return;
      }

      // Get current user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showCustomSnackbar(
          title: "Error--------",
          message: "You must be logged in to connect an app.",
          baseColor: AppColors.errorColor,
          icon: Icons.error_outline,
        );
        return;
      }

      // Save the App ID to the user's document in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        'appSheetAppId': appId,
        'appSheetAppUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      showCustomSnackbar(
        title: "Success",
        message: "AppSheet app connected successfully!",
        baseColor: AppColors.greenColor2,
        icon: Icons.check_circle,
      );

      // Clear the input field
      appSheetUrlController.clear();

      // Navigate back or to next screen
      Get.back();

    } catch (e) {
      showCustomSnackbar(
        title: "Error.......",
        message: "An error occurred: ${e.toString()}",
        baseColor: AppColors.errorColor,
        icon: Icons.error_outline,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? _extractAppIdFromUrl(String url) {
    // Regular expression to match AppSheet URLs
    final RegExp appIdRegExp = RegExp(
      r'(?:appsheet\.com/start/|appId=)([a-zA-Z0-9\-]+)',
      caseSensitive: false,
    );

    Match? match = appIdRegExp.firstMatch(url);
    return match?.group(1);
  }

  Future<bool> _validateAppId(String appId) async {
    // This is optional but recommended to ensure the App ID is correct
    try {
      // Try to make a simple API call to validate the App ID
      // You'll need to add your AppSheet Application Access Key
      const String testApplicationAccessKey = 'YOUR_APPSHEET_APPLICATION_ACCESS_KEY';

      // If you don't have an access key, you can skip validation
      if (testApplicationAccessKey == 'YOUR_APPSHEET_APPLICATION_ACCESS_KEY') {
        return true; // Skip validation if key not configured
      }

      // Make a test API call
      // This would require the http package and proper error handling
      // For simplicity, we'll just return true in this example
      return true;

    } catch (e) {
      // If validation fails, you might want to return false
      // For this example, we'll return true to allow the flow to continue
      return true;
    }
  }


  // -----------------------------------------------------------------------
  // 1. UPDATED HANDLE LOGIN
  // -----------------------------------------------------------------------
  void handleLogin() async {
    // Trim removes spaces from start/end
    String email = loginUsernameController.text.trim();
    String password = loginPasswordController.text.trim();

    // ✅ VALIDATION STEP: Check fields before doing anything else
    if (!_validateLoginForm(email, password)) {
      return; // Stop here if validation fails
    }

    try {
      if (_isDisposed) return;
      isLoading.value = true;

      // Sign in user
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (_isDisposed) return;

      // Success Message
      showNativeSnackbar(
        title: "Success",
        message: "Login successful!",
        isError: false,
      );

      // Store basic user info in shared preferences
      final currentUser = _auth.currentUser!;
      await AppConstants.setUserId(currentUser.uid);
      await sharedPreferencesHelper.storePrefData("email", currentUser.email ?? "");

      /// Try to get user document from Firestore
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .get();

        print("userData: ${userDoc.exists ? 'Exists' : 'Does not exist'}");

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final username = userDoc["username"] ?? "";
          final hasSpreadsheetId = userData.containsKey('spreadsheetId') &&
              userDoc['spreadsheetId'] != null;

          await sharedPreferencesHelper.storePrefData("username", username);

          if (hasSpreadsheetId) {
            await sharedPreferencesHelper.storePrefData(
                "spreadsheetId", userData['spreadsheetId']);
            AppConstants.spreadsheetId = userData['spreadsheetId'].toString();
            // Auto-create Item, Customer, Invoice etc. tabs if missing
            try {
              await GoogleSheetService.ensureSheetsExist();
            } catch (e) {
              print('ensureSheetsExist after email login: $e');
            }
          }
          print("Username stored: $username");
        } else {
          print("User document does not exist in Firestore");
          await _createUserDocument(currentUser);
        }
      } catch (e) {
        print("Warning: Could not fetch user data from Firestore: $e");
      }

      // Check company registration and navigate accordingly
      await _checkAndNavigateAfterLogin();

    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors (wrong password, user not found)
      // Firebase Error
      showNativeSnackbar(
        title: "Login Failed",
        message: e.message ?? "Authentication failed",
        isError: true,
      );
    } catch (e) {
      print("Unexpected error during login: $e");
      showNativeSnackbar(
        title: "Error",
        message: "An unexpected error occurred",
        isError: true,
      );
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // -----------------------------------------------------------------------
  // 2. UPDATED VALIDATION LOGIC (Add this to your Controller)
  // -----------------------------------------------------------------------
  bool _validateLoginForm(String email, String password) {
    // Check Empty Email
    if (email.isEmpty) {
      showNativeSnackbar(
        title: "Required",
        message: "Please enter your email address",
        isError: true,
      );
      return false;
    }

    // Check Email Format
    if (!GetUtils.isEmail(email)) {
      showNativeSnackbar(
        title: "Invalid Email",
        message: "Please enter a valid email address",
        isError: true,
      );
      return false;
    }

    // Check Empty Password
    if (password.isEmpty) {
      showNativeSnackbar(
        title: "Required",
        message: "Please enter your password",
        isError: true,
      );
      return false;
    }

    return true; // Validation Passed
  }

  /// Get current Google access token if user has an active Google session (for creating FY sheet in user's Drive).
  Future<String?> getGoogleAccessToken() async {
    try {
      final String? serverClientId = AppConstants.googleWebClientId.isNotEmpty ? AppConstants.googleWebClientId : null;
      final String? webClientId = kIsWeb ? (AppConstants.googleWebClientId.isNotEmpty ? AppConstants.googleWebClientId : null) : null;
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/drive.file', 'https://www.googleapis.com/auth/spreadsheets'],
        serverClientId: serverClientId,
        clientId: webClientId,
      );
      final GoogleSignInAccount? account = await googleSignIn.signInSilently();
      if (account == null) return null;
      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.accessToken;
    } catch (_) {
      return null;
    }
  }

  /// Sign in with Google – same post-login flow as email/password (current flow remains).
  Future<void> handleGoogleSignIn() async {
    try {
      if (_isDisposed) return;
      isLoading.value = true;

      // Web: serverClientId required. Android: use Web client ID so Firebase accepts the idToken.
      final String? serverClientId = AppConstants.googleWebClientId.isNotEmpty
          ? AppConstants.googleWebClientId
          : null;
      if (kIsWeb && (serverClientId == null || serverClientId.isEmpty)) {
        if (!_isDisposed) isLoading.value = false;
        showNativeSnackbar(
          title: "Setup required",
          message: "Google Sign-In on web needs Web client ID in app_constant.dart",
          isError: true,
        );
        return;
      }

      // Clear any previous sign-in state (helps on web and Android when login was cancelled or failed before)
      // On web, clientId is required so the account picker opens; otherwise plugin can throw null check.
      final String? webClientId = kIsWeb ? (AppConstants.googleWebClientId.isNotEmpty ? AppConstants.googleWebClientId : null) : null;
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/spreadsheets',
        ],
        serverClientId: serverClientId,
        clientId: webClientId, // Required on web for account picker / sign-in flow
      );
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (!_isDisposed) isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      if (idToken == null && accessToken == null) {
        if (!_isDisposed) isLoading.value = false;
        showNativeSnackbar(
          title: "Google sign-in failed",
          message: "No token received from Google. Try again or use email login.",
          isError: true,
        );
        return;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      await _auth.signInWithCredential(credential);

      // Save token for Company Registration to ensure InvoiceSathi folder creation
      if (accessToken != null) {
        AppConstants.googleAccessToken = accessToken;
      }

      if (_isDisposed) return;

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (!_isDisposed) {
          showNativeSnackbar(
            title: "Error",
            message: "Sign-in completed but no user. Try again.",
            isError: true,
          );
        }
        return;
      }

      showNativeSnackbar(
        title: "Success",
        message: "Signed in with Google successfully!",
        isError: false,
      );

      await AppConstants.setUserId(currentUser.uid);
      await sharedPreferencesHelper.storePrefData("email", currentUser.email ?? "");

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .get();

        final userData = userDoc.data();
        final hasSpreadsheetId = userData != null &&
            userData['spreadsheetId'] != null &&
            (userData['spreadsheetId'].toString().trim().isNotEmpty);

        // Google login: no sheet is created here anymore. It's moved to Company Registration.

        if (userDoc.exists) {
          if (userData != null) {
            final username = userData["username"]?.toString() ?? "";
            await sharedPreferencesHelper.storePrefData("username", username);
            if (hasSpreadsheetId) {
              await sharedPreferencesHelper.storePrefData(
                  "spreadsheetId", userData['spreadsheetId']);
              AppConstants.spreadsheetId =
                  userData['spreadsheetId'].toString();
              await Future.delayed(const Duration(seconds: 3));

              try {
                await GoogleSheetService.ensureSheetsExist();
              } catch (e) {
                print('ensureSheetsExist (Google existing sheet) first try: $e');
                await Future.delayed(const Duration(seconds: 3));
                try {
                  await GoogleSheetService.ensureSheetsExist();
                } catch (e2) {
                  print(
                      'ensureSheetsExist (Google existing sheet) retry failed: $e2');
                  if (!_isDisposed) {
                    showNativeSnackbar(
                      title: "Sheet tables not created",
                      message: _sheetFailureMessage(e2),
                      isError: true,
                    );
                  }
                }
              }
            }
          }
        } else if (AppConstants.spreadsheetId.isEmpty) {
          await _createUserDocument(currentUser);
        }
      } catch (e) {
        print("Warning: Could not fetch user data from Firestore: $e");
      }

      await _checkAndNavigateAfterLogin();
    } on FirebaseAuthException catch (e) {
      if (!_isDisposed) {
        showNativeSnackbar(
          title: "Google sign-in failed",
          message: e.message ?? e.code,
          isError: true,
        );
      }
      print("Google sign-in FirebaseAuthException: ${e.code} ${e.message}");
    } catch (e, stack) {
      print("Google sign-in error: $e\n$stack");
      if (!_isDisposed) {
        String displayMsg = "Could not sign in with Google. Try again.";
        if (e is PlatformException) {
          if (e.code == '10') {
            displayMsg = "Error 10: Add Android client ID from other project in Firebase → Auth → Google → Whitelist client IDs.";
          } else {
            displayMsg = e.message ?? e.code;
          }
        } else {
          final String msg = e.toString();
          if (msg.contains("10") || msg.contains("DEVELOPER_ERROR") || msg.contains("ApiException")) {
            displayMsg = "Error 10: Add Android client ID from other project in Firebase → Auth → Google → Whitelist client IDs.";
          } else if (msg.contains("sign_in_failed") || msg.contains("SIGN_IN_FAILED")) {
            displayMsg = "Sign-in failed. Add SHA-1 in Firebase Project settings → Your apps.";
          } else {
            final String raw = msg.replaceFirst("Exception: ", "").replaceFirst("PlatformException(", "");
            displayMsg = raw.length > 100 ? "${raw.substring(0, 97)}..." : raw;
          }
        }
        showNativeSnackbar(
          title: "Error",
          message: displayMsg,
          isError: true,
        );
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _createUserDocument(User user, {String? spreadsheetId}) async {
    try {
      final data = {
        'userId': user.uid,
        'email': user.email,
        'username': user.displayName ?? user.email?.split('@').first ?? 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': false,
      };
      if (spreadsheetId != null && spreadsheetId.isNotEmpty) {
        data['spreadsheetId'] = spreadsheetId;
        final fy = FinancialYearHelper.currentFy();
        data['activeFy'] = fy;
        data['spreadsheetIdsByFy'] = {fy: spreadsheetId};
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(data);
      print("User document created for ${user.uid}");
    } catch (e) {
      print("Error creating user document: $e");
    }
  }

  // -----------------------------------------------------------------------
  // 3. NEW HELPER: Native Snackbar (Guaranteed to show)
  // -----------------------------------------------------------------------
  String _sheetFailureMessage(Object e) {
    if (GoogleSheetService.isProjectDeletedError(e)) {
      return GoogleSheetService.projectDeletedUserMessage;
    }
    return "Open the sheet in Drive → Share → Add ${AppConstants.serviceAccountEmailForDisplay} as Editor, then sign in again.";
  }

  void showNativeSnackbar({required String title, required String message, required bool isError}) {
    final BuildContext? ctx = Get.context;
    if (ctx == null) {
      print("⚠️ Context is null, cannot show snackbar: $message");
      return;
    }
    try {
      ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(message, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating, // Floats above bottom nav/fab
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("⚠️ Snackbar error: $e");
    }
  }

  // Registration methods demo for Api
  void handleRegistrationApi() async {
    if (!_validateRegistrationForm()) {
      return;
    }

    try {
      if (_isDisposed) return;
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Check if controller is still active before proceeding
      if (_isDisposed) return;

      // Add your registration logic here
      showCustomSnackbar(
        title: "Success",
        message: "Registration successful!",
        baseColor: AppColors.greenColor2,
        icon: Icons.done_all,
      );

      // Clear form after successful registration
      _clearRegistrationForm();

      // Switch to login tab only if controller is still active
      if (!_isDisposed && tabController.index != 0) {
        tabController.animateTo(0);
      }

    } catch (error) {
      if (!_isDisposed) {
        showCustomSnackbar(
          title: "Error--------",
          message: "Registration failed: ${error.toString()}",
          baseColor: AppColors.errorColor,
          icon: Icons.sms_failed_outlined,
        );
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  void handleRegistration() async {
    if (!_validateRegistrationForm()) return;

    final email = regEmailController.text.trim();
    final password = loginPasswordController.text.trim(); // you can add a password field in Register form

    UserCredential? userCred;

    try {
      if (_isDisposed) return;
      isLoading.value = true;

      // Create user with Firebase Auth
      userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_isDisposed) return;

      // Save user data to Firestore
      await _saveUserDataWithRetry(userCred.user!.uid, spreadsheetId: '');

      if (_isDisposed) return;

      showNativeSnackbar(
        title: "Success",
        message: "Registration successful!",
        isError: false,
      );

      await AppConstants.setUserId(userCred.user!.uid);
      //await sharedPreferencesHelper.storePrefData("userId", userCred.user!.uid);
      await sharedPreferencesHelper.storePrefData("email", email);
      await sharedPreferencesHelper.storePrefData("username", regUsernameController.text.trim());

      AppConstants.userId = userCred.user!.uid  ;
      _clearRegistrationForm();
      // Navigate to company registration for new users
      Get.offAllNamed(CompanyRegistrationScreen.pageId);

      // Switch back to login tab
      if (!_isDisposed && tabController.index != 0) {
        tabController.animateTo(0);
      }

    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      if (!_isDisposed) {
        showNativeSnackbar(
          title: "Registration Failed",
          message: e.message ?? "Could not register user",
          isError: true,
        );
      }
    } catch (e) {
      // Handle Firestore or other errors
      if (!_isDisposed) {
        String errorMessage = "Registration failed";

        if (e.toString().contains("cloud_firestore") ||
            e.toString().contains("Unable to establish connection")) {
          errorMessage = "User created but profile data couldn't be saved. Please check your internet connection and try logging in.";
        }

        showNativeSnackbar(
          title: "Error",
          message: errorMessage,
          isError: true,
        );

        // If user was created but Firestore failed, still consider it partial success
        if (userCred?.user != null) {
          showNativeSnackbar(
            title: "Info",
            message: "Account created successfully. You can login now.",
            isError: false,
          );

          _clearRegistrationForm();
          if (!_isDisposed && tabController.index != 0) {
            tabController.animateTo(0);
          }
        }
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

// Helper method to save user data with retry logic
  Future<void> _saveUserDataWithRetry(String uid, {int maxRetries = 3, String spreadsheetId = ''}) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .set({
          "username": regUsernameController.text.trim(),
          "email": regEmailController.text.trim(),
          "mobile1": regMobile1Controller.text.trim(),
          "mobile2": regMobile2Controller.text.trim(),
          "address": regAddressController.text.trim(),
          "city": regCityController.text.trim(),
          "state": selectedState.value,
          "country": selectedCountry.value,
          "altEmail": regAltEmailController.text.trim(),
          "createdAt": FieldValue.serverTimestamp(),
          "endDate": DateTime.now().add(const Duration(days: 5000)),
          "appId":"",
          "spreadsheetId": spreadsheetId,
          "isDemo": isDemo.value,
          "isActive": false,
          if (spreadsheetId.isNotEmpty) "activeFy": FinancialYearHelper.currentFy(),
          if (spreadsheetId.isNotEmpty) "spreadsheetIdsByFy": {FinancialYearHelper.currentFy(): spreadsheetId},
        });

        // If successful, break out of retry loop
        return;

      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          // If all retries failed, rethrow the error
          throw e;
        }

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }

// Alternative method to save user data later if initial save fails
  Future<void> retryUserDataSave() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;

      // Check if user data already exists
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Save the data if it doesn't exist
        await _saveUserDataWithRetry(user.uid);

        showCustomSnackbar(
          title: "Success",
          message: "Profile data saved successfully!",
          baseColor: AppColors.greenColor2,
          icon: Icons.done_all,
        );
      } else {
        showCustomSnackbar(
          title: "Info",
          message: "Profile data already exists",
          baseColor: AppColors.appColor,
          icon: Icons.info,
        );
      }

    } catch (e) {
      showCustomSnackbar(
        title: "Error----",
        message: "Failed to save profile data: ${e.toString()}",
        baseColor: AppColors.errorColor,
        icon: Icons.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateRegistrationForm() {
    String username = regUsernameController.text.trim();
    String email = regEmailController.text.trim();
    String mobile1 = regMobile1Controller.text.trim();
    String city = regCityController.text.trim();
    String state = selectedState.value;
    String country = selectedCountry.value;

    if (username.isEmpty) {
      showNativeSnackbar(title: "Required", message: "Full Name is required", isError: true);
      return false;
    }
    if (email.isEmpty) {
      showNativeSnackbar(title: "Required", message: "Email ID is required", isError: true);
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      showNativeSnackbar(title: "Invalid", message: "Please enter a valid email address", isError: true);
      return false;
    }

    if (mobile1.isEmpty) {
      showNativeSnackbar(title: "Required", message: "Mobile Number is required", isError: true);
      return false;
    }
    if (!GetUtils.isPhoneNumber(mobile1)) {
      showNativeSnackbar(title: "Invalid", message: "Please enter a valid mobile number", isError: true);
      return false;
    }
    if (city.isEmpty) {
      showNativeSnackbar(title: "Required", message: "City is required", isError: true);
      return false;
    }
    if (state.isEmpty) {
      showNativeSnackbar(title: "Required", message: "Please select your State", isError: true);
      return false;
    }
    if (country.isEmpty) {
      showNativeSnackbar(title: "Required", message: "Please select your Country", isError: true);
      return false;
    }

    return true;
  }

  void _clearRegistrationForm() {
    regUsernameController.clear();
    regEmailController.clear();
    regMobile1Controller.clear();
    regMobile2Controller.clear();
    regAddressController.clear();
    regCityController.clear();
    selectedState.value = "";
    selectedCountry.value = "";
    isDemo.value = false;
    regAltEmailController.clear();
  }

  // Mobile authentication - Fixed to not navigate immediately
  void authenticateWithMobile() async {
    try {
      if (_isDisposed) return;
      isLoading.value = true;

      // Simulate mobile authentication
      await Future.delayed(Duration(seconds: 2));

      // Check if controller is still active before proceeding
      if (_isDisposed) return;

      // Show dialog or navigate based on current context
      showCustomSnackbar(
        title: "Mobile Auth",
        message: "Mobile authentication initiated",
        baseColor: AppColors.appColor,
        icon: Icons.phone,
      );

      // Only navigate if authentication is successful
      // You can add actual mobile auth logic here
      Get.toNamed(CustomerRegistrationScreen.pageId);

    } catch (error) {
      if (!_isDisposed) {
        showCustomSnackbar(
          title: "Error+++++++",
          message: "Authentication failed: ${error.toString()}",
          baseColor: AppColors.errorColor,
          icon: Icons.error,
        );
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // Utility methods
  void switchToLoginTab() {
    if (!_isDisposed && tabController.index != 0) {
      currentTabIndex.value = 0;
      tabController.animateTo(0);
    }
  }

  void switchToRegistrationTab() {
    if (!_isDisposed && tabController.index != 1) {
      currentTabIndex.value = 1;
      tabController.animateTo(1);
    }
  }


  /// Check if user has registered a company after login
  Future<void> _checkAndNavigateAfterLogin() async {
    print("Checking company registration after login...");

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }

      print("Checking company for user: ${user.uid}");

      // Query nested companies collection under the user document
      final companyQuery = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .limit(1)
          .get();

      print("Company query successful: ${companyQuery.docs.length} documents found");


      if (companyQuery.docs.isNotEmpty) {
        final companyData = companyQuery.docs.first;
        print("Company found: ${companyData['companyName'] ?? 'Unnamed'}");

        // Store company ID for future use
        final companyId = companyData.id;
         print("Stored company ID: $companyId");
        await AppConstants.setCompanyId(companyId);
        // await sharedPreferencesHelper.storePrefData("companyId", companyId);
        // AppConstants.companyId = companyId;

        Get.offAllNamed(DashboardScreen.pageId);
      } else {
        print("No company found for user");
        Get.offAllNamed(CompanyRegistrationScreen.pageId);
      }
    } catch (e) {
      print('Error checking company registration: $e');
      Get.offAllNamed(CompanyRegistrationScreen.pageId);
    }
  }

  /// Show Forgot Password Dialog
  void showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    final RxBool dialogIsLoading = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        // ✅ વેબ માટે વિડ્થ ફિક્સ કરી (Max 450px)
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // આઈકોન અને હેડિંગ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 40,
                  color: AppColors.tealColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your registered email address to receive a password reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Email Input
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: "Email Address",
                  hintText: "example@gmail.com",
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // બટન્સ
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                          () => ElevatedButton(
                            onPressed: dialogIsLoading.value
                                ? null
                                : () async {
                              final email = emailController.text.trim();

                              // ૧. વેલિડેશન
                              if (email.isEmpty) {
                                showNativeSnackbar(
                                  title: "Required",
                                  message: "Please enter your email address",
                                  isError: true,
                                );
                                return;
                              }

                              if (!GetUtils.isEmail(email)) {
                                showNativeSnackbar(
                                  title: "Invalid Email",
                                  message: "Please enter a valid email address",
                                  isError: true,
                                );
                                return;
                              }

                              // ૨. મેઈન લોજિક (આ લાઈન તેં લખી નહોતી)
                              dialogIsLoading.value = true;
                              try {
                                await _auth.sendPasswordResetEmail(email: email);

                                dialogIsLoading.value = false;
                                Get.back(); // ડાયલોગ બંધ કરો

                                showNativeSnackbar(
                                  title: "Success",
                                  message: "Password reset link sent to your email!",
                                  isError: false,
                                );
                              } on FirebaseAuthException catch (e) {
                                dialogIsLoading.value = false;
                                showNativeSnackbar(
                                  title: "Error",
                                  message: e.message ?? "Failed to send reset link",
                                  isError: true,
                                );
                              } catch (e) {
                                dialogIsLoading.value = false;
                                showNativeSnackbar(
                                  title: "Error",
                                  message: "An unexpected error occurred",
                                  isError: true,
                                );
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: dialogIsLoading.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "Send Link",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Forgot Password - Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) {
      showCustomSnackbar(
        title: "Required",
        message: "Please enter your email address",
        baseColor: AppColors.errorColor,
        icon: Icons.error_outline,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      showCustomSnackbar(
        title: "Invalid Email",
        message: "Please enter a valid email address",
        baseColor: AppColors.errorColor,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      if (_isDisposed) return;
      isLoading.value = true;

      await _auth.sendPasswordResetEmail(email: email.trim());

      if (_isDisposed) return;

      showCustomSnackbar(
        title: "Success",
        message: "Password reset email sent! Please check your inbox.",
        baseColor: AppColors.greenColor2,
        icon: Icons.check_circle,
      );

      // Close the dialog after success
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No account found with this email address";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address format";
          break;
        case 'too-many-requests':
          errorMessage = "Too many requests. Please try again later";
          break;
        default:
          errorMessage = e.message ?? "Failed to send reset email";
      }

      if (!_isDisposed) {
        showCustomSnackbar(
          title: "Error",
          message: errorMessage,
          baseColor: AppColors.errorColor,
          icon: Icons.error,
        );
      }
    } catch (e) {
      if (!_isDisposed) {
        showCustomSnackbar(
          title: "Error",
          message: "An unexpected error occurred",
          baseColor: AppColors.errorColor,
          icon: Icons.error,
        );
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  /// Show snackbar after next frame so overlay is available (avoids crash when coming from dialog).
  void _safeSnackbar({required String title, required String message, required bool isError}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      try {
        if (Get.overlayContext != null) {
          showCustomSnackbar(
            title: title,
            message: message,
            baseColor: isError ? AppColors.errorColor : AppColors.greenColor2,
            icon: isError ? Icons.error : Icons.check_circle,
          );
        } else {
          Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM, backgroundColor: isError ? Colors.red : Colors.green);
        }
      } catch (_) {
        print('$title: $message');
      }
    });
  }

  Future<void> loadUserFyData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) return;
      final data = doc.data() ?? {};
      activeFyValue.value = (data['activeFy'] as String?) ?? AppConstants.activeFy;
      final byFy = data['spreadsheetIdsByFy'];
      if (byFy is Map) {
        fyList.assignAll(byFy.keys.map((k) => k.toString()).toList()..sort());
      } else if (activeFyValue.value.isNotEmpty) {
        fyList.assignAll([activeFyValue.value]);
      }
    } catch (e) {
      print('loadUserFyData: $e');
    }
  }

  Future<bool> addNewFinancialYear() async {
    final currentFy = AppConstants.activeFy.isNotEmpty ? AppConstants.activeFy : FinancialYearHelper.currentFy();
    final nextFy = FinancialYearHelper.nextFy(currentFy);
    return addNewFinancialYearForFy(nextFy);
  }

  /// Create a new Google Sheet for the given [fy] and set it as active.
  /// Uses Google token when available (same as first sheet) so previous-year sheet creation works without Drive API for Service Account.
  Future<bool> addNewFinancialYearForFy(String fy) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final email = user.email ?? '';
    if (email.isEmpty) return false;
    isLoadingFy.value = true;
    try {
      // Prefer user's Google token (creates in their Drive, same as first sheet) to avoid 403
      String? accessToken = await getGoogleAccessToken();
      final result = await GoogleSheetService.createNewSpreadsheetForFy(
        user.uid,
        email,
        user.displayName ?? email.split('@').first,
        fy: fy,
        accessToken: accessToken,
      );
      if (result == null || result.$1.isEmpty) {
        if (!_isDisposed) {
          _safeSnackbar(title: 'Error', message: 'Could not create new sheet for FY $fy', isError: true);
        }
        return false;
      }
      final newId = result.$1;
      await AppConstants.setSpreadsheetId(newId);
      await AppConstants.setActiveFy(fy);
      try {
        await GoogleSheetService.ensureSheetsExist();
      } catch (e) {
        print('ensureSheetsExist for new FY: $e');
      }
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      Map<String, String> byFy = {};
      final existing = data['spreadsheetIdsByFy'];
      if (existing is Map) {
        for (final e in existing.entries) {
          byFy[e.key.toString()] = e.value?.toString() ?? '';
        }
      }
      byFy[fy] = newId;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'spreadsheetId': newId,
        'activeFy': fy,
        'spreadsheetIdsByFy': byFy,
      });
      fyList.assignAll(byFy.keys.toList()..sort());
      activeFyValue.value = fy;
      GoogleSheetService.clearInvoiceListCacheForNewFy();
      try {
        await Get.find<DashboardController>().refreshDashboard();
      } catch (_) {}
      if (!_isDisposed) {
        _safeSnackbar(title: 'Success', message: 'FY $fy sheet created and set active', isError: false);
      }
      return true;
    } catch (e) {
      print('addNewFinancialYearForFy: $e');
      if (!_isDisposed) {
        final is403 = e.toString().contains('403') || e.toString().toLowerCase().contains('permission');
        final msg = is403
            ? 'Permission denied. Enable Drive API in Google Cloud Console for your project and ensure the Service Account can create files. Then try again.'
            : e.toString();
        _safeSnackbar(title: 'Error', message: msg, isError: true);
      }
      return false;
    } finally {
      isLoadingFy.value = false;
    }
  }

  Future<void> switchFinancialYear(String fy) async {
    final user = _auth.currentUser;
    if (user == null) return;
    isLoadingFy.value = true;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) return;
      final data = doc.data() ?? {};
      final byFy = data['spreadsheetIdsByFy'];
      if (byFy is! Map) return;
      final id = byFy[fy]?.toString();
      if (id == null || id.isEmpty) return;
      await AppConstants.setSpreadsheetId(id);
      await AppConstants.setActiveFy(fy);
      activeFyValue.value = fy;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'activeFy': fy, 'spreadsheetId': id});
      // Clear invoice cache so dashboard loads data from the new FY sheet, not old cached data.
      GoogleSheetService.clearInvoiceListCacheForNewFy();
      try {
        await Get.find<DashboardController>().refreshDashboard();
      } catch (_) {}
      if (!_isDisposed) {
        _safeSnackbar(title: 'Switched', message: 'Now using FY $fy', isError: false);
      }
    } catch (e) {
      print('switchFinancialYear: $e');
      if (!_isDisposed) {
        _safeSnackbar(title: 'Error', message: e.toString(), isError: true);
      }
    } finally {
      isLoadingFy.value = false;
    }
  }

  /// Central logout: sign out, clear prefs/constants, navigate to Auth. Used by Dashboard and Account Inactive dialog.
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await sharedPreferencesHelper.clearPrefData();
      AppConstants.userId = "";
      AppConstants.companyId = "";
      AppConstants.appId = "";
      AppConstants.spreadsheetId = "";
      AppConstants.accessKey = "";
      AppConstants.isChallan.value = false;
      AppConstants.isCashMemo.value = false;
      AppConstants.withGST.value = false;
      Get.deleteAll(force: true);
      Get.offAllNamed(AuthScreen.pageId);
      print("✅ Logout completed.");
    } catch (e) {
      print("❌ Logout failed: $e");
      Get.snackbar("Error", "Logout failed, please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }
}