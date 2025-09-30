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

/// Working 28-09 5:45
// class NewChallanController extends BaseController {
//   // Form controllers
//   final formKey = GlobalKey<FormState>();
//   final customerNameController = TextEditingController();
//   final customerMobileController = TextEditingController();
//   final customerEmailController = TextEditingController();
//   final customerAddressController = TextEditingController();
//   final challanNumberController = TextEditingController();
//   final challanDateController = TextEditingController();
//   final notesController = TextEditingController();
//
//   // Observable variables
//   var isLoading = false.obs;
//   var selectedCustomer = Rxn<Map<String, dynamic>>();
//   var customers = <Map<String, dynamic>>[].obs;
//   var items = <Map<String, dynamic>>[].obs;
//   var itemList = <Item>[].obs;
//   var challanList = <Challan>[].obs;
//   var challanItems = <ChallanItem>[].obs;
//   var challanDate = DateTime.now().obs;
//   var showCustomerForm = false.obs;
//   var customerCount = 0.obs;
//   var totalItems = 0.obs;
//   final RxString selectedCustomerId = ''.obs;
//
//   // Calculation observables
//   var subtotal = 0.0.obs;
//   var paymentStatus = 'Pending'.obs;
//   var totalAmount = 0.0.obs;
//   var discountType = 'amount'.obs;
//   var discountAmount = 0.0.obs;
//   var companyData = <String, dynamic>{}.obs;
//
//   // Firebase instances
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   var priceControllers = <TextEditingController>[].obs;
//   var gstAmount = 0.0.obs;
//
//   final RxBool isEditMode = false.obs;
//   final RxString editingChallanId = ''.obs;
//   final Rxn<Map<String, dynamic>> originalChallanData = Rxn<Map<String, dynamic>>();
//   final RxInt originalItemsCount = 0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _handleArguments();
//     // ✅ Generate challan ID first (only depends on challans)
//     initializeChallan();
//
//     // ✅ Load other data in parallel (non-blocking for challan ID)
//     Future.microtask(() {
//       loadCompanyData();
//       loadCustomers();
//       fetchItems();
//     });
//
//     //loadChallans();
//     //initializeChallan();
//     // loadCompanyData();
//     // loadCustomers();
//     // fetchItems();
//   }
//
//
//
// // ALTERNATIVE: Fix your _handleArguments to handle both cases
//   void _handleArguments() {
//     print("🔍 Starting _handleArguments...");
//
//     final arguments = Get.arguments;
//     print("📥 Raw arguments: $arguments");
//     print("📊 Arguments type: ${arguments.runtimeType}");
//     print("❓ Arguments is null: ${arguments == null}");
//
//     // Handle the case where arguments is directly a Challan object
//     if (arguments is Challan) {
//       print("🏷️ Arguments is directly a Challan object - treating as edit mode");
//
//       isEditMode.value = true;
//       editingChallanId.value = arguments.challanId ?? '';
//
//       print("📝 Set isEditMode.value = true (from direct Challan)");
//       print("🆔 Set editingChallanId.value = '${editingChallanId.value}'");
//
//       try {
//         originalChallanData.value = _challanToMap(arguments);
//         print("✅ Successfully converted direct Challan to Map");
//
//         _prefillChallanData();
//         print("✅ Successfully called _prefillChallanData()");
//       } catch (e, stackTrace) {
//         print("❌ Error processing direct Challan: $e");
//         print("📄 Stack trace: $stackTrace");
//       }
//     }
//     // Handle normal Map arguments
//     else if (arguments != null && arguments is Map) {
//       print("✅ Arguments is a valid Map");
//       print("🗝️ Arguments keys: ${arguments.keys.toList()}");
//       print("📋 Arguments values: ${arguments.values.toList()}");
//
//       final editModeValue = arguments['editMode'];
//       print("🔧 Edit mode value: $editModeValue (type: ${editModeValue.runtimeType})");
//       print("🔧 Edit mode == true: ${editModeValue == true}");
//
//       if (arguments['editMode'] == true) {
//         print("✅ Entering edit mode");
//
//         isEditMode.value = true;
//         print("📝 Set isEditMode.value = true");
//
//         final challanIdValue = arguments['challanId'];
//         print("🆔 Challan ID value: $challanIdValue (type: ${challanIdValue.runtimeType})");
//
//         editingChallanId.value = arguments['challanId']?.toString() ?? '';
//         print("🆔 Set editingChallanId.value = '${editingChallanId.value}'");
//
//         final challanDataValue = arguments['challanData'];
//         print("📦 Challan data value: $challanDataValue");
//         print("📦 Challan data type: ${challanDataValue.runtimeType}");
//
//         if (arguments['challanData'] != null) {
//           print("✅ Challan data is not null, processing...");
//
//           if (arguments['challanData'] is Challan) {
//             print("🏷️ Challan data is Challan object");
//             final challanObj = arguments['challanData'] as Challan;
//
//             try {
//               originalChallanData.value = _challanToMap(challanObj);
//               print("✅ Successfully converted Challan to Map");
//
//               _prefillChallanData();
//               print("✅ Successfully called _prefillChallanData()");
//             } catch (e, stackTrace) {
//               print("❌ Error converting Challan to Map: $e");
//               print("📄 Stack trace: $stackTrace");
//             }
//           } else if (arguments['challanData'] is Map) {
//             print("🗺️ Challan data is Map object");
//
//             try {
//               originalChallanData.value = Map<String, dynamic>.from(arguments['challanData'] as Map);
//               print("✅ Successfully processed Map data");
//
//               _prefillChallanData();
//               print("✅ Successfully called _prefillChallanData()");
//             } catch (e, stackTrace) {
//               print("❌ Error processing Map data: $e");
//               print("📄 Stack trace: $stackTrace");
//             }
//           }
//         }
//       }
//     }
//     else {
//       print("❌ Arguments is null or unrecognized type");
//       if (arguments != null) {
//         print("❓ Arguments type: ${arguments.runtimeType}");
//         print("💾 Arguments content: $arguments");
//       }
//     }
//
//     print("🏁 Finished _handleArguments");
//     print("📊 Final state:");
//     print("   - isEditMode.value: ${isEditMode.value}");
//     print("   - editingChallanId.value: '${editingChallanId.value}'");
//   }
//
//   /// Convert Challan object to Map for editing
//   Map<String, dynamic> _challanToMap(Challan challan) {
//     return {
//       'challanId': challan.challanId,
//       'customerName': challan.customerName,
//       'customerEmail': challan.customerEmail,
//       'customerMobile': challan.customerMobile,
//       'customerAddress': challan.customerAddress,
//       'challanDate': challan.challanDate,
//       'subtotal': challan.subtotal,
//       'gstAmount': challan.gstAmount,
//       'totalAmount': challan.totalAmount,
//       'paymentStatus': challan.paymentStatus,
//       'status': challan.status,
//       'notes': challan.notes,
//       // Add other fields as needed
//     };
//   }
//
//   /// Pre-fill form fields with existing challan data
//   void _prefillChallanData() {
//     final challanData = originalChallanData.value;
//     if (challanData != null) {
//       // Pre-fill basic challan info
//       challanNumberController.text = challanData['challanId']?.toString() ?? '';
//
//       // Pre-fill date
//       if (challanData['challanDate'] != null) {
//         if (challanData['challanDate'] is DateTime) {
//           ///selectedChallanDate.value = challanData['challanDate'] as DateTime;
//           challanDateController.text = _formatDate(challanData['challanDate'] as DateTime);
//         } else if (challanData['challanDate'] is String) {
//           // Parse string date if needed
//           try {
//             final date = DateTime.parse(challanData['challanDate'] as String);
//             ///selectedChallanDate.value = date;
//             challanDateController.text = _formatDate(date);
//           } catch (e) {
//             print('Error parsing date: $e');
//           }
//         }
//       }
//
//       // Pre-fill customer info
//       customerNameController.text = challanData['customerName']?.toString() ?? '';
//       customerMobileController.text = challanData['customerMobile']?.toString() ?? '';
//       customerEmailController.text = challanData['customerEmail']?.toString() ?? '';
//       customerAddressController.text = challanData['customerAddress']?.toString() ?? '';
//
//       // Pre-fill payment status
//       paymentStatus.value = challanData['paymentStatus']?.toString() ?? 'Pending';
//
//       // Pre-fill notes
//       notesController.text = challanData['notes']?.toString() ?? '';
//
//       // Load existing items for this challan
//       _loadExistingChallanItems();
//     }
//   }
//
//   /// Load existing items for the challan being edited
//   void _loadExistingChallanItems() async {
//     if (editingChallanId.value.isNotEmpty) {
//       try {
//         isLoading.value = true;
//         final existingItems = await GoogleSheetService.getChallanItemsByChallanId(editingChallanId.value);
//
//         originalItemsCount.value = existingItems.length;
//
//         // Clear existing items and add the loaded ones
//         challanItems.clear();
//         for (var item in existingItems) {
//           challanItems.add(ChallanItem(
//             customerId: item.customerId,
//             itemId: item.itemId,
//             challanId: editingChallanId.value,
//             itemName: item.itemName,
//             description: item.description,
//             quantity: item.quantity,
//             price: item.price,
//             unit: item.unit,
//             totalPrice: item.totalPrice,
//           ));
//         }
//
//         // Recalculate totals
//         calculateTotals();
//
//         print('✅ Loaded ${existingItems.length} existing items for editing');
//       } catch (e) {
//         print('❌ Error loading existing items: $e');
//         Get.snackbar('Error', 'Failed to load existing items');
//       } finally {
//         isLoading.value = false;
//       }
//     }
//   }
//
//   /// Format original challan date for display
//   String formatOriginalChallanDate() {
//     final challanData = originalChallanData.value;
//     if (challanData?['challanDate'] != null) {
//       if (challanData!['challanDate'] is DateTime) {
//         return _formatDate(challanData['challanDate'] as DateTime);
//       } else if (challanData['challanDate'] is String) {
//         return challanData['challanDate'] as String;
//       }
//     }
//     return 'N/A';
//   }
//
//
//   @override
//   void onClose() {
//     customerNameController.dispose();
//     customerMobileController.dispose();
//     customerEmailController.dispose();
//     customerAddressController.dispose();
//     challanNumberController.dispose();
//     challanDateController.dispose();
//     notesController.dispose();
//     super.onClose();
//   }
//
//
//   Future<void> loadChallans() async {
//     try {
//       isLoading.value = true;
//       print("=== ATTEMPTING TO FETCH CHALLANS ===");
//
//       // Add more detailed error handling
//       List<Challan> challans = await GoogleSheetService.getChallans();
//
//       print("Final result: ${challans.length} challans found");
//
//       // Debug: Print each found challan
//       for (var challan in challans) {
//         print("Found challan: ${challan.challanId} - ${challan.customerName}");
//       }
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
//           message: "Found ${challans.length} challans",
//           baseColor: Colors.green.shade700,
//           icon: Icons.check_circle_outline,
//         );
//       }
//
//     } catch (e, stackTrace) {
//       print("Error in loadChallans(): $e");
//       print("Stack trace: $stackTrace");
//
//       // More specific error handling
//       String errorMessage = "Failed to load challans";
//       if (e is FormatException) {
//         errorMessage = "Data format error: ${e.message}";
//         print("FormatException details: ${e.source}");
//       }
//
//       showCustomSnackbar(
//         title: "Error",
//         message: errorMessage,
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//
//   void initializeChallan() async {
//     print("🆕 INITIALIZING CHALLAN - Starting...");
//
//     final lastChallan = await getLastChallan();
//     String newId = generateChallanIdFromLast(lastChallan);
//     /// Only load challans here (not other data)
//     //await loadChallans();
//
//     // String newChallanId = generateChallanId();
//     // print("🆔 FINAL GENERATED CHALLAN ID: $newChallanId");
//
//     challanNumberController.text = newId;
//     challanDateController.text = _formatDate(challanDate.value);
//
//     addNewItem();
//     print("✅ CHALLAN INITIALIZATION COMPLETE");
//   }
//
//   /// 🟢 Always keep priceControllers in sync with challanItems
//   TextEditingController getPriceController(int index, {double? initialValue}) {
//     while (priceControllers.length < challanItems.length) {
//       final itemIndex = priceControllers.length;
//       final item = challanItems[itemIndex];
//       priceControllers.add(
//         TextEditingController(text: item.price.toStringAsFixed(2)), // ✅ int only
//       );
//     }
//
//     while (priceControllers.length > challanItems.length) {
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
//
//   String generateChallanIdFromLast(Challan? lastChallan) {
//     if (lastChallan == null || lastChallan.challanId == null) return "CH001";
//
//     RegExp regex = RegExp(r'^CH(\d+)$', caseSensitive: false);
//     final match = regex.firstMatch(lastChallan.challanId!);
//     if (match == null) return "CH001";
//
//     int number = int.tryParse(match.group(1) ?? "0") ?? 0;
//     return "CH${(number + 1).toString().padLeft(3, '0')}";
//   }
//
//   String generateChallanId() {
//     print("🔍 ANALYZING EXISTING CHALLANS FOR ID GENERATION:");
//
//     if (challanList.isEmpty) {
//       print("No existing challans found, starting with CH001");
//       return "CH001";
//     }
//
//     List<int> existingNumbers = [];
//
//     for (var challan in challanList) {
//       if (challan.challanId != null) {
//         String id = challan.challanId!.toUpperCase(); // Handle case variations
//         print("Checking challan ID: $id");
//
//         // Match CH followed by digits (case insensitive)
//         RegExp regex = RegExp(r'^CH(\d+)$', caseSensitive: false);
//         Match? match = regex.firstMatch(id);
//
//         if (match != null) {
//           try {
//             String numericPart = match.group(1)!;
//             int number = int.parse(numericPart);
//             existingNumbers.add(number);
//             print("  → Extracted number: $number");
//           } catch (e) {
//             print("  → Failed to parse numeric part: ${match.group(1)}");
//           }
//         } else {
//           print("  → Does not match CH### pattern");
//         }
//       }
//     }
//
//     if (existingNumbers.isEmpty) {
//       print("No valid CH-prefixed challans found, starting with CH001");
//       return "CH001";
//     }
//
//     int maxNumber = existingNumbers.reduce((max, current) => current > max ? current : max);
//     String newId = "CH${(maxNumber + 1).toString().padLeft(3, '0')}";
//
//     print("📊 Max existing number: $maxNumber");
//     print("🎯 Generated new ID: $newId");
//
//     return newId;
//   }
//
//   Future<Challan?> getLastChallan() async {
//     List<Challan> challans = await GoogleSheetService.getChallansList();
//     if (challans.isEmpty) return null;
//
//     challans.sort((a, b) => (a.challanId ?? '').compareTo(b.challanId ?? ''));
//    print("----lastttt: ${challans.last}");
//     return challans.last;
//   }
//
//   // Add this method to fetch company data
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
//         print("Company data loaded");
//       }
//     } catch (e) {
//       print("Error loading company data: $e");
//     }
//   }
//
//   Future<void> loadCustomers() async {
//     try {
//       isLoading.value = true;
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       print("Company ID: $companyId");
//
//       final customersSnapshot = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers")
//           .get();
//
//       customers.clear();
//       for (var doc in customersSnapshot.docs) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         customers.add(data);
//       }
//
//       // Also update customer count
//       customerCount.value = customers.length;
//
//       print("Customer---count----${customerCount.value}");
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
//   Future<void> fetchItems() async {
//     try {
//       isLoading.value = true;
//       final userId = AppConstants.userId;
//
//       print("=== ATTEMPTING TO FETCH ITEMS FOR USER: $userId ===");
//
//       // Try to get items
//       List<Item> items = await GoogleSheetService.getItems(userId: userId);
//
//       /// If no items found, try alternative methods
//       // if (items.isEmpty) {
//       //   print("Standard method failed, trying alternative...");
//       //   items = await RemoteService.getItemsAlternative(userId);
//       // }
//
//       print("Final result: ${items.length} items found");
//
//       // Debug: Print each found item
//       for (var item in items) {
//         print("Found item: ${item.itemName} (ID: ${item.itemId}) for user: ${item.userId}");
//       }
//
//       itemList.assignAll(items);
//
//       if (items.isEmpty) {
//         showCustomSnackbar(
//           title: "No Items",
//           message: "No items found for the current user",
//           baseColor: Colors.orange.shade700,
//           icon: Icons.info_outline,
//         );
//       } else {
//         showCustomSnackbar(
//           title: "Success",
//           message: "Found ${items.length} items",
//           baseColor: Colors.green.shade700,
//           icon: Icons.check_circle_outline,
//         );
//       }
//
//     } catch (e) {
//       print("Error in fetchItems(): $e");
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
//
//   void selectCustomer(Map<String, dynamic>? customer) {
//     if (customer == null) {
//       selectedCustomer.value = null;
//       clearCustomerSelection();
//       showCustomerForm.value = false;
//       return;
//     }
//
//     selectedCustomer.value = customer;
//     customerNameController.text = customer['name'] ?? '';
//     customerMobileController.text = customer['mobile'] ?? '';
//     customerEmailController.text = customer['email'] ?? '';
//     customerAddressController.text = customer['address'] ?? '';
//     selectedCustomerId.value = customer['customerId'] ?? '';
//     showCustomerForm.value = false;
//
//     print("Selected CustomerID:---- ${selectedCustomerId.value} ----NAme: ${customerNameController.text}");
//   }
//
//   void toggleCustomerForm() {
//     showCustomerForm.value = !showCustomerForm.value;
//     if (showCustomerForm.value) {
//       selectedCustomer.value = null;
//       clearCustomerSelection();
//     }
//   }
//
//   void clearCustomerSelection() {
//     selectedCustomer.value = null;
//     customerNameController.clear();
//     customerMobileController.clear();
//     customerEmailController.clear();
//     customerAddressController.clear();
//   }
//
//   void addNewItem() {
//     challanItems.add(ChallanItem(
//       description: '',
//       quantity: 1.0,
//       price: 0.0,
//       gstRate: 0.0,
//       itemId: '',
//       totalPrice: 0.0,
//       itemName: '',
// customerId: '',
//       unit: ''
//
//     ));
//     calculateTotals();
//   }
//
//   void updateItem(int index, {String? description, double? quantity, double? price, String? itemId,   String? unit,}) {
//     if (index < challanItems.length) {
//       final item = challanItems[index];
//       challanItems[index] = ChallanItem(
//         customerId: item.customerId,
//         description: description ?? item.description,
//         quantity: quantity!,
//         price: price ?? item.price,
//         gstRate: item.gstRate,
//         itemId: itemId ?? item.itemId,
//         itemName: description ?? item.itemName,
//         totalPrice: item.totalPrice,
//         unit: unit
//       );
//       calculateTotals();
//     }
//   }
//
//   void selectRemoteItemForIndex(int index, Item item) {
//     if (index < challanItems.length) {
//       challanItems[index] = ChallanItem(
//         customerId: selectedCustomerId.value.toString(),
//         description: item.itemName,
//         quantity: challanItems[index].quantity,
//         price: item.price.toDouble(),
//         gstRate: item.gstPercent.toDouble(),
//         itemId: item.itemId,
//           itemName: item.itemName,
//           totalPrice: item.price,
//         unit: item.unitOfMeasurement
//       );
//       calculateTotals();
//     }
//   }
//
//   void removeItem(int index) {
//     if (challanItems.length > 1) {
//       challanItems.removeAt(index);
//       calculateTotals();
//     }
//   }
//
//
//   void updatePaymentStatus(String status) {
//     paymentStatus.value = status;
//   }
//
//   Future<void> selectChallanDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: challanDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null && picked != challanDate.value) {
//       challanDate.value = picked;
//       challanDateController.text = _formatDate(picked);
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }
//
//   Future<bool> saveChallan({required bool isDraft}) async {
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
//
//       // Calculate totals first
//       calculateTotals();
//
//       // 1. First save the main challan record (single record)
//       Map<String, dynamic> challanData = {
//         'challanId': challanNumberController.text,
//         'challanDate': challanDate.value.toIso8601String(),
//         'customerId': selectedCustomerId.value,
//         'customerName': customerNameController.text.trim(),
//         'customerMobile': customerMobileController.text.trim(),
//         'customerEmail': customerEmailController.text.trim(),
//         'customerAddress': customerAddressController.text.trim(),
//         'subtotal': subtotal.value,
//         'gstRate': challanItems.isNotEmpty ? challanItems.first.gstRate : 0.0, // ✅ rate
//         'gstAmount': gstAmount.value, // ✅ calculated amount
//         'totalAmount': totalAmount.value,
//         'paymentStatus': paymentStatus.value,
//         'notes': notesController.text,
//         'status': isDraft ? 'draft' : 'inProgress',
//         'userId': AppConstants.userId,
//
//       };
//
//       print("Saving main challan record: ${jsonEncode(challanData)}");
//       await GoogleSheetService.addChallan(challanData, AppConstants.userId);
//
//       /// 2. Then save each challan item separately to InvoiceItems table
//       for (var item in challanItems) {
//         Map<String, dynamic> challanItemData = {
//          // '_RowNumber': '',
//           'challanId': challanNumberController.text, // Use challan ID as reference
//           'customerId': selectedCustomerId.value.toString(),
//           'itemId': item.itemId,
//           'itemName': item.description,
//           'description': item.description,
//           'quantity': item.quantity.toString(),
//           'price': item.price.toString(),
//           'gstRate': item.gstRate.toString(),
//           'gstAmount': item.gstAmount.toString(),
//           'amountWithGst': item.amountWithGst.toString(),
//           'totalPrice': (item.quantity * item.price).toString(),
//           'unit': item.unit,
//         };
//
//         print("Saving challan item to InvoiceItems: ${jsonEncode(challanItemData)}");
//
//         await GoogleSheetService.addChallanItem(challanItemData, AppConstants.userId);
//       }
//
//
//       /// 3. Update stock in Google Sheets
//       await GoogleSheetService.updateStockAfterDispatch(challanItems);
//
//       List<Challan> challanModel = challanItems.map((item) {
//         return Challan(
//             challanId: challanNumberController.text,
//             itemId: item.itemId,
//             itemName: item.description,   // ✅ correctly mapped
//             qty: item.quantity,
//             price: item.price.toDouble(),  // ✅ correctly mapped
//           gst: item.gstRate,
//           customerMobile: customerMobileController.text.trim(),
//           customerId: selectedCustomerId.value,
//           customerName: customerNameController.text.trim(),
//           customerEmail: customerEmailController.text.trim(),
//           customerAddress: customerAddressController.text.trim(),
//           subtotal: subtotal.value,
//           totalAmount: totalAmount.value,
//           gstAmount: gstAmount.value,
//           notes: notesController.text,
//           status: paymentStatus.value,
//           // unit: item.unit,
//         );
//       }).toList();
//
//
//
//       //
//       // Generate and share challan
//       await InvoiceHelper.generateAndShareChallan(
//         challanModel, // Pass items instead of challanModels
//         customerNameController.text.trim(),
//         customerMobileController.text.trim(),
//         customerEmailController.text.trim(),
//         customerAddressController.text.trim(),
//         subtotal.value,
//         challanDateController.text,
//         //taxAmount.value,
//         totalAmount.value,
//         //taxRate.value,
//         paymentStatus.value,
//         notesController.text,
//         companyData.value,
//         gstAmount.value,
//       );
//
//       showCustomSnackbar(
//         title: "Success",
//         message: "Challan created successfully!",
//         baseColor: AppColors.darkGreenColor,
//         icon: Icons.check_circle_outline,
//       );
//       clearForm();
//
//
//       Get.back();
//       return true;
//
//     } catch (e) {
//       print("Error saving challan: $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to save challan: ${e.toString()}",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error,
//       );
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // void calculateTotals() {
//   //   double sub = 0.0;
//   //   double gst = 0.0;
//   //
//   //   for (var item in challanItems) {
//   //     sub += item.quantity * item.price;
//   //   }
//   //   subtotal.value = sub;
//   //
//   //   double discountValue = 0.0;
//   //   if (discountType.value == 'percentage') {
//   //     discountValue = subtotal.value * (discountAmount.value / 100);
//   //   } else {
//   //     discountValue = discountAmount.value;
//   //   }
//   //
//   //   double afterDiscount = subtotal.value - discountValue;
//   //   taxAmount.value = afterDiscount * (taxRate.value / 100);
//   //   totalAmount.value = afterDiscount + taxAmount.value;
//   // }
//
//   ///with GSt
//   void calculateTotals() {
//     double sub = 0.0;
//     double gst = 0.0;
//
//     for (var i = 0; i < challanItems.length; i++) {
//       final item = challanItems[i];
//       final itemTotal = item.price * item.quantity;
//
//       double gstForItem = 0.0;
//       double withGst = itemTotal;
//
//       if (AppConstants.withGST.value) {
//         gstForItem = itemTotal * (item.gstRate / 100);
//         withGst = itemTotal + gstForItem;
//       }
//
//       // ✅ Always update challan item properly
//       challanItems[i] = item.copyWith(
//         totalPrice: itemTotal,
//         gstAmount: gstForItem,
//         amountWithGst: withGst,
//       );
//
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
//   }
//
//
//
//
//   void clearForm() {
//     formKey.currentState?.reset();
//     challanItems.clear();
//     clearCustomerSelection();
//     notesController.clear();
//     paymentStatus.value = 'Pending';
//     calculateTotals();
//
//     initializeChallan();
//   }
// }


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

  final RxBool isEditMode = false.obs;
  final RxString editingChallanId = ''.obs;
  final Rxn<Map<String, dynamic>> originalChallanData = Rxn<Map<String, dynamic>>();
  final RxInt originalItemsCount = 0.obs;

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
          } else if (arguments['challanData'] is Map) {
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
        } else if (challanData['challanDate'] is String) {
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


  // Modified initializeChallan to be called only for new challans
  void initializeChallan() async {
    print("🆕 INITIALIZING NEW CHALLAN - Starting...");

    // Only generate new ID if not in edit mode
    if (isEditMode.value) {
      print("⚠️ In edit mode, skipping new challan initialization");
      return;
    }

    final lastChallan = await getLastChallan();
    String newId = generateChallanIdFromLast(lastChallan);

    challanNumberController.text = newId;
    challanDateController.text = _formatDate(challanDate.value);

    // Add initial empty item for new challans
    if (challanItems.isEmpty) {
      addNewItem();
    }

    print("✅ NEW CHALLAN INITIALIZATION COMPLETE - ID: $newId");
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

    // IMPORTANT: Make sure customerId is set correctly
    selectedCustomerId.value = customer['customerId'] ?? customer['id'] ?? '';

    showCustomerForm.value = false;

    print("Selected Customer:");
    print("  ID: ${selectedCustomerId.value}");
    print("  Name: ${customerNameController.text}");
    print("  Mobile: ${customerMobileController.text}");
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

  /// Fixed addNewItem method
  void addNewItem() {
    print("Adding new item in ${isEditMode.value ? 'EDIT' : 'CREATE'} mode");

    String customerId = _getValidCustomerId();

    if (customerId.isEmpty) {
      print("WARNING: Customer ID is empty! This will cause data integrity issues.");
      if (isEditMode.value) {
        Get.snackbar(
          'Error',
          'Unable to determine customer ID. Please reload the challan.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
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
    if (index < challanItems.length) {
      final currentItem = challanItems[index];

      String customerId = _getValidCustomerId();

      if (customerId.isEmpty) {
        print("ERROR: Cannot select item - no valid customer ID found");
        Get.snackbar(
          'Error',
          'Customer ID missing. Please reload the challan.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      double gstRateToUse;
      if (isEditMode.value && currentItem.itemId.isNotEmpty) {
        gstRateToUse = currentItem.gstRate;
        print("Edit mode: Preserving existing GST rate: $gstRateToUse for existing item");
      } else {
        gstRateToUse = item.gstPercent.toDouble();
        print("Using item master GST rate: $gstRateToUse for new/empty item");
      }

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

/// Add a method to check if we're in edit mode
  bool get isInEditMode => isEditMode.value && editingChallanId.value.isNotEmpty;

  /// ENHANCED: Get valid customer ID with multiple fallback sources
  String _getValidCustomerId() {
    String customerId = '';

    // Try multiple sources in order of preference
    if (selectedCustomerId.value.isNotEmpty) {
      customerId = selectedCustomerId.value;
      print("Using selectedCustomerId: $customerId");
    } else if (isEditMode.value && originalChallanData.value?['customerId'] != null) {
      customerId = originalChallanData.value!['customerId'].toString();
      // Update selectedCustomerId for consistency
      selectedCustomerId.value = customerId;
      print("Using originalChallanData customerId: $customerId");
    } else if (challanItems.isNotEmpty && challanItems.first.customerId.isNotEmpty) {
      customerId = challanItems.first.customerId;
      selectedCustomerId.value = customerId;
      print("Using existing item's customerId: $customerId");
    }

    print("Final customer ID: '$customerId'");
    return customerId;
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

      debugAllItemsCustomerId();
      calculateTotals();

      String finalCustomerId = _getValidCustomerId();
      final challanId = challanNumberController.text;

      Map<String, dynamic> challanData = {
        'challanId': challanId,
        'challanDate': _formatDate(challanDate.value),
        'customerId': finalCustomerId,
        'customerName': customerNameController.text.trim(),
        'customerMobile': customerMobileController.text.trim(),
        'customerEmail': customerEmailController.text.trim(),
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

        await _refreshParentControllersAsync();
        await Future.delayed(const Duration(milliseconds: 300));

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
          message: "Challan updated successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );

        Get.back(result: true);
        return true;

      } else {
        print("=== CREATING NEW CHALLAN ===");

        await GoogleSheetService.addChallan(challanData, AppConstants.userId);

        for (var item in challanItems) {
          await GoogleSheetService.addChallanItem(
            createChallanItemData(item),
            AppConstants.userId,
          );
        }

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

    initializeChallan();
  }
}


