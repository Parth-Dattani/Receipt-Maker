import 'package:demo_prac_getx/routes.dart';
import 'package:demo_prac_getx/screen/screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constant/constant.dart';
import 'controller/controller.dart';
import 'services/remote_service.dart';
import 'utils/shared_preferences_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();



  await sharedPreferencesHelper.getSharedPreferencesInstance();
  //await Firebase.initializeApp();
  /// Initialize Firebase with platform-specific options
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBTWh86tWbhygufUosvn7OQwYdrMycCPzA",
        authDomain: "getyourinvoice-8f128.firebaseapp.com",
        projectId: "getyourinvoice-8f128",
        storageBucket: "getyourinvoice-8f128.firebasestorage.app",
        messagingSenderId: "134369591951",
        appId: "1:134369591951:web:5cf271caa468b073d8a6fa",
      ),
    );
  }
  else {
    await Firebase.initializeApp();
  }
  // await Supabase.initialize(
  //   url: 'https://dwhvrupyeeknfwnusjdr.supabase.co',
  //   anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3aHZydXB5ZWVrbmZ3bnVzamRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NDc5NzYsImV4cCI6MjA3MjIyMzk3Nn0.yFCtlbH7lkLk79e0zte-JzjkUikESZCm4HFTWC7IKIA',
  //);

  /// 🔹 Load language before app starts
  await AppConstants.loadFromPrefs();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: SplashScreen.pageId,
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
