import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/controller/bash_controller.dart';
import 'package:demo_prac_getx/utils/pdf_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../model/model.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import '../widgets/widgets.dart';
import 'controller.dart';


class NewChallanController extends BaseController {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final customerNameController = TextEditingController();
  final customerMobileController = TextEditingController();
  final customerEmailController = TextEditingController();
  final customerPanController = TextEditingController();
  final customerGstController = TextEditingController();
  final customerAddressController = TextEditingController();
  final challanNumberController = TextEditingController();
  final challanDateController = TextEditingController();
  final notesController = TextEditingController();

  // Observable variables
  var selectedCustomer = Rxn<Map<String, dynamic>>();
  var customers = <Map<String, dynamic>>[].obs;
  var items = <Map<String, dynamic>>[].obs;
  var itemList = <Item>[].obs;
  var challanList = <Challan>[].obs;
  var challanItems = <ChallanItem>[].obs;
  var challanDate = DateTime.now().obs;
  var showCustomerForm = false.obs;
  var customerCount = 0.obs;
  var totalItems = 0.obs;
  final RxString selectedCustomerId = ''.obs;

  // Calculation observables
  var subtotal = 0.0.obs;
  var paymentStatus = 'Pending'.obs;
  var totalAmount = 0.0.obs;
  var discountType = 'amount'.obs;
  var discountAmount = 0.0.obs;
  var companyData = <String, dynamic>{}.obs;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var priceControllers = <TextEditingController>[].obs;
  var gstAmount = 0.0.obs;
  var quantityControllers = <TextEditingController>[].obs;

  final RxBool isEditMode = false.obs;
  final RxString editingChallanId = ''.obs;
  final Rxn<Map<String, dynamic>> originalChallanData = Rxn<Map<String, dynamic>>();
  final RxInt originalItemsCount = 0.obs;

// ✅ ADD THESE (multi-item tracking):
  final RxSet<int> itemsWithStockViolation = <int>{}.obs; // Track indices of items with violations
  final RxMap<int, String> violationMessages = <int, String>{}.obs; // Track error messages per item

// ✅ ADD THIS COMPUTED PROPERTY:
  bool get hasAnyStockViolation => itemsWithStockViolation.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
    // ✅ Generate challan ID first (only depends on challans)
    //initializeChallan();

    // Only initialize new challan if NOT in edit mode
    if (!isEditMode.value) {
      initializeChallan();
    } else {
      // For edit mode, just add one item if none exist
      if (challanItems.isEmpty) {
        addNewItem();
      }
    }

    // ✅ Validate dates for demo mode
    _validateDatesForDemoMode();

    // ✅ Load other data in parallel (non-blocking for challan ID)
    Future.microtask(() {
      loadCompanyData();
      loadCustomers();
      fetchItems();
    });

  }



// ALTERNATIVE: Fix your _handleArguments to handle both cases
  /// FIXED: Enhanced arguments handling with better error handling
  void _handleArguments() {
    print("🔍 Starting _handleArguments...");

    final arguments = Get.arguments;
    print("📥 Raw arguments: $arguments");
    print("📊 Arguments type: ${arguments.runtimeType}");

    // Handle the case where arguments is directly a Challan object
    if (arguments is Challan) {
      print("🏷️ Arguments is directly a Challan object - treating as edit mode");

      isEditMode.value = true;
      editingChallanId.value = arguments.challanId ?? '';

      print("📝 Set isEditMode.value = true (from direct Challan)");
      print("🆔 Set editingChallanId.value = '${editingChallanId.value}'");

      try {
        originalChallanData.value = _challanToMap(arguments);
        print("✅ Successfully converted direct Challan to Map");

        _prefillChallanData();
        print("✅ Successfully called _prefillChallanData()");
      } catch (e, stackTrace) {
        print("❌ Error processing direct Challan: $e");
        print("📄 Stack trace: $stackTrace");
      }
    }
    // Handle normal Map arguments
    else if (arguments != null && arguments is Map) {
      print("✅ Arguments is a valid Map");
      print("🗝️ Arguments keys: ${arguments.keys.toList()}");

      final editModeValue = arguments['editMode'];
      print("🔧 Edit mode value: $editModeValue");

      if (arguments['editMode'] == true) {
        print("✅ Entering edit mode");

        isEditMode.value = true;
        print("📝 Set isEditMode.value = true");

        editingChallanId.value = arguments['challanId']?.toString() ?? '';
        print("🆔 Set editingChallanId.value = '${editingChallanId.value}'");

        if (arguments['challanData'] != null) {
          print("✅ Challan data is not null, processing...");

          if (arguments['challanData'] is Challan) {
            print("🏷️ Challan data is Challan object");
            final challanObj = arguments['challanData'] as Challan;

            try {
              originalChallanData.value = _challanToMap(challanObj);
              print("✅ Successfully converted Challan to Map");

              _prefillChallanData();
              print("✅ Successfully called _prefillChallanData()");
            } catch (e, stackTrace) {
              print("❌ Error converting Challan to Map: $e");
              print("📄 Stack trace: $stackTrace");
            }
          }
          else if (arguments['challanData'] is Map) {
            print("🗺️ Challan data is Map object");

            try {
              originalChallanData.value = Map<String, dynamic>.from(arguments['challanData'] as Map);
              print("✅ Successfully processed Map data");

              _prefillChallanData();
              print("✅ Successfully called _prefillChallanData()");
            } catch (e, stackTrace) {
              print("❌ Error processing Map data: $e");
              print("📄 Stack trace: $stackTrace");
            }
          }
        }
      }
    } else {
      print("❌ Arguments is null or unrecognized type");
    }

    print("🏁 Finished _handleArguments");
    print("📊 Final state:");
    print("   - isEditMode.value: ${isEditMode.value}");
    print("   - editingChallanId.value: '${editingChallanId.value}'");
  }



  /// Convert Challan object to Map for editing
  Map<String, dynamic> _challanToMap(Challan challan) {
    return {
      'challanId': challan.challanId,
      'customerId': challan.customerId, // CRITICAL: Include customer ID
      'customerName': challan.customerName,
      'customerEmail': challan.customerEmail,
      'customerMobile': challan.customerMobile,
      'customerAddress': challan.customerAddress,
      'challanDate': challan.challanDate,
      'subtotal': challan.subtotal,
      'gstAmount': challan.gstAmount,
      'totalAmount': challan.totalAmount,
      'paymentStatus': challan.paymentStatus,
      'status': challan.status,
      'notes': challan.notes,
    };
  }

  /// Pre-fill form fields with existing challan data

  /// FIXED: Enhanced prefill with better customer ID handling
  void _prefillChallanData() {
    print("🔄 Starting _prefillChallanData...");

    final challanData = originalChallanData.value;
    if (challanData != null) {
      print("📋 Prefilling with data: $challanData");

      // Pre-fill basic challan info
      challanNumberController.text = challanData['challanId']?.toString() ?? '';
      print("🆔 Set challan number to: ${challanNumberController.text}");

      // Pre-fill date
      if (challanData['challanDate'] != null) {
        if (challanData['challanDate'] is DateTime) {
          challanDateController.text = _formatDate(challanData['challanDate'] as DateTime);
          challanDate.value = challanData['challanDate'] as DateTime;
        }
        else if (challanData['challanDate'] is String) {
          challanDateController.text = challanData['challanDate'] as String;
          try {
            challanDate.value = DateTime.parse(challanData['challanDate'] as String);
          } catch (e) {
            print('Could not parse date string: ${challanData['challanDate']}');
          }
        }
      }

      // Pre-fill customer info
      customerNameController.text = challanData['customerName']?.toString() ?? '';
      customerMobileController.text = challanData['customerMobile']?.toString() ?? '';
      customerEmailController.text = challanData['customerEmail']?.toString() ?? '';
      customerPanController.text = challanData['customerPan']?.toString() ?? '';
      customerGstController.text = challanData['customerGst']?.toString() ?? '';
      customerAddressController.text = challanData['customerAddress']?.toString() ?? '';

      // CRITICAL: Restore customer ID
      if (challanData['customerId'] != null && challanData['customerId'].toString().isNotEmpty) {
        selectedCustomerId.value = challanData['customerId'].toString();
        print("🆔 Restored customer ID: ${selectedCustomerId.value}");
      }

      // Pre-fill payment status and other fields
      paymentStatus.value = challanData['paymentStatus']?.toString() ?? 'Pending';
      notesController.text = challanData['notes']?.toString() ?? '';

      // Set financial values
      if (challanData['subtotal'] != null) {
        subtotal.value = double.tryParse(challanData['subtotal'].toString()) ?? 0.0;
      }
      if (challanData['gstAmount'] != null) {
        gstAmount.value = double.tryParse(challanData['gstAmount'].toString()) ?? 0.0;
      }
      if (challanData['totalAmount'] != null) {
        totalAmount.value = double.tryParse(challanData['totalAmount'].toString()) ?? 0.0;
      }

      // Load existing items for this challan
      _loadExistingChallanItems();
    }
  }

  /// FIXED: Enhanced loading of existing items with better error handling
  void _loadExistingChallanItems() async {
    if (editingChallanId.value.isEmpty) {
      print("⚠️ No editing challan ID, skipping item load");
      return;
    }

    try {
      isLoading.value = true;
      print("📦 Loading existing items for challan: ${editingChallanId.value}");

      final existingItems = await GoogleSheetService.getChallanItemsByChallanId(editingChallanId.value);

      originalItemsCount.value = existingItems.length;
      print("📊 Found ${existingItems.length} existing items");

      // Clear existing items and add the loaded ones
      challanItems.clear();
      for (var item in existingItems) {
        print("📦 Loading item: ${item.itemName}");
        print("   - Price: ${item.price}");
        print("   - Quantity: ${item.quantity}");
        print("   - GST Rate: ${item.gstRate}");

        challanItems.add(ChallanItem(
          customerId: item.customerId ?? '',
          itemId: item.itemId ?? '',
          challanId: editingChallanId.value,
          itemName: item.itemName ?? '',
          description: item.description ?? '',
          quantity: item.quantity ?? 1.0,
          price: item.price ?? 0.0,
          unit: item.unit ?? 'pcs',
          totalPrice: item.totalPrice ?? 0.0,
          gstRate: item.gstRate ?? 0.0,
          gstAmount: item.gstAmount ?? 0.0,
          amountWithGst: item.amountWithGst ?? 0.0,
        ));

        print("✅ Loaded item with GST rate: ${challanItems.last.gstRate}");
      }

      // Recalculate totals after loading all items
      calculateTotals();

      print('✅ Loaded ${existingItems.length} existing items for editing');
      print('💰 Recalculated totals - GST Amount: ${gstAmount.value}');

    } catch (e) {
      print('❌ Error loading existing items: $e');
      Get.snackbar('Error', 'Failed to load existing items');
    } finally {
      isLoading.value = false;
    }
  }



// Also check your GoogleSheetService.getChallanItemsByChallanId method
// Make sure it's returning the gstRate field from the database

// Add this debug method to check what data is being loaded
  void debugLoadedItems() {
    print("🔍 DEBUG: Current challan items after loading:");
    for (int i = 0; i < challanItems.length; i++) {
      final item = challanItems[i];
      print("Item $i:");
      print("  Name: ${item.itemName}");
      print("  Price: ${item.price}");
      print("  Quantity: ${item.quantity}");
      print("  GST Rate: ${item.gstRate}");
      print("  GST Amount: ${item.gstAmount}");
      print("  Total Price: ${item.totalPrice}");
      print("  Amount with GST: ${item.amountWithGst}");
      print("---");
    }
  }

  /// Format original challan date for display
  String formatOriginalChallanDate() {
    final challanData = originalChallanData.value;
    if (challanData?['challanDate'] != null) {
      if (challanData!['challanDate'] is DateTime) {
        return _formatDate(challanData['challanDate'] as DateTime);
      } else if (challanData['challanDate'] is String) {
        return challanData['challanDate'] as String;
      }
    }
    return 'N/A';
  }


  @override
  void onClose() {
    // Cleanup controllers
    for (var controller in priceControllers) {
      controller.dispose();
    }
    priceControllers.clear();

    for (var controller in quantityControllers) {
      controller.dispose();
    }
    quantityControllers.clear();

    customerNameController.dispose();
    customerMobileController.dispose();
    customerEmailController.dispose();
    customerAddressController.dispose();
    challanNumberController.dispose();
    challanDateController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// ✅ Keep quantityControllers in sync with challanItems
  TextEditingController getQuantityController(int index, {double? initialValue}) {
    // Ensure we have enough controllers
    while (quantityControllers.length < challanItems.length) {
      final itemIndex = quantityControllers.length;
      final item = challanItems[itemIndex];

      // ✅ Start with empty string instead of default "1"
      String quantityText = "";

      quantityControllers.add(
        TextEditingController(text: quantityText),
      );

      print("✅ Created quantity controller for index $itemIndex with empty value");
    }

    // Remove excess controllers (when items are deleted)
    while (quantityControllers.length > challanItems.length) {
      final removedController = quantityControllers.removeLast();
      removedController.dispose();
      print("🗑️ Disposed excess quantity controller");
    }

    // Validate index
    if (index >= quantityControllers.length) {
      print("⚠️ Warning: Index $index is out of bounds for quantityControllers");
      return TextEditingController();
    }

    // ✅ Only update if initialValue is explicitly provided AND controller is empty
    if (initialValue != null && quantityControllers[index].text.isEmpty) {
      String newText = initialValue % 1 == 0
          ? initialValue.toInt().toString()
          : initialValue.toString();

      quantityControllers[index].text = newText;
      print("📝 Set initial quantity at index $index to: $newText");
    }

    return quantityControllers[index];
  }

  Future<void> loadChallans() async {
    try {
      isLoading.value = true;
      print("=== ATTEMPTING TO FETCH CHALLANS ===");

      // Add more detailed error handling
      List<Challan> challans = await GoogleSheetService.getChallans();

      print("Final result: ${challans.length} challans found");

      // Debug: Print each found challan
      for (var challan in challans) {
        print("Found challan: ${challan.challanId} - ${challan.customerName}");
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
          message: "Found ${challans.length} challans",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );
      }

    } catch (e, stackTrace) {
      print("Error in loadChallans(): $e");
      print("Stack trace: $stackTrace");

      // More specific error handling
      String errorMessage = "Failed to load challans";
      if (e is FormatException) {
        errorMessage = "Data format error: ${e.message}";
        print("FormatException details: ${e.source}");
      }

      showCustomSnackbar(
        title: "Error",
        message: errorMessage,
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
    } finally {
      isLoading.value = false;
    }
  }


  // Modified initializeChallan to be called only for new challans
  void initializeChallan() async {
    print("🆕 INITIALIZING NEW CHALLAN - Starting...");

    // Only generate new ID if not in edit mode
    if (isEditMode.value) {
      print("⚠️ In edit mode, skipping new challan initialization");
      return;
    }

    try {
      final lastChallan = await getLastChallan();
      String newId = generateChallanIdFromLast(lastChallan);

      challanNumberController.text = newId;
      challanDateController.text = _formatDate(challanDate.value);

      // Add initial empty item for new challans
      if (challanItems.isEmpty) {
        addNewItem();
      }

      print("✅ NEW CHALLAN INITIALIZATION COMPLETE - ID: $newId");
    } catch (e) {
      print("⚠️ Error initializing challan: $e");
      // Fallback to default ID if sheet doesn't exist yet
      challanNumberController.text = "CH001";
      challanDateController.text = _formatDate(challanDate.value);

      if (challanItems.isEmpty) {
        addNewItem();
      }
    }
  }

  Future<Challan?> getLastChallan() async {
    try {
      List<Challan> challans = await GoogleSheetService.getChallansList();

      if (challans.isEmpty) {
        print("ℹ️ No previous challans found, starting with CH001");
        return null;
      }

      challans.sort((a, b) => (a.challanId ?? '').compareTo(b.challanId ?? ''));
      print("----lastttt: ${challans.last.challanId}");
      return challans.last;

    } catch (e) {
      print("⚠️ Error fetching last challan: $e");
      return null; // Return null to trigger CH001
    }
  }

  String generateChallanIdFromLast(Challan? lastChallan) {
    if (lastChallan == null ||
        lastChallan.challanId == null ||
        lastChallan.challanId!.isEmpty) {
      print("✅ Generating first challan ID: CH001");
      return "CH001";
    }

    RegExp regex = RegExp(r'^CH(\d+)$', caseSensitive: false);
    final match = regex.firstMatch(lastChallan.challanId!);

    if (match == null) {
      print("⚠️ Invalid challan ID format, defaulting to CH001");
      return "CH001";
    }

    int number = int.tryParse(match.group(1) ?? "0") ?? 0;
    String newId = "CH${(number + 1).toString().padLeft(3, '0')}";

    print("✅ Generated new challan ID: $newId");
    return newId;
  }

  String generateChallanId() {
    print("🔍 ANALYZING EXISTING CHALLANS FOR ID GENERATION:");

    if (challanList.isEmpty) {
      print("No existing challans found, starting with CH001");
      return "CH001";
    }

    List<int> existingNumbers = [];

    for (var challan in challanList) {
      if (challan.challanId != null) {
        String id = challan.challanId!.toUpperCase(); // Handle case variations
        print("Checking challan ID: $id");

        // Match CH followed by digits (case insensitive)
        RegExp regex = RegExp(r'^CH(\d+)$', caseSensitive: false);
        Match? match = regex.firstMatch(id);

        if (match != null) {
          try {
            String numericPart = match.group(1)!;
            int number = int.parse(numericPart);
            existingNumbers.add(number);
            print("  → Extracted number: $number");
          } catch (e) {
            print("  → Failed to parse numeric part: ${match.group(1)}");
          }
        } else {
          print("  → Does not match CH### pattern");
        }
      }
    }

    if (existingNumbers.isEmpty) {
      print("No valid CH-prefixed challans found, starting with CH001");
      return "CH001";
    }

    int maxNumber = existingNumbers.reduce((max, current) => current > max ? current : max);
    String newId = "CH${(maxNumber + 1).toString().padLeft(3, '0')}";

    print("📊 Max existing number: $maxNumber");
    print("🎯 Generated new ID: $newId");

    return newId;
  }

  /// 🟢 Always keep priceControllers in sync with challanItems
  TextEditingController getPriceController(int index, {double? initialValue}) {
    while (priceControllers.length < challanItems.length) {
      final itemIndex = priceControllers.length;
      final item = challanItems[itemIndex];
      priceControllers.add(
        TextEditingController(text: item.price.toStringAsFixed(2)), // ✅ int only
      );
    }

    while (priceControllers.length > challanItems.length) {
      priceControllers.removeLast().dispose();
    }

    if (initialValue != null &&
        priceControllers[index].text != initialValue.toInt().toString()) {
      priceControllers[index].text = initialValue.toInt().toString();
    }

    return priceControllers[index];
  }



  // Add any other missing methods from your original implementation
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
        print("Company data loaded");
      }
    } catch (e) {
      print("Error loading company data: $e");
    }
  }


// Replace your existing loadCustomers() method with this updated version:

  /// ✅ FIXED: Load customers from Google Sheets instead of Firebase
  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        print("⚠️ No authenticated user found");
        return;
      }

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      print("📦 Loading customers for Company ID: $companyId");

      if (companyId.isEmpty) {
        print("⚠️ No company ID found");
        Get.snackbar(
          'Company Required',
          'Please select a company first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final allCustomers = await GoogleSheetService.getCustomers(
        companyId: companyId,
        userId: user.uid,
      );

      print("📊 Total customers fetched: ${allCustomers.length}");

      customers.clear();
      int debtorCount = 0;

      for (var customer in allCustomers) {
        bool isActive = customer['isActive']?.toString().toLowerCase() == 'true';
        bool isDebtor = customer['sundryType']?.toString().toLowerCase() == 'debtors';

        if (isActive && isDebtor) {
          customers.add(customer);
          debtorCount++;
          print("✅ Added debtor customer: ${customer['name']} (ID: ${customer['customerId']})");
        } else if (isActive && !isDebtor) {
          print("⏭️ Skipped non-debtor customer: ${customer['name']} (Type: ${customer['sundryType']})");
        } else {
          print("⏭️ Skipped inactive customer: ${customer['name']}");
        }
      }

      customerCount.value = customers.length;
      print("📈 Active debtor customers loaded: $debtorCount");

      if (customers.isEmpty) {
        print("⚠️ No active debtor customers found");
        Get.snackbar(
          'No Debtor Customers',
          'No active debtor customers found. Please add debtor customers first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

    } catch (e, stackTrace) {
      print("❌ Error loading customers: $e");
      print("📄 Stack trace: $stackTrace");

      Get.snackbar(
        'Error',
        'Failed to load customers: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true;
      final userId = AppConstants.userId;

      print("=== ATTEMPTING TO FETCH ITEMS FOR USER: $userId ===");

      // Try to get items
      List<Item> items = await GoogleSheetService.getItems(userId: userId);

      /// If no items found, try alternative methods
      // if (items.isEmpty) {
      //   print("Standard method failed, trying alternative...");
      //   items = await RemoteService.getItemsAlternative(userId);
      // }

      print("Final result: ${items.length} items found");

      // Debug: Print each found item
      for (var item in items) {
        print("Found item: ${item.itemName} (ID: ${item.itemId}) for user: ${item.userId}");
      }

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

    } catch (e) {
      print("Error in fetchItems(): $e");
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

// Add this helper method to check customer status during selection
  void selectCustomer(Map<String, dynamic>? customer) {
    if (customer == null) {
      selectedCustomer.value = null;
      clearCustomerSelection();
      showCustomerForm.value = false;
      return;
    }

    // Double-check if customer is still active
    bool isActive = customer['isActive']?.toString().toLowerCase() == 'true';
    if (!isActive) {
      Get.snackbar(
        'Customer Inactive',
        'This customer is currently inactive. Please select an active customer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    selectedCustomer.value = customer;

    // ✅ Map Google Sheets fields to form controllers
    customerNameController.text = customer['name'] ?? '';
    customerMobileController.text = customer['mobile1'] ?? '';
    customerEmailController.text = customer['email'] ?? '';
    customerPanController.text = customer['pan'] ?? '';
    customerGstController.text = customer['gst'] ?? '';
    customerAddressController.text = customer['address'] ?? '';

    // ✅ Use 'customerId' field from Google Sheets
    selectedCustomerId.value = customer['customerId'] ?? '';

    showCustomerForm.value = false;

    print("✅ Selected Active Customer:");
    print("   ID: ${selectedCustomerId.value}");
    print("   Name: ${customerNameController.text}");
    print("   Mobile: ${customerMobileController.text}");
  }

  void toggleCustomerForm() {
    showCustomerForm.value = !showCustomerForm.value;
    if (showCustomerForm.value) {
      selectedCustomer.value = null;
      clearCustomerSelection();
    }
  }

  void clearCustomerSelection() {
    selectedCustomer.value = null;
    customerNameController.clear();
    customerMobileController.clear();
    customerEmailController.clear();
    customerPanController.clear();
    customerGstController.clear();
    customerAddressController.clear();
  }

  /// Fixed addNewItem method
  void addNewItem() {
    print("Adding new item in ${isEditMode.value ? 'EDIT' : 'CREATE'} mode");

    String customerId = _getValidCustomerId();

    // ✅ FIXED: Only show error in EDIT mode
    if (customerId.isEmpty && isEditMode.value) {
      print("WARNING: Customer ID is empty in edit mode!");
      Get.snackbar(
        'Error',
        'Unable to determine customer ID. Please reload the challan.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // ✅ In CREATE mode, allow empty customer ID (will be populated when customer is selected)
    if (customerId.isEmpty && !isEditMode.value) {
      print("INFO: Creating item without customer ID (will be set when customer is selected)");
    }

    challanItems.add(ChallanItem(
      description: '',
      quantity: 1.0,
      price: 0.0,
      gstRate: 0.0,
      itemId: '',
      totalPrice: 0.0,
      itemName: '',
      customerId: customerId,
      unit: '',
    ));

    print("Added new item with customer ID: '$customerId'");
    print("Total items: ${challanItems.length}");

    calculateTotals();
  }

  void updateItem(int index, {String? description, double? quantity, double? price, String? itemId, String? unit,}) {
    if (index < challanItems.length) {
      final item = challanItems[index];
      challanItems[index] = ChallanItem(
        customerId: item.customerId,
        description: description ?? item.description,
        quantity: quantity ?? item.quantity,
        price: price ?? item.price,
        gstRate: item.gstRate,
        itemId: itemId ?? item.itemId,
        itemName: description ?? item.itemName,
        totalPrice: item.totalPrice,
        unit: unit ?? item.unit,
      );
      calculateTotals();
    }
  }

  void selectRemoteItemForIndex(int index, Item item) {
    if (index >= challanItems.length) return;

    // Check if this item already exists in challanItems (excluding current index)
    int existingIndex = -1;
    for (int i = 0; i < challanItems.length; i++) {
      if (i != index && challanItems[i].itemId == item.itemId && challanItems[i].itemId.isNotEmpty) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      // Item already exists - merge quantities
      final existingItem = challanItems[existingIndex];
      final currentQty = challanItems[index].quantity;

      // Update the existing item with increased quantity
      challanItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + currentQty,
      );

      // Remove the duplicate row
      removeItem(index);

      // Show feedback to user
      Get.snackbar(
        "Item Merged",
        "Quantity added to existing ${item.itemName}. Total: ${existingItem.quantity + currentQty}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.tealColor.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
      );

      // Recalculate totals after merging
      calculateTotals();

      return;
    }

    // No duplicate found - proceed with normal item selection
    final currentItem = challanItems[index];
    String customerId = _getValidCustomerId();

    // Validate customer ID only in edit mode
    if (customerId.isEmpty && isEditMode.value) {
      print("ERROR: Cannot select item in edit mode - no valid customer ID found");
      Get.snackbar(
        'Error',
        'Customer ID missing. Please reload the challan.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Determine GST rate to use
    double gstRateToUse;
    if (isEditMode.value && currentItem.itemId.isNotEmpty) {
      gstRateToUse = currentItem.gstRate;
      print("Edit mode: Preserving existing GST rate: $gstRateToUse for existing item");
    } else {
      gstRateToUse = item.gstPercent.toDouble();
      print("Using item master GST rate: $gstRateToUse for new/empty item");
    }

    // Update the item at the current index
    challanItems[index] = ChallanItem(
      customerId: customerId,
      description: item.itemName,
      quantity: currentItem.quantity,
      price: item.price.toDouble(),
      gstRate: gstRateToUse,
      itemId: item.itemId,
      itemName: item.itemName,
      totalPrice: currentItem.quantity * item.price.toDouble(),
      unit: item.unitOfMeasurement,
    );

    print("Updated item $index with customer ID: '${challanItems[index].customerId}'");
    calculateTotals();
  }


// Helper method to manually update GST rate if needed
  void updateItemGstRate(int index, double newGstRate) {
    if (index < challanItems.length) {
      final currentItem = challanItems[index];
      challanItems[index] = currentItem.copyWith(gstRate: newGstRate);
      calculateTotals();
      print("Updated GST rate for item $index to $newGstRate");
    }
  }

  void removeItem(int index) {
    if (challanItems.length > 1) {
      challanItems.removeAt(index);

      // ✅ Remove corresponding controllers
      if (index < priceControllers.length) {
        priceControllers[index].dispose();
        priceControllers.removeAt(index);
      }

      if (index < quantityControllers.length) {
        quantityControllers[index].dispose();
        quantityControllers.removeAt(index);
      }

      // Clear violations for this item
      itemsWithStockViolation.remove(index);
      violationMessages.remove(index);

      // Rebuild violation indices (shift them down)
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

      calculateTotals();
    }
  }

  void updatePaymentStatus(String status) {
    paymentStatus.value = status;
  }

  Future<void> selectChallanDate() async {
    // ✅ Enhanced demo mode date handling
    final DateTime firstDate = AppConstants.isDemo.value
        ? DateTime(1990, 1, 1)
        : DateTime(2000);
    final DateTime lastDate = AppConstants.isDemo.value
        ? DateTime(1992, 12, 31)
        : DateTime.now();

    // ✅ Ensure initial date is within demo range
    DateTime initialDate = challanDate.value;
    if (AppConstants.isDemo.value) {
      if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (initialDate.isAfter(lastDate)) {
        initialDate = lastDate;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: AppConstants.isDemo.value
          ? 'Select Date (Demo: 1990-1992 only)'
          : 'Select Challan Date',
      fieldLabelText: AppConstants.isDemo.value
          ? 'Enter date between 1990-1992'
          : 'Enter challan date',
      fieldHintText: AppConstants.isDemo.value
          ? 'DD/MM/1990-1992'
          : 'DD/MM/YYYY',
    );

    if (picked != null && picked != challanDate.value) {
      challanDate.value = picked;
      challanDateController.text = _formatDate(picked);

      // ✅ Show demo mode info when date is selected
      if (AppConstants.isDemo.value) {
        Get.snackbar(
          'Demo Mode Active',
          'Date limited to 1990-1992 range',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: Duration(seconds: 2),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Validate and adjust dates for demo mode
  void _validateDatesForDemoMode() {
    if (!AppConstants.isDemo.value) return;

    final DateTime demoFirstDate = DateTime(1990, 1, 1);
    final DateTime demoLastDate = DateTime(1992, 12, 31);

    // Validate challan date
    if (challanDate.value.isBefore(demoFirstDate) ||
        challanDate.value.isAfter(demoLastDate)) {
      print("⚠️ Adjusting challan date for demo mode");
      challanDate.value = demoFirstDate;
      challanDateController.text = _formatDate(demoFirstDate);
    }

    // Validate original challan date in edit mode
    if (isEditMode.value && originalChallanData.value != null) {
      final originalDate = originalChallanData.value!['challanDate'];
      if (originalDate is DateTime) {
        if (originalDate.isBefore(demoFirstDate) || originalDate.isAfter(demoLastDate)) {
          print("⚠️ Original challan date outside demo range");
        }
      }
    }
  }

  /// Add a method to check if we're in edit mode
  bool get isInEditMode => isEditMode.value && editingChallanId.value.isNotEmpty;

  /// ENHANCED: Get valid customer ID with multiple fallback sources
  String _getValidCustomerId() {
    String customerId = '';

    // Try multiple sources in order of preference
    if (selectedCustomerId.value.isNotEmpty) {
      customerId = selectedCustomerId.value;
      print("Using selectedCustomerId: $customerId");
    }
    else if (isEditMode.value && originalChallanData.value?['customerId'] != null) {
      customerId = originalChallanData.value!['customerId'].toString();
      // Update selectedCustomerId for consistency
      selectedCustomerId.value = customerId;
      print("Using originalChallanData customerId: $customerId");
    }
    else if (challanItems.isNotEmpty && challanItems.first.customerId.isNotEmpty) {
      customerId = challanItems.first.customerId;
      selectedCustomerId.value = customerId;
      print("Using existing item's customerId: $customerId");
    }

    // ✅ NEW: Handle manual customer entry
    else if (customerNameController.text.trim().isNotEmpty) {
      // Generate a temporary ID based on customer name + timestamp
      customerId = 'MANUAL_${customerNameController.text.trim().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      selectedCustomerId.value = customerId;
      print("Generated manual entry customer ID: $customerId");
    }

    print("Final customer ID: '$customerId'");
    return customerId;
  }

  // Add this method to your controller
  void validateManualCustomerEntry() {
    if (showCustomerForm.value &&
        customerNameController.text.trim().isNotEmpty &&
        selectedCustomerId.value.isEmpty) {
      // Generate customer ID for manual entry
      selectedCustomerId.value = 'MANUAL_${DateTime.now().millisecondsSinceEpoch}';
      print("Auto-generated customer ID for manual entry: ${selectedCustomerId.value}");
    }
  }

  /// Debug methods for troubleshooting
  void debugChallanItemsBeforeSaving() {
    print("=== DEBUGGING CHALLAN ITEMS BEFORE SAVING ===");
    print("Selected Customer ID: ${selectedCustomerId.value}");
    print("Challan Date: ${challanDate.value}");

    for (int i = 0; i < challanItems.length; i++) {
      final item = challanItems[i];
      print("Item $i:");
      print("  customerId: '${selectedCustomerId.value}'");
      print("  itemId: '${item.itemId}'");
      print("  itemName: '${item.itemName}'");
      print("  quantity: ${item.quantity}");
      print("  price: ${item.price}");
      print("  gstRate: ${item.gstRate}");
      print("  totalPrice: ${item.totalPrice}");
      print("  ---");
    }
    print("=== END DEBUG ===");
  }

  void debugAllItemsCustomerId() {
    print("=== DEBUGGING ALL ITEMS CUSTOMER ID ===");
    print("selectedCustomerId.value: '${selectedCustomerId.value}'");
    print("originalChallanData customerId: '${originalChallanData.value?['customerId']}'");

    for (int i = 0; i < challanItems.length; i++) {
      final item = challanItems[i];
      print("Item $i: customerId='${item.customerId}', itemName='${item.itemName}'");

      // Fix any items with empty customer ID
      if (item.customerId.isEmpty) {
        String correctCustomerId = _getValidCustomerId();
        if (correctCustomerId.isNotEmpty) {
          challanItems[i] = item.copyWith(customerId: correctCustomerId);
          print("  FIXED: Set customer ID to '$correctCustomerId'");
        }
      }
    }
    print("=== END DEBUG ===");
  }



// Fixed challan item data creation
// Modified createChallanItemData to double-check customer ID
  Map<String, dynamic> createChallanItemData(ChallanItem item) {
    // CRITICAL: Ensure customer ID is never empty
    String customerId = item.customerId;
    if (customerId.isEmpty) {
      customerId = _getValidCustomerId();
      print("WARNING: Item had empty customer ID, using: '$customerId'");
    }

    // Format date properly for Google Sheets
    String formattedDate = _formatDate(challanDate.value);

    Map<String, dynamic> itemData = {
      'challanId': challanNumberController.text,
      'customerId': customerId,
      'itemId': item.itemId ?? '',
      'itemName': item.itemName ?? '',
      'description': item.description ?? '',
      'quantity': item.quantity.toString(),
      'price': item.price.toString(),
      'challanDate': formattedDate,
      'gstRate': item.gstRate.toString(),
      'gstAmount': item.gstAmount.toString(),
      'amountWithGst': item.amountWithGst.toString(),
      'totalPrice': item.totalPrice.toString(),
      'unit': item.unit ?? 'pcs',
      'userId': AppConstants.userId,
    };

    print("Created item data with customer ID: '${itemData['customerId']}'");
    return itemData;
  }

  void _removeEmptyItemsBeforeSave() {
    challanItems.removeWhere((item) {
      bool isEmpty = (item.itemId?.isEmpty ?? true) &&
          (item.description?.isEmpty ?? true) &&
          (item.itemName?.isEmpty ?? true);

      // Keep items that have been filled or have quantity/rate changes
      return isEmpty && item.quantity == 1 && item.price == 0.0;
    });

    // Ensure at least one item remains
    if (challanItems.isEmpty) {
      addNewItem();
    }
  }


  /// Validates that at least one valid item exists before saving
  bool _validateChallanItems() {
    // Check if there are any items at all
    if (challanItems.isEmpty) {
      showCustomSnackbar(
        title: "Validation Error",
        message: "Please add at least one item to the challan",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
      return false;
    }

    // Check if there's at least one valid item (has itemId or description)
    bool hasValidItem = challanItems.any((item) {
      bool hasItemId = item.itemId != null && item.itemId!.isNotEmpty;
      bool hasDescription = item.description != null && item.description!.isNotEmpty;
      bool hasItemName = item.itemName != null && item.itemName!.isNotEmpty;

      return hasItemId || hasDescription || hasItemName;
    });

    if (!hasValidItem) {
      showCustomSnackbar(
        title: "No Items Selected",
        message: "Please select or add at least one item before creating the challan",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }

    // Additional validation: check for items with zero quantity or price
    bool hasInvalidQuantityOrPrice = challanItems.any((item) {
      bool isValidItem = (item.itemId?.isNotEmpty ?? false) ||
          (item.description?.isNotEmpty ?? false) ||
          (item.itemName?.isNotEmpty ?? false);

      if (isValidItem) {
        return item.quantity <= 0 || item.price <= 0;
      }
      return false;
    });

    if (hasInvalidQuantityOrPrice) {
      showCustomSnackbar(
        title: "Invalid Item Data",
        message: "All selected items must have quantity and price greater than 0",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }

    return true;
  }

  Future<bool> saveChallan({required bool isDraft}) async {
    try {

      // ✅ Handle manual customer entry
      if (showCustomerForm.value && customerNameController.text.trim().isNotEmpty) {
        validateManualCustomerEntry();
      }

      // ✅ FIRST: Validate customer is selected/entered
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

      if (!_validateChallanItems()) {
        return false;
      }

      // ✅ NEW: Check for stock violations FIRST
      if (hasAnyStockViolation) {
        String violationList = violationMessages.values.join('\n• ');

        showCustomSnackbar(
          title: "Cannot Create Challan",
          message: "Fix these issues first:\n• $violationList",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
          duration: Duration(seconds: 5),
        );
        return false;
      }

      _removeEmptyItemsBeforeSave();

      // Double-check after removing empty items
      if (challanItems.isEmpty) {
        showCustomSnackbar(
          title: "No Valid Items",
          message: "Please add at least one valid item to the challan",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
        return false;
      }
      isLoading.value = true;

      debugAllItemsCustomerId();
      calculateTotals();

      String finalCustomerId = _getValidCustomerId();

      // ✅ Final customer ID check
      if (finalCustomerId.isEmpty) {
        isLoading.value = false;
        showCustomSnackbar(
          title: "Customer ID Error",
          message: "Unable to determine customer ID. Please try again.",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
        return false;
      }

      final challanId = challanNumberController.text;

      Map<String, dynamic> challanData = {
        'challanId': challanId,
        'challanDate': _formatDate(challanDate.value),
        'customerId': finalCustomerId,
        'customerName': customerNameController.text.trim(),
        'customerMobile': customerMobileController.text.trim(),
        'customerEmail': customerEmailController.text.trim(),
        'customerPan': customerPanController.text.trim(),
        'customerGst': customerGstController.text.trim(),
        'customerAddress': customerAddressController.text.trim(),
        'subtotal': subtotal.value,
        'gstRate': challanItems.isNotEmpty ? challanItems.first.gstRate : 0.0,
        'gstAmount': gstAmount.value,
        'totalAmount': totalAmount.value,
        'paymentStatus': paymentStatus.value,
        'notes': notesController.text,
        'status': isDraft ? 'draft' : 'inProgress',
        'userId': AppConstants.userId,
      };

      if (isInEditMode) {
        print("=== UPDATING EXISTING CHALLAN ===");

        await GoogleSheetService.updateChallanWithCacheClear(
          challanData,
          AppConstants.userId,
        );

        List<Map<String, dynamic>> itemsData =
        challanItems.map((item) => createChallanItemData(item)).toList();

        await GoogleSheetService.updateChallanItemsWithCacheClear(
          challanId,
          itemsData,
          AppConstants.userId,
        );
        isLoading.value = false;

        await _refreshParentControllersAsync();

        // ✅ Generate challan PDF (same as 1st code)
        List<Challan> challanModel = challanItems.map((item) {
          return Challan(
            challanId: challanId,
            itemId: item.itemId,
            itemName: item.description,
            qty: item.quantity,
            price: item.price.toDouble(),
            gst: item.gstRate,
            customerMobile: customerMobileController.text.trim(),
            customerId: selectedCustomerId.value,
            customerName: customerNameController.text.trim(),
            customerEmail: customerEmailController.text.trim(),
            customerPan: customerPanController.text.trim(),
            customerGst: customerGstController.text.trim(),
            customerAddress: customerAddressController.text.trim(),
            subtotal: subtotal.value,
            totalAmount: totalAmount.value,
            gstAmount: gstAmount.value,
            notes: notesController.text,
            status: paymentStatus.value,
          );
        }).toList();

        if(!isInEditMode)
          await InvoiceHelper.generateAndShareChallan(
          challanModel,
          customerNameController.text.trim(),
          customerMobileController.text.trim(),
          customerEmailController.text.trim(),
          customerPanController.text.trim(),
          customerGstController.text.trim(),
          customerAddressController.text.trim(),
          subtotal.value,
          challanDateController.text,
          totalAmount.value,
          paymentStatus.value,
          notesController.text,
          companyData.value,
          gstAmount.value,
        );

        Get.back(result: true);
        await Future.delayed(const Duration(milliseconds: 100),() {
          showCustomSnackbar(
            title: "Success",
            message: "Challan updated successfully!",
            baseColor: Colors.green.shade700,
            icon: Icons.check_circle_outline,
          );
        },);

        return true;

      }
      else {
        print("=== CREATING NEW CHALLAN ===");

        await GoogleSheetService.addChallan(challanData, AppConstants.userId);

        /// ✅ Instead of looping, use batch add
        List<Map<String, dynamic>> itemsData =
        challanItems.map((item) => createChallanItemData(item)).toList();

        await GoogleSheetService.addChallanItemsBatch(
          itemsData,
          AppConstants.userId,
        );

        await GoogleSheetService.updateStockAfterDispatch(challanItems);

        // ✅ Generate challan PDF (same as 1st code)
        List<Challan> challanModel = challanItems.map((item) {
          return Challan(
            challanId: challanId,
            itemId: item.itemId,
            itemName: item.description,
            qty: item.quantity,
            price: item.price.toDouble(),
            gst: item.gstRate,
            customerMobile: customerMobileController.text.trim(),
            customerId: selectedCustomerId.value,
            customerName: customerNameController.text.trim(),
            customerEmail: customerEmailController.text.trim(),
            customerAddress: customerAddressController.text.trim(),
            subtotal: subtotal.value,
            totalAmount: totalAmount.value,
            gstAmount: gstAmount.value,
            notes: notesController.text,
            status: paymentStatus.value,
          );
        }).toList();

        await InvoiceHelper.generateAndShareChallan(
          challanModel,
          customerNameController.text.trim(),
          customerMobileController.text.trim(),
          customerEmailController.text.trim(),
          customerPanController.text.trim(),
          customerGstController.text.trim(),
          customerAddressController.text.trim(),
          subtotal.value,
          challanDateController.text,
          totalAmount.value,
          paymentStatus.value,
          notesController.text,
          companyData.value,
          gstAmount.value,
        );

        showCustomSnackbar(
          title: "Success",
          message: "Challan created successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );

        clearForm();
        Get.back(result: true);
        return true;
      }

    } catch (e) {
      print("❌ Error saving challan: $e");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to save challan: ${e.toString()}",
        baseColor: Colors.red.shade700,
        icon: Icons.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  /// FIXED: Async refresh with proper await
  Future<void> _refreshParentControllersAsync() async {
    try {
      print("=== REFRESHING PARENT CONTROLLERS (ASYNC) ===");

      // Refresh list controller
      if (Get.isRegistered<ChallanListController>()) {
        final listController = Get.find<ChallanListController>();
        print("Refreshing ChallanListController...");
        await listController.loadChallans();
        print("✅ List refreshed");
      }

      // Refresh details controller
      if (Get.isRegistered<ChallanDetailsController>()) {
        final detailsController = Get.find<ChallanDetailsController>();
        print("Refreshing ChallanDetailsController...");
        await detailsController.forceRefreshChallanData();
        print("✅ Details refreshed");
      }

      print("=== REFRESH COMPLETED ===");
    } catch (e) {
      print("❌ Error refreshing controllers: $e");
    }
  }


  ///with GSt
  void calculateTotals() {
    double sub = 0.0;
    double gst = 0.0;

    for (var i = 0; i < challanItems.length; i++) {
      final item = challanItems[i];
      final itemTotal = item.price * item.quantity;

      double gstForItem = 0.0;
      double withGst = itemTotal;

      if (AppConstants.withGST.value) {
        gstForItem = itemTotal * (item.gstRate / 100);
        withGst = itemTotal + gstForItem;
      }

      challanItems[i] = item.copyWith(
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

    print("Calculated totals: Subtotal=${sub}, GST=${gst}, Total=${totalAmount.value}");
  }



  void clearForm() {
    formKey.currentState?.reset();
    challanItems.clear();
    clearCustomerSelection();
    notesController.clear();
    paymentStatus.value = 'Pending';
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

    initializeChallan();
  }
}


