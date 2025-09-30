import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/controller.dart';
import '../../model/model.dart';


///After NNo 4:19 28-09
//   class ChallanDetailsScreen extends GetView<ChallanDetailsController> {
//     static const String pageId = '/ChallanDetailsScreen';
//
//     const ChallanDetailsScreen({Key? key}) : super(key: key);
//
//     @override
//     Widget build(BuildContext context) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text("Challan Details"),
//           actions: [
//             Obx(() => controller.isEditMode.value
//                 ? IconButton(
//               icon: const Icon(Icons.save),
//               tooltip: "Save Changes",
//               onPressed: () => controller.updateChallan(),
//             )
//                 : IconButton(
//               icon: const Icon(Icons.edit),
//               tooltip: "Edit Items",
//               onPressed: () => controller.enterEditMode(),
//             )),
//             Obx(() => controller.isLoadingItems.value
//                 ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2))
//                 : IconButton(
//               icon: const Icon(Icons.refresh, size: 20),
//               onPressed: () => controller.refreshChallanItems(),
//               tooltip: "Refresh Items",
//             )),
//           ],
//           backgroundColor: Colors.blue.shade700,
//           foregroundColor: Colors.white,
//         ),
//         body: Obx(() {
//           final challan = controller.challan.value;
//           if (challan == null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline,
//                       size: 64, color: Colors.grey.shade400),
//                   const SizedBox(height: 16),
//                   Text("Challan not found",
//                       style: TextStyle(
//                           fontSize: 18, color: Colors.grey.shade600)),
//                 ],
//               ),
//             );
//           }
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildChallanHeader(challan),
//                 const SizedBox(height: 24),
//                 _buildCustomerInfo(challan),
//                 const SizedBox(height: 24),
//                 _buildChallanItems(),
//                 const SizedBox(height: 24),
//                 _buildPaymentSummary(challan),
//               ],
//             ),
//           );
//         }),
//       );
//     }
//
//     /// Challan header (ID, Date, Status)
//     Widget _buildChallanHeader(Challan challan) {
//       return Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Challan ${challan.challanId ?? 'N/A'}",
//                     style: const TextStyle(
//                         fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   Container(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(challan.status),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       challan.status ?? "Unknown",
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 "Date: ${_formatDate(challan.challanDate)}",
//                 style: TextStyle(
//                     color: Colors.grey.shade600, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     /// Customer details
//     Widget _buildCustomerInfo(Challan challan) {
//       return Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Customer Information",
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue.shade700)),
//               const SizedBox(height: 12),
//               _buildInfoRow("Name:", challan.customerName ?? "N/A"),
//               _buildInfoRow("Email:", challan.customerEmail ?? "N/A"),
//               _buildInfoRow("Phone:", challan.customerMobile ?? "N/A"),
//               _buildInfoRow("Address:", challan.customerAddress ?? "N/A"),
//             ],
//           ),
//         ),
//       );
//     }
//
//     /// Items list
//     Widget _buildChallanItems() {
//       return Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Challan Items",
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue.shade700)),
//                   Obx(() => controller.isLoadingItems.value
//                       ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2))
//                       : IconButton(
//                     icon: const Icon(Icons.refresh, size: 20),
//                     onPressed:controller.refreshChallanItems,
//                     tooltip: "Refresh Items",
//                   )),
//                 ],
//               ),
//               const SizedBox(height: 12),
//
//               /// Items list
//               Obx(() {
//                 if (controller.isLoadingItems.value) {
//                   return const Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(20),
//                         child: CircularProgressIndicator(),
//                       ));
//                 }
//
//                 if (controller.challanItems.isEmpty) {
//                   return Container(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       children: [
//                         Icon(Icons.inbox,
//                             size: 48, color: Colors.grey.shade400),
//                         const SizedBox(height: 8),
//                         Text("No items found",
//                             style: TextStyle(color: Colors.grey.shade600)),
//                       ],
//                     ),
//                   );
//                 }
//
//                 final itemsSubtotal = controller.challanItems.fold(
//                     0.0,
//                         (s, it) =>
//                     s + ((it.quantity ?? 0) * (it.price ?? 0.0)));
//
//                 // return Column(
//                 //   children: [
//                 //     // header
//                 //     Container(
//                 //       padding: const EdgeInsets.symmetric(
//                 //           vertical: 8, horizontal: 12),
//                 //       decoration: BoxDecoration(
//                 //           color: Colors.grey.shade100,
//                 //           borderRadius: BorderRadius.circular(8)),
//                 //       child: Row(
//                 //         children: const [
//                 //           Expanded(
//                 //               flex: 3,
//                 //               child: Text("Item",
//                 //                   style: TextStyle(
//                 //                       fontWeight: FontWeight.bold))),
//                 //           Expanded(
//                 //               flex: 1,
//                 //               child: Text("Qty",
//                 //                   textAlign: TextAlign.center,
//                 //                   style: TextStyle(
//                 //                       fontWeight: FontWeight.bold))),
//                 //           Expanded(
//                 //               flex: 2,
//                 //               child: Text("Price",
//                 //                   textAlign: TextAlign.right,
//                 //                   style: TextStyle(
//                 //                       fontWeight: FontWeight.bold))),
//                 //           Expanded(
//                 //               flex: 2,
//                 //               child: Text("Total",
//                 //                   textAlign: TextAlign.right,
//                 //                   style: TextStyle(
//                 //                       fontWeight: FontWeight.bold))),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //     const SizedBox(height: 8),
//                 //
//                 //     // rows
//                 //     ...controller.challanItems.map((item) => Container(
//                 //       padding: const EdgeInsets.symmetric(
//                 //           vertical: 12, horizontal: 12),
//                 //       margin: const EdgeInsets.only(bottom: 8),
//                 //       decoration: BoxDecoration(
//                 //           color: Colors.grey.shade50,
//                 //           borderRadius: BorderRadius.circular(8),
//                 //           border:
//                 //           Border.all(color: Colors.grey.shade200)),
//                 //       child: Row(
//                 //         children: [
//                 //           Expanded(
//                 //               flex: 3,
//                 //               child: Text(item.itemName ?? "N/A",
//                 //                   style: const TextStyle(
//                 //                       fontWeight: FontWeight.w500))),
//                 //           Expanded(
//                 //               flex: 1,
//                 //               child: Text("${item.quantity ?? 0}",
//                 //                   textAlign: TextAlign.center)),
//                 //           Expanded(
//                 //               flex: 2,
//                 //               child: Text(
//                 //                   "₹${(item.price ?? 0).toStringAsFixed(2)}",
//                 //                   textAlign: TextAlign.right)),
//                 //           Expanded(
//                 //               flex: 2,
//                 //               child: Text(
//                 //                   "₹${((item.quantity ?? 0) * (item.price ?? 0)).toStringAsFixed(2)}",
//                 //                   textAlign: TextAlign.right,
//                 //                   style: TextStyle(
//                 //                       fontWeight: FontWeight.bold,
//                 //                       color: Colors.green.shade700))),
//                 //         ],
//                 //       ),
//                 //     )),
//                 //
//                 //     const SizedBox(height: 12),
//                 //     Container(
//                 //       padding: const EdgeInsets.symmetric(
//                 //           vertical: 8, horizontal: 12),
//                 //       decoration: BoxDecoration(
//                 //           color: Colors.blue.shade50,
//                 //           borderRadius: BorderRadius.circular(8),
//                 //           border:
//                 //           Border.all(color: Colors.blue.shade200)),
//                 //       child: Row(
//                 //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 //         children: [
//                 //           Text("Items Subtotal (${controller.challanItems.length} items):",
//                 //               style: TextStyle(
//                 //                   fontWeight: FontWeight.bold,
//                 //                   color: Colors.blue.shade700)),
//                 //           Text("₹${itemsSubtotal.toStringAsFixed(2)}",
//                 //               style: TextStyle(
//                 //                   fontWeight: FontWeight.bold,
//                 //                   color: Colors.blue.shade700,
//                 //                   fontSize: 16)),
//                 //         ],
//                 //       ),
//                 //     )
//                 //   ],
//                 // );
//                 return Column(
//                   children: [
//                     // header
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                       decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: Row(
//                         children: const [
//                           Expanded(
//                               flex: 3,
//                               child: Text("Item",
//                                   style: TextStyle(fontWeight: FontWeight.bold))),
//                           Expanded(
//                               flex: 1,
//                               child: Text("Qty",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(fontWeight: FontWeight.bold))),
//                           Expanded(
//                               flex: 2,
//                               child: Text("Price",
//                                   textAlign: TextAlign.right,
//                                   style: TextStyle(fontWeight: FontWeight.bold))),
//                           Expanded(
//                               flex: 2,
//                               child: Text("Total",
//                                   textAlign: TextAlign.right,
//                                   style: TextStyle(fontWeight: FontWeight.bold))),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//
//                     // rows (switch between view/edit mode)
//                     Obx(() {
//                       if (controller.isEditMode.value) {
//                         return Column(
//                           children: List.generate(controller.editableItems.length, (index) {
//                             final ctrls = controller.editableItems[index];
//                             return Container(
//                               padding:
//                               const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                               margin: const EdgeInsets.only(bottom: 8),
//                               decoration: BoxDecoration(
//                                   color: Colors.grey.shade50,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: Colors.grey.shade200)),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 3,
//                                     child: TextField(
//                                       controller: ctrls['itemName'],
//                                       decoration: const InputDecoration(
//                                         hintText: "Item name",
//                                         border: InputBorder.none,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: TextField(
//                                       controller: ctrls['qty'],
//                                       textAlign: TextAlign.center,
//                                       keyboardType: TextInputType.number,
//                                       decoration: const InputDecoration(
//                                         border: InputBorder.none,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 2,
//                                     child: TextField(
//                                       controller: ctrls['rate'],
//                                       textAlign: TextAlign.right,
//                                       keyboardType: TextInputType.number,
//                                       decoration: const InputDecoration(
//                                         border: InputBorder.none,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 2,
//                                     child: Obx(() => Text(
//                                       "₹${controller.calculateItemTotal(index).toStringAsFixed(2)}",
//                                       textAlign: TextAlign.right,
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.green.shade700),
//                                     )),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.delete, color: Colors.red),
//                                     onPressed: () => controller.removeItem(index),
//                                   )
//                                 ],
//                               ),
//                             );
//                           }),
//                         );
//                       } else {
//                         return Column(
//                           children: controller.challanItems.map((item) {
//                             return Container(
//                               padding:
//                               const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                               margin: const EdgeInsets.only(bottom: 8),
//                               decoration: BoxDecoration(
//                                   color: Colors.grey.shade50,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: Colors.grey.shade200)),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                       flex: 3,
//                                       child: Text(item.itemName ?? "N/A",
//                                           style:
//                                           const TextStyle(fontWeight: FontWeight.w500))),
//                                   Expanded(
//                                       flex: 1,
//                                       child: Text("${item.quantity ?? 0}",
//                                           textAlign: TextAlign.center)),
//                                   Expanded(
//                                       flex: 2,
//                                       child: Text(
//                                           "₹${(item.price ?? 0).toStringAsFixed(2)}",
//                                           textAlign: TextAlign.right)),
//                                   Expanded(
//                                       flex: 2,
//                                       child: Text(
//                                           "₹${((item.quantity ?? 0) * (item.price ?? 0)).toStringAsFixed(2)}",
//                                           textAlign: TextAlign.right,
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.green.shade700))),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         );
//                       }
//                     }),
//
//                     const SizedBox(height: 12),
//
//                     // subtotal (different for edit/view mode)
//                     Obx(() {
//                       final subtotal = controller.isEditMode.value
//                           ? controller.calculatedTotal
//                           : controller.challanItems.fold<double>(
//                         0.0,
//                             (s, it) => s + ((it.quantity ?? 0) * (it.price ?? 0.0)),
//                       );
//                       final itemCount = controller.isEditMode.value
//                           ? controller.editableItems.length
//                           : controller.challanItems.length;
//
//                       return Container(
//                         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                         decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.blue.shade200)),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Items Subtotal ($itemCount items):",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue.shade700)),
//                             Text("₹${subtotal.toStringAsFixed(2)}",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue.shade700,
//                                     fontSize: 16)),
//                           ],
//                         ),
//                       );
//                     }),
//
//                     // add button (only in edit mode)
//                     Obx(() => controller.isEditMode.value
//                         ? Align(
//                       alignment: Alignment.centerLeft,
//                       child: TextButton.icon(
//                         icon: const Icon(Icons.add),
//                         label: const Text("Add Item"),
//                         onPressed: controller.addNewItem,
//                       ),
//                     )
//                         : const SizedBox.shrink())
//                   ],
//                 );
//
//               })
//             ],
//           ),
//         ),
//       );
//     }
//
//     /// Payment summary
//     Widget _buildPaymentSummary(Challan challan) {
//       final subtotal = challan.subtotal ?? 0.0;
//       final tax = challan.gstAmount ?? 0.0;
//       final total = challan.subtotal ?? (subtotal + tax);
//
//       return Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Payment Summary",
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue.shade700)),
//               const SizedBox(height: 12),
//               _buildInfoRow("Subtotal:", "₹${subtotal.toStringAsFixed(2)}"),
//               _buildInfoRow("Tax:", "₹${tax.toStringAsFixed(2)}"),
//               const Divider(thickness: 2),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Total Amount:",
//                       style:
//                       TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   Text("₹${total.toStringAsFixed(2)}",
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green.shade700)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     /// Reusable info row
//     Widget _buildInfoRow(String label, String value) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4),
//         child: Row(
//           children: [
//             SizedBox(
//                 width: 90,
//                 child: Text(label,
//                     style: TextStyle(color: Colors.grey.shade600))),
//             Expanded(
//                 child: Text(value,
//                     style: const TextStyle(fontWeight: FontWeight.w500))),
//           ],
//         ),
//       );
//     }
//
//     String _formatDate(DateTime? date) {
//       if (date == null) return "-";
//       return DateFormat("MMM dd, yyyy").format(date);
//     }
//
//
//     Color _getStatusColor(String? status) {
//       switch (status?.toLowerCase()) {
//         case "completed":
//           return Colors.green;
//         case "pending":
//           return Colors.orange;
//         case "cancelled":
//           return Colors.red;
//         default:
//           return Colors.grey;
//       }
//     }
//   }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChallanDetailsScreen extends GetView<ChallanDetailsController> {
  static const String pageId = '/ChallanDetailsScreen';

  const ChallanDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challan Details"),
        actions: [
          // Edit button - navigates to NewChallanScreen for editing
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit Challan",
            onPressed: () => controller.navigateToEditMode(),
          ),
          // Refresh button
          Obx(() => controller.isLoadingItems.value
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () async {
              print("🔄 MANUAL REFRESH TRIGGERED");
              await controller.loadChallanItems(controller.challan.value!.challanId!);
              Get.snackbar('Success', 'Items refreshed from server');
            },
            tooltip: "Force Refresh Items",
          )),
        ],
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          final challan = controller.challan.value;
          if (challan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("Challan not found",
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            );
          }
        
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChallanHeader(challan),
                const SizedBox(height: 24),
                _buildCustomerInfo(challan),
                const SizedBox(height: 24),
                _buildChallanItems(challan),
                const SizedBox(height: 24),
                _buildPaymentSummary(challan),
                const SizedBox(height: 24),
               // _buildActionButtons(challan),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Challan header (ID, Date, Status)
  Widget _buildChallanHeader(Challan challan) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Challan ${challan.challanId ?? 'N/A'}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(challan.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    challan.status ?? "Unknown",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Date: ${_formatDate(challan.challanDate)}",
              style: TextStyle(
                  color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            if (challan.notes != null && challan.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Notes: ${challan.notes}",
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }

  /// Customer details
  Widget _buildCustomerInfo(Challan challan) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer Information",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700)),
            const SizedBox(height: 12),
            _buildInfoRow("Name:", challan.customerName ?? "N/A"),
            _buildInfoRow("Email:", challan.customerEmail ?? "N/A"),
            _buildInfoRow("Phone:", challan.customerMobile ?? "N/A"),
            _buildInfoRow("Address:", challan.customerAddress ?? "N/A"),
          ],
        ),
      ),
    );
  }

  /// Items list
  Widget _buildChallanItems(Challan challan) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Challan Items",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700)),
                Obx(() => controller.isLoadingItems.value
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: controller.refreshChallanItems,
                  tooltip: "Refresh Items",
                )),
              ],
            ),
            const SizedBox(height: 12),

            /// Items list
            Obx(() {
              if (controller.isLoadingItems.value) {
                return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ));
              }

              if (controller.challanItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.inbox,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text("No items found",
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text("Item",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 1,
                            child: Text("Qty",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text("Price",
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text("Total",
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // items rows
                  Column(
                    children: controller.challanItems.map((item) {
                      return Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.itemName ?? "N/A",
                                        style:
                                        const TextStyle(fontWeight: FontWeight.w500)),
                                    if (item.unit != null && item.unit!.isNotEmpty)
                                      Text(
                                        "Unit: ${item.unit!.toUpperCase()}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                )),
                            Expanded(
                                flex: 1,
                                child: Text("${item.quantity ?? 0}",
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    "₹${(item.price ?? 0).toStringAsFixed(2)}",
                                    textAlign: TextAlign.right)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    "₹${((item.quantity ?? 0) * (item.price ?? 0)).toStringAsFixed(2)}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // subtotal
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Items Subtotal (${controller.challanItems.length} items):",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700)),
                        Text("₹${_calculateItemsSubtotal().toStringAsFixed(2)}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 16)),
                      ],
                    ),
                  )
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  /// Payment summary
  Widget _buildPaymentSummary(Challan challan) {
    final subtotal = challan.subtotal ?? _calculateItemsSubtotal();
    final tax = challan.gstAmount ?? 0.0;
    final total =  (subtotal + tax);
    //final total = challan.totalAmount ?? (subtotal + tax);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payment Summary",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700)),
            const SizedBox(height: 12),
            _buildInfoRow("Subtotal:", "₹${subtotal.toStringAsFixed(2)}"),
            if (tax > 0) _buildInfoRow("GST:", "₹${tax.toStringAsFixed(2)}"),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount:",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("₹${total.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700)),
              ],
            ),
            // const SizedBox(height: 12),
            // _buildInfoRow("Payment Status:", _getPaymentStatusBadge(challan.paymentStatus)),

          ],
        ),
      ),
    );
  }

  /// Action buttons
  Widget _buildActionButtons(Challan challan) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.downloadChallanPdf(),
            icon: const Icon(Icons.download),
            label: const Text("Download PDF"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.shareChallan(),
            icon: const Icon(Icons.share),
            label: const Text("Share Challan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  /// Payment status badge
  Widget _getPaymentStatusBadge(String? status) {
    final statusColor = _getPaymentStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        status ?? "Unknown",
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "paid":
        return Colors.green;
      case "partial":
        return Colors.orange;
      case "pending":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("MMM dd, yyyy").format(date);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "completed":
      case "delivered":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
      case "rejected":
        return Colors.red;
      case "draft":
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  double _calculateItemsSubtotal() {
    return controller.challanItems.fold(
      0.0,
          (sum, item) => sum + ((item.quantity ?? 0) * (item.price ?? 0.0)),
    );
  }
}

///Morning 28-09
// class ChallanDetailsScreen extends GetView<ChallanDetailsController> {
//   static const String pageId = '/ChallanDetailsScreen';
//
//   const ChallanDetailsScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Challan Details"),
//         backgroundColor: Colors.blue.shade700,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             tooltip: "Edit Challan",
//             onPressed: () async {
//               final challan = controller.challan.value;
//               if (challan != null) {
//                 await controller.editChallan(context, challan);
//               }
//             },
//           )
//         ],
//       ),
//       body: Obx(() {
//         final challan = controller.challan.value;
//         if (challan == null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline,
//                     size: 64, color: Colors.grey.shade400),
//                 const SizedBox(height: 16),
//                 Text("Challan not found",
//                     style: TextStyle(
//                         fontSize: 18, color: Colors.grey.shade600)),
//               ],
//             ),
//           );
//         }
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildChallanHeader(challan),
//               const SizedBox(height: 24),
//               _buildCustomerInfo(challan),
//               const SizedBox(height: 24),
//               _buildChallanItems(),
//               const SizedBox(height: 24),
//               _buildPaymentSummary(challan),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   /// Challan header (ID, Date, Status)
//   Widget _buildChallanHeader(Challan challan) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Challan ${challan.challanId ?? 'N/A'}",
//                   style: const TextStyle(
//                       fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 Container(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(challan.status),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     challan.status ?? "Unknown",
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Date: ${_formatDate(challan.challanDate)}",
//               style: TextStyle(
//                   color: Colors.grey.shade600, fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Customer details
//   Widget _buildCustomerInfo(Challan challan) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Customer Information",
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700)),
//             const SizedBox(height: 12),
//             _buildInfoRow("Name:", challan.customerName ?? "N/A"),
//             _buildInfoRow("Email:", challan.customerEmail ?? "N/A"),
//             _buildInfoRow("Phone:", challan.customerMobile ?? "N/A"),
//             _buildInfoRow("Address:", challan.customerAddress ?? "N/A"),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Items list
//   Widget _buildChallanItems() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Challan Items",
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue.shade700)),
//                 Obx(() => controller.isLoadingItems.value
//                     ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2))
//                     : IconButton(
//                   icon: const Icon(Icons.refresh, size: 20),
//                   onPressed: () async {
//                     await controller.refreshChallanItems();
//                   },
//                   tooltip: "Refresh Items",
//                 )),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             /// Items list
//             Obx(() {
//               if (controller.isLoadingItems.value) {
//                 return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: CircularProgressIndicator(),
//                     ));
//               }
//
//               if (controller.challanItems.isEmpty) {
//                 return Container(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       Icon(Icons.inbox,
//                           size: 48, color: Colors.grey.shade400),
//                       const SizedBox(height: 8),
//                       Text("No items found",
//                           style: TextStyle(color: Colors.grey.shade600)),
//                     ],
//                   ),
//                 );
//               }
//
//               final itemsSubtotal = controller.challanItems.fold(
//                   0.0,
//                       (s, it) =>
//                   s + ((it.quantity ?? 0) * (it.price ?? 0.0)));
//
//               return Column(
//                 children: [
//                   // header
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8, horizontal: 12),
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(8)),
//                     child: Row(
//                       children: const [
//                         Expanded(
//                             flex: 3,
//                             child: Text("Item",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold))),
//                         Expanded(
//                             flex: 1,
//                             child: Text("Qty",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold))),
//                         Expanded(
//                             flex: 2,
//                             child: Text("Price",
//                                 textAlign: TextAlign.right,
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold))),
//                         Expanded(
//                             flex: 2,
//                             child: Text("Total",
//                                 textAlign: TextAlign.right,
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold))),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//
//                   // rows
//                   ...controller.challanItems.map((item) => Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 12),
//                     margin: const EdgeInsets.only(bottom: 8),
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border:
//                         Border.all(color: Colors.grey.shade200)),
//                     child: Row(
//                       children: [
//                         Expanded(
//                             flex: 3,
//                             child: Text(item.itemName ?? "N/A",
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w500))),
//                         Expanded(
//                             flex: 1,
//                             child: Text("${item.quantity ?? 0}",
//                                 textAlign: TextAlign.center)),
//                         Expanded(
//                             flex: 2,
//                             child: Text(
//                                 "₹${(item.price ?? 0).toStringAsFixed(2)}",
//                                 textAlign: TextAlign.right)),
//                         Expanded(
//                             flex: 2,
//                             child: Text(
//                                 "₹${((item.quantity ?? 0) * (item.price ?? 0)).toStringAsFixed(2)}",
//                                 textAlign: TextAlign.right,
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green.shade700))),
//                       ],
//                     ),
//                   )),
//
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8, horizontal: 12),
//                     decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border:
//                         Border.all(color: Colors.blue.shade200)),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                             "Items Subtotal (${controller.challanItems.length} items):",
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue.shade700)),
//                         Text("₹${itemsSubtotal.toStringAsFixed(2)}",
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue.shade700,
//                                 fontSize: 16)),
//                       ],
//                     ),
//                   )
//                 ],
//               );
//             })
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Payment summary
//   Widget _buildPaymentSummary(Challan challan) {
//     final subtotal = challan.subtotal ?? 0.0;
//     final tax = challan.gstAmount ?? 0.0;
//     final total = challan.subtotal ?? (subtotal + tax);
//
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Payment Summary",
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700)),
//             const SizedBox(height: 12),
//             _buildInfoRow("Subtotal:", "₹${subtotal.toStringAsFixed(2)}"),
//             _buildInfoRow("Tax:", "₹${tax.toStringAsFixed(2)}"),
//             const Divider(thickness: 2),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Total Amount:",
//                     style:
//                     TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 Text("₹${total.toStringAsFixed(2)}",
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green.shade700)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Reusable info row
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//               width: 90,
//               child: Text(label,
//                   style: TextStyle(color: Colors.grey.shade600))),
//           Expanded(
//               child: Text(value,
//                   style: const TextStyle(fontWeight: FontWeight.w500))),
//         ],
//       ),
//     );
//   }
//
//   String _formatDate(DateTime? date) {
//     if (date == null) return "-";
//     return DateFormat("MMM dd, yyyy").format(date);
//   }
//
//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case "completed":
//         return Colors.green;
//       case "pending":
//         return Colors.orange;
//       case "cancelled":
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }
