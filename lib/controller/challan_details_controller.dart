import 'package:demo_prac_getx/controller/bash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constant/constant.dart';
import '../model/model.dart';
import '../screen/screen.dart';
import '../services/service.dart';
import 'controller.dart';

///Noon @8-09- 4:25
// class ChallanDetailsController extends GetxController {
//   final challan = Rxn<Challan>();
//   final challanItems = <ChallanItem>[].obs;
//   final isLoading = false.obs;
//   final isLoadingItems = false.obs;
//   final isEditMode = false.obs;
//
//   late TextEditingController customerNameCtrl;
//   late TextEditingController customerEmailCtrl;
//   late TextEditingController customerPhoneCtrl;
//   late TextEditingController customerAddressCtrl;
//
//   /// Editable items: keys: "itemName", "qty", "rate"
//   var editableItems = <Map<String, TextEditingController>>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // init customer controllers
//     customerNameCtrl = TextEditingController();
//     customerEmailCtrl = TextEditingController();
//     customerPhoneCtrl = TextEditingController();
//     customerAddressCtrl = TextEditingController();
//
//     // get challan from arguments (must be passed when navigating)
//     final passedChallan = Get.arguments as Challan?;
//     if (passedChallan != null) {
//       challan.value = passedChallan;
//
//       // populate customer fields
//       customerNameCtrl.text = passedChallan.customerName ?? '';
//       customerEmailCtrl.text = passedChallan.customerEmail ?? '';
//       customerPhoneCtrl.text = passedChallan.customerMobile ?? '';
//       customerAddressCtrl.text = passedChallan.customerAddress ?? '';
//
//       // load challan items (async)
//       if ((passedChallan.challanId ?? '').isNotEmpty) {
//         loadChallanItems(passedChallan.challanId!);
//       }
//     }
//   }
//
//
//   // @override
//   // void onInit() {
//   //   super.onInit();
//   //
//   //   // init customer controllers
//   //   customerNameCtrl = TextEditingController();
//   //   customerEmailCtrl = TextEditingController();
//   //   customerPhoneCtrl = TextEditingController();
//   //   customerAddressCtrl = TextEditingController();
//   //   if (Get.arguments != null && Get.arguments is Challan) {
//   //     challan.value = Get.arguments as Challan;
//   //   }
//   //
//   //   // get challan from arguments (if any)
//   //   final Challan? passedChallan = Get.arguments as Challan?;
//   //   if (passedChallan != null) {
//   //     challan.value = passedChallan;
//   //
//   //     // populate customer fields
//   //     customerNameCtrl.text = passedChallan.customerName ?? '';
//   //     customerEmailCtrl.text = passedChallan.customerEmail ?? '';
//   //     customerPhoneCtrl.text = passedChallan.customerMobile ?? '';
//   //     customerAddressCtrl.text = passedChallan.customerAddress ?? '';
//   //
//   //     // load challan items (async)
//   //     if ((passedChallan.challanId ?? '').isNotEmpty) {
//   //       loadChallanItems(passedChallan.challanId!);
//   //     }
//   //   }
//   // }
//
//
//   @override
//   void onClose() {
//     // dispose customer controllers
//     customerNameCtrl.dispose();
//     customerEmailCtrl.dispose();
//     customerPhoneCtrl.dispose();
//     customerAddressCtrl.dispose();
//
//     // dispose item controllers
//     for (var m in editableItems) {
//       m['itemName']?.dispose();
//       m['qty']?.dispose();
//       m['rate']?.dispose();
//     }
//
//     super.onClose();
//   }
//
//   Future<void> loadChallanItems(String challanId) async {
//     try {
//       isLoadingItems.value = true;
//       final List<ChallanItem> items =
//       await GoogleSheetService.getChallanItemsByChallanId(challanId);
//
//       challanItems.assignAll(items);
//
//       _setupEditableItemsFromLoaded(items);
//     } catch (e, st) {
//       print('❌ Error loading challan items: $e\n$st');
//       Get.snackbar('Error', 'Failed to load challan items');
//     } finally {
//       isLoadingItems.value = false;
//     }
//   }
//
//   /// Refresh challan items
//   Future<void> refreshChallanItems() async {
//     if (challan.value == null) return;
//
//     isLoadingItems.value = true;
//     try {
//       final items = await GoogleSheetService.getChallanItemsByChallanId(
//         challan.value!.challanId!,
//       );
//       challanItems.assignAll(items);
//       _setupEditableItemsFromLoaded(items);
//
//       print("✅ Reloaded ${items.length} items for challan ${challan.value!.challanId}");
//     } catch (e) {
//       print("❌ Error refreshing challan items: $e");
//       Get.snackbar("Error", "Failed to refresh challan items");
//     } finally {
//       isLoadingItems.value = false;
//     }
//   }
//
//   void _setupEditableItemsFromLoaded(List<ChallanItem> items) {
//     // dispose previous
//     for (var m in editableItems) {
//       m['itemName']?.dispose();
//       m['qty']?.dispose();
//       m['rate']?.dispose();
//     }
//
//     final newList = <Map<String, TextEditingController>>[];
//
//     if (items.isNotEmpty) {
//       for (var item in items) {
//         newList.add({
//           'itemName': TextEditingController(text: item.itemName ?? ''),
//           'qty': TextEditingController(text: (item.quantity ?? 1).toString()),
//           'rate': TextEditingController(
//               text: (item.price ?? 0.0).toStringAsFixed(2)),
//         });
//       }
//     } else {
//       newList.add({
//         'itemName': TextEditingController(),
//         'qty': TextEditingController(text: '1'),
//         'rate': TextEditingController(text: '0.00'),
//       });
//     }
//
//     editableItems.value = newList;
//     editableItems.refresh();
//   }
//
//   void enterEditMode() {
//     if (editableItems.isEmpty) {
//       if (challanItems.isNotEmpty) {
//         _setupEditableItemsFromLoaded(challanItems);
//       } else {
//         addNewItem();
//       }
//     }
//     isEditMode.value = true;
//   }
//
//   void addNewItem() {
//     editableItems.add({
//       'itemName': TextEditingController(),
//       'qty': TextEditingController(text: '1'),
//       'rate': TextEditingController(text: '0.00'),
//     });
//     editableItems.refresh();
//   }
//
//   void removeItem(int index) {
//     if (index >= 0 && index < editableItems.length) {
//       editableItems[index]['itemName']?.dispose();
//       editableItems[index]['qty']?.dispose();
//       editableItems[index]['rate']?.dispose();
//       editableItems.removeAt(index);
//
//       if (editableItems.isEmpty) addNewItem();
//       editableItems.refresh();
//     }
//   }
//
//   double calculateItemTotal(int index) {
//     if (index < 0 || index >= editableItems.length) return 0.0;
//     final qtyText = editableItems[index]['qty']?.text ?? '0';
//     final rateText = editableItems[index]['rate']?.text ?? '0';
//     final qty = double.tryParse(qtyText) ?? 0.0;
//     final rate = double.tryParse(rateText) ?? 0.0;
//     return qty * rate;
//   }
//
//   double get calculatedTotal {
//     double t = 0.0;
//     for (int i = 0; i < editableItems.length; i++) {
//       t += calculateItemTotal(i);
//     }
//     return t;
//   }
//
//
//   /// Edit challan (show dialog and save)
//   Future<void> editChallan(BuildContext context, Challan c) async {
//     final nameCtrl = TextEditingController(text: c.customerName);
//     final emailCtrl = TextEditingController(text: c.customerEmail);
//     final phoneCtrl = TextEditingController(text: c.customerMobile);
//     final addressCtrl = TextEditingController(text: c.customerAddress);
//     final statusCtrl = TextEditingController(text: c.status ?? "Pending");
//
//     final formKey = GlobalKey<FormState>();
//
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Edit Challan"),
//         content: Form(
//           key: formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: nameCtrl,
//                   decoration: const InputDecoration(labelText: "Customer Name"),
//                   validator: (v) => v == null || v.isEmpty ? "Required" : null,
//                 ),
//                 TextFormField(
//                   controller: emailCtrl,
//                   decoration: const InputDecoration(labelText: "Customer Email"),
//                 ),
//                 TextFormField(
//                   controller: phoneCtrl,
//                   decoration: const InputDecoration(labelText: "Customer Phone"),
//                 ),
//                 TextFormField(
//                   controller: addressCtrl,
//                   decoration: const InputDecoration(labelText: "Customer Address"),
//                 ),
//                 TextFormField(
//                   controller: statusCtrl,
//                   decoration: const InputDecoration(labelText: "Status"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (!formKey.currentState!.validate()) return;
//
//               // Update challan model
//               final updated = c.copyWith(
//                 customerName: nameCtrl.text,
//                 customerEmail: emailCtrl.text,
//                 customerMobile: phoneCtrl.text,
//                 customerAddress: addressCtrl.text,
//                 status: statusCtrl.text,
//                 challanDate: c.challanDate ?? DateTime.now(),
//               );
//
//               try {
//                 // ✅ Update challan in Google Sheets
//                 await GoogleSheetService.updateChallan(updated.toMap(), AppConstants.userId);
//
//                 challan.value = updated; // update locally
//                 Get.back(); // close dialog
//                 Get.snackbar("Success", "Challan updated successfully");
//               } catch (e) {
//                 print("❌ Error updating challan: $e");
//                 Get.snackbar("Error", "Failed to update challan");
//               }
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }
//
// /// Fixed updateChallan function in your controller
// //   Future<void> updateChallan() async {
// //     try {
// //       final updatedChallan = challan.value;
// //       if (updatedChallan == null) throw Exception("No challan selected");
// //
// //       // Collect items
// //       final updatedItems = <ChallanItem>[];
// //       for (int i = 0; i < editableItems.length; i++) {
// //         final ctrls = editableItems[i];
// //
// //         final itemName = ctrls['itemName']?.text.trim() ?? '';
// //         final qty = double.tryParse(ctrls['qty']?.text ?? '0') ?? 0;
// //         final rate = double.tryParse(ctrls['rate']?.text ?? '0') ?? 0.0;
// //
// //         if (itemName.isEmpty && qty == 0 && rate == 0) continue;
// //
// //         final existingItemId = (i < challanItems.length)
// //             ? challanItems[i].itemId
// //             : DateTime.now().millisecondsSinceEpoch.toString();
// //
// //         updatedItems.add(ChallanItem(
// //           itemId: existingItemId,
// //           challanId: updatedChallan.challanId,
// //           itemName: itemName,
// //           quantity: qty,
// //           price: rate,
// //           totalPrice: qty * rate,
// //           description: itemName,
// //           customerId: '',
// //         ));
// //       }
// //
// //       // Calculate totals with proper GST handling
// //       final subtotal = updatedItems.fold<double>(0, (s, it) => s + (it.totalPrice ?? 0));
// //
// //       // Get GST rate from app constants or settings (default 18%)
// //       final gstRate =  18.0; // You might need to add this to AppConstants
// //       final gstAmount = AppConstants.withGST.value ? (subtotal * gstRate / 100) : 0.0;
// //       final total = subtotal + gstAmount;
// //
// //       final challanData = {
// //         'challanId': updatedChallan.challanId,
// //         'customerName': updatedChallan.customerName,
// //         'customerEmail': updatedChallan.customerEmail,
// //         'customerPhone': updatedChallan.customerMobile,
// //         'customerAddress': updatedChallan.customerAddress,
// //         'challanDate': DateFormat('dd/MM/yyyy').format(updatedChallan.challanDate!),
// //         'subtotal': subtotal.toStringAsFixed(2),
// //         'gstRate': gstRate.toStringAsFixed(2),           // Added GST rate
// //         'gstAmount': gstAmount.toStringAsFixed(2),       // Added GST amount
// //         'totalAmount': total.toStringAsFixed(2),
// //         'paymentStatus': updatedChallan.paymentStatus ?? 'Pending',
// //         'status':  updatedChallan.status ?? 'InProgress',  // or whatever status you want
// //       };
// //
// //       print("💰 Updating with: Subtotal: ${subtotal.toStringAsFixed(2)}, GST Rate: ${gstRate}%, GST Amount: ${gstAmount.toStringAsFixed(2)}, Total: ${total.toStringAsFixed(2)}");
// //
// //       // Update challan in Google Sheets
// //       await GoogleSheetService.updateChallan(challanData, AppConstants.userId);
// //
// //       // Update challan items in sheet
// //       await GoogleSheetService.updateChallanItems(
// //         updatedChallan.challanId!,
// //         updatedItems.map((e) => e.toMap()).toList(),
// //         AppConstants.userId,
// //       );
// //
// //       // Update local data
// //       challanItems.assignAll(updatedItems);
// //       challan.value = challan.value!.copyWith(
// //         subtotal: subtotal,
// //         // gstAmount: gstAmount,
// //         // totalAmount: total,
// //       );
// //
// //       isEditMode.value = false;
// //
// //       Get.snackbar("Success", "Challan updated successfully!");
// //     } catch (e, st) {
// //       print("❌ Error in updateChallan: $e\n$st");
// //       Get.snackbar("Error", "Failed to update challan: ${e.toString()}");
// //     }
// //   }
//
//   Future<void> updateChallan({bool preserveGSTRates = true}) async {
//     try {
//       final updatedChallan = challan.value;
//       if (updatedChallan == null) throw Exception("No challan selected");
//
//       print("🔄 Starting challan update process...");
//
//       // Collect items with better validation
//       final updatedItems = <ChallanItem>[];
//       for (int i = 0; i < editableItems.length; i++) {
//         final ctrls = editableItems[i];
//
//         final itemName = ctrls['itemName']?.text.trim() ?? '';
//         final qty = double.tryParse(ctrls['qty']?.text ?? '0') ?? 0;
//         final rate = double.tryParse(ctrls['rate']?.text ?? '0') ?? 0.0;
//
//         // Skip completely empty items
//         if (itemName.isEmpty && qty == 0 && rate == 0) {
//           print("⏭️ Skipping empty item at index $i");
//           continue;
//         }
//
//         final existingItemId = (i < challanItems.length)
//             ? challanItems[i].itemId
//             : DateTime.now().millisecondsSinceEpoch.toString();
//
//         final challanItem = ChallanItem(
//           itemId: existingItemId,
//           challanId: updatedChallan.challanId,
//           itemName: itemName,
//           quantity: qty,
//           price: rate,
//           totalPrice: qty * rate,
//           description: itemName,
//           customerId: updatedChallan.customerId ?? '',
//           unit: 'pcs', // Default unit, you can make this dynamic
//         );
//
//         updatedItems.add(challanItem);
//         print("📦 Added item: $itemName, Qty: $qty, Rate: $rate, Total: ${qty * rate}");
//       }
//
//       print("📊 Total items to update: ${updatedItems.length}");
//
//       // Calculate totals
//       final subtotal = updatedItems.fold<double>(0, (s, it) => s + (it.totalPrice ?? 0));
//       print("💰 Calculated subtotal: $subtotal");
//
//       double gstAmount;
//       double total;
//
//       if (preserveGSTRates) {
//         // Keep existing GST amount if preserving rates
//         gstAmount = updatedChallan.gstAmount ?? 0;
//         total = subtotal + gstAmount;
//         print("🔒 Preserving existing GST: $gstAmount");
//       } else {
//         // Recalculate GST based on current settings
//         final gstRate = 8.0; // Your GST rate
//         gstAmount = AppConstants.withGST.value ? (subtotal * gstRate / 100) : 0.0;
//         total = subtotal + gstAmount;
//         print("🔄 Recalculated GST: $gstAmount (Rate: $gstRate%)");
//       }
//
//       final challanData = {
//         'challanId': updatedChallan.challanId,
//         'customerName': updatedChallan.customerName,
//         'customerEmail': updatedChallan.customerEmail,
//         'customerPhone': updatedChallan.customerMobile,
//         'customerAddress': updatedChallan.customerAddress,
//         'challanDate': DateFormat('dd/MM/yyyy').format(updatedChallan.challanDate!),
//         'subtotal': subtotal.toStringAsFixed(2),
//         'gstAmount': gstAmount.toStringAsFixed(2),
//         'totalAmount': total.toStringAsFixed(2),
//         'status': updatedChallan.paymentStatus ?? 'Pending',
//         'statusProgress': 'InProgress',
//         'preserveGST': preserveGSTRates,
//       };
//
//       print("📤 Challan data prepared: ${challanData['challanId']}, Total: ${challanData['totalAmount']}");
//
//       // First update the challan
//       print("1️⃣ Updating challan in Google Sheets...");
//       await GoogleSheetService.updateChallan(challanData, AppConstants.userId);
//       print("✅ Challan updated successfully");
//
//       // Then update the challan items
//       print("2️⃣ Updating challan items in Google Sheets...");
//       final itemsData = updatedItems.map((item) {
//         final itemMap = item.toMap();
//         print("📦 Item map: $itemMap");
//         return itemMap;
//       }).toList();
//
//       await GoogleSheetService.updateChallanItems(
//         updatedChallan.challanId!,
//         itemsData,
//         AppConstants.userId,
//       );
//       print("✅ Challan items updated successfully");
//
//       // Update local data
//       challanItems.assignAll(updatedItems);
//       challan.value = challan.value!.copyWith(
//         subtotal: subtotal,
//         gstAmount: gstAmount,
//         //totalAmount: total,
//       );
//
//       isEditMode.value = false;
//
//       Get.snackbar(
//         "Success",
//         "Challan updated successfully!\nItems: ${updatedItems.length}, Total: ${total.toStringAsFixed(2)}",
//         backgroundColor: Colors.green.withOpacity(0.1),
//         colorText: Colors.green,
//         duration: Duration(seconds: 3),
//       );
//
//       print("🎉 Challan update process completed successfully");
//
//     } catch (e, st) {
//       print("❌ Error in updateChallan: $e");
//       print("📄 Stack trace: $st");
//
//       Get.snackbar(
//         "Error",
//         "Failed to update challan: ${e.toString()}",
//         backgroundColor: Colors.red.withOpacity(0.1),
//         colorText: Colors.red,
//         duration: Duration(seconds: 5),
//       );
//     }
//   }
//
// // Also add this method to check your ChallanItem.toMap() method is working correctly
//   void debugChallanItemMapping() {
//     print("🔍 Debugging ChallanItem mapping...");
//
//     for (int i = 0; i < challanItems.length; i++) {
//       final item = challanItems[i];
//       final itemMap = item.toMap();
//
//       print("Item $i:");
//       print("  - Object: ${item.toString()}");
//       print("  - Map: $itemMap");
//       print("  - Required fields:");
//       print("    challanId: ${itemMap['challanId']}");
//       print("    itemId: ${itemMap['itemId']}");
//       print("    itemName: ${itemMap['itemName']}");
//       print("    quantity: ${itemMap['quantity']}");
//       print("    price: ${itemMap['price']}");
//       print("    totalPrice: ${itemMap['totalPrice']}");
//     }
//   }
// }

// FIXED: ChallanDetailsController - Key improvements for data refresh

class ChallanDetailsController extends GetxController {
  final challan = Rxn<Challan>();
  final challanItems = <ChallanItem>[].obs;
  final isLoading = false.obs;
  final isLoadingItems = false.obs;

  var priceControllers = <TextEditingController>[].obs;
  var quantityControllers = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Get challan from arguments (must be passed when navigating)
    final passedChallan = Get.arguments as Challan?;
    if (passedChallan != null) {
      challan.value = passedChallan;

      // Load challan items (async)
      if ((passedChallan.challanId ?? '').isNotEmpty) {
        loadChallanItems(passedChallan.challanId!);
      }
    }
  }

  @override
  void onClose() {
    // Cleanup controllers
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    quantityControllers.clear();

    for (var controller in priceControllers) {
      controller.dispose();
    }
    priceControllers.clear();

    super.onClose();
  }

  void navigateToEditMode() async {
    final currentChallan = challan.value;
    if (currentChallan == null) {
      Get.snackbar('Error', 'No challan data available');
      return;
    }

    try {
      print("=== NAVIGATING TO EDIT MODE ===");

      // Cleanup existing controller
      if (Get.isRegistered<NewChallanController>()) {
        Get.delete<NewChallanController>(force: true);
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Register new controller
      Get.put(NewChallanController());

      final argumentsMap = {
        'editMode': true,
        'challanId': currentChallan.challanId,
        'challanData': currentChallan,
      };

      // Navigate and AWAIT result
      final result = await Get.to(
            () => NewChallanScreen(),
        arguments: argumentsMap,
        preventDuplicates: true,
      );

      print("=== RETURNED FROM EDIT ===");
      print("Result: $result");

      // ALWAYS refresh after returning (whether saved or cancelled)
      if (result == true) {
        // Give time for sheets to propagate
        await Future.delayed(Duration(milliseconds: 500));

        await forceRefreshChallanData();

        Get.snackbar(
          'Success',
          'Challan updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Still refresh in case of partial changes
        await forceRefreshChallanData();
      }

    } catch (e, stack) {
      print('❌ Navigation error: $e\n$stack');

      // Always try to refresh
      try {
        await forceRefreshChallanData();
      } catch (refreshError) {
        print('❌ Refresh error: $refreshError');
      }
    }
  }

  /// ENHANCED: Force refresh with proper cache clearing
  Future<void> forceRefreshChallanData() async {
    try {
      print("=== FORCE REFRESH CHALLAN DATA ===");

      final currentChallan = challan.value;
      if (currentChallan?.challanId == null) {
        print("No challan to refresh");
        return;
      }

      isLoadingItems.value = true;
      final challanId = currentChallan!.challanId!;

      // CRITICAL: Clear cache FIRST
      GoogleSheetService.clearChallanItemCache(challanId);

      print("Fetching fresh data for: $challanId");

      // Force fresh load (not from cache)
      final freshItems = await GoogleSheetService.getChallanItemsByChallanId(
          challanId
      );

      print("Received ${freshItems.length} fresh items");

      // Update items
      challanItems.clear();
      challanItems.assignAll(freshItems);

      // Force UI rebuild
      challanItems.refresh();
      update(); // Force GetX update

      print("✅ Refresh completed - ${challanItems.length} items loaded");

    } catch (e, stack) {
      print("❌ Error refreshing: $e\n$stack");
      Get.snackbar('Error', 'Failed to refresh data');
    } finally {
      isLoadingItems.value = false;
    }
  }


  /// Keep existing refreshChallanData for backward compatibility
  Future<void> refreshChallanData() async {
    await forceRefreshChallanData();
  }

  /// ENHANCED: Load challan details with fresh data
  Future<void> loadChallanDetails(String challanId) async {
    try {
      isLoading.value = true;
      print("Loading fresh challan details for ID: $challanId");

      await loadChallanItems(challanId);

      print("Challan details loaded successfully");
    } catch (e) {
      print('Error loading challan details: $e');
      Get.snackbar('Error', 'Failed to load challan details');
    } finally {
      isLoading.value = false;
    }
  }

  /// ENHANCED: Force load fresh items with better error handling
  Future<void> loadChallanItems(String challanId) async {
    try {
      isLoadingItems.value = true;
      print("🔄 Force loading fresh challan items for: $challanId");

      // Clear existing items first
      challanItems.clear();

      final List<ChallanItem> freshItems =
      await GoogleSheetService.getChallanItemsByChallanId(challanId);

      print("📦 Fetched ${freshItems.length} fresh items from Google Sheets");

      // Debug: Print each item's data
      for (var item in freshItems) {
        print("Fresh item: ${item.itemName} - Qty: ${item.quantity} - Price: ${item.price}");
      }

      // Assign fresh data
      challanItems.assignAll(freshItems);

      // Force UI update
      challanItems.refresh();

      print("✅ Successfully loaded and updated ${freshItems.length} items");

    } catch (e, st) {
      print('❌ Error loading challan items: $e\n$st');
      Get.snackbar('Error', 'Failed to load challan items: $e');
    } finally {
      isLoadingItems.value = false;
    }
  }

  /// ENHANCED: Manual refresh with user feedback
  Future<void> refreshChallanItems() async {
    if (challan.value == null) return;

    isLoadingItems.value = true;
    try {
      print("🔄 MANUAL REFRESH TRIGGERED");

      final items = await GoogleSheetService.getChallanItemsByChallanId(
        challan.value!.challanId!,
      );

      challanItems.assignAll(items);

      print("✅ Reloaded ${items.length} items for challan ${challan.value!.challanId}");
      Get.snackbar('Success', 'Items refreshed from server');
    } catch (e) {
      print("❌ Error refreshing challan items: $e");
      Get.snackbar("Error", "Failed to refresh challan items");
    } finally {
      isLoadingItems.value = false;
    }
  }

  /// Debug data flow method
  void debugDataFlow() async {
    print("=== DEBUGGING DATA FLOW ===");

    // Check controller registration
    print("Controllers registered:");
    print("  - ChallanListController: ${Get.isRegistered<ChallanListController>()}");
    print("  - ChallanDetailsController: ${Get.isRegistered<ChallanDetailsController>()}");

    // Check current data
    if (Get.isRegistered<ChallanListController>()) {
      final listController = Get.find<ChallanListController>();
      print("  - ChallanList count: ${listController.challanList.length}");
      print("  - FilteredList count: ${listController.filteredChallanList.length}");

      // Find current challan in the list
      final currentChallanInList = listController.challanList.firstWhereOrNull(
              (c) => c.challanId == challan.value?.challanId);

      if (currentChallanInList != null) {
        print("  - Current challan found in list");
        print("  - List challan customer: ${currentChallanInList.customerName}");
        print("  - Local challan customer: ${challan.value?.customerName}");
      } else {
        print("  - Current challan NOT found in list!");
      }
    }

    print("=== END DEBUG ===");
  }

  /// Download challan as PDF
  Future<void> downloadChallanPdf() async {
    try {
      isLoading.value = true;
      // Implement PDF download logic
      Get.snackbar('Success', 'PDF download started');
    } catch (e) {
      print('❌ Error downloading PDF: $e');
      Get.snackbar('Error', 'Failed to download PDF');
    } finally {
      isLoading.value = false;
    }
  }

  /// Share challan
  Future<void> shareChallan() async {
    try {
      final challanData = challan.value;
      if (challanData != null) {
        final shareText = '''
Challan Details:
ID: ${challanData.challanId}
Date: ${DateFormat('MMM dd, yyyy').format(challanData.challanDate!)}
Customer: ${challanData.customerName}
Total: ₹${challanData.totalAmount?.toStringAsFixed(2) ?? '0.00'}
Status: ${challanData.status}
''';

        Get.snackbar('Success', 'Challan shared successfully');
      }
    } catch (e) {
      print('❌ Error sharing challan: $e');
      Get.snackbar('Error', 'Failed to share challan');
    }
  }
}

/// morning 28-09
// class ChallanDetailsController extends GetxController {
//   final Rx<Challan?> challan = Rx<Challan?>(null);
//   final RxList<ChallanItem> challanItems = <ChallanItem>[].obs;
//   final RxBool isLoadingItems = false.obs;
//
//   /// Load challan details (called from binding or navigation)
//   void loadChallan(Challan c) {
//     challan.value = c;
//     refreshChallanItems();
//   }
//
//   /// Refresh challan items from Google Sheets
//   Future<void> refreshChallanItems() async {
//     if (challan.value == null) return;
//
//     isLoadingItems.value = true;
//     try {
//       final items = await GoogleSheetService.getChallan(
//         challan.value!.challanId!,
//         //AppConstants.userId,
//       );
//       challanItems.assignAll(items);
//       print("✅ Loaded ${items.length} items for challan ${challan.value!.challanId}");
//     } catch (e) {
//       print("❌ Error loading challan items: $e");
//       Get.snackbar("Error", "Failed to load challan items");
//     } finally {
//       isLoadingItems.value = false;
//     }
//   }
//
//   /// Edit challan (show dialog and save)
//   Future<void> editChallan(BuildContext context, Challan c) async {
//     final nameCtrl = TextEditingController(text: c.customerName);
//     final emailCtrl = TextEditingController(text: c.customerEmail);
//     final phoneCtrl = TextEditingController(text: c.customerMobile);
//     final addressCtrl = TextEditingController(text: c.customerAddress);
//     final statusCtrl = TextEditingController(text: c.status ?? "Pending");
//
//     final formKey = GlobalKey<FormState>();
//
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Edit Challan"),
//         content: Form(
//           key: formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: nameCtrl,
//                   decoration: const InputDecoration(labelText: "Customer Name"),
//                   validator: (v) => v == null || v.isEmpty ? "Required" : null,
//                 ),
//                 TextFormField(
//                   controller: emailCtrl,
//                   decoration: const InputDecoration(labelText: "Customer Email"),
//                 ),
//                 TextFormField(
//                   controller: phoneCtrl,
//                   decoration: const InputDecoration(labelText: "Customer Phone"),
//                 ),
//                 TextFormField(
//                   controller: addressCtrl,
//                   decoration: const InputDecoration(labelText: "Customer Address"),
//                 ),
//                 TextFormField(
//                   controller: statusCtrl,
//                   decoration: const InputDecoration(labelText: "Status"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (!formKey.currentState!.validate()) return;
//
//               // Update challan model
//               final updated = c.copyWith(
//                 customerName: nameCtrl.text,
//                 customerEmail: emailCtrl.text,
//                 customerMobile: phoneCtrl.text,
//                 customerAddress: addressCtrl.text,
//                 status: statusCtrl.text,
//                 challanDate: c.challanDate ?? DateTime.now(),
//               );
//
//               try {
//                 // ✅ Update challan in Google Sheets
//                 await GoogleSheetService.updateChallan(updated.toMap(), AppConstants.userId);
//
//                 challan.value = updated; // update locally
//                 Get.back(); // close dialog
//                 Get.snackbar("Success", "Challan updated successfully");
//               } catch (e) {
//                 print("❌ Error updating challan: $e");
//                 Get.snackbar("Error", "Failed to update challan");
//               }
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }
// }

