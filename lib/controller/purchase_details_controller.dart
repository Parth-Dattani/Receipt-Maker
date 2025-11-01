import 'package:demo_prac_getx/controller/bash_controller.dart';
import 'package:demo_prac_getx/controller/controller.dart';
import 'package:demo_prac_getx/screen/Inventory/purchase_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../model/model.dart';
import '../services/service.dart';

class PurchaseDetailsController extends BaseController {
  final purchase = Rxn<PurchaseEntry>();
  final purchaseItems = <PurchaseItem>[].obs;
  final isLoading = false.obs;
  final isLoadingItems = false.obs;

  var priceControllers = <TextEditingController>[].obs;
  var quantityControllers = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Get purchase from arguments (must be passed when navigating)
    final passedPurchase = Get.arguments as PurchaseEntry?;
    if (passedPurchase != null) {
      purchase.value = passedPurchase;

      // Load purchase items (async)
      if ((passedPurchase.purchaseId ?? '').isNotEmpty) {
        loadPurchaseItems(passedPurchase.purchaseId!);
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
    final currentPurchase = purchase.value;
    if (currentPurchase == null) {
      Get.snackbar('Error', 'No purchase data available');
      return;
    }

    try {
      print("=== NAVIGATING TO EDIT MODE ===");

      // Cleanup existing controller
      if (Get.isRegistered<PurchaseEntryController>()) {
        Get.delete<PurchaseEntryController>(force: true);
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Register new controller
      Get.put(PurchaseEntryController());

      final argumentsMap = {
        'editMode': true,
        'purchaseId': currentPurchase.purchaseId,
        'purchaseData': currentPurchase,
      };

      // Navigate and AWAIT result
      final result = await Get.to(
            () => PurchaseEntryScreen(),
        arguments: argumentsMap,
        preventDuplicates: true,
      );

      print("=== RETURNED FROM EDIT ===");
      print("Result: $result");

      // ALWAYS refresh after returning (whether saved or cancelled)
      if (result == true) {
        // Give time for sheets to propagate
        await Future.delayed(Duration(milliseconds: 500));

        await forceRefreshPurchaseData();
        // Force reload from server
        await _reloadPurchaseFromServer(currentPurchase.purchaseId!);
        Get.snackbar(
          'Success',
          'Purchase updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Still refresh in case of partial changes
        await forceRefreshPurchaseData();
      }
    } catch (e, stack) {
      print('❌ Navigation error: $e\n$stack');

      // Always try to refresh
      try {
        await forceRefreshPurchaseData();
      } catch (refreshError) {
        print('❌ Refresh error: $refreshError');
      }
    }
  }

  /// ENHANCED: Force refresh with proper cache clearing
  Future<void> forceRefreshPurchaseData() async {
    try {
      print("=== FORCE REFRESH PURCHASE DATA ===");

      final currentPurchase = purchase.value;
      if (currentPurchase?.purchaseId == null) {
        print("No purchase to refresh");
        return;
      }

      isLoadingItems.value = true;
      final purchaseId = currentPurchase!.purchaseId!;

      // CRITICAL: Clear cache FIRST
      GoogleSheetService.clearPurchaseItemCache(purchaseId);

      print("Fetching fresh data for: $purchaseId");

      // Force fresh load (not from cache)
      final freshItems =
      await GoogleSheetService.getPurchaseItemsByPurchaseId(purchaseId);

      print("Received ${freshItems.length} fresh items");

      // Update items
      purchaseItems.clear();
      purchaseItems.assignAll(freshItems);

      // Force UI rebuild
      purchaseItems.refresh();
      update(); // Force GetX update

      print("✅ Refresh completed - ${purchaseItems.length} items loaded");
    } catch (e, stack) {
      print("❌ Error refreshing: $e\n$stack");
      Get.snackbar('Error', 'Failed to refresh data');
    } finally {
      isLoadingItems.value = false;
    }
  }

  Future<void> _reloadPurchaseFromServer(String purchaseId) async {
    try {
      print("🔄 Reloading purchase $purchaseId from server");

      isLoadingItems.value = true;

      // Clear cache
      GoogleSheetService.clearPurchaseItemCache(purchaseId);

      // Fetch fresh purchase data
      final List<PurchaseEntry> purchases =
      await GoogleSheetService.getPurchasesList();
      final freshPurchase =
      purchases.firstWhereOrNull((p) => p.purchaseId == purchaseId);

      if (freshPurchase != null) {
        print("✅ Found updated purchase data");
        purchase.value = freshPurchase;

        // Reload items
        await loadPurchaseItems(purchaseId);

        print("✅ Purchase and items reloaded successfully");
      } else {
        print("⚠️ Could not find purchase in fresh data");
      }
    } catch (e, stack) {
      print("❌ Error reloading purchase: $e");
      print("Stack: $stack");
    } finally {
      isLoadingItems.value = false;
    }
  }

  /// Keep existing refreshPurchaseData for backward compatibility
  Future<void> refreshPurchaseData() async {
    await forceRefreshPurchaseData();
  }

  /// ENHANCED: Load purchase details with fresh data
  Future<void> loadPurchaseDetails(String purchaseId) async {
    try {
      isLoading.value = true;
      print("Loading fresh purchase details for ID: $purchaseId");

      await loadPurchaseItems(purchaseId);

      print("Purchase details loaded successfully");
    } catch (e) {
      print('Error loading purchase details: $e');

    } finally {
      isLoading.value = false;
    }
  }

  /// ENHANCED: Force load fresh items with better error handling
  Future<void> loadPurchaseItems(String purchaseId) async {
    try {
      isLoadingItems.value = true;
      print("🔄 Force loading fresh purchase items for: $purchaseId");

      // Clear existing items first
      purchaseItems.clear();

      final List<PurchaseItem> freshItems =
      await GoogleSheetService.getPurchaseItemsByPurchaseId(purchaseId);

      print("📦 Fetched ${freshItems.length} fresh items from Google Sheets");

      // Debug: Print each item's data
      for (var item in freshItems) {
        print(
            "Fresh item: ${item.itemName} - Qty: ${item.quantity} - Price: ${item.purchasePrice}");
      }

      // Assign fresh data
      purchaseItems.assignAll(freshItems);

      // Force UI update
      purchaseItems.refresh();

      print("✅ Successfully loaded and updated ${freshItems.length} items");
    } catch (e, st) {
      print('❌ Error loading purchase items: $e\n$st');

    } finally {
      isLoadingItems.value = false;
    }
  }

  /// ENHANCED: Manual refresh with user feedback
  Future<void> refreshPurchaseItems() async {
    if (purchase.value == null) return;

    isLoadingItems.value = true;
    try {
      print("🔄 MANUAL REFRESH TRIGGERED");

      final items = await GoogleSheetService.getPurchaseItemsByPurchaseId(
        purchase.value!.purchaseId!,
      );

      purchaseItems.assignAll(items);

      print(
          "✅ Reloaded ${items.length} items for purchase ${purchase.value!.purchaseId}");
      Get.snackbar('Success', 'Items refreshed from server');
    } catch (e) {
      print("❌ Error refreshing purchase items: $e");
      Get.snackbar("Error", "Failed to refresh purchase items");
    } finally {
      isLoadingItems.value = false;
    }
  }

  /// Debug data flow method
  void debugDataFlow() async {
    print("=== DEBUGGING DATA FLOW ===");

    // Check controller registration
    print("Controllers registered:");
    print(
        "  - PurchaseListController: ${Get.isRegistered<PurchaseListController>()}");
    print(
        "  - PurchaseDetailsController: ${Get.isRegistered<PurchaseDetailsController>()}");

    // Check current data
    if (Get.isRegistered<PurchaseListController>()) {
      final listController = Get.find<PurchaseListController>();
      print("  - PurchaseList count: ${listController.purchaseList.length}");
      print(
          "  - FilteredList count: ${listController.filteredPurchaseList.length}");

      // Find current purchase in the list
      final currentPurchaseInList = listController.purchaseList
          .firstWhereOrNull((p) => p.purchaseId == purchase.value?.purchaseId);

      if (currentPurchaseInList != null) {
        print("  - Current purchase found in list");
        print(
            "  - List purchase vendor: ${currentPurchaseInList.vendorName}");
        print("  - Local purchase vendor: ${purchase.value?.vendorName}");
      } else {
        print("  - Current purchase NOT found in list!");
      }
    }

    print("=== END DEBUG ===");
  }

  /// Download purchase as PDF
  Future<void> downloadPurchasePdf() async {
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

  /// Share purchase
  Future<void> sharePurchase() async {
    try {
      final purchaseData = purchase.value;
      if (purchaseData != null) {
        final shareText = '''
Purchase Details:
ID: ${purchaseData.purchaseId}
Date: ${DateFormat('MMM dd, yyyy').format(purchaseData.purchaseDate!)}
Vendor: ${purchaseData.vendorName}
Total: ₹${purchaseData.totalAmount?.toStringAsFixed(2) ?? '0.00'}
Paid: ₹${purchaseData.paidAmount?.toStringAsFixed(2) ?? '0.00'}
Pending: ₹${purchaseData.pendingAmount?.toStringAsFixed(2) ?? '0.00'}
Status: ${purchaseData.paymentStatus}
''';

        Get.snackbar('Success', 'Purchase shared successfully');
      }
    } catch (e) {
      print('❌ Error sharing purchase: $e');
      Get.snackbar('Error', 'Failed to share purchase');
    }
  }
}