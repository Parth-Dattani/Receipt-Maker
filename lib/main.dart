import 'package:GetYourInvoice/routes.dart';
import 'package:GetYourInvoice/screen/screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constant/constant.dart';
import 'firebase_options.dart';
import 'utils/app_logger.dart';
import 'utils/shared_preferences_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLog.init();

  // Initialize SharedPreferences
  await sharedPreferencesHelper.getSharedPreferencesInstance();
  
  // Load AppConstants from SharedPreferences
  await AppConstants.loadFromPrefs();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NoorReceiptApp());
}

class NoorReceiptApp extends StatelessWidget {
  const NoorReceiptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.appTheame,
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      initialRoute: SplashScreen.pageId,
      getPages: appPages,
      // Localization setup
      translations: Messages(),
      locale: AppConstants.isGujarati.value 
          ? const Locale('gu', 'IN') 
          : const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
