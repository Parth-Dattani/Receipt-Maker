import 'package:demo_prac_getx/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../model/model.dart';

/// Working Code 28-09 edit Feature Give Here 4:59
// class NewChallanScreen extends GetView<NewChallanController> {
//   static const String pageId = '/NewChallanScreen';
//
//   const NewChallanScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('New Challan'),
//         backgroundColor: Colors.green.shade700,
//         foregroundColor: Colors.white,
//         // actions: [
//         //   Obx(() => controller.isLoading.value
//         //       ? Padding(
//         //     padding: EdgeInsets.all(16),
//         //     child: SizedBox(
//         //       width: 20,
//         //       height: 20,
//         //       child: CircularProgressIndicator(
//         //         strokeWidth: 2,
//         //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         //       ),
//         //     ),
//         //   )
//         //       : Row(
//         //     children: [
//         //       TextButton(
//         //         onPressed: () => controller.saveChallan(isDraft: true),
//         //         child: Text(
//         //           'Save Draft',
//         //           style: TextStyle(color: Colors.white),
//         //         ),
//         //       ),
//         //       TextButton(
//         //         onPressed: () => controller.saveChallan(isDraft: false),
//         //         child: Text(
//         //           'Create Challan',
//         //           style: TextStyle(
//         //             color: Colors.white,
//         //             fontWeight: FontWeight.bold,
//         //           ),
//         //         ),
//         //       ),
//         //     ],
//         //   )),
//         // ],
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Form(
//               key: controller.formKey,
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Challan Details Section
//                     _buildChallanDetailsCard(),
//
//                     SizedBox(height: 16),
//
//                     // Customer Section
//                     _buildCustomerSection(),
//
//                     SizedBox(height: 16),
//
//                     // Items Section
//                     _buildItemsSection(),
//
//                     SizedBox(height: 16),
//
//                     // Calculations Section
//                     _buildCalculationsSection(),
//
//                     SizedBox(height: 16),
//
//                     // Notes Section
//                     _buildNotesSection(),
//
//                     SizedBox(height: 32),
//
//                     // Action Buttons
//                     _buildActionButtons(),
//                   ],
//                 ),
//               ),
//             ),
//             Obx(() => controller.isLoading.value
//                 ? Container(
//               color: Colors.black.withOpacity(0.3),
//               child: Center(
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 10,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Loading...',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//                 : SizedBox.shrink()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildChallanDetailsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Challan Details',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green.shade700,
//               ),
//             ),
//             SizedBox(height: 16),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: controller.challanNumberController,
//                     decoration: InputDecoration(
//                       labelText: 'Challan Number',
//                       prefixIcon: Icon(Icons.receipt_long),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     controller: controller.challanDateController,
//                     decoration: InputDecoration(
//                       labelText: 'Challan Date',
//                       prefixIcon: Icon(Icons.calendar_today),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     readOnly: true,
//                     onTap: controller.selectChallanDate,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCustomerSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'Customer Information',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//                 Spacer(),
//                 IconButton(
//                   onPressed: controller.toggleCustomerForm,
//                   icon: Icon(
//                     controller.showCustomerForm.value
//                         ? Icons.person
//                         : Icons.person_add,
//                     color: Colors.green.shade700,
//                   ),
//                   tooltip: controller.showCustomerForm.value
//                       ? 'Select from existing customers'
//                       : 'Add new customer manually',
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Obx(() {
//               if (controller.customers.isEmpty && !controller.showCustomerForm.value) {
//                 return Column(
//                   children: [
//                     Text(
//                       'No customers found. Please add a customer.',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     SizedBox(height: 12),
//                     ElevatedButton(
//                       onPressed: controller.toggleCustomerForm,
//                       child: Text('Add New Customer'),
//                     ),
//                   ],
//                 );
//               } else if (!controller.showCustomerForm.value) {
//                 return Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: DropdownButton<Map<String, dynamic>>(
//                     value: controller.selectedCustomer.value,
//                     isExpanded: true,
//                     hint: Text('Select Customer'),
//                     underline: SizedBox(),
//                     items: [
//                       DropdownMenuItem(
//                         value: null,
//                         child: Text('Select Customer'),
//                       ),
//                       ...controller.customers.map((customer) {
//                         return DropdownMenuItem(
//                           value: customer,
//                           child: Text(customer['name'] ?? 'Unknown Customer'),
//                         );
//                       }).toList(),
//                     ],
//                     onChanged: controller.selectCustomer,
//                   ),
//                 );
//               } else {
//                 return Column(
//                   children: [
//                     SizedBox(height: 12),
//                     Text(
//                       'Add New Customer',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.orange.shade700,
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     TextFormField(
//                       controller: controller.customerNameController,
//                       decoration: InputDecoration(
//                         labelText: 'Customer Name *',
//                         prefixIcon: Icon(Icons.person),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter customer name';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             controller: controller.customerMobileController,
//                             decoration: InputDecoration(
//                               labelText: 'Mobile Number',
//                               prefixIcon: Icon(Icons.phone),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             keyboardType: TextInputType.phone,
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: TextFormField(
//                             controller: controller.customerEmailController,
//                             decoration: InputDecoration(
//                               labelText: 'Email',
//                               prefixIcon: Icon(Icons.email),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             keyboardType: TextInputType.emailAddress,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12),
//                     TextFormField(
//                       controller: controller.customerAddressController,
//                       decoration: InputDecoration(
//                         labelText: 'Address',
//                         prefixIcon: Icon(Icons.location_on),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       maxLines: 2,
//                     ),
//                   ],
//                 );
//               }
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildItemsSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'Challan Items',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//                 Spacer(),
//                 Obx(() => Text(
//                   'Total: ₹${controller.totalAmount.value}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green.shade700,
//                   ),
//                 )),
//               ],
//             ),
//             SizedBox(height: 16),
//
//             // Items list header
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: Text(
//                       'Item Description',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green.shade800,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       'Price (₹)',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green.shade800,
//                       ),
//                       textAlign: TextAlign.start,
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Text(
//                       'Qty',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green.shade800,
//                       ),
//                       textAlign: TextAlign.start,
//                     ),
//                   ),
//                   // Expanded(
//                   //   flex: 2,
//                   //   child: Text(
//                   //     'Price (₹)',
//                   //     style: TextStyle(
//                   //       fontWeight: FontWeight.bold,
//                   //       color: Colors.green.shade800,
//                   //     ),
//                   //     textAlign: TextAlign.center,
//                   //   ),
//                   // ),
//                   // Expanded(
//                   //   flex: 2,
//                   //   child: Text(
//                   //     'Amount',
//                   //     style: TextStyle(
//                   //       fontWeight: FontWeight.bold,
//                   //       color: Colors.green.shade800,
//                   //     ),
//                   //     textAlign: TextAlign.center,
//                   //   ),
//                   // ),
//                   // SizedBox(width: 40), // Space for delete button
//                 ],
//               ),
//             ),
//             SizedBox(height: 12),
//
//             Obx(() => Column(
//               children: [
//                 // Display message if no items available
//                 if (controller.itemList.isEmpty)
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     margin: EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.orange.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.info, color: Colors.orange.shade700),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'No items available. Please add items in your inventory first.',
//                             style: TextStyle(color: Colors.orange.shade800),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 /// Challan items list
//                 ...controller.challanItems.asMap().entries.map((entry) {
//                   int index = entry.key;
//                   ChallanItem item = entry.value;
//
//                   return Container(
//                     margin: EdgeInsets.only(bottom: 12),
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: Colors.grey.shade200),
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 2,
//                           offset: Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // ///Unit Section
//                         // Row(
//                         //   children: [
//                         //     Expanded(
//                         //       flex: 2,
//                         //       child: Column(
//                         //         crossAxisAlignment: CrossAxisAlignment.start,
//                         //         children: [
//                         //           Text("Unit", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                         //           SizedBox(height: 4),
//                         //           Container(
//                         //             height: 40,
//                         //             padding: EdgeInsets.symmetric(horizontal: 8),
//                         //             decoration: BoxDecoration(
//                         //               border: Border.all(color: Colors.grey.shade300),
//                         //               borderRadius: BorderRadius.circular(6),
//                         //             ),
//                         //             child: DropdownButton<String>(
//                         //               value: item.unit != null && ["kg", "gm", "ltr", "ml", "pcs"].contains(item.unit)
//                         //                   ? item.unit
//                         //                   : null,
//                         //               isExpanded: true,
//                         //               underline: SizedBox(),
//                         //               hint: Text('Unit', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
//                         //               items: ["kg", "gm", "ltr", "ml", "pcs"].map((u) {
//                         //                 return DropdownMenuItem(
//                         //                     value: u,
//                         //                     child: Text(u.toUpperCase(), style: TextStyle(fontSize: 14))
//                         //                 );
//                         //               }).toList(),
//                         //               onChanged: (value) {
//                         //                 double? qty = double.tryParse(value!);
//                         //                 if (qty != null && qty > 0) {
//                         //                   controller.updateItem(
//                         //                     index,
//                         //                     quantity: qty,
//                         //                     unit: item.unit,   // ✅ keep unit
//                         //                     price: item.price, // ✅ keep price
//                         //                   );
//                         //                 }
//                         //               },
//                         //
//                         //
//                         //             ),
//                         //           ),
//                         //         ],
//                         //       ),
//                         //     ),
//                         //     SizedBox(width: 12),
//                         //     Expanded(flex: 3, child: SizedBox()), // Spacer to maintain layout
//                         //   ],
//                         // ),
//                         SizedBox(height: 12),
//
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               flex: 3,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Item ${index + 1}',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey.shade700,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8),
//                                   if (controller.itemList.isNotEmpty)
//                                     Container(
//                                       height: 40,
//                                       padding: EdgeInsets.symmetric(horizontal: 8),
//                                       decoration: BoxDecoration(
//                                         border: Border.all(color: Colors.grey.shade300),
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                       child: DropdownButton<Item>(
//                                         value: controller.itemList.firstWhereOrNull(
//                                                 (element) => element.itemId == item.itemId
//                                         ),
//                                         isExpanded: true,
//                                         hint: Padding(
//                                           padding: EdgeInsets.symmetric(horizontal: 8),
//                                           child: Text('Select Item', style: TextStyle(fontSize: 14)),
//                                         ),
//                                         underline: SizedBox(),
//                                         icon: Padding(
//                                           padding: EdgeInsets.only(right: 8),
//                                           child: Icon(Icons.arrow_drop_down, size: 20),
//                                         ),
//                                         items: [
//                                           DropdownMenuItem(
//                                             value: null,
//                                             child: Padding(
//                                               padding: EdgeInsets.symmetric(horizontal: 8),
//                                               child: Text('Select Item', style: TextStyle(fontSize: 14)),
//                                             ),
//                                           ),
//                                           ...controller.itemList.map((item) {
//                                             return DropdownMenuItem(
//                                               value: item,
//                                               child: Padding(
//                                                 padding: EdgeInsets.symmetric(horizontal: 8),
//                                                 child: Text(
//                                                   '${item.itemName}',
//                                                   style: TextStyle(fontSize: 14),
//                                                 ),
//                                               ),
//                                             );
//                                           }).toList(),
//                                         ],
//                                         onChanged: (selectedItem) {
//                                           if (selectedItem != null) {
//                                             controller.selectRemoteItemForIndex(index, selectedItem);
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   if (controller.itemList.isEmpty)
//                                     TextFormField(
//                                       initialValue: item.description,
//                                       decoration: InputDecoration(
//                                         labelText: 'Item Description',
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(6),
//                                         ),
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                       ),
//                                       onChanged: (value) {
//                                         controller.updateItem(index, description: value);
//                                       },
//                                     ),
//                                 ],
//                               ),
//                             ),
//
//                             SizedBox(width: 12),
//
//                             /// Price
//                             Expanded(
//                               flex: 2,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Price ',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Container(
//                                     height: 40,
//                                     child: TextFormField(
//                                       controller: controller.getPriceController(index, initialValue: item.price),
//                                       textAlign: TextAlign.center,
//                                       decoration: InputDecoration(
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(6),
//                                         ),
//                                       ),
//                                       keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                       onChanged: (value) {
//                                         double? price = double.tryParse(value);
//                                         if (price != null && price >= 0) {
//                                           controller.updateItem(
//                                             index,
//                                             price: price,
//                                             unit: item.unit,   // keep selected unit
//                                             quantity: item.quantity,
//                                           );
//
//                                         }
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             SizedBox(width: 12),
//
//                             /// Quantity
//                             Expanded(
//                               flex: 1,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Qty',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Container(
//                                     height: 40,
//                                     child: TextFormField(
//                                       initialValue: item.quantity.toString(),
//                                       textAlign: TextAlign.center,
//                                       decoration: InputDecoration(
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(6),
//                                         ),
//                                       ),
//                                       keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                       onChanged: (value) {
//                                         double? qty = double.tryParse(value);
//
//                                         if (qty == null || qty <= 0) return;
//
//                                         // ✅ Validation based on unit
//                                         if (item.unit?.toLowerCase() == "pcs") {
//                                           if (qty % 1 != 0) {
//                                             // not a whole number → reset or show error
//                                             Get.snackbar(
//                                               "Invalid Qty",
//                                               "You can only enter whole numbers for PCS items.",
//                                               snackPosition: SnackPosition.BOTTOM,
//                                             );
//                                             return;
//                                           }
//                                         }
//
//                                         controller.updateItem(
//                                           index,
//                                           quantity: qty,
//                                           price: item.price,
//                                           unit: item.unit,
//                                         );
//                                       },
//
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//
//                             if (controller.challanItems.length > 1)
//                               SizedBox(
//                                 width: 20,
//                                 child: Padding(
//                                   padding: EdgeInsets.only(top: 20, left: 5),
//                                   child: IconButton(
//                                     onPressed: () => controller.removeItem(index),
//                                     icon: Icon(Icons.delete, color: Colors.red, size: 20),
//                                     padding: EdgeInsets.zero,
//                                     constraints: BoxConstraints(),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//
//                 /// Add item button
//                 SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: controller.addNewItem,
//                     icon: Icon(Icons.add_circle_outline, size: 20),
//                     label: Text('Add Another Item'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green.shade600,
//                       foregroundColor: Colors.white,
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Summary
//                 SizedBox(height: 16),
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.green.shade200),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Total Items:',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green.shade800,
//                         ),
//                       ),
//                       Text(
//                         '${controller.challanItems.length}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green.shade800,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             )),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCalculationsSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Calculations',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green.shade700,
//               ),
//             ),
//             SizedBox(height: 16),
//             Obx(() => Column(
//               children: [
//                 _buildTotalRow('Subtotal', controller.subtotal.value),
//                 // if (controller.taxRate.value > 0)
//                 //   _buildTotalRow('Tax: (${controller.taxRate.value}%)', controller.taxAmount.value),
//                 /// ✅ Show GST only when enabled
//                 if (AppConstants.withGST.value) ...[
//                   _buildTotalRow('CGST', controller.gstAmount.value / 2),
//                   _buildTotalRow('SGST', controller.gstAmount.value / 2),
//                 ],
//                 // _buildTotalRow('CGST', controller.gstAmount.value/2),
//                 // _buildTotalRow('SGST', controller.gstAmount.value/2),
//                 Divider(),
//                 _buildTotalRow('Total Amount', controller.totalAmount.value , isTotal: true),
//               ],
//             )),
//             SizedBox(height: 20),
//             Divider(),
//             Text("Payment Staus"),
//             Row(
//               children: [
//                 Expanded(
//                   child: Obx(() => Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: DropdownButton<String>(
//                       value: controller.paymentStatus.value,
//                       isExpanded: true,
//                       underline: SizedBox(),
//                       items: [
//                         DropdownMenuItem(value: 'Pending', child: Text('Pending')),
//                         DropdownMenuItem(value: 'Paid', child: Text('Paid')),
//                         DropdownMenuItem(value: 'Partial', child: Text('Partial')),
//                       ],
//                       onChanged: (value) {
//                         if (value != null) {
//                           controller.updatePaymentStatus(value);
//                         }
//                       },
//                     ),
//                   )),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ? Colors.green.shade700 : Colors.black87,
//             ),
//           ),
//           Text(
//             '₹${amount.toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ? Colors.green.shade700 : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotesSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Additional Notes',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green.shade700,
//               ),
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: controller.notesController,
//               decoration: InputDecoration(
//                 hintText: 'Add any additional notes or terms...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               maxLines: 4,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Obx(() => Row(
//       children: [
//         // Cancel button
//         Expanded(
//           flex: 2,
//           child: OutlinedButton(
//             onPressed: controller.isLoading.value ? null : () => Get.back(),
//             style: OutlinedButton.styleFrom(
//               padding: EdgeInsets.symmetric(vertical: 12),
//             ),
//             child: Text('Cancel'),
//           ),
//         ),
//         SizedBox(width: 8),
//
//         /// Main action button
//         Expanded(
//           flex: 4,
//           child: ElevatedButton(
//             onPressed: controller.isLoading.value ? null : () => controller.saveChallan(isDraft: false),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green.shade700,
//               padding: EdgeInsets.symmetric(vertical: 12),
//             ),
//             child: Text(
//               'Create Challan',
//               style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteColor),
//             ),
//           ),
//         ),
//       ],
//     ));
//   }
// }

class NewChallanScreen extends GetView<NewChallanController> {
  static const String pageId = '/NewChallanScreen';

  const NewChallanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isEditMode.value ? 'Edit Challan' : 'New Challan',
        )),
        backgroundColor: controller.isEditMode.value
            ? Colors.orange.shade700  // Different color for edit mode
            : Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Show different actions based on edit mode
          Obx(() => controller.isEditMode.value
              ? _buildEditModeActions()
              : const SizedBox.shrink()
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challan Details Section
                    _buildChallanDetailsCard(),

                    SizedBox(height: 16),

                    // Customer Section
                    _buildCustomerSection(),

                    SizedBox(height: 16),

                    // Items Section
                    _buildItemsSection(),

                    SizedBox(height: 16),

                    // Calculations Section
                    _buildCalculationsSection(),

                    SizedBox(height: 16),

                    // Notes Section
                    _buildNotesSection(),

                    SizedBox(height: 32),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
            Obx(() => controller.isLoading.value
                ? Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            controller.isEditMode.value
                                ? Colors.orange.shade700
                                : Colors.green.shade700
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.isEditMode.value ? 'Updating...' : 'Loading...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  /// AppBar actions for edit mode
  Widget _buildEditModeActions() {
    return Row(
      children: [
        // Delete button in edit mode
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () => _showDeleteConfirmation(),
          tooltip: 'Delete Challan',
        ),
        SizedBox(width: 8),
      ],
    );
  }



  Widget _buildChallanDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Challan Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.isEditMode.value
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
                Spacer(),
                // Show edit mode badge
                Obx(() => controller.isEditMode.value
                    ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'Edit Mode',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : SizedBox()
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.challanNumberController,
                    decoration: InputDecoration(
                      labelText: 'Challan Number',
                      prefixIcon: Icon(Icons.receipt_long),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                    style: TextStyle(
                      color: controller.isEditMode.value ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: controller.challanDateController,
                    decoration: InputDecoration(
                      labelText: 'Challan Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                    onTap: controller.selectChallanDate,
                  ),
                ),
              ],
            ),

            // Show original challan info in edit mode
            Obx(() {
              if (controller.isEditMode.value && controller.originalChallanData != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12),
                    Divider(),
                    Text(
                      'Original Challan Information:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date: ${controller.formatOriginalChallanDate()}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    // Text(
                    //   'Customer: ${controller.originalChallanData!['customerName'] ?? 'N/A'}',
                    //   style: TextStyle(
                    //     color: Colors.grey.shade600,
                    //     fontSize: 12,
                    //   ),
                    // ),
                  ],
                );
              }
              return SizedBox();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.isEditMode.value
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
                Spacer(),
                // Only show customer toggle in create mode
                Obx(() => !controller.isEditMode.value ? IconButton(
                  onPressed: controller.toggleCustomerForm,
                  icon: Icon(
                    controller.showCustomerForm.value
                        ? Icons.person
                        : Icons.person_add,
                    color: controller.isEditMode.value
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                  tooltip: controller.showCustomerForm.value
                      ? 'Select from existing customers'
                      : 'Add new customer manually',
                ) : SizedBox()),
              ],
            ),
            SizedBox(height: 16),
            Obx(() {
              if (controller.isEditMode.value) {
                // In edit mode, show customer info as read-only or editable fields
                return _buildEditModeCustomerInfo();
              } else {
                // Original customer selection logic for create mode
                if (controller.customers.isEmpty && !controller.showCustomerForm.value) {
                  return Column(
                    children: [
                      Text(
                        'No customers found. Please add a customer.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.toggleCustomerForm,
                        child: Text('Add New Customer'),
                      ),
                    ],
                  );
                } else if (!controller.showCustomerForm.value) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<Map<String, dynamic>>(
                      value: controller.selectedCustomer.value,
                      isExpanded: true,
                      hint: Text('Select Customer'),
                      underline: SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Select Customer'),
                        ),
                        ...controller.customers.map((customer) {
                          return DropdownMenuItem(
                            value: customer,
                            child: Text(customer['name'] ?? 'Unknown Customer'),
                          );
                        }).toList(),
                      ],
                      onChanged: controller.selectCustomer,
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      SizedBox(height: 12),
                      Text(
                        'Add New Customer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: controller.customerNameController,
                        decoration: InputDecoration(
                          labelText: 'Customer Name *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.customerMobileController,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: controller.customerEmailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: controller.customerAddressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  );
                }
              }
            }),
          ],
        ),
      ),
    );
  }



  /// Customer info display for edit mode
  Widget _buildEditModeCustomerInfo() {
    return Column(
      children: [
        /// Show original customer info
        // if (controller.originalChallanData != null) ...[
        //   Container(
        //     padding: EdgeInsets.all(12),
        //     decoration: BoxDecoration(
        //       color: Colors.grey.shade50,
        //       borderRadius: BorderRadius.circular(8),
        //       border: Border.all(color: Colors.grey.shade200),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(
        //           'Current Customer:',
        //           style: TextStyle(
        //             fontWeight: FontWeight.bold,
        //             color: Colors.grey.shade700,
        //           ),
        //         ),
        //         SizedBox(height: 8),
        //         Text('Name: ${controller.customerNameController.text}'),
        //         Text('Phone: ${controller.customerMobileController.text}'),
        //         Text('Email: ${controller.customerEmailController.text}'),
        //         if (controller.customerAddressController.text.isNotEmpty)
        //           Text('Address: ${controller.customerAddressController.text}'),
        //       ],
        //     ),
        //   ),
        //   SizedBox(height: 12),
        // ],

        // Editable customer fields
        TextFormField(
          controller: controller.customerNameController,
          decoration: InputDecoration(
            labelText: 'Customer Name *',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter customer name';
            }
            return null;
          },
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.customerMobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.customerEmailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: controller.customerAddressController,
          decoration: InputDecoration(
            labelText: 'Address',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Challan Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.isEditMode.value
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
                Spacer(),
                Obx(() => Text(
                  'Total: ₹${controller.totalAmount.value}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: controller.isEditMode.value
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                )),
              ],
            ),
            SizedBox(height: 16),

            // Show original items count in edit mode
            Obx(() {
              if (controller.isEditMode.value && controller.originalItemsCount > 0) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 16, color: Colors.orange.shade700),
                      SizedBox(width: 8),
                      Text(
                        'Originally had ${controller.originalItemsCount} items',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox();
            }),
            SizedBox(height: 12),

            // Items list header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: controller.isEditMode.value
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Item Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: controller.isEditMode.value
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price (₹)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: controller.isEditMode.value
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Qty',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: controller.isEditMode.value
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            Obx(() => Column(
              children: [
                // Display message if no items available
                if (controller.itemList.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade700),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No items available. Please add items in your inventory first.',
                            style: TextStyle(color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),

                /// Challan items list
                ...controller.challanItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  ChallanItem item = entry.value;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ///Unit Section
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       flex: 2,
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text("Unit", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        //           SizedBox(height: 4),
                        //           Container(
                        //             height: 40,
                        //             padding: EdgeInsets.symmetric(horizontal: 8),
                        //             decoration: BoxDecoration(
                        //               border: Border.all(color: Colors.grey.shade300),
                        //               borderRadius: BorderRadius.circular(6),
                        //             ),
                        //             child: DropdownButton<String>(
                        //               value: item.unit != null && ["kg", "gm", "ltr", "ml", "pcs"].contains(item.unit)
                        //                   ? item.unit
                        //                   : null,
                        //               isExpanded: true,
                        //               underline: SizedBox(),
                        //               hint: Text('Unit', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                        //               items: ["kg", "gm", "ltr", "ml", "pcs"].map((u) {
                        //                 return DropdownMenuItem(
                        //                     value: u,
                        //                     child: Text(u.toUpperCase(), style: TextStyle(fontSize: 14))
                        //                 );
                        //               }).toList(),
                        //               onChanged: (value) {
                        //                 double? qty = double.tryParse(value!);
                        //                 if (qty != null && qty > 0) {
                        //                   controller.updateItem(
                        //                     index,
                        //                     quantity: qty,
                        //                     unit: item.unit,   // ✅ keep unit
                        //                     price: item.price, // ✅ keep price
                        //                   );
                        //                 }
                        //               },
                        //
                        //
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     SizedBox(width: 12),
                        //     Expanded(flex: 3, child: SizedBox()), // Spacer to maintain layout
                        //   ],
                        // ),
                        SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Item ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (controller.itemList.isNotEmpty)
                                    Container(
                                      height: 40,
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: DropdownButton<Item>(
                                        value: controller.itemList.firstWhereOrNull(
                                                (element) => element.itemId == item.itemId
                                        ),
                                        isExpanded: true,
                                        hint: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: Text('Select Item', style: TextStyle(fontSize: 14)),
                                        ),
                                        underline: SizedBox(),
                                        icon: Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Icon(Icons.arrow_drop_down, size: 20),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              child: Text('Select Item', style: TextStyle(fontSize: 14)),
                                            ),
                                          ),
                                          ...controller.itemList.map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8),
                                                child: Text(
                                                  '${item.itemName}',
                                                  style: TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                        onChanged: (selectedItem) {
                                          if (selectedItem != null) {
                                            controller.selectRemoteItemForIndex(index, selectedItem);
                                          }
                                        },
                                      ),
                                    ),
                                  if (controller.itemList.isEmpty)
                                    TextFormField(
                                      initialValue: item.description,
                                      decoration: InputDecoration(
                                        labelText: 'Item Description',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                      onChanged: (value) {
                                        controller.updateItem(index, description: value);
                                      },
                                    ),
                                ],
                              ),
                            ),

                            SizedBox(width: 12),

                            /// Price
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    height: 40,
                                    child: TextFormField(
                                      controller: controller.getPriceController(index, initialValue: item.price),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (value) {
                                        double? price = double.tryParse(value);
                                        if (price != null && price >= 0) {
                                          controller.updateItem(
                                            index,
                                            price: price,
                                            unit: item.unit,   // keep selected unit
                                            quantity: item.quantity,
                                          );

                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 12),

                            /// Quantity
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Qty',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: item.quantity.toString(),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (value) {
                                        double? qty = double.tryParse(value);

                                        if (qty == null || qty <= 0) return;

                                        // ✅ Validation based on unit
                                        if (item.unit?.toLowerCase() == "pcs") {
                                          if (qty % 1 != 0) {
                                            // not a whole number → reset or show error
                                            Get.snackbar(
                                              "Invalid Qty",
                                              "You can only enter whole numbers for PCS items.",
                                              snackPosition: SnackPosition.BOTTOM,
                                            );
                                            return;
                                          }
                                        }

                                        controller.updateItem(
                                          index,
                                          quantity: qty,
                                          price: item.price,
                                          unit: item.unit,
                                        );
                                      },

                                    ),
                                  ),
                                ],
                              ),
                            ),


                            if (controller.challanItems.length > 1)
                              SizedBox(
                                width: 20,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20, left: 5),
                                  child: IconButton(
                                    onPressed: () => controller.removeItem(index),
                                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),

                /// Add item button
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.addNewItem,
                    icon: Icon(Icons.add_circle_outline, size: 20),
                    label: Text('Add Another Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Summary
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        '${controller.challanItems.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.isEditMode.value
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
              ),
            ),
            SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildTotalRow('Subtotal', controller.subtotal.value),
                if (AppConstants.withGST.value) ...[
                  _buildTotalRow('CGST', controller.gstAmount.value / 2),
                  _buildTotalRow('SGST', controller.gstAmount.value / 2),
                ],
                Divider(),
                _buildTotalRow('Total Amount', controller.totalAmount.value , isTotal: true),
              ],
            )),
            SizedBox(height: 20),
            Divider(),
            Text("Payment Status"),
            Row(
              children: [
                Expanded(
                  child: Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: controller.paymentStatus.value,
                      isExpanded: true,
                      underline: SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                        DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.updatePaymentStatus(value);
                        }
                      },
                    ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ?
              (controller.isEditMode.value ? Colors.orange.shade700 : Colors.green.shade700)
                  : Colors.black87,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ?
              (controller.isEditMode.value ? Colors.orange.shade700 : Colors.green.shade700)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.isEditMode.value
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controller.notesController,
              decoration: InputDecoration(
                hintText: 'Add any additional notes or terms...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() => Row(
      children: [
        // Cancel button
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: controller.isLoading.value ? null : () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: 8),

        /// Main action button - different text for edit mode
        Expanded(
          flex: 4,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.saveChallan(isDraft: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isEditMode.value
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              controller.isEditMode.value ? 'Update Challan' : 'Create Challan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    ));
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Challan'),
        content: Text('Are you sure you want to delete this challan? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              //controller.deleteChallan();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
