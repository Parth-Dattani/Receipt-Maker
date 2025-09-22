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

class NewChallanController extends BaseController {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final customerNameController = TextEditingController();
  final customerMobileController = TextEditingController();
  final customerEmailController = TextEditingController();
  final customerAddressController = TextEditingController();
  final challanNumberController = TextEditingController();
  final challanDateController = TextEditingController();
  final notesController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
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
  var taxRate = 0.0.obs;
  var taxAmount = 0.0.obs;
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

  @override
  void onInit() {
    super.onInit();
    // ✅ Generate challan ID first (only depends on challans)
    initializeChallan();

    // ✅ Load other data in parallel (non-blocking for challan ID)
    Future.microtask(() {
      loadCompanyData();
      loadCustomers();
      fetchItems();
    });

    //loadChallans();
    //initializeChallan();
    // loadCompanyData();
    // loadCustomers();
    // fetchItems();
  }

  @override
  void onClose() {
    customerNameController.dispose();
    customerMobileController.dispose();
    customerEmailController.dispose();
    customerAddressController.dispose();
    challanNumberController.dispose();
    challanDateController.dispose();
    notesController.dispose();
    super.onClose();
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


  void initializeChallan() async {
    print("🆕 INITIALIZING CHALLAN - Starting...");

    final lastChallan = await getLastChallan();
    String newId = generateChallanIdFromLast(lastChallan);
    /// Only load challans here (not other data)
    //await loadChallans();

    // String newChallanId = generateChallanId();
    // print("🆔 FINAL GENERATED CHALLAN ID: $newChallanId");

    challanNumberController.text = newId;
    challanDateController.text = _formatDate(challanDate.value);

    addNewItem();
    print("✅ CHALLAN INITIALIZATION COMPLETE");
  }

  /// 🟢 Always keep priceControllers in sync with challanItems
  TextEditingController getPriceController(int index, {double? initialValue}) {
    while (priceControllers.length < challanItems.length) {
      final itemIndex = priceControllers.length;
      final item = challanItems[itemIndex];
      priceControllers.add(
        TextEditingController(text: item.price.toInt().toString()), // ✅ int only
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



  String generateChallanIdFromLast(Challan? lastChallan) {
    if (lastChallan == null || lastChallan.challanId == null) return "CH001";

    RegExp regex = RegExp(r'^CH(\d+)$', caseSensitive: false);
    final match = regex.firstMatch(lastChallan.challanId!);
    if (match == null) return "CH001";

    int number = int.tryParse(match.group(1) ?? "0") ?? 0;
    return "CH${(number + 1).toString().padLeft(3, '0')}";
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

  Future<Challan?> getLastChallan() async {
    List<Challan> challans = await GoogleSheetService.getChallansList();
    if (challans.isEmpty) return null;

    challans.sort((a, b) => (a.challanId ?? '').compareTo(b.challanId ?? ''));
   print("----lastttt: ${challans.last}");
    return challans.last;
  }

  // Add this method to fetch company data
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

  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      print("Company ID: $companyId");

      final customersSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .collection("customers")
          .get();

      customers.clear();
      for (var doc in customersSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        customers.add(data);
      }

      // Also update customer count
      customerCount.value = customers.length;

      print("Customer---count----${customerCount.value}");
    } catch (e) {
      print("Error loading customers: $e");
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


  void selectCustomer(Map<String, dynamic>? customer) {
    if (customer == null) {
      selectedCustomer.value = null;
      clearCustomerSelection();
      showCustomerForm.value = false;
      return;
    }

    selectedCustomer.value = customer;
    customerNameController.text = customer['name'] ?? '';
    customerMobileController.text = customer['mobile'] ?? '';
    customerEmailController.text = customer['email'] ?? '';
    customerAddressController.text = customer['address'] ?? '';
    selectedCustomerId.value = customer['customerId'] ?? '';
    showCustomerForm.value = false;

    print("Selected CustomerID:---- ${selectedCustomerId.value} ----NAme: ${customerNameController.text}");
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
    customerAddressController.clear();
  }

  void addNewItem() {
    challanItems.add(ChallanItem(
      description: '',
      quantity: 1,
      price: 0.0,
      gst: 0.0,
      itemId: '',
      totalPrice: 0.0,
      itemName: '',
customerId: ''
    ));
    calculateTotals();
  }

  void updateItem(int index, {String? description, int? quantity, double? price, String? itemId}) {
    if (index < challanItems.length) {
      final item = challanItems[index];
      challanItems[index] = ChallanItem(
        customerId: item.customerId,
        description: description ?? item.description,
        quantity: quantity ?? item.quantity,
        price: price ?? item.price,
        gst: item.gst,
        itemId: itemId ?? item.itemId,
        itemName: description ?? item.itemName,
        totalPrice: item.totalPrice,
      );
      calculateTotals();
    }
  }

  void selectRemoteItemForIndex(int index, Item item) {
    if (index < challanItems.length) {
      challanItems[index] = ChallanItem(
        customerId: selectedCustomerId.value.toString(),
        description: item.itemName,
        quantity: challanItems[index].quantity,
        price: item.price.toDouble(),
        gst: item.gstPercent.toDouble(),
        itemId: item.itemId,
          itemName: item.itemName,
          totalPrice: item.price
      );
      calculateTotals();
    }
  }

  void removeItem(int index) {
    if (challanItems.length > 1) {
      challanItems.removeAt(index);
      calculateTotals();
    }
  }


  void updatePaymentStatus(String status) {
    paymentStatus.value = status;
  }

  Future<void> selectChallanDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: challanDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != challanDate.value) {
      challanDate.value = picked;
      challanDateController.text = _formatDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<bool> saveChallan({required bool isDraft}) async {
    try {
      if (!formKey.currentState!.validate()) {
        showCustomSnackbar(
          title: "Validation Error",
          message: "Please fill all required fields",
          baseColor: Colors.orange.shade700,
          icon: Icons.warning,
        );
        return false;
      }

      isLoading.value = true;

      // Calculate totals first
      calculateTotals();

      // 1. First save the main challan record (single record)
      Map<String, dynamic> challanData = {
        'challanId': challanNumberController.text,
        'challanDate': challanDate.value.toIso8601String(),
        'customerId': selectedCustomerId.value,
        'customerName': customerNameController.text.trim(),
        'customerMobile': customerMobileController.text.trim(),
        'customerEmail': customerEmailController.text.trim(),
        'customerAddress': customerAddressController.text.trim(),
        'subtotal': subtotal.value,
        'taxRate': taxRate.value,
        'taxAmount': taxAmount.value,
        'totalAmount': totalAmount.value,
        'paymentStatus': paymentStatus.value,
        'notes': notesController.text,
        'status': isDraft ? 'draft' : 'completed',
        'userId': AppConstants.userId,
      };

      print("Saving main challan record: ${jsonEncode(challanData)}");
      await GoogleSheetService.addChallan(challanData, AppConstants.userId);

      /// 2. Then save each challan item separately to InvoiceItems table
      for (var item in challanItems) {
        Map<String, dynamic> challanItemData = {
         // '_RowNumber': '',
          'challanId': challanNumberController.text, // Use challan ID as reference
          'customerId': selectedCustomerId.value.toString(),
          'itemId': item.itemId,
          'itemName': item.description,
          'description': item.description,
          'quantity': item.quantity.toString(),
          'price': item.price.toString(),
          'gst': item.gst.toString(),
          'totalPrice': (item.quantity * item.price).toString(),
        };

        print("Saving challan item to InvoiceItems: ${jsonEncode(challanItemData)}");

        await GoogleSheetService.addChallanItem(challanItemData, AppConstants.userId);
      }


      /// 3. Update stock in Google Sheets
      await GoogleSheetService.updateStockAfterDispatch(challanItems);

      List<Challan> challanModel = challanItems.map((item) {
        return Challan(
            challanId: challanNumberController.text,
            itemId: item.itemId,
            itemName: item.description,   // ✅ correctly mapped
            qty: item.quantity,
            price: item.price.toDouble(),  // ✅ correctly mapped
          gst: item.gst,
          customerMobile: customerMobileController.text.trim(),
          customerId: selectedCustomerId.value,
          customerName: customerNameController.text.trim(),
          customerEmail: customerEmailController.text.trim(),
          customerAddress: customerAddressController.text.trim(),
          subtotal: subtotal.value,
          taxRate: taxRate.value,
          taxAmount: taxAmount.value,
          notes: notesController.text,
          status: paymentStatus.value,
        );
      }).toList();



      //
      // Generate and share challan
      await InvoiceHelper.generateAndShareChallan(
        challanModel, // Pass items instead of challanModels
        customerNameController.text.trim(),
        customerMobileController.text.trim(),
        customerEmailController.text.trim(),
        customerAddressController.text.trim(),
        subtotal.value,
        taxAmount.value,
        totalAmount.value,
        taxRate.value,
        paymentStatus.value,
        notesController.text,
        companyData.value,
        gstAmount.value,
      );

      showCustomSnackbar(
        title: "Success",
        message: "Challan ${isDraft ? 'saved as draft' : 'created'} successfully!",
        baseColor: AppColors.darkGreenColor,
        icon: Icons.check_circle_outline,
      );


      Get.back();
      return true;

    } catch (e) {
      print("Error saving challan: $e");
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

  // void calculateTotals() {
  //   double sub = 0.0;
  //   double gst = 0.0;
  //
  //   for (var item in challanItems) {
  //     sub += item.quantity * item.price;
  //   }
  //   subtotal.value = sub;
  //
  //   double discountValue = 0.0;
  //   if (discountType.value == 'percentage') {
  //     discountValue = subtotal.value * (discountAmount.value / 100);
  //   } else {
  //     discountValue = discountAmount.value;
  //   }
  //
  //   double afterDiscount = subtotal.value - discountValue;
  //   taxAmount.value = afterDiscount * (taxRate.value / 100);
  //   totalAmount.value = afterDiscount + taxAmount.value;
  // }

  ///with GSt
  void calculateTotals() {
    double sub = 0.0;
    double gst = 0.0;

    for (var item in challanItems) {
      final itemTotal = item.price * item.quantity;
      sub += itemTotal;

      final gstForItem = itemTotal * (item.gst / 100);
      gst += gstForItem;
    }

    subtotal.value = sub;
    gstAmount.value = gst;
    totalAmount.value = sub + gst;
  }


  void clearForm() {
    formKey.currentState?.reset();
    challanItems.clear();
    clearCustomerSelection();
    notesController.clear();
    taxRate.value = 0.0;
    taxAmount.value = 0.0;
    paymentStatus.value = 'Pending';
    calculateTotals();

    initializeChallan();
  }
}


