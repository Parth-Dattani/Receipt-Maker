import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../controller/controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // On web keep controller permanent so sidebar works on every screen
    Get.put<DashboardController>(DashboardController(), permanent: kIsWeb);
  }
}