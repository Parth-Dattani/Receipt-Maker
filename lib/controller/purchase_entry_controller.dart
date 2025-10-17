
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  // Observable variables - Changed from vendors to customers
  var selectedVendor = Rxn<Map<String, dynamic>>();
  var customers = <Map<String, dynamic>>[].obs; // Changed from vendors
  var itemList = <Item>[].obs;
  var purchaseList = <PurchaseEntry>[].obs;
  var purchaseItems = <PurchaseItem>[].obs;
  var purchaseDate = DateTime.now().obs;
  var showVendorForm = false.obs;
  var vendorCount = 0.obs;
  final RxString selectedVendorId = ''.obs;

  // Calculation observables
  var subtotal = 0.0.obs;
  var paymentStatus = 'Pending'.obs;
  var totalAmount = 0.0.obs;
  var gstAmount = 0.0.obs;
  var companyData = <String, dynamic>{}.obs;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Edit mode variables
  final RxBool isEditMode = false.obs;
  final RxString editingPurchaseId = ''.obs;
  final Rxn<Map<String, dynamic>> originalPurchaseData = Rxn<Map<String, dynamic>>();
  final RxInt originalItemsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
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
      loadCustomersAsVendors(); // Changed method name
      fetchItems();
    });
  }

  void _handleArguments() {
    print("🔍 Starting _handleArguments...");

    final arguments = Get.arguments;
    print("📥 Raw arguments: $arguments");

    if (arguments is PurchaseEntry) {
      print("🏷️ Arguments is directly a PurchaseEntry object");
      isEditMode.value = true;
      editingPurchaseId.value = arguments.purchaseId ?? '';

      try {
        originalPurchaseData.value = _purchaseToMap(arguments);
        _prefillPurchaseData();
      } catch (e, stackTrace) {
        print("❌ Error processing direct PurchaseEntry: $e");
        print("📄 Stack trace: $stackTrace");
      }
    } else if (arguments != null && arguments is Map) {
      if (arguments['editMode'] == true) {
        isEditMode.value = true;
        editingPurchaseId.value = arguments['purchaseId']?.toString() ?? '';

        if (arguments['purchaseData'] != null) {
          if (arguments['purchaseData'] is PurchaseEntry) {
            final purchaseObj = arguments['purchaseData'] as PurchaseEntry;
            try {
              originalPurchaseData.value = _purchaseToMap(purchaseObj);
              _prefillPurchaseData();
            } catch (e, stackTrace) {
              print("❌ Error converting PurchaseEntry to Map: $e");
            }
          } else if (arguments['purchaseData'] is Map) {
            try {
              originalPurchaseData.value = Map<String, dynamic>.from(arguments['purchaseData'] as Map);
              _prefillPurchaseData();
            } catch (e, stackTrace) {
              print("❌ Error processing Map data: $e");
            }
          }
        }
      }
    }

    print("🏁 Finished _handleArguments");
    print("📊 Final state: isEditMode=${isEditMode.value}, editingPurchaseId='${editingPurchaseId.value}'");
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
    print("🔄 Starting _prefillPurchaseData...");

    final purchaseData = originalPurchaseData.value;
    if (purchaseData != null) {
      print("📋 Prefilling with data: $purchaseData");

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
            print('Could not parse date string: ${purchaseData['purchaseDate']}');
          }
        }
      }

      vendorNameController.text = purchaseData['vendorName']?.toString() ?? '';
      vendorMobileController.text = purchaseData['vendorMobile']?.toString() ?? '';
      vendorEmailController.text = purchaseData['vendorEmail']?.toString() ?? '';
      vendorAddressController.text = purchaseData['vendorAddress']?.toString() ?? '';

      if (purchaseData['vendorId'] != null && purchaseData['vendorId'].toString().isNotEmpty) {
        selectedVendorId.value = purchaseData['vendorId'].toString();
        print("🆔 Restored vendor ID: ${selectedVendorId.value}");
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
    if (editingPurchaseId.value.isEmpty) {
      print("⚠️ No editing purchase ID, skipping item load");
      return;
    }

    try {
      isLoading.value = true;
      print("📦 Loading existing items for purchase: ${editingPurchaseId.value}");

      final existingItems = await GoogleSheetService.getPurchaseItemsByPurchaseId(editingPurchaseId.value);

      originalItemsCount.value = existingItems.length;
      print("📊 Found ${existingItems.length} existing items");

      purchaseItems.clear();
      for (var item in existingItems) {
        print("📦 Loading item: ${item.itemName}");
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
      print('✅ Loaded ${existingItems.length} existing items for editing');

    } catch (e) {
      print('❌ Error loading existing items: $e');
      Get.snackbar('Error', 'Failed to load existing items');
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
    super.onClose();
  }

  void initializePurchase() async {
    print("🆕 INITIALIZING NEW PURCHASE");

    if (isEditMode.value) {
      print("⚠️ In edit mode, skipping new purchase initialization");
      return;
    }

    final lastPurchase = await getLastPurchase();
    String newId = generatePurchaseIdFromLast(lastPurchase);

    purchaseNumberController.text = newId;
    purchaseDateController.text = _formatDate(purchaseDate.value);

    if (purchaseItems.isEmpty) {
      addNewItem();
    }

    print("✅ NEW PURCHASE INITIALIZATION COMPLETE - ID: $newId");
  }

  String generatePurchaseIdFromLast(PurchaseEntry? lastPurchase) {
    if (lastPurchase == null || lastPurchase.purchaseId == null) return "PUR001";

    RegExp regex = RegExp(r'^PUR(\d+)$', caseSensitive: false);
    final match = regex.firstMatch(lastPurchase.purchaseId!);
    if (match == null) return "PUR001";

    int number = int.tryParse(match.group(1) ?? "0") ?? 0;
    return "PUR${(number + 1).toString().padLeft(3, '0')}";
  }

  Future<PurchaseEntry?> getLastPurchase() async {
    List<PurchaseEntry> purchases = await GoogleSheetService.getPurchasesList();
    if (purchases.isEmpty) return null;

    purchases.sort((a, b) => (a.purchaseId ?? '').compareTo(b.purchaseId ?? ''));
    return purchases.last;
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
        print("Company data loaded");
      }
    } catch (e) {
      print("Error loading company data: $e");
    }
  }

  // Changed method name from loadVendors to loadCustomersAsVendors
  Future<void> loadCustomersAsVendors() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      print("Company ID: $companyId");

      // Changed collection from "vendors" to "customers"
      final customersSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .collection("customers") // Changed from vendors
          .get();

      customers.clear();

      for (var doc in customersSnapshot.docs) {
        final data = doc.data();
        bool isActive = data['isActive'] ?? true;

        if (isActive) {
          data['id'] = doc.id;
          // Map customer fields to vendor fields
          data['vendorId'] = data['customerId'] ?? doc.id;
          customers.add(data);
          print("Added active customer as vendor: ${data['name']} (ID: ${doc.id})");
        }
      }

      vendorCount.value = customers.length;
      print("Active Customer count (as vendors): ${vendorCount.value}");

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

      List<Item> items = await GoogleSheetService.getItems(userId: userId);

      print("Final result: ${items.length} items found");

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

  void selectVendor(Map<String, dynamic>? vendor) {
    if (vendor == null) {
      selectedVendor.value = null;
      clearVendorSelection();
      showVendorForm.value = false;
      return;
    }

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

    selectedVendor.value = vendor;
    vendorNameController.text = vendor['name'] ?? '';
    vendorMobileController.text = vendor['mobile1'] ?? vendor['mobile'] ?? '';
    vendorEmailController.text = vendor['email'] ?? '';
    vendorAddressController.text = vendor['address'] ?? '';

    selectedVendorId.value = vendor['vendorId'] ?? vendor['customerId'] ?? vendor['id'] ?? '';
    showVendorForm.value = false;

    print("Selected Active Customer as Vendor: ID: ${selectedVendorId.value}, Name: ${vendorNameController.text}");
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

  void addNewItem() {
    print("Adding new item in ${isEditMode.value ? 'EDIT' : 'CREATE'} mode");

    String vendorId = _getValidVendorId();

    if (vendorId.isEmpty && isEditMode.value) {
      print("WARNING: Vendor ID is empty in edit mode!");
      Get.snackbar(
        'Error',
        'Unable to determine vendor ID. Please reload the purchase.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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

    print("Added new item with vendor ID: '$vendorId'");
    print("Total items: ${purchaseItems.length}");

    calculateTotals();
  }

  // Modified to handle manual item entry
  void updateItem(int index, {
    String? itemName,
    String? description,
    int? quantity,
    double? purchasePrice,
    String? unit,
  }) {
    if (index < purchaseItems.length) {
      final item = purchaseItems[index];
      purchaseItems[index] = PurchaseItem(
        vendorId: item.vendorId,
        itemName: itemName ?? item.itemName,
        description: description ?? item.description,
        quantity: quantity ?? item.quantity,
        purchasePrice: purchasePrice ?? item.purchasePrice,
        gstRate: item.gstRate,
        itemId: item.itemId,
        totalPrice: item.totalPrice,
        unit: unit ?? item.unit,
        createdAt: item.createdAt,
      );
      calculateTotals();
    }
  }

  void removeItem(int index) {
    if (purchaseItems.length > 1) {
      purchaseItems.removeAt(index);
      calculateTotals();
    }
  }

  void updatePaymentStatus(String status) {
    paymentStatus.value = status;
  }

  Future<void> selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: purchaseDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != purchaseDate.value) {
      purchaseDate.value = picked;
      purchaseDateController.text = _formatDate(picked);
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
        message: "Please add at least one item to the purchase",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
      return false;
    }

    bool hasValidItem = purchaseItems.any((item) {
      bool hasItemName = item.itemName != null && item.itemName!.isNotEmpty;
      bool hasDescription = item.description != null && item.description!.isNotEmpty;
      return hasItemName || hasDescription;
    });

    if (!hasValidItem) {
      showCustomSnackbar(
        title: "No Items Entered",
        message: "Please enter at least one item name or description",
        baseColor: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }

    bool hasInvalidQuantityOrPrice = purchaseItems.any((item) {
      bool isValidItem = (item.itemName?.isNotEmpty ?? false) ||
          (item.description?.isNotEmpty ?? false);

      if (isValidItem) {
        return item.quantity <= 0 || item.purchasePrice <= 0;
      }
      return false;
    });

    if (hasInvalidQuantityOrPrice) {
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

    String formattedDate = _formatDate(purchaseDate.value);

    return {
      'purchaseId': purchaseNumberController.text,
      'vendorId': vendorId,
      'itemId': item.itemId ?? '',
      'itemName': item.itemName ?? '',
      'description': item.description ?? '',
      'quantity': item.quantity.toString(),
      'purchasePrice': item.purchasePrice.toString(),
      'purchaseDate': formattedDate,
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
      final itemTotal = item.purchasePrice * item.quantity;

      double gstForItem = 0.0;
      double withGst = itemTotal;

      if (AppConstants.withGST.value) {
        gstForItem = itemTotal * (item.gstRate / 100);
        withGst = itemTotal + gstForItem;
      }

      purchaseItems[i] = item.copyWith(
        totalPrice: withGst,
      );

      sub += itemTotal;
      gst += gstForItem;
    }

    subtotal.value = sub;
    gstAmount.value = gst;
    totalAmount.value = AppConstants.withGST.value ? sub + gst : sub;

    print("Calculated totals: Subtotal=${sub}, GST=${gst}, Total=${totalAmount.value}");
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

      if (!formKey.currentState!.validate()) {
        showCustomSnackbar(
          title: "Validation Error",
          message: "Please fill all required fields",
          baseColor: Colors.orange.shade700,
          icon: Icons.warning,
        );
        return false;
      }

      if (!_validatePurchaseItems()) {
        return false;
      }

      isLoading.value = true;
      calculateTotals();

      String finalVendorId = _getValidVendorId();

      if (finalVendorId.isEmpty) {
        isLoading.value = false;
        showCustomSnackbar(
          title: "Vendor ID Error",
          message: "Unable to determine vendor ID. Please try again.",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
        return false;
      }

      final purchaseId = purchaseNumberController.text;

      Map<String, dynamic> purchaseData = {
        'purchaseId': purchaseId,
        'purchaseDate': _formatDate(purchaseDate.value),
        'vendorId': finalVendorId,
        'vendorName': vendorNameController.text.trim(),
        'vendorMobile': vendorMobileController.text.trim(),
        'vendorEmail': vendorEmailController.text.trim(),
        'vendorAddress': vendorAddressController.text.trim(),
        'subtotal': subtotal.value,
        'gstRate': purchaseItems.isNotEmpty ? purchaseItems.first.gstRate : 0.0,
        'gstAmount': gstAmount.value,
        'totalAmount': totalAmount.value,
        'paymentStatus': paymentStatus.value,
        'notes': notesController.text,
        'userId': AppConstants.userId,
      };

      if (isEditMode.value && editingPurchaseId.value.isNotEmpty) {
        print("=== UPDATING EXISTING PURCHASE ===");

        await GoogleSheetService.updatePurchaseWithCacheClear(
          purchaseData,
          AppConstants.userId,
        );

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

        Get.back(result: true);
        return true;

      } else {
        print("=== CREATING NEW PURCHASE ===");

        await GoogleSheetService.addPurchase(purchaseData, AppConstants.userId);

        List<Map<String, dynamic>> itemsData =
        purchaseItems.map((item) => createPurchaseItemData(item)).toList();

        await GoogleSheetService.addPurchaseItemsBatch(
          itemsData,
          AppConstants.userId,
        );

        await GoogleSheetService.updateStockAfterPurchase(purchaseItems);

        showCustomSnackbar(
          title: "Success",
          message: "Purchase created successfully!",
          baseColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );

        clearForm();
        Get.back(result: true);
        return true;
      }

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

  String formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }
}