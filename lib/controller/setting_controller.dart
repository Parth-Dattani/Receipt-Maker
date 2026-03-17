import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../controller/controller.dart';
import '../screen/setting/widgets/widgets.dart';

/// PDF template IDs stored in Firestore company document (selectedPdfTemplate).
const String kPdfTemplateModern = 'Modern';
const String kPdfTemplateClassic = 'Classic';
const String kPdfTemplateMinimal = 'Minimal';
const String kPdfTemplateProfessional = 'Professional';
const String kPdfTemplateElegant = 'Elegant';

/// Logo position on invoice PDF (companyLogoPosition).
const String kLogoPositionLeft = 'Left';
const String kLogoPositionCenter = 'Center';
const String kLogoPositionRight = 'Right';
const String kLogoPositionTopLeft = 'TopLeft';
const String kLogoPositionTopCenter = 'TopCenter';

class SettingsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var currencySymbol = '\$'.obs;
  var isGstEnabled = false.obs;
  var isPanEnabled = false.obs;
  var isBankDetailEnabled = false.obs;
  var selectedBillFormat = 1.obs;
  var startInvoiceNumber = 1.obs;
  var selectedLanguage = 'English'.obs;
  var termsAndConditions = ''.obs;
  var selectedTemplate = 1.obs;

  /// Invoice PDF theme (5 options). Saved in Firestore company doc.
  var selectedPdfTemplate = kPdfTemplateClassic.obs;
  var isLoadingPdfTemplate = false.obs;

  /// Company logo position on invoice: Left, Center, Right, TopLeft, TopCenter.
  var selectedLogoPosition = kLogoPositionCenter.obs;
  var isLoadingLogoPosition = false.obs;

  // Form controllers
  final currencyController = TextEditingController();
  final startInvoiceController = TextEditingController();
  final termsController = TextEditingController();

  // Currency options
  final List<String> currencyOptions = [
    '\$', '€', '£', '¥', '₹', '₦', '₽', '₴', '₩', '₪', '₡', '₨'
  ];

  // Language options
  final List<String> languageOptions = [
    'English', 'Hindi', 'Spanish', 'French', 'German', 'Italian',
    'Portuguese', 'Chinese', 'Japanese', 'Korean', 'Arabic'
  ];

  // Bill formats
  final List<Map<String, String>> billFormats = [
    {'id': '1', 'name': 'Standard Invoice', 'description': 'Basic invoice format'},
    {'id': '2', 'name': 'Tax Invoice', 'description': 'Invoice with tax details'},
    {'id': '3', 'name': 'Proforma Invoice', 'description': 'Quotation format'},
    {'id': '4', 'name': 'Commercial Invoice', 'description': 'For export/import'},
  ];

  // Invoice templates
  final List<Map<String, dynamic>> invoiceTemplates = [
    {
      'id': 1,
      'name': 'Classic Blue',
      'description': 'Professional blue theme',
      'color': Colors.blue,
      'preview': 'assets/templates/classic_blue.png'
    },
    {
      'id': 2,
      'name': 'Modern Green',
      'description': 'Clean green design',
      'color': Colors.green,
      'preview': 'assets/templates/modern_green.png'
    },
    {
      'id': 3,
      'name': 'Corporate Gray',
      'description': 'Minimalist gray theme',
      'color': Colors.grey,
      'preview': 'assets/templates/corporate_gray.png'
    },
    {
      'id': 4,
      'name': 'Elegant Purple',
      'description': 'Stylish purple design',
      'color': Colors.purple,
      'preview': 'assets/templates/elegant_purple.png'
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadSettings();

    // Set initial values
    currencyController.text = currencySymbol.value;
    startInvoiceController.text = startInvoiceNumber.value.toString();
    termsController.text = termsAndConditions.value;

    // Add listeners for dependent fields
    ever(isGstEnabled, (bool enabled) {
      if (enabled) {
        isPanEnabled.value = true;
        isBankDetailEnabled.value = true;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    try {
      Get.find<AuthController>().loadUserFyData();
    } catch (_) {}
    loadPdfTemplateFromFirestore();
  }

  static const _validTemplates = [
    kPdfTemplateModern, kPdfTemplateClassic, kPdfTemplateMinimal,
    kPdfTemplateProfessional, kPdfTemplateElegant,
  ];
  static const _validLogoPositions = [
    kLogoPositionLeft, kLogoPositionCenter, kLogoPositionRight,
    kLogoPositionTopLeft, kLogoPositionTopCenter,
  ];

  /// Load selectedPdfTemplate and companyLogoPosition from Firestore company document.
  Future<void> loadPdfTemplateFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    final companyId = AppConstants.companyId;
    if (user == null || companyId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        final v = data?['selectedPdfTemplate']?.toString();
        if (v != null && _validTemplates.contains(v)) {
          selectedPdfTemplate.value = v;
        }
        final pos = data?['companyLogoPosition']?.toString();
        if (pos != null && _validLogoPositions.contains(pos)) {
          selectedLogoPosition.value = pos;
        }
      }
    } catch (e) {
      print('loadPdfTemplateFromFirestore: $e');
    }
  }

  /// Save selected PDF theme to Firestore company document.
  Future<void> updatePdfTemplate(String template) async {
    if (!_validTemplates.contains(template)) return;
    final user = FirebaseAuth.instance.currentUser;
    final companyId = AppConstants.companyId;
    if (user == null || companyId.isEmpty) return;
    isLoadingPdfTemplate.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId)
          .update({'selectedPdfTemplate': template});
      selectedPdfTemplate.value = template;
      Get.snackbar(
        'Invoice theme',
        'Set to $template',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('updatePdfTemplate: $e');
      Get.snackbar('Error', 'Could not save theme', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isLoadingPdfTemplate.value = false;
    }
  }

  /// Save company logo position to Firestore company document.
  Future<void> updateLogoPosition(String position) async {
    if (!_validLogoPositions.contains(position)) return;
    final user = FirebaseAuth.instance.currentUser;
    final companyId = AppConstants.companyId;
    if (user == null || companyId.isEmpty) return;
    isLoadingLogoPosition.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId)
          .update({'companyLogoPosition': position});
      selectedLogoPosition.value = position;
      Get.snackbar(
        'Logo position',
        'Set to $position',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('updateLogoPosition: $e');
      Get.snackbar('Error', 'Could not save logo position', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isLoadingLogoPosition.value = false;
    }
  }

  void loadSettings() async {
    try {
      isLoading.value = true;

      // Simulate loading from SharedPreferences or API
      await Future.delayed(Duration(seconds: 1));

      // Load saved settings (mock data)
      currencySymbol.value = '₹';
      isGstEnabled.value = true;
      isPanEnabled.value = true;
      isBankDetailEnabled.value = true;
      selectedBillFormat.value = 1;
      startInvoiceNumber.value = 1001;
      selectedLanguage.value = 'English';
      termsAndConditions.value = 'Payment due within 30 days. Late payments may incur additional charges.';
      selectedTemplate.value = 1;

      // Update controllers
      currencyController.text = currencySymbol.value;
      startInvoiceController.text = startInvoiceNumber.value.toString();
      termsController.text = termsAndConditions.value;

    } catch (error) {
      Get.snackbar(
        'Error',
        'Failed to load settings: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateCurrency(String currency) {
    currencySymbol.value = currency;
    currencyController.text = currency;
  }

  void updateGstStatus(bool enabled) {
    isGstEnabled.value = enabled;
    if (enabled) {
      isPanEnabled.value = true;
      isBankDetailEnabled.value = true;
      _showGstEnabledDialog();
    }
  }

  void updatePanStatus(bool enabled) {
    if (isGstEnabled.value && !enabled) {
      Get.snackbar(
        'Warning',
        'PAN is mandatory when GST is enabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    isPanEnabled.value = enabled;
  }

  void updateBankDetailStatus(bool enabled) {
    if (isGstEnabled.value && !enabled) {
      Get.snackbar(
        'Warning',
        'Bank details are mandatory when GST is enabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    isBankDetailEnabled.value = enabled;
  }

  void updateBillFormat(int format) {
    selectedBillFormat.value = format;
  }

  void updateStartInvoiceNumber() {
    int? number = int.tryParse(startInvoiceController.text);
    if (number != null && number > 0) {
      startInvoiceNumber.value = number;
    } else {
      startInvoiceController.text = startInvoiceNumber.value.toString();
      Get.snackbar(
        'Error',
        'Please enter a valid invoice number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void updateLanguage(String language) {
    selectedLanguage.value = language;
  }

  void updateTermsAndConditions() {
    termsAndConditions.value = termsController.text;
  }

  void updateTemplate(int templateId) {
    selectedTemplate.value = templateId;
  }

  void saveSettings() async {
    try {
      isLoading.value = true;

      // Update from controllers
      updateStartInvoiceNumber();
      updateTermsAndConditions();

      // Simulate saving to SharedPreferences or API
      await Future.delayed(Duration(seconds: 1));

      Get.snackbar(
        'Success',
        'Settings saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (error) {
      Get.snackbar(
        'Error',
        'Failed to save settings: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetSettings() {
    Get.defaultDialog(
      title: 'Reset Settings',
      middleText: 'Are you sure you want to reset all settings to default?',
      textConfirm: 'Reset',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Reset to defaults
        currencySymbol.value = '\$';
        isGstEnabled.value = false;
        isPanEnabled.value = false;
        isBankDetailEnabled.value = false;
        selectedBillFormat.value = 1;
        startInvoiceNumber.value = 1;
        selectedLanguage.value = 'English';
        termsAndConditions.value = '';
        selectedTemplate.value = 1;

        // Update controllers
        currencyController.text = currencySymbol.value;
        startInvoiceController.text = startInvoiceNumber.value.toString();
        termsController.clear();

        Get.back();
        Get.snackbar(
          'Success',
          'Settings reset to default!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      },
    );
  }

  void _showGstEnabledDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, color: Colors.blue, size: 48),
              SizedBox(height: 16),
              Text(
                'GST Enabled',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Since GST is enabled, PAN and Bank Details are now mandatory for invoice generation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Got it!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void previewTemplate(int templateId) {
    Get.to(() => TemplatePreviewScreen(templateId: templateId));
  }

  @override
  void onClose() {
    currencyController.dispose();
    startInvoiceController.dispose();
    termsController.dispose();
    super.onClose();
  }
}
