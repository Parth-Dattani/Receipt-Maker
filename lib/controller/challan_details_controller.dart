import 'package:GetYourInvoice/controller/bash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constant/constant.dart';
import '../model/model.dart';
import '../screen/screen.dart';
import '../services/service.dart';
import 'controller.dart';



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

    /// ✅ CHECK IF CHALLAN IS IN PROGRESS STATUS
    // if (currentChallan.status?.toLowerCase() == 'progress') {
    //   Get.dialog(
    //     AlertDialog(
    //       title: Row(
    //         children: [
    //           Icon(Icons.lock, color: Colors.orange.shade700, size: 28),
    //           SizedBox(width: 12),
    //           Text('Challan Locked'),
    //         ],
    //       ),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(
    //             'This challan is currently in PROGRESS and cannot be edited.',
    //             style: TextStyle(fontSize: 16),
    //           ),
    //           SizedBox(height: 16),
    //           Container(
    //             padding: EdgeInsets.all(12),
    //             decoration: BoxDecoration(
    //               color: Colors.blue.shade50,
    //               borderRadius: BorderRadius.circular(8),
    //               border: Border.all(color: Colors.blue.shade200),
    //             ),
    //             child: Row(
    //               children: [
    //                 Icon(Icons.pending_actions, color: Colors.blue.shade700, size: 20),
    //                 SizedBox(width: 8),
    //                 Expanded(
    //                   child: Text(
    //                     'Status: PROGRESS',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       color: Colors.blue.shade800,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           SizedBox(height: 12),
    //           Text(
    //             'Challans in progress are locked because they have been converted to an invoice and are being processed.',
    //             style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
    //           ),
    //           SizedBox(height: 8),
    //           Container(
    //             padding: EdgeInsets.all(10),
    //             decoration: BoxDecoration(
    //               color: Colors.amber.shade50,
    //               borderRadius: BorderRadius.circular(6),
    //               border: Border.all(color: Colors.amber.shade200),
    //             ),
    //             child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Icon(Icons.info_outline, color: Colors.amber.shade700, size: 16),
    //                 SizedBox(width: 6),
    //                 Expanded(
    //                   child: Text(
    //                     'To make changes, the challan status must be changed back to "InProgress" or "Pending".',
    //                     style: TextStyle(
    //                       fontSize: 12,
    //                       color: Colors.amber.shade900,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Get.back(),
    //           child: Text('OK', style: TextStyle(fontSize: 16)),
    //         ),
    //       ],
    //     ),
    //     barrierDismissible: true,
    //   );
    //   return;
    // }

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
        // Force reload from server
        await _reloadChallanFromServer(currentChallan.challanId!);
        Get.snackbar(
          'Success',
          'Challan updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      else {
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

  Future<void> _reloadChallanFromServer(String challanId) async {
    try {
      print("🔄 Reloading challan $challanId from server");

      isLoadingItems.value = true;

      // Clear cache
      GoogleSheetService.clearChallanItemCache(challanId);

      // Fetch fresh challan data
      final List<Challan> challans = await GoogleSheetService.getChallansList();
      final freshChallan = challans.firstWhereOrNull(
              (c) => c.challanId == challanId
      );

      if (freshChallan != null) {
        print("✅ Found updated challan data");
        challan.value = freshChallan;

        // Reload items
        await loadChallanItems(challanId);

        print("✅ Challan and items reloaded successfully");
      } else {
        print("⚠️ Could not find challan in fresh data");
      }

    } catch (e, stack) {
      print("❌ Error reloading challan: $e");
      print("Stack: $stack");
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


