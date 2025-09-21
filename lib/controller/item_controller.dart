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


// class ItemController extends GetxController {
//   var itemList = <Item>[].obs; // Changed from Invoice to Item
//   var cart = <Invoice>[].obs;
//   var isLoading = false.obs;
//   var isSavingInvoice = false.obs;
//   var currentInvoiceId = "".obs;
//
//   double get total => cart.fold(0, (sum, item) => sum + (item.qty * item.price));
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchItems();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       print("object----${"\u20B9"}");
//       RemoteService.checkInvoiceTableStructure();
//     });
//   }
//
//   Future<void> fetchItems() async {
//     print("object----${"\u20B9"}");
//
//     try {
//       isLoading.value = true;
//       final items = await RemoteService.getItems();
//       print("Fetched items: ${items.length}");
//       print(items.map((e) => e.toMap()).toList());
//       itemList.assignAll(items);
//       print("itemLListLengt------:${items.length}");
//     } catch (e) {
//       print("-----Error on fetchItems() in Controller,,,, ${e.toString()}");
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
//   // Generate invoice ID only once when first item is added to cart
//   void generateInvoiceIdIfNeeded() {
//     if (currentInvoiceId.value.isEmpty) {
//       currentInvoiceId.value = "INV-${DateTime.now().millisecondsSinceEpoch}";
//       print("Generated new invoice ID: ${currentInvoiceId.value}");
//     }
//   }
//
//   // Add item to cart (convert Item to Invoice)
//  void addToCart(Item item) {
//    generateInvoiceIdIfNeeded();
//
//     // Check if item already in cart
//     final existingIndex = cart.indexWhere((cartItem) => cartItem.itemId == item.itemId);
//
//     if (existingIndex >= 0) {
//       // Update quantity if already in cart
//       final existingItem = cart[existingIndex];
//       cart[existingIndex] = Invoice(
//         invoiceId: currentInvoiceId.value,
//         itemId: existingItem.itemId,
//         itemName: existingItem.itemName,
//         qty: existingItem.qty + 1,
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
//
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
//     // Reset invoice ID if cart becomes empty
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
//   // Add new item to Items table
//   Future<void> addNewItem(String name, double price) async {
//     final newItem = Item(
//       itemId: DateTime.now().millisecondsSinceEpoch.toString(),
//       itemName: name,
//       price: price,
//     );
//
//     try {
//       await RemoteService.addItem(newItem);
//       itemList.add(newItem);
//       showCustomSnackbar(
//         title: "Success",
//         message: "Item saved to Items table",
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
//   // Save invoice to Invoice table
//   Future<bool> saveInvoice(List<Invoice> invoices, String userName, String phone) async {
//     if (invoices.isEmpty) {
//       showCustomSnackbar(
//         title: "Error",
//         message: "Cart is empty",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//       return false;
//     }
//     isSavingInvoice.value = true;
//     try {
//       // Generate one invoiceId for the whole cart
//       final String invoiceId = currentInvoiceId.value;
//
//       // Assign the same invoiceId to all items
//       final invoicesWithUser = invoices.map((e) => Invoice(
//         invoiceId: invoiceId,
//         itemId: e.itemId,
//         itemName: e.itemName,
//         //productName: e.productName,
//         qty: e.qty,
//         price: e.price,
//         mobile: phone,
//         customerName: userName,
//
//       )).toList();
//
//       print("Sending invoice data: ${invoicesWithUser.map((e) => e.toMap()).toList()}");
//       await RemoteService.addInvoice(invoicesWithUser);
//
//       showCustomSnackbar(
//         title: "Success",
//         message: "Invoice saved successfully!",
//         baseColor: AppColors.darkGreenColor,
//         icon: Icons.check_circle_outline,
//       );
//       clearCart();
//       return true;
//     } catch (e) {
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to save invoice: $e",
//         baseColor: Colors.red.shade700,
//         icon: Icons.error_outline,
//       );
//       print("Save invoice error: $e");
//       return false;
//     }finally {
//       isSavingInvoice.value = false;
//     }
//     isLoading.value = false;
//   }
//
//   Future<void> editItem(String itemId, String newName, double newPrice) async {
//     try {
//       isLoading.value = true;
//       await RemoteService.editItem(itemId, newName, newPrice);
//
//       // Update in local list
//       int index = itemList.indexWhere((item) => item.itemId == itemId);
//       if (index != -1) {
//         itemList[index] = Item(
//           itemId: itemId,
//           itemName: newName,
//           price: newPrice,
//         );
//         itemList.refresh(); // refresh UI
//       }
//
//       showCustomSnackbar(
//         title: "Success",
//         message: "Item updated successfully ✅",
//         baseColor: Colors.green,
//         icon: Icons.check_circle,
//       );
//     } catch (e) {
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to edit item: $e",
//         baseColor: Colors.red,
//         icon: Icons.error_outline,
//       );
//     } finally {
//       isLoading.value = false;
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

  var customers = <Map<String, dynamic>>[].obs;
  var isLoadingCustomers = false.obs;

  // Unit options for dropdown
  final List<String> unitOptions = [
    'pcs', 'kg', 'gm', 'ltr', 'ml', 'mtr', 'cm', 'ft', 'inch', 'box', 'pack', 'dozen'
  ];

  double get total => cart.fold(0, (sum, item) => sum + (item.qty! * item.price!));

  // Filtered item list based on active status
  List<Item> get filteredItemList => showInactiveItems.value
      ? itemList
      : itemList.where((item) => item.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    fetchItems2();

    ///fetchItems();
    // loadCustomers();
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   print("object----${"\u20B9"}");
    //   RemoteService.checkInvoiceTableStructure();
    // });
  }


/// Updated controller method
  Future<void> fetchItems2() async {
    try {
      isLoading.value = true;

      final userId = "${AppConstants.userId}"; // Your target user ID

      print("=== ATTEMPTING TO FETCH ITEMS FOR USER: $userId ===");

      // Try Method 1: Standard approach
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


// Step 3: Make sure your getCurrentUserId() method is working
  String? getCurrentUserId() {
    // DEBUG: Print what you're returning
    String? userId = "${AppConstants.userId}"; // Replace with your actual method

    print("getCurrentUserId() returning: '$userId'");
    return userId;
  }

  void generateInvoiceIdIfNeeded() {
    if (currentInvoiceId.value.isEmpty) {
      currentInvoiceId.value = "INV-${DateTime.now().millisecondsSinceEpoch}";
      print("Generated new invoice ID: ${currentInvoiceId.value}");
    }
  }

  void addToCart(Item item) {
    // Check stock availability
    if (item.currentStock <= 0 && item.currentStock != -1) { // -1 means unlimited stock
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

      // Check if new quantity exceeds stock
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
      print("Cart empty - reset invoice ID");
    }
  }

  void clearCart() {
    cart.clear();
    currentInvoiceId.value = "";
    print("Cart cleared - reset invoice ID");
  }

  Future<void> addNewItem({
    required String name,
    required double price,
    required String unitOfMeasurement,
    required int currentStock,
    required String detailRequirement,
    required bool isActive,
  }) async {
    final newItem = Item(
      itemId: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: name,
      price: price,
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



  void toggleShowInactive() {
    showInactiveItems.value = !showInactiveItems.value;
  }

  // Add these methods to your ItemController class
  Future<void> loadCustomers() async {
    try {
      isLoadingCustomers.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get current company ID from SharedPreferences
      String companyId = await await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      print("Company ID:-itemCntrol--------- $companyId");

      if (companyId.isEmpty) {
        showCustomSnackbar(
          title: 'Company Required',
          message: 'Please register a company first',
          baseColor: Colors.orange,
          icon: Icons.warning,
        );
        return;
      }

      // Load customers from Firebase
      final customersSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .collection("customers")
          .orderBy('createdAt', descending: true)
          .get();

      customers.clear();
      for (var doc in customersSnapshot.docs) {
        final customerData = doc.data();
        customerData['id'] = doc.id;
        customers.add(customerData);
      }

      print("Loaded ${customers.length} customers");

    } catch (e) {
      print("Error loading customers: $e");
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to load customers',
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  Future<void> saveNewCustomer({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String companyId = await SharedPreferencesHelper().getPrefData("CompanyId") ?? "";
      if (companyId.isEmpty) return;

      final customerData = {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email?.trim() ?? '',
        'address': address?.trim() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      final docRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .collection("customers")
          .add(customerData);

      // Add to local list
      customerData['id'] = docRef.id;
      customers.insert(0, customerData);

      showCustomSnackbar(
        title: 'Success',
        message: 'Customer saved successfully',
        baseColor: AppColors.darkGreenColor,
        icon: Icons.check_circle_outline,
      );

    } catch (e) {
      print("Error saving customer: $e");
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to save customer',
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
    }
  }
}

///for Single row
//   Future<bool> saveInvoice(List<Invoice> invoices, String userName, String phone) async {
//   if (invoices.isEmpty) {
//     showCustomSnackbar(
//       title: "Error",
//       message: "Cart is empty",
//       baseColor: Colors.red.shade700,
//       icon: Icons.error_outline,
//     );
//     return false;
//   }
//   isSavingInvoice.value = true;
//   try {
//     // Generate one invoiceId for the whole invoice
//     final String invoiceId = "INV-${DateTime.now().millisecondsSinceEpoch}";
//
//     // Combine all items into a single string
//     final itemsString = invoices.map((e) => "${e.itemName} x${e.qty} @ ₹${e.price}").join(", ");
//
//     // Create a single invoice row
//     final invoiceRow = {
//       "invoiceId": invoiceId,
//       "items": itemsString,
//       "customerName": userName,
//       "mobile": phone,
//       "total": invoices.fold(0.0, (sum, e) => sum + (e.qty * e.price)).toStringAsFixed(2),
//
//     };
//
//     print("Sending single invoice row: $invoiceRow");
//     await RemoteService.addSingleInvoice(invoiceRow);
//
//     showCustomSnackbar(
//       title: "Success",
//       message: "Invoice saved successfully!",
//       baseColor: AppColors.darkGreenColor,
//       icon: Icons.check_circle_outline,
//     );
//     clearCart();
//     return true;
//   } catch (e) {
//     showCustomSnackbar(
//       title: "Error",
//       message: "Failed to save invoice: $e",
//       baseColor: Colors.red.shade700,
//       icon: Icons.error_outline,
//     );
//     print("Save invoice error: $e");
//     return false;
//   } finally {
//     isSavingInvoice.value = false;
//   }
// }



