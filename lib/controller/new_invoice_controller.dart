import 'dart:convert';

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


///29-09 morning 10:58
// class NewInvoiceController extends GetxController {
//   // Form controllers
//   final formKey = GlobalKey<FormState>();
//   final customerNameController = TextEditingController();
//   final customerMobileController = TextEditingController();
//   final customerEmailController = TextEditingController();
//   final customerAddressController = TextEditingController();
//   final invoiceNumberController = TextEditingController();
//   final dueDateController = TextEditingController();
//   final notesController = TextEditingController();
//   final RxString selectedCustomerId = ''.obs;
//
//   // Observable variables
//   var isLoading = false.obs;
//   // var selectedCustomer = Rxn<Map<String, dynamic>>();
//   var customers = <Map<String, dynamic>>[].obs;
//   var items = <Map<String, dynamic>>[].obs;
//   var itemList = <Item>[].obs;
//   var invoiceList = <Invoice>[].obs;
//   var invoiceItems = <InvoiceItem>[].obs;
//   var dueDate = DateTime.now().obs;
//   var showCustomerForm = false.obs;
//   var customerCount = 0.obs;
//   final invoiceType = InvoiceType.invoice.obs;
//
//   // Calculated values
//   var subtotal = 0.0.obs;
//   var taxAmount = 0.0.obs;
//   var totalAmount = 0.0.obs;
//
//   // Company data
//   var companyData = <String, dynamic>{}.obs;
//   int _lastInvoiceId = 0;
//
//   // Challan related variables
//   var challanList = <Challan>[].obs;
//   var challanItems = <ChallanItem>[].obs;
//   var challanDate = DateTime.now().obs;
//   final Rx<Challan?> selectedChallan = Rx<Challan?>(null);
//   final RxList<Challan> allChallans = <Challan>[].obs;
//   final RxList<String> customerNames = <String>[].obs;
//   final RxString selectedCustomerForInvoice = ''.obs;
//   final RxList<Challan> selectedCustomerChallans = <Challan>[].obs;
//   final RxBool createFromChallan = false.obs;
//
//   // Firebase instances
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Date controllers
//   final fromDateController = TextEditingController();
//   final toDateController = TextEditingController();
//   var selectedFromDate = DateTime.now().subtract(Duration(days: 30)).obs;
//   var selectedToDate = DateTime.now().obs;
//
//   var paymentStatus = 'Pending'.obs;
//
//   // Performance optimization variables
//   bool _isEssentialDataLoaded = false;
//   bool _isSecondaryDataLoaded = false;
//   bool _isTertiaryDataLoaded = false;
//   bool _initializationLock = false;
//   Timer? _debounceTimer;
//
//   // Caching mechanism
//   final Map<String, dynamic> _cache = {};
//   final Map<String, DateTime> _cacheTimestamps = {};
//   final Duration _cacheDuration = Duration(minutes: 10);
//
//   // Pagination variables
//   var currentChallanPage = 0;
//   final challanPageSize = 20;
//   var hasMoreChallans = true;
//   var priceControllers = <TextEditingController>[].obs;
//   var gstAmount = 0.0.obs;
//
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // Set up date controllers
//     fromDateController.text = _formatDateForDisplay(selectedFromDate.value);
//     toDateController.text = _formatDateForDisplay(selectedToDate.value);
//
//     // Load essential data only
//     _loadEssentialData();
//
//     // Load other data after a delay or when needed
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadSecondaryData();
//     });
//   }
//
//   Future<void> _loadEssentialData() async {
//     if (_initializationLock) return;
//     _initializationLock = true;
//
//     try {
//       await loadInvoices();
//       _initializeLastInvoiceId();
//       initializeInvoice();
//       _isEssentialDataLoaded = true;
//     } finally {
//       _initializationLock = false;
//     }
//   }
//
//
//   Future<void> _loadSecondaryData() async {
//     if (_isSecondaryDataLoaded) return;
//
//     try {
//       await loadCompanyData();
//       await loadCustomers();
//       await fetchItems2();
//       _isSecondaryDataLoaded = true;
//     } catch (e) {
//       print("Error loading secondary data: $e");
//     }
//   }
//
//   Future<void> _loadTertiaryData() async {
//     if (_isTertiaryDataLoaded) return;
//
//     try {
//       await loadChallans();
//       await loadChallansForInvoice();
//       _isTertiaryDataLoaded = true;
//     } catch (e) {
//       print("Error loading tertiary data: $e");
//     }
//   }
//
//   // Call this method when user actually needs the tertiary data
//   Future<void> ensureTertiaryDataLoaded() async {
//     if (!_isTertiaryDataLoaded) {
//       await _loadTertiaryData();
//     }
//   }
//
//
//
//   void initPriceControllers() {
//     priceControllers.clear();
//     for (var item in invoiceItems) {
//       priceControllers.add(TextEditingController(
//         text: item.rate.toStringAsFixed(0), // ✅ set once, no decimals
//       ));
//     }
//   }
//
//   /// 🟢 Always keep priceControllers in sync with invoiceItems
//   TextEditingController getPriceController(int index, {double? initialValue}) {
//     while (priceControllers.length < invoiceItems.length) {
//       final itemIndex = priceControllers.length;
//       final item = invoiceItems[itemIndex];
//       priceControllers.add(
//         TextEditingController(text: item.rate.toInt().toString()), // ✅ int only
//       );
//     }
//
//     while (priceControllers.length > invoiceItems.length) {
//       priceControllers.removeLast().dispose();
//     }
//
//     if (initialValue != null &&
//         priceControllers[index].text != initialValue.toInt().toString()) {
//       priceControllers[index].text = initialValue.toInt().toString();
//     }
//
//     return priceControllers[index];
//   }
//
//
//   void updatePriceController(int index, double newPrice) {
//     if (index < priceControllers.length) {
//       final formatted = newPrice.toStringAsFixed(0);
//       if (priceControllers[index].text != formatted) {
//         priceControllers[index].text = formatted;
//       }
//     }
//   }
//
//
//   @override
//   void onClose() {
//     // Cancel any pending timers
//     _debounceTimer?.cancel();
//
//     // Clear large lists to free memory
//     allChallans.clear();
//     selectedCustomerChallans.clear();
//     invoiceItems.clear();
//     customers.clear();
//     items.clear();
//     itemList.clear();
//     invoiceList.clear();
//     challanList.clear();
//
//     // Clear cache
//     _cache.clear();
//     _cacheTimestamps.clear();
//
//     // Dispose controllers
//     customerNameController.dispose();
//     customerMobileController.dispose();
//     customerEmailController.dispose();
//     customerAddressController.dispose();
//     invoiceNumberController.dispose();
//     dueDateController.dispose();
//     notesController.dispose();
//     fromDateController.dispose();
//     toDateController.dispose();
//
//     super.onClose();
//   }
//
//   // Generic method for cached data loading
//   Future<T> _loadWithCache<T>(String cacheKey, Future<T> Function() loader) async {
//     // Return cached data if it exists and is still valid
//     if (_cache.containsKey(cacheKey) &&
//         _cacheTimestamps.containsKey(cacheKey) &&
//         DateTime.now().difference(_cacheTimestamps[cacheKey]!) < _cacheDuration) {
//       return _cache[cacheKey] as T;
//     }
//
//     // Load fresh data
//     final data = await loader();
//
//     // Update cache
//     _cache[cacheKey] = data;
//     _cacheTimestamps[cacheKey] = DateTime.now();
//
//     return data;
//   }
//
//   void _initializeLastInvoiceId() {
//     final sameTypeInvoices = invoiceList.where((inv) =>
//     inv.invoiceId != null &&
//         inv.invoiceId!.startsWith(invoiceType.value.prefix)
//     ).toList();
//
//     if (sameTypeInvoices.isNotEmpty) {
//       final maxId = sameTypeInvoices.map((inv) {
//         return int.tryParse(inv.invoiceId!.replaceAll(invoiceType.value.prefix, '')) ?? 0;
//       }).reduce((a, b) => a > b ? a : b);
//
//       _lastInvoiceId = maxId;
//     } else {
//       _lastInvoiceId = 0;
//     }
//
//     print("📌 Last invoice ID initialized to $_lastInvoiceId");
//   }
//
//
//   Future<void> loadChallansForInvoice({bool loadMore = false}) async {
//     if (!loadMore) {
//       currentChallanPage = 0;
//       hasMoreChallans = true;
//       allChallans.clear();
//       customerNames.clear();
//       selectedCustomerChallans.clear();
//       invoiceItems.clear();
//     }
//
//     if (!hasMoreChallans) return;
//
//     try {
//       isLoading.value = true;
//
//       final challans = await GoogleSheetService.getChallansByDateRange(
//         fromDate: selectedFromDate.value,
//         toDate: selectedToDate.value,
//         userId: AppConstants.userId,
//       );
//
//       if (challans.length < challanPageSize) {
//         hasMoreChallans = false;
//       }
//
//       allChallans.addAll(challans);
//       currentChallanPage++;
//
//       // Extract unique customer names
//       final names = challans.map((challan) => challan.customerName).toSet().toList();
//       customerNames.assignAll(names);
//
//       print("Loaded ${challans.length} challans with items for ${names.length} customers");
//
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to load challans: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void selectCustomerForInvoice(String? customerName) async {
//     // Cancel previous timer if it exists
//     if (_debounceTimer != null && _debounceTimer!.isActive) {
//       _debounceTimer!.cancel();
//     }
//
//     // Set a new timer
//     _debounceTimer = Timer(Duration(milliseconds: 500), () {
//       _actuallySelectCustomerForInvoice(customerName);
//     });
//   }
//
//   void _actuallySelectCustomerForInvoice(String? customerName) async {
//     print("selectCustomerForInvoice called with: $customerName");
//     selectedCustomerForInvoice.value = customerName ?? '';
//
//     if (customerName != null && customerName.isNotEmpty) {
//       try {
//         isLoading.value = true;
//
//         // Clear previous selection
//         selectedCustomerChallans.clear();
//         invoiceItems.clear();
//
//         print("Loading challans with items for customer: $customerName");
//
//         // Load ONLY the challans for this specific customer WITH ITEMS
//         List<Challan> customerChallans =
//         await GoogleSheetService.getChallansWithItemsByCustomer(customerName);
//
//         // 🟢 Filter challans where status == 'inProgress'
//         customerChallans = customerChallans.where((challan) {
//           return challan.status?.toLowerCase() == "inprogress";
//         }).toList();
//
//         // 📌 Count challans inProgress
//         int inProgressCount = customerChallans.length;
//
//         // Filter to only include challans within date range
//         customerChallans = customerChallans.where((challan) {
//           return challan.challanDate != null &&
//               !challan.challanDate!.isBefore(selectedFromDate.value) &&
//               !challan.challanDate!.isAfter(selectedToDate.value);
//         }).toList();
//
//         selectedCustomerChallans.assignAll(customerChallans);
//
//         print("Found $inProgressCount in-progress challans for $customerName");
//         print("After date filter: ${selectedCustomerChallans.length}");
//
//         if (selectedCustomerChallans.isNotEmpty) {
//           populateInvoiceFromCustomerChallans();
//
//           showCustomSnackbar(
//             title: "Success",
//             message:
//             "Found $inProgressCount in-progress challans, loaded ${selectedCustomerChallans.length} for $customerName",
//             baseColor: Colors.green.shade700,
//             icon: Icons.check_circle_outline,
//           );
//         } else {
//           showCustomSnackbar(
//             title: "No Challans",
//             message: "No in-progress challans found for $customerName",
//             baseColor: Colors.orange.shade700,
//             icon: Icons.info_outline,
//           );
//         }
//       } catch (e) {
//         print("Error selecting customer for invoice: $e");
//         showCustomSnackbar(
//           title: "Error",
//           message: "Failed to load challans for customer",
//           baseColor: Colors.red.shade700,
//           icon: Icons.error_outline,
//         );
//       } finally {
//         isLoading.value = false;
//       }
//     } else {
//       selectedCustomerChallans.clear();
//       invoiceItems.clear();
//     }
//   }
//
//
//   void populateInvoiceFromCustomerChallans() {
//     invoiceItems.clear();
//
//     if (selectedCustomerChallans.isEmpty) {
//       return;
//     }
//
//     // Use more efficient operations
//     final newItems = selectedCustomerChallans
//         .where((challan) => challan.items != null && challan.items!.isNotEmpty)
//         .expand((challan) => challan.items!)
//         .map((challanItem) => InvoiceItem(
//       itemId: challanItem.itemId,
//       description: challanItem.itemName,
//       quantity: challanItem.quantity,
//       rate: challanItem.price,
//       itemName: challanItem.itemName,
//       ////totalPrice: challanItem.totalPrice,
//       challanId: challanItem.challanId,
//         gstRate: challanItem.gstRate
//     ))
//         .toList();
//
//     invoiceItems.addAll(newItems);
//
//     // Only update customer info if not already set
//     if (customerNameController.text.isEmpty && selectedCustomerChallans.isNotEmpty) {
//       final firstChallan = selectedCustomerChallans.first;
//       selectedCustomerId.value = firstChallan.customerId ?? '';
//       customerNameController.text = firstChallan.customerName ?? '';
//       customerMobileController.text =  firstChallan.customerMobile ?? '';
//       customerEmailController.text = firstChallan.customerEmail ?? '';
//       customerAddressController.text = firstChallan.customerAddress ?? '';
//     }
//
//     calculateTotals();
//   }
//
//   String _formatDateForDisplay(DateTime date) {
//     return DateFormat('dd/MM/yyyy').format(date);
//   }
//
//   void selectChallan(Challan challan) {
//     // Check if already selected
//     bool alreadySelected = selectedCustomerChallans.any(
//             (selected) => selected.challanId == challan.challanId
//     );
//
//     if (!alreadySelected) {
//       selectedCustomerChallans.add(challan);
//       print("Selected challan: ${challan.challanId}");
//     } else {
//       print("Challan ${challan.challanId} already selected");
//     }
//   }
//
//   void deselectChallan(Challan challan) {
//     selectedCustomerChallans.removeWhere(
//             (selected) => selected.challanId == challan.challanId
//     );
//     print("Deselected challan: ${challan.challanId}");
//   }
//
//   void clearChallanSelections() {
//     selectedCustomerChallans.clear();
//     print("Cleared all challan selections");
//   }
//
//   Future<void> loadChallans() async {
//     try {
//       isLoading.value = true;
//       print("=== FETCHING CHALLANS WITH ITEMS FROM APPSHEET ===");
//
//       List<Challan> challans = await _loadWithCache('challans', () async {
//         return await GoogleSheetService.getChallans();
//       });
//
//       print("Final result: ${challans.length} challans found");
//
//       // Detailed logging
//       int totalItems = 0;
//       for (var challan in challans) {
//         totalItems += challan.items?.length ?? 0;
//       }
//       print("Total items across all challans: $totalItems");
//
//       challanList.assignAll(challans);
//
//       if (challans.isEmpty) {
//         showCustomSnackbar(
//           title: "No Challans",
//           message: "No challans found",
//           baseColor: Colors.orange.shade700,
//           icon: Icons.info_outline,
//         );
//       } else {
//         showCustomSnackbar(
//           title: "Success",
//           message: "Found ${challans.length} challans with $totalItems items",
//           baseColor: Colors.green.shade700,
//           icon: Icons.check_circle_outline,
//         );
//       }
//
//     } catch (e) {
//       print("Error in loadChallans(): $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to load challans: ${e.toString()}",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadCompanyData() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       if (companyId.isEmpty) return;
//
//       final companyDoc = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .get();
//
//       if (companyDoc.exists) {
//         companyData.value = companyDoc.data() ?? {};
//         print("Company data loaded: ${companyData.value}");
//       }
//     } catch (e) {
//       print("Error loading company data: $e");
//     }
//   }
//
//   Future<void> loadCustomers() async {
//     try {
//       isLoading.value = true;
//
//       await _loadWithCache('customers', () async {
//         final user = _auth.currentUser;
//         if (user == null) return;
//
//         String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//         print("Company ID: $companyId");
//
//         final customersSnapshot = await _firestore
//             .collection("users")
//             .doc(user.uid)
//             .collection("companies")
//             .doc(companyId)
//             .collection("customers")
//             .get();
//
//         customers.clear();
//         for (var doc in customersSnapshot.docs) {
//           final data = doc.data();
//           data['id'] = doc.id;
//           customers.add(data);
//         }
//
//         customerCount.value = customers.length;
//         print("Customer count: ${customerCount.value}");
//
//         return null;
//       });
//
//     } catch (e) {
//       print("Error loading customers: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to load customers',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> fetchItems2() async {
//     try {
//       isLoading.value = true;
//
//       await _loadWithCache('items', () async {
//         final userId = AppConstants.userId;
//
//         print("=== ATTEMPTING TO FETCH ITEMS FOR USER: $userId ===");
//
//         List<Item> items = await GoogleSheetService.getItems(userId: userId);
//
//         print("Final result: ${items.length} items found");
//
//         for (var item in items) {
//           print("Found item: ${item.itemName} (ID: ${item.itemId}) for user: ${item.userId}");
//         }
//
//         itemList.assignAll(items);
//
//         if (items.isEmpty) {
//           showCustomSnackbar(
//             title: "No Items",
//             message: "No items found for the current user",
//             baseColor: Colors.orange.shade700,
//             icon: Icons.info_outline,
//           );
//         } else {
//           showCustomSnackbar(
//             title: "Success",
//             message: "Found ${items.length} items",
//             baseColor: Colors.green.shade700,
//             icon: Icons.check_circle_outline,
//           );
//         }
//
//         return null;
//       });
//
//     } catch (e) {
//       print("Error in fetchItems2(): $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to load items: $e",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadInvoices() async {
//     try {
//       isLoading.value = true;
//
//       await _loadWithCache('invoices', () async {
//         print("=== ATTEMPTING TO FETCH INVOICES ===");
//
//         List<Invoice> invoices = await GoogleSheetService.getInvoices();
//
//         if (invoices.isEmpty) {
//           print("Standard method failed, trying alternative...");
//           invoices = await GoogleSheetService.getInvoices();
//         }
//
//         print("Final result: ${invoices.length} invoices found");
//
//         for (var invoice in invoices) {
//           print("Found invoice: ${invoice.invoiceId} - Amount: ${invoice.totalAmount}");
//         }
//
//         invoiceList.assignAll(invoices);
//
//         if (invoices.isEmpty) {
//           showCustomSnackbar(
//             title: "No Invoices",
//             message: "No invoices found",
//             baseColor: Colors.orange.shade700,
//             icon: Icons.info_outline,
//           );
//         } else {
//           print("Found:-- ${invoices.length} invoices");
//         }
//
//         return null;
//       });
//
//     } catch (e) {
//       print("Error in fetchInvoices2(): $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to load invoices: $e",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void initializeInvoice() async {
//     print("🆕 INITIALIZING INVOICE - Starting...");
//     final newInvoiceId = generateInvoiceId();
//     print("🆔 GENERATED NEW INVOICE ID: $newInvoiceId");
//     invoiceNumberController.text = newInvoiceId;
//     dueDateController.text = _formatDate(dueDate.value);
//     print("📅 DUE DATE SET TO: ${dueDateController.text}");
//     addNewItem();
//     print("✅ INVOICE INITIALIZATION COMPLETE");
//   }
//
//   void setInvoiceType(InvoiceType type) {
//     invoiceType.value = type;
//     _generateInvoiceId();
//   }
//
//   String _generateInvoiceId() {
//     final newId = generateInvoiceId();
//     invoiceNumberController.text = newId;
//     print("------------New ID---------${newId}");
//     return newId;
//   }
//
//   String generateInvoiceId() {
//     _lastInvoiceId++;
//     return "${invoiceType.value.prefix}${(_lastInvoiceId).toString().padLeft(3, '0')}";
//   }
//
//
//   void selectCustomer(Map<String, dynamic>? customer) {
//     if (customer == null) {
//       selectedCustomerId.value = '';
//       clearCustomerSelection();
//       showCustomerForm.value = false;
//       return;
//     }
//
//
//     selectedCustomerId.value = customer['id'] ?? ''; // Make sure this captures the ID
//     customerNameController.text = customer['name'] ?? '';
//     customerMobileController.text = customer['mobile'] ?? '';
//     customerEmailController.text = customer['email'] ?? '';
//     customerAddressController.text = customer['address'] ?? '';
//     showCustomerForm.value = false;
//
//     print("Selected CustomerID: ${selectedCustomerId.value} ---- Name: ${customerNameController.text}");
//   }
//
//   void toggleCustomerForm() {
//     showCustomerForm.value = !showCustomerForm.value;
//     if (showCustomerForm.value) {
//       selectedCustomerId.value = '';
//       clearCustomerSelection();
//     }
//   }
//
//   void clearCustomerSelection() {
//     selectedCustomerId.value = '';
//     customerNameController.clear();
//     customerMobileController.clear();
//     customerEmailController.clear();
//     customerAddressController.clear();
//   }
//
//   void addNewItem() {
//     invoiceItems.add(InvoiceItem(
//         description: '',
//         quantity: 1,
//         rate: 0.0,
//         gstRate: 0.0,
//         itemId: '',
//         itemName: '',
//         totalPrice: 0.0
//     ));
//
//     calculateTotals();
//   }
//
//   void updateItem(int index, {String? description, double? quantity, double? rate, String? itemId, String? unit,}) {
//     if (index < invoiceItems.length) {
//       final item = invoiceItems[index];
//       final int newRate = rate?.toInt() ?? item.rate.toInt();
//
//       invoiceItems[index] = InvoiceItem(
//           description: description ?? item.description,
//           quantity: quantity ?? item.quantity,
//           rate: newRate.toDouble(),
//           gstRate: item.gstRate,
//           itemId: itemId ?? item.itemId,
//           totalPrice: item.totalPrice,
//           itemName: description ?? item.itemName,
//           unit: unit
//       );
//       calculateTotals();
//     }
//   }
//
//   void selectRemoteItemForIndex(int index, Item item) {
//     if (index < invoiceItems.length) {
//       invoiceItems[index] = InvoiceItem(
//           description: item.itemName,
//           quantity: invoiceItems[index].quantity,
//           rate: item.price.toDouble(),
//           gstRate: item.gstPercent.toDouble(),
//           itemId: item.itemId,
//           itemName: item.itemName,
//           //totalPrice: item.price
//           unit: item.unitOfMeasurement
//       );
//       calculateTotals();
//     }
//   }
//
//   void removeItem(int index) {
//     if (invoiceItems.length > 1) {
//       invoiceItems.removeAt(index);
//       calculateTotals();
//     }
//   }
//
//   void calculateTotals() {
//     // Use fold for better performance with large lists
//     double sub = 0.0;
//     double gst = 0.0;
//
//     for (var i = 0; i < invoiceItems.length; i++) {
//       final item = invoiceItems[i];
//       final itemTotal = item.rate * item.quantity;
//
//       double gstForItem = 0.0;
//       double withGst = itemTotal;
//
//       if (AppConstants.withGST.value) {
//         gstForItem = itemTotal * (item.gstRate / 100);
//         withGst += itemTotal +  gstForItem;
//       }
//
//       invoiceItems[i] = item.copyWith(
//         totalPrice: itemTotal,
//         gstAmount: gstForItem,
//         amountWithGst: withGst
//       );
//       sub += itemTotal;
//       gst += gstForItem;
//     }
//
//     subtotal.value = sub;
//
//     if (AppConstants.withGST.value) {
//       gstAmount.value = gst;
//       totalAmount.value = sub + gst;
//     } else {
//       gstAmount.value = 0.0;
//       totalAmount.value = sub;
//     }
//
//   }
//
//
//   void updatePaymentStatus(String status) {
//     paymentStatus.value = status;
//   }
//
//
//   Future<void> selectDueDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: dueDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null && picked != dueDate.value) {
//       dueDate.value = picked;
//       dueDateController.text = _formatDate(picked);
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }
//
//   Future<bool> saveInvoice({required bool isDraft}) async {
//     try {
//       if (!formKey.currentState!.validate()) {
//         showCustomSnackbar(
//           title: "Validation Error",
//           message: "Please fill all required fields",
//           baseColor: Colors.orange.shade700,
//           icon: Icons.warning,
//         );
//         return false;
//       }
//
//       isLoading.value = true;
//       // Calculate totals first
//       calculateTotals();
//
//       // Get customer ID logic (keep your existing logic)
//       String finalCustomerId = selectedCustomerId.value;
//
//       Map<String, dynamic> invoiceData = {
//         'invoiceId': invoiceNumberController.text,
//         'customerId': finalCustomerId,
//         'customerName': customerNameController.text.trim(),
//         'mobile': customerMobileController.text.trim(),
//         'customerEmail': customerEmailController.text.trim(),
//         'customerAddress': customerAddressController.text.trim(),
//         'issueDate':dueDate.value.toIso8601String(),
//         'dueDate': dueDate.value.toIso8601String(),
//         'subtotal': subtotal.value,
//         'gstRate': invoiceItems.isNotEmpty ? invoiceItems.first.gstRate : 0.0,
//         'gstAmount': gstAmount.value,
//         'totalAmount': totalAmount.value,
//         'notes': notesController.text,
//         'status': paymentStatus.value,
//         'userId': AppConstants.userId,
//       };
//
//       print("Saving invoice: ${invoiceData['invoiceId']}");
//
//       // 1. First save the main invoice
//       await GoogleSheetService.addInvoice(invoiceData, AppConstants.userId);
//
//       // 2. Then save each invoice item
//       for (var item in invoiceItems) {
//         Map<String, dynamic> invoiceItemData = {
//           'invoiceId': invoiceNumberController.text, // This must match the main invoice ID
//           'itemId': item.itemId,
//           'itemName': item.itemName,
//           'description': item.description,
//           'quantity': item.quantity,
//           'price': item.rate,
//           'gstRate': item.gstRate,
//           'gstAmount': item.gstAmount,
//           'amountWithGst': item.amountWithGst,
//           'totalPrice': item.totalPrice,
//         };
//
//         print("Saving invoice item: ${jsonEncode(invoiceItemData)}");
//
//         await GoogleSheetService.addInvoiceItem(invoiceItemData, AppConstants.userId);
//       }
//
//       // 3. Update stock (if needed)
//       await GoogleSheetService.updateStockAfterInvoice(invoiceItems);
//
//       // ✅ 4. Update challan status if challan items are linked
//       for (var item in invoiceItems) {
//         if (item.challanId != null && item.challanId!.isNotEmpty) {
//           try {
//             await GoogleSheetService.updateChallanStatus(
//               item.challanId!,
//               "Progress", // new status
//               AppConstants.userId,
//             );
//           } catch (e) {
//             print("Failed to update challan ${item.challanId}: $e");
//           }
//         }
//       }
//
//
//       // 4. Generate & share PDF (no need to pass invoiceItems again!)
//       List<Invoice> invoiceModels = invoiceItems.map((item) {
//         return Invoice(
//           invoiceId: invoiceNumberController.text,
//           itemId: item.itemId,
//           itemName: item.description,
//           qty: item.quantity,
//           price: item.rate.toDouble(),
//           mobile: customerMobileController.text.trim(),
//           customerId: selectedCustomerId.value,
//           customerName: customerNameController.text.trim(),
//           customerEmail: customerEmailController.text.trim(),
//           customerAddress: customerAddressController.text.trim(),
//           issueDate: DateTime.now(),
//           dueDate: dueDate.value,
//           subtotal: subtotal.value,
//           gst: item.gstRate,
//           gstRate: item.gstRate,
//           gstAmount: gstAmount.value,
//           totalAmount: totalAmount.value,
//           notes: notesController.text,
//           status: paymentStatus.value,
//         );
//       }).toList();
//
//       if (invoiceModels.isEmpty) {
//         showCustomSnackbar(
//           title: "Error",
//           message: "Invoice must have at least one item",
//           baseColor: Colors.red.shade700,
//           icon: Icons.error_outline,
//         );
//         return false;
//       }
//
//       // Check if invoice has challan reference
//       final bool hasChallan = invoiceItems.any((it) {
//         try {
//           return (it.challanId ?? '').toString().isNotEmpty;
//         } catch (_) { return false; }
//       });
//
//       print("----------======IS Challan=======---------$hasChallan");
//       if (hasChallan) {
//         // pass invoiceItems (the actual list that contains challanId)
//         await InvoiceHelper.generateAndShareInvoiceFromChallan(
//           invoiceItems, // List<dynamic> (InvoiceItem objects)
//           invoiceNumberController.text, // invoiceId
//           dueDateController.text,
//           customerNameController.text.trim(),
//           customerMobileController.text.trim(),
//           customerEmailController.text.trim(),
//           customerAddressController.text.trim(),
//           subtotal.value,
//           taxAmount.value,
//           totalAmount.value,
//           notesController.text,
//           companyData.value,
//           invoiceType.value,
//           gstAmount.value,
//         );
//       }
//       else {
//         // fallback to your existing function
//         await InvoiceHelper.generateAndShareInvoice(
//           invoiceModels,
//           customerNameController.text.trim(),
//           customerMobileController.text.trim(),
//           customerEmailController.text.trim(),
//           customerAddressController.text.trim(),
//           subtotal.value,
//           dueDateController.text,
//           //taxAmount.value,
//           totalAmount.value,
//
//          // taxRate.value,
//           //discountType.value,
//           notesController.text,
//           companyData.value,
//           invoiceType.value,
//           gstAmount.value,
//         );
//       }
//
//       showCustomSnackbar(
//         title: "Success",
//         message: "Invoice 'created' successfully!",
//         baseColor: AppColors.darkGreenColor,
//         icon: Icons.check_circle_outline,
//       );
//       clearForm();
//
//       Get.back();
//       return true;
//     } catch (e) {
//       print("Error saving invoice: $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to save invoice: ${e.toString()}",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error,
//       );
//
//       // Optional: Add rollback logic here if invoice was saved but items failed
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void clearForm() {
//     formKey.currentState?.reset();
//     invoiceItems.clear();
//     clearCustomerSelection();
//     notesController.clear();
//     calculateTotals();
//
//     initializeInvoice();
//   }
//
//   void showCustomSnackbar({
//     required String title,
//     required String message,
//     required Color baseColor,
//     required IconData icon,
//   }) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: baseColor,
//       colorText: Colors.white,
//       icon: Icon(icon, color: Colors.white),
//       duration: Duration(seconds: 3),
//     );
//   }
//
//   Future<void> selectFromDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedFromDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != selectedFromDate.value) {
//       selectedFromDate.value = picked;
//       fromDateController.text = _formatDateForDisplay(picked);
//       // Reload challans with new date range
//       loadChallansForInvoice();
//     }
//   }
//
//   Future<void> selectToDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedToDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != selectedToDate.value) {
//       selectedToDate.value = picked;
//       toDateController.text = _formatDateForDisplay(picked);
//       // Reload challans with new date range
//       loadChallansForInvoice();
//     }
//   }
// }

class NewInvoiceController extends GetxController {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final customerNameController = TextEditingController();
  final customerMobileController = TextEditingController();
  final customerEmailController = TextEditingController();
  final customerAddressController = TextEditingController();
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

  // NEW: Edit mode variables (matching Challan)
  final RxBool isEditMode = false.obs;
  final RxString editingInvoiceId = ''.obs;
  final Rxn<Map<String, dynamic>> originalInvoiceData = Rxn<Map<String, dynamic>>();
  final RxInt originalItemsCount = 0.obs;

  // Calculated values
  var subtotal = 0.0.obs;
  var taxAmount = 0.0.obs;
  var totalAmount = 0.0.obs;

  // Company data
  var companyData = <String, dynamic>{}.obs;
  int _lastInvoiceId = 0;

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
  var gstAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    // NEW: Handle arguments for edit mode
    _handleArguments();

    // Set up date controllers
    fromDateController.text = _formatDateForDisplay(selectedFromDate.value);
    toDateController.text = _formatDateForDisplay(selectedToDate.value);

    // Only initialize new invoice if NOT in edit mode
    if (!isEditMode.value) {
      _loadEssentialData();
    } else {
      // For edit mode, load data but don't initialize new invoice
      _loadEssentialData();
      if (invoiceItems.isEmpty) {
        addNewItem();
      }
    }

    // Load other data after a delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSecondaryData();
    });
  }

  // NEW: Handle arguments (matching Challan)
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

      print("📝 Set isEditMode.value = true (from direct Invoice)");
      print("🆔 Set editingInvoiceId.value = '${editingInvoiceId.value}'");

      try {
        originalInvoiceData.value = _invoiceToMap(arguments);
        print("✅ Successfully converted direct Invoice to Map");

        _prefillInvoiceData();
        print("✅ Successfully called _prefillInvoiceData()");
      } catch (e, stackTrace) {
        print("❌ Error processing direct Invoice: $e");
        print("📄 Stack trace: $stackTrace");
      }
    }
    // Handle Map arguments
    else if (arguments != null && arguments is Map) {
      print("✅ Arguments is a valid Map");
      print("🗝️ Arguments keys: ${arguments.keys.toList()}");

      final editModeValue = arguments['editMode'];
      print("🔧 Edit mode value: $editModeValue");

      if (arguments['editMode'] == true) {
        print("✅ Entering edit mode");

        isEditMode.value = true;
        print("📝 Set isEditMode.value = true");

        editingInvoiceId.value = arguments['invoiceId']?.toString() ?? '';
        print("🆔 Set editingInvoiceId.value = '${editingInvoiceId.value}'");

        if (arguments['invoiceData'] != null) {
          print("✅ Invoice data is not null, processing...");

          if (arguments['invoiceData'] is Invoice) {
            print("🏷️ Invoice data is Invoice object");
            final invoiceObj = arguments['invoiceData'] as Invoice;

            try {
              originalInvoiceData.value = _invoiceToMap(invoiceObj);
              print("✅ Successfully converted Invoice to Map");

              _prefillInvoiceData();
              print("✅ Successfully called _prefillInvoiceData()");
            } catch (e, stackTrace) {
              print("❌ Error converting Invoice to Map: $e");
              print("📄 Stack trace: $stackTrace");
            }
          } else if (arguments['invoiceData'] is Map) {
            print("🗺️ Invoice data is Map object");

            try {
              originalInvoiceData.value = Map<String, dynamic>.from(arguments['invoiceData'] as Map);
              print("✅ Successfully processed Map data");

              _prefillInvoiceData();
              print("✅ Successfully called _prefillInvoiceData()");
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
    print("   - editingInvoiceId.value: '${editingInvoiceId.value}'");
  }

  // NEW: Convert Invoice object to Map
  Map<String, dynamic> _invoiceToMap(Invoice invoice) {
    return {
      'invoiceId': invoice.invoiceId,
      'customerId': invoice.customerId,
      'customerName': invoice.customerName,
      'customerEmail': invoice.customerEmail,
      'mobile': invoice.mobile,
      'customerAddress': invoice.customerAddress,
      'issueDate': invoice.issueDate,
      'dueDate': invoice.dueDate,
      'subtotal': invoice.subtotal,
      'gstAmount': invoice.gstAmount,
      'totalAmount': invoice.totalAmount,
      'status': invoice.status,
      'notes': invoice.notes,
    };
  }

  // NEW: Pre-fill form fields with existing invoice data
  void _prefillInvoiceData() {
    print("🔄 Starting _prefillInvoiceData...");

    final invoiceData = originalInvoiceData.value;
    if (invoiceData != null) {
      print("📋 Prefilling with data: $invoiceData");

      // Pre-fill basic invoice info
      invoiceNumberController.text = invoiceData['invoiceId']?.toString() ?? '';
      print("🆔 Set invoice number to: ${invoiceNumberController.text}");

      // Pre-fill dates
      if (invoiceData['dueDate'] != null) {
        if (invoiceData['dueDate'] is DateTime) {
          dueDateController.text = _formatDate(invoiceData['dueDate'] as DateTime);
          dueDate.value = invoiceData['dueDate'] as DateTime;
        } else if (invoiceData['dueDate'] is String) {
          dueDateController.text = invoiceData['dueDate'] as String;
          try {
            dueDate.value = DateTime.parse(invoiceData['dueDate'] as String);
          } catch (e) {
            print('Could not parse date string: ${invoiceData['dueDate']}');
          }
        }
      }
      print("📅 Set due date to: ${dueDateController.text}");

      // Pre-fill customer info
      customerNameController.text = invoiceData['customerName']?.toString() ?? '';
      customerMobileController.text = invoiceData['mobile']?.toString() ?? '';
      customerEmailController.text = invoiceData['customerEmail']?.toString() ?? '';
      customerAddressController.text = invoiceData['customerAddress']?.toString() ?? '';

      // Restore customer ID
      if (invoiceData['customerId'] != null && invoiceData['customerId'].toString().isNotEmpty) {
        selectedCustomerId.value = invoiceData['customerId'].toString();
        print("🆔 Restored customer ID: ${selectedCustomerId.value}");
      }

      print("👤 Customer info prefilled:");
      print("   Name: ${customerNameController.text}");
      print("   Mobile: ${customerMobileController.text}");
      print("   Email: ${customerEmailController.text}");
      print("   Customer ID: ${selectedCustomerId.value}");

      // Pre-fill payment status and notes
      paymentStatus.value = invoiceData['status']?.toString() ?? 'Pending';
      notesController.text = invoiceData['notes']?.toString() ?? '';

      // Set financial values
      if (invoiceData['subtotal'] != null) {
        subtotal.value = double.tryParse(invoiceData['subtotal'].toString()) ?? 0.0;
      }
      if (invoiceData['gstAmount'] != null) {
        gstAmount.value = double.tryParse(invoiceData['gstAmount'].toString()) ?? 0.0;
      }
      if (invoiceData['totalAmount'] != null) {
        totalAmount.value = double.tryParse(invoiceData['totalAmount'].toString()) ?? 0.0;
      }

      print("💰 Financial data prefilled:");
      print("   Subtotal: ${subtotal.value}");
      print("   GST Amount: ${gstAmount.value}");
      print("   Total: ${totalAmount.value}");

      // Load existing items for this invoice
      _loadExistingInvoiceItems();
    }
  }

  // NEW: Load existing items for the invoice being edited
  // In NewInvoiceController - Replace _loadExistingInvoiceItems with this:

  void _loadExistingInvoiceItems() async {
    if (editingInvoiceId.value.isEmpty) {
      print("⚠️ No editing invoice ID, skipping item load");
      return;
    }

    try {
      isLoading.value = true;
      print("📦 Loading existing items for invoice: ${editingInvoiceId.value}");

      // Clear cache to force fresh data
      GoogleSheetService.clearInvoiceItemCache(editingInvoiceId.value);

      final existingItems = await GoogleSheetService.getInvoiceItemsByInvoiceId(
          editingInvoiceId.value
      );

      originalItemsCount.value = existingItems.length;
      print("📊 Found ${existingItems.length} existing items");

      // Clear and rebuild items list
      invoiceItems.clear();

      for (int i = 0; i < existingItems.length; i++) {
        final item = existingItems[i];

        print("📦 Item $i: ${item.itemName}");
        print("   - Rate: ${item.rate}");
        print("   - Quantity: ${item.quantity}");  // ← Check this value
        print("   - GST Rate: ${item.gstRate}");
        print("   - Total: ${item.totalPrice}");

        // Create new item with EXACT values from sheet
        final newItem = InvoiceItem(
          itemId: item.itemId ?? '',
          invoiceId: editingInvoiceId.value,
          customerId: item.customerId ?? _getValidCustomerId(),
          itemName: item.itemName ?? '',
          description: item.description ?? item.itemName ?? '',
          quantity: item.quantity,  // ✅ Critical - use actual value
          rate: item.rate ?? 0.0,
          gstRate: item.gstRate ?? 0.0,
          gstAmount: item.gstAmount ?? 0.0,      // ✅ Preserve
          amountWithGst: item.amountWithGst ?? 0.0,  // ✅ Preserve
          totalPrice: item.totalPrice ?? 0.0,    // ✅ Preserve
          challanId: item.challanId,
          unit: item.unit,
        );

        invoiceItems.add(newItem);

        // Verify the item was added correctly
        print("✅ Added item: Qty=${invoiceItems[i].quantity}, Rate=${invoiceItems[i].rate}");
      }

      // ✅ Clear and rebuild controllers after loading items
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

      // Force UI update
      invoiceItems.refresh();
      update();

      // Recalculate totals after loading all items
      calculateTotals();

      print('✅ Successfully loaded ${existingItems.length} items');
      print('💰 Totals - Subtotal: ${subtotal.value}, GST: ${gstAmount.value}, Total: ${totalAmount.value}');
      // ✅ Print final state
      print("=== FINAL LOADED STATE ===");
      for (int i = 0; i < invoiceItems.length; i++) {
        print("Item $i: ${invoiceItems[i].itemName} - Qty: ${invoiceItems[i].quantity}");
      }
    } catch (e, stackTrace) {
      print('❌ Error loading existing items: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar('Error', 'Failed to load existing items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // NEW: Format original invoice date for display
  String formatOriginalInvoiceDate() {
    final invoiceData = originalInvoiceData.value;
    if (invoiceData?['dueDate'] != null) {
      if (invoiceData!['dueDate'] is DateTime) {
        return _formatDate(invoiceData['dueDate'] as DateTime);
      } else if (invoiceData['dueDate'] is String) {
        return invoiceData['dueDate'] as String;
      }
    }
    return 'N/A';
  }

  // NEW: Check if in edit mode
  bool get isInEditMode => isEditMode.value && editingInvoiceId.value.isNotEmpty;

  Future<void> _loadEssentialData() async {
    if (_initializationLock) return;
    _initializationLock = true;

    try {
      await loadInvoices();
      _initializeLastInvoiceId();

      // Only initialize new invoice if NOT in edit mode
      if (!isEditMode.value) {
        initializeInvoice();
      }

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

  void initPriceControllers() {
    priceControllers.clear();
    for (var item in invoiceItems) {
      priceControllers.add(TextEditingController(
        text: item.rate.toStringAsFixed(0),
      ));
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

  // ✅ Add this method (similar to getPriceController)
  TextEditingController getQuantityController(int index, {double? initialValue}) {
    // Ensure we have enough controllers
    while (quantityControllers.length < invoiceItems.length) {
      final itemIndex = quantityControllers.length;
      final item = invoiceItems[itemIndex];
      quantityControllers.add(
        TextEditingController(text: item.quantity.toString()),
      );
    }

    // Remove excess controllers
    while (quantityControllers.length > invoiceItems.length) {
      quantityControllers.removeLast().dispose();
    }

    // Update if value changed
    if (initialValue != null &&
        quantityControllers[index].text != initialValue.toString()) {
      quantityControllers[index].text = initialValue.toString();
    }

    return quantityControllers[index];
  }

  // ✅ Update this method
  void updateQuantityController(int index, double newQuantity) {
    if (index < quantityControllers.length) {
      final formatted = newQuantity.toString();
      if (quantityControllers[index].text != formatted) {
        quantityControllers[index].text = formatted;
      }
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();

    // ✅ Add this
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
    customerAddressController.dispose();
    invoiceNumberController.dispose();
    dueDateController.dispose();
    notesController.dispose();
    fromDateController.dispose();
    toDateController.dispose();

    super.onClose();
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

  void _initializeLastInvoiceId() {
    final sameTypeInvoices = invoiceList.where((inv) =>
    inv.invoiceId != null &&
        inv.invoiceId!.startsWith(invoiceType.value.prefix)
    ).toList();

    if (sameTypeInvoices.isNotEmpty) {
      final maxId = sameTypeInvoices.map((inv) {
        return int.tryParse(inv.invoiceId!.replaceAll(invoiceType.value.prefix, '')) ?? 0;
      }).reduce((a, b) => a > b ? a : b);

      _lastInvoiceId = maxId;
    } else {
      _lastInvoiceId = 0;
    }

    print("📌 Last invoice ID initialized to $_lastInvoiceId");
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

      print("Loaded ${challans.length} challans with items for ${names.length} customers");

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

  void _actuallySelectCustomerForInvoice(String? customerName) async {
    print("selectCustomerForInvoice called with: $customerName");
    selectedCustomerForInvoice.value = customerName ?? '';

    if (customerName != null && customerName.isNotEmpty) {
      try {
        isLoading.value = true;

        selectedCustomerChallans.clear();
        invoiceItems.clear();

        print("Loading challans with items for customer: $customerName");

        List<Challan> customerChallans =
        await GoogleSheetService.getChallansWithItemsByCustomer(customerName);

        customerChallans = customerChallans.where((challan) {
          return challan.status?.toLowerCase() == "inprogress";
        }).toList();

        int inProgressCount = customerChallans.length;

        customerChallans = customerChallans.where((challan) {
          return challan.challanDate != null &&
              !challan.challanDate!.isBefore(selectedFromDate.value) &&
              !challan.challanDate!.isAfter(selectedToDate.value);
        }).toList();

        selectedCustomerChallans.assignAll(customerChallans);

        print("Found $inProgressCount in-progress challans for $customerName");
        print("After date filter: ${selectedCustomerChallans.length}");

        if (selectedCustomerChallans.isNotEmpty) {
          populateInvoiceFromCustomerChallans();

          showCustomSnackbar(
            title: "Success",
            message:
            "Found $inProgressCount in-progress challans, loaded ${selectedCustomerChallans.length} for $customerName",
            baseColor: Colors.green.shade700,
            icon: Icons.check_circle_outline,
          );
        } else {
          showCustomSnackbar(
            title: "No Challans",
            message: "No in-progress challans found for $customerName",
            baseColor: Colors.orange.shade700,
            icon: Icons.info_outline,
          );
        }
      } catch (e) {
        print("Error selecting customer for invoice: $e");
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

  void populateInvoiceFromCustomerChallans() {
    invoiceItems.clear();

    if (selectedCustomerChallans.isEmpty) {
      return;
    }

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

    if (customerNameController.text.isEmpty && selectedCustomerChallans.isNotEmpty) {
      final firstChallan = selectedCustomerChallans.first;
      selectedCustomerId.value = firstChallan.customerId ?? '';
      customerNameController.text = firstChallan.customerName ?? '';
      customerMobileController.text = firstChallan.customerMobile ?? '';
      customerEmailController.text = firstChallan.customerEmail ?? '';
      customerAddressController.text = firstChallan.customerAddress ?? '';
    }

    calculateTotals();
  }

  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void selectChallan(Challan challan) {
    bool alreadySelected = selectedCustomerChallans.any(
            (selected) => selected.challanId == challan.challanId
    );

    if (!alreadySelected) {
      selectedCustomerChallans.add(challan);
      print("Selected challan: ${challan.challanId}");
    } else {
      print("Challan ${challan.challanId} already selected");
    }
  }

  void deselectChallan(Challan challan) {
    selectedCustomerChallans.removeWhere(
            (selected) => selected.challanId == challan.challanId
    );
    print("Deselected challan: ${challan.challanId}");
  }

  void clearChallanSelections() {
    selectedCustomerChallans.clear();
    print("Cleared all challan selections");
  }

  Future<void> loadChallans() async {
    try {
      isLoading.value = true;
      print("=== FETCHING CHALLANS WITH ITEMS FROM APPSHEET ===");

      List<Challan> challans = await _loadWithCache('challans', () async {
        return await GoogleSheetService.getChallans();
      });

      print("Final result: ${challans.length} challans found");

      int totalItems = 0;
      for (var challan in challans) {
        totalItems += challan.items?.length ?? 0;
      }
      print("Total items across all challans: $totalItems");

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
      print("Error in loadChallans(): $e");
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
        print("Company data loaded: ${companyData.value}");
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

        customerCount.value = customers.length;
        print("Customer count: ${customerCount.value}");

        return null;
      });

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

  Future<void> fetchItems2() async {
    try {
      isLoading.value = true;

      await _loadWithCache('items', () async {
        final userId = AppConstants.userId;

        print("=== ATTEMPTING TO FETCH ITEMS FOR USER: $userId ===");

        List<Item> items = await GoogleSheetService.getItems(userId: userId);

        print("Final result: ${items.length} items found");

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

        return null;
      });

    } catch (e) {
      print("Error in fetchItems2(): $e");
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
        print("=== ATTEMPTING TO FETCH INVOICES ===");

        List<Invoice> invoices = await GoogleSheetService.getInvoices();

        if (invoices.isEmpty) {
          print("Standard method failed, trying alternative...");
          invoices = await GoogleSheetService.getInvoices();
        }

        print("Final result: ${invoices.length} invoices found");

        for (var invoice in invoices) {
          print("Found invoice: ${invoice.invoiceId} - Amount: ${invoice.totalAmount}");
        }

        invoiceList.assignAll(invoices);

        if (invoices.isEmpty) {
          showCustomSnackbar(
            title: "No Invoices",
            message: "No invoices found",
            baseColor: Colors.orange.shade700,
            icon: Icons.info_outline,
          );
        } else {
          print("Found:-- ${invoices.length} invoices");
        }

        return null;
      });

    } catch (e) {
      print("Error in fetchInvoices2(): $e");
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

  // Modified initializeInvoice to be called only for new invoices
  void initializeInvoice() async {
    print("🆕 INITIALIZING NEW INVOICE - Starting...");

    // Only generate new ID if not in edit mode
    if (isEditMode.value) {
      print("⚠️ In edit mode, skipping new invoice initialization");
      return;
    }

    final newInvoiceId = generateInvoiceId();
    print("🆔 GENERATED NEW INVOICE ID: $newInvoiceId");
    invoiceNumberController.text = newInvoiceId;
    dueDateController.text = _formatDate(dueDate.value);
    print("📅 DUE DATE SET TO: ${dueDateController.text}");
    addNewItem();
    print("✅ INVOICE INITIALIZATION COMPLETE");
  }

  void setInvoiceType(InvoiceType type) {
    invoiceType.value = type;
    _generateInvoiceId();
  }

  String _generateInvoiceId() {
    final newId = generateInvoiceId();
    invoiceNumberController.text = newId;
    print("------------New ID---------${newId}");
    return newId;
  }

  String generateInvoiceId() {
    _lastInvoiceId++;
    return "${invoiceType.value.prefix}${(_lastInvoiceId).toString().padLeft(3, '0')}";
  }

  void selectCustomer(Map<String, dynamic>? customer) {
    if (customer == null) {
      selectedCustomerId.value = '';
      clearCustomerSelection();
      showCustomerForm.value = false;
      return;
    }

    selectedCustomerId.value = customer['customerId'] ?? customer['id'] ?? '';
    customerNameController.text = customer['name'] ?? '';
    customerMobileController.text = customer['mobile'] ?? '';
    customerEmailController.text = customer['email'] ?? '';
    customerAddressController.text = customer['address'] ?? '';
    showCustomerForm.value = false;

    print("Selected Customer:");
    print("  ID: ${selectedCustomerId.value}");
    print("  Name: ${customerNameController.text}");
    print("  Mobile: ${customerMobileController.text}");
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
    customerAddressController.clear();
  }

  // NEW: Get valid customer ID (matching Challan)
  String _getValidCustomerId() {
    String customerId = '';

    if (selectedCustomerId.value.isNotEmpty) {
      customerId = selectedCustomerId.value;
      print("Using selectedCustomerId: $customerId");
    } else if (isEditMode.value && originalInvoiceData.value?['customerId'] != null) {
      customerId = originalInvoiceData.value!['customerId'].toString();
      selectedCustomerId.value = customerId;
      print("Using originalInvoiceData customerId: $customerId");
    } else if (invoiceItems.isNotEmpty && invoiceItems.first.customerId?.isNotEmpty == true) {
      customerId = invoiceItems.first.customerId!;
      selectedCustomerId.value = customerId;
      print("Using existing item's customerId: $customerId");
    }

    print("Final customer ID: '$customerId'");
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

    invoiceItems.add(InvoiceItem(
      description: '',
      quantity: 1,
      rate: 0.0,
      gstRate: 0.0,
      itemId: '',
      itemName: '',
      totalPrice: 0.0,
      customerId: customerId,
    ));

    print("Added new item with customer ID: '$customerId'");
    print("Total items: ${invoiceItems.length}");

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

      print("=== UPDATING ITEM $index ===");
      print("Old quantity: ${item.quantity}");
      print("New quantity: $quantity");

      final double updatedQuantity = quantity ?? item.quantity;
      final double updatedRate = rate ?? item.rate;

      // Recalculate totals with updated values
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

      // ✅ Update controllers
      if (quantity != null) {
        updateQuantityController(index, quantity);
      }
      if (rate != null) {
        updatePriceController(index, rate);
      }

      print("✅ Updated - Qty: ${invoiceItems[index].quantity}, Rate: ${invoiceItems[index].rate}");
      calculateTotals();
    }
  }

  void selectRemoteItemForIndex(int index, Item item) {
    if (index < invoiceItems.length) {
      final currentItem = invoiceItems[index];

      String customerId = _getValidCustomerId();

      if (customerId.isEmpty) {
        print("ERROR: Cannot select item - no valid customer ID found");
        Get.snackbar(
          'Error',
          'Customer ID missing. Please reload the invoice.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      double gstRateToUse;
      if (isEditMode.value && currentItem.itemId?.isNotEmpty == true) {
        gstRateToUse = currentItem.gstRate;
        print("Edit mode: Preserving existing GST rate: $gstRateToUse");
      } else {
        gstRateToUse = item.gstPercent.toDouble();
        print("Using item master GST rate: $gstRateToUse");
      }

      invoiceItems[index] = InvoiceItem(
        customerId: customerId,
        description: item.itemName,
        quantity: currentItem.quantity,
        rate: item.price.toDouble(),
        gstRate: gstRateToUse,
        itemId: item.itemId,
        itemName: item.itemName,
        totalPrice: currentItem.quantity * item.price.toDouble(),
        unit: item.unitOfMeasurement,
      );

      print("Updated item $index with customer ID: '${invoiceItems[index].customerId}'");
      calculateTotals();
    }
  }

  void removeItem(int index) {
    if (invoiceItems.length > 1) {
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

    print("Calculated totals: Subtotal=${sub}, GST=${gst}, Total=${totalAmount.value}");
  }

  void updatePaymentStatus(String status) {
    paymentStatus.value = status;
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

  // NEW: Debug methods (matching Challan)
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
      print("WARNING: Item had empty customer ID, using: '$customerId'");
    }

    Map<String, dynamic> itemData = {
      'invoiceId': invoiceNumberController.text,
      'customerId': customerId,
      'itemId': item.itemId ?? '',
      'itemName': item.itemName ?? '',
      'description': item.description ?? '',
      'quantity': item.quantity.toString(),
      'price': item.rate.toString(),
      'gstRate': item.gstRate.toString(),
      'gstAmount': item.gstAmount.toString(),
      'amountWithGst': item.amountWithGst.toString(),
      'totalPrice': item.totalPrice.toString(),
      'userId': AppConstants.userId,
    };

    print("Created item data with customer ID: '${itemData['customerId']}'");
    return itemData;
  }

  // NEW: Refresh parent controllers (matching Challan)
  void _refreshParentControllers() {
    try {
      if (Get.isRegistered<InvoiceListController>()) {
        final listController = Get.find<InvoiceListController>();
        listController.loadInvoices();
        print("Refreshed InvoiceListController");
      }

      if (Get.isRegistered<InvoiceDetailsController>()) {
        final detailsController = Get.find<InvoiceDetailsController>();
        detailsController.refreshInvoiceData();
        print("Refreshed InvoiceDetailsController");
      }
    } catch (e) {
      print("Error refreshing parent controllers: $e");
    }
  }

  ///06:39
  // Future<bool> saveInvoice({required bool isDraft}) async {
  //   try {
  //     if (!formKey.currentState!.validate()) {
  //       showCustomSnackbar(
  //         title: "Validation Error",
  //         message: "Please fill all required fields",
  //         baseColor: Colors.orange.shade700,
  //         icon: Icons.warning,
  //       );
  //       return false;
  //     }
  //
  //     isLoading.value = true;
  //
  //     // Fix any items with missing customer ID before saving
  //     debugAllItemsCustomerId();
  //
  //     // Calculate totals BEFORE saving
  //     calculateTotals();
  //
  //     Map<String, dynamic> invoiceData = {
  //       'invoiceId': invoiceNumberController.text,
  //       'customerId': _getValidCustomerId(),
  //       'customerName': customerNameController.text.trim(),
  //       'mobile': customerMobileController.text.trim(),
  //       //'customerEmail': customerEmailCtrl.text.trim(),
  //       'customerAddress': customerAddressController.text.trim(),
  //       'issueDate': dueDate.value.toIso8601String(),
  //       'dueDate': dueDate.value.toIso8601String(),
  //       'subtotal': subtotal.value,
  //       'gstRate': invoiceItems.isNotEmpty ? invoiceItems.first.gstRate : 0.0,
  //       'gstAmount': gstAmount.value,
  //       'totalAmount': totalAmount.value,
  //       'notes': notesController.text,
  //       'status': paymentStatus.value,
  //       'userId': AppConstants.userId,
  //     };
  //
  //     if (isInEditMode) {
  //       print("Updating existing invoice: ${invoiceNumberController.text}");
  //       debugInvoiceItemsBeforeSaving();
  //
  //       await GoogleSheetService.updateInvoice(invoiceData, AppConstants.userId);
  //
  //       List<Map<String, dynamic>> itemsData = [];
  //       for (var item in invoiceItems) {
  //         itemsData.add(createInvoiceItemData(item));
  //       }
  //
  //       await GoogleSheetService.updateInvoiceItems(
  //         invoiceNumberController.text,
  //         itemsData,
  //         AppConstants.userId,
  //       );
  //
  //       _refreshParentControllers();
  //       await loadInvoices();
  //
  //       showCustomSnackbar(
  //         title: "Success",
  //         message: "Invoice updated successfully!",
  //         baseColor: Colors.green.shade700,
  //         icon: Icons.check_circle_outline,
  //       );
  //
  //       // ✅ CRITICAL: Navigate back BEFORE cleanup
  //       Get.back(result: true);
  //
  //       // ✅ Wait a frame before cleanup to ensure navigation completes
  //       await Future.delayed(Duration(milliseconds: 100));
  //
  //       return true;
  //
  //     } else {
  //       print("Creating new invoice: ${invoiceNumberController.text}");
  //       debugInvoiceItemsBeforeSaving();
  //
  //       await GoogleSheetService.addInvoice(invoiceData, AppConstants.userId);
  //
  //       for (var item in invoiceItems) {
  //         Map<String, dynamic> invoiceItemData = createInvoiceItemData(item);
  //         print("Saving invoice item: ${invoiceItemData}");
  //         await GoogleSheetService.addInvoiceItem(invoiceItemData, AppConstants.userId);
  //       }
  //
  //       await GoogleSheetService.updateStockAfterInvoice(invoiceItems);
  //
  //       // Update challan status if items are linked
  //       for (var item in invoiceItems) {
  //         if (item.challanId != null && item.challanId!.isNotEmpty) {
  //           try {
  //             await GoogleSheetService.updateChallanStatus(
  //               item.challanId!,
  //               "Progress",
  //               AppConstants.userId,
  //             );
  //           } catch (e) {
  //             print("Failed to update challan ${item.challanId}: $e");
  //           }
  //         }
  //       }
  //
  //       await loadInvoices();
  //
  //       showCustomSnackbar(
  //         title: "Success",
  //         message: "Invoice created successfully!",
  //         baseColor: Colors.green.shade700,
  //         icon: Icons.check_circle_outline,
  //       );
  //
  //       clearForm();
  //       Get.back(result: true);
  //
  //       return true;
  //     }
  //
  //   } catch (e) {
  //     print("Error saving invoice: $e");
  //     showCustomSnackbar(
  //       title: "Error",
  //       message: "Failed to save invoice: ${e.toString()}",
  //       baseColor: Colors.red.shade700,
  //       icon: Icons.error,
  //       duration: Duration(seconds: 5),
  //     );
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<bool> saveInvoice({required bool isDraft}) async {
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

      // Fix any items with missing customer ID before saving
      debugAllItemsCustomerId();

      // Calculate totals BEFORE saving
      calculateTotals();

      String finalCustomerId = _getValidCustomerId();

      Map<String, dynamic> invoiceData = {
        'invoiceId': invoiceNumberController.text,
        'customerId': finalCustomerId,
        'customerName': customerNameController.text.trim(),
        'mobile': customerMobileController.text.trim(),
        'customerEmail': customerEmailController.text.trim(),
        'customerAddress': customerAddressController.text.trim(),
        'issueDate': dueDate.value.toIso8601String(),
        'dueDate': dueDate.value.toIso8601String(),
        'subtotal': subtotal.value,
        'gstRate': invoiceItems.isNotEmpty ? invoiceItems.first.gstRate : 0.0,
        'gstAmount': gstAmount.value,
        'totalAmount': totalAmount.value,
        'notes': notesController.text,
        'status': paymentStatus.value,
        'userId': AppConstants.userId,
      };

      // ✅ EDIT MODE vs CREATE MODE
      if (isInEditMode) {
        print("=== UPDATING EXISTING INVOICE ===");
        print("Invoice ID: ${invoiceNumberController.text}");
        debugInvoiceItemsBeforeSaving();

        // 1. Update the main invoice
        await GoogleSheetService.updateInvoice(invoiceData, AppConstants.userId);

        // 2. Update all invoice items (replace existing)
        List<Map<String, dynamic>> itemsData = [];
        for (var item in invoiceItems) {
          itemsData.add(createInvoiceItemData(item));
        }

        await GoogleSheetService.updateInvoiceItems(
          invoiceNumberController.text,
          itemsData,
          AppConstants.userId,
        );

        // 3. Refresh parent controllers
        _refreshParentControllers();

        showCustomSnackbar(
          title: "Success",
          message: "Invoice updated successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );

        // ✅ Navigate back BEFORE cleanup
        Get.back(result: true);

        // ✅ Wait a frame before cleanup
        await Future.delayed(Duration(milliseconds: 100));

        return true;

      } else {
        // ✅ CREATE MODE
        print("=== CREATING NEW INVOICE ===");
        print("Invoice ID: ${invoiceNumberController.text}");
        debugInvoiceItemsBeforeSaving();

        // 1. Save the main invoice
        await GoogleSheetService.addInvoice(invoiceData, AppConstants.userId);

        // 2. Save each invoice item
        for (var item in invoiceItems) {
          Map<String, dynamic> invoiceItemData = createInvoiceItemData(item);
          print("Saving invoice item: ${invoiceItemData}");
          await GoogleSheetService.addInvoiceItem(invoiceItemData, AppConstants.userId);
        }

        // 3. Update stock
        await GoogleSheetService.updateStockAfterInvoice(invoiceItems);

        // 4. Update challan status if items are linked
        for (var item in invoiceItems) {
          if (item.challanId != null && item.challanId!.isNotEmpty) {
            try {
              await GoogleSheetService.updateChallanStatus(
                item.challanId!,
                "Progress",
                AppConstants.userId,
              );
            } catch (e) {
              print("Failed to update challan ${item.challanId}: $e");
            }
          }
        }

        // 5. Generate & share PDF
        List<Invoice> invoiceModels = invoiceItems.map((item) {
          return Invoice(
            invoiceId: invoiceNumberController.text,
            itemId: item.itemId,
            itemName: item.description,
            qty: item.quantity,
            price: item.rate.toDouble(),
            mobile: customerMobileController.text.trim(),
            customerId: finalCustomerId,
            customerName: customerNameController.text.trim(),
            customerEmail: customerEmailController.text.trim(),
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

        // Check if invoice has challan reference
        final bool hasChallan = invoiceItems.any((it) {
          try {
            return (it.challanId ?? '').toString().isNotEmpty;
          } catch (_) {
            return false;
          }
        });

        print("----------======IS Challan=======---------$hasChallan");

        if (hasChallan) {
          await InvoiceHelper.generateAndShareInvoiceFromChallan(
            invoiceItems,
            invoiceNumberController.text,
            dueDateController.text,
            customerNameController.text.trim(),
            customerMobileController.text.trim(),
            customerEmailController.text.trim(),
            customerAddressController.text.trim(),
            subtotal.value,
            taxAmount.value,
            totalAmount.value,
            notesController.text,
            companyData.value,
            invoiceType.value,
            gstAmount.value,
          );
        } else {
          await InvoiceHelper.generateAndShareInvoice(
            invoiceModels,
            customerNameController.text.trim(),
            customerMobileController.text.trim(),
            customerEmailController.text.trim(),
            customerAddressController.text.trim(),
            subtotal.value,
            dueDateController.text,
            totalAmount.value,
            notesController.text,
            companyData.value,
            invoiceType.value,
            gstAmount.value,
          );
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
    calculateTotals();

    initializeInvoice();
  }

  // void showCustomSnackbar({
  //   required String title,
  //   required String message,
  //   required Color baseColor,
  //   required IconData icon,
  // }) {
  //   Get.snackbar(
  //     title,
  //     message,
  //     snackPosition: SnackPosition.BOTTOM,
  //     backgroundColor: baseColor,
  //     colorText: Colors.white,
  //     icon: Icon(icon, color: Colors.white),
  //     duration: Duration(seconds: 3),
  //   );
  // }

  // In NewInvoiceController - Update your showCustomSnackbar method:

  void showCustomSnackbar({
    required String title,
    required String message,
    required Color baseColor,
    required IconData icon,
    Duration? duration, // ✅ Add optional duration parameter
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: baseColor,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      duration: duration ?? Duration(seconds: 3), // ✅ Use custom or default duration
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




