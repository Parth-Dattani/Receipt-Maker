import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GetYourInvoice/controller/bash_controller.dart';
import 'package:GetYourInvoice/screen/dashboard/dashboard_screen.dart';
import 'package:GetYourInvoice/screen/screen.dart';
import 'package:GetYourInvoice/services/remote_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constant/app_colors.dart';
import '../constant/app_constant.dart';
import '../constant/constant.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/shared_preferences_helper.dart';
import '../utils/financial_year_helper.dart';
import '../services/service.dart';
import 'controller.dart';

class CompanyController extends BaseController {
  // TextEditingControllers
  final companyCodeController = TextEditingController();
  final companyNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final pincodeController = TextEditingController();
  final logoController = TextEditingController();
  final phoneController = TextEditingController();
  final businessCategoryController = TextEditingController();
  final gstController = TextEditingController();
  final panController = TextEditingController();
  final bankNameController = TextEditingController();
  final ifscController = TextEditingController();
  final accountNumberController = TextEditingController();
  final upiController = TextEditingController();
  final authorisedSignatureController = TextEditingController();
  final extraNote1Controller = TextEditingController();
  final extraNote2Controller = TextEditingController();
  final extraNote3Controller = TextEditingController();
  var isExtraNotesEnabled = false.obs;

  // 🆕 NEW: Invoice starting number controller
  final invoiceStartingNumberController = TextEditingController(text: '1');

  // 🆕 NEW: Due date controllers
  final dueDateDaysController = TextEditingController();
  var isDueDateEnabled = false.obs;

  var isChallanEnabled = false.obs;
  var isCashMemoEnabled = false.obs;
  var selectedCountry = ''.obs;
  var selectedState = ''.obs;
  var isGstEnabled = false.obs;
  final formKey = GlobalKey<FormState>();

  // Observable variables
  var isCompanyRegistered = false.obs;
  var currentCompany = Rxn<Map<String, dynamic>>();
  var isEditMode = false.obs;
  String? existingCompanyId;

  var selectedBusinessType = ''.obs;
  final List<String> businessTypes = ['Trading', 'Service', 'Client'];

  /// Logo: URL or data URL (base64). Used for preview in registration screen.
  var logoPreviewUrl = Rxn<String>();


  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    // Set default values
    selectedCountry.value = 'India';
    selectedState.value = 'Gujarat';
    cityController.text = 'Jamnagar';

    logoController.addListener(() {
      final t = logoController.text.trim();
      logoPreviewUrl.value = t.isEmpty ? null : t;
    });

    final args = Get.arguments;
    print('Arguments received: $args');

    if (args != null && args['isEdit'] == true && args['companyData'] != null) {
      isEditMode.value = true;
      existingCompanyId = args['companyId'];
      print('Edit mode enabled with company ID: $existingCompanyId');
      _populateFields(args['companyData']);
      isLoading.value = false; // Ensure form shows immediately in edit mode
    } else {
      print('Create mode enabled');
      _checkCompanyRegistration();
    }
  }

  Future<void> _checkCompanyRegistration() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final companyDocs = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (companyDocs.docs.isNotEmpty) {
        isCompanyRegistered.value = true;
        currentCompany.value = companyDocs.docs.first.data();
        currentCompany.value!['id'] = companyDocs.docs.first.id;
        _populateFields(currentCompany.value!);

        await AppConstants.setBusinessType(currentCompany.value!['businessType'] ?? 'Trading');

        final spreadsheetId = currentCompany.value!['spreadsheetId'] as String?;
        if (spreadsheetId != null && spreadsheetId.isNotEmpty) {
          Get.offAllNamed(DashboardScreen.pageId);
        } else {
          showCustomSnackbar(
            title: "Action Required",
            message: "Google Sheet not found. Please click 'Update' below to generate your data sheets.",
            icon: Icons.info,
            baseColor: AppColors.appColor,
          );
        }
      }
    } catch (e) {
      print("Error checking company registration: $e");
    }
  }

  void _populateFields(Map<String, dynamic> companyData) {
    print('Populating fields with data: $companyData');
    print('Invoice Starting Number from DB: ${companyData['invoiceStartingNumber']}'); // Add this

    companyCodeController.text = companyData['companyCode'] ?? '';
    companyNameController.text = companyData['companyName'] ?? '';
    addressController.text = companyData['address'] ?? '';

    // Only override defaults if data exists
    cityController.text = companyData['city'] ?? 'Jamnagar';
    pincodeController.text = companyData['pincode'] ?? '';
    logoController.text = companyData['logo'] ?? '';
    logoPreviewUrl.value = companyData['logo']?.toString().trim().isNotEmpty == true ? companyData['logo'].toString() : null;
    businessCategoryController.text = companyData['businessCategory'] ?? '';
    selectedBusinessType.value = companyData['businessType'] ?? '';
    gstController.text = companyData['gst'] ?? '';
    panController.text = companyData['pan'] ?? '';
    phoneController.text = companyData['phone'] ?? '';
    bankNameController.text = companyData['bankName'] ?? '';
    ifscController.text = companyData['ifsc'] ?? '';
    accountNumberController.text = companyData['accountNumber'] ?? '';
    upiController.text = companyData['upiId'] ?? '';
    authorisedSignatureController.text = companyData['authorisedSignature'] ?? '';
    isExtraNotesEnabled.value = companyData['isExtraNotesEnabled'] ?? false;
    extraNote1Controller.text = companyData['extraNote1'] ?? '';
    extraNote2Controller.text = companyData['extraNote2'] ?? '';
    extraNote3Controller.text = companyData['extraNote3'] ?? '';

    isChallanEnabled.value = companyData['isChallanEnabled'] ?? false;
    isCashMemoEnabled.value = companyData['isCashMemoEnabled'] ?? false;
    isGstEnabled.value = companyData['isGstEnabled'] ?? false;

    invoiceStartingNumberController.text = (companyData['invoiceStartingNumber'] ?? 1).toString();
    print('Invoice Starting Number Controller: ${invoiceStartingNumberController.text}'); // Add this

    isDueDateEnabled.value = companyData['isDueDateEnabled'] ?? false;
    dueDateDaysController.text = companyData['dueDateDays'] != null && companyData['dueDateDays'] != 0
        ? companyData['dueDateDays'].toString()
        : '';

    final String country = companyData['country'] ?? 'India';
    if (countries.contains(country)) {
      selectedCountry.value = country;

      final String state = companyData['state'] ?? 'Gujarat';
      final availableStates = getStatesForCountry();
      if (availableStates.contains(state)) {
        selectedState.value = state;
      } else {
        selectedState.value = 'Gujarat'; // fallback to default
      }
    } else {
      selectedCountry.value = 'India';
      selectedState.value = 'Gujarat';
    }
  }

  void clearLogo() {
    logoController.clear();
    logoPreviewUrl.value = null;
  }

  /// Picks an image from gallery and sets logo as base64 data URL.
  Future<void> pickLogoImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      final base64 = base64Encode(bytes);
      final mime = image.mimeType ?? 'image/jpeg';
      final dataUrl = 'data:$mime;base64,$base64';
      logoController.text = dataUrl;
      logoPreviewUrl.value = dataUrl;
    } catch (e) {
      print('Error picking logo image: $e');
      showCustomSnackbar(
        title: "Error",
        message: "Could not pick image. Try using a logo URL instead.",
        icon: Icons.error,
        baseColor: AppColors.errorColor,
      );
    }
  }

  Future<bool> _isCompanyCodeUnique(String companyCode) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      Query query = _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .where('companyCode', isEqualTo: companyCode.trim().toUpperCase());

      if (isEditMode.value && existingCompanyId != null && existingCompanyId!.isNotEmpty) {
        query = query.where(FieldPath.documentId, isNotEqualTo: existingCompanyId);
      }

      final querySnapshot = await query.limit(1).get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print("Error checking company code uniqueness: $e");
      return false;
    }
  }

  bool _validateRequiredFields() {
    // ... existing validations ...

    // 🆕 NEW: Validate invoice starting number
    final invoiceNumber = int.tryParse(invoiceStartingNumberController.text.trim());
    if (invoiceNumber == null || invoiceNumber < 1) {
      showCustomSnackbar(
        title: "",
        message: "Invoice starting number must be a positive number",
        icon: Icons.close,
        baseColor: AppColors.appColor,
      );
      return false;
    }
    // 🆕 NEW: Validate due date days if enabled
    if (isDueDateEnabled.value) {
      final dueDays = int.tryParse(dueDateDaysController.text.trim());
      if (dueDays == null || dueDays < 1) {
        showCustomSnackbar(
          title: "",
          message: "Due date days must be a positive number",
          icon: Icons.close,
          baseColor: AppColors.appColor,
        );
        return false;
      }
    }

    if (isExtraNotesEnabled.value) {
      final note1 = extraNote1Controller.text.trim();
      final note2 = extraNote2Controller.text.trim();
      final note3 = extraNote3Controller.text.trim();

      if (note1.isEmpty && note2.isEmpty && note3.isEmpty) {
        showCustomSnackbar(
          title: "",
          message: "At least one extra note is required when Extra Notes is enabled",
          icon: Icons.close,
          baseColor: AppColors.appColor,
        );
        return false;
      }
    }


    return true;
  }

  Future<void> registerCompany() async {
    if (!formKey.currentState!.validate()) return;
    if (!_validateRequiredFields()) return;

    final user = _auth.currentUser;
    if (user == null) {
      showCustomSnackbar(
        title: "Error",
        message: "Please login first!",
        baseColor: AppColors.errorColor,
        icon: Icons.error,
      );
      return;
    }

    try {
      isLoading.value = true;

      final isUnique = await _isCompanyCodeUnique(companyCodeController.text);
      if (!isUnique) {
        showCustomSnackbar(
          title: "Error",
          message: "Company code already exists. Please choose a different one.",
          baseColor: AppColors.errorColor,
          icon: Icons.error,
        );
        return;
      }

      final companyRef = _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc();

      final invoiceStartNum = int.tryParse(invoiceStartingNumberController.text.trim()) ?? 1;

      final companyData = {
        'id': companyRef.id,
        'userId': user.uid,
        'userEmail': user.email,
        'companyCode': companyCodeController.text.trim().toUpperCase(),
        'companyName': companyNameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': selectedState.value,
        'country': selectedCountry.value,
        'pincode': pincodeController.text.trim(),
        'phone': phoneController.text.trim(),
        'logo': logoController.text.trim(),
        'businessCategory': businessCategoryController.text.trim(),
        'businessType': selectedBusinessType.value,
        'gst': gstController.text.trim().toUpperCase(),
        'pan': panController.text.trim().toUpperCase(),
        'isDueDateEnabled': isDueDateEnabled.value,
        'dueDateDays': isDueDateEnabled.value
            ? int.tryParse(dueDateDaysController.text.trim()) ?? 0
            : 0,
        'bankName': bankNameController.text.trim(),
        'ifsc': ifscController.text.trim().toUpperCase(),
        'accountNumber': accountNumberController.text.trim(),
        'upiId': upiController.text.trim(),
        'authorisedSignature': authorisedSignatureController.text.trim(),
        'isExtraNotesEnabled': isExtraNotesEnabled.value,
        'extraNote1': isExtraNotesEnabled.value ? extraNote1Controller.text.trim() : '',
        'extraNote2': isExtraNotesEnabled.value ? extraNote2Controller.text.trim() : '',
        'extraNote3': isExtraNotesEnabled.value ? extraNote3Controller.text.trim() : '',

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isChallanEnabled': isChallanEnabled.value,
        'isCashMemoEnabled': isCashMemoEnabled.value,
        'isGstEnabled': isGstEnabled.value,

        // 🆕 NEW: Store invoice starting number
        'invoiceStartingNumber': invoiceStartNum,
        'currentInvoiceNumber': invoiceStartNum, // Current counter
      };

      await companyRef.set(companyData);

      // Store logo URL in Google Sheet only when it's a normal URL (not base64 data URL)
      final logoUrl = logoController.text.trim();
      if (logoUrl.isNotEmpty && (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'))) {
        GoogleSheetService.addOrUpdateCompanyLogo(
          companyRef.id,
          companyNameController.text.trim(),
          logoUrl,
        );
      }

      isCompanyRegistered.value = true;
      currentCompany.value = companyData;

      showCustomSnackbar(
        title: "Success",
        message: "Company registered successfully!",
        icon: Icons.done_all,
        baseColor: AppColors.greenColor2,
      );

      AppConstants.isChallan.value = isChallanEnabled.value;
      AppConstants.withGST.value = isGstEnabled.value;
      await AppConstants.setChallanEnabled(isChallanEnabled.value);
      await AppConstants.setCashMemoEnabled(isCashMemoEnabled.value);
      await AppConstants.setGstEnabled(isGstEnabled.value);
      await AppConstants.setBusinessType(selectedBusinessType.value); // 🆕 NEW

      // 🆕 NEW: Save due date settings to AppConstants
      await AppConstants.setDueDateEnabled(isDueDateEnabled.value);
      await AppConstants.setDueDateDays(
          isDueDateEnabled.value
              ? int.tryParse(dueDateDaysController.text.trim()) ?? 0
              : 0
      );
      await AppConstants.setExtraNotesEnabled(isExtraNotesEnabled.value);

      // Persist active company context (some controllers read "CompanyId")
      await AppConstants.setCompanyId(companyRef.id);
      await sharedPreferencesHelper.storePrefData("CompanyId", companyRef.id);
      final String savedCompanyName = companyNameController.text.trim();
      if (savedCompanyName.isNotEmpty) {
        await AppConstants.setCompanyName(savedCompanyName);
      }

      // After company registration, go to Dashboard (not Customer Registration)

      // 🆕 Create Google Sheet using Service Account flow since it's missing (or user Drive if Google Token exists)
      if (AppConstants.spreadsheetId.isEmpty) {
        try {
          String? accessToken = AppConstants.googleAccessToken.isNotEmpty 
              ? AppConstants.googleAccessToken 
              : null;
              
          if (accessToken == null) {
            try {
              accessToken = await Get.find<AuthController>().getGoogleAccessToken();
            } catch (_) {}
          }

          final result = await GoogleSheetService.createNewUserSpreadsheet(
            user.uid,
            accessToken: accessToken,
            userEmail: user.email,
            username: user.displayName ?? user.email?.split('@').first ?? 'user',
          );
          
          if (result != null && result.$1.isNotEmpty) {
            final newSpreadsheetId = result.$1;
            AppConstants.spreadsheetId = newSpreadsheetId;
            await sharedPreferencesHelper.storePrefData("spreadsheetId", newSpreadsheetId);
            
            final fy = FinancialYearHelper.currentFy();
            await AppConstants.setActiveFy(fy);
            
            await _firestore.collection("users").doc(user.uid).update({
              "spreadsheetId": newSpreadsheetId,
              "activeFy": fy,
              "spreadsheetIdsByFy": {fy: newSpreadsheetId},
            });
            
            // Also update the company document with the spreadsheet ID
            await companyRef.update({
              "spreadsheetId": newSpreadsheetId,
            });

            await GoogleSheetService.ensureSheetsExist();
          }
        } catch (e) {
          print('createNewUserSpreadsheet during company registration failed: $e');
        }
      }

      Get.offAllNamed(DashboardScreen.pageId);

    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Registration failed: ${e.toString()}",
        icon: Icons.close,
        baseColor: AppColors.appColor,
      );
      print('Company registration error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCompany() async {
    if (!formKey.currentState!.validate()) return;
    if (!_validateRequiredFields()) return;

    final user = _auth.currentUser;
    if (user == null) {
      showCustomSnackbar(
        title: "Error",
        message: "Please login first!",
        baseColor: AppColors.errorColor,
        icon: Icons.error,
      );
      return;
    }

    try {
      isLoading.value = true;

      final docSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(existingCompanyId)
          .get();

      if (!docSnapshot.exists) {
        showCustomSnackbar(
          title: "Error",
          message: "Company document not found.",
          baseColor: AppColors.errorColor,
          icon: Icons.error,
        );
        return;
      }

      final invoiceStartNum = int.tryParse(invoiceStartingNumberController.text.trim()) ?? 1;
      final existingData = docSnapshot.data() ?? {};
      final currentInvoiceNum = existingData['currentInvoiceNumber'] as int?;

      final updateData = {
        'companyName': companyNameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': selectedState.value,
        'country': selectedCountry.value,
        'pincode': pincodeController.text.trim(),
        'phone': phoneController.text.trim(),
        'logo': logoController.text.trim(),
        'businessCategory': businessCategoryController.text.trim(),
        'businessType': selectedBusinessType.value,
        'gst': gstController.text.trim().toUpperCase(),
        'pan': panController.text.trim().toUpperCase(),
        'isDueDateEnabled': isDueDateEnabled.value,
        'dueDateDays': isDueDateEnabled.value
            ? int.tryParse(dueDateDaysController.text.trim()) ?? 0
            : 0,
        'bankName': bankNameController.text.trim(),
        'ifsc': ifscController.text.trim().toUpperCase(),
        'accountNumber': accountNumberController.text.trim(),
        'upiId': upiController.text.trim(),
        'authorisedSignature': authorisedSignatureController.text.trim(),
        'isExtraNotesEnabled': isExtraNotesEnabled.value,
        'extraNote1': isExtraNotesEnabled.value ? extraNote1Controller.text.trim() : '',
        'extraNote2': isExtraNotesEnabled.value ? extraNote2Controller.text.trim() : '',
        'extraNote3': isExtraNotesEnabled.value ? extraNote3Controller.text.trim() : '',
        'updatedAt': FieldValue.serverTimestamp(),
        'isChallanEnabled': isChallanEnabled.value,
        'isCashMemoEnabled': isCashMemoEnabled.value,
        'isGstEnabled': isGstEnabled.value,
        'invoiceStartingNumber': invoiceStartNum,
      };

      if (currentInvoiceNum == null || currentInvoiceNum < invoiceStartNum) {
        updateData['currentInvoiceNumber'] = invoiceStartNum;
      }

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(existingCompanyId)
          .set(updateData, SetOptions(merge: true));

      // Store logo URL in Google Sheet only when it's a normal URL (not base64 data URL)
      final logoUrl = logoController.text.trim();
      if (logoUrl.isNotEmpty && existingCompanyId != null && (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'))) {
        GoogleSheetService.addOrUpdateCompanyLogo(
          existingCompanyId!,
          companyNameController.text.trim(),
          logoUrl,
        );
      }

      // 🆕 Create Google Sheet using Service Account flow since it's missing (or user Drive if Google Token exists)
      final currentSpreadsheetId = existingData['spreadsheetId'] as String?;
      if (currentSpreadsheetId == null || currentSpreadsheetId.isEmpty) {
        try {
          String? accessToken = AppConstants.googleAccessToken.isNotEmpty 
              ? AppConstants.googleAccessToken 
              : null;
              
          if (accessToken == null) {
            try {
              accessToken = await Get.find<AuthController>().getGoogleAccessToken();
            } catch (_) {}
          }

          final result = await GoogleSheetService.createNewUserSpreadsheet(
            user.uid,
            accessToken: accessToken,
            userEmail: user.email,
            username: user.displayName ?? user.email?.split('@').first ?? 'user',
          );
          
          if (result != null && result.$1.isNotEmpty) {
            final newSpreadsheetId = result.$1;
            AppConstants.spreadsheetId = newSpreadsheetId;
            await sharedPreferencesHelper.storePrefData("spreadsheetId", newSpreadsheetId);
            
            final fy = FinancialYearHelper.currentFy();
            await AppConstants.setActiveFy(fy);
            
            await _firestore.collection("users").doc(user.uid).update({
              "spreadsheetId": newSpreadsheetId,
              "activeFy": fy,
              "spreadsheetIdsByFy": {fy: newSpreadsheetId},
            });
            
            // Also update the company document with the spreadsheet ID
            await _firestore
                .collection("users")
                .doc(user.uid)
                .collection("companies")
                .doc(existingCompanyId)
                .update({
              "spreadsheetId": newSpreadsheetId,
            });

            await GoogleSheetService.ensureSheetsExist();
          }
        } catch (e) {
          print('createNewUserSpreadsheet during company update failed: $e');
        }
      }

      // Fetch the updated document from Firebase
      final updatedDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(existingCompanyId)
          .get();

      if (updatedDoc.exists) {
        currentCompany.value = {
          ...updatedDoc.data()!,
          'id': updatedDoc.id,
        };
        currentCompany.refresh();

        // Update DashboardController if it exists
        if (Get.isRegistered<DashboardController>()) {
          final dashController = Get.find<DashboardController>();
          dashController.currentCompany.value = {
            ...updatedDoc.data()!,
            'id': updatedDoc.id,
          };
          dashController.currentCompany.refresh();

          // Also update AppConstants
          AppConstants.isChallan.value = isChallanEnabled.value;
          AppConstants.withGST.value = isGstEnabled.value;
          await AppConstants.setChallanEnabled(isChallanEnabled.value);
          await AppConstants.setCashMemoEnabled(isCashMemoEnabled.value);
          await AppConstants.setGstEnabled(isGstEnabled.value);
          await AppConstants.setBusinessType(selectedBusinessType.value);


        }
      }

      showCustomSnackbar(
        title: "Success",
        message: "Company updated successfully!",
        baseColor: AppColors.greenColor2,
        icon: Icons.done_all,
      );

      AppConstants.isChallan.value = isChallanEnabled.value;
      AppConstants.withGST.value = isGstEnabled.value;
      await AppConstants.setChallanEnabled(isChallanEnabled.value);
      await AppConstants.setCashMemoEnabled(isCashMemoEnabled.value);
      await AppConstants.setGstEnabled(isGstEnabled.value);
      await AppConstants.setBusinessType(selectedBusinessType.value); // 🆕 NEW
      // 🆕 NEW: Save due date settings to AppConstants
      await AppConstants.setDueDateEnabled(isDueDateEnabled.value);
      await AppConstants.setDueDateDays(
          isDueDateEnabled.value
              ? int.tryParse(dueDateDaysController.text.trim()) ?? 0
              : 0
      );
      await AppConstants.setExtraNotesEnabled(isExtraNotesEnabled.value);

      isLoading.value = false;

      // Close snackbar so it doesn't block navigation
      try {
        Get.closeCurrentSnackbar();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 150));

      // Navigate back to Dashboard screen (same pattern as invoice/challan)
      Get.until((route) => route.settings.name == DashboardScreen.pageId);
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshDashboard();
      }
      return;
    } catch (e) {
      print('Update error: $e');
      showCustomSnackbar(
        title: "Error",
        message: "Update failed: ${e.toString()}",
        baseColor: AppColors.errorColor,
        icon: Icons.close,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCompany() async {
    if (isEditMode.value) {
      await updateCompany();
    } else {
      await registerCompany();
    }
  }

  @override
  void dispose() {
    companyCodeController.dispose();
    companyNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pincodeController.dispose();
    logoController.dispose();
    phoneController.dispose();
    businessCategoryController.dispose();
    gstController.dispose();
    panController.dispose();
    bankNameController.dispose();
    ifscController.dispose();
    accountNumberController.dispose();
    upiController.dispose();
    authorisedSignatureController.dispose();
    extraNote1Controller.dispose();
    extraNote2Controller.dispose();
    extraNote3Controller.dispose();
    invoiceStartingNumberController.dispose(); // 🆕 NEW
    dueDateDaysController.dispose();
    super.dispose();
  }

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

  List<String> getStatesForCountry() {
    if (selectedCountry.value.isEmpty) return [];
    return countryStates[selectedCountry.value] ?? [];
  }
}

