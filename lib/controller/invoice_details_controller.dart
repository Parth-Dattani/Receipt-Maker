import 'package:GetYourInvoice/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../model/model.dart';
import '../screen/screen.dart';
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

import 'controller.dart';




class InvoiceDetailsController extends GetxController {
  final invoice = Rxn<Invoice>();
  final invoiceItems = <InvoiceItem>[].obs;
  final isLoading = false.obs;
  final isLoadingItems = false.obs;
  final isEditMode = false.obs;
  final isSaving = false.obs; // Added for save operations

  late TextEditingController customerNameCtrl;
  late TextEditingController customerPanCtrl;
  late TextEditingController customerGstCtrl;
  late TextEditingController customerEmailCtrl;
  late TextEditingController customerPhoneCtrl;
  late TextEditingController customerAddressCtrl;

  var statusOptions = ["Pending", "Paid", "Overdue"];
  late RxString selectedStatus;

  /// Editable items for edit mode
  var editableItems = <Map<String, TextEditingController>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // init controllers
    customerNameCtrl = TextEditingController();
    customerEmailCtrl = TextEditingController();
    customerPanCtrl = TextEditingController();
    customerGstCtrl = TextEditingController();
    customerPhoneCtrl = TextEditingController();
    customerAddressCtrl = TextEditingController();

    // get invoice from navigation
    final Invoice? passedInvoice = Get.arguments as Invoice?;
    if (passedInvoice != null) {
      invoice.value = passedInvoice;

      selectedStatus = (passedInvoice.status ?? "Pending").obs;

      // populate UI fields
      customerNameCtrl.text = passedInvoice.customerName ?? '';
      customerPanCtrl.text = passedInvoice.customerPan ?? '';
      customerGstCtrl.text = passedInvoice.customerGst ?? '';
      customerEmailCtrl.text = passedInvoice.customerEmail ?? '';
      customerPhoneCtrl.text = passedInvoice.mobile ?? '';
      customerAddressCtrl.text = passedInvoice.customerAddress ?? '';

      // load items if id exists
      if ((passedInvoice.invoiceId ?? '').isNotEmpty) {
        loadInvoiceItems(passedInvoice.invoiceId!);
      }
    }
  }

  @override
  void onClose() {
    _safeDisposeController(customerNameCtrl);
    _safeDisposeController(customerEmailCtrl);
    _safeDisposeController(customerPanCtrl);
    _safeDisposeController(customerGstCtrl);
    _safeDisposeController(customerPhoneCtrl);
    _safeDisposeController(customerAddressCtrl);

    for (var m in editableItems) {
      _safeDisposeController(m['itemName']);
      _safeDisposeController(m['qty']);
      _safeDisposeController(m['rate']);
    }
    super.onClose();
  }

  /// Navigate to edit mode with proper loading management
  void navigateToEditMode() async {
    final currentInvoice = invoice.value;
    if (currentInvoice == null) {
      Get.snackbar(
        'Error',
        'No invoice data available for editing',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    /// ✅ CHECK IF INVOICE IS PAID
    // if (currentInvoice.status?.toLowerCase() == 'paid') {
    //   Get.dialog(
    //     AlertDialog(
    //       title: Row(
    //         children: [
    //           Icon(Icons.lock, color: Colors.orange.shade700, size: 28),
    //           SizedBox(width: 12),
    //           Text('Invoice Locked'),
    //         ],
    //       ),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(
    //             'This invoice has been marked as PAID and cannot be edited.',
    //             style: TextStyle(fontSize: 16),
    //           ),
    //           SizedBox(height: 16),
    //           Container(
    //             padding: EdgeInsets.all(12),
    //             decoration: BoxDecoration(
    //               color: Colors.green.shade50,
    //               borderRadius: BorderRadius.circular(8),
    //               border: Border.all(color: Colors.green.shade200),
    //             ),
    //             child: Row(
    //               children: [
    //                 Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
    //                 SizedBox(width: 8),
    //                 Expanded(
    //                   child: Text(
    //                     'Status: PAID',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       color: Colors.green.shade800,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           SizedBox(height: 12),
    //           Text(
    //             'To make changes, first change the status to "Pending" or "Partial" in the invoice management system.',
    //             style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
    //           ),
    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Get.back(),
    //           child: Text('OK', style: TextStyle(fontSize: 16)),
    //         ),
    //       ],
    //     ),
    //     barrierDismissible: true,
    //   );
    //   return;
    // }

    /// Prevent multiple clicks
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;

      print("=== STARTING EDIT MODE NAVIGATION ===");
      print("Current invoice: ${currentInvoice.invoiceId}");
      print("Current items count: ${invoiceItems.length}");

      // Clean up existing controller
      if (Get.isRegistered<NewInvoiceController>()) {
        print("Removing old controller");
        Get.delete<NewInvoiceController>(force: true);
      }

      await Future.delayed(Duration(milliseconds: 50));

      // Register the controller BEFORE navigation
      Get.put(NewInvoiceController());

      final argumentsMap = {
        'editMode': true,
        'invoiceId': currentInvoice.invoiceId,
        'invoiceData': currentInvoice,
      };

      print("Navigation arguments: editMode=${argumentsMap['editMode']}, invoiceId=${argumentsMap['invoiceId']}");

      // Navigate and wait for result
      final result = await Get.to(
            () => NewInvoiceScreen(),
        arguments: argumentsMap,
        preventDuplicates: true,
      );

      print("=== NAVIGATION COMPLETED ===");
      print("Result: $result");

      // Force refresh data after navigation
      await Future.delayed(Duration(milliseconds: 200));

      print("=== FORCING DATA REFRESH ===");
      await forceRefreshInvoiceData();

      if (result == true) {
        Get.snackbar(
          'Success',
          'Invoice updated and data refreshed',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }

    } catch (e, stack) {
      print('Navigation error: $e');
      print('Stack trace: $stack');
      Get.snackbar(
        'Error',
        'Failed to open edit screen: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Still try to refresh
      try {
        await forceRefreshInvoiceData();
      } catch (refreshError) {
        print('Error refreshing: $refreshError');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Force refresh with cache clearing and proper loading state
  Future<void> forceRefreshInvoiceData() async {
    // Don't start new refresh if already refreshing
    if (isLoadingItems.value) {
      print("Already refreshing, skipping...");
      return;
    }

    try {
      print("=== FORCE REFRESHING INVOICE DATA ===");

      final currentInvoice = invoice.value;
      if (currentInvoice?.invoiceId == null) {
        print("No invoice to refresh");
        return;
      }

      isLoadingItems.value = true;

      // Clear the cache first
      GoogleSheetService.clearInvoiceItemCache(currentInvoice!.invoiceId!);

      print("Fetching fresh data for invoice: ${currentInvoice.invoiceId}");

      // Force fresh load from sheets
      final List<InvoiceItem> freshItems =
      await GoogleSheetService.getInvoiceItemsByInvoiceId(
          currentInvoice.invoiceId!);

      print("=== FRESH DATA RECEIVED ===");
      print("Total items: ${freshItems.length}");

      // Clear and assign new data
      invoiceItems.clear();
      invoiceItems.assignAll(freshItems);

      // Debug each item
      for (int i = 0; i < freshItems.length; i++) {
        print("Item $i: ${freshItems[i].itemName}");
        print("  Qty: ${freshItems[i].quantity}");
        print("  Rate: ${freshItems[i].rate}");
        print("  Total: ${freshItems[i].totalPrice}");
      }

      // Update UI controllers
      _setupEditableItemsFromLoaded(freshItems);

      // Force UI update
      invoiceItems.refresh();

      print("=== REFRESH COMPLETED ===");
      print("Final items count: ${invoiceItems.length}");

    } catch (e, stack) {
      print("Error force refreshing: $e");
      print("Stack: $stack");
      Get.snackbar(
        'Error',
        'Failed to refresh invoice data: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingItems.value = false;
    }
  }

  /// Keep for backward compatibility
  Future<void> refreshInvoiceData() async {
    await forceRefreshInvoiceData();
  }

  /// Load invoice details
  Future<void> loadInvoiceDetails(String invoiceId) async {
    // Prevent duplicate loads
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;
      print("Loading fresh invoice details for ID: $invoiceId");

      await loadInvoiceItems(invoiceId);

      print("Invoice details loaded successfully");
    } catch (e) {
      print('Error loading invoice details: $e');
      Get.snackbar(
        'Error',
        'Failed to load invoice details: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load invoice items with proper loading state
  Future<void> loadInvoiceItems(String invoiceId) async {
    // Prevent duplicate loads
    if (isLoadingItems.value) {
      print("Already loading items, skipping...");
      return;
    }

    try {
      isLoadingItems.value = true;
      print("🔄 Loading items for: $invoiceId");

      invoiceItems.clear();

      final List<InvoiceItem> freshItems =
      await GoogleSheetService.getInvoiceItemsByInvoiceId(invoiceId);

      // Debug: Check what we got
      print("=== LOADED ITEMS DEBUG ===");
      for (var item in freshItems) {
        print("Loaded item: ${item.itemName}");
        print("  - Rate: ${item.rate}");
        print("  - Quantity: ${item.quantity}");
        print("  - Total: ${item.totalPrice}");
        print("  - GST Rate: ${item.gstRate}");
      }

      invoiceItems.assignAll(freshItems);
      _setupEditableItemsFromLoaded(freshItems);
      invoiceItems.refresh();

      print("✅ Items loaded successfully: ${freshItems.length} items");

    } catch (e, st) {
      print('❌ Error loading items: $e\n$st');
      Get.snackbar(
        'Error',
        'Failed to load invoice items: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingItems.value = false;
    }
  }

  /// Safely dispose a TextEditingController (handles already-disposed case).
  void _safeDisposeController(TextEditingController? c) {
    if (c == null) return;
    try {
      c.dispose();
    } catch (_) {
      // Already disposed - ignore
    }
  }

  void _setupEditableItemsFromLoaded(List<InvoiceItem> items) {
    // Safely dispose old controllers (may already be disposed when returning from edit screen)
    for (var m in editableItems) {
      _safeDisposeController(m['itemName']);
      _safeDisposeController(m['qty']);
      _safeDisposeController(m['rate']);
    }

    final newList = <Map<String, TextEditingController>>[];
    for (var item in items) {
      String itemName = item.itemName?.trim().isNotEmpty == true
          ? item.itemName!.trim()
          : (item.description ?? '');
      newList.add({
        'itemName': TextEditingController(text: itemName),
        'qty': TextEditingController(text: (item.quantity ?? 1).toString()),
        'rate': TextEditingController(
            text: (item.rate ?? 0.0).toStringAsFixed(2)),
      });
    }

    editableItems.value = newList.isNotEmpty
        ? newList
        : [
      {
        'itemName': TextEditingController(),
        'qty': TextEditingController(text: '1'),
        'rate': TextEditingController(text: '0.00'),
      }
    ];
    editableItems.refresh();
  }

  /// --- Edit mode controls ---
  void enterEditMode() {
    if (editableItems.isEmpty) {
      if (invoiceItems.isNotEmpty) {
        _setupEditableItemsFromLoaded(invoiceItems);
      } else if ((invoice.value?.items ?? []).isNotEmpty) {
        _setupEditableItemsFromLoaded(invoice.value!.items!);
      } else {
        addNewItem();
      }
    }
    isEditMode.value = true;
  }

  void addNewItem() {
    editableItems.add({
      'itemName': TextEditingController(),
      'qty': TextEditingController(text: '1'),
      'rate': TextEditingController(text: '0.00'),
    });
    editableItems.refresh();
  }

  void removeItem(int index) {
    if (index >= 0 && index < editableItems.length) {
      _safeDisposeController(editableItems[index]['itemName']);
      _safeDisposeController(editableItems[index]['qty']);
      _safeDisposeController(editableItems[index]['rate']);
      editableItems.removeAt(index);
      if (editableItems.isEmpty) addNewItem();
      editableItems.refresh();
    }
  }

  /// --- Totals ---
  double calculateItemTotal(int index) {
    if (index < 0 || index >= editableItems.length) return 0.0;
    final qty = double.tryParse(editableItems[index]['qty']?.text ?? '0') ?? 0;
    final rate =
        double.tryParse(editableItems[index]['rate']?.text ?? '0') ?? 0.0;
    return qty * rate;
  }

  double get calculatedTotal =>
      List.generate(editableItems.length, (i) => calculateItemTotal(i))
          .fold(0.0, (a, b) => a + b);

  double calculateItemGst(InvoiceItem item) {
    final qty = (item.quantity ?? 0).toDouble();
    final rate = item.rate ?? 0.0;
    final base = qty * rate;
    final gstRate = (item.gstRate ?? 0).toDouble();
    return (base * gstRate) / 100;
  }

  double get totalGstAmount =>
      invoiceItems.fold(0.0, (s, it) => s + calculateItemGst(it));

  double get itemsSubtotal => isEditMode.value
      ? calculatedTotal
      : invoiceItems.fold(
      0.0, (s, it) => s + ((it.quantity ?? 0) * (it.rate ?? 0.0)));

  double get grandTotal {
    final discount = invoice.value?.discountAmount ?? 0.0;
    return itemsSubtotal + totalGstAmount - discount;
  }

  /// Update invoice with proper loading management
  Future<void> updateInvoice() async {
    // Prevent duplicate saves
    if (isSaving.value) {
      print("Already saving, skipping...");
      return;
    }

    try {
      isSaving.value = true;

      final updatedInvoice = invoice.value;
      if (updatedInvoice == null) throw Exception("No invoice selected");

      print("=== UPDATING INVOICE ===");
      print("Invoice ID: ${updatedInvoice.invoiceId}");

      final updatedItems = <InvoiceItem>[];
      for (int i = 0; i < editableItems.length; i++) {
        final ctrls = editableItems[i];
        final itemName = ctrls['itemName']?.text.trim() ?? '';
        final qty = double.tryParse(ctrls['qty']?.text ?? '0') ?? 0;
        final rate = double.tryParse(ctrls['rate']?.text ?? '0') ?? 0.0;

        if (itemName.isEmpty && qty == 0 && rate == 0) continue;

        final existingItemId = (i < invoiceItems.length)
            ? invoiceItems[i].itemId
            : DateTime.now().millisecondsSinceEpoch.toString();

        updatedItems.add(InvoiceItem(
          itemId: existingItemId,
          invoiceId: updatedInvoice.invoiceId,
          itemName: itemName,
          description: itemName,
          quantity: qty,
          rate: rate,
          purchasePrice: (i < invoiceItems.length) ? invoiceItems[i].purchasePrice : 0.0,
        ));
      }

      print("Updated items count: ${updatedItems.length}");

      final subtotal = updatedItems.fold<double>(
          0, (s, it) => s + ((it.quantity ?? 0) * (it.rate ?? 0.0)));
      final gstAmount =
      updatedItems.fold<double>(0, (s, it) => s + calculateItemGst(it));
      final discount = updatedInvoice.discountAmount ?? 0;
      final total = subtotal + gstAmount - discount;

      print("Subtotal: $subtotal");
      print("GST: $gstAmount");
      print("Total: $total");

      double calculatedProfit = 0.0;
      for (var it in updatedItems) {
        final sellTotal = (it.rate ?? 0) * (it.quantity ?? 0);
        final purchaseTotal = it.purchasePrice * (it.quantity ?? 0);
        calculatedProfit += (sellTotal - purchaseTotal);
      }

      final invoiceData = {
        'invoiceId': updatedInvoice.invoiceId,
        'customerName': customerNameCtrl.text,
        'customerPan': customerPanCtrl.text,
        'customerGst': customerGstCtrl.text,
        'pan': customerPanCtrl.text,
        'gst': customerGstCtrl.text,
        'customerEmail': customerEmailCtrl.text,
        'customerPhone': customerPhoneCtrl.text,
        'mobile': customerPhoneCtrl.text,
        'customerAddress': customerAddressCtrl.text,
        'issueDate': updatedInvoice.issueDate?.toIso8601String(),
        'dueDate': updatedInvoice.dueDate?.toIso8601String(),
        'subtotal': subtotal.toStringAsFixed(2),
        'gstAmount': gstAmount.toStringAsFixed(2),
        'discountAmount': discount.toStringAsFixed(2),
        'totalAmount': total.toStringAsFixed(2),
        'status': selectedStatus.value,
        'profit': calculatedProfit,
        'invoiceType': 'invoice',
        'updatedAt': DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      };

      await GoogleSheetService.updateInvoice(invoiceData, AppConstants.userId);
      await GoogleSheetService.updateInvoiceItems(
        updatedInvoice.invoiceId!,
        updatedItems.map((e) => e.toMap()).toList(),
        AppConstants.userId,
      );

      invoiceItems.assignAll(updatedItems);
      isEditMode.value = false;

      print("✅ Invoice updated successfully");

      Get.snackbar(
        "Success",
        "Invoice updated successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

    } catch (e, st) {
      print("❌ Error in updateInvoice: $e\n$st");
      Get.snackbar(
        "Error",
        "Failed to update invoice: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Refresh with user feedback
  Future<void> refreshInvoiceItems() async {
    if ((invoice.value?.invoiceId ?? '').isEmpty) {
      Get.snackbar(
        'Error',
        'No invoice ID available',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    print("🔄 MANUAL REFRESH TRIGGERED");
    await loadInvoiceItems(invoice.value!.invoiceId!);

    Get.snackbar(
      'Success',
      'Items refreshed from server',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  /// Debug data flow
  void debugDataFlow() async {
    print("=== DEBUGGING DATA FLOW ===");

    // Check controller registration
    print("Controllers registered:");
    print("  - InvoiceListController: ${Get.isRegistered<InvoiceListController>()}");
    print("  - InvoiceDetailsController: ${Get.isRegistered<InvoiceDetailsController>()}");

    // Check current data
    if (Get.isRegistered<InvoiceListController>()) {
      final listController = Get.find<InvoiceListController>();
      print("  - InvoiceList count: ${listController.invoiceList.length}");
      print("  - FilteredList count: ${listController.filteredInvoiceList.length}");

      // Find current invoice in the list
      final currentInvoiceInList = listController.invoiceList.firstWhereOrNull(
              (inv) => inv.invoiceId == invoice.value?.invoiceId);

      if (currentInvoiceInList != null) {
        print("  - Current invoice found in list");
        print("  - List invoice customer: ${currentInvoiceInList.customerName}");
        print("  - Local invoice customer: ${invoice.value?.customerName}");
      } else {
        print("  - Current invoice NOT found in list!");
      }
    }

    // Check loading states
    print("\nLoading States:");
    print("  - isLoading: ${isLoading.value}");
    print("  - isLoadingItems: ${isLoadingItems.value}");
    print("  - isSaving: ${isSaving.value}");
    print("  - isEditMode: ${isEditMode.value}");

    // Check data
    print("\nData Status:");
    print("  - Invoice: ${invoice.value != null ? 'Present' : 'NULL'}");
    print("  - Items count: ${invoiceItems.length}");
    print("  - Editable items count: ${editableItems.length}");

    print("=== END DEBUG ===");
  }
}
