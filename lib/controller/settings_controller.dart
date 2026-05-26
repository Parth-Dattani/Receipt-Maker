import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constant/constant.dart';
import '../services/google_sheets_service.dart';
import '../services/firebase_service.dart';
import '../utils/shared_preferences_helper.dart';
import 'controller.dart';

class SettingsController extends GetxController {
  final startRecCtrl = TextEditingController();
  final donationTypeCtrl = TextEditingController();
  var currentFY = "2026-27".obs;
  var donationTypes = <String>[].obs;
  var isLoadingTypes = false.obs;
  var isLoading = false.obs; // 🚀 Add overall loading state
  
  // 🚀 Dynamic FY Options List
  var fyOptions = <String>['2026-27'].obs;

  // User Info
  String get userEmail => FirebaseAuth.instance.currentUser?.email ?? '';
  String get userName => FirebaseAuth.instance.currentUser?.displayName ?? userEmail.split('@')[0];

  @override
  void onInit() {
    super.onInit();
    loadAvailableFYs();
    loadSavedSettings();
    loadDonationTypes();
  }

  /// 🚀 ગૂગલ શીટમાંથી અવેલેબલ FY ટેબ્સ ખેંચો અને પ્રોજેક્ટેડ વર્ષો ઉમેરો
  Future<void> loadAvailableFYs() async {
    // ૧. ગૂગલ શીટમાંથી લાઈવ ટેબ્સ લાવો
    final List<String> liveFys = await GoogleSheetsService.fetchAvailableFYs();
    
    // ૨. ચાલુ વર્ષના આધારે રેન્જ નક્કી કરો (૨ વર્ષ પહેલા અને ૩ વર્ષ પછી)
    final now = DateTime.now();
    final currentStartYear = now.month >= 4 ? now.year : now.year - 1;
    
    List<String> projectedYears = [];
    for (int i = -2; i <= 3; i++) {
      int start = currentStartYear + i;
      String end = (start + 1).toString().substring(2);
      projectedYears.add("$start-$end");
    }

    // ૩. બંને લિસ્ટને ભેગા કરો અને ડુપ્લીકેટ હટાવો
    final Set<String> allUniqueFys = {...liveFys, ...projectedYears};
    
    // ૪. સોર્ટ કરો (નવું વર્ષ પહેલા) અને રિફ્રેશ કરો
    List<String> sortedList = allUniqueFys.toList();
    sortedList.sort((a, b) => b.compareTo(a));
    
    fyOptions.value = sortedList;
  }

  void _generateFYOptions() {
    final now = DateTime.now();
    final currentStartYear = now.month >= 4 ? now.year : now.year - 1;
    
    List<String> years = [];
    // Generate 2 past years, current year, and 2 future years
    for (int i = -2; i <= 2; i++) {
      int start = currentStartYear + i;
      String end = (start + 1).toString().substring(2);
      years.add("$start-$end");
    }
    fyOptions.value = years;
  }

  void loadSavedSettings() async {
    await sharedPreferencesHelper.getSharedPreferencesInstance();

    // FY load karo
    String? savedFY = await sharedPreferencesHelper.getPrefData("active_fy");
    if (savedFY != null) currentFY.value = savedFY;

    // 🚀 Start Receipt Number વર્ષ મુજબ લોડ કરો
    String? startRec = await sharedPreferencesHelper.getPrefData("start_rec_no_${currentFY.value}");
    // જો આ વર્ષ માટે સેટ ના હોય તો ગ્લોબલ સેટિંગ ટ્રાય કરો
    startRec ??= await sharedPreferencesHelper.getPrefData("start_rec_no");

    if (startRec != null) startRecCtrl.text = startRec;
  }

  void loadDonationTypes() async {
    isLoadingTypes.value = true;
    donationTypes.value = await FirebaseService.getDonationTypes();
    isLoadingTypes.value = false;
  }

  Future<void> addDonationType() async {
    String newType = donationTypeCtrl.text.trim();
    if (newType.isEmpty) return;

    if (donationTypes.contains(newType)) {
      Get.snackbar("Error", "Type already exists");
      return;
    }

    await FirebaseService.addDonationType(newType);
    donationTypeCtrl.clear();
    loadDonationTypes();
    Get.snackbar("Success", "Donation type added");
  }

  Future<void> removeDonationType(String type) async {
    await FirebaseService.removeDonationType(type);
    loadDonationTypes();
    Get.snackbar("Removed", "Donation type removed");
  }

  void toggleDirectShare(bool val) async {
    await AppConstants.setIsWhatsappDirectShare(val);
  }

  // SettingsController.dart
  void changeFinancialYear(String newFY) async {
    currentFY.value = newFY;

    // 1. SharedPreferences માં સેવ કરો (Unified method)
    await AppConstants.setActiveFy(newFY);

    // 2. Google Sheets માં ટેબ બનાવો
    await GoogleSheetsService.createNewFinancialYearTab(newFY);

    // 3. Active Sheet સેટ કરો
    GoogleSheetsService.setActiveSheet("Receipts_$newFY");

    // 4. ડેશબોર્ડ અપડેટ કરો
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().updateDashboardAfterSettings();
    }

    Get.snackbar("Success", "Financial year changed to $newFY");
  }

  void saveSettings() async {
    isLoading.value = true;
    try {
      // 🚀 RecNo વર્ષ મુજબ સેવ કરો
      await sharedPreferencesHelper.storePrefData("start_rec_no_${currentFY.value}", startRecCtrl.text);
      // બેકવર્ડ સુસંગતતા માટે ગ્લોબલ પણ સેવ કરો
      await sharedPreferencesHelper.storePrefData("start_rec_no", startRecCtrl.text);

      Get.back();
      Get.snackbar("Saved", "Settings for ${currentFY.value} updated successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to save settings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    startRecCtrl.dispose();
    donationTypeCtrl.dispose();
    super.onClose();
  }
}