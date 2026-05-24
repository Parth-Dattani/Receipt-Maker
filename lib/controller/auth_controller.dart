import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../constant/constant.dart';
import '../screen/auth/login_screen.dart';
import '../screen/dashboard/dashboard_screen.dart';
import '../screen/auth/register_screen.dart';
import '../services/google_sheets_service.dart';
import '../utils/shared_preferences_helper.dart';
import 'receipt_controller.dart';
import 'dashboard_controller.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  late final GoogleSignIn _googleSignIn;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  User? get currentUser => _auth.currentUser;
  String get userEmail => currentUser?.email ?? '';

  // ── Auth-state listener ────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    // Initialize GoogleSignIn based on platform
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: AppConstants.googleWebClientId,
        scopes: [
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/spreadsheets',
        ],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/spreadsheets',
        ],
      );
    }

    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await AppConstants.setUserId(user.uid);

        if (user.email != null) {
          // 🛡️ સિંગલ ટાઈમ સેન્ટ્રલ ટ્રિગર જે બધું હેન્ડલ અને સ્ટોર કરશે
          await handleSilentGoogleLogin(user.email!);
        }

        if (Get.currentRoute != DashboardScreen.pageId) {
          Get.offAllNamed(DashboardScreen.pageId);
        }
      } else {
        await AppConstants.setUserId('');
        if (Get.currentRoute != LoginScreen.pageId &&
            Get.currentRoute != '/login' &&
            Get.currentRoute != '/SplashScreen' &&
            Get.currentRoute != RegisterScreen.pageId) {
          Get.offAllNamed(LoginScreen.pageId);
        }
      }
    });
  }

  // ── 🌟 Silent Google Login & Store IDs inside Firestore ──────────────────────
  Future<void> handleSilentGoogleLogin(String firebaseEmail) async {
    try {
      bool isConnected = await GoogleSheetsService.signInSilentlyWithEmail(firebaseEmail);

      if (isConnected) {
        final fyLabel = _currentFYLabel();

        // 🚀 ગૂગલ ડ્રાઇવ એન્જિન રન કરો અને આઇડી મેળવો
        Map<String, String>? driveData = await GoogleSheetsService.setupUserDriveAndSheet(_auth.currentUser!.uid, fyLabel);

        // 📝 જો આઇડી સફળતાપૂર્વક મળે, તો ફાયરસ્ટોરમાં સેવ કરો
        if (driveData != null && driveData['folderId'] != 'ALREADY_ACTIVE') {
          await _db.collection('users').doc(_auth.currentUser!.uid).set({
            'driveFolderId': driveData['folderId'],
            'googleSheetId': driveData['spreadsheetId'],
            'activeFY': driveData['financialYear'],
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          debugPrint('[Firestore Sync] ✅ Folder and Sheet IDs stored successfully!');
        }
      }
    } catch (e) {
      debugPrint('[Silent Auth Error] $e');
    }
  }

  // ── Explicit Google Button Login ──────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Ensure we are signed out first to force a fresh account picker
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _handleUserSetup(userCredential.user!, 'Google');
      }
    } catch (e) {
      debugPrint('[Google Login Error] $e');
      _showSnack('Error', 'Google Sign-In Failed: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleUserSetup(User user, String method) async {
    final uid = user.uid;
    final userDoc = await _db.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      await _db.collection('users').doc(uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'uid': uid,
        'authMethod': method,
      }, SetOptions(merge: true));
    } else {
      await _db.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Regular Email/Password Login ──────────────────────────────────────────
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (credential.user != null) {
        await _db.collection('users').doc(credential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed';
      if (e.code == 'user-not-found') msg = 'Email not found';
      if (e.code == 'wrong-password') msg = 'Wrong password';
      if (e.code == 'invalid-credential') msg = 'Invalid email or password';
      _showSnack('Error', msg, Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    if (passwordController.text != confirmPasswordController.text) {
      _showSnack('Error', 'Passwords do not match', Colors.red);
      return;
    }

    isLoading.value = true;
    try {
      final rawPassword = passwordController.text.trim();
      String base64Password = utf8.fuse(base64).encode(rawPassword);

      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: rawPassword,
      );

      if (credential.user != null) {
        await _db.collection('users').doc(credential.user!.uid).set({
          'email': credential.user!.email,
          'authHash': base64Password,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'uid': credential.user!.uid,
          'authMethod': 'Email_Password',
        }, SetOptions(merge: true));

        _showSnack('Success', 'Account created successfully', Colors.green);
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Registration failed';
      if (e.code == 'email-already-in-use') msg = 'Email already in use';
      if (e.code == 'weak-password') msg = 'Password is too weak';
      _showSnack('Error', msg, Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Reset Password ─────────────────────────────────────────────────────────
  Future<void> resetPassword() async {
    if (emailController.text.isEmpty || !GetUtils.isEmail(emailController.text)) {
      _showSnack('Error', 'Please enter a valid email to reset password', Colors.orange);
      return;
    }
    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      _showSnack('Success', 'Password reset email sent', Colors.blue);
    } catch (_) {
      _showSnack('Error', 'Failed to send reset email', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      // 0. Unfocus everything to prevent keyboard/controller race conditions
      FocusManager.instance.primaryFocus?.unfocus();

      // 1. Google Sign Out (Critical for Web/Mobile)
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('[Google SignOut Error] $e');
      }

      // 2. Firebase Sign Out
      await _auth.signOut();
      
      // 3. Reset Services
      GoogleSheetsService.reset();
      
      // 4. Clear Local Cache (SharedPreferences)
      await sharedPreferencesHelper.clearPrefData();
      
      debugPrint('[Logout] ✅ Full cleanup successful.');

      // 5. Redirect to Login FIRST. 
      // This removes the active screens that might be using the controllers we're about to delete.
      Get.offAllNamed(LoginScreen.pageId);
      
      // 6. Clean up Controllers AFTER navigation starts
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isRegistered<DashboardController>()) {
          Get.delete<DashboardController>(force: true);
        }
        if (Get.isRegistered<ReceiptController>()) {
          Get.delete<ReceiptController>(force: true);
        }
      });
      
    } catch (e) {
      debugPrint('[Logout Error] $e');
      _showSnack('Error', 'Failed to logout: $e', Colors.red);
    }
  }

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  String _currentFYLabel() {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    return '$startYear-${startYear + 1}';
  }

  void _showSnack(String title, String msg, MaterialColor color) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(
          title,
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: color.shade100,
          colorText: color.shade800,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      } else {
        debugPrint('[$title]: $msg');
      }
    });
  }
}
