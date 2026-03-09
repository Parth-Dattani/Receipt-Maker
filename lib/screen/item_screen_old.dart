// import 'package:GetYourInvoice/constant/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controller/item_controller.dart';
// import '../model/model.dart';
// import '../utils/pdf_helper.dart';
// import '../widgets/widgets.dart';
//
// class ItemScreen extends GetView<ItemController> {
//   static const pageId = "/ItemScreen";
//
//   const ItemScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.tealColor,
//         leading:  Icon(Icons.menu, color: AppColors.whiteColor),
//         title:  Text(
//           "Items",
//           style: TextStyle(color: AppColors.whiteColor),
//         ),
//         actions: [
//           Obx(() {
//             return Stack(
//               children: [
//                 IconButton(
//                   icon:  Icon(Icons.shopping_cart, color: AppColors.whiteColor),
//                   onPressed: controller.cart.isEmpty
//                       ? null
//                       : () => _showCartDialog(context),
//                 ),
//                 if (controller.cart.isNotEmpty)
//                   Positioned(
//                     right: 8,
//                     top: 8,
//                     child: CircleAvatar(
//                       radius: 8,
//                       backgroundColor: Colors.red,
//                       child: Text(
//                         "${controller.cart.length}",
//                         style: const TextStyle(fontSize: 10, color: Colors.white),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           }),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return ListView.builder(
//           itemCount: controller.itemList.length,
//           itemBuilder: (context, index) {
//             final item = controller.itemList[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(12),
//                 title: Text(
//                   item.itemName,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Text(
//                   "₹${item.price.toStringAsFixed(2)}",
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     addToCartBtn(item),
//                     IconButton(
//                       icon: const Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () {
//                         _showEditItemDialog(context, item);
//                       },
//                     ),
//                     // IconButton(
//                     //   icon: const Icon(Icons.delete, color: Colors.red),
//                     //   onPressed: () => _confirmDelete(context, item),
//                     // ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.tealColor,
//         onPressed: () => _showAddItemDialog(context),
//         child:  Icon(Icons.add, color: AppColors.whiteColor),
//       ),
//     );
//   }
//
//   /// ✅ Add to Cart Button
//   Widget addToCartBtn(Item item) {
//     return Obx(() {
//       final inCart = controller.cart.any((e) => e.itemId == item.itemId);
//
//       return ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: inCart ? Colors.orange : AppColors.tealColor,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           minimumSize: const Size(90, 36),
//         ),
//         icon: Icon(inCart ? Icons.check : Icons.add_shopping_cart, size: 18),
//         label: Text(
//           inCart ? "Added" : "Add",
//           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//         ),
//         onPressed: () {
//           if (!inCart) {
//             controller.addToCart(item);
//             showCustomSnackbar(
//               title: "Added",
//               message: "${item.itemName} added to cart",
//               baseColor: AppColors.darkGreenColor,
//               icon: Icons.add_shopping_cart,
//             );
//           } else {
//             // optional: open cart directly if already added
//             _showCartDialog(Get.context!);
//           }
//         },
//       );
//     });
//   }
//
//   void _showAddItemDialog(BuildContext context) {
//     final nameCtrl = TextEditingController();
//     final priceCtrl = TextEditingController();
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         bool isAdding = false;
//
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               elevation: 8,
//               insetPadding: EdgeInsets.all(16),
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.5,
//                   maxWidth: 400,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Add New Item",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.tealColor,
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.close, color: AppColors.tealColor),
//                           onPressed: isAdding ? null : () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     TextFormField(
//                       controller: nameCtrl,
//                       decoration: InputDecoration(
//                         labelText: "Item Name",
//                         hintText: "Enter item name",
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                         filled: true,
//                         fillColor: Colors.grey.shade50,
//                         prefixIcon: Icon(Icons.label_outline, color: AppColors.tealColor),
//                       ),
//                       enabled: !isAdding,
//                     ),
//                     SizedBox(height: 12),
//                     TextFormField(
//                       controller: priceCtrl,
//                       decoration: InputDecoration(
//                         labelText: "Price",
//                         hintText: "Enter price",
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                         filled: true,
//                         fillColor: Colors.grey.shade50,
//                         prefixIcon: Icon(Icons.currency_rupee_outlined, color: AppColors.tealColor),
//                       ),
//                       keyboardType: TextInputType.number,
//                       enabled: !isAdding,
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           onPressed: isAdding ? null : () => Navigator.pop(context),
//                           child: Text(
//                             "Cancel",
//                             style: TextStyle(
//                               color: Colors.grey.shade700,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.tealColor,
//                             foregroundColor: AppColors.whiteColor,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                             elevation: 3,
//                           ),
//                           onPressed: isAdding
//                               ? null
//                               : () async {
//                             setState(() => isAdding = true);
//
//                             final name = nameCtrl.text.trim();
//                             final price = double.tryParse(priceCtrl.text) ?? 0.0;
//
//                             if (name.isEmpty) {
//                               setState(() => isAdding = false);
//                               showCustomSnackbar(
//                                 title: "Error",
//                                 message: "Item name cannot be empty",
//                                 baseColor: Colors.red.shade700,
//                                 icon: Icons.error_outline,
//                               );
//                               return;
//                             }
//                             if (price <= 0) {
//                               setState(() => isAdding = false);
//                               showCustomSnackbar(
//                                 title: "Error",
//                                 message: "Price must be greater than 0",
//                                 baseColor: Colors.red.shade700,
//                                 icon: Icons.error_outline,
//                               );
//                               return;
//                             }
//
//                             try {
//                               await controller.addNewItem(name, price);
//                               Navigator.pop(context);
//                             } catch (e) {
//                               setState(() => isAdding = false);
//                               showCustomSnackbar(
//                                 title: "Error",
//                                 message: "Failed to save item: $e",
//                                 baseColor: Colors.red.shade700,
//                                 icon: Icons.error_outline,
//                               );
//                             }
//                           },
//                           child: isAdding
//                               ? SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
//                             ),
//                           )
//                               : Text(
//                             "Add",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showCartDialog(BuildContext context) {
//     final nameCtrl = TextEditingController();
//     final phoneCtrl = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     bool isFormValid = false;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             void validateForm() {
//               final isValid = formKey.currentState?.validate() ?? false;
//               if (isValid != isFormValid) {
//                 setState(() {
//                   isFormValid = isValid;
//                 });
//               }
//             }
//
//             return Dialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               elevation: 8,
//               insetPadding: EdgeInsets.all(16),
//               child: Container(
//                 constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.85,
//                   maxWidth: 400,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppColors.tealColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Your Cart",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.tealColor,
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.close, color: AppColors.tealColor),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: Obx(() {
//                         if (controller.cart.isEmpty) {
//                           return Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   "Your cart is empty",
//                                   style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                         return ListView.builder(
//                           shrinkWrap: true,
//                           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           itemCount: controller.cart.length,
//                           itemBuilder: (context, index) {
//                             final item = controller.cart[index];
//                             return Card(
//                               margin: EdgeInsets.symmetric(vertical: 8),
//                               elevation: 2,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               child: ListTile(
//                                 contentPadding: EdgeInsets.all(12),
//                                 title: Text(
//                                   "${item.itemName}",
//                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                                 ),
//                                 subtitle: Text(
//                                   "₹${item.price.toStringAsFixed(2)} x ${item.qty} = ₹${(item.price * item.qty).toStringAsFixed(2)}",
//                                   style: TextStyle(color: Colors.grey.shade600),
//                                 ),
//                                 trailing: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400),
//                                       onPressed: () {
//                                         if (item.qty > 1) {
//                                           controller.cart[index] = Invoice(
//                                             invoiceId: item.invoiceId,
//                                             itemId: item.itemId,
//                                             itemName: item.itemName,
//                                             qty: item.qty - 1,
//                                             price: item.price,
//                                             mobile: item.mobile,
//                                             customerName: item.customerName,
//                                           );
//                                           showCustomSnackbar(
//                                             title: "Updated",
//                                             message: "${item.itemName} quantity decreased to ${item.qty - 1}",
//                                             baseColor: AppColors.darkGreenColor,
//                                             icon: Icons.remove_shopping_cart,
//                                           );
//                                         } else {
//                                           controller.removeFromCart(item.itemId);
//                                           showCustomSnackbar(
//                                             title: "Removed",
//                                             message: "${item.itemName} removed from cart",
//                                             baseColor: Colors.red.shade700,
//                                             icon: Icons.delete_outline,
//                                           );
//                                         }
//                                       },
//                                     ),
//                                     Text(
//                                       "${item.qty}",
//                                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                                     ),
//                                     IconButton(
//                                       icon: Icon(Icons.add_circle_outline, color: AppColors.darkGreenColor),
//                                       onPressed: () {
//                                         controller.cart[index] = Invoice(
//                                           invoiceId: item.invoiceId,
//                                           itemId: item.itemId,
//                                           itemName: item.itemName,
//                                           qty: item.qty + 1,
//                                           price: item.price,
//                                           mobile: item.mobile,
//                                           customerName: item.customerName,
//                                         );
//                                         showCustomSnackbar(
//                                           title: "Updated",
//                                           message: "${item.itemName} quantity increased to ${item.qty + 1}",
//                                           baseColor: AppColors.darkGreenColor,
//                                           icon: Icons.add_shopping_cart,
//                                         );
//                                       },
//                                     ),
//                                     IconButton(
//                                       icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
//                                       onPressed: () {
//                                         controller.removeFromCart(item.itemId);
//                                         showCustomSnackbar(
//                                           title: "Removed",
//                                           message: "${item.itemName} removed from cart",
//                                           baseColor: Colors.red.shade700,
//                                           icon: Icons.delete_outline,
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       }),
//                     ),
//                     Divider(height: 1, thickness: 1),
//                     Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Form(
//                         key: formKey,
//                         child: Column(
//                           children: [
//                             TextFormField(
//                               controller: nameCtrl,
//                               decoration: InputDecoration(
//                                 labelText: "User Name",
//                                 hintText: "Enter your name",
//                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                                 filled: true,
//                                 fillColor: Colors.grey.shade50,
//                                 prefixIcon: Icon(Icons.person_outline, color: AppColors.tealColor),
//                               ),
//                               validator: (value) => value == null || value.trim().isEmpty ? "Enter name" : null,
//                               onChanged: (value) => validateForm(),
//                             ),
//                             SizedBox(height: 12),
//                             TextFormField(
//                               controller: phoneCtrl,
//                               decoration: InputDecoration(
//                                 labelText: "Phone Number",
//                                 hintText: "Enter 10-digit phone number",
//                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                                 filled: true,
//                                 fillColor: Colors.grey.shade50,
//                                 prefixIcon: Icon(Icons.phone_outlined, color: AppColors.tealColor),
//                               ),
//                               keyboardType: TextInputType.phone,
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) return "Enter phone";
//                                 if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) return "Enter valid 10-digit number";
//                                 return null;
//                               },
//                               onChanged: (value) => validateForm(),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppColors.tealColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//                       ),
//                       child: Obx(() {
//                         final double total = controller.cart.fold(0, (sum, item) => sum + (item.price * item.qty));
//                         return Column(
//                           children: [
//                             Text(
//                               "Total: ₹${total.toStringAsFixed(2)}",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.tealColor,
//                               ),
//                             ),
//                             SizedBox(height: 12),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.tealColor,
//                                 foregroundColor: AppColors.whiteColor,
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                 minimumSize: Size(double.infinity, 50),
//                                 elevation: 3,
//                               ),
//                               onPressed: isFormValid && controller.cart.isNotEmpty
//                                   ? () async {
//                                 final phone = phoneCtrl.text.trim();
//                                 final userName = nameCtrl.text.trim();
//
//                                 try {
//                                   // Save to invoices table with userName
//
//                                   final cartCopy = controller.cart.toList();
//                                   final saved = await controller.saveInvoice(cartCopy, userName, phone);
//                                   if (saved) {
//                                     await InvoiceHelper.generateAndShareInvoice(cartCopy, userName, phone);
//                                     // Now you can clear the cart if you want
//                                     controller.clearCart();
//
//                                   }
//                                   Navigator.pop(context);
//                                   showCustomSnackbar(
//                                     title: "Success",
//                                     message: "Invoice saved successfully!",
//                                     baseColor: AppColors.darkGreenColor,
//                                     icon: Icons.check_circle_outline,
//                                   );
//                                 } catch (e) {
//                                   showCustomSnackbar(
//                                     title: "Error",
//                                     message: "Failed to save invoice: $e",
//                                     baseColor: Colors.red.shade700,
//                                     icon: Icons.error_outline,
//                                   );
//                                 }
//                               }
//                                   : null,
//                               child: Text(
//                                 "Generate Invoice",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ],
//                         );
//                       }),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   /// ✅ Edit Item Dialog
//   void _showEditItemDialog(BuildContext context, Item item) {
//     final nameCtrl = TextEditingController(text: item.itemName);
//     final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(2));
//
//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: const Text("Edit Item"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameCtrl,
//                 decoration: const InputDecoration(labelText: "Item Name"),
//               ),
//               TextField(
//                 controller: priceCtrl,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(labelText: "Price"),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final newName = nameCtrl.text;
//                 final newPrice = double.tryParse(priceCtrl.text) ?? item.price;
//
//                 await controller.editItem(item.itemId, newName, newPrice);
//
//                 // ✅ Safer way
//                 if (Get.isDialogOpen ?? false) {
//                   Get.back(); // closes dialog safely
//                 }
//               },
//               child: const Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
// }
//
// /// ✅ Delete Confirmation
// // void _confirmDelete(BuildContext context, Item item) {
// //   showDialog(
// //     context: context,
// //     builder: (_) => AlertDialog(
// //       title: const Text("Delete Item"),
// //       content: Text("Are you sure you want to delete '${item.itemName}'?"),
// //       actions: [
// //         TextButton(
// //           onPressed: () => Navigator.pop(context),
// //           child: const Text("Cancel"),
// //         ),
// //         ElevatedButton(
// //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //           onPressed: () async {
// //             await controller.deleteItem(item.itemId);
// //             Navigator.pop(context);
// //             showCustomSnackbar(
// //               title: "Deleted",
// //               message: "${item.itemName} deleted successfully",
// //               baseColor: Colors.red.shade700,
// //               icon: Icons.delete_outline,
// //             );
// //           },
// //           child: const Text("Delete"),
// //         ),
// //       ],
// //     ),
// //   );
// // }
//
