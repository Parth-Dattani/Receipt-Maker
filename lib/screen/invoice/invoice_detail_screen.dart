import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/controller.dart';
import '../../model/model.dart';

// class InvoiceDetailsScreen extends GetView<InvoiceDetailsController> {
//   static const String pageId = '/invoiceDetails';
//
//   const InvoiceDetailsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     Get.lazyPut(() => InvoiceDetailsController());
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Invoice Details'),
//         backgroundColor: Colors.blue.shade700,
//         foregroundColor: Colors.white,
//         // actions: [
//         //   IconButton(
//         //     icon: Icon(Icons.edit),
//         //     onPressed: controller.editInvoice,
//         //     tooltip: 'Edit Invoice',
//         //   ),
//         //   PopupMenuButton(
//         //     itemBuilder: (context) => [
//         //       PopupMenuItem(
//         //         value: 'share',
//         //         child: Row(
//         //           children: [
//         //             Icon(Icons.share, size: 20),
//         //             SizedBox(width: 8),
//         //             Text('Share'),
//         //           ],
//         //         ),
//         //       ),
//         //       PopupMenuItem(
//         //         value: 'download',
//         //         child: Row(
//         //           children: [
//         //             Icon(Icons.download, size: 20),
//         //             SizedBox(width: 8),
//         //             Text('Download'),
//         //           ],
//         //         ),
//         //       ),
//         //       PopupMenuItem(
//         //         value: 'delete',
//         //         child: Row(
//         //           children: [
//         //             Icon(Icons.delete, size: 20, color: Colors.red),
//         //             SizedBox(width: 8),
//         //             Text('Delete', style: TextStyle(color: Colors.red)),
//         //           ],
//         //         ),
//         //       ),
//         //     ],
//         //     onSelected: (value) {
//         //       switch (value) {
//         //         case 'share':
//         //           controller.shareInvoice();
//         //           break;
//         //         case 'download':
//         //           controller.downloadInvoice();
//         //           break;
//         //         case 'delete':
//         //           controller.deleteInvoice();
//         //           break;
//         //       }
//         //     },
//         //   ),
//         // ],
//       ),
//       body: Obx(() {
//         final invoice = controller.invoice.value;
//         if (invoice == null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
//                 SizedBox(height: 16),
//                 Text(
//                   'Invoice not found',
//                   style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return SingleChildScrollView(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Invoice Header
//               _buildInvoiceHeader(invoice),
//               SizedBox(height: 24),
//
//               // Customer Information
//               _buildCustomerInfo(invoice),
//               SizedBox(height: 24),
//
//               // Invoice Items
//               _buildInvoiceItems(invoice),
//               SizedBox(height: 24),
//
//               // Payment Information
//               _buildPaymentInfo(invoice),
//               //SizedBox(height: 32),
//
//               /// Action Buttons
//               //_buildActionButtons(),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildInvoiceHeader(Invoice invoice) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Invoice ${invoice.invoiceId ?? 'N/A'}',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(invoice.status),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     invoice.status ?? 'Unknown',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Issue Date:', style: TextStyle(color: Colors.grey.shade600)),
//                       Text(
//                         DateFormat('MMM dd, yyyy').format(invoice.issueDate ?? DateTime.now()),
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Due Date:', style: TextStyle(color: Colors.grey.shade600)),
//                       Text(
//                         DateFormat('MMM dd, yyyy').format(invoice.dueDate ?? DateTime.now()),
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                     ],
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
//   Widget _buildCustomerInfo(Invoice invoice) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Customer Information',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue.shade700,
//               ),
//             ),
//             SizedBox(height: 12),
//             _buildInfoRow('Name:', invoice.customerName ?? 'N/A'),
//             _buildInfoRow('Email:', invoice.customerEmail ?? 'N/A'),
//             _buildInfoRow('Phone:', invoice.mobile ?? 'N/A'),
//             _buildInfoRow('Address:', invoice.customerAddress ?? 'N/A'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInvoiceItems(Invoice invoice) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Invoice Items',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//                 Obx(() => controller.isLoadingItems.value
//                     ? SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//                     : IconButton(
//                   icon: Icon(Icons.refresh, size: 20),
//                   onPressed: controller.refreshInvoiceItems,
//                   tooltip: 'Refresh Items',
//                 ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//
//             // Items List
//             Obx(() {
//               if (controller.isLoadingItems.value) {
//                 return Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               }
//
//               if (controller.invoiceItems.isEmpty) {
//                 return Container(
//                   padding: EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
//                       SizedBox(height: 8),
//                       Text(
//                         'No items found',
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               // Calculate correct subtotal
//               final double itemsSubtotal = controller.invoiceItems.fold(0.0, (sum, item) => sum + item.totalPrice);
//
//               return Column(
//                 children: [
//                   // Items Header
//                   Container(
//                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
//                         Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
//                         Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
//                         Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 8),
//
//                   // Items List
//                   ...controller.invoiceItems.map((item) => Container(
//                     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                     margin: EdgeInsets.only(bottom: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 3,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.description.isNotEmpty ? item.description : item.itemName,
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               if (item.itemId.isNotEmpty)
//                                 Text(
//                                   'ID: ${item.itemId}',
//                                   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: Text(
//                             '${item.quantity}',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             '₹${item.rate.toStringAsFixed(2)}',
//                             textAlign: TextAlign.right,
//                             style: TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             '₹${item.totalPrice.toStringAsFixed(2)}',
//                             textAlign: TextAlign.right,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green.shade700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )).toList(),
//
//                   // Items Summary
//                   SizedBox(height: 12),
//                   Container(
//                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.blue.shade200),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Items Subtotal (${controller.invoiceItems.length} items):',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue.shade700,
//                           ),
//                         ),
//                         Text(
//                           '₹${itemsSubtotal.toStringAsFixed(2)}',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue.shade700,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentInfo(Invoice invoice) {
//     // Calculate the correct values
//     final double subtotal = invoice.totalAmount ?? 0.0;
//     final double tax = invoice.taxAmount ?? 0.0;
//     final double discount = invoice.discountAmount ?? 0.0;
//     final double total = subtotal + tax - discount;
//
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Payment Summary',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue.shade700,
//               ),
//             ),
//             SizedBox(height: 12),
//             _buildInfoRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
//             _buildInfoRow('Tax:', '₹${tax.toStringAsFixed(2)}'),
//             _buildInfoRow('Discount:', '-₹${discount.toStringAsFixed(2)}'),
//             Divider(thickness: 2),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total Amount:',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '₹${total.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green.shade700,
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
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               label,
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget _buildActionButtons() {
//   //   return Column(
//   //     children: [
//   //       SizedBox(
//   //         width: double.infinity,
//   //         child: ElevatedButton.icon(
//   //           onPressed: controller.editInvoice,
//   //           icon: Icon(Icons.edit),
//   //           label: Text('Edit Invoice'),
//   //           style: ElevatedButton.styleFrom(
//   //             backgroundColor: Colors.blue.shade700,
//   //             foregroundColor: Colors.white,
//   //             padding: EdgeInsets.symmetric(vertical: 12),
//   //           ),
//   //         ),
//   //       ),
//   //       SizedBox(height: 12),
//   //       Row(
//   //         children: [
//   //           Expanded(
//   //             child: OutlinedButton.icon(
//   //               onPressed: controller.shareInvoice,
//   //               icon: Icon(Icons.share),
//   //               label: Text('Share'),
//   //               style: OutlinedButton.styleFrom(
//   //                 padding: EdgeInsets.symmetric(vertical: 12),
//   //               ),
//   //             ),
//   //           ),
//   //           SizedBox(width: 12),
//   //           Expanded(
//   //             child: OutlinedButton.icon(
//   //               onPressed: controller.downloadInvoice,
//   //               icon: Icon(Icons.download),
//   //               label: Text('Download'),
//   //               style: OutlinedButton.styleFrom(
//   //                 padding: EdgeInsets.symmetric(vertical: 12),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'paid':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'overdue':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//
// }


class InvoiceDetailsScreen extends GetView<InvoiceDetailsController> {
  static const String pageId = '/invoiceDetails';

  const InvoiceDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => InvoiceDetailsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => IconButton(
            icon: Icon(controller.isEditMode.value ? Icons.check : Icons.edit),
            onPressed: () {
              if (controller.isEditMode.value) {
                controller.updateInvoice();
              } else {
                controller.enterEditMode();
              }
            },
          )),
        ],
      ),
      body: Obx(() {
        final inv = controller.invoice.value;
        if (inv == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('Invoice not found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoiceHeader(inv),
              const SizedBox(height: 24),
              _buildCustomerInfo(inv),
              const SizedBox(height: 24),
              _buildInvoiceItems(inv),
              const SizedBox(height: 24),
              _buildPaymentInfo(inv),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInvoiceHeader(Invoice invoice) {
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
                Text('Invoice ${invoice.invoiceId ?? 'N/A'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //   decoration: BoxDecoration(color: _getStatusColor(invoice.status), borderRadius: BorderRadius.circular(20)),
                //   child: Text(invoice.status ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                // ),

                Obx(() {
                  if (controller.isEditMode.value) {
                    return DropdownButton<String>(
                      value: controller.selectedStatus.value,
                      items: controller.statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedStatus.value = val;
                        }
                      },
                    );
                  }

                  // Normal display mode
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      invoice.status ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),

              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Issue Date:', style: TextStyle(color: Colors.grey.shade600)),
                      Text(DateFormat('MMM dd, yyyy').format(invoice.issueDate ?? DateTime.now()), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date:', style: TextStyle(color: Colors.grey.shade600)),
                      Text(DateFormat('MMM dd, yyyy').format(invoice.dueDate ?? DateTime.now()), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Invoice invoice) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.isEditMode.value) {
                return Column(
                  children: [
                    TextField(controller: controller.customerNameCtrl, decoration: const InputDecoration(labelText: 'Customer Name')),
                    TextField(controller: controller.customerEmailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                    TextField(controller: controller.customerPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                    TextField(controller: controller.customerAddressCtrl, decoration: const InputDecoration(labelText: 'Address')),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Name:', invoice.customerName ?? 'N/A'),
                  _buildInfoRow('Email:', invoice.customerEmail ?? 'N/A'),
                  _buildInfoRow('Phone:', invoice.mobile ?? 'N/A'),
                  _buildInfoRow('Address:', invoice.customerAddress ?? 'N/A'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItems(Invoice invoice) {
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
                Text('Invoice Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                Obx(() => controller.isLoadingItems.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: controller.refreshInvoiceItems, tooltip: 'Refresh Items')),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.isLoadingItems.value) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              }

              if (controller.isEditMode.value) {
                final editable = controller.editableItems;

                return Column(
                  children: [
                    // header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: const [
                          Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                          Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                          Expanded(flex: 1, child: SizedBox(width: 40)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // editable rows
                    ...List.generate(editable.length, (index) {
                      final ctrls = editable[index];
                      final itemTotal = controller.calculateItemTotal(index);

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: ctrls['itemName'],
                                decoration: const InputDecoration(hintText: 'Item name', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 8), filled: true, fillColor: Colors.white),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                onChanged: (_) => controller.editableItems.refresh(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: ctrls['qty'],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 8), filled: true, fillColor: Colors.white),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                onChanged: (_) => controller.editableItems.refresh(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: ctrls['rate'],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.right,
                                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 8), filled: true, fillColor: Colors.white, prefixText: '₹'),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                onChanged: (_) => controller.editableItems.refresh(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text('₹${itemTotal.toStringAsFixed(2)}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: editable.length > 1
                                  ? IconButton(icon: Icon(Icons.delete, color: Colors.red.shade700, size: 20), onPressed: () => controller.removeItem(index), tooltip: 'Remove item')
                                  : const SizedBox(width: 40),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: controller.addNewItem,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue.shade700, elevation: 1),
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Items Subtotal (${editable.length} items):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          Text('₹${controller.calculatedTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // DISPLAY mode
              if (controller.invoiceItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [Icon(Icons.inbox, size: 48, color: Colors.grey.shade400), const SizedBox(height: 8), Text('No items found', style: TextStyle(color: Colors.grey.shade600))]),
                );
              }

              final itemsSubtotal = controller.invoiceItems.fold(0.0, (s, it) => s + (it.totalPrice ?? 0.0));

              return Column(
                  children: [
              Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Row(children: const [Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))), Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)), Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)), Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right))]),
              ),
              const SizedBox(height: 8),

              ...controller.invoiceItems.map((item) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Row(children: [
              Expanded(
              flex: 3,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.itemName?.isNotEmpty == true ? item.itemName! : (item.description?.isNotEmpty == true ? item.description! : 'Unnamed Item'), style: const TextStyle(fontWeight: FontWeight.w500)),
              if (item.itemId?.isNotEmpty == true) Text('ID: ${item.itemId}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
              Expanded(flex: 1, child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500))),
              Expanded(flex: 2, child: Text('₹${(item.rate ?? 0.0).toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
              Expanded(flex: 2, child: Text('₹${(item.quantity * item.rate ?? 0.0).toStringAsFixed(2)}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)))]),
              )).toList(),

              const SizedBox(height: 12),
              Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Items Subtotal (${controller.invoiceItems.length} items):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)), Text('₹${itemsSubtotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 16))]),
              ),
              ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Widget _buildPaymentInfo(Invoice invoice) {
  //   final double subtotal = controller.isEditMode.value ? controller.calculatedTotal : (invoice.totalAmount ?? 0.0);
  //   final double tax = invoice.taxAmount ?? 0.0;
  //   final double discount = invoice.discountAmount ?? 0.0;
  //   final double total = subtotal + tax - discount;
  //
  //   return Card(
  //     elevation: 2,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
  //           const SizedBox(height: 12),
  //           _buildInfoRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
  //           _buildInfoRow('Tax:', '₹${tax.toStringAsFixed(2)}'),
  //           _buildInfoRow('Discount:', '-₹${discount.toStringAsFixed(2)}'),
  //           const Divider(thickness: 2),
  //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total Amount:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text('₹${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700))]),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPaymentInfo(Invoice invoice) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Summary',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700)),
            const SizedBox(height: 12),

            Obx(() {
              double subtotal = 0.0;

              if (controller.isEditMode.value) {
                // Edit mode → use calculated
                subtotal = controller.calculatedTotal;
              } else {
                // View mode → calculate qty * rate
                for (var item in controller.invoiceItems) {
                  final qty = (item.quantity ?? 0).toDouble();
                  final rate = item.rate ?? 0.0;
                  subtotal += (qty * rate);
                }
              }

              // GST amount from invoice (already stored in sheet)
              final double gstAmount = invoice.gstAmount ?? 0.0;
              final double discount = invoice.discountAmount ?? 0.0;
              final double total = subtotal + gstAmount - discount;

              return Column(
                children: [
                  _buildInfoRow('Subtotal:', '${subtotal.toStringAsFixed(2)}'),
                  _buildInfoRow('GST:',
                      '${gstAmount.toStringAsFixed(2)}'),
                  _buildInfoRow('Discount:',
                      '-${discount.toStringAsFixed(2)}'),
                  const Divider(thickness: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('₹${total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700))
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }




  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade600))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)))]),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
