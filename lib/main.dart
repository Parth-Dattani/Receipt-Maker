import 'package:GetYourInvoice/routes.dart';
import 'package:GetYourInvoice/screen/screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constant/constant.dart';
import 'controller/controller.dart';
import 'firebase_options.dart';
import 'services/remote_service.dart';
import 'utils/app_logger.dart';
import 'utils/shared_preferences_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLog.init();

  // ✅ Add this for better GetX performance in release mode
  Get.config(
    enableLog: true,  // Keep true even in release for debugging if needed
    defaultTransition: Transition.fade,
  );

  await sharedPreferencesHelper.getSharedPreferencesInstance();
  //await Firebase.initializeApp();
  /// Initialize Firebase with platform-specific options
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  else {
    await Firebase.initializeApp();
  }


  /// 🔹 Load language before app starts
  await AppConstants.loadFromPrefs();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    
    // Check if we are handling a web URL that should bypass Splash
    String initialRoute = SplashScreen.pageId;
    if (kIsWeb) {
      final currentUri = Uri.base;
      if (currentUri.fragment.contains('/order')) {
        initialRoute = '/order';
      }
    }
    
    if (initialRoute == SplashScreen.pageId) {
      Get.put(SplashController()); // Required before SplashScreen
    }

    return GetMaterialApp(
      navigatorKey: Get.key,
      title: 'Invoice Sathi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: initialRoute,
      getPages: appPages,
      translations: Messages(),
      locale: AppConstants.isGujarati.value
          ? const Locale('gu', 'IN')
          : const Locale('en', 'US'), // Load saved language or device language
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
    );
  }
}

