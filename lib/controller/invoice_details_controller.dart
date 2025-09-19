import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../model/model.dart';
import '../services/remote_service.dart';
import '../utils/pdf_helper.dart';


// class InvoiceDetailsController extends GetxController {
//   final invoice = Rx<Invoice?>(null);
//   final invoiceItems = <InvoiceItem>[].obs;
//   final isLoading = false.obs;
//   final isLoadingItems = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Get the invoice passed as argument
//     final Invoice? passedInvoice = Get.arguments as Invoice?;
//     if (passedInvoice != null) {
//       invoice.value = passedInvoice;
//       loadInvoiceItems(passedInvoice.invoiceId);
//
//     }
//   }
//
//   Future<void> loadInvoiceItems(String invoiceId) async {
//     try {
//       isLoading.value = true;
//       print("Loading items for invoice: $invoiceId");
//
//       // Fetch ONLY the items for this specific invoice
//       List<InvoiceItem> items = await RemoteService.getInvoiceItemsByInvoiceId(invoiceId);
//       invoiceItems.assignAll(items);
//
//       print("✅ Successfully loaded ${items.length} items for invoice $invoiceId");
//
//       // Add debug info
//       if (items.isNotEmpty) {
//         //print("First item invoiceId: ${items.first.invoiceId}");
//         print("Items breakdown:");
//         for (var item in items) {
//           print("  - ${item.description}: Qty ${item.quantity} × \$${item.rate} = \$${item.totalPrice}");
//         }
//       }
//     } catch (e) {
//       print("Error loading invoice items: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to load invoice items: ${e.toString()}',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void editInvoice() {
//     if (invoice.value != null) {
//       Get.toNamed('/edit-invoice', arguments: invoice.value);
//     }
//   }
//
//
//
//   void downloadInvoice() {
//     // Implement download functionality
//     Get.snackbar(
//       'Download',
//       'Download functionality to be implemented',
//       backgroundColor: Colors.green.shade100,
//       colorText: Colors.green.shade800,
//     );
//   }
//
//   void deleteInvoice() async {
//     final confirmed = await Get.dialog(
//       AlertDialog(
//         title: Text('Delete Invoice?'),
//         content: Text('Are you sure you want to delete this invoice?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Get.back(result: true),
//             child: Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       try {
//         isLoading.value = true;
//
//         // Delete from remote service
//         if (invoice.value != null) {
//           //await RemoteService.deleteInvoice(invoice.value!.invoiceId);
//           await RemoteService.deleteInvoiceItems(invoice.value!.invoiceId);
//         }
//
//         Get.back(); // Go back to invoice list
//         Get.snackbar(
//           'Deleted',
//           'Invoice deleted successfully',
//           backgroundColor: Colors.green.shade100,
//           colorText: Colors.green.shade800,
//         );
//       } catch (e) {
//         Get.snackbar(
//           'Error',
//           'Failed to delete invoice: ${e.toString()}',
//           backgroundColor: Colors.red.shade100,
//           colorText: Colors.red.shade800,
//         );
//       } finally {
//         isLoading.value = false;
//       }
//     }
//   }
//
//   // Calculate totals from loaded items
//   double get itemsSubtotal {
//     return invoiceItems.fold(0.0, (sum, item) => sum + item.totalPrice);
//   }
//
//   void refreshInvoiceItems() {
//     if (invoice.value != null) {
//       loadInvoiceItems(invoice.value!.invoiceId);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class InvoiceDetailsController extends GetxController {
  final invoice = Rx<Invoice?>(null);
  final invoiceItems = <InvoiceItem>[].obs;
  final isLoading = false.obs;
  final isLoadingItems = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get the invoice passed as argument
    final Invoice? passedInvoice = Get.arguments as Invoice?;
    if (passedInvoice != null) {
      invoice.value = passedInvoice;
      loadInvoiceItems(passedInvoice.invoiceId);
    }
  }

  Future<void> loadInvoiceItems(String invoiceId) async {
    try {
      isLoadingItems.value = true;
      print("Loading items for invoice: $invoiceId");

      // Fetch ONLY the items for this specific invoice
      List<InvoiceItem> items = await GoogleSheetService.getInvoiceItemsByInvoiceId(invoiceId);
      invoiceItems.assignAll(items);

      print("✅ Successfully loaded ${items.length} items for invoice $invoiceId");

      // Add debug info
      if (items.isNotEmpty) {
        print("Items breakdown:");
        for (var item in items) {
          print("Items name:-${item.itemName} :  Desc:- ${item.description}: Qty ${item.quantity} × \$${item.rate} = \$${item.totalPrice}");
        }
      }
    } catch (e) {
      print("Error loading invoice items: $e");
      Get.snackbar(
        'Error',
        'Failed to load invoice items: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoadingItems.value = false;
    }
  }

  void editInvoice() {
    if (invoice.value != null) {
      Get.toNamed('/edit-invoice', arguments: invoice.value);
    }
  }

  void downloadInvoice() {
    // Implement download functionality
    Get.snackbar(
      'Download',
      'Download functionality to be implemented',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  }

  // void deleteInvoice() async {
  //   final confirmed = await Get.dialog(
  //     AlertDialog(
  //       title: Text('Delete Invoice?'),
  //       content: Text('Are you sure you want to delete this invoice?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(result: false),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Get.back(result: true),
  //           child: Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (confirmed == true) {
  //     try {
  //       isLoading.value = true;
  //
  //       // Delete from remote service
  //       if (invoice.value != null) {
  //         await RemoteService.deleteInvoiceItems(invoice.value!.invoiceId);
  //       }
  //
  //       Get.back(); // Go back to invoice list
  //       Get.snackbar(
  //         'Deleted',
  //         'Invoice deleted successfully',
  //         backgroundColor: Colors.green.shade100,
  //         colorText: Colors.green.shade800,
  //       );
  //     } catch (e) {
  //       Get.snackbar(
  //         'Error',
  //         'Failed to delete invoice: ${e.toString()}',
  //         backgroundColor: Colors.red.shade100,
  //         colorText: Colors.red.shade800,
  //       );
  //     } finally {
  //       isLoading.value = false;
  //     }
  //   }
  // }

  /// Calculate totals from loaded items
  double get itemsSubtotal {
    return invoiceItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void refreshInvoiceItems() {
    if (invoice.value != null) {
      loadInvoiceItems(invoice.value!.invoiceId);
    }
  }

  // Shimmer effect widgets for the view
  Widget buildInvoiceDetailsShimmer() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          _buildHeaderShimmer(),
          SizedBox(height: 24),

          // Customer info shimmer
          _buildCustomerInfoShimmer(),
          SizedBox(height: 24),

          // Items header shimmer
          _buildItemsHeaderShimmer(),
          SizedBox(height: 16),

          // Invoice items shimmer
          _buildInvoiceItemsShimmer(),
          SizedBox(height: 24),

          // Totals shimmer
          _buildTotalsShimmer(),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 6),
          Container(
            width: 180,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 6),
          Container(
            width: 160,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildInvoiceItemsShimmer() {
    return Column(
      children: List.generate(3, (index) => _buildInvoiceItemShimmer()),
    );
  }

  Widget _buildInvoiceItemShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}