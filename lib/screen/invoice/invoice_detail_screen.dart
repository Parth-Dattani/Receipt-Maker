import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';

///3-10
// class InvoiceDetailsScreen extends GetView<InvoiceDetailsController> {
//   static const String pageId = '/invoiceDetails';
//
//   const InvoiceDetailsScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Get.lazyPut(() => InvoiceDetailsController());
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Invoice Details'),
//         backgroundColor: Colors.blue.shade700,
//         foregroundColor: Colors.white,
//         actions: [
//           // Edit button - navigates to NewInvoiceScreen for editing
//           IconButton(
//             icon: const Icon(Icons.edit),
//             tooltip: 'Edit Invoice',
//             onPressed: () => controller.navigateToEditMode(),
//           ),
//           // Manual refresh button
//           Obx(() => controller.isLoadingItems.value
//               ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: Colors.white,
//               ))
//               : IconButton(
//             icon: const Icon(Icons.refresh, size: 20),
//             onPressed: () async {
//               print("🔄 MANUAL REFRESH TRIGGERED");
//               await controller.loadInvoiceItems(
//                   controller.invoice.value!.invoiceId!);
//               Get.snackbar('Success', 'Items refreshed from server');
//             },
//             tooltip: 'Force Refresh Items',
//           )),
//         ],
//       ),
//       body: SafeArea(
//         child: Obx(() {
//           final inv = controller.invoice.value;
//           if (inv == null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline,
//                       size: 64, color: Colors.grey.shade400),
//                   const SizedBox(height: 16),
//                   Text('Invoice not found',
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
//                 _buildInvoiceHeader(inv),
//                 const SizedBox(height: 24),
//                 _buildCustomerInfo(inv),
//                 const SizedBox(height: 24),
//                 _buildInvoiceItems(inv),
//                 const SizedBox(height: 24),
//                 _buildPaymentInfo(inv),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildInvoiceHeader(Invoice invoice) {
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
//                 Text('Invoice ${invoice.invoiceId ?? 'N/A'}',
//                     style: const TextStyle(
//                         fontSize: 24, fontWeight: FontWeight.bold)),
//                 Container(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                       color: _getStatusColor(invoice.status),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Text(invoice.status ?? 'Unknown',
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Issue Date:',
//                           style: TextStyle(color: Colors.grey.shade600)),
//                       Text(
//                           DateFormat('MMM dd, yyyy')
//                               .format(invoice.issueDate ?? DateTime.now()),
//                           style: const TextStyle(fontWeight: FontWeight.w500)),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Due Date:',
//                           style: TextStyle(color: Colors.grey.shade600)),
//                       Text(
//                           DateFormat('MMM dd, yyyy')
//                               .format(invoice.dueDate ?? DateTime.now()),
//                           style: const TextStyle(fontWeight: FontWeight.w500)),
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
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Customer Information',
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700)),
//             const SizedBox(height: 12),
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
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Invoice Items',
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
//                     icon: const Icon(Icons.refresh, size: 20),
//                     onPressed: controller.refreshInvoiceItems,
//                     tooltip: 'Refresh Items')),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             Obx(() {
//               if (controller.isLoadingItems.value) {
//                 return const Center(
//                     child: Padding(
//                         padding: EdgeInsets.all(20),
//                         child: CircularProgressIndicator()));
//               }
//
//               if (controller.invoiceItems.isEmpty) {
//                 return Container(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(children: [
//                     Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
//                     const SizedBox(height: 8),
//                     Text('No items found',
//                         style: TextStyle(color: Colors.grey.shade600))
//                   ]),
//                 );
//               }
//
//               final itemsSubtotal = controller.invoiceItems.fold(
//                   0.0, (s, it) => s + ((it.quantity ?? 0) * (it.rate ?? 0.0)));
//
//               return Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8, horizontal: 12),
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(8)),
//                     child: Row(children: const [
//                       Expanded(
//                           flex: 3,
//                           child: Text('Item',
//                               style: TextStyle(fontWeight: FontWeight.bold))),
//                       Expanded(
//                           flex: 1,
//                           child: Text('Qty',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.center)),
//                       Expanded(
//                           flex: 2,
//                           child: Text('Price',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.right)),
//                       Expanded(
//                           flex: 2,
//                           child: Text('Total',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.right))
//                     ]),
//                   ),
//                   const SizedBox(height: 8),
//
//                   ...controller.invoiceItems.map((item) => Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 12),
//                     margin: const EdgeInsets.only(bottom: 8),
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey.shade200)),
//                     child: Row(children: [
//                       Expanded(
//                           flex: 3,
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                     item.itemName?.isNotEmpty == true
//                                         ? item.itemName!
//                                         : (item.description?.isNotEmpty ==
//                                         true
//                                         ? item.description!
//                                         : 'Unnamed Item'),
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w500)),
//                                 // if (item.itemId?.isNotEmpty == true)
//                                 //   Text('ID: ${item.itemId}',
//                                 //       style: TextStyle(
//                                 //           fontSize: 12,
//                                 //           color: Colors.grey.shade600)),
//                               ])),
//                       Expanded(
//                           flex: 1,
//                           child: Text('${item.quantity}',
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w500))),
//                       Expanded(
//                           flex: 2,
//                           child: Text(
//                               '${(item.rate ?? 0.0).toStringAsFixed(2)}',
//                               textAlign: TextAlign.right,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w500))),
//                       Expanded(
//                           flex: 2,
//                           child: Text(
//                               '${((item.quantity ?? 0) * (item.rate ?? 0.0)).toStringAsFixed(2)}',
//                               textAlign: TextAlign.right,
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green.shade700)))
//                     ]),
//                   )).toList(),
//
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8, horizontal: 12),
//                     decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue.shade200)),
//                     child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                               'Items Subtotal (${controller.invoiceItems.length} items):',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue.shade700)),
//                           Text('₹${itemsSubtotal.toStringAsFixed(2)}',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue.shade700,
//                                   fontSize: 16))
//                         ]),
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
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Payment Summary',
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700)),
//             const SizedBox(height: 12),
//
//             Obx(() {
//               double subtotal = 0.0;
//               double totalGst = 0.0;  // ✅ Calculate from items
//
//               // Calculate from actual loaded items
//               for (var item in controller.invoiceItems) {
//                 final qty = item.quantity ?? 0.0;
//                 final rate = item.rate ?? 0.0;
//                 final itemTotal = qty * rate;
//
//                 subtotal += itemTotal;
//
//                 // ✅ Calculate GST for each item
//                 if (AppConstants.withGST.value) {
//                   final gstRate = item.gstRate ?? 0.0;
//                   final itemGst = (itemTotal * gstRate) / 100;
//                   totalGst += itemGst;
//
//                   print("Item: ${item.itemName}");
//                   print("  Qty: $qty, Rate: $rate");
//                   print("  Item Total: $itemTotal");
//                   print("  GST Rate: $gstRate%");
//                   print("  Item GST: $itemGst");
//                 }
//               }
//
//               final double discount = invoice.discountAmount ?? 0.0;
//               final double total = subtotal + totalGst - discount;
//
//               print("=== PAYMENT SUMMARY ===");
//               print("Subtotal: $subtotal");
//               print("Total GST: $totalGst");
//               print("Discount: $discount");
//               print("Grand Total: $total");
//
//               return Column(
//                 children: [
//                   _buildInfoRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
//                   if (AppConstants.withGST.value) ...[
//                     _buildInfoRow('CGST:', '₹${(totalGst / 2).toStringAsFixed(2)}'),
//                     _buildInfoRow('SGST:', '₹${(totalGst / 2).toStringAsFixed(2)}'),
//                   ],
//                   if (discount > 0)
//                     _buildInfoRow('Discount:', '-₹${discount.toStringAsFixed(2)}'),
//                   const Divider(thickness: 2),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('Total Amount:',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold)),
//                       Text('₹${total.toStringAsFixed(2)}',
//                           style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green.shade700))
//                     ],
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
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//               width: 80,
//               child: Text(label,
//                   style: TextStyle(color: Colors.grey.shade600))),
//           Expanded(
//               child: Text(value,
//                   style: const TextStyle(fontWeight: FontWeight.w500)))
//         ],
//       ),
//     );
//   }
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
          // Edit button - navigates to NewInvoiceScreen for editing
          Obx(() => controller.isLoading.value
              ? const SizedBox.shrink()
              : IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Invoice',
            onPressed: () => controller.navigateToEditMode(),
          )),
          // Manual refresh button
          Obx(() => controller.isLoadingItems.value
              ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ))
              : IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () async {
              print("🔄 MANUAL REFRESH TRIGGERED");
              await controller.loadInvoiceItems(
                  controller.invoice.value!.invoiceId!);
            },
            tooltip: 'Force Refresh Items',
          )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // Main loading state with shimmer
          if (controller.isLoading.value && controller.invoice.value == null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerInvoiceHeader(),
                  const SizedBox(height: 24),
                  _buildShimmerCustomerInfo(),
                  const SizedBox(height: 24),
                  _buildShimmerInvoiceItems(),
                  const SizedBox(height: 24),
                  _buildShimmerPaymentInfo(),
                ],
              ),
            );
          }

          final inv = controller.invoice.value;
          if (inv == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Invoice not found',
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
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
      ),
    );
  }

  // Shimmer for Invoice Header
  Widget _buildShimmerInvoiceHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer for Customer Info
  Widget _buildShimmerCustomerInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                4,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 150,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer for Invoice Items
  Widget _buildShimmerInvoiceItems() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Container(width: 60, height: 14, color: Colors.white)),
                    Expanded(flex: 1, child: Container(width: 30, height: 14, color: Colors.white)),
                    Expanded(flex: 2, child: Container(width: 50, height: 14, color: Colors.white)),
                    Expanded(flex: 2, child: Container(width: 50, height: 14, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                3,
                    (index) => Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer for Payment Info
  Widget _buildShimmerPaymentInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                4,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 2),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                Expanded(
                  child: Text('Invoice ${invoice.invoiceId ?? 'N/A'}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _getStatusColor(invoice.status),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(invoice.status ?? 'Unknown',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Issue Date:',
                          style: TextStyle(color: Colors.grey.shade600)),
                      Text(
                          DateFormat('MMM dd, yyyy')
                              .format(invoice.issueDate ?? DateTime.now()),
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date:',
                          style: TextStyle(color: Colors.grey.shade600)),
                      Text(
                          DateFormat('MMM dd, yyyy')
                              .format(invoice.dueDate ?? DateTime.now()),
                          style: const TextStyle(fontWeight: FontWeight.w500)),
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
            Text('Customer Information',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700)),
            const SizedBox(height: 12),
            _buildInfoRow('Name:', invoice.customerName ?? 'N/A'),
            if(invoice.customerEmail!.isNotEmpty)
              _buildInfoRow('Email:', invoice.customerEmail ?? 'N/A'),
            if(invoice.mobile.isNotEmpty)
             _buildInfoRow('Phone:', invoice.mobile ?? 'N/A'),
            if(invoice.customerAddress!.isNotEmpty)
            _buildInfoRow('Address:', invoice.customerAddress ?? 'N/A'),
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
                Text('Invoice Items',
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
                    onPressed: controller.refreshInvoiceItems,
                    tooltip: 'Refresh Items')),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              // Loading items with shimmer
              if (controller.isLoadingItems.value) {
                return _buildShimmerItemsList();
              }

              // Empty state
              if (controller.invoiceItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No items found',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Text('Try refreshing or add items in edit mode',
                        style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500))
                  ]),
                );
              }

              final itemsSubtotal = controller.invoiceItems.fold(
                  0.0, (s, it) => s + ((it.quantity ?? 0) * (it.rate ?? 0.0)));

              return Column(
                children: [
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(children: const [
                      Expanded(
                          flex: 3,
                          child: Text('Item',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 1,
                          child: Text('Qty',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text('Price',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right)),
                      Expanded(
                          flex: 2,
                          child: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right))
                    ]),
                  ),
                  const SizedBox(height: 8),

                  // Item rows
                  ...controller.invoiceItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200)),
                      child: Row(children: [
                        Expanded(
                            flex: 3,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      item.itemName?.isNotEmpty == true
                                          ? item.itemName!
                                          : (item.description?.isNotEmpty ==
                                          true
                                          ? item.description!
                                          : 'Item ${index + 1}'),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ])),
                        Expanded(
                            flex: 1,
                            child: Text('${item.quantity ?? 0}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500))),
                        Expanded(
                            flex: 2,
                            child: Text(
                                '${(item.rate ?? 0.0).toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500))),
                        Expanded(
                            flex: 2,
                            child: Text(
                                '${((item.quantity ?? 0) * (item.rate ?? 0.0)).toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700)))
                      ]),
                    );
                  }).toList(),

                  const SizedBox(height: 12),
                  // Subtotal
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Items Subtotal (${controller.invoiceItems.length} items):',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700)),
                          Text('₹${itemsSubtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 16))
                        ]),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Shimmer for loading items list only
  Widget _buildShimmerItemsList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          3,
              (index) => Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              // Show shimmer while calculating
              if (controller.isLoadingItems.value) {
                return _buildShimmerPaymentSummary();
              }

              double subtotal = 0.0;
              double totalGst = 0.0;

              // Calculate from actual loaded items
              for (var item in controller.invoiceItems) {
                final qty = item.quantity ?? 0.0;
                final rate = item.rate ?? 0.0;
                final itemTotal = qty * rate;

                subtotal += itemTotal;

                // Calculate GST for each item
                if (AppConstants.withGST.value) {
                  final gstRate = item.gstRate ?? 0.0;
                  final itemGst = (itemTotal * gstRate) / 100;
                  totalGst += itemGst;
                }
              }

              final double discount = invoice.discountAmount ?? 0.0;
              final double total = subtotal + totalGst - discount;

              return Column(
                children: [
                  _buildInfoRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
                  if (AppConstants.withGST.value) ...[
                    _buildInfoRow(
                        'CGST:', '₹${(totalGst / 2).toStringAsFixed(2)}'),
                    _buildInfoRow(
                        'SGST:', '₹${(totalGst / 2).toStringAsFixed(2)}'),
                  ],
                  if (discount > 0)
                    _buildInfoRow(
                        'Discount:', '-₹${discount.toStringAsFixed(2)}'),
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

  // Shimmer for payment summary only
  Widget _buildShimmerPaymentSummary() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          ...List.generate(
            4,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 2),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 100,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)))
        ],
      ),
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