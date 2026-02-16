import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/constant/app_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../model/invoice_model.dart';
import '../screen/screen.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'controller.dart';


// class QuotationListController extends BaseController {
//   final quotationList = <Invoice>[].obs;
//   final filteredQuotationList = <Invoice>[].obs;
//   final quotationItems = <InvoiceItem>[].obs;
//   final searchQuery = ''.obs;
//   final selectedFilter = 'All'.obs;
//   var companyData = <String, dynamic>{}.obs;
//   final isLoadingQuotations = false.obs;
//   final isLoadingCompany = false.obs;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadQuotations();
//     loadCompanyData();
//   }
//
//   Future<void> loadCompanyData() async {
//     try {
//       isLoadingCompany.value = true;
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
//       }
//     } catch (e) {
//       print("Error loading company data: $e");
//     } finally {
//       isLoadingCompany.value = false;
//     }
//   }
//
//   Future<void> loadQuotations() async {
//     try {
//       isLoadingQuotations.value = true;
//
//       final currentUserId = _auth.currentUser?.uid;
//       if (currentUserId == null) {
//         showCustomSnackbar(
//           title: "Error",
//           message: "User not logged in",
//           baseColor: Colors.red.shade700,
//           icon: Icons.error_outline,
//         );
//         return;
//       }
//
//       List<Invoice> quotations = await GoogleSheetService.getInvoices(type: "QUO");
//       List<Invoice> userQuotations = quotations
//           .where((quotation) => quotation.userId == currentUserId)
//           .toList();
//
//       quotationList.assignAll(userQuotations);
//       filteredQuotationList.assignAll(userQuotations);
//
//       if (userQuotations.isEmpty) {
//         Get.snackbar(
//           'No Quotations',
//           'No quotations found in the system',
//           backgroundColor: Colors.orange.shade100,
//           colorText: Colors.orange.shade800,
//         );
//       }
//     } catch (e) {
//       print("Error loading quotations: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to load quotations: ${e.toString()}',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//       );
//     } finally {
//       isLoadingQuotations.value = false;
//     }
//   }
//
//   // ✅ NEW: Navigate to Invoice Form with Pre-filled Quotation Data
//   Future<void> convertQuotationToInvoice(Invoice quotation) async {
//     try {
//       isLoading.value = true;
//
//       // Fetch quotation items
//       List<InvoiceItem> quotationItems =
//       await GoogleSheetService.getInvoiceItemsByInvoiceId(quotation.invoiceId);
//
//       if (quotationItems.isEmpty) {
//         Get.snackbar(
//           'Warning',
//           'No items found for this quotation',
//           backgroundColor: Colors.orange.shade100,
//           colorText: Colors.orange.shade800,
//         );
//         isLoading.value = false;
//         return;
//       }
//
//       // Navigate to NewInvoiceScreen with quotation data
//       Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());
//
//       final result = await Get.to(
//             () => NewInvoiceScreen(),
//         arguments: {
//           'isFromQuotation': true,
//           'quotation': quotation,
//           'quotationItems': quotationItems,
//         },
//       );
//
//       // If invoice was created successfully, update quotation status
//       if (result == true) {
//         //await _updateQuotationStatus(quotation.invoiceId, 'Converted');
//         await loadQuotations(); // Refresh list
//
//         Get.snackbar(
//           'Success',
//           'Quotation converted to invoice successfully',
//           backgroundColor: Colors.green.shade100,
//           colorText: Colors.green.shade800,
//           icon: Icon(Icons.check_circle, color: Colors.green.shade700),
//         );
//       }
//
//     } catch (e) {
//       print("Error converting quotation to invoice: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to convert quotation: ${e.toString()}',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//         icon: Icon(Icons.error_outline, color: Colors.red.shade700),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Generate unique invoice ID
//   Future<String> _generateInvoiceId() async {
//     try {
//       // Get existing invoices to find next number
//       List<Invoice> existingInvoices = await GoogleSheetService.getInvoices(type: "INV");
//
//       int maxNumber = 0;
//       for (var inv in existingInvoices) {
//         // Extract number from invoice ID (e.g., "INV-001" -> 1)
//         final match = RegExp(r'INV-(\d+)').firstMatch(inv.invoiceId);
//         if (match != null) {
//           int num = int.tryParse(match.group(1) ?? '0') ?? 0;
//           if (num > maxNumber) maxNumber = num;
//         }
//       }
//
//       // Generate next invoice ID
//       String nextId = 'INV-${(maxNumber + 1).toString().padLeft(3, '0')}';
//       return nextId;
//
//     } catch (e) {
//       // Fallback to timestamp-based ID
//       return 'INV-${DateTime.now().millisecondsSinceEpoch}';
//     }
//   }
//
//   /// Update quotation status
//   // Add this method to your GoogleSheetService class
//   static Future<void> updateInvoiceStatus(String invoiceId, String newStatus) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$scriptUrl?action=updateInvoiceStatus'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'invoiceId': invoiceId,
//           'status': newStatus,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);
//         if (result['status'] == 'success') {
//           print('✅ Invoice status updated successfully');
//         } else {
//           throw Exception(result['message'] ?? 'Failed to update status');
//         }
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('❌ Error updating invoice status: $e');
//       throw Exception('Failed to update invoice status: $e');
//     }
//   }
//
//   /// Existing methods...
//   void filterQuotations(String query) {
//     searchQuery.value = query;
//     if (query.isEmpty) {
//       filteredQuotationList.assignAll(quotationList);
//       return;
//     }
//
//     final filtered = quotationList.where((quotation) {
//       return quotation.invoiceId.toLowerCase().contains(query.toLowerCase()) ||
//           quotation.customerName.toLowerCase().contains(query.toLowerCase()) ||
//           quotation.totalAmount.toString().contains(query);
//     }).toList();
//
//     filteredQuotationList.assignAll(filtered);
//   }
//
//   void filterByStatus(String status) {
//     selectedFilter.value = status;
//     if (status == 'All') {
//       filteredQuotationList.assignAll(quotationList);
//       return;
//     }
//
//     final filtered = quotationList.where((quotation) {
//       return quotation.status?.toLowerCase() == status.toLowerCase();
//     }).toList();
//
//     filteredQuotationList.assignAll(filtered);
//   }
//
//   void refreshQuotations() async {
//     await loadQuotations();
//   }
//
//   void viewQuotationDetails(Invoice quotation) {
//     Get.lazyPut<InvoiceDetailsController>(() => InvoiceDetailsController());
//     Get.to(() => InvoiceDetailsScreen(), arguments: quotation);
//   }
//
//   Future<void> deleteQuotation(Invoice quotation) async {
//     final confirmed = await Get.dialog(
//       AlertDialog(
//         title: Text('Delete Quotation?'),
//         content: Text('Are you sure you want to delete quotation ${quotation.invoiceId}?'),
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
//         //await GoogleSheetService.deleteInvoice(quotation.invoiceId);
//         quotationList.remove(quotation);
//         filteredQuotationList.remove(quotation);
//
//         Get.snackbar(
//           'Deleted',
//           'Quotation ${quotation.invoiceId} has been deleted',
//           backgroundColor: Colors.green.shade100,
//           colorText: Colors.green.shade800,
//         );
//       } catch (e) {
//         Get.snackbar(
//           'Error',
//           'Failed to delete quotation: ${e.toString()}',
//           backgroundColor: Colors.red.shade100,
//           colorText: Colors.red.shade800,
//         );
//       } finally {
//         isLoading.value = false;
//       }
//     }
//   }
//
//   Future<void> exportQuotationAsPdf(Invoice quotation) async {
//     try {
//       isLoading.value = true;
//
//       List<InvoiceItem> fetchedQuotationItems =
//       await GoogleSheetService.getInvoiceItemsByInvoiceId(quotation.invoiceId);
//
//       final cleanedItems = fetchedQuotationItems.map((item) {
//         final fixedName = (item.itemName != null && item.itemName.trim().isNotEmpty)
//             ? item.itemName
//             : (item.description ?? "Service/Product");
//
//         return InvoiceItem(
//           itemId: item.itemId,
//           itemName: fixedName,
//           description: item.description,
//           quantity: item.quantity,
//           rate: item.rate,
//           gstRate: item.gstRate,
//           gstAmount: item.gstAmount,
//           amountWithGst: item.amountWithGst,
//           totalPrice: item.totalPrice,
//         );
//       }).toList();
//
//       final pdfFile = await InvoiceHelper.generateDocument(
//         isChallan: false,
//         invoice: quotation,
//         invoiceItems: cleanedItems,
//         companyData: companyData.value,
//       );
//
//       await Share.shareXFiles([XFile(pdfFile.path)], text: 'Quotation - ${quotation.invoiceId}');
//
//       Get.snackbar(
//         'Success',
//         'Quotation exported as PDF',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       print("Error exporting PDF: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to export PDF: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   double get totalValue {
//     return quotationList.fold(0, (sum, quotation) => sum + (quotation.totalAmount ?? 0));
//   }
//
//   int get totalQuotations => quotationList.length;
//   int get acceptedQuotations => quotationList.where((q) => q.status == 'Accepted').length;
//   int get pendingQuotations => quotationList.where((q) => q.status == 'Pending').length;
//   int get convertedQuotations => quotationList.where((q) => q.status == 'Converted').length;
// }

class QuotationListController extends BaseController {
  final quotationList = <Invoice>[].obs;
  final filteredQuotationList = <Invoice>[].obs;
  final quotationItems = <InvoiceItem>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  var companyData = <String, dynamic>{}.obs;
  final isLoadingQuotations = false.obs;
  final isLoadingCompany = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadQuotations();
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {
    try {
      isLoadingCompany.value = true;
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
      }
    } catch (e) {
      print("Error loading company data: $e");
    } finally {
      isLoadingCompany.value = false;
    }
  }

  Future<void> loadQuotations() async {
    try {
      isLoadingQuotations.value = true;

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

      List<Invoice> quotations = await GoogleSheetService.getInvoices(type: "QUO");
      List<Invoice> userQuotations = quotations
          .where((quotation) => quotation.userId == currentUserId)
          .toList();

      quotationList.assignAll(userQuotations);
      filteredQuotationList.assignAll(userQuotations);

      if (userQuotations.isEmpty) {
        Get.snackbar(
          'No Quotations',
          'No quotations found in the system',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
      }
    } catch (e) {
      print("Error loading quotations: $e");
      Get.snackbar(
        'Error',
        'Failed to load quotations: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoadingQuotations.value = false;
    }
  }

  // ✅ Navigate to Invoice Form with Pre-filled Quotation Data
  Future<void> convertQuotationToInvoice(Invoice quotation) async {
    try {
      isLoading.value = true;

      // Fetch quotation items
      List<InvoiceItem> quotationItems =
      await GoogleSheetService.getInvoiceItemsByInvoiceId(quotation.invoiceId);

      if (quotationItems.isEmpty) {
        Get.snackbar(
          'Warning',
          'No items found for this quotation',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
        isLoading.value = false;
        return;
      }

      // Navigate to NewInvoiceScreen with quotation data
      Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());

      final result = await Get.to(
            () => NewInvoiceScreen(),
        arguments: {
          'isFromQuotation': true,
          'quotation': quotation,
          'quotationItems': quotationItems,
          'quotationId': quotation.invoiceId, // Pass the quotation ID
        },
      );

      // If invoice was created successfully, update quotation status to "Accepted"
      if (result == true) {
        await _updateQuotationStatus(quotation.invoiceId, 'Accepted');
        await loadQuotations(); // Refresh list

        Get.snackbar(
          'Success',
          'Quotation converted to invoice successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          icon: Icon(Icons.check_circle, color: Colors.green.shade700),
        );
      }

    } catch (e) {
      print("Error converting quotation to invoice: $e");
      Get.snackbar(
        'Error',
        'Failed to convert quotation: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade700),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update quotation status - Only updates the QUOTATION row, not the invoice
  Future<void> _updateQuotationStatus(String quotationId, String newStatus) async {
    try {
      final updated = await GoogleSheetService.updateInvoiceStatus(quotationId, newStatus);
      if (updated) {
        final index = quotationList.indexWhere((q) => q.invoiceId == quotationId);
        if (index != -1) {
          quotationList[index] = quotationList[index].copyWith(status: newStatus);
          quotationList.refresh();
          filterQuotations(searchQuery.value);
        }
      } else {
        Get.snackbar('Warning', 'Quotation row not found in sheet to update status',
            backgroundColor: Colors.orange.shade100, colorText: Colors.orange.shade800);
      }
    } catch (e) {
      print("❌ Error updating quotation status: $e");
      // optional snackbar
    }
  }


  void filterQuotations(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredQuotationList.assignAll(quotationList);
      return;
    }

    final filtered = quotationList.where((quotation) {
      return quotation.invoiceId.toLowerCase().contains(query.toLowerCase()) ||
          quotation.customerName.toLowerCase().contains(query.toLowerCase()) ||
          quotation.totalAmount.toString().contains(query);
    }).toList();

    filteredQuotationList.assignAll(filtered);
  }

  void filterByStatus(String status) {
    selectedFilter.value = status;
    if (status == 'All') {
      filteredQuotationList.assignAll(quotationList);
      return;
    }

    final filtered = quotationList.where((quotation) {
      return quotation.status?.toLowerCase() == status.toLowerCase();
    }).toList();

    filteredQuotationList.assignAll(filtered);
  }

  void refreshQuotations() async {
    await loadQuotations();
  }

  void viewQuotationDetails(Invoice quotation) {
    Get.lazyPut<InvoiceDetailsController>(() => InvoiceDetailsController());
    Get.to(() => InvoiceDetailsScreen(), arguments: quotation);
  }

  Future<void> deleteQuotation(Invoice quotation) async {
    final confirmed = await Get.dialog(
      AlertDialog(
        title: Text('Delete Quotation?'),
        content: Text('Are you sure you want to delete quotation ${quotation.invoiceId}?'),
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
        //await GoogleSheetService.deleteInvoice(quotation.invoiceId);
        quotationList.remove(quotation);
        filteredQuotationList.remove(quotation);

        Get.snackbar(
          'Deleted',
          'Quotation ${quotation.invoiceId} has been deleted',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete quotation: ${e.toString()}',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> exportQuotationAsPdf(Invoice quotation) async {
    try {
      isLoading.value = true;

      print("Fetching quotation items for PDF: ${quotation.invoiceId}");

      // Fetch items from Google Sheets
      List<InvoiceItem> fetchedQuotationItems =
      await GoogleSheetService.getInvoiceItemsByInvoiceId(quotation.invoiceId);

      if (fetchedQuotationItems.isEmpty) {
        Get.snackbar(
          'Warning',
          'No items found for this quotation',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
        isLoading.value = false;
        return;
      }

      // ✅ Clean item names (fallback to description if blank)
      final cleanedItems = fetchedQuotationItems.map((item) {
        final fixedName = (item.itemName != null && item.itemName.trim().isNotEmpty)
            ? item.itemName
            : (item.description ?? "Service/Product");

        return InvoiceItem(
          itemId: item.itemId,
          itemName: fixedName,
          description: item.description,
          quantity: item.quantity,
          rate: item.rate,
          gstRate: item.gstRate,
          gstAmount: item.gstAmount,
          amountWithGst: item.amountWithGst,
          totalPrice: item.totalPrice,
        );
      }).toList();

      // ✅ Debug output
      print("Found ${cleanedItems.length} items for quotation ${quotation.invoiceId}");
      for (var item in cleanedItems) {
        print("PDF Item -> name: ${item.itemName}, qty: ${item.quantity}, rate: ${item.rate}, gst: ${item.gstAmount}");
      }

      // ✅ Generate PDF using the same method as InvoiceListScreen
      final pdfFile = await InvoiceHelper.generateDocumentPrint(
        isChallan: false,
        invoice: quotation,
        invoiceItems: cleanedItems,
        companyData: companyData.value,
      );

      // ✅ FIX: Check if file exists (Mobile) before sharing
      if (pdfFile != null) {
        await Share.shareXFiles(
            [XFile(pdfFile.path)],
            text: 'Quotation - ${quotation.invoiceId}'
        );
      }
      else {
        print("Web download triggered automatically");
      }

      Get.snackbar(
        'Success',
        'Quotation exported as PDF',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: Icon(Icons.check_circle, color: Colors.green.shade700),
      );

    } catch (e) {
      print("Error exporting PDF: $e");
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade700),
      );
    } finally {
      isLoading.value = false;
    }
  }

  double get totalValue {
    return quotationList.fold(0, (sum, quotation) => sum + (quotation.totalAmount ?? 0));
  }

  int get totalQuotations => quotationList.length;
  int get acceptedQuotations => quotationList.where((q) => q.status == 'Accepted').length;
  int get pendingQuotations => quotationList.where((q) => q.status == 'Pending').length;
  int get convertedQuotations => quotationList.where((q) => q.status == 'Converted').length;
}