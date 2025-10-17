import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/constant/app_constant.dart';
import 'package:demo_prac_getx/model/model.dart';
import 'package:demo_prac_getx/services/remote_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_colors.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'controller.dart';


///16-10 working 12:39
// class ItemController extends GetxController {
//   var itemList = <Item>[].obs;
//   var cart = <Invoice>[].obs;
//   var isLoading = false.obs;
//   var isSavingInvoice = false.obs;
//   var currentInvoiceId = "".obs;
//   var showInactiveItems = false.obs;
//
//   var customers = <Map<String, dynamic>>[].obs;
//   var isLoadingCustomers = false.obs;
//
//   // Unit options for dropdown
//   final List<String> unitOptions = [
//     'pcs', 'kg', 'ltr', 'ml', 'mtr', 'cm', 'ft', 'inch', 'box', 'pack', 'dozen'
//   ];
//
//   double get total => cart.fold(0, (sum, item) => sum + (item.qty! * item.price!));
//
//   // Filtered item list based on active status
//   List<Item> get filteredItemList => showInactiveItems.value
//       ? itemList
//       : itemList.where((item) => item.isActive).toList();
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchItems2();
//
//     ///fetchItems();
//     // loadCustomers();
//     //
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   print("object----${"\u20B9"}");
//     //   RemoteService.checkInvoiceTableStructure();
//     // });
//   }
//
//
// /// Updated controller method
//   Future<void> fetchItems2() async {
//     try {
//       isLoading.value = true;
//
//       final userId = "${AppConstants.userId}"; // Your target user ID
//
//       print("=== ATTEMPTING TO FETCH ITEMS FOR USER: $userId ===");
//
//       // Try Method 1: Standard approach
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
//       print("Error in fetchItems2(): $e");
//
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
// // Step 3: Make sure your getCurrentUserId() method is working
//   String? getCurrentUserId() {
//     // DEBUG: Print what you're returning
//     String? userId = "${AppConstants.userId}"; // Replace with your actual method
//
//     print("getCurrentUserId() returning: '$userId'");
//     return userId;
//   }
//
//   void generateInvoiceIdIfNeeded() {
//     if (currentInvoiceId.value.isEmpty) {
//       currentInvoiceId.value = "INV-${DateTime.now().millisecondsSinceEpoch}";
//       print("Generated new invoice ID: ${currentInvoiceId.value}");
//     }
//   }
//
//   void addToCart(Item item) {
//     // Check stock availability
//     if (item.currentStock <= 0 && item.currentStock != -1) { // -1 means unlimited stock
//       showCustomSnackbar(
//         title: "Out of Stock",
//         message: "${item.itemName} is currently out of stock",
//         baseColor: Colors.orange.shade700,
//         icon: Icons.inventory_2_outlined,
//       );
//       return;
//     }
//
//     generateInvoiceIdIfNeeded();
//
//     final existingIndex = cart.indexWhere((cartItem) => cartItem.itemId == item.itemId);
//
//     if (existingIndex >= 0) {
//       final existingItem = cart[existingIndex];
//       final newQty = existingItem.qty! + 1;
//
//       // Check if new quantity exceeds stock
//       if (item.currentStock != -1 && newQty > item.currentStock) {
//         showCustomSnackbar(
//           title: "Stock Limit",
//           message: "Only ${item.currentStock} ${item.unitOfMeasurement} available",
//           baseColor: Colors.orange.shade700,
//           icon: Icons.inventory_2_outlined,
//         );
//         return;
//       }
//
//       cart[existingIndex] = Invoice(
//         invoiceId: currentInvoiceId.value,
//         itemId: existingItem.itemId,
//         itemName: existingItem.itemName,
//         qty: newQty,
//         price: existingItem.price,
//         mobile: existingItem.mobile,
//         customerName: existingItem.customerName,
//       );
//     } else {
//       cart.add(Invoice(
//         invoiceId: currentInvoiceId.value,
//         itemId: item.itemId,
//         itemName: item.itemName,
//         qty: 1,
//         price: item.price,
//         mobile: "",
//         customerName: "",
//       ));
//       showCustomSnackbar(
//         title: "Added to Cart",
//         message: "${item.itemName} added to cart",
//         baseColor: AppColors.darkGreenColor,
//         icon: Icons.add_shopping_cart,
//       );
//     }
//   }
//
//   void removeFromCart(String pid) {
//     final item = cart.firstWhereOrNull((cartItem) => cartItem.itemId == pid);
//     cart.removeWhere((item) => item.itemId == pid);
//     if (item != null) {
//       showCustomSnackbar(
//         title: "Removed",
//         message: "${item.itemId} removed from cart",
//         baseColor: Colors.red.shade700,
//         icon: Icons.delete_outline,
//       );
//     }
//     if (cart.isEmpty) {
//       currentInvoiceId.value = "";
//       print("Cart empty - reset invoice ID");
//     }
//   }
//
//   void clearCart() {
//     cart.clear();
//     currentInvoiceId.value = "";
//     print("Cart cleared - reset invoice ID");
//   }
//
//   Future<void> addNewItem({
//     required String name,
//     required double price,
//     required double gstPercent,
//     required String unitOfMeasurement,
//     required int currentStock,
//     required String detailRequirement,
//     required bool isActive,
//   }) async {
//     final newItem = Item(
//       itemId: DateTime.now().millisecondsSinceEpoch.toString(),
//       itemName: name,
//       price: price,
//       gstPercent: gstPercent,
//       unitOfMeasurement: unitOfMeasurement,
//       currentStock: currentStock,
//       detailRequirement: detailRequirement,
//       isActive: isActive,
//     );
//
//     print("=======ICCC---UID:-----${AppConstants.userId}");
//     try {
//       await GoogleSheetService.addItem(AppConstants.userId ,newItem);
//       itemList.add(newItem);
//       showCustomSnackbar(
//         title: "Success",
//         message: "Item saved successfully",
//         baseColor: AppColors.darkGreenColor,
//         icon: Icons.check_circle_outline,
//       );
//     } catch (e) {
//       print("-----Error on addItems() in Controller,,,, ${e.toString()}");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to save item: $e",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//     }
//   }
//
//   Future<void> editItem({
//     required String itemId,
//     required String newName,
//     required double newPrice,
//     required double gstPercent,
//     required String unitOfMeasurement,
//     required int currentStock,
//     required String detailRequirement,
//     required bool isActive,
//   }) async {
//     print("=== EDIT ITEM DEBUG ===");
//     print("ItemId: $itemId");
//
//     try {
//       isLoading.value = true;
//
//       // Find the current item to ensure we have the right one
//       final currentIndex = itemList.indexWhere((item) => item.itemId == itemId);
//       if (currentIndex == -1) {
//         throw Exception("Item not found in local list");
//       }
//
//       final currentItem = itemList[currentIndex];
//       print("Found current item: ${currentItem.itemName}");
//
//       final updatedItem = Item(
//         itemId: itemId,
//         itemName: newName,
//         price: newPrice,
//         gstPercent: gstPercent,
//         unitOfMeasurement: unitOfMeasurement,
//         currentStock: currentStock,
//         detailRequirement: detailRequirement,
//         isActive: isActive,
//       );
//
//       print("Created updated item: ${updatedItem.toMap()}");
//
//       // Call API to update
//       await GoogleSheetService.editItemAlternative3(AppConstants.userId, updatedItem);
//       print("API call successful");
//
//       // Update local list
//       itemList[currentIndex] = updatedItem;
//       print("Updated local list at index $currentIndex");
//
//       // Force UI refresh
//       itemList.refresh();
//       print("Refreshed itemList");
//
//       showCustomSnackbar(
//         title: "Success",
//         message: "Item updated successfully",
//         baseColor: Colors.green,
//         icon: Icons.check_circle,
//       );
//
//       print("=== EDIT ITEM SUCCESS ===");
//     } catch (e) {
//       print("=== EDIT ITEM ERROR ===");
//       print("Error details: $e");
//       print("Error type: ${e.runtimeType}");
//
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to edit item: ${e.toString()}",
//         baseColor: Colors.red,
//         icon: Icons.error_outline,
//       );
//
//       rethrow;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//
//   Future<void> updateItemStatus({
//     required String itemId,
//     required bool isActive,
//   }) async {
//     try {
//       isLoading.value = true;
//
//       final currentIndex = itemList.indexWhere((item) => item.itemId == itemId);
//       if (currentIndex == -1) {
//         throw Exception("Item not found in local list");
//       }
//
//       final currentItem = itemList[currentIndex];
//
//       // Create updated item with new status
//       final updatedItem = Item(
//         itemId: currentItem.itemId,
//         itemName: currentItem.itemName,
//         price: currentItem.price,
//         unitOfMeasurement: currentItem.unitOfMeasurement,
//         currentStock: currentItem.currentStock,
//         detailRequirement: currentItem.detailRequirement,
//         isActive: isActive,
//       );
//
//       // Update in Google Sheet (reuses your existing service)
//       await GoogleSheetService.editItemAlternative3(AppConstants.userId, updatedItem);
//
//       // Update in local list
//       itemList[currentIndex] = updatedItem;
//       itemList.refresh();
//
//       showCustomSnackbar(
//         title: "Success",
//         message: isActive
//             ? "Item restored successfully"
//             : "Item deleted successfully",
//         baseColor: Colors.green,
//         icon: Icons.check_circle,
//       );
//     } catch (e) {
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to update item: $e",
//         baseColor: Colors.red,
//         icon: Icons.error_outline,
//       );
//       rethrow;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//
//
//   void toggleShowInactive() {
//     showInactiveItems.value = !showInactiveItems.value;
//   }
//
//   // Add these methods to your ItemController class
//   Future<void> loadCustomers() async {
//     try {
//       isLoadingCustomers.value = true;
//
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;
//
//       // Get current company ID from SharedPreferences
//       String companyId = await await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       print("Company ID:-itemCntrol--------- $companyId");
//
//       if (companyId.isEmpty) {
//         showCustomSnackbar(
//           title: 'Company Required',
//           message: 'Please register a company first',
//           baseColor: Colors.orange,
//           icon: Icons.warning,
//         );
//         return;
//       }
//
//       // Load customers from Firebase
//       final customersSnapshot = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers")
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       customers.clear();
//       for (var doc in customersSnapshot.docs) {
//         final customerData = doc.data();
//         customerData['id'] = doc.id;
//         customers.add(customerData);
//       }
//
//       print("Loaded ${customers.length} customers");
//
//     } catch (e) {
//       print("Error loading customers: $e");
//       showCustomSnackbar(
//         title: 'Error',
//         message: 'Failed to load customers',
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//     } finally {
//       isLoadingCustomers.value = false;
//     }
//   }
//
//   Future<void> saveNewCustomer({
//     required String name,
//     required String phone,
//     String? email,
//     String? address,
//   }) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;
//
//       String companyId = await SharedPreferencesHelper().getPrefData("CompanyId") ?? "";
//       if (companyId.isEmpty) return;
//
//       final customerData = {
//         'name': name.trim(),
//         'phone': phone.trim(),
//         'email': email?.trim() ?? '',
//         'address': address?.trim() ?? '',
//         'createdAt': FieldValue.serverTimestamp(),
//         'isActive': true,
//       };
//
//       final docRef = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers")
//           .add(customerData);
//
//       // Add to local list
//       customerData['id'] = docRef.id;
//       customers.insert(0, customerData);
//
//       showCustomSnackbar(
//         title: 'Success',
//         message: 'Customer saved successfully',
//         baseColor: AppColors.darkGreenColor,
//         icon: Icons.check_circle_outline,
//       );
//
//     } catch (e) {
//       print("Error saving customer: $e");
//       showCustomSnackbar(
//         title: 'Error',
//         message: 'Failed to save customer',
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//     }
//   }
// }


class ItemController extends GetxController {
  var itemList = <Item>[].obs;
  var cart = <Invoice>[].obs;
  var isLoading = false.obs;
  var isSavingInvoice = false.obs;
  var currentInvoiceId = "".obs;
  var showInactiveItems = false.obs;

  // Inventory management
  var inventoryTransactions = <InventoryTransaction>[].obs;
  var isLoadingTransactions = false.obs;
  var lowStockThreshold = 10.obs;

  var customers = <Map<String, dynamic>>[].obs;
  var isLoadingCustomers = false.obs;

  final List<String> unitOptions = [
    'pcs', 'kg', 'ltr', 'ml', 'mtr', 'cm', 'ft', 'inch', 'box', 'pack', 'dozen'
  ];

  double get total => cart.fold(0, (sum, item) => sum + (item.qty! * item.price!));

  // ✅ FIXED: Better filtering logic
  List<Item> get filteredItemList {
    print("=== FILTERING DEBUG ===");
    print("showInactiveItems: ${showInactiveItems.value}");
    print("Total items in list: ${itemList.length}");

    if (showInactiveItems.value) {
      print("Returning ALL items (${itemList.length})");
      return itemList;
    }

    final filtered = itemList.where((item) {
      final isActive = item.isActive ?? false;
      print("Item: ${item.itemName} - isActive: $isActive");
      return isActive;
    }).toList();

    print("Filtered active items: ${filtered.length}");
    return filtered;
  }

  // Low stock items - only count active items
  List<Item> get lowStockItems {
    final low = itemList
        .where((item) {
      final isActive = item.isActive ?? false;
      final hasStock = item.currentStock != -1;
      final belowThreshold = item.currentStock <= lowStockThreshold.value;

      final matches = isActive && hasStock && belowThreshold;

      if (matches) {
        print("Low stock: ${item.itemName} - Stock: ${item.currentStock}, Threshold: ${lowStockThreshold.value}");
      }

      return matches;
    })
        .toList();

    print("Total low stock items: ${low.length}");
    return low;
  }

  // Total inventory value - fixed calculation
  double get totalInventoryValue {
    double total = 0;

    itemList.forEach((item) {
      if (item.currentStock != -1 && item.currentStock > 0) {
        final value = item.currentStock * item.price;
        total += value;
        print("${item.itemName}: ${item.currentStock} × ${item.price} = $value");
      }
    });

    print("Total inventory value: $total");
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    print("=== ItemController.onInit() ===");
    fetchItems2();
    loadInventoryTransactions();
  }

  Future<void> fetchItems2() async {
    try {
      isLoading.value = true;
      final userId = "${AppConstants.userId}";

      print("=== FETCHING ITEMS ===");
      print("User ID: $userId");

      List<Item> items = await GoogleSheetService.getItems(userId: userId);

      print("Items received: ${items.length}");

      // Debug: Print each item
      for (var item in items) {
        print("Item: ${item.itemName}");
        print("  - ID: ${item.itemId}");
        print("  - Price: ${item.price}");
        print("  - Stock: ${item.currentStock}");
        print("  - Active: ${item.isActive}");
        print("  - GST: ${item.gstPercent}");
      }

      itemList.assignAll(items);

      print("ItemList updated. Total: ${itemList.length}");
      print("Active items: ${itemList.where((i) => i.isActive).length}");
      print("Inactive items: ${itemList.where((i) => !i.isActive).length}");

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
      print("❌ Error in fetchItems2(): $e");
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

  Future<void> loadInventoryTransactions() async {
    try {
      isLoadingTransactions.value = true;
      final userId = "${AppConstants.userId}";

      List<InventoryTransaction> transactions =
      await GoogleSheetService.getInventoryTransactions(userId: userId);

      print("Loaded ${transactions.length} inventory transactions");
      inventoryTransactions.assignAll(transactions);
    } catch (e) {
      print("Error loading inventory transactions: $e");
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Future<void> addInventory({
    required String itemId,
    required int quantity,
    required String reason,
    String notes = '',
  }) async {
    try {
      final item = itemList.firstWhereOrNull((i) => i.itemId == itemId);
      if (item == null) throw Exception("Item not found");

      final newStock = (item.currentStock == -1 ? 0 : item.currentStock) + quantity;

      final transaction = InventoryTransaction(
        transactionId: "TXN-${DateTime.now().millisecondsSinceEpoch}",
        itemId: itemId,
        itemName: item.itemName,
        quantity: quantity,
        type: 'add',
        reason: reason,
        timestamp: DateTime.now(),
        notes: notes,
      );

      await GoogleSheetService.addInventoryTransaction(
        AppConstants.userId,
        transaction,
      );

      final updatedItem = Item(
        itemId: item.itemId,
        itemName: item.itemName,
        price: item.price,
        gstPercent: item.gstPercent,
        unitOfMeasurement: item.unitOfMeasurement,
        currentStock: newStock,
        detailRequirement: item.detailRequirement,
        isActive: item.isActive,
      );

      await GoogleSheetService.editItemAlternative3(AppConstants.userId, updatedItem);

      final index = itemList.indexWhere((i) => i.itemId == itemId);
      itemList[index] = updatedItem;
      itemList.refresh();

      inventoryTransactions.insert(0, transaction);

      showCustomSnackbar(
        title: "Success",
        message: "Added $quantity units to inventory",
        baseColor: Colors.green.shade700,
        icon: Icons.add_circle_outline,
      );
    } catch (e) {
      print("Error adding inventory: $e");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to add inventory: $e",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
      rethrow;
    }
  }

  Future<void> removeInventory({
    required String itemId,
    required int quantity,
    required String reason,
    String notes = '',
  }) async {
    try {
      final item = itemList.firstWhereOrNull((i) => i.itemId == itemId);
      if (item == null) throw Exception("Item not found");

      final currentStock = item.currentStock == -1 ? 0 : item.currentStock;
      if (quantity > currentStock) {
        throw Exception("Insufficient stock. Available: $currentStock");
      }

      final newStock = currentStock - quantity;

      final transaction = InventoryTransaction(
        transactionId: "TXN-${DateTime.now().millisecondsSinceEpoch}",
        itemId: itemId,
        itemName: item.itemName,
        quantity: quantity,
        type: 'remove',
        reason: reason,
        timestamp: DateTime.now(),
        notes: notes,
      );

      await GoogleSheetService.addInventoryTransaction(
        AppConstants.userId,
        transaction,
      );

      final updatedItem = Item(
        itemId: item.itemId,
        itemName: item.itemName,
        price: item.price,
        gstPercent: item.gstPercent,
        unitOfMeasurement: item.unitOfMeasurement,
        currentStock: newStock,
        detailRequirement: item.detailRequirement,
        isActive: item.isActive,
      );

      await GoogleSheetService.editItemAlternative3(AppConstants.userId, updatedItem);

      final index = itemList.indexWhere((i) => i.itemId == itemId);
      itemList[index] = updatedItem;
      itemList.refresh();

      inventoryTransactions.insert(0, transaction);

      showCustomSnackbar(
        title: "Success",
        message: "Removed $quantity units from inventory",
        baseColor: Colors.orange.shade700,
        icon: Icons.remove_circle_outline,
      );
    } catch (e) {
      print("Error removing inventory: $e");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to remove inventory: $e",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
      rethrow;
    }
  }

  Future<void> adjustInventory({
    required String itemId,
    required int newQuantity,
    String reason = 'Manual Adjustment',
    String notes = '',
  }) async {
    try {
      final item = itemList.firstWhereOrNull((i) => i.itemId == itemId);
      if (item == null) throw Exception("Item not found");

      final currentStock = item.currentStock == -1 ? 0 : item.currentStock;
      final difference = newQuantity - currentStock;

      final transaction = InventoryTransaction(
        transactionId: "TXN-${DateTime.now().millisecondsSinceEpoch}",
        itemId: itemId,
        itemName: item.itemName,
        quantity: difference.abs(),
        type: 'adjustment',
        reason: reason,
        timestamp: DateTime.now(),
        notes: "Changed from $currentStock to $newQuantity. $notes",
      );

      await GoogleSheetService.addInventoryTransaction(
        AppConstants.userId,
        transaction,
      );

      final updatedItem = Item(
        itemId: item.itemId,
        itemName: item.itemName,
        price: item.price,
        gstPercent: item.gstPercent,
        unitOfMeasurement: item.unitOfMeasurement,
        currentStock: newQuantity,
        detailRequirement: item.detailRequirement,
        isActive: item.isActive,
      );

      await GoogleSheetService.editItemAlternative3(AppConstants.userId, updatedItem);

      final index = itemList.indexWhere((i) => i.itemId == itemId);
      itemList[index] = updatedItem;
      itemList.refresh();

      inventoryTransactions.insert(0, transaction);

      showCustomSnackbar(
        title: "Success",
        message: "Inventory adjusted successfully",
        baseColor: Colors.blue.shade700,
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      print("Error adjusting inventory: $e");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to adjust inventory: $e",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
      rethrow;
    }
  }

  List<InventoryTransaction> getItemTransactions(String itemId) {
    return inventoryTransactions
        .where((t) => t.itemId == itemId)
        .toList();
  }

  void setLowStockThreshold(int value) {
    lowStockThreshold.value = value;
  }

  void toggleShowInactive() {
    print("Toggling showInactiveItems from ${showInactiveItems.value} to ${!showInactiveItems.value}");
    showInactiveItems.value = !showInactiveItems.value;
  }

  // Your existing methods (addToCart, removeFromCart, etc.) remain unchanged
  void addToCart(Item item) {
    if (item.currentStock <= 0 && item.currentStock != -1) {
      showCustomSnackbar(
        title: "Out of Stock",
        message: "${item.itemName} is currently out of stock",
        baseColor: Colors.orange.shade700,
        icon: Icons.inventory_2_outlined,
      );
      return;
    }

    generateInvoiceIdIfNeeded();

    final existingIndex = cart.indexWhere((cartItem) => cartItem.itemId == item.itemId);

    if (existingIndex >= 0) {
      final existingItem = cart[existingIndex];
      final newQty = existingItem.qty! + 1;

      if (item.currentStock != -1 && newQty > item.currentStock) {
        showCustomSnackbar(
          title: "Stock Limit",
          message: "Only ${item.currentStock} ${item.unitOfMeasurement} available",
          baseColor: Colors.orange.shade700,
          icon: Icons.inventory_2_outlined,
        );
        return;
      }

      cart[existingIndex] = Invoice(
        invoiceId: currentInvoiceId.value,
        itemId: existingItem.itemId,
        itemName: existingItem.itemName,
        qty: newQty,
        price: existingItem.price,
        mobile: existingItem.mobile,
        customerName: existingItem.customerName,
      );
    } else {
      cart.add(Invoice(
        invoiceId: currentInvoiceId.value,
        itemId: item.itemId,
        itemName: item.itemName,
        qty: 1,
        price: item.price,
        mobile: "",
        customerName: "",
      ));
      showCustomSnackbar(
        title: "Added to Cart",
        message: "${item.itemName} added to cart",
        baseColor: AppColors.darkGreenColor,
        icon: Icons.add_shopping_cart,
      );
    }
  }

  void removeFromCart(String pid) {
    final item = cart.firstWhereOrNull((cartItem) => cartItem.itemId == pid);
    cart.removeWhere((item) => item.itemId == pid);
    if (item != null) {
      showCustomSnackbar(
        title: "Removed",
        message: "${item.itemId} removed from cart",
        baseColor: Colors.red.shade700,
        icon: Icons.delete_outline,
      );
    }
    if (cart.isEmpty) {
      currentInvoiceId.value = "";
    }
  }

  void clearCart() {
    cart.clear();
    currentInvoiceId.value = "";
  }

  void generateInvoiceIdIfNeeded() {
    if (currentInvoiceId.value.isEmpty) {
      currentInvoiceId.value = "INV-${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  String? getCurrentUserId() {
    String? userId = "${AppConstants.userId}";
    print("getCurrentUserId() returning: '$userId'");
    return userId;
  }



  Future<void> addNewItem({
    required String name,
    required double price,
    required double gstPercent,
    required String unitOfMeasurement,
    required int currentStock,
    required String detailRequirement,
    required bool isActive,
  }) async {
    final newItem = Item(
      itemId: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: name,
      price: price,
      gstPercent: gstPercent,
      unitOfMeasurement: unitOfMeasurement,
      currentStock: currentStock,
      detailRequirement: detailRequirement,
      isActive: isActive,
    );

    print("=======ICCC---UID:-----${AppConstants.userId}");
    try {
      await GoogleSheetService.addItem(AppConstants.userId ,newItem);
      itemList.add(newItem);
      showCustomSnackbar(
        title: "Success",
        message: "Item saved successfully",
        baseColor: AppColors.darkGreenColor,
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      print("-----Error on addItems() in Controller,,,, ${e.toString()}");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to save item: $e",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> editItem({
    required String itemId,
    required String newName,
    required double newPrice,
    required double gstPercent,
    required String unitOfMeasurement,
    required int currentStock,
    required String detailRequirement,
    required bool isActive,
  }) async {
    print("=== EDIT ITEM DEBUG ===");
    print("ItemId: $itemId");

    try {
      isLoading.value = true;

      // Find the current item to ensure we have the right one
      final currentIndex = itemList.indexWhere((item) => item.itemId == itemId);
      if (currentIndex == -1) {
        throw Exception("Item not found in local list");
      }

      final currentItem = itemList[currentIndex];
      print("Found current item: ${currentItem.itemName}");

      final updatedItem = Item(
        itemId: itemId,
        itemName: newName,
        price: newPrice,
        gstPercent: gstPercent,
        unitOfMeasurement: unitOfMeasurement,
        currentStock: currentStock,
        detailRequirement: detailRequirement,
        isActive: isActive,
      );

      print("Created updated item: ${updatedItem.toMap()}");

      // Call API to update
      await GoogleSheetService.editItemAlternative3(AppConstants.userId, updatedItem);
      print("API call successful");

      // Update local list
      itemList[currentIndex] = updatedItem;
      print("Updated local list at index $currentIndex");

      // Force UI refresh
      itemList.refresh();
      print("Refreshed itemList");

      showCustomSnackbar(
        title: "Success",
        message: "Item updated successfully",
        baseColor: Colors.green,
        icon: Icons.check_circle,
      );

      print("=== EDIT ITEM SUCCESS ===");
    } catch (e) {
      print("=== EDIT ITEM ERROR ===");
      print("Error details: $e");
      print("Error type: ${e.runtimeType}");

      showCustomSnackbar(
        title: "Error",
        message: "Failed to edit item: ${e.toString()}",
        baseColor: Colors.red,
        icon: Icons.error_outline,
      );

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateItemStatus({
    required String itemId,
    required bool isActive,
  }) async {
    try {
      isLoading.value = true;

      final currentIndex = itemList.indexWhere((item) => item.itemId == itemId);
      if (currentIndex == -1) {
        throw Exception("Item not found in local list");
      }

      final currentItem = itemList[currentIndex];

      // Create updated item with new status
      final updatedItem = Item(
        itemId: currentItem.itemId,
        itemName: currentItem.itemName,
        price: currentItem.price,
        unitOfMeasurement: currentItem.unitOfMeasurement,
        currentStock: currentItem.currentStock,
        detailRequirement: currentItem.detailRequirement,
        isActive: isActive,
      );

      // Update in Google Sheet (reuses your existing service)
      await GoogleSheetService.editItemAlternative3(AppConstants.userId, updatedItem);

      // Update in local list
      itemList[currentIndex] = updatedItem;
      itemList.refresh();

      showCustomSnackbar(
        title: "Success",
        message: isActive
            ? "Item restored successfully"
            : "Item deleted successfully",
        baseColor: Colors.green,
        icon: Icons.check_circle,
      );
    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Failed to update item: $e",
        baseColor: Colors.red,
        icon: Icons.error_outline,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }




}


