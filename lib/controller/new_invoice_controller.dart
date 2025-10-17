import 'dart:convert';

import 'package:demo_prac_getx/screen/invoice/new_invoice_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../constant/constant.dart';
import '../model/model.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'controller.dart';


import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class NewInvoiceController extends GetxController {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final customerNameController = TextEditingController();
  final customerMobileController = TextEditingController();
  final customerEmailController = TextEditingController();
  final customerAddressController = TextEditingController();
  final customerPanController = TextEditingController();
  final customerGstController = TextEditingController();
  final invoiceNumberController = TextEditingController();
  final dueDateController = TextEditingController();
  final notesController = TextEditingController();
  final RxString selectedCustomerId = ''.obs;

  // Observable variables
  var isLoading = false.obs;
  var customers = <Map<String, dynamic>>[].obs;
  var items = <Map<String, dynamic>>[].obs;
  var itemList = <Item>[].obs;
  var invoiceList = <Invoice>[].obs;
  var invoiceItems = <InvoiceItem>[].obs;
  var dueDate = DateTime.now().obs;
  var showCustomerForm = false.obs;
  var customerCount = 0.obs;
  final invoiceType = InvoiceType.invoice.obs;

  // Edit mode variables
  final RxBool isEditMode = false.obs;
  final RxString editingInvoiceId = ''.obs;
  final Rxn<Map<String, dynamic>> originalInvoiceData = Rxn<Map<String, dynamic>>();
  final RxInt originalItemsCount = 0.obs;

  // NEW: Quotation conversion variables
  final RxBool isFromQuotation = false.obs;
  final RxString sourceQuotationId = ''.obs;

  // Calculated values
  var subtotal = 0.0.obs;
  var taxAmount = 0.0.obs;
  var totalAmount = 0.0.obs;
  var gstAmount = 0.0.obs;

  // Company data
  var companyData = <String, dynamic>{}.obs;

  // Challan related variables
  var challanList = <Challan>[].obs;
  var challanItems = <ChallanItem>[].obs;
  var challanDate = DateTime.now().obs;
  final Rx<Challan?> selectedChallan = Rx<Challan?>(null);
  final RxList<Challan> allChallans = <Challan>[].obs;
  final RxList<String> customerNames = <String>[].obs;
  final RxString selectedCustomerForInvoice = ''.obs;
  final RxList<Challan> selectedCustomerChallans = <Challan>[].obs;
  final RxBool createFromChallan = false.obs;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Date controllers
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  var selectedFromDate = DateTime.now().subtract(Duration(days: 30)).obs;
  var selectedToDate = DateTime.now().obs;

  var paymentStatus = 'Pending'.obs;

  // Performance optimization variables
  bool _isEssentialDataLoaded = false;
  bool _isSecondaryDataLoaded = false;
  bool _isTertiaryDataLoaded = false;
  bool _initializationLock = false;
  Timer? _debounceTimer;

  // Caching mechanism
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = Duration(minutes: 10);

  // Pagination variables
  var currentChallanPage = 0;
  final challanPageSize = 20;
  var hasMoreChallans = true;
  var priceControllers = <TextEditingController>[].obs;
  var quantityControllers = <TextEditingController>[].obs;

  bool get isInEditMode => isEditMode.value && editingInvoiceId.value.isNotEmpty;

  final serviceDescription = ''.obs;
  final TextEditingController serviceDescriptionController = TextEditingController();

  final receivedAmountController = TextEditingController();
  var receivedAmount = 0.0.obs;
  var pendingAmount = 0.0.obs;

  var invoiceDate = DateTime.now().obs;  // Invoice issue date
  var paymentDueDate = DateTime.now().add(Duration(days: 15)).obs;  // Payment due date
  final invoiceDateController = TextEditingController();
  final paymentDueDateController = TextEditingController();


  @override
  void onInit() {
    super.onInit();

    // Set up date controllers
    invoiceDateController.text = _formatDateForDisplay(invoiceDate.value);
    paymentDueDateController.text = _formatDateForDisplay(paymentDueDate.value);
    fromDateController.text = _formatDateForDisplay(selectedFromDate.value);
    toDateController.text = _formatDateForDisplay(selectedToDate.value);

    // Check if coming from quotation conversion FIRST
    final arguments = Get.arguments;
    if (arguments != null &&
        arguments is Map &&
        arguments['isFromQuotation'] == true) {

      print("🔄 Quotation conversion detected in onInit");
      isFromQuotation.value = true;

      // Load essential data first, then handle quotation
      _loadEssentialDataWithoutInit().then((_) {
        _handleQuotationConversion();
      });

    } else {
      // Handle arguments for edit mode only
      _handleArguments();

      if (!isEditMode.value) {
        // Normal new invoice flow
        _loadEssentialData();
      } else {
        // Edit mode flow
        _loadEssentialData();
        if (invoiceItems.isEmpty) {
          addNewItem();
        }
      }
    }

    // Load other data after a delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSecondaryData();
    });
  }

// Updated _handleArguments - no longer handles quotation conversion
  void _handleArguments() {
    print("🔍 Starting _handleArguments...");

    final arguments = Get.arguments;
    print("📥 Raw arguments: $arguments");
    print("📊 Arguments type: ${arguments.runtimeType}");

    // Handle direct Invoice object
    if (arguments is Invoice) {
      print("🏷️ Arguments is directly an Invoice object - treating as edit mode");

      isEditMode.value = true;
      editingInvoiceId.value = arguments.invoiceId ?? '';

      try {
        originalInvoiceData.value = _invoiceToMap(arguments);
        _prefillInvoiceData();
      } catch (e, stackTrace) {
        print("❌ Error processing direct Invoice: $e");
        print("📄 Stack trace: $stackTrace");
      }
    }
    // Handle Map arguments for EDIT MODE ONLY
    else if (arguments != null && arguments is Map) {
      print("✅ Arguments is a valid Map");
      print("🗝️ Arguments keys: ${arguments.keys.toList()}");

      // Check for edit mode
      if (arguments['editMode'] == true) {
        print("✅ Entering edit mode");

        isEditMode.value = true;
        editingInvoiceId.value = arguments['invoiceId']?.toString() ?? '';

        if (arguments['invoiceData'] != null) {
          if (arguments['invoiceData'] is Invoice) {
            final invoiceObj = arguments['invoiceData'] as Invoice;
            try {
              originalInvoiceData.value = _invoiceToMap(invoiceObj);
              _prefillInvoiceData();
            } catch (e, stackTrace) {
              print("❌ Error converting Invoice to Map: $e");
              print("📄 Stack trace: $stackTrace");
            }
          }
          else if (arguments['invoiceData'] is Map) {
            try {
              originalInvoiceData.value = Map<String, dynamic>.from(arguments['invoiceData'] as Map);
              _prefillInvoiceData();
            } catch (e, stackTrace) {
              print("❌ Error processing Map data: $e");
              print("📄 Stack trace: $stackTrace");
            }
          }
        }
      }
    }

    print("🏁 Finished _handleArguments");
    print("📊 Final state:");
    print("   - isEditMode.value: ${isEditMode.value}");
    print("   - editingInvoiceId.value: '${editingInvoiceId.value}'");
  }

  void _handleQuotationConversion() async {  // Add async here
    final arguments = Get.arguments;

    if (arguments != null &&
        arguments is Map &&
        arguments['isFromQuotation'] == true) {

      print("🔄 Loading quotation data for conversion...");

      final Invoice quotation = arguments['quotation'];
      final List<InvoiceItem> quotationItems = arguments['quotationItems'];
      final String originalQuotationId = arguments['quotationId'] ?? quotation.invoiceId;

      isFromQuotation.value = true;
      sourceQuotationId.value = originalQuotationId;

      await _prefillFromQuotation(quotation, quotationItems, originalQuotationId);  // Add await
    }
  }

  String formatOriginalInvoiceDate() {
    final invoiceData = originalInvoiceData.value;
    // Try to get issueDate first (invoice date)
    if (invoiceData?['issueDate'] != null) {
      if (invoiceData!['issueDate'] is DateTime) {
        return 'Issued: ${_formatDate(invoiceData['issueDate'] as DateTime)}';
      } else if (invoiceData['issueDate'] is String) {
        try {
          DateTime date = DateTime.parse(invoiceData['issueDate'] as String);
          return 'Issued: ${_formatDate(date)}';
        } catch (e) {
          return invoiceData['issueDate'] as String;
        }
      }
    }

    // Fallback to dueDate if issueDate not available
    if (invoiceData?['dueDate'] != null) {
      if (invoiceData!['dueDate'] is DateTime) {
        return 'Due: ${_formatDate(invoiceData['dueDate'] as DateTime)}';
      } else if (invoiceData['dueDate'] is String) {
        try {
          DateTime date = DateTime.parse(invoiceData['dueDate'] as String);
          return 'Due: ${_formatDate(date)}';
        } catch (e) {
          return invoiceData['dueDate'] as String;
        }
      }
    }

    return 'N/A';
  }

  Future<void> _prefillFromQuotation(
      Invoice quotation,
      List<InvoiceItem> items,
      String originalQuotationId
      ) async {
    try {
      print("📋 Pre-filling invoice from quotation $originalQuotationId");

      // 🆕 CRITICAL: Generate NEW invoice number FIRST
      final newInvoiceNumber = await getNextInvoiceNumber();
      invoiceNumberController.text = newInvoiceNumber;
      print("🆕 Generated new invoice number: $newInvoiceNumber");

      // ✅ Set invoice date to today
      DateTime today = DateTime.now();
      invoiceDate.value = today;
      invoiceDateController.text = _formatDate(today);

      // ✅ Set payment due date to 15 days from today
      paymentDueDate.value = today.add(Duration(days: 15));
      paymentDueDateController.text = _formatDate(paymentDueDate.value);

      // Set customer info
      selectedCustomerId.value = quotation.customerId ?? '';
      customerNameController.text = quotation.customerName ?? '';
      customerMobileController.text = quotation.mobile ?? '';
      customerEmailController.text = quotation.customerEmail ?? '';
      customerAddressController.text = quotation.customerAddress ?? '';
      // ✅ CRITICAL FIX: Always fetch complete customer details from Firestore
      // This ensures PAN and GST are loaded even if not in the quotation
      if (quotation.customerId != null && quotation.customerId!.isNotEmpty) {
        print("🔍 Fetching complete customer details for ID: ${quotation.customerId}");
        await _fetchCustomerDetailsById(quotation.customerId!);
      } else {
        print("⚠️ No customer ID available, using quotation data only");
        customerPanController.text = quotation.customerPan ?? '';
        customerGstController.text = quotation.customerGst ?? '';
      }

      if (quotation.dueDate != null) {
        dueDate.value = quotation.dueDate!;
        dueDateController.text = _formatDate(quotation.dueDate!);
      } else if (quotation.issueDate != null) {
        // Fallback to issue date if due date is null
        dueDate.value = quotation.issueDate!;
        dueDateController.text = _formatDate(quotation.issueDate!);
      } else {
        // Last resort: use today's date
        dueDate.value = DateTime.now();
        dueDateController.text = _formatDate(DateTime.now());
        print("⚠️ Warning: No date found in quotation, using today's date");
      }

      print("📅 Invoice date: ${invoiceDate.value}");
      print("📅 Payment due date: ${paymentDueDate.value}");

      update();

      // Add note about conversion
      notesController.text = 'Quotation from: $originalQuotationId\n${quotation.notes ?? ''}';
      print("📝 Added conversion note");

      // Pre-fill items with proper customer ID
      invoiceItems.clear();
      for (var item in items) {
        // ✅ Create controller with existing description
        final descController = TextEditingController(text: item.description ?? '');

        invoiceItems.add(InvoiceItem(
          itemId: item.itemId,
          itemName: item.itemName ?? item.description,
          description: item.description ?? item.itemName,
          quantity: item.quantity,
          rate: item.rate,
          gstRate: item.gstRate ?? 0.0,
          gstAmount: item.gstAmount ?? 0.0,
          amountWithGst: item.amountWithGst ?? 0.0,
          totalPrice: item.totalPrice ?? (item.quantity * item.rate),
          customerId: quotation.customerId,
          unit: item.unit,
          descriptionController: descController,
        ));
      }

      // Initialize controllers for items
      quantityControllers.clear();
      priceControllers.clear();

      for (int i = 0; i < invoiceItems.length; i++) {
        quantityControllers.add(
            TextEditingController(text: invoiceItems[i].quantity.toString())
        );
        priceControllers.add(
            TextEditingController(text: invoiceItems[i].rate.toString())
        );
      }

      // Recalculate totals
      calculateTotals();

      // Show info message
      Get.snackbar(
        'Quotation Loaded',
        'Review and save to create invoice from quotation',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        icon: Icon(Icons.info_outline, color: Colors.blue.shade700),
        duration: Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );

      print("✅ Quotation data pre-filled successfully");
      print("   Invoice Number: ${invoiceNumberController.text}");
      print("   Customer: ${customerNameController.text}");
      print("   Items: ${invoiceItems.length}");
      print("   Total: ${totalAmount.value}");

      // ✅ DEBUG: Print customer data after fetching
      print("=== CUSTOMER DATA AFTER QUOTATION CONVERSION ===");
      print("Customer Name: '${customerNameController.text}'");
      print("Customer Mobile: '${customerMobileController.text}'");
      print("Customer Email: '${customerEmailController.text}'");
      print("Customer PAN: '${customerPanController.text}'");
      print("Customer GST: '${customerGstController.text}'");
      print("Customer Address: '${customerAddressController.text}'");
      print("================================================");

    } catch (e, stackTrace) {
      print("❌ Error pre-filling quotation data: $e");
      print("Stack trace: $stackTrace");

      Get.snackbar(
        'Error',
        'Could not load quotation data. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade700),
      );
    }
  }

  Map<String, dynamic> _invoiceToMap(Invoice invoice) {
    return {
      'invoiceId': invoice.invoiceId,
      'customerId': invoice.customerId,
      'customerName': invoice.customerName,
      'customerEmail': invoice.customerEmail,
      'customerPan': invoice.customerPan,
      'customerGst': invoice.customerGst,
      'mobile': invoice.mobile,
      'customerAddress': invoice.customerAddress,
      'issueDate': invoice.issueDate,
      'dueDate': invoice.dueDate,
      'subtotal': invoice.subtotal,
      'gstAmount': invoice.gstAmount,
      'totalAmount': invoice.totalAmount,
      'status': invoice.status,
      'notes': invoice.notes,
      'receivedAmount': invoice.receivedAmount ?? 0.0,
      'pendingAmount': invoice.pendingAmount ?? 0.0,
    };
  }

  void _prefillInvoiceData() {
    print("🔄 Starting _prefillInvoiceData...");

    final invoiceData = originalInvoiceData.value;
    if (invoiceData != null) {
      print("📋 Prefilling with data: $invoiceData");
      invoiceNumberController.text = invoiceData['invoiceId']?.toString() ?? '';

      // ✅ Handle invoice date (issueDate)
      if (invoiceData['issueDate'] != null) {
        if (invoiceData['issueDate'] is DateTime) {
          invoiceDate.value = invoiceData['issueDate'] as DateTime;
          invoiceDateController.text = _formatDate(invoiceData['issueDate'] as DateTime);
        } else if (invoiceData['issueDate'] is String) {
          try {
            invoiceDate.value = DateTime.parse(invoiceData['issueDate'] as String);
            invoiceDateController.text = _formatDate(invoiceDate.value);
          } catch (e) {
            print('Could not parse invoice date: ${invoiceData['issueDate']}');
          }
        }
      }

      // ✅ Handle payment due date
      if (invoiceData['dueDate'] != null) {
        if (invoiceData['dueDate'] is DateTime) {
          paymentDueDateController.text = _formatDate(invoiceData['dueDate'] as DateTime);
          paymentDueDate.value = invoiceData['dueDate'] as DateTime;
        } else if (invoiceData['dueDate'] is String) {
          paymentDueDateController.text = invoiceData['dueDate'] as String;
          try {
            paymentDueDate.value = DateTime.parse(invoiceData['dueDate'] as String);
          } catch (e) {
            print('Could not parse due date string: ${invoiceData['dueDate']}');
          }
        }
      }

      customerNameController.text = invoiceData['customerName']?.toString() ?? '';
      customerMobileController.text = invoiceData['mobile']?.toString() ?? '';
      customerEmailController.text = invoiceData['customerEmail']?.toString() ?? '';
      customerPanController.text = invoiceData['customerPan']?.toString() ?? '';
      customerGstController.text = invoiceData['customerGst']?.toString() ?? '';
      customerAddressController.text = invoiceData['customerAddress']?.toString() ?? '';

      if (invoiceData['customerId'] != null && invoiceData['customerId'].toString().isNotEmpty) {
        selectedCustomerId.value = invoiceData['customerId'].toString();
      }

      paymentStatus.value = invoiceData['status']?.toString() ?? 'Pending';
      notesController.text = invoiceData['notes']?.toString() ?? '';

      if (invoiceData['subtotal'] != null) {
        subtotal.value = double.tryParse(invoiceData['subtotal'].toString()) ?? 0.0;
      }
      if (invoiceData['gstAmount'] != null) {
        gstAmount.value = double.tryParse(invoiceData['gstAmount'].toString()) ?? 0.0;
      }
      if (invoiceData['totalAmount'] != null) {
        totalAmount.value = double.tryParse(invoiceData['totalAmount'].toString()) ?? 0.0;
      }

      // Add after paymentStatus assignment:
      if (invoiceData['receivedAmount'] != null) {
        receivedAmount.value = double.tryParse(invoiceData['receivedAmount'].toString()) ?? 0.0;
        receivedAmountController.text = receivedAmount.value.toString();
      }
      if (invoiceData['pendingAmount'] != null) {
        pendingAmount.value = double.tryParse(invoiceData['pendingAmount'].toString()) ?? 0.0;
      } else {
        pendingAmount.value = calculatedPendingAmount;
      }
      _loadExistingInvoiceItems();
    }




  }

  void _loadExistingInvoiceItems() async {
    if (editingInvoiceId.value.isEmpty) {
      print("⚠️ No editing invoice ID, skipping item load");
      return;
    }

    try {
      isLoading.value = true;
      print("📦 Loading existing items for invoice: ${editingInvoiceId.value}");

      GoogleSheetService.clearInvoiceItemCache(editingInvoiceId.value);

      final existingItems = await GoogleSheetService.getInvoiceItemsByInvoiceId(
          editingInvoiceId.value
      );

      originalItemsCount.value = existingItems.length;
      invoiceItems.clear();

      for (int i = 0; i < existingItems.length; i++) {
        final item = existingItems[i];
        // ✅ Create controller with existing description
        final descController = TextEditingController(text: item.description ?? '');


        final newItem = InvoiceItem(
          itemId: item.itemId ?? '',
          invoiceId: editingInvoiceId.value,
          customerId: item.customerId ?? _getValidCustomerId(),
          itemName: item.itemName ?? '',
          description: item.description ?? item.itemName ?? '',
          quantity: item.quantity,
          rate: item.rate ?? 0.0,
          gstRate: item.gstRate ?? 0.0,
          gstAmount: item.gstAmount ?? 0.0,
          amountWithGst: item.amountWithGst ?? 0.0,
          totalPrice: item.totalPrice ?? 0.0,
          challanId: item.challanId,
          unit: item.unit,
          descriptionController: descController,
        );

        invoiceItems.add(newItem);
      }

      quantityControllers.clear();
      priceControllers.clear();

      for (int i = 0; i < invoiceItems.length; i++) {
        quantityControllers.add(
            TextEditingController(text: invoiceItems[i].quantity.toString())
        );
        priceControllers.add(
            TextEditingController(text: invoiceItems[i].rate.toString())
        );
      }

      invoiceItems.refresh();
      update();
      calculateTotals();

      print('✅ Successfully loaded ${existingItems.length} items');
    } catch (e, stackTrace) {
      print('❌ Error loading existing items: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar('Error', 'Failed to load existing items: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> _loadEssentialData() async {
    if (_initializationLock) return;
    _initializationLock = true;

    try {
      await loadInvoices();

      if (!isEditMode.value && !isFromQuotation.value) {
        await initializeInvoice();
      }

      _isEssentialDataLoaded = true;
    } finally {
      _initializationLock = false;
    }
  }

  // NEW: Load essential data without initializing new invoice
  Future<void> _loadEssentialDataWithoutInit() async {
    if (_initializationLock) return;
    _initializationLock = true;

    try {
      await loadInvoices();
      _isEssentialDataLoaded = true;
    } finally {
      _initializationLock = false;
    }
  }

  Future<void> _loadSecondaryData() async {
    if (_isSecondaryDataLoaded) return;

    try {
      await loadCompanyData();
      await loadCustomers();
      await fetchItems2();
      _isSecondaryDataLoaded = true;
    } catch (e) {
      print("Error loading secondary data: $e");
    }
  }

  Future<void> _loadTertiaryData() async {
    if (_isTertiaryDataLoaded) return;

    try {
      await loadChallans();
      await loadChallansForInvoice();
      _isTertiaryDataLoaded = true;
    } catch (e) {
      print("Error loading tertiary data: $e");
    }
  }

  Future<void> ensureTertiaryDataLoaded() async {
    if (!_isTertiaryDataLoaded) {
      await _loadTertiaryData();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();

    // Dispose item description controllers
    for (var item in invoiceItems) {
      item.descriptionController?.dispose();
    }

    for (var controller in quantityControllers) {
      controller.dispose();
    }
    quantityControllers.clear();

    for (var controller in priceControllers) {
      controller.dispose();
    }
    priceControllers.clear();

    allChallans.clear();
    selectedCustomerChallans.clear();
    invoiceItems.clear();
    customers.clear();
    items.clear();
    itemList.clear();
    invoiceList.clear();
    challanList.clear();

    _cache.clear();
    _cacheTimestamps.clear();

    customerNameController.dispose();
    customerMobileController.dispose();
    customerEmailController.dispose();
    customerPanController.dispose();
    customerGstController.dispose();
    customerAddressController.dispose();
    invoiceNumberController.dispose();
    dueDateController.dispose();
    notesController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    receivedAmountController.dispose();
    invoiceDateController.dispose();
    paymentDueDateController.dispose();
    super.onClose();
  }

  // 4. Add method to update invoice date and auto-calculate due date
  Future<void> selectInvoiceDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: invoiceDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != invoiceDate.value) {
      invoiceDate.value = picked;
      invoiceDateController.text = _formatDate(picked);

      // ✅ AUTO-CALCULATE DUE DATE (15 days from invoice date)
      if (!isEditMode.value) {  // Only auto-calculate for new invoices
        paymentDueDate.value = picked.add(Duration(days: 15));
        paymentDueDateController.text = _formatDate(paymentDueDate.value);

        Get.snackbar(
          'Due Date Updated',
          'Payment due date set to ${_formatDate(paymentDueDate.value)} (15 days)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade800,
          duration: Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> selectPaymentDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: paymentDueDate.value,
      firstDate: invoiceDate.value,  // Can't be before invoice date
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != paymentDueDate.value) {
      paymentDueDate.value = picked;
      paymentDueDateController.text = _formatDate(picked);
    }
  }

  void validateManualCustomerEntry() {
    if (showCustomerForm.value &&
        customerNameController.text.trim().isNotEmpty &&
        selectedCustomerId.value.isEmpty) {
      // Generate customer ID for manual entry
      selectedCustomerId.value = 'MANUAL_${DateTime.now().millisecondsSinceEpoch}';
      print("Auto-generated customer ID for manual entry: ${selectedCustomerId.value}");
    }
  }

  Future<T> _loadWithCache<T>(String cacheKey, Future<T> Function() loader) async {
    if (_cache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!) < _cacheDuration) {
      return _cache[cacheKey] as T;
    }

    final data = await loader();
    _cache[cacheKey] = data;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return data;
  }

  Future<void> loadChallansForInvoice({bool loadMore = false}) async {
    if (!loadMore) {
      currentChallanPage = 0;
      hasMoreChallans = true;
      allChallans.clear();
      customerNames.clear();
      selectedCustomerChallans.clear();
      invoiceItems.clear();
    }

    if (!hasMoreChallans) return;

    try {
      isLoading.value = true;

      final challans = await GoogleSheetService.getChallansByDateRange(
        fromDate: selectedFromDate.value,
        toDate: selectedToDate.value,
        userId: AppConstants.userId,
      );

      if (challans.length < challanPageSize) {
        hasMoreChallans = false;
      }

      allChallans.addAll(challans);
      currentChallanPage++;

      final names = challans.map((challan) => challan.customerName).toSet().toList();
      customerNames.assignAll(names);

    } catch (e) {
      Get.snackbar('Error', 'Failed to load challans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCustomerForInvoice(String? customerName) async {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _actuallySelectCustomerForInvoice(customerName);
    });
  }

  // UPDATED: populateInvoiceFromCustomerChallans with customer data fetch
  void populateInvoiceFromCustomerChallans() async {
    invoiceItems.clear();

    if (selectedCustomerChallans.isEmpty) {
      return;
    }

    // Populate items from challans
    final newItems = selectedCustomerChallans
        .where((challan) => challan.items != null && challan.items!.isNotEmpty)
        .expand((challan) => challan.items!)
        .map((challanItem) => InvoiceItem(
      itemId: challanItem.itemId,
      description: challanItem.itemName,
      quantity: challanItem.quantity,
      rate: challanItem.price,
      itemName: challanItem.itemName,
      challanId: challanItem.challanId,
      gstRate: challanItem.gstRate,
    ))
        .toList();

    invoiceItems.addAll(newItems);

    // Set customer details from first challan
    if (customerNameController.text.isEmpty && selectedCustomerChallans.isNotEmpty) {
      final firstChallan = selectedCustomerChallans.first;
      selectedCustomerId.value = firstChallan.customerId ?? '';
      customerNameController.text = firstChallan.customerName ?? '';
      customerMobileController.text = firstChallan.customerMobile ?? '';
      customerEmailController.text = firstChallan.customerEmail ?? '';

      // ⚠️ PROBLEM: Challan might not have PAN/GST, so fetch from Firestore
      customerPanController.text = firstChallan.customerPan ?? '';
      customerGstController.text = firstChallan.customerGst ?? '';
      customerAddressController.text = firstChallan.customerAddress ?? '';

      // 🔧 FIX: If PAN/GST are empty, fetch from customer master
      if ((firstChallan.customerPan?.isEmpty ?? true) ||
          (firstChallan.customerGst?.isEmpty ?? true)) {
        await _fetchCustomerDetailsById(firstChallan.customerId ?? '');
      }
    }

    calculateTotals();
  }

// NEW: Fetch complete customer details from Firestore
  Future<void> _fetchCustomerDetailsById(String customerId) async {
    if (customerId.isEmpty) {
      print("⚠️ Cannot fetch customer details: customerId is empty");
      return;
    }

    try {
      print("🔍 Fetching complete customer details for ID: $customerId");

      final user = _auth.currentUser;
      if (user == null) {
        print("❌ No authenticated user");
        return;
      }

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      if (companyId.isEmpty) {
        print("❌ No company ID found");
        return;
      }

      // Query Firestore for customer
      final customerSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .collection("customers")
          .where("customerId", isEqualTo: customerId)
          .limit(1)
          .get();

      if (customerSnapshot.docs.isEmpty) {
        print("⚠️ No customer found with customerId: $customerId");
        return;
      }

      final customerData = customerSnapshot.docs.first.data();

      // ✅ ALWAYS update PAN and GST (overwrite existing values)
      customerPanController.text = customerData['pan'] ?? '';
      customerGstController.text = customerData['gst'] ?? '';

      print("✅ Fetched PAN: '${customerPanController.text}'");
      print("✅ Fetched GST: '${customerGstController.text}'");

      // Update other fields if empty
      if (customerNameController.text.isEmpty && customerData['name'] != null) {
        customerNameController.text = customerData['name'] ?? '';
        print("✅ Set Name: ${customerNameController.text}");
      }

      if (customerAddressController.text.isEmpty && customerData['address'] != null) {
        customerAddressController.text = customerData['address'] ?? '';
        print("✅ Set Address: ${customerAddressController.text}");
      }

      if (customerEmailController.text.isEmpty && customerData['email'] != null) {
        customerEmailController.text = customerData['email'] ?? '';
        print("✅ Set Email: ${customerEmailController.text}");
      }

      if (customerMobileController.text.isEmpty && customerData['mobile1'] != null) {
        customerMobileController.text = customerData['mobile1'] ?? '';
        print("✅ Set Mobile: ${customerMobileController.text}");
      }

      print("✅ Customer details fetched and populated successfully");

    } catch (e, stackTrace) {
      print("❌ Error fetching customer details: $e");
      print("Stack trace: $stackTrace");
    }
  }

// ALTERNATIVE FIX: Update your selectCustomerForInvoice method
  void _actuallySelectCustomerForInvoice(String? customerName) async {
    selectedCustomerForInvoice.value = customerName ?? '';

    if (customerName != null && customerName.isNotEmpty) {
      try {
        isLoading.value = true;

        selectedCustomerChallans.clear();
        invoiceItems.clear();

        List<Challan> customerChallans =
        await GoogleSheetService.getChallansWithItemsByCustomer(customerName);

        // Filter by status
        customerChallans = customerChallans.where((challan) {
          return challan.status?.toLowerCase() == "inprogress";
        }).toList();

        // Filter by date range
        customerChallans = customerChallans.where((challan) {
          return challan.challanDate != null &&
              !challan.challanDate!.isBefore(selectedFromDate.value) &&
              !challan.challanDate!.isAfter(selectedToDate.value);
        }).toList();

        int dateFilteredCount = customerChallans.length;

        selectedCustomerChallans.assignAll(customerChallans);

        if (selectedCustomerChallans.isNotEmpty) {
          // 🔧 CRITICAL: Populate invoice AND fetch customer details
          populateInvoiceFromCustomerChallans();

          showCustomSnackbar(
            title: "Success",
            message: "Loaded ${dateFilteredCount} in-progress challan(s) for $customerName in selected date range",
            baseColor: Colors.green.shade700,
            icon: Icons.check_circle_outline,
          );
        } else {
          showCustomSnackbar(
            title: "No Challans",
            message: "No in-progress challans found for $customerName in selected date range",
            baseColor: Colors.orange.shade700,
            icon: Icons.info_outline,
          );
        }
      } catch (e) {
        showCustomSnackbar(
          title: "Error",
          message: "Failed to load challans for customer",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      selectedCustomerChallans.clear();
      invoiceItems.clear();
    }
  }

// DEBUGGING: Add this method to check values before PDF generation
  void debugCustomerDataBeforePDF() {
    print("=== CUSTOMER DATA BEFORE PDF GENERATION ===");
    print("Customer Name: '${customerNameController.text}'");
    print("Customer Mobile: '${customerMobileController.text}'");
    print("Customer Email: '${customerEmailController.text}'");
    print("Customer PAN: '${customerPanController.text}'");  // ← Check this
    print("Customer GST: '${customerGstController.text}'");  // ← Check this
    print("Customer Address: '${customerAddressController.text}'");
    print("Selected Customer ID: '${selectedCustomerId.value}'");
    print("===========================================");
  }

  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> loadChallans() async {
    try {
      isLoading.value = true;

      List<Challan> challans = await _loadWithCache('challans', () async {
        return await GoogleSheetService.getChallans();
      });

      int totalItems = 0;
      for (var challan in challans) {
        totalItems += challan.items?.length ?? 0;
      }

      challanList.assignAll(challans);

      if (challans.isEmpty) {
        showCustomSnackbar(
          title: "No Challans",
          message: "No challans found",
          baseColor: Colors.orange.shade700,
          icon: Icons.info_outline,
        );
      } else {
        showCustomSnackbar(
          title: "Success",
          message: "Found ${challans.length} challans with $totalItems items",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );
      }

    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Failed to load challans: ${e.toString()}",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> loadCompanyData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      if (companyId.isEmpty) return;

      final companyDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .get();

      if (companyDoc.exists) {
        companyData.value = companyDoc.data() ?? {};
      }
    } catch (e) {
      print("Error loading company data: $e");
    }
  }

  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;

      await _loadWithCache('customers', () async {
        final user = _auth.currentUser;
        if (user == null) return;

        String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";

        final customersSnapshot = await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("companies")
            .doc(companyId)
            .collection("customers")
            .get();

        customers.clear();
        int activeCount = 0;
        int inactiveCount = 0;

        for (var doc in customersSnapshot.docs) {
          final data = doc.data();

          // Check if customer is active
          // Adjust field name based on your Firestore structure
          bool isActive = data['isActive'] ?? true; // Default to true if field doesn't exist
          // OR if you use status field:
          // bool isActive = data['status'] == 'active';

          if (isActive) {
            data['id'] = doc.id;
            customers.add(data);
            activeCount++;
            print("✅ Added active customer: ${data['name']} (ID: ${doc.id})");
          } else {
            inactiveCount++;
            print("⏭️ Skipped inactive customer: ${data['name']} (ID: ${doc.id})");
          }
        }

        // Update customer count with only active customers
        customerCount.value = customers.length;

        print("📊 Customer Summary:");
        print("   Active: $activeCount");
        print("   Inactive: $inactiveCount");
        print("   Total shown: ${customerCount.value}");

        if (customers.isEmpty) {
          print("⚠️ No active customers found");
          showCustomSnackbar(
            title: "No Active Customers",
            message: "No active customers available. Please add customers first.",
            baseColor: Colors.orange.shade700,
            icon: Icons.info_outline,
          );
        }

        return null;
      });

    } catch (e) {
      print("❌ Error loading customers: $e");
      Get.snackbar(
        'Error',
        'Failed to load customers',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchItems2() async {
    try {
      isLoading.value = true;

      await _loadWithCache('items', () async {
        final userId = AppConstants.userId;

        List<Item> items = await GoogleSheetService.getItems(userId: userId);

        itemList.assignAll(items);

        if (items.isEmpty) {
          showCustomSnackbar(
            title: "No Items",
            message: "No items found for the current user",
            baseColor: Colors.orange.shade700,
            icon: Icons.info_outline,
          );
        } else {
          showCustomSnackbar(
            title: "Success",
            message: "Found ${items.length} items",
            baseColor: Colors.green.shade700,
            icon: Icons.check_circle_outline,
          );
        }

        return null;
      });

    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Failed to load items: $e",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInvoices() async {
    try {
      isLoading.value = true;

      await _loadWithCache('invoices', () async {
        List<Invoice> invoices = await GoogleSheetService.getInvoices();

        if (invoices.isEmpty) {
          invoices = await GoogleSheetService.getInvoices();
        }

        invoiceList.assignAll(invoices);

        return null;
      });

    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Failed to load invoices: $e",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeInvoice() async {
    if (isEditMode.value || isFromQuotation.value) {
      return;
    }

    isLoading.value = true;

    final nextInvoiceId = await getNextInvoiceNumber();
    invoiceNumberController.text = nextInvoiceId;
    DateTime today = DateTime.now();
    dueDate.value = today;
    dueDateController.text = _formatDate(today);

    // ✅ Set payment due date to 15 days from today
    paymentDueDate.value = today.add(Duration(days: 15));
    paymentDueDateController.text = _formatDate(paymentDueDate.value);

    addNewItem();

    isLoading.value = false;
  }

  Future<String> getNextInvoiceNumber() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "${invoiceType.value.prefix}0001";

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      if (companyId.isEmpty) return "${invoiceType.value.prefix}0001";

      final companyDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId)
          .get();

      if (!companyDoc.exists) {
        return "${invoiceType.value.prefix}0001";
      }

      final data = companyDoc.data();

      // Get counter based on invoice type
      final String counterField = invoiceType.value == InvoiceType.invoice
          ? 'currentInvoiceNumber'
          : 'currentQuotationNumber';

      final currentNumber = data?[counterField] ?? 1;

      return "${invoiceType.value.prefix}${currentNumber.toString().padLeft(4, '0')}";
    } catch (e) {
      return "${invoiceType.value.prefix}0001";
    }
  }

  Future<String> incrementAndGetInvoiceNumber() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "${invoiceType.value.prefix}0001";

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      if (companyId.isEmpty) return "${invoiceType.value.prefix}0001";

      final companyRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId);

      return await _firestore.runTransaction((transaction) async {
        final companyDoc = await transaction.get(companyRef);

        if (!companyDoc.exists) {
          return "${invoiceType.value.prefix}0001";
        }

        final data = companyDoc.data();
        // Use different counter field based on invoice type
        final String counterField = invoiceType.value == InvoiceType.invoice
            ? 'currentInvoiceNumber'
            : 'currentQuotationNumber';

        final currentNumber = data?[counterField] ?? 1;
        final nextNumber = currentNumber + 1;

        transaction.update(companyRef, {
          counterField: nextNumber,
        });

        return "${invoiceType.value.prefix}${currentNumber.toString().padLeft(4, '0')}";
      });
    } catch (e) {
      return "${invoiceType.value.prefix}0001";
    }
  }

  void setInvoiceType(InvoiceType type) async {
    invoiceType.value = type;
    final nextNumber = await getNextInvoiceNumber();
    invoiceNumberController.text = nextNumber;
  }

  void selectCustomer(Map<String, dynamic>? customer) {
    if (customer == null) {
      selectedCustomerId.value = '';
      clearCustomerSelection();
      showCustomerForm.value = false;
      return;
    }

    // Double-check if customer is still active before selection
    bool isActive = customer['isActive'] ?? true;
    // OR: bool isActive = customer['status'] == 'active';

    if (!isActive) {
      showCustomSnackbar(
        title: "Customer Inactive",
        message: "This customer is currently inactive. Please select an active customer or activate this customer first.",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning,
        duration: Duration(seconds: 4),
      );
      return;
    }

    selectedCustomerId.value = customer['customerId'] ?? customer['id'] ?? '';
    customerNameController.text = customer['name'] ?? '';
    customerMobileController.text = customer['mobile1'] ?? '';
    customerEmailController.text = customer['email'] ?? '';
    customerAddressController.text = customer['address'] ?? '';
    customerPanController.text = customer['pan'] ?? '';
    customerGstController.text = customer['gst'] ?? '';
    showCustomerForm.value = false;

    print("✅ Selected active customer:");
    print("   ID: ${selectedCustomerId.value}");
    print("   Name: ${customerNameController.text}");
    print("   Mobile: ${customerMobileController.text}");
  }

  void toggleCustomerForm() {
    showCustomerForm.value = !showCustomerForm.value;
    if (showCustomerForm.value) {
      selectedCustomerId.value = '';
      clearCustomerSelection();
    }
  }

  void clearCustomerSelection() {
    selectedCustomerId.value = '';
    customerNameController.clear();
    customerMobileController.clear();
    customerEmailController.clear();
    customerPanController.clear();
    customerGstController.clear();
    customerAddressController.clear();
  }

  String _getValidCustomerId() {
    String customerId = '';

    if (selectedCustomerId.value.isNotEmpty) {
      customerId = selectedCustomerId.value;
    }
    else if (isEditMode.value && originalInvoiceData.value?['customerId'] != null) {
      customerId = originalInvoiceData.value!['customerId'].toString();
      selectedCustomerId.value = customerId;
    }
    else if (invoiceItems.isNotEmpty && invoiceItems.first.customerId?.isNotEmpty == true) {
      customerId = invoiceItems.first.customerId!;
      selectedCustomerId.value = customerId;
    }

    else if (customerNameController.text.trim().isNotEmpty) {
      customerId = 'MANUAL_${customerNameController.text.trim().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      selectedCustomerId.value = customerId;
      print("Generated manual entry customer ID: $customerId");
    }

    return customerId;
  }

  void addNewItem() {
    print("Adding new item in ${isEditMode.value ? 'EDIT' : 'CREATE'} mode");


    String customerId = _getValidCustomerId();

    if (customerId.isEmpty && isEditMode.value) {
      Get.snackbar(
        'Error',
        'Unable to determine customer ID. Please reload the invoice.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // ✅ In CREATE mode, allow empty customer ID (will be populated when customer is selected)
    if (customerId.isEmpty && !isEditMode.value) {
      print("INFO: Creating item without customer ID (will be set when customer is selected)");
    }

    // ✅ Check business type
    final businessType = AppConstants.businessType?.toLowerCase() ?? '';
    final isServiceBusiness = (businessType == 'service' || businessType == 'client');

    // ✅ For service business, start with empty description (user will type custom text)
    // For product business, description will be filled when item is selected
    final initialDescription = isServiceBusiness ? '' : '';

    // ✅ Create new controller with appropriate initial value
    final newDescriptionController = TextEditingController(text: initialDescription);

    invoiceItems.add(InvoiceItem(
      description: '',
      quantity: 1,
      rate: 0.0,
      gstRate: 0.0,
      itemId: '',
      itemName: '',
      totalPrice: 0.0,
      unit: '',
      customerId: customerId,
      descriptionController: newDescriptionController,
    ));

    calculateTotals();
  }

  void updateItem(int index, {
    String? description,
    double? quantity,
    double? rate,
    String? itemId,
    String? unit
  }) {
    if (index < invoiceItems.length) {
      final item = invoiceItems[index];

      final double updatedQuantity = quantity ?? item.quantity;
      final double updatedRate = rate ?? item.rate;

      final double newTotalPrice = updatedQuantity * updatedRate;
      final double newGstAmount = (newTotalPrice * item.gstRate) / 100;
      final double newAmountWithGst = newTotalPrice + newGstAmount;

      invoiceItems[index] = InvoiceItem(
        customerId: item.customerId,
        invoiceId: item.invoiceId,
        description: description ?? item.description,
        quantity: updatedQuantity,
        rate: updatedRate,
        gstRate: item.gstRate,
        itemId: itemId ?? item.itemId,
        totalPrice: newTotalPrice,
        gstAmount: newGstAmount,
        amountWithGst: newAmountWithGst,
        itemName: description ?? item.itemName,
        unit: unit,
        challanId: item.challanId,
      );

      if (quantity != null) {
        updateQuantityController(index, quantity);
      }
      if (rate != null) {
        updatePriceController(index, rate);
      }

      calculateTotals();
    }
  }

  TextEditingController getPriceController(int index, {double? initialValue}) {
    while (priceControllers.length < invoiceItems.length) {
      final itemIndex = priceControllers.length;
      final item = invoiceItems[itemIndex];
      priceControllers.add(
        TextEditingController(text: item.rate.toInt().toString()),
      );
    }

    while (priceControllers.length > invoiceItems.length) {
      priceControllers.removeLast().dispose();
    }

    if (initialValue != null &&
        priceControllers[index].text != initialValue.toInt().toString()) {
      priceControllers[index].text = initialValue.toInt().toString();
    }

    return priceControllers[index];
  }

  void updatePriceController(int index, double newPrice) {
    if (index < priceControllers.length) {
      final formatted = newPrice.toStringAsFixed(0);
      if (priceControllers[index].text != formatted) {
        priceControllers[index].text = formatted;
      }
    }
  }

  TextEditingController getQuantityController(int index, {double? initialValue}) {
    // Ensure we have the right number of controllers
    while (quantityControllers.length < invoiceItems.length) {
      final itemIndex = quantityControllers.length;
      final item = invoiceItems[itemIndex];
      quantityControllers.add(
        TextEditingController(text: item.quantity.toString()),
      );
    }

    // Remove extra controllers if items were removed
    while (quantityControllers.length > invoiceItems.length) {
      quantityControllers.removeLast().dispose();
    }

    // Update the controller text if initial value is provided and different
    if (initialValue != null &&
        quantityControllers[index].text != initialValue.toString()) {
      quantityControllers[index].text = initialValue.toString();
    }

    return quantityControllers[index];
  }

// Keep this method for programmatic updates:
  void updateQuantityController(int index, double newQuantity) {
    if (index < quantityControllers.length) {
      final formatted = newQuantity.toString();
      if (quantityControllers[index].text != formatted) {
        quantityControllers[index].text = formatted;
      }
    }
  }

  void selectRemoteItemForIndex(int index, Item item) {
    if (index >= invoiceItems.length) return;

    // 🔎 Check if this item already exists
    int existingIndex = -1;
    for (int i = 0; i < invoiceItems.length; i++) {
      if (i != index && invoiceItems[i].itemId == item.itemId && invoiceItems[i].itemId.isNotEmpty) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      // ✅ Item already exists - merge quantities
      final existingItem = invoiceItems[existingIndex];
      final currentQty = invoiceItems[index].quantity;
      final newQty = existingItem.quantity + currentQty;

      // Update the existing item with increased quantity
      invoiceItems[existingIndex] = existingItem.copyWith(
        quantity: newQty,
        totalPrice: newQty * existingItem.rate,
      );

      // ✅ UPDATE THE CONTROLLER for the existing item
      updateQuantityController(existingIndex, newQty);

      // Remove the duplicate row
      invoiceItems[index].descriptionController?.dispose();
      removeItem(index);

      // Show feedback to user
      Get.snackbar(
        "Item Merged",
        "Quantity added to existing ${item.itemName}. Total: $newQty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
      );

      calculateTotals();
      return;
    }

    // 🚀 No duplicate found - proceed with normal item selection
    final currentItem = invoiceItems[index];
    String customerId = _getValidCustomerId();

    if (customerId.isEmpty && isEditMode.value) {
      Get.snackbar(
        'Error',
        'Customer ID missing. Please reload the invoice.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // GST logic
    double gstRateToUse;
    if (isEditMode.value && currentItem.itemId.isNotEmpty) {
      gstRateToUse = currentItem.gstRate;
    } else {
      gstRateToUse = item.gstPercent.toDouble();
    }

    // ✅ CRITICAL: Preserve the existing description controller
    final existingController = currentItem.descriptionController;
    final customDescription = existingController?.text.trim() ?? '';

    // ✅ NEW: Decide what description to use
    String finalDescription;
    // Check business type
    final businessType = AppConstants.businessType?.toLowerCase() ?? '';
    final isServiceBusiness = (businessType == 'service' || businessType == 'client');

    if (isServiceBusiness) {
      // For service business: Keep user's custom description if they typed something different
      // Otherwise, pre-fill with item name as starting point
      if (customDescription.isNotEmpty &&
          customDescription != currentItem.itemName &&
          customDescription != currentItem.description) {
        finalDescription = customDescription;  // ✅ Keep user's custom description
      } else {
        finalDescription = item.itemName;  // ✅ Pre-fill with item name for service description
      }
    } else {
      // For non-service business: just use item name
      finalDescription = item.itemName;
    }

    // Update item at current index
    invoiceItems[index] = InvoiceItem(
      customerId: customerId,
      description: finalDescription,
      quantity: currentItem.quantity,
      rate: item.price.toDouble(),
      gstRate: gstRateToUse,
      itemId: item.itemId,
      itemName: item.itemName,
      totalPrice: currentItem.quantity * item.price.toDouble(),
      unit: item.unitOfMeasurement,
        descriptionController: existingController
    );

    // ✅ CRITICAL: Update the controller text
    if (existingController != null) {
      existingController.text = finalDescription;
      // Move cursor to end only if there's text
      if (finalDescription.isNotEmpty) {
        existingController.selection = TextSelection.fromPosition(
          TextPosition(offset: finalDescription.length),
        );
      }
    }


    // ✅ UPDATE CONTROLLERS for the current index
    updateQuantityController(index, currentItem.quantity);
    updatePriceController(index, item.price.toDouble());

    calculateTotals();
  }


  // ✅ NEW: Helper method to update item description
  void updateItemDescription(int index, String description) {
    if (index >= invoiceItems.length) return;

    final item = invoiceItems[index];

    // Update the item's description field
    invoiceItems[index] = item.copyWith(
      description: description,
    );

    // No need to call calculateTotals since description doesn't affect totals
    invoiceItems.refresh();
  }

  void removeItem(int index) {
    if (invoiceItems.length > 1) {
      // Dispose the controller before removing
      invoiceItems[index].descriptionController?.dispose();


      invoiceItems.removeAt(index);
      calculateTotals();
    }
  }

  void calculateTotals() {
    double sub = 0.0;
    double gst = 0.0;

    for (var i = 0; i < invoiceItems.length; i++) {
      final item = invoiceItems[i];
      final itemTotal = item.rate * item.quantity;

      double gstForItem = 0.0;
      double withGst = itemTotal;

      if (AppConstants.withGST.value) {
        gstForItem = itemTotal * (item.gstRate / 100);
        withGst = itemTotal + gstForItem;
      }

      invoiceItems[i] = item.copyWith(
        totalPrice: itemTotal,
        gstAmount: gstForItem,
        amountWithGst: withGst,
      );

      sub += itemTotal;
      gst += gstForItem;
    }

    subtotal.value = sub;
    gstAmount.value = gst;
    totalAmount.value = AppConstants.withGST.value ? sub + gst : sub;

    pendingAmount.value = calculatedPendingAmount;
  }



// Add this computed getter
  double get calculatedPendingAmount {
    if (paymentStatus.value == 'Partial') {
      return totalAmount.value - receivedAmount.value;
    } else if (paymentStatus.value == 'Paid') {
      return 0.0;
    } else {
      return totalAmount.value;
    }
  }

// Add this method to handle received amount changes
  void updateReceivedAmount(String value) {
    double? amount = double.tryParse(value);
    if (amount != null && amount >= 0) {
      receivedAmount.value = amount;
      pendingAmount.value = calculatedPendingAmount;

      // Validate that received amount doesn't exceed total
      if (amount > totalAmount.value) {
        Get.snackbar(
          'Invalid Amount',
          'Received amount cannot exceed total amount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
        receivedAmountController.text = totalAmount.value.toString();
        receivedAmount.value = totalAmount.value;
        pendingAmount.value = 0.0;
      }
    }
  }

  void updatePaymentStatus(String status) {
    paymentStatus.value = status;

    // Auto-set received amount based on status
    if (status == 'Paid') {
      receivedAmount.value = totalAmount.value;
      receivedAmountController.text = totalAmount.value.toString();
      pendingAmount.value = 0.0;
    } else if (status == 'Pending') {
      receivedAmount.value = 0.0;
      receivedAmountController.clear();
      pendingAmount.value = totalAmount.value;
    } else if (status == 'Partial') {
      // Keep current received amount or set to 0
      pendingAmount.value = calculatedPendingAmount;
    }
  }

  Future<void> selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: dueDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != dueDate.value) {
      dueDate.value = picked;
      dueDateController.text = _formatDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void debugInvoiceItemsBeforeSaving() {
    print("=== DEBUGGING INVOICE ITEMS BEFORE SAVING ===");
    print("Selected Customer ID: ${selectedCustomerId.value}");
    print("Due Date: ${dueDate.value}");

    for (int i = 0; i < invoiceItems.length; i++) {
      final item = invoiceItems[i];
      print("Item $i:");
      print("  customerId: '${item.customerId}'");
      print("  itemId: '${item.itemId}'");
      print("  itemName: '${item.itemName}'");
      print("  quantity: ${item.quantity}");
      print("  rate: ${item.rate}");
      print("  gstRate: ${item.gstRate}");
      print("  gstAmount: ${item.gstAmount}");
      print("  totalPrice: ${item.totalPrice}");
      print("  ---");
    }
    print("=== END DEBUG ===");
  }

  void debugAllItemsCustomerId() {
    print("=== DEBUGGING ALL ITEMS CUSTOMER ID ===");
    print("selectedCustomerId.value: '${selectedCustomerId.value}'");
    print("originalInvoiceData customerId: '${originalInvoiceData.value?['customerId']}'");

    for (int i = 0; i < invoiceItems.length; i++) {
      final item = invoiceItems[i];
      print("Item $i: customerId='${item.customerId}', itemName='${item.itemName}'");

      if (item.customerId?.isEmpty ?? true) {
        String correctCustomerId = _getValidCustomerId();
        if (correctCustomerId.isNotEmpty) {
          invoiceItems[i] = item.copyWith(customerId: correctCustomerId);
          print("  FIXED: Set customer ID to '$correctCustomerId'");
        }
      }
    }
    print("=== END DEBUG ===");
  }

  Map<String, dynamic> createInvoiceItemData(InvoiceItem item) {
    String customerId = item.customerId ?? '';
    if (customerId.isEmpty) {
      customerId = _getValidCustomerId();
    }

    String finalDescription = '';
    final businessType = AppConstants.businessType?.toLowerCase() ?? '';


    if (businessType == 'service' || businessType == 'client') {
      // ✅ Use the item's OWN controller, not a shared one
      final textValue = item.descriptionController?.text.trim() ?? '';

      if (textValue.isNotEmpty) {
        finalDescription = textValue;
      } else {
        finalDescription = item.description ?? '';
      }
    } else {
      finalDescription = item.description ?? '';
    }



    Map<String, dynamic> itemData = {
      'invoiceId': invoiceNumberController.text,
      'customerId': customerId,
      'itemId': item.itemId ?? '',
      'itemName':  item.itemName ?? '',
      'description': finalDescription,
    // AppConstants.businessType == 'service'
    //       ? serviceDescriptionController.value.text.isNotEmpty
    //       ? serviceDescription.value.toString()
    //       :  item.description ??  '' ,
    //       :  item.description ??  '' ,
      'quantity': item.quantity.toString(),
      'price': item.rate.toString(),
      'gstRate': item.gstRate.toString(),
      'gstAmount': item.gstAmount.toString(),
      'amountWithGst': item.amountWithGst.toString(),
      'totalPrice': item.totalPrice.toString(),
      'userId': AppConstants.userId,
    };

    return itemData;
  }

  void _refreshParentControllers() {
    try {
      if (Get.isRegistered<InvoiceListController>()) {
        final listController = Get.find<InvoiceListController>();
        listController.loadInvoices();
      }

      if (Get.isRegistered<InvoiceDetailsController>()) {
        final detailsController = Get.find<InvoiceDetailsController>();
        detailsController.refreshInvoiceData();
      }

      // NEW: Refresh quotation list if converting from quotation
      if (Get.isRegistered<QuotationListController>()) {
        final quotationController = Get.find<QuotationListController>();
        quotationController.loadQuotations();
      }
    } catch (e) {
      print("Error refreshing parent controllers: $e");
    }
  }

  void _removeEmptyItemsBeforeSave() {
    invoiceItems.removeWhere((item) {
      bool isEmpty = (item.itemId?.isEmpty ?? true) &&
          (item.description?.isEmpty ?? true) &&
          (item.itemName?.isEmpty ?? true);

      // Keep items that have been filled or have quantity/rate changes
      return isEmpty && item.quantity == 1 && item.rate == 0.0;
    });

    // Ensure at least one item remains
    if (invoiceItems.isEmpty) {
      addNewItem();
    }
  }

  /// Validates that at least one valid item exists before saving
  bool _validateInvoiceItems() {
    // Check if there are any items at all
    if (invoiceItems.isEmpty) {
      showCustomSnackbar(
        title: "Validation Error",
        message: "Please add at least one item to the invoice",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
      return false;
    }

    // Check if there's at least one valid item (has itemId or description)
    bool hasValidItem = invoiceItems.any((item) {
      bool hasItemId = item.itemId != null && item.itemId!.isNotEmpty;
      bool hasDescription = item.description != null && item.description!.isNotEmpty;
      bool hasItemName = item.itemName != null && item.itemName!.isNotEmpty;

      return hasItemId || hasDescription || hasItemName;
    });

    if (!hasValidItem) {
      showCustomSnackbar(
        title: "No Items Selected",
        message: "Please select or add at least one item before creating the invoice",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }

    // ✅ FIXED: Changed challanItems to invoiceItems
    bool hasInvalidQuantityOrPrice = invoiceItems.any((item) {
      bool isValidItem = (item.itemId?.isNotEmpty ?? false) ||
          (item.description?.isNotEmpty ?? false) ||
          (item.itemName?.isNotEmpty ?? false);

      if (isValidItem) {
        // ✅ FIXED: Changed item.price to item.rate (invoices use 'rate')
        return item.quantity <= 0 || item.rate <= 0;
      }
      return false;
    });

    if (hasInvalidQuantityOrPrice) {
      showCustomSnackbar(
        title: "Invalid Item Data",
        message: "All selected items must have quantity and rate greater than 0",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }

    return true;
  }

  Future<bool> saveInvoice({required bool isDraft}) async {
    try {
      if (showCustomerForm.value && customerNameController.text.trim().isNotEmpty) {
        validateManualCustomerEntry();
      }

      // ✅ NEW: Validate customer is selected/entered
      if (customerNameController.text.trim().isEmpty) {
        showCustomSnackbar(
          title: "Customer Required",
          message: "Please select a customer or enter customer details",
          baseColor: Colors.red.shade700,
          icon: Icons.person_outline,
        );
        return false;
      }

      if (!formKey.currentState!.validate()) {
        showCustomSnackbar(
          title: "Validation Error",
          message: "Please fill all required fields",
          baseColor: Colors.orange.shade700,
          icon: Icons.warning,
        );
        return false;
      }

      if (!_validateInvoiceItems()) {
        return false;
      }
      _removeEmptyItemsBeforeSave();

      if (invoiceItems.isEmpty) {
        showCustomSnackbar(
          title: "No Valid Items",
          message: "Please add at least one valid item to the invoice",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
        return false;
      }

      isLoading.value = true;

      debugAllItemsCustomerId();
      calculateTotals();

      String finalCustomerId = _getValidCustomerId();

      Map<String, dynamic> invoiceData = {
        'invoiceId': invoiceNumberController.text,
        'customerId': finalCustomerId,
        'customerName': customerNameController.text.trim(),
        'customerPan': customerPanController.text.trim(),  // Add this
        'customerGst': customerGstController.text.trim(),  // Add this
        'mobile': customerMobileController.text.trim(),
        'customerEmail': customerEmailController.text.trim(),
        'customerAddress': customerAddressController.text.trim(),
        'issueDate': invoiceDate.value.toIso8601String(),
        'dueDate': paymentDueDate.value.toIso8601String(),
        'subtotal': subtotal.value,
        'gstRate': invoiceItems.isNotEmpty ? invoiceItems.first.gstRate : 0.0,
        'gstAmount': gstAmount.value,
        'totalAmount': totalAmount.value,
        'notes': notesController.text,
        'status': paymentStatus.value,
        'userId': AppConstants.userId,
        'receivedAmount': receivedAmount.value,
        'pendingAmount': pendingAmount.value,
      };

      if (isInEditMode) {
        await GoogleSheetService.updateInvoice(invoiceData, AppConstants.userId);

        List<Map<String, dynamic>> itemsData = [];
        for (var item in invoiceItems) {
          itemsData.add(createInvoiceItemData(item));
        }

        await GoogleSheetService.updateInvoiceItems(
          invoiceNumberController.text,
          itemsData,
          AppConstants.userId,
        );

        _refreshParentControllers();

        showCustomSnackbar(
          title: "Success",
          message: "Invoice updated successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );

        Get.back(result: true);
        await Future.delayed(Duration(milliseconds: 100));

        return true;

      } else {
        final actualInvoiceId = await incrementAndGetInvoiceNumber();
        invoiceNumberController.text = actualInvoiceId;
        invoiceData['invoiceId'] = actualInvoiceId;

        await GoogleSheetService.addInvoice(invoiceData, AppConstants.userId);

        List<Map<String, dynamic>> itemsData =
        invoiceItems.map((item) => createInvoiceItemData(item)).toList();

        await GoogleSheetService.addInvoiceItemsBatch(itemsData, AppConstants.userId);


        await GoogleSheetService.updateStockAfterInvoice(invoiceItems);

        List<String> challanIds = invoiceItems
            .where((item) => (item.challanId ?? '').isNotEmpty)
            .map((item) => item.challanId!)
            .toSet() // avoid duplicates
            .toList();

        if (challanIds.isNotEmpty) {
          await GoogleSheetService.updateChallanStatusBatch(
            challanIds,
            "Progress",
            AppConstants.userId,
          );
        }


        List<Invoice> invoiceModels = invoiceItems.map((item) {
          // ✅ For service business, use the full description
          String displayName = item.itemName ?? '';

          final businessType = AppConstants.businessType?.toLowerCase() ?? '';
          if (businessType == 'service' || businessType == 'client') {
            // Use description field for service businesses
            displayName = item.description ?? item.itemName ?? '';
          }


          return Invoice(
            invoiceId: invoiceNumberController.text,
            itemId: item.itemId,
            itemName: item.itemName,
            qty: item.quantity,
            price: item.rate.toDouble(),
            mobile: customerMobileController.text.trim(),
            customerId: finalCustomerId,
            customerName: customerNameController.text.trim(),
            customerEmail: customerEmailController.text.trim(),
            customerPan: customerPanController.text.trim(),
            customerGst: customerGstController.text.trim(),
            customerAddress: customerAddressController.text.trim(),
            issueDate: DateTime.now(),
            dueDate: dueDate.value,
            subtotal: subtotal.value,
            gst: item.gstRate,
            gstRate: item.gstRate,
            gstAmount: gstAmount.value,
            totalAmount: totalAmount.value,
            notes: notesController.text,
            status: paymentStatus.value,

            // ✅ ADD THIS: Pass item description separately
            items: [item],  // Pass the full item with description
          );
        }).toList();

        if (invoiceModels.isEmpty) {
          showCustomSnackbar(
            title: "Error",
            message: "Invoice must have at least one item",
            baseColor: Colors.red.shade700,
            icon: Icons.error_outline,
          );
          return false;
        }

        final bool hasChallan = invoiceItems.any((it) {
          try {
            return (it.challanId ?? '').toString().isNotEmpty;
          } catch (_) {
            return false;
          }
        });

        debugCustomerDataBeforePDF();

        if (hasChallan) {
          await InvoiceHelper.generateAndShareInvoiceFromChallan(
            invoiceItems,
            invoiceNumberController.text,
            dueDateController.text,
            selectedFromDate.value.toString(),
            selectedToDate.value.toString(),
            customerNameController.text.trim(),
            customerMobileController.text.trim(),
            customerEmailController.text.trim(),
            customerPanController.text.trim(),
            customerGstController.text.trim(),
            customerAddressController.text.trim(),
            subtotal.value,
            taxAmount.value,
            totalAmount.value,
            notesController.text,
            companyData.value,
            invoiceType.value,
            gstAmount.value,
            _formatDate(paymentDueDate.value),
          );
        } else {
          await InvoiceHelper.generateAndShareInvoice(
            invoiceModels,
            customerNameController.text.trim(),
            customerMobileController.text.trim(),
            customerEmailController.text.trim(),
            customerPanController.text.trim(),
            customerGstController.text.trim(),
            customerAddressController.text.trim(),
            subtotal.value,
            dueDateController.text,
            totalAmount.value,
            notesController.text,
            companyData.value,
            invoiceType.value,
            gstAmount.value,
            _formatDate(paymentDueDate.value),
          );
        }

        if (isFromQuotation.value && sourceQuotationId.value.isNotEmpty) {
          try {
            print("🔄 Updating quotation ${sourceQuotationId.value} status to 'Accepted'");

            final updated = await GoogleSheetService.updateInvoiceStatus(
              sourceQuotationId.value,
              'Accepted',
              sheetName: 'Invoice', // Specify the sheet name where quotations are stored
            );

            if (updated) {
              print("✅ Quotation ${sourceQuotationId.value} status updated to 'Accepted'");
            } else {
              print("⚠️ Could not update quotation status");
            }
          } catch (e) {
            print("❌ Error updating quotation status: $e");
            // Don't fail the whole operation if this fails
          }
        }

        showCustomSnackbar(
          title: "Success",
          message: "Invoice created successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );


        clearForm();
        Get.back(result: true);

        return true;
      }

    } catch (e, stackTrace) {
      print("Error saving invoice: $e");
      print("Stack trace: $stackTrace");

      showCustomSnackbar(
        title: "Error",
        message: "Failed to save invoice: ${e.toString()}",
        baseColor: Colors.red.shade700,
        icon: Icons.error,
        duration: Duration(seconds: 5),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    formKey.currentState?.reset();
    invoiceItems.clear();
    clearCustomerSelection();
    notesController.clear();
    paymentStatus.value = 'Pending';
    receivedAmountController.clear();
    receivedAmount.value = 0.0;
    pendingAmount.value = 0.0;
    calculateTotals();

    initializeInvoice();
  }

  void showCustomSnackbar({
    required String title,
    required String message,
    required Color baseColor,
    required IconData icon,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: baseColor,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      duration: duration ?? Duration(seconds: 3),
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedFromDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedFromDate.value) {
      selectedFromDate.value = picked;
      fromDateController.text = _formatDateForDisplay(picked);
      loadChallansForInvoice();
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedToDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedToDate.value) {
      selectedToDate.value = picked;
      toDateController.text = _formatDateForDisplay(picked);
      loadChallansForInvoice();
    }
  }

  // If you have an edit action in your invoice list, add the same check there:

  void onEditInvoice(Invoice invoice) {
    // ✅ Check if paid
    if (invoice.status?.toLowerCase() == 'paid') {
      Get.snackbar(
        'Cannot Edit',
        'Paid invoices cannot be edited. Change status first.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: Icon(Icons.lock, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Proceed with normal edit flow
    Get.to(() => NewInvoiceScreen(), arguments: {
      'editMode': true,
      'invoiceId': invoice.invoiceId,
      'invoiceData': invoice,
    });
  }


}

enum InvoiceType {
  invoice,
  quotation,
}

extension InvoiceTypeExtension on InvoiceType {
  String get name {
    switch (this) {
      case InvoiceType.invoice:
        return 'Invoice';
      case InvoiceType.quotation:
        return 'Quotation';
    }
  }

  String get prefix {
    switch (this) {
      case InvoiceType.invoice:
        return 'INV';
      case InvoiceType.quotation:
        return 'QUO';
    }
  }
}
