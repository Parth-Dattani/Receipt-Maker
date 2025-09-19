// controllers/invoice_list_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/screen/screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../model/model.dart';
import '../services/service.dart';
import '../utils/utils.dart';
import '../widgets/custom_snackbar.dart';
import 'controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class InvoiceListController extends BaseController {
  final isLoading = false.obs;
  final invoiceList = <Invoice>[].obs;
  final filteredInvoiceList = <Invoice>[].obs;
  final invoiceItems = <InvoiceItem>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  var companyData = <String, dynamic>{}.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      if (companyId.isEmpty) return;

      final companyDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .get();

      if (companyDoc.exists) {
        companyData.value = companyDoc.data() ?? {};
        print("Company data loaded: ${companyData.value}");
      }
    } catch (e) {
      print("Error loading company data: $e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInvoices() async {
    try {
      isLoading.value = true;
      print("=== LOADING INVOICES ===");

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        showCustomSnackbar(
          title: "Error",
          message: "User not logged in",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
        return;
      }


      List<Invoice> invoices = await GoogleSheetService.getInvoices();

      // If no invoices found, try alternative method
      if (invoices.isEmpty) {
        print("Standard method failed, trying alternative...");
        invoices = await GoogleSheetService.getInvoices();
      }

      // Filter invoices by current user ID
      List<Invoice> userInvoices = invoices.where((invoice) {
        // Check if invoice has userId field and it matches current user
        return invoice.userId == currentUserId;
      }).toList();
      print("=============usrInvoice----${userInvoices}");

      // If no invoices found, try alternative methods
      if (userInvoices.isEmpty) {
        print("Standard method failed, trying alternative...");
        invoices = await GoogleSheetService.getInvoices();
        // Filter again
        userInvoices = invoices.where((invoice) => invoice.userId == currentUserId).toList();
      }

      invoiceList.assignAll(userInvoices);
      filteredInvoiceList.assignAll(userInvoices);

      print("✅ Loaded ${invoices.length} invoices");

      if (userInvoices.isEmpty) {
        Get.snackbar(
          'No Invoices',
          'No invoices found in the system',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          icon: Icon(Icons.info_outline, color: Colors.orange.shade700),
        );
      }
    } catch (e) {
      print("❌ Error loading invoices: $e");
      Get.snackbar(
        'Error',
        'Failed to load invoices: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade700),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterInvoices(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredInvoiceList.assignAll(invoiceList);
      return;
    }

    final filtered = invoiceList.where((invoice) {
      return invoice.invoiceId.toLowerCase().contains(query.toLowerCase()) == true ||
          invoice.customerName.toLowerCase().contains(query.toLowerCase()) == true ||
          invoice.totalAmount.toString().contains(query) ||
          (invoice.itemName!.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    filteredInvoiceList.assignAll(filtered);
  }

  void filterByStatus(String status) {
    selectedFilter.value = status;

    if (status == 'All') {
      filteredInvoiceList.assignAll(invoiceList);
      return;
    }

    // Assuming you have a status field in your Invoice model
    final filtered = invoiceList.where((invoice) {
      // Replace with your actual status field logic
      return invoice.status?.toLowerCase() == status.toLowerCase();
    }).toList();

    filteredInvoiceList.assignAll(filtered);
  }

  void refreshInvoices() async {
    await loadInvoices();
  }

  void viewInvoiceDetails(Invoice invoice) {
    Get.lazyPut<InvoiceDetailsController>(() => InvoiceDetailsController());
    Get.to(() => InvoiceDetailsScreen(), arguments: invoice);
    ///Get.toNamed(InvoiceDetailsScreen.pageId, arguments: invoice);
  }

  void editInvoice(Invoice invoice) {
    Get.toNamed('/edit-invoice', arguments: invoice);
  }

  Future<void> deleteInvoice(Invoice invoice) async {
    final confirmed = await Get.dialog(
      AlertDialog(
        title: Text('Delete Invoice?'),
        content: Text('Are you sure you want to delete invoice ${invoice.invoiceId}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isLoading.value = true;
        // Implement delete logic here
        // await RemoteService.deleteInvoice(invoice.id);
        invoiceList.remove(invoice);
        filteredInvoiceList.remove(invoice);

        Get.snackbar(
          'Deleted',
          'Invoice ${invoice.invoiceId} has been deleted',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete invoice: ${e.toString()}',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// Updated method with proper parameter handling
  void exportInvoiceAsPdf(Invoice invoice) async {
    try {
      // Show loading indicator
      isLoading.value = true;

      // Fetch the invoice items for this specific invoice
      print("Fetching invoice items for PDF: ${invoice.invoiceId}");
      List<InvoiceItem> fetchedInvoiceItems = await GoogleSheetService.getInvoiceItemsByInvoiceId(invoice.invoiceId);

      // ✅ Fix: Fallback itemName -> description if blank
      final cleanedItems = fetchedInvoiceItems.map((item) {
        final fixedName = (item.itemName != null && item.itemName.trim().isNotEmpty)
            ? item.itemName
            : (item.description ?? "Service/Product");

        return InvoiceItem(
          itemId: item.itemId,
          itemName: fixedName,
          description: item.description,
          quantity: item.quantity,
          rate: item.rate,
          totalPrice: item.totalPrice,
        );
      }).toList();

      invoiceItems.assignAll(cleanedItems);

      print("Found ${invoiceItems.length} items for invoice ${invoice.invoiceId}");


      /// If no items found, create a default item based on invoice data
      // if (fetchedInvoiceItems.isEmpty) {
      //   print("No items found, creating default item from invoice data");
      //   fetchedInvoiceItems = [
      //     InvoiceItem(
      //       description: invoice.itemName!,
      //       itemId: invoice.itemId!,
      //       itemName: invoice.itemName!,
      //       quantity: invoice.qty ?? 1,
      //       rate: invoice.price ?? 0.0,
      //       totalPrice: invoice.totalAmount ?? 0.0,
      //     ),
      //   ];
      // }
      for (var item in invoiceItems) {
        print("PDF Item -> name: ${item.itemName}, desc: ${item.description}, qty: ${item.quantity}, rate: ${item.rate}");
      }


      // Generate PDF with the complete invoice data including items
      final pdfFile = await InvoiceHelper.generate(invoice, invoiceItems, companyData.value);

      // Open the PDF file
      ///await OpenFile.open(pdfFile.path);
      await Share.shareXFiles([XFile(pdfFile.path)], text: 'Invoice - ${invoice.invoiceId}');


      // Show success message
      Get.snackbar(
        'Success',
        'Invoice exported as PDF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Show error message
      print("Error exporting PDF: $e");
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }




  double get totalRevenue {
    return invoiceList.fold(0, (sum, invoice) => sum + (invoice.totalAmount ?? 0));
  }

  int get totalInvoices => invoiceList.length;

  int get paidInvoices => invoiceList.where((invoice) => invoice.status == 'Paid').length;

  int get pendingInvoices => invoiceList.where((invoice) => invoice.status == 'Pending').length;
}

// class InvoiceListController extends BaseController {
//   final isLoading = false.obs;
//   final invoiceList = <Invoice>[].obs;
//   final filteredInvoiceList = <Invoice>[].obs;
//   final invoiceItem = <InvoiceItem>[].obs;
//   final searchQuery = ''.obs;
//   final selectedFilter = 'All'.obs;
//   var companyData = <String, dynamic>{}.obs;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadInvoices();
//     loadCompanyData();
//   }
//
//
//   Future<void> loadCompanyData() async {
//     try {
//       isLoading.value = true;
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       if (companyId.isEmpty) return;
//
//       final companyDoc = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .get();
//
//       if (companyDoc.exists) {
//         companyData.value = companyDoc.data() ?? {};
//         print("Company data loaded: ${companyData.value}");
//       }
//     } catch (e) {
//       print("Error loading company data: $e");
//       isLoading.value = false;
//     }
//     finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadInvoices() async {
//     try {
//       isLoading.value = true;
//       print("=== LOADING INVOICES ===");
//
//       List<Invoice> invoices = await RemoteService.getInvoices();
//
//       // If no invoices found, try alternative method
//       if (invoices.isEmpty) {
//         print("Standard method failed, trying alternative...");
//         invoices = await RemoteService.getInvoices();
//       }
//
//       invoiceList.assignAll(invoices);
//       filteredInvoiceList.assignAll(invoices);
//
//       print("✅ Loaded ${invoices.length} invoices");
//
//       if (invoices.isEmpty) {
//         Get.snackbar(
//           'No Invoices',
//           'No invoices found in the system',
//           backgroundColor: Colors.orange.shade100,
//           colorText: Colors.orange.shade800,
//           icon: Icon(Icons.info_outline, color: Colors.orange.shade700),
//         );
//       }
//
//     } catch (e) {
//       print("❌ Error loading invoices: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to load invoices: ${e.toString()}',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//         icon: Icon(Icons.error_outline, color: Colors.red.shade700),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void filterInvoices(String query) {
//     searchQuery.value = query;
//
//     if (query.isEmpty) {
//       filteredInvoiceList.assignAll(invoiceList);
//       return;
//     }
//
//     final filtered = invoiceList.where((invoice) {
//       return invoice.invoiceId.toLowerCase().contains(query.toLowerCase()) == true ||
//           invoice.customerName.toLowerCase().contains(query.toLowerCase()) == true ||
//           invoice.totalAmount.toString().contains(query) ||
//           (invoice.itemName.toLowerCase().contains(query.toLowerCase()) ?? false);
//     }).toList();
//
//     filteredInvoiceList.assignAll(filtered);
//   }
//
//   void filterByStatus(String status) {
//     selectedFilter.value = status;
//
//     if (status == 'All') {
//       filteredInvoiceList.assignAll(invoiceList);
//       return;
//     }
//
//     // Assuming you have a status field in your Invoice model
//     final filtered = invoiceList.where((invoice) {
//       // Replace with your actual status field logic
//       return invoice.status?.toLowerCase() == status.toLowerCase();
//     }).toList();
//
//     filteredInvoiceList.assignAll(filtered);
//   }
//
//   void refreshInvoices() async {
//     await loadInvoices();
//   }
//
//   void viewInvoiceDetails(Invoice invoice) {
//     Get.lazyPut<InvoiceDetailsController>(() => InvoiceDetailsController());
//     Get.to(() => InvoiceDetailsScreen(), arguments: invoice);
//     ///Get.toNamed(InvoiceDetailsScreen.pageId, arguments: invoice);
//   }
//
//   void editInvoice(Invoice invoice) {
//     Get.toNamed('/edit-invoice', arguments: invoice);
//   }
//
//   Future<void> deleteInvoice(Invoice invoice) async {
//     final confirmed = await Get.dialog(
//       AlertDialog(
//         title: Text('Delete Invoice?'),
//         content: Text('Are you sure you want to delete invoice ${invoice.invoiceId}?'),
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
//         // Implement delete logic here
//         // await RemoteService.deleteInvoice(invoice.id);
//         invoiceList.remove(invoice);
//         filteredInvoiceList.remove(invoice);
//
//         Get.snackbar(
//           'Deleted',
//           'Invoice ${invoice.invoiceId} has been deleted',
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
// // In your InvoiceListController
//
//   // void exportInvoiceAsPdf(Invoice invoice, InvoiceItem invoiceItems) async {
//   //   try {
//   //     // Show loading indicator
//   //     isLoading.value = true;
//   //
//   //     // First, fetch the invoice items for this specific invoice
//   //     print("Fetching invoice items for PDF: ${invoice.invoiceId}");
//   //      invoiceItems = await RemoteService.getInvoiceItemsByInvoiceId(invoice.invoiceId);
//   //
//   //     print("Found ${invoiceItems.length} items for invoice ${invoice.invoiceId}");
//   //
//   //     // Create a copy of the invoice with the items included
//   //     Invoice invoiceWithItems = invoice.copyWith(
//   //       items: invoiceItems, // Make sure your Invoice class has an items field
//   //     );
//   //
//   //     // Generate PDF with the complete invoice data including items
//   //     final pdfFile = await InvoiceHelper.generate(invoiceWithItems, invoiceItems,  companyData.value);
//   //
//   //     // Open the PDF file
//   //     await OpenFile.open(pdfFile.path);
//   //
//   //     // Show success message
//   //     Get.snackbar(
//   //       'Success',
//   //       'Invoice exported as PDF',
//   //       snackPosition: SnackPosition.BOTTOM,
//   //       backgroundColor: Colors.green,
//   //       colorText: Colors.white,
//   //     );
//   //   } catch (e) {
//   //     // Show error message
//   //     print("Error exporting PDF: $e");
//   //     Get.snackbar(
//   //       'Error',
//   //       'Failed to export PDF: ${e.toString()}',
//   //       snackPosition: SnackPosition.BOTTOM,
//   //       backgroundColor: Colors.red,
//   //       colorText: Colors.white,
//   //     );
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }
//
//   // Updated method with proper parameter handling
//   void exportInvoiceAsPdf(Invoice invoice) async {
//     try {
//       // Show loading indicator
//       isLoading.value = true;
//
//       // Fetch the invoice items for this specific invoice
//       print("Fetching invoice items for PDF: ${invoice.invoiceId}");
//       List<InvoiceItem> fetchedInvoiceItems = await RemoteService.getInvoiceItemsByInvoiceId(invoice.invoiceId);
//
//       print("Found ${fetchedInvoiceItems.length} items for invoice ${invoice.invoiceId}");
//
//       // If no items found, create a default item based on invoice data
//       if (fetchedInvoiceItems.isEmpty) {
//         print("No items found, creating default item from invoice data");
//         fetchedInvoiceItems = [
//           InvoiceItem(
//            itemId: invoice.itemId,
//             description: invoice.itemName  ,
//             itemName: invoice.itemName ?? 'Service/Product',
//             quantity: invoice.qty ?? 1,
//             rate: invoice.price ?? 0.0,
//             totalPrice: invoice.totalAmount ?? 0.0,
//           ),
//         ];
//       }
//
//       // Generate PDF with the complete invoice data including items
//       final pdfFile = await InvoiceHelper.generate(invoice, fetchedInvoiceItems, companyData.value);
//
//       // Open the PDF file
//       await OpenFile.open(pdfFile.path);
//
//       // Show success message
//       Get.snackbar(
//         'Success',
//         'Invoice exported as PDF',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       // Show error message
//       print("Error exporting PDF: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to export PDF: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   double get totalRevenue {
//     return invoiceList.fold(0, (sum, invoice) => sum + (invoice.totalAmount ?? 0));
//   }
//
//   int get totalInvoices => invoiceList.length;
//
//   int get paidInvoices => invoiceList.where((invoice) => invoice.status == 'Paid').length;
//
//   int get pendingInvoices => invoiceList.where((invoice) => invoice.status == 'Pending').length;
// }