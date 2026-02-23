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
import '../screen/screen.dart';
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
  var paymentMode = 'Cash'.obs;

  var invoiceDate = DateTime.now().obs;  // Invoice issue date
  var paymentDueDate = DateTime.now().add(Duration(days: 15)).obs;  // Payment due date
  final invoiceDateController = TextEditingController();
  final paymentDueDateController = TextEditingController();

  final RxSet<int> itemsWithStockViolation = <int>{}.obs; // Track indices of items with violations
  final RxMap<int, String> violationMessages = <int, String>{}.obs;  // Track which item violated
  bool get hasAnyStockViolation => itemsWithStockViolation.isNotEmpty;
  var forceRefreshTriggers = <int, int>{}.obs;


//  @override
//   void onInit() {
//     super.onInit();
//     invoiceType.value = InvoiceType.invoice;
//
//     // Set up date controllers
//     invoiceDateController.text = _formatDateForDisplay(invoiceDate.value);
//     paymentDueDateController.text = _formatDateForDisplay(paymentDueDate.value);
//
//
// // ✅ FIX: Set default dates based on Demo Mode
//     if (AppConstants.isDemo.value) {
//       selectedFromDate.value = DateTime(1990, 1, 1);
//       selectedToDate.value = DateTime(1992, 12, 31);
//     } else {
//       // Standard defaults
//       selectedToDate.value = DateTime.now();
//       selectedFromDate.value = DateTime.now().subtract(Duration(days: 30));
//     }
//
//     fromDateController.text = _formatDateForDisplay(selectedFromDate.value);
//     toDateController.text = _formatDateForDisplay(selectedToDate.value);
//
//     // Check if coming from quotation conversion FIRST
//     final arguments = Get.arguments;
//     if (arguments != null &&
//         arguments is Map &&
//         arguments['isFromQuotation'] == true) {
//
//       print("🔄 Quotation conversion detected in onInit");
//       isFromQuotation.value = true;
//
//       // Load essential data first, then handle quotation
//       _loadEssentialDataWithoutInit().then((_) {
//         _handleQuotationConversion();
//       });
//
//     } else {
//       // Handle arguments for edit mode only
//       _handleArguments();
//
//       if (!isEditMode.value) {
//         // Normal new invoice flow
//         _loadEssentialData();
//       } else {
//         // Edit mode flow
//         _loadEssentialData();
//         if (invoiceItems.isEmpty) {
//           addNewItem();
//         }
//       }
//     }
//
//     // Load other data after a delay
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadSecondaryData();
//       ensureControllersMatch();
//     });
//   }

// Replace your onInit() method in NewInvoiceController with this:
  @override
  void onInit() {
    super.onInit();
    print("🚀 [INIT] Starting NewInvoiceController initialization");

    // ✅ CRITICAL: Initialize ALL observables with direct assignment
    // This FORCES GetX to track them properly in release mode

    invoiceType.value = InvoiceType.invoice;
    isEditMode.value = false;
    isFromQuotation.value = false;
    isLoading.value = false;
    showCustomerForm.value = false;
    createFromChallan.value = false;

    selectedCustomerId.value = '';
    editingInvoiceId.value = '';
    selectedCustomerForInvoice.value = '';
    sourceQuotationId.value = '';
    paymentStatus.value = 'Pending';

    // ✅ CRITICAL: Force GetX to register observables for release mode
    invoiceType.listen((value) {
      print("📊 InvoiceType changed to: $value");
    });

    isEditMode.listen((value) {
      print("✏️ EditMode changed to: $value");
    });

    isFromQuotation.listen((value) {
      print("📄 FromQuotation changed to: $value");
    });

    // Initialize dates
    DateTime defaultDate = AppConstants.isDemo.value
        ? DateTime(1991, 1, 1)
        : DateTime.now();

    invoiceDate.value = defaultDate;

    int daysToAdd = AppConstants.isDueDateEnabled.value
        ? AppConstants.dueDateDays
        : 15;

    paymentDueDate.value = defaultDate.add(Duration(days: daysToAdd));

    selectedFromDate.value = AppConstants.isDemo.value
        ? DateTime(1990, 1, 1)
        : DateTime.now().subtract(Duration(days: 30));

    selectedToDate.value = AppConstants.isDemo.value
        ? DateTime(1992, 12, 31)
        : DateTime.now();

    // Initialize text controllers
    invoiceDateController.text = _formatDateForDisplay(invoiceDate.value);
    paymentDueDateController.text = _formatDateForDisplay(paymentDueDate.value);
    fromDateController.text = _formatDateForDisplay(selectedFromDate.value);
    toDateController.text = _formatDateForDisplay(selectedToDate.value);

    print("📅 [INIT] Dates initialized:");
    print("   - Invoice Date: ${invoiceDate.value}");
    print("   - Payment Due Date: ${paymentDueDate.value}");

    // ✅ CRITICAL: Use addPostFrameCallback to handle arguments AFTER widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeHandleArguments();
    });

    print("✅ [INIT] NewInvoiceController initialization complete");
  }

// ✅ NEW: Safe argument handling method
  void _safeHandleArguments() {
    print("🔍 [ARGS] Starting safe argument handling...");

    try {
      final arguments = Get.arguments;
      print("📥 [ARGS] Raw arguments: $arguments");

      if (arguments == null) {
        print("ℹ️ [ARGS] No arguments provided - loading as new invoice");
        _loadEssentialData();
        return;
      }

      // ✅ PRIORITY 1: Check for quotation conversion
      if (arguments is Map && arguments['isFromQuotation'] == true) {
        print("🔄 [ARGS] Quotation conversion detected");
        isFromQuotation.value = true;
        isFromQuotation.refresh(); // Force UI update

        _loadEssentialDataWithoutInit().then((_) {
          _handleQuotationConversion();
        });
        return;
      }

      // ✅ PRIORITY 2: Check for direct Invoice object (edit mode)
      if (arguments is Invoice) {
        print("🏷️ [ARGS] Direct Invoice object - edit mode");
        _handleDirectInvoiceEdit(arguments);
        return;
      }

      // ✅ PRIORITY 3: Check for Map with edit mode flag
      if (arguments is Map && arguments['editMode'] == true) {
        print("✏️ [ARGS] Edit mode via Map");
        _handleMapEditMode(arguments);
        return;
      }

      // ✅ DEFAULT: Normal new invoice
      print("📝 [ARGS] Default new invoice flow");
      _loadEssentialData();

    } catch (e, stackTrace) {
      print("❌ [ARGS ERROR] Exception during argument handling: $e");
      print("📄 [ARGS ERROR] Stack trace: $stackTrace");

      // Fallback to new invoice on error
      _loadEssentialData();
    }
  }

// ✅ NEW: Handle direct invoice object edit
  void _handleDirectInvoiceEdit(Invoice invoice) {
    print("🔧 [EDIT] Processing direct Invoice object");

    isEditMode.value = true;
    editingInvoiceId.value = invoice.invoiceId ?? '';

    try {
      originalInvoiceData.value = _invoiceToMap(invoice);
      print("✅ [EDIT] Invoice data mapped successfully");

      _loadEssentialData().then((_) {
        _prefillInvoiceData();
        if (invoiceItems.isEmpty) {
          addNewItem();
        }
      });
    } catch (e, stackTrace) {
      print("❌ [EDIT ERROR] Failed to process Invoice: $e");
      print("📄 [EDIT ERROR] Stack trace: $stackTrace");

      Get.snackbar(
        'Error',
        'Failed to load invoice for editing',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

// ✅ NEW: Handle Map-based edit mode
  void _handleMapEditMode(Map arguments) {
    print("🔧 [EDIT] Processing Map-based edit mode");

    isEditMode.value = true;
    editingInvoiceId.value = arguments['invoiceId']?.toString() ?? '';

    print("📝 [EDIT] Invoice ID: ${editingInvoiceId.value}");

    try {
      if (arguments['invoiceData'] == null) {
        throw Exception('No invoice data provided');
      }

      if (arguments['invoiceData'] is Invoice) {
        final invoiceObj = arguments['invoiceData'] as Invoice;
        originalInvoiceData.value = _invoiceToMap(invoiceObj);
        print("✅ [EDIT] Converted Invoice object to Map");
      } else if (arguments['invoiceData'] is Map) {
        originalInvoiceData.value =
        Map<String, dynamic>.from(arguments['invoiceData'] as Map);
        print("✅ [EDIT] Used Map data directly");
      } else {
        throw Exception('Invalid invoice data type: ${arguments['invoiceData'].runtimeType}');
      }

      _loadEssentialData().then((_) {
        _prefillInvoiceData();
        if (invoiceItems.isEmpty) {
          addNewItem();
        }
      });

    } catch (e, stackTrace) {
      print("❌ [EDIT ERROR] Failed to process Map edit: $e");
      print("📄 [EDIT ERROR] Stack trace: $stackTrace");

      Get.snackbar(
        'Error',
        'Failed to load invoice: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    }
  }


  @override
  void onReady() {
    super.onReady();

    print("🎯 [READY] NewInvoiceController onReady called");
    print("📊 [READY] Current state:");
    print("   - Invoice Type: ${invoiceType.value.name}");
    print("   - Edit Mode: ${isEditMode.value}");
    print("   - From Quotation: ${isFromQuotation.value}");
    print("   - Invoice Date: ${invoiceDate.value}");
    print("   - Payment Due Date: ${paymentDueDate.value}");

    // Load secondary data
    _loadSecondaryData();
    ensureControllersMatch();

    print("✅ [READY] onReady complete");
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

  void _handleQuotationConversion() async {
    print("🔄 [QUOTATION] Starting quotation conversion...");

    final arguments = Get.arguments;

    if (arguments == null || arguments is! Map) {
      print("❌ [QUOTATION] Invalid arguments for quotation conversion");
      return;
    }

    try {
      final Invoice quotation = arguments['quotation'];
      final List<InvoiceItem> quotationItems = arguments['quotationItems'];
      final String originalQuotationId = arguments['quotationId'] ?? quotation.invoiceId;

      print("📋 [QUOTATION] Converting quotation: $originalQuotationId");
      print("📦 [QUOTATION] Items count: ${quotationItems.length}");

      isFromQuotation.value = true;
      sourceQuotationId.value = originalQuotationId;

      await _prefillFromQuotation(quotation, quotationItems, originalQuotationId);

      print("✅ [QUOTATION] Conversion complete");

    } catch (e, stackTrace) {
      print("❌ [QUOTATION ERROR] Failed to convert: $e");
      print("📄 [QUOTATION ERROR] Stack trace: $stackTrace");

      Get.snackbar(
        'Error',
        'Failed to load quotation data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void forceRefresh() {
    invoiceType.refresh();
    isEditMode.refresh();
    isFromQuotation.refresh();
    update();
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
      DateTime defaultDate;
      if (AppConstants.isDemo.value) {
        // For demo mode, set default to middle of allowed range
        defaultDate = DateTime(1991, 1, 1);
        print("🔒 Demo mode: Setting default date to 1991-01-01");
      } else {
        // For regular users, use today's date
        defaultDate = DateTime.now();
      }

      invoiceDate.value = defaultDate;
      invoiceDateController.text = _formatDate(defaultDate);


// NEW CODE (ADD):
// ✅ Set payment due date based on company settings
      int daysToAdd = AppConstants.isDueDateEnabled.value
          ? AppConstants.dueDateDays
          : 15; // Default to 15 days if not enabled

      paymentDueDate.value = defaultDate.add(Duration(days: daysToAdd));
      paymentDueDateController.text = _formatDate(paymentDueDate.value);

      print("📅 Quotation conversion - Invoice date: ${invoiceDate.value}");
      print("📅 Quotation conversion - Payment due date: ${paymentDueDate.value} (+$daysToAdd days)");



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
      if (invoiceData['paymentMode'] != null) {
        paymentMode.value = invoiceData['paymentMode'].toString();
        print("✅ Restored payment mode: ${paymentMode.value}");
      }
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
      forceRefresh();
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
    // ✅ Use AppConstants.isDemo directly - no async needed!
    final DateTime firstDate = AppConstants.isDemo.value ? DateTime(1990, 1, 1) : DateTime(2000);
    final DateTime lastDate = AppConstants.isDemo.value ? DateTime(1992, 12, 31) : DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: invoiceDate.value.isBefore(firstDate) || invoiceDate.value.isAfter(lastDate)
          ? firstDate
          : invoiceDate.value,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: AppConstants.isDemo.value ? 'Select Date (Demo: 1990-1992 only)' : 'Select Invoice Date',
    );

    if (picked != null && picked != invoiceDate.value) {
      invoiceDate.value = picked;
      invoiceDateController.text = _formatDate(picked);

      // ✅ AUTO-CALCULATE DUE DATE (15 days from invoice date)
      if (!isEditMode.value) {
        // 🆕 Use dueDateDays from AppConstants (from company settings)
        int daysToAdd = AppConstants.isDueDateEnabled.value
            ? AppConstants.dueDateDays
            : 15; // Default to 15 days if not enabled

        paymentDueDate.value = picked.add(Duration(days: daysToAdd));


        // ✅ Ensure due date is also within demo range if applicable
        if (AppConstants.isDemo.value && paymentDueDate.value.isAfter(lastDate)) {
          paymentDueDate.value = lastDate;
        }

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
    final DateTime firstDate = AppConstants.isDemo.value
        ? DateTime(1990, 1, 1)
        : invoiceDate.value;
    final DateTime lastDate = AppConstants.isDemo.value
        ? DateTime(1992, 12, 31)
        : DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: paymentDueDate.value.isBefore(firstDate) || paymentDueDate.value.isAfter(lastDate)
          ? firstDate
          : paymentDueDate.value,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: AppConstants.isDemo.value ? 'Select Date (Demo: 1990-1992 only)' : 'Select Payment Due Date',
    );

    if (picked != null && picked != paymentDueDate.value) {
// ✅ Validate that due date is not before invoice date
      if (picked.isBefore(invoiceDate.value)) {
        Get.snackbar(
          'Invalid Date',
          'Due date cannot be before invoice date',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          icon: Icon(Icons.warning, color: Colors.orange.shade700),
          duration: Duration(seconds: 3),
        );
        return;
      }
      paymentDueDate.value = picked;
      paymentDueDateController.text = _formatDate(picked);

      // Show how many days until due
      int daysUntil = picked.difference(invoiceDate.value).inDays;
      Get.snackbar(
        'Due Date Set',
        'Payment due in $daysUntil days',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: Duration(seconds: 2),
      );
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
  /// ✅ FIXED: Fetch complete customer details from Google Sheets
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

      // ✅ Fetch from Google Sheets instead of Firestore
      final allCustomers = await GoogleSheetService.getCustomers(
        companyId: companyId,
        userId: user.uid,
      );

      // Find the specific customer
      final customerData = allCustomers.firstWhere(
            (customer) => customer['customerId'] == customerId,
        orElse: () => <String, dynamic>{},
      );

      if (customerData.isEmpty) {
        print("⚠️ No customer found with customerId: $customerId");
        return;
      }

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

      print("✅ Customer details fetched and populated successfully from Google Sheets");

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

  /// ✅ FIXED: Load customers from Google Sheets instead of Firebase
  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;

      await _loadWithCache('customers', () async {
        final user = _auth.currentUser;
        if (user == null) {
          print("⚠️ No authenticated user found");
          return;
        }

        String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
        print("📦 Loading customers for Company ID: $companyId");

        if (companyId.isEmpty) {
          print("⚠️ No company ID found");
          // Get.snackbar(
          //   'Company Required',
          //   'Please select a company first',
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: Colors.orange,
          //   colorText: Colors.white,
          // );
          return;
        }

        // ✅ Fetch customers from Google Sheets
        final allCustomers = await GoogleSheetService.getCustomers(
          companyId: companyId,
          userId: user.uid,
        );

        print("📊 Total customers fetched from Google Sheets: ${allCustomers.length}");

        // ✅ Filter only active customers AND sundryType == "Debtors"
        customers.clear();
        int activeDebtorsCount = 0;
        int inactiveCount = 0;
        int creditorsCount = 0;

        for (var customer in allCustomers) {
          // Check if customer is active
          bool isActive = customer['isActive']?.toString().toLowerCase() == 'true';

          // ✅ NEW: Check if sundryType is "Debtors"
          String sundryType = customer['sundryType']?.toString() ?? '';

          if (isActive && sundryType.toLowerCase() == 'debtors') {
            customers.add(customer);
            activeDebtorsCount++;
            print("✅ Added debtor customer: ${customer['name']} (ID: ${customer['customerId']})");
          } else {
            if (!isActive) {
              inactiveCount++;
              print("⏭️ Skipped inactive customer: ${customer['name']}");
            } else if (sundryType.toLowerCase() != 'debtors') {
              creditorsCount++;
              print("⏭️ Skipped creditor customer: ${customer['name']} (Type: $sundryType)");
            }
          }
        }

        // Update customer count with only active debtors
        customerCount.value = customers.length;

        print("📊 Customer Summary:");
        print("   Active Debtors: $activeDebtorsCount");
        print("   Creditors (skipped): $creditorsCount");
        print("   Inactive (skipped): $inactiveCount");
        print("   Total shown: ${customerCount.value}");

        if (customers.isEmpty) {
          print("⚠️ No active debtor customers found");
          // showCustomSnackbar(
          //   title: "No Customers",
          //   message: "No debtor customers available. Please add customers first.",
          //   baseColor: Colors.orange.shade700,
          //   icon: Icons.info_outline,
          // );
        } else {
          // showCustomSnackbar(
          //   title: "Customers Loaded",
          //   message: "Found $activeDebtorsCount debtor customer${activeDebtorsCount != 1 ? 's' : ''}",
          //   baseColor: Colors.green.shade700,
          //   icon: Icons.check_circle_outline,
          // );
        }

        return null;
      });

    } catch (e, stackTrace) {
      print("❌ Error loading customers: $e");
      print("📄 Stack trace: $stackTrace");

      // Get.snackbar(
      //   'Error',
      //   'Failed to load customers: ${e.toString()}',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   duration: Duration(seconds: 4),
      // );
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
          print("⚠️ No items found");
          // showCustomSnackbar(
          //   title: "No Items",
          //   message: "No items found for the current user",
          //   baseColor: Colors.orange.shade700,
          //   icon: Icons.info_outline,
          // );
        } else {
          print("✅ Found ${items.length} items");
          // showCustomSnackbar(
          //   title: "Success",
          //   message: "Found ${items.length} items",
          //   baseColor: Colors.green.shade700,
          //   icon: Icons.check_circle_outline,
          // );
        }

        return null;
      });

    } catch (e) {
      print("❌ Failed to load items: $e");
      // showCustomSnackbar(
      //   title: "Error",
      //   message: "Failed to load items: $e",
      //   baseColor: Colors.red.shade700,
      //   icon: Icons.error_outline,
      // );
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
      print("❌ Failed to load invoices: $e");
      // showCustomSnackbar(
      //   title: "Error",
      //   message: "Failed to load invoices: $e",
      //   baseColor: Colors.red.shade700,
      //   icon: Icons.error_outline,
      // );
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

    // ✅ Set default date based on demo mode
    DateTime defaultDate;
    if (AppConstants.isDemo.value) {
      // For demo mode, set default to middle of allowed range (Jan 1, 1991)
      defaultDate = DateTime(1991, 1, 1);
    } else {
      // For regular users, use today's date
      defaultDate = DateTime.now();
    }

    dueDate.value = defaultDate;
    dueDateController.text = _formatDate(defaultDate);

    // ✅ Set invoice date
    invoiceDate.value = defaultDate;
    invoiceDateController.text = _formatDate(defaultDate);

    // ✅ NEW: Set payment due date based on company settings
    int daysToAdd = AppConstants.isDueDateEnabled.value
        ? AppConstants.dueDateDays
        : 15; // Default to 15 days if not enabled


    // ✅ Set payment due date to 15 days from default date
    DateTime dueDateValue = defaultDate.add(Duration(days: daysToAdd));

    // ✅ Ensure due date is also within demo range if applicable
    if (AppConstants.isDemo.value && dueDateValue.isAfter(DateTime(1992, 12, 31))) {
      dueDateValue = DateTime(1992, 12, 31);
    }

    paymentDueDate.value = dueDateValue;
    paymentDueDateController.text = _formatDate(dueDateValue);

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
      String counterField;
      switch (invoiceType.value) {
        case InvoiceType.invoice:
        case InvoiceType.quickInvoice:  // ✅ Use same counter as invoice
          counterField = 'currentInvoiceNumber';
          break;
        case InvoiceType.quotation:
          counterField = 'currentQuotationNumber';
          break;
      }

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
        // Quick Invoice and Invoice use SAME counter
        String counterField;
        switch (invoiceType.value) {
          case InvoiceType.invoice:
          case InvoiceType.quickInvoice:  // ✅ Use same counter as invoice
            counterField = 'currentInvoiceNumber';
            break;
          case InvoiceType.quotation:
            counterField = 'currentQuotationNumber';
            break;
        }

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
    invoiceType.refresh();
    update();

    final nextNumber = await getNextInvoiceNumber();
    invoiceNumberController.text = nextNumber;

    // Show info when switching to Quick Invoice
    if (type.isQuickMode) {
      Get.snackbar(
        'Quick Invoice Mode',
        'Only mobile number is required. Create invoices instantly!',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: Icon(Icons.flash_on, color: Colors.green.shade700),
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void selectCustomer(Map<String, dynamic>? customer) {
    if (customer == null) {
      selectedCustomerId.value = '';
      clearCustomerSelection();
      showCustomerForm.value = false;
      return;
    }

    // ✅ Double-check if customer is still active before selection
    bool isActive = customer['isActive']?.toString().toLowerCase() == 'true';

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

    // ✅ Map Google Sheets fields to form controllers
    selectedCustomerId.value = customer['customerId'] ?? '';
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
    print("   PAN: ${customerPanController.text}");
    print("   GST: ${customerGstController.text}");
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
    // ✅ Initialize controllers AFTER adding item
    ensureControllersMatch();

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

      invoiceItems[index] = item.copyWith(
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

      // if (quantity != null) {
      //   updateQuantityController(index, quantity);
      // }
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
  ///chnaged 18/12
  // TextEditingController getQuantityController(int index, {double? initialValue}) {
  //   // Ensure we have the right number of controllers
  //   while (quantityControllers.length < invoiceItems.length) {
  //     final itemIndex = quantityControllers.length;
  //     final item = invoiceItems[itemIndex];
  //
  //     String quantityText = "";
  //
  //     quantityControllers.add(
  //       TextEditingController(text: quantityText),
  //     );
  //   }
  //
  //   // Remove extra controllers if items were removed
  //   while (quantityControllers.length > invoiceItems.length) {
  //     final removedController = quantityControllers.removeLast();
  //     removedController.dispose();
  //   }
  //
  //   if (index >= quantityControllers.length) {
  //     print("⚠️ Warning: Index $index is out of bounds for quantityControllers");
  //     return TextEditingController();
  //   }
  //
  //   // ✅ Only update if initialValue is explicitly provided AND controller is empty
  //   if (initialValue != null && quantityControllers[index].text.isEmpty) {
  //     String newText = initialValue % 1 == 0
  //         ? initialValue.toInt().toString()
  //         : initialValue.toString();
  //
  //     quantityControllers[index].text = newText;
  //     print("📝 Set initial quantity at index $index to: $newText");
  //   }
  //
  //   return quantityControllers[index];
  // }


  void ensureControllersMatch() {
    // Ensure quantity controllers match items
    while (quantityControllers.length < invoiceItems.length) {
      final index = quantityControllers.length;
      final item = invoiceItems[index];
      quantityControllers.add(
        TextEditingController(
          text: item.quantity > 0 ? item.quantity.toString() : '',
        ),
      );
    }

    // Remove extra controllers
    while (quantityControllers.length > invoiceItems.length) {
      final controller = quantityControllers.removeLast();
      controller.dispose();
    }

    // Ensure price controllers match items
    while (priceControllers.length < invoiceItems.length) {
      final index = priceControllers.length;
      final item = invoiceItems[index];
      priceControllers.add(
        TextEditingController(
          text: item.rate > 0 ? item.rate.toInt().toString() : '',
        ),
      );
    }

    // Remove extra price controllers
    while (priceControllers.length > invoiceItems.length) {
      final controller = priceControllers.removeLast();
      controller.dispose();
    }
  }

  TextEditingController getQuantityController(int index, {double? initialValue}) {
    // ✅ Don't modify lists during build - just return what exists
    if (index >= quantityControllers.length || index < 0) {
      print("⚠️ Index $index out of bounds for quantityControllers (length: ${quantityControllers.length})");
      // Return a temporary controller (will be fixed on next frame)
      return TextEditingController(text: initialValue?.toString() ?? '');
    }

    final controller = quantityControllers[index];

    // Only update text if different (avoid infinite loops)
    if (initialValue != null) {
      String newText = initialValue % 1 == 0
          ? initialValue.toInt().toString()
          : initialValue.toString();

      if (controller.text != newText) {
        // Use post-frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!controller.hasListeners) return; // Skip if disposed
          try {
            controller.text = newText;
          } catch (e) {
            print("⚠️ Could not update controller: $e");
          }
        });
      }
    }

    return controller;
  }

// // Keep this method for programmatic updates:
//   void updateQuantityController(int index, double newQuantity) {
//     if (index < quantityControllers.length) {
//       final formatted = newQuantity.toString();
//       if (quantityControllers[index].text != formatted) {
//         quantityControllers[index].text = formatted;
//       }
//     }
//   }

  void selectRemoteItemForIndex(int index, Item item) {
    if (index >= invoiceItems.length) return;

    // ✅ NEW: Stock Check Logic
    // 1. Check if business is NOT service (Services don't use stock)

    final businessType = AppConstants.businessType?.toLowerCase() ?? '';
    final isProductBusiness = businessType != 'service' && businessType != 'client';

    if (isProductBusiness) {
      // 2. Check if stock is 0 or less
      // Note: Make sure your Item model has a 'stock' or 'quantity' property.
      // Replace 'item.stock' with 'item.currentStock' if your variable name is different.
      if ((item.currentStock ?? 0) <= 0) {

        // Use the unit in the message (e.g., "0 PCS")
        String unit = item.unitOfMeasurement ?? 'units';

        // 3. Show Notification
        Get.snackbar(
          "Out of Stock",
          "Item '${item.itemName}' has 0 $unit stock available.\nPlease add stock in Inventory first.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          icon: Icon(Icons.inventory_2_outlined, color: Colors.white),
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(16),
        );

        // 4. Stop execution (Do not select the item)
        return;
      }
    }

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
      //updateQuantityController(existingIndex, newQty);

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
      rate: item.sellPrice.toDouble(),
      purchasePrice: item.price.toDouble(),
      gstRate: gstRateToUse,
      itemId: item.itemId,
      itemName: item.itemName,
      totalPrice: currentItem.quantity * item.sellPrice.toDouble(),
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
    //updateQuantityController(index, currentItem.quantity);
    updatePriceController(index, item.sellPrice.toDouble());
    ensureControllersMatch();

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
      print("🗑️ Removing item at index $index");
      print("📊 Before removal: ${invoiceItems.length} items");

      // ✅ Remove the item
      invoiceItems.removeAt(index);

      // ✅ Remove corresponding controllers
      if (index < priceControllers.length) {
        priceControllers[index].dispose();
        priceControllers.removeAt(index);
      }

      if (index < quantityControllers.length) {
        quantityControllers[index].dispose();
        quantityControllers.removeAt(index);
      }

      // ✅ Clear violations for removed item
      itemsWithStockViolation.remove(index);
      violationMessages.remove(index);

      // ✅ Rebuild violation indices (shift them down)
      final newViolations = <int>{};
      final newMessages = <int, String>{};

      for (var i in itemsWithStockViolation) {
        if (i > index) {
          newViolations.add(i - 1);
          newMessages[i - 1] = violationMessages[i] ?? '';
        } else if (i < index) {
          newViolations.add(i);
          newMessages[i] = violationMessages[i] ?? '';
        }
      }

      itemsWithStockViolation.assignAll(newViolations);
      violationMessages.assignAll(newMessages);
      ensureControllersMatch();

      calculateTotals();

      Get.snackbar(
        'Item Removed',
        'Item successfully removed from invoice',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
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
      paymentMode.value = 'Cash';
    }
    else if (status == 'Pending') {
      receivedAmount.value = 0.0;
      receivedAmountController.clear();
      pendingAmount.value = totalAmount.value;
      paymentMode.value = '';
    }
    else if (status == 'Partial') {
      // Keep current received amount or set to 0
      pendingAmount.value = calculatedPendingAmount;
      paymentMode.value = 'Cash';
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
      'purchasePrice': item.purchasePrice.toString(),
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

  Future<bool> saveInvoiceOld({required bool isDraft}) async {
    try {
      // ✅ Quick Invoice validation - only mobile required
      if (invoiceType.value.isQuickMode) {
        if (customerMobileController.text.trim().isEmpty) {
          showCustomSnackbar(
            title: "Mobile Required",
            message: "Please enter customer mobile number for Quick Invoice",
            baseColor: Colors.red.shade700,
            icon: Icons.phone_missed,
          );
          return false;
        }

        // Validate mobile number format
        String mobile = customerMobileController.text.trim();
        if (mobile.length < 10) {
          showCustomSnackbar(
            title: "Invalid Mobile",
            message: "Please enter a valid 10-digit mobile number",
            baseColor: Colors.orange.shade700,
            icon: Icons.warning,
          );
          return false;
        }

        // Auto-populate customer name as "Customer-{last 4 digits}" if empty
        if (customerNameController.text.trim().isEmpty) {
          customerNameController.text = "Customer-${mobile.substring(mobile.length - 4)}";
        }
      } else {
        // Regular invoice/quotation validation
        if (showCustomerForm.value && customerNameController.text.trim().isNotEmpty) {
          validateManualCustomerEntry();
        }

        if (customerNameController.text.trim().isEmpty) {
          showCustomSnackbar(
            title: "Customer Required",
            message: "Please select a customer or enter customer details",
            baseColor: Colors.red.shade700,
            icon: Icons.person_outline,
          );
          return false;
        }
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

      // ✅ Check for ANY stock violations
      if (hasAnyStockViolation) {
        String violationList = violationMessages.values.join('\n• ');

        showCustomSnackbar(
          title: "Cannot Create Invoice",
          message: "Fix these issues first:\n• $violationList",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
          duration: Duration(seconds: 5),
        );
        return false;
      }

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
        'invoiceType': invoiceType.value.name,
        'paymentMode': (paymentStatus.value == 'Paid' || paymentStatus.value == 'Partial')
            ? paymentMode.value
            : '',  // Empty if Pending
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

        // ✅ CRITICAL FIX: Close any open snackbars BEFORE navigation
        try {
          Get.closeAllSnackbars();
        } catch (e) {
          print("⚠️ Could not close snackbars: $e");
        }

        // ✅ Navigate back first
        Get.back(result: true);
        _refreshParentControllers();

        await Future.delayed(Duration(milliseconds: 100), () {
          showCustomSnackbar(
            title: "Success",
            message: "Invoice updated successfully!",
            baseColor: Colors.green.shade700,
            icon: Icons.check_circle_outline,
          );
        },);

        return true;

      }
      else {
        final actualInvoiceId = await incrementAndGetInvoiceNumber();
        invoiceNumberController.text = actualInvoiceId;
        invoiceData['invoiceId'] = actualInvoiceId;

        await GoogleSheetService.addInvoice(invoiceData, AppConstants.userId);

        List<Map<String, dynamic>> itemsData =
        invoiceItems.map((item) => createInvoiceItemData(item)).toList();

        await GoogleSheetService.addInvoiceItemsBatch(itemsData, AppConstants.userId);

// ✅ FIX: Prevent Double Stock Deduction
        // Filter items: Only deduct stock for items that do NOT come from a Challan.
        // If an item has a challanId, stock was already deducted when the Challan was made.
        List<InvoiceItem> itemsToDeductStock = invoiceItems.where((item) {
          return (item.challanId == null || item.challanId!.isEmpty);
        }).toList();

        if (itemsToDeductStock.isNotEmpty) {
          print("📉 Deducting stock for ${itemsToDeductStock.length} manual items (Challan items skipped)");
          await GoogleSheetService.updateStockAfterInvoice(itemsToDeductStock);
        } else {
          print("ℹ️ No stock deduction needed (All items are from Challan)");
        }

        //await GoogleSheetService.updateStockAfterInvoice(invoiceItems);

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
            issueDate: invoiceDate.value,
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
            //dueDateController.text,

            _formatDate(invoiceDate.value),
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
          await InvoiceHelper.generateAndShareInvoicePrint(
            invoiceModels,
            customerNameController.text.trim(),
            customerMobileController.text.trim(),
            customerEmailController.text.trim(),
            customerPanController.text.trim(),
            customerGstController.text.trim(),
            customerAddressController.text.trim(),
            subtotal.value,
           // dueDateController.text,
            _formatDate(invoiceDate.value),
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
        // ✅ CRITICAL FIX: Close all snackbars BEFORE navigation
        try {
          Get.closeAllSnackbars();
        } catch (e) {
          print("⚠️ Could not close snackbars: $e");
        }

        // ✅ Clear form and navigate back FIRST
        clearForm();
        Get.back(result: true);

        showCustomSnackbar(
          title: "Success",
          message: "Invoice created successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );

        return true;
      }

    } catch (e, stackTrace) {
      print("Error saving invoice: $e");
      print("Stack trace: $stackTrace");

      // ✅ Close any open snackbars before showing error
      try {
        Get.closeAllSnackbars();
      } catch (e) {
        print("⚠️ Could not close snackbars: $e");
      }

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



  Future<bool> saveInvoice({required bool isDraft}) async {
    try {
      // ---------------- VALIDATION STEPS (SAME AS BEFORE) ----------------
      if (invoiceType.value.isQuickMode) {
        if (customerMobileController.text.trim().isEmpty) {
          showCustomSnackbar(title: "Mobile Required", message: "Please enter customer mobile number", baseColor: Colors.red.shade700, icon: Icons.phone_missed);
          return false;
        }
        String mobile = customerMobileController.text.trim();
        if (mobile.length < 10) {
          showCustomSnackbar(title: "Invalid Mobile", message: "Please enter valid mobile number", baseColor: Colors.orange.shade700, icon: Icons.warning);
          return false;
        }
        if (customerNameController.text.trim().isEmpty) {
          customerNameController.text = "Customer-${mobile.substring(mobile.length - 4)}";
        }
      } else {
        if (showCustomerForm.value && customerNameController.text.trim().isNotEmpty) validateManualCustomerEntry();
        if (customerNameController.text.trim().isEmpty) {
          showCustomSnackbar(title: "Customer Required", message: "Select or enter customer details", baseColor: Colors.red.shade700, icon: Icons.person_outline);
          return false;
        }
      }

      if (!formKey.currentState!.validate()) {
        showCustomSnackbar(title: "Validation Error", message: "Fill all required fields", baseColor: Colors.orange.shade700, icon: Icons.warning);
        return false;
      }

      if (!_validateInvoiceItems()) return false;
      _removeEmptyItemsBeforeSave();

      if (hasAnyStockViolation) {
        showCustomSnackbar(title: "Cannot Create Invoice", message: "Fix stock issues first", baseColor: Colors.red.shade700, icon: Icons.error_outline);
        return false;
      }

      if (invoiceItems.isEmpty) {
        showCustomSnackbar(title: "No Valid Items", message: "Add at least one valid item", baseColor: Colors.red.shade700, icon: Icons.error_outline);
        return false;
      }

      // ---------------- SAVE LOGIC ----------------
      isLoading.value = true;
      debugAllItemsCustomerId();
      calculateTotals();

      String finalCustomerId = _getValidCustomerId();
      double calculatedInvoiceProfit = 0.0;
      for (var item in invoiceItems) {
        double sellTotal = item.rate * item.quantity;
        double purchaseTotal = item.purchasePrice * item.quantity;
        calculatedInvoiceProfit += (sellTotal - purchaseTotal);
      }

      // Prepare Data
      Map<String, dynamic> invoiceData = {
        'invoiceId': invoiceNumberController.text,
        'customerId': finalCustomerId,
        'customerName': customerNameController.text.trim(),
        'customerPan': customerPanController.text.trim(),
        'customerGst': customerGstController.text.trim(),
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
        'invoiceType': invoiceType.value.name,
        'paymentMode': (paymentStatus.value == 'Paid' || paymentStatus.value == 'Partial') ? paymentMode.value : '',
        'profit': calculatedInvoiceProfit,
      };

      // Save to Google Sheets
      if (isInEditMode) {
        await GoogleSheetService.updateInvoice(invoiceData, AppConstants.userId);
        List<Map<String, dynamic>> itemsData = [];
        for (var item in invoiceItems) {
          itemsData.add(createInvoiceItemData(item));
        }
        await GoogleSheetService.updateInvoiceItems(invoiceNumberController.text, itemsData, AppConstants.userId);
      } else {
        final actualInvoiceId = await incrementAndGetInvoiceNumber();
        invoiceNumberController.text = actualInvoiceId;
        invoiceData['invoiceId'] = actualInvoiceId;

        await GoogleSheetService.addInvoice(invoiceData, AppConstants.userId);
        List<Map<String, dynamic>> itemsData = invoiceItems.map((item) => createInvoiceItemData(item)).toList();
        await GoogleSheetService.addInvoiceItemsBatch(itemsData, AppConstants.userId);

        // Deduct Stock (Skip challan items)
        List<InvoiceItem> itemsToDeductStock = invoiceItems.where((item) {
          return (item.challanId == null || item.challanId!.isEmpty);
        }).toList();

        if (itemsToDeductStock.isNotEmpty) {
          await GoogleSheetService.updateStockAfterInvoice(itemsToDeductStock);
        }

        // Update Challan Status
        List<String> challanIds = invoiceItems
            .where((item) => (item.challanId ?? '').isNotEmpty)
            .map((item) => item.challanId!)
            .toSet().toList();

        if (challanIds.isNotEmpty) {
          await GoogleSheetService.updateChallanStatusBatch(challanIds, "Progress", AppConstants.userId);
        }
      }

      // Refresh Controllers
      _refreshParentControllers();

      // ---------------- PREPARE DATA FOR PRINT/PDF ----------------
      List<Invoice> invoiceModels = invoiceItems.map((item) {
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
          issueDate: invoiceDate.value,
          dueDate: paymentDueDate.value, // ✅ Use paymentDueDate
          subtotal: subtotal.value,
          gst: item.gstRate,
          gstRate: item.gstRate,
          gstAmount: gstAmount.value,
          totalAmount: totalAmount.value,
          notes: notesController.text,
          status: paymentStatus.value,
          items: [item],
        );
      }).toList();

      // ---------------- STOP LOADING & SHOW DIALOG ----------------
      isLoading.value = false;

      // ✅ OPEN DIALOG: Print vs PDF
      await _showOutputFormatDialog(invoiceModels);

      return true;

    } catch (e, stackTrace) {
      print("Error saving invoice: $e");
      print("Stack trace: $stackTrace");
      isLoading.value = false;
      showCustomSnackbar(title: "Error", message: "Failed: ${e.toString()}", baseColor: Colors.red.shade700, icon: Icons.error);
      return false;
    }
  }

// ✅ NEW: DIALOG FOR INVOICE PRINT/PDF
  Future<void> _showOutputFormatDialog(List<Invoice> invoiceModels) async {
    final bool hasChallan = invoiceItems.any((it) => (it.challanId ?? '').isNotEmpty);

    await Get.defaultDialog(
      title: "Invoice Saved Successfully",
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor),
      content: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 50),
          SizedBox(height: 10),
          Text("Select output format:"),
          SizedBox(height: 20),

          // 1. Thermal Print
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor, foregroundColor: Colors.white),
              icon: Icon(Icons.print),
              label: Text("Thermal Print "),
              onPressed: () async {
                Get.back(); // Close Dialog

                if (hasChallan) {
                  await InvoiceHelper.generateAndShareInvoiceFromChallan(
                    invoiceItems, // Using items directly for challan based
                    invoiceNumberController.text,
                    _formatDate(invoiceDate.value),
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
                  // ✅ Using Standard Print Method
                  await InvoiceHelper.generateAndShareInvoicePrint(
                    invoiceModels,
                    customerNameController.text.trim(),
                    customerMobileController.text.trim(),
                    customerEmailController.text.trim(),
                    customerPanController.text.trim(),
                    customerGstController.text.trim(),
                    customerAddressController.text.trim(),
                    subtotal.value,
                    _formatDate(invoiceDate.value),
                    totalAmount.value,
                    notesController.text,
                    companyData.value,
                    invoiceType.value,
                    gstAmount.value,
                    _formatDate(paymentDueDate.value),
                  );
                }
                _finishAndClose();
              },
            ),
          ),

          SizedBox(height: 10),

          // 2. Standard PDF (A4)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.tealColor),
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Save as PDF "),
              onPressed: () async {
                Get.back(); // Close Dialog

                // ✅ Standard A4 PDF Generation (Existing Method)
                // NOTE: Use your existing A4 method here.
                // Assuming 'generateAndShareInvoice' exists for A4.

                // If you don't have a separate method, use the same one but maybe pass a flag?
                // Or call the specific A4 method if you have it.

                await InvoiceHelper.generateAndShareInvoice(
                  invoiceModels,
                  customerNameController.text.trim(),
                  customerMobileController.text.trim(),
                  customerEmailController.text.trim(),
                  customerPanController.text.trim(),
                  customerGstController.text.trim(),
                  customerAddressController.text.trim(),
                  subtotal.value,
                  _formatDate(invoiceDate.value),
                  totalAmount.value,
                  notesController.text,
                  companyData.value,
                  invoiceType.value,
                  gstAmount.value,
                  _formatDate(paymentDueDate.value),
                );

                _finishAndClose();
              },
            ),
          ),

          SizedBox(height: 10),

          // 3. Skip
          TextButton(
            onPressed: () {
              Get.back();
              _finishAndClose();
            },
            child: Text("Skip & Close", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

// ✅ Correct Navigation
  void _finishAndClose() {
    clearForm();
    Get.until((route) => route.settings.name == DashboardScreen.pageId);

    // 🔄 REFRESH DATA SILENTLY (Optional but Recommended)
    try {
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDataSilently();
      }

      if (Get.isRegistered<InvoiceListController>()) {
        print("🔄 Refreshing Invoice List...");
        Get.find<InvoiceListController>().loadInvoices();
      }
    } catch (e) {
      print("Error refreshing dashboard: $e");
    }

    showCustomSnackbar(
      title: "Success",
      message: "Invoice saved successfully!",
      baseColor: Colors.green.shade700,
      icon: Icons.check_circle_outline,
    );
  }

  void updatePaymentMode(String mode) {
    paymentMode.value = mode;
    print("Payment mode updated to: $mode");
  }

  void clearForm() {
    formKey.currentState?.reset();
    // ✅ Dispose description controllers before clearing items
    for (var item in invoiceItems) {
      item.descriptionController?.dispose();
    }

    invoiceItems.clear();
    clearCustomerSelection();
    notesController.clear();
    paymentStatus.value = 'Pending';
    receivedAmountController.clear();
    receivedAmount.value = 0.0;
    pendingAmount.value = 0.0;
    // ✅ Clear violations
    itemsWithStockViolation.clear();
    violationMessages.clear();

    calculateTotals();
    // ✅ Clear all controllers
    for (var controller in priceControllers) {
      controller.dispose();
    }
    priceControllers.clear();

    for (var controller in quantityControllers) {
      controller.dispose();
    }
    quantityControllers.clear();

    initializeInvoice();
  }

  void showCustomSnackbar({
    required String title,
    required String message,
    required Color baseColor,
    required IconData icon,
    Duration? duration,
  }) {
    try {
      // ✅ Check if we're still on a valid route
      if (Get.context == null) {
        print("⚠️ No context available for snackbar");
        return;
      }

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
    } catch (e) {
      print("⚠️ Error showing snackbar: $e");
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    // 1. Define constraints
    final DateTime firstDate = AppConstants.isDemo.value
        ? DateTime(1990, 1, 1)
        : DateTime(2000);

    final DateTime lastDate = AppConstants.isDemo.value
        ? DateTime(1992, 12, 31)
        : DateTime.now();

    // 2. Ensure initialDate is valid within range
    DateTime initial = selectedFromDate.value;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: AppConstants.isDemo.value
          ? 'Select From Date (Demo: 1990-1992)'
          : 'Select From Date',
    );

    if (picked != null && picked != selectedFromDate.value) {
      selectedFromDate.value = picked;
      fromDateController.text = _formatDateForDisplay(picked);
      loadChallansForInvoice();
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    // 1. Define constraints
    final DateTime firstDate = AppConstants.isDemo.value
        ? DateTime(1990, 1, 1)
        : DateTime(2000);

    final DateTime lastDate = AppConstants.isDemo.value
        ? DateTime(1992, 12, 31)
        : DateTime.now();

    // 2. Ensure initialDate is valid within range
    DateTime initial = selectedToDate.value;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: AppConstants.isDemo.value
          ? 'Select To Date (Demo: 1990-1992)'
          : 'Select To Date',
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
  quickInvoice,  // NEW: Quick Invoice type
}

extension InvoiceTypeExtension on InvoiceType {
  String get name {
    switch (this) {
      case InvoiceType.invoice:
        return 'Invoice';
      case InvoiceType.quotation:
        return 'Quotation';
      case InvoiceType.quickInvoice:
        return 'Quick Invoice';
    }
  }

  String get prefix {
    switch (this) {
      case InvoiceType.invoice:
        return 'INV';
      case InvoiceType.quotation:
        return 'QUO';
      case InvoiceType.quickInvoice:
        return 'INV';  // Use same prefix as regular invoice
    }
  }

  // NEW: Check if minimal fields are required
  bool get isQuickMode {
    return this == InvoiceType.quickInvoice;
  }
}