// import 'package:demo_prac_getx/model/model.dart';
// import 'package:demo_prac_getx/services/remote_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../constant/app_colors.dart';
// import '../widgets/widgets.dart';
//
//
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
//
// ///for Single row
// //   Future<bool> saveInvoice(List<Invoice> invoices, String userName, String phone) async {
// //   if (invoices.isEmpty) {
// //     showCustomSnackbar(
// //       title: "Error",
// //       message: "Cart is empty",
// //       baseColor: Colors.red.shade700,
// //       icon: Icons.error_outline,
// //     );
// //     return false;
// //   }
// //   isSavingInvoice.value = true;
// //   try {
// //     // Generate one invoiceId for the whole invoice
// //     final String invoiceId = "INV-${DateTime.now().millisecondsSinceEpoch}";
// //
// //     // Combine all items into a single string
// //     final itemsString = invoices.map((e) => "${e.itemName} x${e.qty} @ ₹${e.price}").join(", ");
// //
// //     // Create a single invoice row
// //     final invoiceRow = {
// //       "invoiceId": invoiceId,
// //       "items": itemsString,
// //       "customerName": userName,
// //       "mobile": phone,
// //       "total": invoices.fold(0.0, (sum, e) => sum + (e.qty * e.price)).toStringAsFixed(2),
// //
// //     };
// //
// //     print("Sending single invoice row: $invoiceRow");
// //     await RemoteService.addSingleInvoice(invoiceRow);
// //
// //     showCustomSnackbar(
// //       title: "Success",
// //       message: "Invoice saved successfully!",
// //       baseColor: AppColors.darkGreenColor,
// //       icon: Icons.check_circle_outline,
// //     );
// //     clearCart();
// //     return true;
// //   } catch (e) {
// //     showCustomSnackbar(
// //       title: "Error",
// //       message: "Failed to save invoice: $e",
// //       baseColor: Colors.red.shade700,
// //       icon: Icons.error_outline,
// //     );
// //     print("Save invoice error: $e");
// //     return false;
// //   } finally {
// //     isSavingInvoice.value = false;
// //   }
// // }
//
//
//
