import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../constant/app_constant.dart'; // તમારી આઈડી સેવ કરવાની ફાઈલ
import '../screen/auth/login_screen.dart';
import '../screen/dashboard/dashboard_screen.dart';

class SplashController extends GetxController {
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    goToNext();
  }

  void goToNext() {
    // 🌟 ફાયરબેઝ યુઝર લૉગિન છે કે નહીં તે ચેક કરો
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      // સુરક્ષા માટે: જો યુઝર લૉગિન છે પણ કોઈ કારણસર લોકલ આઈડી ક્લીન થઈ ગયું હોય, તો ફરી સેટ કરી દેવું
      AppConstants.setUserId(firebaseUser.uid);

      if (Get.currentRoute != DashboardScreen.pageId) {
        Get.offAllNamed(DashboardScreen.pageId);
      }
    } else {
      // જો લૉગિન ન હોય તો લોકલ આઈડી પણ ખાલી કરી દેવી
      AppConstants.setUserId('');
      if (Get.currentRoute != LoginScreen.pageId) {
        Get.offAllNamed(LoginScreen.pageId);
      }
    }
  }
}