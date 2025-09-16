import 'package:demo_prac_getx/routes.dart';
import 'package:demo_prac_getx/screen/screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controller/controller.dart';
import 'utils/shared_preferences_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPreferencesHelper.getSharedPreferencesInstance();
  await Firebase.initializeApp();
  // await Supabase.initialize(
  //   url: 'https://dwhvrupyeeknfwnusjdr.supabase.co',
  //   anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3aHZydXB5ZWVrbmZ3bnVzamRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NDc5NzYsImV4cCI6MjA3MjIyMzk3Nn0.yFCtlbH7lkLk79e0zte-JzjkUikESZCm4HFTWC7IKIA',
  //);
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
      debugShowCheckedModeBanner: false,
    );
  }
}
