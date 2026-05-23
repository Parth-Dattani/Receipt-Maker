import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/controller.dart';
import '../controller/receipt_controller.dart';
import '../controller/dashboard_controller.dart';
import '../controller/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);

    // 🚀 અલ્ટીમેટ ફિક્સ: fenix: true કરવાથી ડેશબોર્ડ પર પ્લસ બટન દબાવતા જ ગેટએક્સ આને ઓટો-લાઇવ કરી દેશે, ક્રેશ સાવ બંધ!
    Get.lazyPut<ReceiptController>(() => ReceiptController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
  }
}

class ReceiptBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ReceiptController>(() => ReceiptController(), fenix: true);
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
  }
}