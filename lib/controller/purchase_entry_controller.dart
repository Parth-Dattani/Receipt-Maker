
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constant/constant.dart';
import '../model/model.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import '../widgets/widgets.dart';
import 'controller.dart';

// class PurchaseEntryController extends BaseController {
//   // Form controllers
//   final formKey = GlobalKey<FormState>();
//   final vendorNameController = TextEditingController();
//   final vendorMobileController = TextEditingController();
//   final vendorEmailController = TextEditingController();
//   final vendorAddressController = TextEditingController();
//   final purchaseNumberController = TextEditingController();
//   final purchaseDateController = TextEditingController();
//   final notesController = TextEditingController();
//
//   // Observable variables - Changed from vendors to customers
//   var selectedVendor = Rxn<Map<String, dynamic>>();
//   var customers = <Map<String, dynamic>>[].obs; // Changed from vendors
//   var itemList = <Item>[].obs;
//   var purchaseList = <PurchaseEntry>[].obs;
//   var purchaseItems = <PurchaseItem>[].obs;
//   var purchaseDate = DateTime.now().obs;
//   var showVendorForm = false.obs;
//   var vendorCount = 0.obs;
//   final RxString selectedVendorId = ''.obs;
//
//   // Calculation observables
//   var subtotal = 0.0.obs;
//   var paymentStatus = 'Pending'.obs;
//   var totalAmount = 0.0.obs;
//   var gstAmount = 0.0.obs;
//   var companyData = <String, dynamic>{}.obs;
//
//   // Firebase instances
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Edit mode variables
//   final RxBool isEditMode = false.obs;
//   final RxString editingPurchaseId = ''.obs;
//   final Rxn<Map<String, dynamic>> originalPurchaseData = Rxn<Map<String, dynamic>>();
//   final RxInt originalItemsCount = 0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _handleArguments();
//
//     if (!isEditMode.value) {
//       initializePurchase();
//     } else {
//       if (purchaseItems.isEmpty) {
//         addNewItem();
//       }
//     }
//
//     Future.microtask(() {
//       loadCompanyData();
//       loadCustomersAsVendors(); // Changed method name
//       fetchItems();
//     });
//   }
//
//   void _handleArguments() {
//     print("🔍 Starting _handleArguments...");
//
//     final arguments = Get.arguments;
//     print("📥 Raw arguments: $arguments");
//
//     if (arguments is PurchaseEntry) {
//       print("🏷️ Arguments is directly a PurchaseEntry object");
//       isEditMode.value = true;
//       editingPurchaseId.value = arguments.purchaseId ?? '';
//
//       try {
//         originalPurchaseData.value = _purchaseToMap(arguments);
//         _prefillPurchaseData();
//       } catch (e, stackTrace) {
//         print("❌ Error processing direct PurchaseEntry: $e");
//         print("📄 Stack trace: $stackTrace");
//       }
//     } else if (arguments != null && arguments is Map) {
//       if (arguments['editMode'] == true) {
//         isEditMode.value = true;
//         editingPurchaseId.value = arguments['purchaseId']?.toString() ?? '';
//
//         if (arguments['purchaseData'] != null) {
//           if (arguments['purchaseData'] is PurchaseEntry) {
//             final purchaseObj = arguments['purchaseData'] as PurchaseEntry;
//             try {
//               originalPurchaseData.value = _purchaseToMap(purchaseObj);
//               _prefillPurchaseData();
//             } catch (e, stackTrace) {
//               print("❌ Error converting PurchaseEntry to Map: $e");
//             }
//           } else if (arguments['purchaseData'] is Map) {
//             try {
//               originalPurchaseData.value = Map<String, dynamic>.from(arguments['purchaseData'] as Map);
//               _prefillPurchaseData();
//             } catch (e, stackTrace) {
//               print("❌ Error processing Map data: $e");
//             }
//           }
//         }
//       }
//     }
//
//     print("🏁 Finished _handleArguments");
//     print("📊 Final state: isEditMode=${isEditMode.value}, editingPurchaseId='${editingPurchaseId.value}'");
//   }
//
//   Map<String, dynamic> _purchaseToMap(PurchaseEntry purchase) {
//     return {
//       'purchaseId': purchase.purchaseId,
//       'vendorId': purchase.vendorId,
//       'vendorName': purchase.vendorName,
//       'vendorEmail': purchase.vendorEmail,
//       'vendorMobile': purchase.vendorMobile,
//       'vendorAddress': purchase.vendorAddress,
//       'purchaseDate': purchase.purchaseDate,
//       'subtotal': purchase.subtotal,
//       'gstAmount': purchase.gstAmount,
//       'totalAmount': purchase.totalAmount,
//       'paymentStatus': purchase.paymentStatus,
//       'notes': purchase.notes,
//     };
//   }
//
//   void _prefillPurchaseData() {
//     print("🔄 Starting _prefillPurchaseData...");
//
//     final purchaseData = originalPurchaseData.value;
//     if (purchaseData != null) {
//       print("📋 Prefilling with data: $purchaseData");
//
//       purchaseNumberController.text = purchaseData['purchaseId']?.toString() ?? '';
//
//       if (purchaseData['purchaseDate'] != null) {
//         if (purchaseData['purchaseDate'] is DateTime) {
//           purchaseDateController.text = _formatDate(purchaseData['purchaseDate'] as DateTime);
//           purchaseDate.value = purchaseData['purchaseDate'] as DateTime;
//         } else if (purchaseData['purchaseDate'] is String) {
//           purchaseDateController.text = purchaseData['purchaseDate'] as String;
//           try {
//             purchaseDate.value = DateTime.parse(purchaseData['purchaseDate'] as String);
//           } catch (e) {
//             print('Could not parse date string: ${purchaseData['purchaseDate']}');
//           }
//         }
//       }
//
//       vendorNameController.text = purchaseData['vendorName']?.toString() ?? '';
//       vendorMobileController.text = purchaseData['vendorMobile']?.toString() ?? '';
//       vendorEmailController.text = purchaseData['vendorEmail']?.toString() ?? '';
//       vendorAddressController.text = purchaseData['vendorAddress']?.toString() ?? '';
//
//       if (purchaseData['vendorId'] != null && purchaseData['vendorId'].toString().isNotEmpty) {
//         selectedVendorId.value = purchaseData['vendorId'].toString();
//         print("🆔 Restored vendor ID: ${selectedVendorId.value}");
//       }
//
//       paymentStatus.value = purchaseData['paymentStatus']?.toString() ?? 'Pending';
//       notesController.text = purchaseData['notes']?.toString() ?? '';
//
//       if (purchaseData['subtotal'] != null) {
//         subtotal.value = double.tryParse(purchaseData['subtotal'].toString()) ?? 0.0;
//       }
//       if (purchaseData['gstAmount'] != null) {
//         gstAmount.value = double.tryParse(purchaseData['gstAmount'].toString()) ?? 0.0;
//       }
//       if (purchaseData['totalAmount'] != null) {
//         totalAmount.value = double.tryParse(purchaseData['totalAmount'].toString()) ?? 0.0;
//       }
//
//       _loadExistingPurchaseItems();
//     }
//   }
//
//   void _loadExistingPurchaseItems() async {
//     if (editingPurchaseId.value.isEmpty) {
//       print("⚠️ No editing purchase ID, skipping item load");
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//       print("📦 Loading existing items for purchase: ${editingPurchaseId.value}");
//
//       final existingItems = await GoogleSheetService.getPurchaseItemsByPurchaseId(editingPurchaseId.value);
//
//       originalItemsCount.value = existingItems.length;
//       print("📊 Found ${existingItems.length} existing items");
//
//       purchaseItems.clear();
//       for (var item in existingItems) {
//         print("📦 Loading item: ${item.itemName}");
//         purchaseItems.add(PurchaseItem(
//           vendorId: item.vendorId ?? '',
//           itemId: item.itemId ?? '',
//           itemName: item.itemName ?? '',
//           description: item.description ?? '',
//           quantity: item.quantity ?? 1,
//           purchasePrice: item.purchasePrice ?? 0.0,
//           unit: item.unit ?? 'pcs',
//           totalPrice: item.totalPrice ?? 0.0,
//           gstRate: item.gstRate ?? 0.0,
//           createdAt: item.createdAt ?? DateTime.now(),
//         ));
//       }
//
//       calculateTotals();
//       print('✅ Loaded ${existingItems.length} existing items for editing');
//
//     } catch (e) {
//       print('❌ Error loading existing items: $e');
//       Get.snackbar('Error', 'Failed to load existing items');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   @override
//   void onClose() {
//     vendorNameController.dispose();
//     vendorMobileController.dispose();
//     vendorEmailController.dispose();
//     vendorAddressController.dispose();
//     purchaseNumberController.dispose();
//     purchaseDateController.dispose();
//     notesController.dispose();
//     super.onClose();
//   }
//
//   void initializePurchase() async {
//     print("🆕 INITIALIZING NEW PURCHASE");
//
//     if (isEditMode.value) {
//       print("⚠️ In edit mode, skipping new purchase initialization");
//       return;
//     }
//
//     final lastPurchase = await getLastPurchase();
//     String newId = generatePurchaseIdFromLast(lastPurchase);
//
//     purchaseNumberController.text = newId;
//     purchaseDateController.text = _formatDate(purchaseDate.value);
//
//     if (purchaseItems.isEmpty) {
//       addNewItem();
//     }
//
//     print("✅ NEW PURCHASE INITIALIZATION COMPLETE - ID: $newId");
//   }
//
//   String generatePurchaseIdFromLast(PurchaseEntry? lastPurchase) {
//     if (lastPurchase == null || lastPurchase.purchaseId == null) return "PUR001";
//
//     RegExp regex = RegExp(r'^PUR(\d+)$', caseSensitive: false);
//     final match = regex.firstMatch(lastPurchase.purchaseId!);
//     if (match == null) return "PUR001";
//
//     int number = int.tryParse(match.group(1) ?? "0") ?? 0;
//     return "PUR${(number + 1).toString().padLeft(3, '0')}";
//   }
//
//   Future<PurchaseEntry?> getLastPurchase() async {
//     List<PurchaseEntry> purchases = await GoogleSheetService.getPurchasesList();
//     if (purchases.isEmpty) return null;
//
//     purchases.sort((a, b) => (a.purchaseId ?? '').compareTo(b.purchaseId ?? ''));
//     return purchases.last;
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
//         print("Company data loaded");
//       }
//     } catch (e) {
//       print("Error loading company data: $e");
//     }
//   }
//
//   // Changed method name from loadVendors to loadCustomersAsVendors
//   Future<void> loadCustomersAsVendors() async {
//     try {
//       isLoading.value = true;
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       print("Company ID: $companyId");
//
//       // Changed collection from "vendors" to "customers"
//       final customersSnapshot = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers") // Changed from vendors
//           .get();
//
//       customers.clear();
//
//       for (var doc in customersSnapshot.docs) {
//         final data = doc.data();
//         bool isActive = data['isActive'] ?? true;
//
//         if (isActive) {
//           data['id'] = doc.id;
//           // Map customer fields to vendor fields
//           data['vendorId'] = data['customerId'] ?? doc.id;
//           customers.add(data);
//           print("Added active customer as vendor: ${data['name']} (ID: ${doc.id})");
//         }
//       }
//
//       vendorCount.value = customers.length;
//       print("Active Customer count (as vendors): ${vendorCount.value}");
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
//   Future<void> fetchItems() async {
//     try {
//       isLoading.value = true;
//       final userId = AppConstants.userId;
//
//       print("=== ATTEMPTING TO FETCH ITEMS FOR USER: $userId ===");
//
//       List<Item> items = await GoogleSheetService.getItems(userId: userId);
//
//       print("Final result: ${items.length} items found");
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
//   void selectVendor(Map<String, dynamic>? vendor) {
//     if (vendor == null) {
//       selectedVendor.value = null;
//       clearVendorSelection();
//       showVendorForm.value = false;
//       return;
//     }
//
//     bool isActive = vendor['isActive'] ?? true;
//     if (!isActive) {
//       Get.snackbar(
//         'Customer Inactive',
//         'This customer is currently inactive. Please select an active customer.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     selectedVendor.value = vendor;
//     vendorNameController.text = vendor['name'] ?? '';
//     vendorMobileController.text = vendor['mobile1'] ?? vendor['mobile'] ?? '';
//     vendorEmailController.text = vendor['email'] ?? '';
//     vendorAddressController.text = vendor['address'] ?? '';
//
//     selectedVendorId.value = vendor['vendorId'] ?? vendor['customerId'] ?? vendor['id'] ?? '';
//     showVendorForm.value = false;
//
//     print("Selected Active Customer as Vendor: ID: ${selectedVendorId.value}, Name: ${vendorNameController.text}");
//   }
//
//   void toggleVendorForm() {
//     showVendorForm.value = !showVendorForm.value;
//     if (showVendorForm.value) {
//       selectedVendor.value = null;
//       clearVendorSelection();
//     }
//   }
//
//   void clearVendorSelection() {
//     selectedVendor.value = null;
//     vendorNameController.clear();
//     vendorMobileController.clear();
//     vendorEmailController.clear();
//     vendorAddressController.clear();
//   }
//
//   void addNewItem() {
//     print("Adding new item in ${isEditMode.value ? 'EDIT' : 'CREATE'} mode");
//
//     String vendorId = _getValidVendorId();
//
//     if (vendorId.isEmpty && isEditMode.value) {
//       print("WARNING: Vendor ID is empty in edit mode!");
//       Get.snackbar(
//         'Error',
//         'Unable to determine vendor ID. Please reload the purchase.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     purchaseItems.add(PurchaseItem(
//       description: '',
//       quantity: 1,
//       purchasePrice: 0.0,
//       gstRate: 0.0,
//       itemId: '',
//       totalPrice: 0.0,
//       itemName: '',
//       vendorId: vendorId,
//       unit: 'pcs',
//       createdAt: DateTime.now(),
//     ));
//
//     print("Added new item with vendor ID: '$vendorId'");
//     print("Total items: ${purchaseItems.length}");
//
//     calculateTotals();
//   }
//
//   // Modified to handle manual item entry
//   void updateItem(int index, {
//     String? itemName,
//     String? description,
//     int? quantity,
//     double? purchasePrice,
//     String? unit,
//   }) {
//     if (index < purchaseItems.length) {
//       final item = purchaseItems[index];
//       purchaseItems[index] = PurchaseItem(
//         vendorId: item.vendorId,
//         itemName: itemName ?? item.itemName,
//         description: description ?? item.description,
//         quantity: quantity ?? item.quantity,
//         purchasePrice: purchasePrice ?? item.purchasePrice,
//         gstRate: item.gstRate,
//         itemId: item.itemId,
//         totalPrice: item.totalPrice,
//         unit: unit ?? item.unit,
//         createdAt: item.createdAt,
//       );
//       calculateTotals();
//     }
//   }
//
//   void removeItem(int index) {
//     if (purchaseItems.length > 1) {
//       purchaseItems.removeAt(index);
//       calculateTotals();
//     }
//   }
//
//   void updatePaymentStatus(String status) {
//     paymentStatus.value = status;
//   }
//
//   Future<void> selectPurchaseDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: purchaseDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null && picked != purchaseDate.value) {
//       purchaseDate.value = picked;
//       purchaseDateController.text = _formatDate(picked);
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }
//
//   String _getValidVendorId() {
//     String vendorId = '';
//
//     if (selectedVendorId.value.isNotEmpty) {
//       vendorId = selectedVendorId.value;
//     } else if (isEditMode.value && originalPurchaseData.value?['vendorId'] != null) {
//       vendorId = originalPurchaseData.value!['vendorId'].toString();
//       selectedVendorId.value = vendorId;
//     } else if (purchaseItems.isNotEmpty && purchaseItems.first.vendorId.isNotEmpty) {
//       vendorId = purchaseItems.first.vendorId;
//       selectedVendorId.value = vendorId;
//     } else if (vendorNameController.text.trim().isNotEmpty) {
//       vendorId = 'MANUAL_${vendorNameController.text.trim().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
//       selectedVendorId.value = vendorId;
//     }
//
//     return vendorId;
//   }
//
//   bool _validatePurchaseItems() {
//     if (purchaseItems.isEmpty) {
//       showCustomSnackbar(
//         title: "Validation Error",
//         message: "Please add at least one item to the purchase",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//       return false;
//     }
//
//     bool hasValidItem = purchaseItems.any((item) {
//       bool hasItemName = item.itemName != null && item.itemName!.isNotEmpty;
//       bool hasDescription = item.description != null && item.description!.isNotEmpty;
//       return hasItemName || hasDescription;
//     });
//
//     if (!hasValidItem) {
//       showCustomSnackbar(
//         title: "No Items Entered",
//         message: "Please enter at least one item name or description",
//         baseColor: Colors.orange.shade700,
//         icon: Icons.warning_amber_rounded,
//       );
//       return false;
//     }
//
//     bool hasInvalidQuantityOrPrice = purchaseItems.any((item) {
//       bool isValidItem = (item.itemName?.isNotEmpty ?? false) ||
//           (item.description?.isNotEmpty ?? false);
//
//       if (isValidItem) {
//         return item.quantity <= 0 || item.purchasePrice <= 0;
//       }
//       return false;
//     });
//
//     if (hasInvalidQuantityOrPrice) {
//       showCustomSnackbar(
//         title: "Invalid Item Data",
//         message: "All items must have quantity and price greater than 0",
//         baseColor: Colors.orange.shade700,
//         icon: Icons.warning_amber_rounded,
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   Map<String, dynamic> createPurchaseItemData(PurchaseItem item) {
//     String vendorId = item.vendorId;
//     if (vendorId.isEmpty) {
//       vendorId = _getValidVendorId();
//     }
//
//     String formattedDate = _formatDate(purchaseDate.value);
//
//     return {
//       'purchaseId': purchaseNumberController.text,
//       'vendorId': vendorId,
//       'itemId': item.itemId ?? '',
//       'itemName': item.itemName ?? '',
//       'description': item.description ?? '',
//       'quantity': item.quantity.toString(),
//       'purchasePrice': item.purchasePrice.toString(),
//       'purchaseDate': formattedDate,
//       'gstRate': item.gstRate.toString(),
//       'totalPrice': item.totalPrice.toString(),
//       'unit': item.unit ?? 'pcs',
//       'userId': AppConstants.userId,
//     };
//   }
//
//   void calculateTotals() {
//     double sub = 0.0;
//     double gst = 0.0;
//
//     for (var i = 0; i < purchaseItems.length; i++) {
//       final item = purchaseItems[i];
//       final itemTotal = item.purchasePrice * item.quantity;
//
//       double gstForItem = 0.0;
//       double withGst = itemTotal;
//
//       if (AppConstants.withGST.value) {
//         gstForItem = itemTotal * (item.gstRate / 100);
//         withGst = itemTotal + gstForItem;
//       }
//
//       purchaseItems[i] = item.copyWith(
//         totalPrice: withGst,
//       );
//
//       sub += itemTotal;
//       gst += gstForItem;
//     }
//
//     subtotal.value = sub;
//     gstAmount.value = gst;
//     totalAmount.value = AppConstants.withGST.value ? sub + gst : sub;
//
//     print("Calculated totals: Subtotal=${sub}, GST=${gst}, Total=${totalAmount.value}");
//   }
//
//   Future<bool> savePurchase() async {
//     try {
//       if (vendorNameController.text.trim().isEmpty) {
//         showCustomSnackbar(
//           title: "Vendor Required",
//           message: "Please select a customer or enter vendor details",
//           baseColor: Colors.red.shade700,
//           icon: Icons.store_outlined,
//         );
//         return false;
//       }
//
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
//       if (!_validatePurchaseItems()) {
//         return false;
//       }
//
//       isLoading.value = true;
//       calculateTotals();
//
//       String finalVendorId = _getValidVendorId();
//
//       if (finalVendorId.isEmpty) {
//         isLoading.value = false;
//         showCustomSnackbar(
//           title: "Vendor ID Error",
//           message: "Unable to determine vendor ID. Please try again.",
//           baseColor: Colors.red.shade700,
//           icon: Icons.error_outline,
//         );
//         return false;
//       }
//
//       final purchaseId = purchaseNumberController.text;
//
//       Map<String, dynamic> purchaseData = {
//         'purchaseId': purchaseId,
//         'purchaseDate': _formatDate(purchaseDate.value),
//         'vendorId': finalVendorId,
//         'vendorName': vendorNameController.text.trim(),
//         'vendorMobile': vendorMobileController.text.trim(),
//         'vendorEmail': vendorEmailController.text.trim(),
//         'vendorAddress': vendorAddressController.text.trim(),
//         'subtotal': subtotal.value,
//         'gstRate': purchaseItems.isNotEmpty ? purchaseItems.first.gstRate : 0.0,
//         'gstAmount': gstAmount.value,
//         'totalAmount': totalAmount.value,
//         'paymentStatus': paymentStatus.value,
//         'notes': notesController.text,
//         'userId': AppConstants.userId,
//       };
//
//       if (isEditMode.value && editingPurchaseId.value.isNotEmpty) {
//         print("=== UPDATING EXISTING PURCHASE ===");
//
//         await GoogleSheetService.updatePurchaseWithCacheClear(
//           purchaseData,
//           AppConstants.userId,
//         );
//
//         List<Map<String, dynamic>> itemsData =
//         purchaseItems.map((item) => createPurchaseItemData(item)).toList();
//
//         await GoogleSheetService.updatePurchaseItemsWithCacheClear(
//           purchaseId,
//           itemsData,
//           AppConstants.userId,
//         );
//
//         showCustomSnackbar(
//           title: "Success",
//           message: "Purchase updated successfully!",
//           baseColor: Colors.green.shade700,
//           icon: Icons.check_circle_outline,
//         );
//
//         Get.back(result: true);
//         return true;
//
//       } else {
//         print("=== CREATING NEW PURCHASE ===");
//
//         await GoogleSheetService.addPurchase(purchaseData, AppConstants.userId);
//
//         List<Map<String, dynamic>> itemsData =
//         purchaseItems.map((item) => createPurchaseItemData(item)).toList();
//
//         await GoogleSheetService.addPurchaseItemsBatch(
//           itemsData,
//           AppConstants.userId,
//         );
//
//         await GoogleSheetService.updateStockAfterPurchase(purchaseItems);
//
//         showCustomSnackbar(
//           title: "Success",
//           message: "Purchase created successfully!",
//           baseColor: Colors.green.shade700,
//           icon: Icons.check_circle_outline,
//         );
//
//         clearForm();
//         Get.back(result: true);
//         return true;
//       }
//
//     } catch (e) {
//       print("❌ Error saving purchase: $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to save purchase: ${e.toString()}",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error,
//       );
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void clearForm() {
//     formKey.currentState?.reset();
//     purchaseItems.clear();
//     clearVendorSelection();
//     notesController.clear();
//     paymentStatus.value = 'Pending';
//     calculateTotals();
//
//     initializePurchase();
//   }
//
//   String formatCurrency(double amount) {
//     return amount.toStringAsFixed(2);
//   }
// }


///19-10 work
// class PurchaseEntryController extends BaseController {
//   // Form controllers
//   final formKey = GlobalKey<FormState>();
//   final vendorNameController = TextEditingController();
//   final vendorMobileController = TextEditingController();
//   final vendorEmailController = TextEditingController();
//   final vendorAddressController = TextEditingController();
//   final purchaseNumberController = TextEditingController();
//   final purchaseDateController = TextEditingController();
//   final notesController = TextEditingController();
//
//   // Observable variables - Changed from vendors to customers
//   var selectedVendor = Rxn<Map<String, dynamic>>();
//   var customers = <Map<String, dynamic>>[].obs; // Changed from vendors
//   var itemList = <Item>[].obs;
//   var purchaseList = <PurchaseEntry>[].obs;
//   var purchaseItems = <PurchaseItem>[].obs;
//   var purchaseDate = DateTime.now().obs;
//   var showVendorForm = false.obs;
//   var vendorCount = 0.obs;
//   final RxString selectedVendorId = ''.obs;
//
//   // Calculation observables
//   var subtotal = 0.0.obs;
//   var paymentStatus = 'Pending'.obs;
//   var totalAmount = 0.0.obs;
//   var gstAmount = 0.0.obs;
//   var companyData = <String, dynamic>{}.obs;
//
//   // Firebase instances
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Edit mode variables
//   final RxBool isEditMode = false.obs;
//   final RxString editingPurchaseId = ''.obs;
//   final Rxn<Map<String, dynamic>> originalPurchaseData = Rxn<Map<String, dynamic>>();
//   final RxInt originalItemsCount = 0.obs;
//
//   /// Add item selection mode
//   var useItemMaster = true.obs; // Toggle between modes
//
//   final List<String> unitOptions = [
//     'pcs', 'kg', 'ltr', 'ml', 'mtr', 'cm', 'ft', 'inch', 'box', 'pack', 'dozen'
//   ];
//
//   @override
//   void onInit() {
//     super.onInit();
//     _handleArguments();
//
//     if (!isEditMode.value) {
//       initializePurchase();
//     } else {
//       if (purchaseItems.isEmpty) {
//         addNewItem();
//       }
//     }
//
//     Future.microtask(() {
//       loadCompanyData();
//       loadCustomersAsVendors(); // Changed method name
//       fetchItems();
//     });
//   }
//
//   void _handleArguments() {
//     print("🔍 Starting _handleArguments...");
//
//     final arguments = Get.arguments;
//     print("📥 Raw arguments: $arguments");
//
//     if (arguments is PurchaseEntry) {
//       print("🏷️ Arguments is directly a PurchaseEntry object");
//       isEditMode.value = true;
//       editingPurchaseId.value = arguments.purchaseId ?? '';
//
//       try {
//         originalPurchaseData.value = _purchaseToMap(arguments);
//         _prefillPurchaseData();
//       } catch (e, stackTrace) {
//         print("❌ Error processing direct PurchaseEntry: $e");
//         print("📄 Stack trace: $stackTrace");
//       }
//     } else if (arguments != null && arguments is Map) {
//       if (arguments['editMode'] == true) {
//         isEditMode.value = true;
//         editingPurchaseId.value = arguments['purchaseId']?.toString() ?? '';
//
//         if (arguments['purchaseData'] != null) {
//           if (arguments['purchaseData'] is PurchaseEntry) {
//             final purchaseObj = arguments['purchaseData'] as PurchaseEntry;
//             try {
//               originalPurchaseData.value = _purchaseToMap(purchaseObj);
//               _prefillPurchaseData();
//             } catch (e, stackTrace) {
//               print("❌ Error converting PurchaseEntry to Map: $e");
//             }
//           } else if (arguments['purchaseData'] is Map) {
//             try {
//               originalPurchaseData.value = Map<String, dynamic>.from(arguments['purchaseData'] as Map);
//               _prefillPurchaseData();
//             } catch (e, stackTrace) {
//               print("❌ Error processing Map data: $e");
//             }
//           }
//         }
//       }
//     }
//
//     print("🏁 Finished _handleArguments");
//     print("📊 Final state: isEditMode=${isEditMode.value}, editingPurchaseId='${editingPurchaseId.value}'");
//   }
//
//   Map<String, dynamic> _purchaseToMap(PurchaseEntry purchase) {
//     return {
//       'purchaseId': purchase.purchaseId,
//       'vendorId': purchase.vendorId,
//       'vendorName': purchase.vendorName,
//       'vendorEmail': purchase.vendorEmail,
//       'vendorMobile': purchase.vendorMobile,
//       'vendorAddress': purchase.vendorAddress,
//       'purchaseDate': purchase.purchaseDate,
//       'subtotal': purchase.subtotal,
//       'gstAmount': purchase.gstAmount,
//       'totalAmount': purchase.totalAmount,
//       'paymentStatus': purchase.paymentStatus,
//       'notes': purchase.notes,
//     };
//   }
//
//   void _prefillPurchaseData() {
//     print("🔄 Starting _prefillPurchaseData...");
//
//     final purchaseData = originalPurchaseData.value;
//     if (purchaseData != null) {
//       print("📋 Prefilling with data: $purchaseData");
//
//       purchaseNumberController.text = purchaseData['purchaseId']?.toString() ?? '';
//
//       if (purchaseData['purchaseDate'] != null) {
//         if (purchaseData['purchaseDate'] is DateTime) {
//           purchaseDateController.text = _formatDate(purchaseData['purchaseDate'] as DateTime);
//           purchaseDate.value = purchaseData['purchaseDate'] as DateTime;
//         } else if (purchaseData['purchaseDate'] is String) {
//           purchaseDateController.text = purchaseData['purchaseDate'] as String;
//           try {
//             purchaseDate.value = DateTime.parse(purchaseData['purchaseDate'] as String);
//           } catch (e) {
//             print('Could not parse date string: ${purchaseData['purchaseDate']}');
//           }
//         }
//       }
//
//       vendorNameController.text = purchaseData['vendorName']?.toString() ?? '';
//       vendorMobileController.text = purchaseData['vendorMobile']?.toString() ?? '';
//       vendorEmailController.text = purchaseData['vendorEmail']?.toString() ?? '';
//       vendorAddressController.text = purchaseData['vendorAddress']?.toString() ?? '';
//
//       if (purchaseData['vendorId'] != null && purchaseData['vendorId'].toString().isNotEmpty) {
//         selectedVendorId.value = purchaseData['vendorId'].toString();
//         print("🆔 Restored vendor ID: ${selectedVendorId.value}");
//       }
//
//       paymentStatus.value = purchaseData['paymentStatus']?.toString() ?? 'Pending';
//       notesController.text = purchaseData['notes']?.toString() ?? '';
//
//       if (purchaseData['subtotal'] != null) {
//         subtotal.value = double.tryParse(purchaseData['subtotal'].toString()) ?? 0.0;
//       }
//       if (purchaseData['gstAmount'] != null) {
//         gstAmount.value = double.tryParse(purchaseData['gstAmount'].toString()) ?? 0.0;
//       }
//       if (purchaseData['totalAmount'] != null) {
//         totalAmount.value = double.tryParse(purchaseData['totalAmount'].toString()) ?? 0.0;
//       }
//
//       _loadExistingPurchaseItems();
//     }
//   }
//
//   void _loadExistingPurchaseItems() async {
//     if (editingPurchaseId.value.isEmpty) {
//       print("⚠️ No editing purchase ID, skipping item load");
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//       print("📦 Loading existing items for purchase: ${editingPurchaseId.value}");
//
//       final existingItems = await GoogleSheetService.getPurchaseItemsByPurchaseId(editingPurchaseId.value);
//
//       originalItemsCount.value = existingItems.length;
//       print("📊 Found ${existingItems.length} existing items");
//
//       purchaseItems.clear();
//       for (var item in existingItems) {
//         print("📦 Loading item: ${item.itemName}");
//         purchaseItems.add(PurchaseItem(
//           vendorId: item.vendorId ?? '',
//           itemId: item.itemId ?? '',
//           itemName: item.itemName ?? '',
//           description: item.description ?? '',
//           quantity: item.quantity ?? 1,
//           purchasePrice: item.purchasePrice ?? 0.0,
//           unit: item.unit ?? 'pcs',
//           totalPrice: item.totalPrice ?? 0.0,
//           gstRate: item.gstRate ?? 0.0,
//           createdAt: item.createdAt ?? DateTime.now(),
//         ));
//       }
//
//       calculateTotals();
//       print('✅ Loaded ${existingItems.length} existing items for editing');
//
//     } catch (e) {
//       print('❌ Error loading existing items: $e');
//       Get.snackbar('Error', 'Failed to load existing items');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   @override
//   void onClose() {
//     vendorNameController.dispose();
//     vendorMobileController.dispose();
//     vendorEmailController.dispose();
//     vendorAddressController.dispose();
//     purchaseNumberController.dispose();
//     purchaseDateController.dispose();
//     notesController.dispose();
//     super.onClose();
//   }
//
//   void initializePurchase() async {
//     print("🆕 INITIALIZING NEW PURCHASE");
//
//     if (isEditMode.value) {
//       print("⚠️ In edit mode, skipping new purchase initialization");
//       return;
//     }
//
//     final lastPurchase = await getLastPurchase();
//     String newId = generatePurchaseIdFromLast(lastPurchase);
//
//     purchaseNumberController.text = newId;
//     purchaseDateController.text = _formatDate(purchaseDate.value);
//
//     if (purchaseItems.isEmpty) {
//       addNewItem();
//     }
//
//     print("✅ NEW PURCHASE INITIALIZATION COMPLETE - ID: $newId");
//   }
//
//   String generatePurchaseIdFromLast(PurchaseEntry? lastPurchase) {
//     if (lastPurchase == null || lastPurchase.purchaseId == null) return "PUR001";
//
//     RegExp regex = RegExp(r'^PUR(\d+)$', caseSensitive: false);
//     final match = regex.firstMatch(lastPurchase.purchaseId!);
//     if (match == null) return "PUR001";
//
//     int number = int.tryParse(match.group(1) ?? "0") ?? 0;
//     return "PUR${(number + 1).toString().padLeft(3, '0')}";
//   }
//
//   Future<PurchaseEntry?> getLastPurchase() async {
//     List<PurchaseEntry> purchases = await GoogleSheetService.getPurchasesList();
//     if (purchases.isEmpty) return null;
//
//     purchases.sort((a, b) => (a.purchaseId ?? '').compareTo(b.purchaseId ?? ''));
//     return purchases.last;
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
//         print("Company data loaded");
//       }
//     } catch (e) {
//       print("Error loading company data: $e");
//     }
//   }
//
//   // Changed method name from loadVendors to loadCustomersAsVendors
//   Future<void> loadCustomersAsVendors() async {
//     try {
//       isLoading.value = true;
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       print("Company ID: $companyId");
//
//       // Changed collection from "vendors" to "customers"
//       final customersSnapshot = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers") // Changed from vendors
//           .get();
//
//       customers.clear();
//
//       for (var doc in customersSnapshot.docs) {
//         final data = doc.data();
//         bool isActive = data['isActive'] ?? true;
//
//         if (isActive) {
//           data['id'] = doc.id;
//           // Map customer fields to vendor fields
//           data['vendorId'] = data['customerId'] ?? doc.id;
//           customers.add(data);
//           print("Added active customer as vendor: ${data['name']} (ID: ${doc.id})");
//         }
//       }
//
//       vendorCount.value = customers.length;
//       print("Active Customer count (as vendors): ${vendorCount.value}");
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
//   Future<void> fetchItems() async {
//     try {
//       isLoading.value = true;
//       final userId = AppConstants.userId;
//
//       print("=== ATTEMPTING TO FETCH ITEMS FOR USER: $userId ===");
//
//       List<Item> items = await GoogleSheetService.getItems(userId: userId);
//
//       print("Final result: ${items.length} items found");
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
//   void selectVendor(Map<String, dynamic>? vendor) {
//     if (vendor == null) {
//       selectedVendor.value = null;
//       clearVendorSelection();
//       showVendorForm.value = false;
//       return;
//     }
//
//     bool isActive = vendor['isActive'] ?? true;
//     if (!isActive) {
//       Get.snackbar(
//         'Customer Inactive',
//         'This customer is currently inactive. Please select an active customer.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     selectedVendor.value = vendor;
//     vendorNameController.text = vendor['name'] ?? '';
//     vendorMobileController.text = vendor['mobile1'] ?? vendor['mobile'] ?? '';
//     vendorEmailController.text = vendor['email'] ?? '';
//     vendorAddressController.text = vendor['address'] ?? '';
//
//     selectedVendorId.value = vendor['vendorId'] ?? vendor['customerId'] ?? vendor['id'] ?? '';
//     showVendorForm.value = false;
//
//     print("Selected Active Customer as Vendor: ID: ${selectedVendorId.value}, Name: ${vendorNameController.text}");
//   }
//
//   void toggleVendorForm() {
//     showVendorForm.value = !showVendorForm.value;
//     if (showVendorForm.value) {
//       selectedVendor.value = null;
//       clearVendorSelection();
//     }
//   }
//
//   void clearVendorSelection() {
//     selectedVendor.value = null;
//     vendorNameController.clear();
//     vendorMobileController.clear();
//     vendorEmailController.clear();
//     vendorAddressController.clear();
//   }
//
//   void addNewItem() {
//     print("Adding new item in ${isEditMode.value ? 'EDIT' : 'CREATE'} mode");
//
//     String vendorId = _getValidVendorId();
//
//     if (vendorId.isEmpty && isEditMode.value) {
//       print("WARNING: Vendor ID is empty in edit mode!");
//       Get.snackbar(
//         'Error',
//         'Unable to determine vendor ID. Please reload the purchase.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     purchaseItems.add(PurchaseItem(
//       description: '',
//       quantity: 1,
//       purchasePrice: 0.0,
//       gstRate: 0.0,
//       itemId: '',
//       totalPrice: 0.0,
//       itemName: '',
//       vendorId: vendorId,
//       unit: 'pcs',
//       createdAt: DateTime.now(),
//     ));
//
//     print("Added new item with vendor ID: '$vendorId'");
//     print("Total items: ${purchaseItems.length}");
//
//     calculateTotals();
//   }
//
//   // Modified to handle manual item entry
//   void updateItem(int index, {
//     String? itemName,
//     String? description,
//     int? quantity,
//     double? purchasePrice,
//     String? unit,
//   }) {
//     if (index < purchaseItems.length) {
//       final item = purchaseItems[index];
//       purchaseItems[index] = PurchaseItem(
//         vendorId: item.vendorId,
//         itemName: itemName ?? item.itemName,
//         description: description ?? item.description,
//         quantity: quantity ?? item.quantity,
//         purchasePrice: purchasePrice ?? item.purchasePrice,
//         gstRate: item.gstRate,
//         itemId: item.itemId,
//         totalPrice: item.totalPrice,
//         unit: unit ?? item.unit,
//         createdAt: item.createdAt,
//       );
//       calculateTotals();
//     }
//   }
//
//   void removeItem(int index) {
//     if (purchaseItems.length > 1) {
//       purchaseItems.removeAt(index);
//       calculateTotals();
//     }
//   }
//
//   void updatePaymentStatus(String status) {
//     paymentStatus.value = status;
//   }
//
//   Future<void> selectPurchaseDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: purchaseDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null && picked != purchaseDate.value) {
//       purchaseDate.value = picked;
//       purchaseDateController.text = _formatDate(picked);
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }
//
//   String _getValidVendorId() {
//     String vendorId = '';
//
//     if (selectedVendorId.value.isNotEmpty) {
//       vendorId = selectedVendorId.value;
//     } else if (isEditMode.value && originalPurchaseData.value?['vendorId'] != null) {
//       vendorId = originalPurchaseData.value!['vendorId'].toString();
//       selectedVendorId.value = vendorId;
//     } else if (purchaseItems.isNotEmpty && purchaseItems.first.vendorId.isNotEmpty) {
//       vendorId = purchaseItems.first.vendorId;
//       selectedVendorId.value = vendorId;
//     } else if (vendorNameController.text.trim().isNotEmpty) {
//       vendorId = 'MANUAL_${vendorNameController.text.trim().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
//       selectedVendorId.value = vendorId;
//     }
//
//     return vendorId;
//   }
//
//   bool _validatePurchaseItems() {
//     if (purchaseItems.isEmpty) {
//       showCustomSnackbar(
//         title: "Validation Error",
//         message: "Please add at least one item to the purchase",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//       return false;
//     }
//
//     bool hasValidItem = purchaseItems.any((item) {
//       bool hasItemName = item.itemName != null && item.itemName!.isNotEmpty;
//       bool hasDescription = item.description != null && item.description!.isNotEmpty;
//       return hasItemName || hasDescription;
//     });
//
//     if (!hasValidItem) {
//       showCustomSnackbar(
//         title: "No Items Entered",
//         message: "Please enter at least one item name or description",
//         baseColor: Colors.orange.shade700,
//         icon: Icons.warning_amber_rounded,
//       );
//       return false;
//     }
//
//     bool hasInvalidQuantityOrPrice = purchaseItems.any((item) {
//       bool isValidItem = (item.itemName?.isNotEmpty ?? false) ||
//           (item.description?.isNotEmpty ?? false);
//
//       if (isValidItem) {
//         return item.quantity <= 0 || item.purchasePrice <= 0;
//       }
//       return false;
//     });
//
//     if (hasInvalidQuantityOrPrice) {
//       showCustomSnackbar(
//         title: "Invalid Item Data",
//         message: "All items must have quantity and price greater than 0",
//         baseColor: Colors.orange.shade700,
//         icon: Icons.warning_amber_rounded,
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   Map<String, dynamic> createPurchaseItemData(PurchaseItem item) {
//     String vendorId = item.vendorId;
//     if (vendorId.isEmpty) {
//       vendorId = _getValidVendorId();
//     }
//
//     String formattedDate = _formatDate(purchaseDate.value);
//
//     return {
//       'purchaseId': purchaseNumberController.text,
//       'vendorId': vendorId,
//       'itemId': item.itemId ?? '',
//       'itemName': item.itemName ?? '',
//       'description': item.description ?? '',
//       'quantity': item.quantity.toString(),
//       'purchasePrice': item.purchasePrice.toString(),
//       'purchaseDate': formattedDate,
//       'gstRate': item.gstRate.toString(),
//       'totalPrice': item.totalPrice.toString(),
//       'unit': item.unit ?? 'pcs',
//       'userId': AppConstants.userId,
//     };
//   }
//
//   void calculateTotals() {
//     double sub = 0.0;
//     double gst = 0.0;
//
//     for (var i = 0; i < purchaseItems.length; i++) {
//       final item = purchaseItems[i];
//       final itemTotal = item.purchasePrice * item.quantity;
//
//       double gstForItem = 0.0;
//       double withGst = itemTotal;
//
//       if (AppConstants.withGST.value) {
//         gstForItem = itemTotal * (item.gstRate / 100);
//         withGst = itemTotal + gstForItem;
//       }
//
//       purchaseItems[i] = item.copyWith(
//         totalPrice: withGst,
//       );
//
//       sub += itemTotal;
//       gst += gstForItem;
//     }
//
//     subtotal.value = sub;
//     gstAmount.value = gst;
//     totalAmount.value = AppConstants.withGST.value ? sub + gst : sub;
//
//     print("Calculated totals: Subtotal=${sub}, GST=${gst}, Total=${totalAmount.value}");
//   }
//
//   Future<bool> savePurchase() async {
//     try {
//       if (vendorNameController.text.trim().isEmpty) {
//         showCustomSnackbar(
//           title: "Vendor Required",
//           message: "Please select a customer or enter vendor details",
//           baseColor: Colors.red.shade700,
//           icon: Icons.store_outlined,
//         );
//         return false;
//       }
//
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
//       if (!_validatePurchaseItems()) {
//         return false;
//       }
//
//       isLoading.value = true;
//       calculateTotals();
//
//       String finalVendorId = _getValidVendorId();
//
//       if (finalVendorId.isEmpty) {
//         isLoading.value = false;
//         showCustomSnackbar(
//           title: "Vendor ID Error",
//           message: "Unable to determine vendor ID. Please try again.",
//           baseColor: Colors.red.shade700,
//           icon: Icons.error_outline,
//         );
//         return false;
//       }
//
//       final purchaseId = purchaseNumberController.text;
//
//       Map<String, dynamic> purchaseData = {
//         'purchaseId': purchaseId,
//         'purchaseDate': _formatDate(purchaseDate.value),
//         'vendorId': finalVendorId,
//         'vendorName': vendorNameController.text.trim(),
//         'vendorMobile': vendorMobileController.text.trim(),
//         'vendorEmail': vendorEmailController.text.trim(),
//         'vendorAddress': vendorAddressController.text.trim(),
//         'subtotal': subtotal.value,
//         'gstRate': purchaseItems.isNotEmpty ? purchaseItems.first.gstRate : 0.0,
//         'gstAmount': gstAmount.value,
//         'totalAmount': totalAmount.value,
//         'paymentStatus': paymentStatus.value,
//         'notes': notesController.text,
//         'userId': AppConstants.userId,
//       };
//
//       if (isEditMode.value && editingPurchaseId.value.isNotEmpty) {
//         print("=== UPDATING EXISTING PURCHASE ===");
//
//         await GoogleSheetService.updatePurchaseWithCacheClear(
//           purchaseData,
//           AppConstants.userId,
//         );
//
//         List<Map<String, dynamic>> itemsData =
//         purchaseItems.map((item) => createPurchaseItemData(item)).toList();
//
//         await GoogleSheetService.updatePurchaseItemsWithCacheClear(
//           purchaseId,
//           itemsData,
//           AppConstants.userId,
//         );
//
//         showCustomSnackbar(
//           title: "Success",
//           message: "Purchase updated successfully!",
//           baseColor: Colors.green.shade700,
//           icon: Icons.check_circle_outline,
//         );
//
//         Get.back(result: true);
//         return true;
//
//       } else {
//         print("=== CREATING NEW PURCHASE ===");
//
//         await GoogleSheetService.addPurchase(purchaseData, AppConstants.userId);
//
//         List<Map<String, dynamic>> itemsData =
//         purchaseItems.map((item) => createPurchaseItemData(item)).toList();
//
//         await GoogleSheetService.addPurchaseItemsBatch(
//           itemsData,
//           AppConstants.userId,
//         );
//
//         await GoogleSheetService.updateStockAfterPurchase(purchaseItems);
//
//         // 🆕 ADD THIS LINE - Sync items to Item master
//         await syncPurchaseItemsToMaster(purchaseItems);
//
//
//         showCustomSnackbar(
//           title: "Success",
//           message: "Purchase created successfully!",
//           baseColor: Colors.green.shade700,
//           icon: Icons.check_circle_outline,
//         );
//
//         clearForm();
//         Get.back(result: true);
//         return true;
//       }
//
//     } catch (e) {
//       print("❌ Error saving purchase: $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to save purchase: ${e.toString()}",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error,
//       );
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void clearForm() {
//     formKey.currentState?.reset();
//     purchaseItems.clear();
//     clearVendorSelection();
//     notesController.clear();
//     paymentStatus.value = 'Pending';
//     calculateTotals();
//
//     initializePurchase();
//   }
//
//   String formatCurrency(double amount) {
//     return amount.toStringAsFixed(2);
//   }
//
//   // Add this method to your PurchaseEntryController class
//
//   /// Sync purchase items to Item master
//   Future<void> syncPurchaseItemsToMaster(List<PurchaseItem> items) async {
//     try {
//       print("🔄 Syncing ${items.length} items to Item master...");
//
//
//       int addedCount = 0;
//       int skippedCount = 0;
//
//
//       for (var purchaseItem in items) {
//         // ✅ FIX: Add check for empty itemName
//         if (purchaseItem.itemName == null || purchaseItem.itemName!.isEmpty) {
//           print("⚠️ Skipping item with empty name");
//           continue;
//         }
//
//
//         // Skip if item already has an itemId (already in master)
//         if (purchaseItem.itemId != null && purchaseItem.itemId!.isNotEmpty) {
//           print("✓ Item ${purchaseItem.itemName} already in master (ID: ${purchaseItem.itemId})");
//           continue;
//         }
//
//         // Check if item with same name already exists
//         final existingItem = itemList.firstWhereOrNull(
//               (item) => item.itemName.toLowerCase() == purchaseItem.itemName.toLowerCase(),
//         );
//
//         if (existingItem != null) {
//           print("✓ Item ${purchaseItem.itemName} already exists in master");
//           // Update the purchaseItem with the existing itemId
//           continue;
//         }
//
//         // Prepare new item with validation
//         final newItemId = 'ITM_${DateTime.now().millisecondsSinceEpoch}_${purchaseItem.itemName.hashCode.abs()}';
//
//         // Create new item for master
//         final newItem = Item(
//           itemId: newItemId,
//           itemName: purchaseItem.itemName,
//           price: purchaseItem.purchasePrice, // Use purchase price as initial price
//           gstPercent: purchaseItem.gstRate,
//           unitOfMeasurement: purchaseItem.unit,
//           currentStock: purchaseItem.quantity, // Add purchased quantity to stock
//           detailRequirement: purchaseItem.description ?? '',
//           isActive: true,
//         );
//
//         try {
//           // Add to Google Sheets
//           await GoogleSheetService.addItem(AppConstants.userId, newItem);
//           itemList.add(newItem);
//
//           print("✅ Added '${newItem.itemName}' to Item master");
//
//           showCustomSnackbar(
//             title: "Item Added",
//             message: "${newItem.itemName} added to inventory master",
//             baseColor: Colors.green.shade700,
//             icon: Icons.check_circle_outline,
//           );
//           addedCount++;
//         } catch (e) {
//           print("❌ Failed to add ${purchaseItem.itemName} to master: $e");
//           skippedCount++;
//         }
//       }
//
//       print("✅ Item sync completed - Added: $addedCount, Skipped: $skippedCount");
//       if (addedCount > 0) {
//         showCustomSnackbar(
//           title: "Sync Complete",
//           message: "$addedCount item(s) added to inventory master",
//           baseColor: Colors.blue.shade700,
//           icon: Icons.sync_outlined,
//         );
//       }
//     } catch (e) {
//       print("❌ Error syncing items: $e");
//       showCustomSnackbar(
//         title: "Sync Error",
//         message: "Error syncing items: $e",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//     }
//   }
//
//
//
// }

class PurchaseEntryController extends BaseController {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final vendorNameController = TextEditingController();
  final vendorMobileController = TextEditingController();
  final vendorEmailController = TextEditingController();
  final vendorAddressController = TextEditingController();
  final purchaseNumberController = TextEditingController();
  final purchaseDateController = TextEditingController();
  final notesController = TextEditingController();

  // Observable variables
  var selectedVendor = Rxn<Map<String, dynamic>>();
  var customers = <Map<String, dynamic>>[].obs;
  var itemList = <Item>[].obs;
  var purchaseList = <PurchaseEntry>[].obs;
  var purchaseItems = <PurchaseItem>[].obs;
  var purchaseDate = DateTime.now().obs;
  var showVendorForm = false.obs;
  var vendorCount = 0.obs;
  final RxString selectedVendorId = ''.obs;

  // ✅ NEW: Item entry mode toggle
  var useItemMaster = true.obs; // true = dropdown, false = manual

  // Calculation observables
  var subtotal = 0.0.obs;
  var paymentStatus = 'Pending'.obs;
  var totalAmount = 0.0.obs;
  var gstAmount = 0.0.obs;
  var companyData = <String, dynamic>{}.obs;

  // ✅ NEW: Add these fields to match Invoice structure
  var paidAmount = 0.0.obs;
  var pendingAmount = 0.0.obs;
  final paidAmountController = TextEditingController();

  // Date management (like Invoice)
  var paymentDueDate = DateTime.now().add(Duration(days: 15)).obs;
  final paymentDueDateController = TextEditingController();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Edit mode variables
  final RxBool isEditMode = false.obs;
  final RxString editingPurchaseId = ''.obs;
  final Rxn<Map<String, dynamic>> originalPurchaseData = Rxn<Map<String, dynamic>>();
  final RxInt originalItemsCount = 0.obs;

  final List<String> unitOptions = [
    'pcs', 'kg', 'ltr', 'ml', 'mtr', 'cm', 'ft', 'inch', 'box', 'pack', 'dozen'
  ];

  var priceControllers = <TextEditingController>[].obs;
  var gstControllers = <TextEditingController>[].obs;
  final Map<int, TextEditingController> qtyControllers = {};
  final Map<int, FocusNode> gstFocusNodes = {};

  @override
  void onInit() {
    super.onInit();
    // ✅ Initialize date controllers (like Invoice)
    purchaseDateController.text = _formatDateForDisplay(purchaseDate.value);
    paymentDueDateController.text = _formatDateForDisplay(paymentDueDate.value);

    _handleArguments();

    if (!isEditMode.value) {
      initializePurchase();
    } else {
      if (purchaseItems.isEmpty) {
        addNewItem();
      }
    }

    Future.microtask(() {
      loadCompanyData();
      loadCustomersAsVendors();
      fetchItems();
    });
  }

  void _handleArguments() {
    print("🔍 Starting _handleArguments...");
    final arguments = Get.arguments;

    if (arguments is PurchaseEntry) {
      isEditMode.value = true;
      editingPurchaseId.value = arguments.purchaseId ?? '';
      try {
        originalPurchaseData.value = _purchaseToMap(arguments);
        _prefillPurchaseData();
      } catch (e) {
        print("❌ Error processing PurchaseEntry: $e");
      }
    } else if (arguments != null && arguments is Map) {
      if (arguments['editMode'] == true) {
        isEditMode.value = true;
        editingPurchaseId.value = arguments['purchaseId']?.toString() ?? '';
        if (arguments['purchaseData'] != null) {
          if (arguments['purchaseData'] is PurchaseEntry) {
            final purchaseObj = arguments['purchaseData'] as PurchaseEntry;
            originalPurchaseData.value = _purchaseToMap(purchaseObj);
          } else if (arguments['purchaseData'] is Map) {
            originalPurchaseData.value = Map<String, dynamic>.from(arguments['purchaseData'] as Map);
          }
          _prefillPurchaseData();
        }
      }
    }
  }

  // ✅ NEW: Add date formatting methods (same as Invoice)
  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }


  Map<String, dynamic> _purchaseToMap(PurchaseEntry purchase) {
    return {
      'purchaseId': purchase.purchaseId,
      'vendorId': purchase.vendorId,
      'vendorName': purchase.vendorName,
      'vendorEmail': purchase.vendorEmail,
      'vendorMobile': purchase.vendorMobile,
      'vendorAddress': purchase.vendorAddress,
      'purchaseDate': purchase.purchaseDate,
      'subtotal': purchase.subtotal,
      'gstAmount': purchase.gstAmount,
      'totalAmount': purchase.totalAmount,
      'paymentStatus': purchase.paymentStatus,
      'notes': purchase.notes,
    };
  }

  void _prefillPurchaseData() {
    final purchaseData = originalPurchaseData.value;
    if (purchaseData != null) {
      purchaseNumberController.text = purchaseData['purchaseId']?.toString() ?? '';

      if (purchaseData['purchaseDate'] != null) {
        if (purchaseData['purchaseDate'] is DateTime) {
          purchaseDateController.text = _formatDate(purchaseData['purchaseDate'] as DateTime);
          purchaseDate.value = purchaseData['purchaseDate'] as DateTime;
        } else if (purchaseData['purchaseDate'] is String) {
          purchaseDateController.text = purchaseData['purchaseDate'] as String;
          try {
            purchaseDate.value = DateTime.parse(purchaseData['purchaseDate'] as String);
          } catch (e) {
            print('Could not parse date');
          }
        }
      }

      vendorNameController.text = purchaseData['vendorName']?.toString() ?? '';
      vendorMobileController.text = purchaseData['vendorMobile']?.toString() ?? '';
      vendorEmailController.text = purchaseData['vendorEmail']?.toString() ?? '';
      vendorAddressController.text = purchaseData['vendorAddress']?.toString() ?? '';

      if (purchaseData['vendorId'] != null) {
        selectedVendorId.value = purchaseData['vendorId'].toString();
      }

      paymentStatus.value = purchaseData['paymentStatus']?.toString() ?? 'Pending';
      notesController.text = purchaseData['notes']?.toString() ?? '';

      if (purchaseData['subtotal'] != null) {
        subtotal.value = double.tryParse(purchaseData['subtotal'].toString()) ?? 0.0;
      }
      if (purchaseData['gstAmount'] != null) {
        gstAmount.value = double.tryParse(purchaseData['gstAmount'].toString()) ?? 0.0;
      }
      if (purchaseData['totalAmount'] != null) {
        totalAmount.value = double.tryParse(purchaseData['totalAmount'].toString()) ?? 0.0;
      }

      _loadExistingPurchaseItems();
    }
  }

  void _loadExistingPurchaseItems() async {
    if (editingPurchaseId.value.isEmpty) return;

    try {
      isLoading.value = true;
      final existingItems = await GoogleSheetService.getPurchaseItemsByPurchaseId(editingPurchaseId.value);
      originalItemsCount.value = existingItems.length;

      purchaseItems.clear();
      for (var item in existingItems) {
        purchaseItems.add(PurchaseItem(
          vendorId: item.vendorId ?? '',
          itemId: item.itemId ?? '',
          itemName: item.itemName ?? '',
          description: item.description ?? '',
          quantity: item.quantity ?? 1,
          purchasePrice: item.purchasePrice ?? 0.0,
          unit: item.unit ?? 'pcs',
          totalPrice: item.totalPrice ?? 0.0,
          gstRate: item.gstRate ?? 0.0,
          createdAt: item.createdAt ?? DateTime.now(),
        ));
      }

      calculateTotals();
    } catch (e) {
      print('❌ Error loading items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    vendorNameController.dispose();
    vendorMobileController.dispose();
    vendorEmailController.dispose();
    vendorAddressController.dispose();
    purchaseNumberController.dispose();
    purchaseDateController.dispose();
    notesController.dispose();

    for (var controller in priceControllers) {
      controller.dispose();
    }
    priceControllers.clear();

    for (var controller in gstControllers) {
      controller.dispose();
    }
    gstControllers.clear();

    qtyControllers.forEach((key, controller) => controller.dispose());
    super.onClose();
  }

  void initializePurchase() async {
    if (isEditMode.value) return;

    try {
      final lastPurchase = await getLastPurchase();
      String newId = generatePurchaseIdFromLast(lastPurchase);

      purchaseNumberController.text = newId;
      purchaseDateController.text = _formatDate(purchaseDate.value);

      if (purchaseItems.isEmpty) {
        addNewItem();
      }
    } catch (e) {
      print("⚠️ Error initializing purchase: $e");
      // Fallback to default ID if sheet doesn't exist yet
      purchaseNumberController.text = "PUR001";
      purchaseDateController.text = _formatDate(purchaseDate.value);

      if (purchaseItems.isEmpty) {
        addNewItem();
      }
    }
  }

  TextEditingController getPriceController(int index, {double? initialValue}) {
    // Create controller if it doesn't exist

    while (priceControllers.length < purchaseItems.length) {
      final itemIndex = priceControllers.length;
      final item = purchaseItems[itemIndex];
      priceControllers.add(
        TextEditingController(text: item.purchasePrice.toStringAsFixed(2)), // ✅ int only
      );
    }
    while (priceControllers.length > purchaseItems.length) {
      priceControllers.removeLast().dispose();
    }

    if (initialValue != null &&
        priceControllers[index].text != initialValue.toInt().toString()) {
      priceControllers[index].text = initialValue.toInt().toString();
    }

    return priceControllers[index];
  }
  /// Get or create qty controller for specific index
  TextEditingController getQtyController(int index, {double? initialValue}) {
    // Create controller if it doesn't exist
    if (!qtyControllers.containsKey(index)) {
      qtyControllers[index] = TextEditingController();
    }

    // Get the current value
    final currentValue = initialValue ??
        (index < purchaseItems.length ? purchaseItems[index].quantity : 1.0);

    // Update controller text
    if (qtyControllers[index]!.text != currentValue.toString()) {
      qtyControllers[index]!.text = currentValue.toString();
    }

    return qtyControllers[index]!;
  }

  TextEditingController getGstController(int index, {double? initialValue}) {
    // Create controller if it doesn't exist

    while (gstControllers.length < purchaseItems.length) {
      final itemIndex = gstControllers.length;
      final item = purchaseItems[itemIndex];
      gstControllers.add(
        TextEditingController(text: item.gstRate.toStringAsFixed(2)), // ✅ int only
      );
    }
    while (gstControllers.length > purchaseItems.length) {
      gstControllers.removeLast().dispose();
    }

    if (initialValue != null &&
        gstControllers[index].text != initialValue.toString()) {
      gstControllers[index].text = initialValue.toString();
    }

    return gstControllers[index];
  }


  void _initializeItemControllers(int index, PurchaseItem item) {
    /// Create controllers if they don't exist


    if (!qtyControllers.containsKey(index)) {
      qtyControllers[index] = TextEditingController(
        text: item.quantity.toString(),
      );
    } else {
      // Update existing controller
      qtyControllers[index]!.text = item.quantity.toString();
    }


  }

  String generatePurchaseIdFromLast(PurchaseEntry? lastPurchase) {
    if (lastPurchase == null ||
        lastPurchase.purchaseId == null ||
        lastPurchase.purchaseId!.isEmpty) {
      print("✅ Generating first purchase ID: PUR001");
      return "PUR001";
    }

    RegExp regex = RegExp(r'^PUR(\d+)$', caseSensitive: false);
    final match = regex.firstMatch(lastPurchase.purchaseId!);

    if (match == null) {
      print("⚠️ Invalid purchase ID format, defaulting to PUR001");
      return "PUR001";
    }

    int number = int.tryParse(match.group(1) ?? "0") ?? 0;
    String newId = "PUR${(number + 1).toString().padLeft(3, '0')}";

    print("✅ Generated new purchase ID: $newId");
    return newId;
  }

  Future<PurchaseEntry?> getLastPurchase() async {
    try {
      List<PurchaseEntry> purchases = await GoogleSheetService.getPurchasesList();

      if (purchases.isEmpty) {
        print("ℹ️ No previous purchases found, starting with PUR001");
        return null;
      }

      purchases.sort((a, b) => (a.purchaseId ?? '').compareTo(b.purchaseId ?? ''));
      return purchases.last;

    } catch (e) {
      print("⚠️ Error fetching last purchase: $e");
      return null; // Return null to trigger PUR001
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

  // ✅ UPDATED: Refresh vendors list
  Future<void> refreshVendors() async {
    await loadCustomersAsVendors();
  }

  Future<void> loadCustomersAsVendors() async {
    try {
      isLoading.value = true;

      // ✅ Get userId from shared preferences
      String userId = await sharedPreferencesHelper.getPrefData("userId") ?? "";
      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";

      if (userId.isEmpty || companyId.isEmpty) {
        print("⚠️ Missing userId or companyId");
        showCustomSnackbar(
          title: "Setup Required",
          message: "Please complete your account setup",
          baseColor: Colors.orange.shade700,
          icon: Icons.warning,
        );
        return;
      }

      print("📋 Fetching customers for companyId: $companyId, userId: $userId");

      // ✅ Fetch customers from Google Sheets
      List<Map<String, dynamic>> customersFromSheet =
      await GoogleSheetService.getCustomers(
        companyId: companyId,
        userId: userId,
      );

      print("📊 Retrieved ${customersFromSheet.length} customers from Google Sheets");

      customers.clear();
      int creditorCount = 0;

      for (var customerData in customersFromSheet) {
        // ✅ Check if customer is active
        bool isActive = customerData['isActive']?.toString().toLowerCase() == 'true';

        // ✅ Check if customer is a Creditor
        bool isCreditor = customerData['sundryType']?.toString().toLowerCase() == 'creditors';

        if (isActive && isCreditor) {
          // ✅ Map customer data to expected format
          Map<String, dynamic> vendor = {
            'id': customerData['customerId'] ?? '',
            'vendorId': customerData['customerId'] ?? '',
            'customerId': customerData['customerId'] ?? '',
            'name': customerData['name'] ?? '',
            'mobile': customerData['mobile1'] ?? '',
            'mobile1': customerData['mobile1'] ?? '',
            'mobile2': customerData['mobile2'] ?? '',
            'email': customerData['email'] ?? '',
            'address': customerData['address'] ?? '',
            'city': customerData['city'] ?? '',
            'state': customerData['state'] ?? '',
            'country': customerData['country'] ?? '',
            'pincode': customerData['pincode'] ?? '',
            'gst': customerData['gst'] ?? '',
            'pan': customerData['pan'] ?? '',
            'businessName': customerData['businessName'] ?? '',
            'businessType': customerData['businessType'] ?? '',
            'sundryType': customerData['sundryType'] ?? '',
            'isActive': true,
          };

          customers.add(vendor);
          creditorCount++;
          print("✅ Added creditor vendor: ${vendor['name']} (${vendor['vendorId']})");
        } else if (isActive && !isCreditor) {
          print("⚠️ Skipped non-creditor customer: ${customerData['name']} (Type: ${customerData['sundryType']})");
        } else {
          print("⚠️ Skipped inactive customer: ${customerData['name']}");
        }
      }

      vendorCount.value = customers.length;
      print("✅ Loaded $creditorCount active creditor customers from Google Sheets");

      if (customers.isEmpty) {
        print("⚠️ No active creditor customers found.");
        showCustomSnackbar(
          title: "No Creditors Found",
          message: "No active creditor customers found. Please add creditor customers first.",
          baseColor: Colors.orange.shade700,
          icon: Icons.info_outline,
        );
      }

    } catch (e) {
      print("❌ Error loading customers from Google Sheets: $e");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to load customers: ${e.toString()}",
        baseColor: Colors.red.shade700,
        icon: Icons.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectVendor(Map<String, dynamic>? vendor) {
    if (vendor == null) {
      selectedVendor.value = null;
      clearVendorSelection();
      showVendorForm.value = false;
      return;
    }

    // ✅ Double-check if vendor is active
    bool isActive = vendor['isActive'] ?? true;
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

    // ✅ Double-check if vendor is a creditor
    bool isCreditor = vendor['sundryType']?.toString().toLowerCase() == 'creditors';
    if (!isCreditor) {
      Get.snackbar(
        'Invalid Vendor Type',
        'Please select a creditor customer for purchase entries.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    selectedVendor.value = vendor;
    vendorNameController.text = vendor['name'] ?? '';
    vendorMobileController.text = vendor['mobile1'] ?? vendor['mobile'] ?? '';
    vendorEmailController.text = vendor['email'] ?? '';
    vendorAddressController.text = vendor['address'] ?? '';
    selectedVendorId.value = vendor['vendorId'] ?? vendor['customerId'] ?? vendor['id'] ?? '';
    showVendorForm.value = false;

    print("✅ Selected Creditor Vendor:");
    print("   ID: ${selectedVendorId.value}");
    print("   Name: ${vendorNameController.text}");
    print("   Type: ${vendor['sundryType']}");
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true;
      List<Item> items = await GoogleSheetService.getItems(userId: AppConstants.userId);
      itemList.assignAll(items);
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      isLoading.value = false;
    }
  }



  void toggleVendorForm() {
    showVendorForm.value = !showVendorForm.value;
    if (showVendorForm.value) {
      selectedVendor.value = null;
      clearVendorSelection();
    }
  }

  void clearVendorSelection() {
    selectedVendor.value = null;
    vendorNameController.clear();
    vendorMobileController.clear();
    vendorEmailController.clear();
    vendorAddressController.clear();
  }

  // ✅ NEW: Toggle item entry mode
  void toggleItemEntryMode() {
    useItemMaster.value = !useItemMaster.value;
    print("Item entry mode: ${useItemMaster.value ? 'DROPDOWN' : 'MANUAL'}");
  }

  void addNewItem() {
    String vendorId = _getValidVendorId();
    int newIndex = purchaseItems.length;

    purchaseItems.add(PurchaseItem(
      description: '',
      quantity: 1,
      purchasePrice: 0.0,
      gstRate: 0.0,
      itemId: '',
      totalPrice: 0.0,
      itemName: '',
      vendorId: vendorId,
      unit: 'pcs',
      createdAt: DateTime.now(),
    ));

    // ✅ Initialize controllers for new item
    _initializeItemControllers(newIndex, purchaseItems[newIndex]);

    calculateTotals();
  }

  // Add this method to PurchaseEntryController after the selectVendor method

  // Replace selectItemForIndex() method in PurchaseEntryController with this:

  void selectItemForIndex(int index, Item item) {
    if (index >= purchaseItems.length) return;

    int existingIndex = -1;
    for (int i = 0; i < purchaseItems.length; i++) {
      if (i != index &&
          purchaseItems[i].itemId == item.itemId &&
          purchaseItems[i].itemId.isNotEmpty) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      final existingItem = purchaseItems[existingIndex];
      final currentQty = purchaseItems[index].quantity;

      purchaseItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + currentQty,
      );

      removeItem(index);

      Get.snackbar(
        "Item Merged",
        "Quantity added to existing ${item.itemName}. Total: ${existingItem.quantity + currentQty}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.tealColor.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
      );

      calculateTotals();
      return;
    }

    final currentItem = purchaseItems[index];
    String vendorId = _getValidVendorId();

    if (vendorId.isEmpty && isEditMode.value) {
      print("ERROR: Cannot select item in edit mode - no valid vendor ID found");
      Get.snackbar(
        'Error',
        'Vendor ID missing. Please reload the purchase entry.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    double gstRateToUse;
    if (isEditMode.value && currentItem.itemId.isNotEmpty) {
      gstRateToUse = currentItem.gstRate;
      print("✓ Edit mode: Preserving existing GST rate: $gstRateToUse");
    } else {
      gstRateToUse = item.gstPercent.toDouble();
      print("✓ Using item master GST rate: $gstRateToUse for ${item.itemName}");
    }

    purchaseItems[index] = PurchaseItem(
      vendorId: vendorId,
      itemId: item.itemId,
      itemName: item.itemName,
      description: item.itemName,
      quantity: currentItem.quantity,
      purchasePrice: item.price.toDouble(),
      gstRate: gstRateToUse,
      unit: item.unitOfMeasurement,
      totalPrice: currentItem.quantity * item.price.toDouble(),
      createdAt: currentItem.createdAt,
    );

    // ✅ NEW: Update controllers after item is selected
    _initializeItemControllers(index, purchaseItems[index]);

    print("✓ Updated item $index:");
    print("  - Name: ${purchaseItems[index].itemName}");
    print("  - Price: ${purchaseItems[index].purchasePrice}");
    print("  - GST: ${purchaseItems[index].gstRate}%");
    print("  - Unit: ${purchaseItems[index].unit}");

    calculateTotals();
  }

  (bool, String?) validateQuantity(String? unit, double quantity) {
    if (quantity <= 0) {
      return (false, "Quantity must be greater than 0");
    }

    // List of units that ONLY accept whole numbers
    final wholeNumberUnits = ['pcs', 'box', 'pack', 'dozen', 'piece', 'pieces'];

    // Check if unit requires whole numbers
    if (unit != null && wholeNumberUnits.contains(unit.toLowerCase())) {
      // For PCS units, only accept whole numbers
      if (quantity % 1 != 0) {
        return (
        false,
        "Only whole numbers allowed for $unit. You entered: $quantity"
        );
      }
    } else {
      // For kg, ltr, ml, mtr, cm, ft, inch - accept decimals
      // No validation needed, any positive number is valid
    }

    return (true, null);
  }


// Update the existing updateItem method to handle both dropdown and manual entry
  void removeItem(int index) {
    if (purchaseItems.length > 1) {
      // Remove the item
      purchaseItems.removeAt(index);

      // Dispose the controller at removed index
      priceControllers[index]?.dispose();
      qtyControllers[index]?.dispose();
      gstControllers[index]?.dispose();

      // Create new maps with reindexed controllers
      Map<int, TextEditingController> newPriceControllers = {};
      Map<int, TextEditingController> newQtyControllers = {};
      Map<int, TextEditingController> newGstControllers = {};

      // Reindex controllers after the removed index
      for (var i = 0; i < purchaseItems.length; i++) {
        if (i < index) {
          /// Keep controllers before removed index as-is
                    if (qtyControllers.containsKey(i)) {
            newQtyControllers[i] = qtyControllers[i]!;
          }

        } else {
          /// Shift controllers after removed index down by 1

          if (qtyControllers.containsKey(i + 1)) {
            newQtyControllers[i] = qtyControllers[i + 1]!;
          }

        }
      }

      // Replace old maps with reindexed ones
      priceControllers.clear();
      qtyControllers.clear();
      gstControllers.clear();

      qtyControllers.addAll(newQtyControllers);

      calculateTotals();
    }
  }

// Update updateItem to update controllers
  void updateItem(int index, {
    String? itemName,
    String? description,
    double? quantity,
    double? purchasePrice,
    String? unit,
    double? gstRate,
    String? itemId,
  }) {
    if (index < purchaseItems.length) {
      final item = purchaseItems[index];
      purchaseItems[index] = PurchaseItem(
        vendorId: item.vendorId,
        itemId: itemId ?? item.itemId,
        itemName: itemName ?? item.itemName,
        description: description ?? item.description,
        quantity: quantity ?? item.quantity,
        purchasePrice: purchasePrice ?? item.purchasePrice,
        gstRate: gstRate ?? item.gstRate,
        totalPrice: item.totalPrice,
        unit: unit ?? item.unit,
        createdAt: item.createdAt,
      );

      // ✅ Update controllers if values changed

      if (quantity != null && qtyControllers.containsKey(index)) {
        qtyControllers[index]!.text = quantity.toString();
      }

      calculateTotals();
    }
  }


  void updatePaymentStatus(String status) {
    paymentStatus.value = status;

    if (status == 'Paid') {
      paidAmount.value = totalAmount.value;
      paidAmountController.text = totalAmount.value.toString();
      pendingAmount.value = 0.0;
    } else if (status == 'Pending') {
      paidAmount.value = 0.0;
      paidAmountController.clear();
      pendingAmount.value = totalAmount.value;
    } else if (status == 'Partial') {
      pendingAmount.value = calculatedPendingAmount;
    }
  }

  double get calculatedPendingAmount {
    if (paymentStatus.value == 'Partial') {
      return totalAmount.value - paidAmount.value;
    } else if (paymentStatus.value == 'Paid') {
      return 0.0;
    } else {
      return totalAmount.value;
    }
  }

  void updatePaidAmount(String value) {
    double? amount = double.tryParse(value);
    if (amount != null && amount >= 0) {
      paidAmount.value = amount;
      pendingAmount.value = calculatedPendingAmount;

      if (amount > totalAmount.value) {
        Get.snackbar(
          'Invalid Amount',
          'Paid amount cannot exceed total amount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
        paidAmountController.text = totalAmount.value.toString();
        paidAmount.value = totalAmount.value;
        pendingAmount.value = 0.0;
      }
    }
  }

  Future<void> selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: purchaseDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      purchaseDate.value = picked;
      purchaseDateController.text = _formatDate(picked);
      /// Auto-calculate due date
      if (!isEditMode.value) {
        paymentDueDate.value = picked.add(Duration(days: 15));
        paymentDueDateController.text = _formatDate(paymentDueDate.value);
      }
    }
  }

  Future<void> selectPaymentDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: paymentDueDate.value,
      firstDate: purchaseDate.value,
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != paymentDueDate.value) {
      paymentDueDate.value = picked;
      paymentDueDateController.text = _formatDate(picked);
    }
  }



  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getValidVendorId() {
    String vendorId = '';

    if (selectedVendorId.value.isNotEmpty) {
      vendorId = selectedVendorId.value;
    } else if (isEditMode.value && originalPurchaseData.value?['vendorId'] != null) {
      vendorId = originalPurchaseData.value!['vendorId'].toString();
      selectedVendorId.value = vendorId;
    } else if (purchaseItems.isNotEmpty && purchaseItems.first.vendorId.isNotEmpty) {
      vendorId = purchaseItems.first.vendorId;
      selectedVendorId.value = vendorId;
    } else if (vendorNameController.text.trim().isNotEmpty) {
      vendorId = 'MANUAL_${vendorNameController.text.trim().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      selectedVendorId.value = vendorId;
    }

    return vendorId;
  }

  bool _validatePurchaseItems() {
    if (purchaseItems.isEmpty) {
      showCustomSnackbar(
        title: "Validation Error",
        message: "Please add at least one item",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
      return false;
    }

    bool hasValidItem = purchaseItems.any((item) {
      return (item.itemName != null && item.itemName!.isNotEmpty) ||
          (item.description != null && item.description!.isNotEmpty);
    });

    if (!hasValidItem) {
      showCustomSnackbar(
        title: "No Items Entered",
        message: "Please enter at least one item",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }

    bool hasInvalidData = purchaseItems.any((item) {
      bool isValidItem = (item.itemName?.isNotEmpty ?? false) ||
          (item.description?.isNotEmpty ?? false);
      if (isValidItem) {
        return item.quantity <= 0 || item.purchasePrice <= 0;
      }
      return false;
    });

    if (hasInvalidData) {
      showCustomSnackbar(
        title: "Invalid Item Data",
        message: "All items must have quantity and price greater than 0",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }

    return true;
  }

  Map<String, dynamic> createPurchaseItemData(PurchaseItem item) {
    String vendorId = item.vendorId;
    if (vendorId.isEmpty) {
      vendorId = _getValidVendorId();
    }

    return {
      'purchaseId': purchaseNumberController.text,
      'vendorId': vendorId,
      'itemId': item.itemId ?? '',
      'itemName': item.itemName ?? '',
      'description': item.description ?? '',
      'quantity': item.quantity.toString(),
      'purchasePrice': item.purchasePrice.toString(),
      'purchaseDate': _formatDate(purchaseDate.value),
      'gstRate': item.gstRate.toString(),
      'totalPrice': item.totalPrice.toString(),
      'unit': item.unit ?? 'pcs',
      'userId': AppConstants.userId,
    };
  }

  void calculateTotals() {
    double sub = 0.0;
    double gst = 0.0;

    for (var i = 0; i < purchaseItems.length; i++) {
      final item = purchaseItems[i];
      // ✅ quantity is already double, so multiplication works correctly
      final itemTotal = item.purchasePrice * item.quantity;

      double gstForItem = 0.0;
      double withGst = itemTotal;

      if (AppConstants.withGST.value) {
        gstForItem = itemTotal * (item.gstRate / 100);
        withGst = itemTotal + gstForItem;
      }

      purchaseItems[i] = item.copyWith(totalPrice: withGst);

      sub += itemTotal;
      gst += gstForItem;
    }

    subtotal.value = sub;
    gstAmount.value = gst;
    totalAmount.value = AppConstants.withGST.value ? sub + gst : sub;

    // ✅ Recalculate pending amount
    pendingAmount.value = calculatedPendingAmount;
  }

  Future<void> _createMissingItemsInItemMaster(List<PurchaseItem> items) async {
    print("🔄 Checking for manual items to add to Item master...");

    try {
      for (var purchaseItem in items) {
        // Skip if item already has an itemId (from dropdown)
        if (purchaseItem.itemId.isNotEmpty) {
          print("✓ Item has itemId, skipping: ${purchaseItem.itemName}");
          continue;
        }
        // Skip if item name is empty
        if (purchaseItem.itemName.trim().isEmpty) {
          print("⚠️ Skipping item with empty name");
          continue;
        }
        print("📝 Creating item in master: ${purchaseItem.itemName}");

        // Create new Item object for manual entry
        final newItem = Item(
          itemId: DateTime.now().millisecondsSinceEpoch.toString(),
          itemName: purchaseItem.itemName.trim(),
          price: purchaseItem.purchasePrice,
          gstPercent: purchaseItem.gstRate,
          unitOfMeasurement: purchaseItem.unit,
          currentStock: purchaseItem.quantity.toInt(),
          detailRequirement: purchaseItem.description.isNotEmpty
              ? "Auto-created from purchase: ${purchaseItem.description}"
              : "Auto-created from purchase entry",
          isActive: true,
        );

        // Add to Google Sheets Item table
        await GoogleSheetService.addItem(AppConstants.userId, newItem);

        print("✅ Item created: ${newItem.itemName} with ID: ${newItem.itemId}");
      }
    } catch (e) {
      print("❌ Error creating items in master: $e");
      showCustomSnackbar(
        title: "Warning",
        message: "Some manual items could not be added to item master",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
      );
    }
  }


  Future<bool> savePurchase() async {
    try {
      if (vendorNameController.text.trim().isEmpty) {
        showCustomSnackbar(
          title: "Vendor Required",
          message: "Please select a customer or enter vendor details",
          baseColor: Colors.red.shade700,
          icon: Icons.store_outlined,
        );
        return false;
      }

      if (!formKey.currentState!.validate()) return false;
      if (!_validatePurchaseItems()) return false;

      isLoading.value = true;
      calculateTotals();

      String finalVendorId = _getValidVendorId();
      if (finalVendorId.isEmpty) {
        isLoading.value = false;
        showCustomSnackbar(
          title: "Vendor ID Error",
          message: "Unable to determine vendor ID",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
        return false;
      }

      final purchaseId = purchaseNumberController.text;

      // ✅ UPDATED: Changed receivedAmount to paidAmount
      Map<String, dynamic> purchaseData = {
        'purchaseId': purchaseId,
        'purchaseDate': _formatDate(purchaseDate.value),
        'dueDate': _formatDate(paymentDueDate.value),
        'vendorId': finalVendorId,
        'vendorName': vendorNameController.text.trim(),
        'vendorMobile': vendorMobileController.text.trim(),
        'vendorEmail': vendorEmailController.text.trim(),
        'vendorAddress': vendorAddressController.text.trim(),
        'subtotal': subtotal.value,
        'gstRate': purchaseItems.isNotEmpty ? purchaseItems.first.gstRate : 0.0,
        'gstAmount': gstAmount.value,
        'totalAmount': totalAmount.value,
        'paidAmount': paidAmount.value,  // ✅ CHANGED
        'pendingAmount': pendingAmount.value,
        'paymentStatus': paymentStatus.value,
        'notes': notesController.text,
        'userId': AppConstants.userId,
      };

      if (isEditMode.value && editingPurchaseId.value.isNotEmpty) {
        await GoogleSheetService.updatePurchaseWithCacheClear(purchaseData, AppConstants.userId);

        List<Map<String, dynamic>> itemsData =
        purchaseItems.map((item) => createPurchaseItemData(item)).toList();

        await GoogleSheetService.updatePurchaseItemsWithCacheClear(
          purchaseId,
          itemsData,
          AppConstants.userId,
        );

        showCustomSnackbar(
          title: "Success",
          message: "Purchase updated successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );
      } else {
        await GoogleSheetService.addPurchase(purchaseData, AppConstants.userId);

        List<Map<String, dynamic>> itemsData =
        purchaseItems.map((item) => createPurchaseItemData(item)).toList();

        await GoogleSheetService.addPurchaseItemsBatch(itemsData, AppConstants.userId);

        await _createMissingItemsInItemMaster(purchaseItems);
        await GoogleSheetService.updateStockAfterPurchase(purchaseItems);

        showCustomSnackbar(
          title: "Success",
          message: "Purchase created successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );

        clearForm();
      }

      Get.back(result: true);
      return true;

    } catch (e) {
      print("❌ Error saving purchase: $e");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to save purchase: ${e.toString()}",
        baseColor: Colors.red.shade700,
        icon: Icons.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    formKey.currentState?.reset();
    purchaseItems.clear();
    clearVendorSelection();
    notesController.clear();
    paymentStatus.value = 'Pending';
    calculateTotals();
    initializePurchase();
  }
}