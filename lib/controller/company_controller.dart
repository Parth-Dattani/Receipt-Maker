import 'dart:async';
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
    selectedBusinessType.value = 'Service';

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

        await AppConstants.setBusinessType(
            currentCompany.value!['businessType']?.toString().trim().isNotEmpty == true
                ? currentCompany.value!['businessType'].toString()
                : 'Service');
        if (AppConstants.isTradingCompany) {
          await AppConstants.setEnablePurchaseFeature(
              currentCompany.value!['enablePurchaseFeature'] != false);
        }

        final spreadsheetId = currentCompany.value!['spreadsheetId'] as String?;
        if (spreadsheetId != null && spreadsheetId.isNotEmpty) {
          Get.offAllNamed(DashboardScreen.pageId);
        } else {
          showCustomSnackbar(
            title: "Action Required",
            message: "Google Sheet not found. Please click 'Update' below to generate your data sheets.",
            icon: Icons.info,
            baseColor: AppColors.appColor,
            position: SnackPosition.BOTTOM,
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
    final bt = companyData['businessType']?.toString().trim() ?? '';
    selectedBusinessType.value = bt.isEmpty ? 'Service' : bt;
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
        position: SnackPosition.BOTTOM,
      );
    }
  }

  /// `true` = code is free; `false` = same code already exists for this user; `null` = check failed (e.g. network).
  Future<bool?> checkCompanyCodeAvailability(String companyCode) async {
    final user = _auth.currentUser;
    if (user == null) return null;

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
      return null;
    }
  }

  /// Same rules as the company [Form] validators + invoice / due date / extra notes.
  List<String> _collectCompanyFormIssues() {
    final issues = <String>[];

    if (companyCodeController.text.trim().isEmpty) {
      issues.add('Company code');
    }
    if (companyNameController.text.trim().isEmpty) {
      issues.add('Company name');
    }
    if (phoneController.text.trim().isEmpty) {
      issues.add('Phone number');
    }
    if (selectedCountry.value.isEmpty) {
      issues.add('Country');
    }
    if (selectedCountry.value.isNotEmpty && selectedState.value.isEmpty) {
      issues.add('State');
    }
    if (cityController.text.trim().isEmpty) {
      issues.add('City');
    }
    if (pincodeController.text.trim().isEmpty) {
      issues.add('Pincode');
    }
    if (businessCategoryController.text.trim().isEmpty) {
      issues.add('Business category');
    }

    final logo = logoController.text.trim();
    if (logo.isNotEmpty &&
        !logo.startsWith('data:') &&
        !logo.startsWith('http://') &&
        !logo.startsWith('https://')) {
      issues.add('Logo URL (https://… or use Pick image)');
    }

    final invRaw = invoiceStartingNumberController.text.trim();
    final invoiceNum = int.tryParse(invRaw);
    if (invRaw.isEmpty || invoiceNum == null || invoiceNum < 1) {
      issues.add('Invoice starting number (positive whole number, e.g. 1)');
    }

    if (isDueDateEnabled.value) {
      final dueRaw = dueDateDaysController.text.trim();
      final dueDays = int.tryParse(dueRaw);
      if (dueRaw.isEmpty || dueDays == null || dueDays < 1) {
        issues.add('Due date in days (positive number when due date is on)');
      }
    }

    if (isExtraNotesEnabled.value) {
      if (extraNote1Controller.text.trim().isEmpty &&
          extraNote2Controller.text.trim().isEmpty &&
          extraNote3Controller.text.trim().isEmpty) {
        issues.add('At least one extra note (Extra Notes is enabled)');
      }
    }

    return issues;
  }

  bool _applyCompanyFormValidationGate() {
    final formState = formKey.currentState;
    final issues = _collectCompanyFormIssues();
    final formOk = formState?.validate() ?? false;

    if (issues.isNotEmpty) {
      final seconds = (4 + issues.length).clamp(5, 12);
      showCustomSnackbar(
        title: 'Please complete',
        message: '• ${issues.join('\n• ')}',
        baseColor: AppColors.errorColor,
        icon: Icons.edit_note,
        duration: Duration(seconds: seconds),
        position: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!formOk) {
      showCustomSnackbar(
        title: 'Form',
        message:
            'Fix invalid values in fields marked in red (e.g. format or logo URL).',
        baseColor: AppColors.errorColor,
        icon: Icons.edit_note,
        duration: const Duration(seconds: 4),
        position: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  /// Firebase [User.email] is sometimes null; prefs may still have registration email.
  Future<String?> _resolveUserEmailForSheets(User user) async {
    final authEmail = user.email?.trim();
    if (authEmail != null && authEmail.isNotEmpty) return authEmail;
    try {
      final pref = await sharedPreferencesHelper.getPrefData('email');
      final p = pref?.trim();
      if (p != null && p.isNotEmpty) return p;
    } catch (_) {}
    return null;
  }

  Future<void> registerCompany() async {
    if (!_applyCompanyFormValidationGate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      showCustomSnackbar(
        title: "Error",
        message: "Please login first!",
        baseColor: AppColors.errorColor,
        icon: Icons.error,
        position: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final codeOk = await checkCompanyCodeAvailability(companyCodeController.text);
      if (codeOk == null) {
        isLoading.value = false;
        showCustomSnackbar(
          title: "Could not verify code",
          message:
              "Company code check failed. Check internet and try again. / કોડ તપાસ ન થઈ શકી — ઇન્ટરનેટ તપાસો.",
          baseColor: AppColors.errorColor,
          icon: Icons.wifi_off_outlined,
          duration: const Duration(seconds: 5),
          position: SnackPosition.BOTTOM,
        );
        return;
      }
      if (!codeOk) {
        isLoading.value = false;
        showCustomSnackbar(
          title: "Same company code",
          message:
              "આ company code તમારા એકાઉન્ટમાં પહેલેથી નોંધાયેલો છે — બીજો code લખો.\nThis code is already used on your account. Please choose a different company code.",
          baseColor: AppColors.errorColor,
          icon: Icons.business_center_outlined,
          duration: const Duration(seconds: 6),
          position: SnackPosition.BOTTOM,
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
        'enablePurchaseFeature': selectedBusinessType.value.trim() == 'Trading',

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

      AppConstants.isChallan.value = isChallanEnabled.value;
      AppConstants.withGST.value = isGstEnabled.value;
      await AppConstants.setChallanEnabled(isChallanEnabled.value);
      await AppConstants.setCashMemoEnabled(isCashMemoEnabled.value);
      await AppConstants.setGstEnabled(isGstEnabled.value);
      await AppConstants.setBusinessType(selectedBusinessType.value); // 🆕 NEW
      await AppConstants.setEnablePurchaseFeature(
          selectedBusinessType.value.trim() == 'Trading');

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

      /// Shown after navigation — Get.offAll clears overlays; snackbar before it never appears.
      String? sheetSetupWarning;

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

          final sheetEmail = await _resolveUserEmailForSheets(user);
          if (sheetEmail == null || sheetEmail.isEmpty) {
            print('[InvoiceSathi:SheetCreate] skip: no email for user ${user.uid} (auth + prefs empty)');
            sheetSetupWarning =
                'Google Sheet બન્યું નથી: એકાઉન્ટ પર email નથી. Firebase Auth માં email ઉમેરો અથવા ફરી login કરો.';
          } else {
            // 🚀 ૧. નવી મેથડ કોલ કરો જે Spreadsheet અને Invoices ફોલ્ડર બંને બનાવશે
            final result = await GoogleSheetService.createNewUserSpreadsheet(
              user.uid,
              accessToken: accessToken,
              userEmail: sheetEmail,
              username: user.displayName ?? sheetEmail.split('@').first,
            );

            if (result != null && result.$1.isNotEmpty) {
              final newSpreadsheetId = result.$1;
              final mainFolderId = result.$2;
              final pdfFolderId = result.$3;

              AppConstants.spreadsheetId = newSpreadsheetId;
              await sharedPreferencesHelper.storePrefData("spreadsheetId", newSpreadsheetId);

              final fy = FinancialYearHelper.currentFy();
              await AppConstants.setActiveFy(fy);

              await _firestore.collection("users").doc(user.uid).update({
                "spreadsheetId": newSpreadsheetId,
                "activeFy": fy,
                "spreadsheetIdsByFy": {fy: newSpreadsheetId},
                "mainFolderId": mainFolderId,
                "pdfFolderId": pdfFolderId,
              });

              await companyRef.update({
                "spreadsheetId": newSpreadsheetId,
                "pdfFolderId": pdfFolderId,
              });

              await GoogleSheetService.ensureSheetsExist();

              print("✅ Drive Setup Complete: Sheet and PDF folder created.");
            } else {
              print('[InvoiceSathi:SheetCreate] company registration: createNewUserSpreadsheet returned null');
              sheetSetupWarning =
                  'Google Sheet બન્યું નથી. Logcat માં ફિલ્ટર: InvoiceSathi (અથવા tag InvoiceSathi). Service Account JSON અને Google Cloud APIs તપાસો.';
            }
          }
        } catch (e) {
          print('createNewUserSpreadsheet during company registration failed: $e');
          sheetSetupWarning = 'Google Sheet setup error: $e';
        }
      }

      await Get.offAllNamed(DashboardScreen.pageId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomSnackbar(
          title: "Success",
          message: "Company registered successfully!",
          icon: Icons.done_all,
          baseColor: AppColors.greenColor2,
          position: SnackPosition.BOTTOM,
        );
      });

      if (sheetSetupWarning != null && sheetSetupWarning.isNotEmpty) {
        final String sheetMsg = sheetSetupWarning;
        await Future.delayed(const Duration(milliseconds: 900));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCustomSnackbar(
            title: 'Google Sheet',
            message: sheetMsg,
            baseColor: AppColors.errorColor,
            icon: Icons.warning_amber_rounded,
            duration: const Duration(seconds: 8),
            position: SnackPosition.BOTTOM,
          );
        });
      }

    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Registration failed: ${e.toString()}",
        icon: Icons.close,
        baseColor: AppColors.appColor,
        position: SnackPosition.BOTTOM,
      );
      print('Company registration error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCompany() async {
    if (!_applyCompanyFormValidationGate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      showCustomSnackbar(
        title: "Error",
        message: "Please login first!",
        baseColor: AppColors.errorColor,
        icon: Icons.error,
        position: SnackPosition.BOTTOM,
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
          position: SnackPosition.BOTTOM,
        );
        return;
      }

      final invoiceStartNum = int.tryParse(invoiceStartingNumberController.text.trim()) ?? 1;
      final existingData = docSnapshot.data() ?? {};
      final currentInvoiceNum = existingData['currentInvoiceNumber'] as int?;
      final bool purchaseFeatureForFirestore = selectedBusinessType.value.trim() == 'Trading'
          ? (existingData['enablePurchaseFeature'] != false)
          : false;

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
        'enablePurchaseFeature': purchaseFeatureForFirestore,
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

          final sheetEmail = await _resolveUserEmailForSheets(user);
          if (sheetEmail == null || sheetEmail.isEmpty) {
            print('[InvoiceSathi:SheetCreate] update company: no email for sheets');
          } else {
          final result = await GoogleSheetService.createNewUserSpreadsheet(
            user.uid,
            accessToken: accessToken,
            userEmail: sheetEmail,
            username: user.displayName ?? sheetEmail.split('@').first,
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
          } else {
            print('[InvoiceSathi:SheetCreate] company update: createNewUserSpreadsheet returned null');
            showCustomSnackbar(
              title: 'Google Sheet',
              message:
                  'Sheet was not created. Search logs for: InvoiceSathi:SheetCreate',
              baseColor: AppColors.errorColor,
              icon: Icons.warning_amber_rounded,
              position: SnackPosition.BOTTOM,
            );
          }
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
        position: SnackPosition.BOTTOM,
      );

      AppConstants.isChallan.value = isChallanEnabled.value;
      AppConstants.withGST.value = isGstEnabled.value;
      await AppConstants.setChallanEnabled(isChallanEnabled.value);
      await AppConstants.setCashMemoEnabled(isCashMemoEnabled.value);
      await AppConstants.setGstEnabled(isGstEnabled.value);
      await AppConstants.setBusinessType(selectedBusinessType.value); // 🆕 NEW
      await AppConstants.setEnablePurchaseFeature(purchaseFeatureForFirestore);
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
        position: SnackPosition.BOTTOM,
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

