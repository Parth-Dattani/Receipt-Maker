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
/// Classic variants that also control logo layout (replaces Logo Position setting).
const String kPdfTemplateClassicLeftLogo = 'ClassicLeftLogo';
const String kPdfTemplateClassicRightLogo = 'ClassicRightLogo';
const String kPdfTemplateMinimal = 'Minimal';
const String kPdfTemplateProfessional = 'Professional';
const String kPdfTemplateElegant = 'Elegant';


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
  var isWhatsappDirectShare = false.obs;
  var isLoadingWhatsappSetting = false.obs;

  /// Invoice PDF theme (5 options). Saved in Firestore company doc.
  var selectedPdfTemplate = kPdfTemplateClassic.obs;
  var isLoadingPdfTemplate = false.obs;

  // Form controllers
  final currencyController = TextEditingController();
  final startInvoiceController = TextEditingController();
  final termsController = TextEditingController();
  var allowDuplicateItems = false.obs;
  var enableCustomerOrderFeature = false.obs;
  var isAdmin = false.obs;
  var isLoadingDuplicateItems = false.obs;
  var isLoadingCustomerOrderFeature = false.obs;

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
    loadAllowDuplicateItems();
    loadIsAdmin();
    loadEnableCustomerOrderFeature();
    loadWhatsappSettings();
  }

  Future<void> loadWhatsappSettings() async {
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
        isWhatsappDirectShare.value = doc.data()?['isWhatsappDirectShare'] == true;
        // AppConstants માં પણ સેટ કરી દઈએ જેથી ઈન્વોઈસ સ્ક્રીન પર સીધું વાપરી શકાય
        AppConstants.setIsWhatsappDirectShare(isWhatsappDirectShare.value);
      }
    } catch (e) {
      print('Error loading WhatsApp settings: $e');
    }
  }

  Future<void> updateWhatsappDirectShare(bool val) async {
    final user = FirebaseAuth.instance.currentUser;
    final companyId = AppConstants.companyId;
    if (user == null || companyId.isEmpty) return;

    isLoadingWhatsappSetting.value = true;
    try {
      isWhatsappDirectShare.value = val;
      await AppConstants.setIsWhatsappDirectShare(val);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId)
          .update({'isWhatsappDirectShare': val});

      Get.snackbar(
        'Success',
        val ? 'WhatsApp Direct Share Enabled' : 'WhatsApp Direct Share Disabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: val ? Colors.green.shade100 : Colors.orange.shade100,
      );
    } catch (e) {
      print('updateWhatsappDirectShare Error: $e');
    } finally {
      isLoadingWhatsappSetting.value = false;
    }
  }

  Future<void> updateAllowDuplicateItems(bool val) async {
    final user = FirebaseAuth.instance.currentUser;
    final companyId = AppConstants.companyId;
    if (user == null || companyId.isEmpty) return;
    isLoadingDuplicateItems.value = true;
    try {
      // Update locally immediately so that invoice screens using AppConstants
      // can react right away (before Firestore round-trip finishes).
      allowDuplicateItems.value = val;
      await AppConstants.setAllowDuplicateItems(val);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId)
          .update({'allowDuplicateItems': val});

    } catch (e) {
      print('updateAllowDuplicateItems: $e');
    } finally {
      isLoadingDuplicateItems.value = false;
    }
  }

  Future<void> updateEnableCustomerOrderFeature(bool val) async {
    if (!isAdmin.value) return; // Non-admin cannot change this feature
    final user = FirebaseAuth.instance.currentUser;
    final companyId = AppConstants.companyId;
    if (user == null || companyId.isEmpty) return;
    isLoadingCustomerOrderFeature.value = true;
    try {
      // Update locally immediately so UI reacts before Firestore round-trip.
      enableCustomerOrderFeature.value = val;
      await AppConstants.setEnableCustomerOrderFeature(val);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId)
          .update({'enableCustomerOrderFeature': val});
    } catch (e) {
      print('updateEnableCustomerOrderFeature: $e');
    } finally {
      isLoadingCustomerOrderFeature.value = false;
    }
  }

  Future<void> loadAllowDuplicateItems() async {
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
        final val = doc.data()?['allowDuplicateItems'] == true;
        allowDuplicateItems.value = val;
        await AppConstants.setAllowDuplicateItems(val);
      }
    } catch (e) {
      print('loadAllowDuplicateItems: $e');
    }
  }

  Future<void> loadEnableCustomerOrderFeature() async {
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
        final val = doc.data()?['enableCustomerOrderFeature'] == true;
        enableCustomerOrderFeature.value = val;
        await AppConstants.setEnableCustomerOrderFeature(val);
      }
    } catch (e) {
      print('loadEnableCustomerOrderFeature: $e');
    }
  }

  Future<void> loadIsAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      isAdmin.value = doc.data()?['isAdmin'] == true;
    } catch (e) {
      print('loadIsAdmin: $e');
    }
  }


  static const _validTemplates = [
    kPdfTemplateModern, kPdfTemplateClassic, kPdfTemplateMinimal,
    kPdfTemplateProfessional, kPdfTemplateElegant,
    kPdfTemplateClassicLeftLogo, kPdfTemplateClassicRightLogo,
  ];

  /// Load selectedPdfTemplate from Firestore company document.
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
