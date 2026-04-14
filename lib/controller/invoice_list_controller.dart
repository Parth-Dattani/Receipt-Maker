import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GetYourInvoice/constant/app_colors.dart';
import 'package:GetYourInvoice/screen/screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:GetYourInvoice/constant/app_constant.dart';
import '../model/model.dart';
import '../services/service.dart';
import '../utils/utils.dart';
import 'controller.dart';
import 'new_invoice_controller.dart' show InvoiceType;
import '../utils/financial_year_helper.dart';


///8-10
// class InvoiceListController extends BaseController {
//   final isLoading = false.obs;
//   final invoiceList = <Invoice>[].obs;
//   final filteredInvoiceList = <Invoice>[].obs;
//   final invoiceItems = <InvoiceItem>[].obs;
//   final searchQuery = ''.obs;
//   final selectedFilter = 'All'.obs;
//   var companyData = <String, dynamic>{}.obs;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadInvoices();
//     loadCompanyData();
//   }
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
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadInvoices() async {
//     try {
//       isLoading.value = true;
//       print("=== LOADING INVOICES ===");
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
//
//       List<Invoice> invoices = await GoogleSheetService.getInvoices(type: "INV");
//
//       // If no invoices found, try alternative method
//       if (invoices.isEmpty) {
//         print("Standard method failed, trying alternative...");
//         invoices = await GoogleSheetService.getInvoices();
//       }
//
//       // Filter invoices by current user ID
//       List<Invoice> userInvoices = invoices.where((invoice) {
//         // Check if invoice has userId field and it matches current user
//         return invoice.userId == currentUserId;
//       }).toList();
//       print("=============usrInvoice----${userInvoices}");
//
//       // If no invoices found, try alternative methods
//       if (userInvoices.isEmpty) {
//         print("Standard method failed, trying alternative...");
//         invoices = await GoogleSheetService.getInvoices();
//         // Filter again
//         userInvoices = invoices.where((invoice) => invoice.userId == currentUserId).toList();
//       }
//
//       invoiceList.assignAll(userInvoices);
//       filteredInvoiceList.assignAll(userInvoices);
//
//       print("✅ Loaded ${invoices.length} invoices");
//
//       if (userInvoices.isEmpty) {
//         Get.snackbar(
//           'No Invoices',
//           'No invoices found in the system',
//           backgroundColor: Colors.orange.shade100,
//           colorText: Colors.orange.shade800,
//           icon: Icon(Icons.info_outline, color: Colors.orange.shade700),
//         );
//       }
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
//           (invoice.itemName!.toLowerCase().contains(query.toLowerCase()) ?? false);
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
//     Get.toNamed(InvoiceDetailsScreen.pageId, arguments: invoice);
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
//   /// Updated method with proper parameter handling ---invoice
//   void exportInvoiceAsPdf(Invoice invoice) async {
//     try {
//       // Show loading indicator
//       isLoading.value = true;
//
//       // Fetch the invoice items for this specific invoice
//       print("Fetching invoice items for PDF: ${invoice.invoiceId}");
//       List<InvoiceItem> fetchedInvoiceItems = await GoogleSheetService.getInvoiceItemsByInvoiceId(invoice.invoiceId);
//
//       print("Fettttttt----ITem======= :${fetchedInvoiceItems[0].gstAmount}");
//
//       // ✅ Fix: Fallback itemName -> description if blank
//       final cleanedItems = fetchedInvoiceItems.map((item) {
//         final fixedName = (item.itemName != null && item.itemName.trim().isNotEmpty)
//             ? item.itemName
//             : (item.description ?? "Service/Product");
//
//
//         // final qty = (item.quantity ?? 0).toDouble();
//         // final rate = item.rate ?? 0.0;
//         // final baseAmount = qty * rate;
//         // final gstRate = (item.gstRate ?? 0).toDouble();
//         // final gstAmount = (baseAmount * gstRate) / 100;
//         // final totalWithGst = baseAmount + gstAmount;
//
//
//         return InvoiceItem(
//           itemId: item.itemId,
//           itemName: fixedName,
//           description: item.description,
//           quantity: item.quantity,
//           rate: item.rate,
//           gstRate: item.gstRate,
//           gstAmount: item.gstAmount,           // ✅ Keep original from sheet
//           amountWithGst: item.amountWithGst,   // ✅ Keep original from sheet
//           totalPrice: item.totalPrice,
//         );
//       }).toList();
//
//       // invoiceItems.assignAll(cleanedItems);
//
//       //print("Found ${invoiceItems.length} items for invoice ${invoice.invoiceId}");
//
//       /// ✅ Debug: Print the ACTUAL data being used
//       print("Found ${cleanedItems.length} items for challan ${invoice.invoiceId}");
//       for (var item in cleanedItems) {
//         print("PDF Item -> name: ${item.itemName}, desc: ${item.description}, qty: ${item.quantity}, price: ${item.rate}-----GSt: ${item.gstAmount}---tot: ${item.totalPrice}");
//       }
//       print("--------=================-----------");
//       print(cleanedItems, );
//
//       // ✅ Calculate totals
//       final subtotal = cleanedItems.fold<double>(0, (s, it) {
//         final qty = (it.quantity ?? 0).toDouble();
//         final rate = it.rate ?? 0.0;
//         return s + (qty * rate);
//       });
//
//       final gstTotal = cleanedItems.fold<double>(0, (s, it) {
//         final qty = (it.quantity ?? 0).toDouble();
//         final rate = it.rate ?? 0.0;
//         final base = qty * rate;
//         return s + ((base * (it.gstRate ?? 0)) / 100);
//       });
//
//       final discount = invoice.discountAmount ?? 0.0;
//       final grandTotal = subtotal + gstTotal - discount;
//
//
//       /// If no items found, create a default item based on invoice data
//       // if (fetchedInvoiceItems.isEmpty) {
//       //   print("No items found, creating default item from invoice data");
//       //   fetchedInvoiceItems = [
//       //     InvoiceItem(
//       //       description: invoice.itemName!,
//       //       itemId: invoice.itemId!,
//       //       itemName: invoice.itemName!,
//       //       quantity: invoice.qty ?? 1,
//       //       rate: invoice.price ?? 0.0,
//       //       totalPrice: invoice.totalAmount ?? 0.0,
//       //     ),
//       //   ];
//       // }
//       for (var item in invoiceItems) {
//         print("PDF Item -> name: ${item.itemName}, desc: ${item.description}, qty: ${item.quantity}, rate: ${item.rate} gst: ${item.gstAmount}, total: ${item.totalPrice}");
//       }
//
//       // DEBUG: Print the data before generating PDF
//       print("--------=================-----------");
//       print(invoiceItems, );
//
//
//       /// Generate PDF with the complete invoice data including items
//       final pdfFile = await InvoiceHelper
//       //     .generate(
//       //   invoice,
//       //   cleanedItems,
//       //   companyData,
//       //   subtotal: subtotal,
//       //   gstAmount: gstTotal,
//       //   total: grandTotal,
//       //   discount: discount,
//       // );
//
//           .generateDocument(
//       isChallan: false,
//           invoice: invoice,
//            invoiceItems: cleanedItems,
//            companyData: companyData.value,
//         //  subtotal: subtotal,
//         // gstAmount: gstTotal,   // ✅ pass GST to PDF
//         // total: grandTotal,
//       );
//
//       /// Open the PDF file
//       ///await OpenFile.open(pdfFile.path);
//       await Share.shareXFiles([XFile(pdfFile.path)], text: 'Invoice - ${invoice.invoiceId}');
//
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

class InvoiceListController extends BaseController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final invoiceList = <Invoice>[].obs;
  final filteredInvoiceList = <Invoice>[].obs;
  final invoiceItems = <InvoiceItem>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  var companyData = <String, dynamic>{}.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController scrollController = ScrollController();

  static const int _pageSize = 50;
  int _offset = 0; // data-row offset (row2 = offset0)

  @override
  void onInit() {
    super.onInit();
    // Load both in parallel without showing loader initially
    _initializeData();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!hasMore.value) return;
    if (isLoading.value || isLoadingMore.value) return;
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= (pos.maxScrollExtent - 280)) {
      loadNextPage();
    }
  }

  // ✅ Initialize data without premature loading state
  Future<void> _initializeData() async {
    // Load company data silently in background
    loadCompanyData();
    // Load invoices with loading state
    await loadFirstPage();
  }

  Future<void> loadCompanyData() async {
    try {
      // ❌ REMOVED: isLoading.value = true;
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
    }
    // ❌ REMOVED: finally block that sets isLoading = false
  }

  Future<void> loadFirstPage() async {
    try {
      isLoading.value = true;
      print("=== LOADING INVOICES ===");

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        print("⚠️ loadFirstPage skipped: no signed-in user");
        return;
      }

      _offset = 0;
      hasMore.value = true;
      invoiceList.clear();
      filteredInvoiceList.clear();

      final (page, more) = await GoogleSheetService.getInvoicesPage(
        type: "INV",
        offset: _offset,
        limit: _pageSize,
      );
      hasMore.value = more;
      _offset += _pageSize;

      final fyFiltered = _applyUserAndFyFilters(page, currentUserId);
      invoiceList.assignAll(fyFiltered);
      _applyCurrentFilters();

      if (invoiceList.isEmpty) {
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

  /// Backward-compat alias (older code calls this).
  Future<void> loadInvoices() async => loadFirstPage();

  Future<void> loadNextPage() async {
    if (!hasMore.value) return;
    if (isLoading.value || isLoadingMore.value) return;
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      isLoadingMore.value = true;
      final (page, more) = await GoogleSheetService.getInvoicesPage(
        type: "INV",
        offset: _offset,
        limit: _pageSize,
      );
      hasMore.value = more;
      _offset += _pageSize;

      final fyFiltered = _applyUserAndFyFilters(page, currentUserId);
      if (fyFiltered.isNotEmpty) {
        invoiceList.addAll(fyFiltered);
        _applyCurrentFilters();
      }
    } catch (e) {
      print("❌ Error loading more invoices: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  List<Invoice> _applyUserAndFyFilters(List<Invoice> invoices, String currentUserId) {
    // User filter (backward compat: empty uid allowed)
    final userInvoices = invoices.where((invoice) {
      final uid = invoice.userId?.toString().trim() ?? '';
      return uid.isEmpty || uid == currentUserId;
    }).toList();

    // FY filter
    final fy = AppConstants.activeFy.isNotEmpty ? AppConstants.activeFy : FinancialYearHelper.currentFy();
    final fyRange = FinancialYearHelper.parseFy(fy);
    if (fyRange == null) return userInvoices;
    final start = DateTime(fyRange.$1, 4, 1);
    final end = DateTime(fyRange.$2, 3, 31, 23, 59, 59, 999);
    return userInvoices.where((inv) {
      final d = inv.issueDate ?? inv.updatedAt;
      if (d == null) return false;
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  void _applyCurrentFilters() {
    // Apply search
    final q = searchQuery.value.trim();
    List<Invoice> list = invoiceList.toList();
    if (q.isNotEmpty) {
      list = list.where((invoice) {
        final name = invoice.customerName.toLowerCase();
        final id = invoice.invoiceId.toLowerCase();
        final itemName = (invoice.itemName ?? '').toLowerCase();
        return id.contains(q.toLowerCase()) ||
            name.contains(q.toLowerCase()) ||
            itemName.contains(q.toLowerCase()) ||
            (invoice.totalAmount?.toString().contains(q) ?? false);
      }).toList();
    }

    // Apply status filter
    final status = selectedFilter.value;
    if (status != 'All') {
      list = list.where((inv) => (inv.status ?? '').toLowerCase() == status.toLowerCase()).toList();
    }
    filteredInvoiceList.assignAll(list);
  }

  void filterInvoices(String query) {
    searchQuery.value = query;
    _applyCurrentFilters();
  }

  void filterByStatus(String status) {
    selectedFilter.value = status;
    _applyCurrentFilters();
  }

  void refreshInvoices() async {
    // Force fresh read (avoid showing stale cached list)
    GoogleSheetService.clearInvoiceListCacheForNewFy();
    await loadFirstPage();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void viewInvoiceDetails(Invoice invoice) {
    Get.lazyPut<InvoiceDetailsController>(() => InvoiceDetailsController());
    Get.toNamed(InvoiceDetailsScreen.pageId, arguments: invoice);
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

  void exportInvoiceAsPdf(Invoice invoice) async {
    try {
      isLoading.value = true;

      print("Fetching invoice items for PDF: ${invoice.invoiceId}");
      List<InvoiceItem> fetchedInvoiceItems = await GoogleSheetService.getInvoiceItemsByInvoiceId(invoice.invoiceId);

      if (fetchedInvoiceItems.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'No items found for this invoice',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

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
          gstRate: item.gstRate,
          gstAmount: item.gstAmount,
          amountWithGst: item.amountWithGst,
          totalPrice: item.totalPrice,
        );
      }).toList();

      final subtotal = cleanedItems.fold<double>(0, (s, it) {
        final qty = (it.quantity ?? 0).toDouble();
        final rate = it.rate ?? 0.0;
        return s + (qty * rate);
      });

      final gstTotal = cleanedItems.fold<double>(0, (s, it) {
        final qty = (it.quantity ?? 0).toDouble();
        final rate = it.rate ?? 0.0;
        final base = qty * rate;
        return s + ((base * (it.gstRate ?? 0)) / 100);
      });

      final discount = invoice.discountAmount ?? 0.0;
      final grandTotal = subtotal + gstTotal - discount;

      final invoiceModels = cleanedItems.map((item) {
        return Invoice(
          invoiceId: invoice.invoiceId,
          itemId: item.itemId,
          itemName: item.itemName,
          qty: item.quantity,
          price: item.rate,
          gst: item.gstRate ?? 0.0,
          mobile: invoice.mobile,
          customerName: invoice.customerName,
          customerId: invoice.customerId,
          customerEmail: invoice.customerEmail,
          customerPan: invoice.customerPan,
          customerGst: invoice.customerGst,
          customerAddress: invoice.customerAddress,
          issueDate: invoice.issueDate,
          dueDate: invoice.dueDate,
          subtotal: subtotal,
          gstAmount: gstTotal,
          totalAmount: grandTotal,
          notes: invoice.notes,
          status: invoice.status,
          items: [item],
        );
      }).toList();

      isLoading.value = false;

      String formatDate(DateTime? d) => d != null ? DateFormat('dd/MM/yyyy').format(d) : '';
      final Map<String, dynamic> company = Map<String, dynamic>.from(companyData.value);

      await Get.defaultDialog(
        title: "Export PDF",
        titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select format:", style: TextStyle(fontSize: 14)),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor, foregroundColor: Colors.white),
                icon: Icon(Icons.print),
                label: Text("Thermal Print"),
                onPressed: () async {
                  Get.back();
                  try {
                    await InvoiceHelper.generateAndShareInvoicePrint(
                      invoiceModels,
                      invoice.customerName ?? '',
                      invoice.mobile ?? '',
                      invoice.customerEmail ?? '',
                      invoice.customerPan ?? '',
                      invoice.customerGst ?? '',
                      invoice.customerAddress ?? '',
                      subtotal,
                      formatDate(invoice.issueDate),
                      grandTotal,
                      invoice.notes ?? '',
                      company,
                      InvoiceType.invoice,
                      gstTotal,
                      formatDate(invoice.dueDate),
                    );
                    Get.snackbar('Success', 'Thermal print ready', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                  } catch (e) {
                    print("Thermal print error: $e");
                    Get.snackbar('Error', 'Failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.tealColor),
                icon: Icon(Icons.picture_as_pdf),
                label: Text("A4 Print"),
                onPressed: () async {
                  Get.back();
                  try {
                    await InvoiceHelper.generateAndShareInvoiceColor(
                      invoiceModels,
                      invoice.customerName ?? '',
                      invoice.mobile ?? '',
                      invoice.customerEmail ?? '',
                      invoice.customerPan ?? '',
                      invoice.customerGst ?? '',
                      invoice.customerAddress ?? '',
                      subtotal,
                      formatDate(invoice.issueDate),
                      grandTotal,
                      invoice.notes ?? '',
                      company,
                      InvoiceType.invoice,
                      gstTotal,
                      formatDate(invoice.dueDate),
                    );
                    Get.snackbar('Success', 'A4 PDF ready', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                  } catch (e) {
                    print("A4 print error: $e");
                    Get.snackbar('Error', 'Failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      print("Error exporting PDF: $e");
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  double get totalRevenue {
    return invoiceList.fold(0, (sum, invoice) => sum + (invoice.totalAmount ?? 0));
  }

  int get totalInvoices => invoiceList.length;

  int get paidInvoices => invoiceList.where((invoice) => invoice.status == 'Paid').length;

  int get pendingInvoices => invoiceList.where((invoice) => invoice.status == 'Pending').length;
}