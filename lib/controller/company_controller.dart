import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/controller/bash_controller.dart';
import 'package:demo_prac_getx/screen/dashboard/dashboard_screen.dart';
import 'package:demo_prac_getx/screen/screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../widgets/custom_snackbar.dart';
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
  final authorisedSignatureController = TextEditingController();

  // 🆕 NEW: Invoice starting number controller
  final invoiceStartingNumberController = TextEditingController(text: '1');

  var isChallanEnabled = false.obs;
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

    final args = Get.arguments;
    print('Arguments received: $args');

    if (args != null && args['isEdit'] == true && args['companyData'] != null) {
      isEditMode.value = true;
      existingCompanyId = args['companyId'];
      print('Edit mode enabled with company ID: $existingCompanyId');
      _populateFields(args['companyData']);
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

        Get.offNamed(
          CustomerRegistrationScreen.pageId,
          arguments: {
            'companyId': companyDocs.docs.first.id,
            'companyData': currentCompany.value,
          },
        );
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
    businessCategoryController.text = companyData['businessCategory'] ?? '';
    selectedBusinessType.value = companyData['businessType'] ?? '';
    gstController.text = companyData['gst'] ?? '';
    panController.text = companyData['pan'] ?? '';
    phoneController.text = companyData['phone'] ?? '';
    bankNameController.text = companyData['bankName'] ?? '';
    ifscController.text = companyData['ifsc'] ?? '';
    accountNumberController.text = companyData['accountNumber'] ?? '';
    authorisedSignatureController.text = companyData['authorisedSignature'] ?? '';
    isChallanEnabled.value = companyData['isChallanEnabled'] ?? false;
    isGstEnabled.value = companyData['isGstEnabled'] ?? false;

    invoiceStartingNumberController.text = (companyData['invoiceStartingNumber'] ?? 1).toString();
    print('Invoice Starting Number Controller: ${invoiceStartingNumberController.text}'); // Add this


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
        'bankName': bankNameController.text.trim(),
        'ifsc': ifscController.text.trim().toUpperCase(),
        'accountNumber': accountNumberController.text.trim(),
        'authorisedSignature': authorisedSignatureController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isChallanEnabled': isChallanEnabled.value,
        'isGstEnabled': isGstEnabled.value,

        // 🆕 NEW: Store invoice starting number
        'invoiceStartingNumber': invoiceStartNum,
        'currentInvoiceNumber': invoiceStartNum, // Current counter
      };

      await companyRef.set(companyData);

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
      await AppConstants.setGstEnabled(isGstEnabled.value);
      await AppConstants.setBusinessType(selectedBusinessType.value); // 🆕 NEW

      Get.toNamed(
        CustomerRegistrationScreen.pageId,
        arguments: {
          'companyId': companyRef.id,
          'companyData': companyData,
        },
      );

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
        'bankName': bankNameController.text.trim(),
        'ifsc': ifscController.text.trim().toUpperCase(),
        'accountNumber': accountNumberController.text.trim(),
        'authorisedSignature': authorisedSignatureController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isChallanEnabled': isChallanEnabled.value,
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
      await AppConstants.setGstEnabled(isGstEnabled.value);
      await AppConstants.setBusinessType(selectedBusinessType.value); // 🆕 NEW


      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isOverlaysOpen) {
          Get.back(result: true); // Pass result indicating update success
          Future.delayed(const Duration(milliseconds: 200), () => Get.back(result: true));
        } else {
          Get.back(result: true);
        }
      });
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
    authorisedSignatureController.dispose();
    invoiceStartingNumberController.dispose(); // 🆕 NEW
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

