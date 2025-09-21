import 'package:demo_prac_getx/constant/constant.dart';
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

import 'controller.dart';

// class InvoiceDetailsController extends GetxController {
//   final invoice = Rx<Invoice?>(null);
//   final invoiceItems = <InvoiceItem>[].obs;
//   final isLoading = false.obs;
//   final isLoadingItems = false.obs;
//   final isEditMode = false.obs;
//
//   late TextEditingController customerNameCtrl;
//   late TextEditingController customerEmailCtrl;
//   late TextEditingController customerPhoneCtrl;
//   late TextEditingController customerAddressCtrl;
//
//   // Editable items
//   var editableItems = <Map<String, TextEditingController>>[].obs;
//
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Get the invoice passed as argument
//     final arg = Get.arguments as Invoice?;
//     if (arg != null) {
//       // Prepare controllers for each item
//       editableItems.value = arg.items?.map((item) {
//         return {
//           "name": TextEditingController(text: item.itemName ?? ""),
//           "qty": TextEditingController(text: item.quantity.toString()),
//           "rate": TextEditingController(text: item.rate.toString()),
//         };
//       }).toList() ?? [];
//
//     }
//
//     final Invoice? passedInvoice = Get.arguments as Invoice?;
//     if (passedInvoice != null) {
//       invoice.value = passedInvoice;
//       loadInvoiceItems(passedInvoice.invoiceId);
//     }
//   }
//
//   Future<void> loadInvoiceItems(String invoiceId) async {
//     try {
//       isLoadingItems.value = true;
//       print("Loading items for invoice: $invoiceId");
//
//       // Fetch ONLY the items for this specific invoice
//       List<InvoiceItem> items = await GoogleSheetService.getInvoiceItemsByInvoiceId(invoiceId);
//       invoiceItems.assignAll(items);
//
//       print("✅ Successfully loaded ${items.length} items for invoice $invoiceId");
//
//       // Add debug info
//       if (items.isNotEmpty) {
//         print("Items breakdown:");
//         for (var item in items) {
//           print("Items name:-${item.itemName} :  Desc:- ${item.description}: Qty ${item.quantity} × \$${item.rate} = \$${item.totalPrice}");
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
//       isLoadingItems.value = false;
//     }
//   }
//
//   void editInvoice() {
//     if (invoice.value != null) {
//       Get.toNamed('/edit-invoice', arguments: invoice.value);
//     }
//   }
//
//   Future<void> updateInvoice() async {
//     if (invoice.value == null) return;
//
//     // Build updated items
//     final updatedItems = editableItems.map((ctrls) {
//       return InvoiceItem(
//         itemName: ctrls["name"]!.text,
//         quantity: int.tryParse(ctrls["qty"]!.text) ?? 0,
//         rate: double.tryParse(ctrls["rate"]!.text) ?? 0.0,
//       itemId: '',
//         totalPrice: 0.0,
//         description: '',
//       );
//     }).toList();
//
//     final updated = invoice.value!.copyWith(
//       items: updatedItems,
//     );
//
//     try {
//       //await Get.find<InvoiceListController>().updateInvoice(updated);
//       invoice.value = updated;
//       isEditMode.value = false;
//     } catch (e) {
//       Get.snackbar("Error", "Failed to update invoice: $e");
//     }
//   }
//
//
//
// void downloadInvoice() {
//     // Implement download functionality
//     Get.snackbar(
//       'Download',
//       'Download functionality to be implemented',
//       backgroundColor: Colors.green.shade100,
//       colorText: Colors.green.shade800,
//     );
//   }
//
//   // void deleteInvoice() async {
//   //   final confirmed = await Get.dialog(
//   //     AlertDialog(
//   //       title: Text('Delete Invoice?'),
//   //       content: Text('Are you sure you want to delete this invoice?'),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Get.back(result: false),
//   //           child: Text('Cancel'),
//   //         ),
//   //         TextButton(
//   //           onPressed: () => Get.back(result: true),
//   //           child: Text('Delete', style: TextStyle(color: Colors.red)),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   //
//   //   if (confirmed == true) {
//   //     try {
//   //       isLoading.value = true;
//   //
//   //       // Delete from remote service
//   //       if (invoice.value != null) {
//   //         await RemoteService.deleteInvoiceItems(invoice.value!.invoiceId);
//   //       }
//   //
//   //       Get.back(); // Go back to invoice list
//   //       Get.snackbar(
//   //         'Deleted',
//   //         'Invoice deleted successfully',
//   //         backgroundColor: Colors.green.shade100,
//   //         colorText: Colors.green.shade800,
//   //       );
//   //     } catch (e) {
//   //       Get.snackbar(
//   //         'Error',
//   //         'Failed to delete invoice: ${e.toString()}',
//   //         backgroundColor: Colors.red.shade100,
//   //         colorText: Colors.red.shade800,
//   //       );
//   //     } finally {
//   //       isLoading.value = false;
//   //     }
//   //   }
//   // }
//
//   /// Calculate totals from loaded items
//   double get itemsSubtotal {
//     return invoiceItems.fold(0.0, (sum, item) => sum + item.totalPrice);
//   }
//
//   void refreshInvoiceItems() {
//     if (invoice.value != null) {
//       loadInvoiceItems(invoice.value!.invoiceId);
//     }
//   }
//
//
// }


class InvoiceDetailsController extends GetxController {
  final invoice = Rxn<Invoice>();
  final invoiceItems = <InvoiceItem>[].obs;
  final isLoading = false.obs;
  final isLoadingItems = false.obs;
  final isEditMode = false.obs;

  late TextEditingController customerNameCtrl;
  late TextEditingController customerEmailCtrl;
  late TextEditingController customerPhoneCtrl;
  late TextEditingController customerAddressCtrl;
  var statusOptions = ["Pending", "Paid", "Overdue"];
  late RxString selectedStatus;

  /// Editable items: map keys are consistent: "itemName", "qty", "rate"
  var editableItems = <Map<String, TextEditingController>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // init customer controllers
    customerNameCtrl = TextEditingController();
    customerEmailCtrl = TextEditingController();
    customerPhoneCtrl = TextEditingController();
    customerAddressCtrl = TextEditingController();

    // get invoice from arguments (if any)
    final Invoice? passedInvoice = Get.arguments as Invoice?;
    if (passedInvoice != null) {
      invoice.value = passedInvoice;

      selectedStatus = (passedInvoice.status ?? "Pending").obs;
      // populate customer fields
      customerNameCtrl.text = passedInvoice.customerName ?? '';
      customerEmailCtrl.text = passedInvoice.customerEmail ?? '';
      customerPhoneCtrl.text = passedInvoice.mobile ?? '';
      customerAddressCtrl.text = passedInvoice.customerAddress ?? '';

      // load items (async)
      if ((passedInvoice.invoiceId ?? '').isNotEmpty) {
        loadInvoiceItems(passedInvoice.invoiceId!);
      } else {
        // if invoice has embedded items, prepare editable items from them
        if ((passedInvoice.items ?? []).isNotEmpty) {
          _setupEditableItemsFromLoaded(passedInvoice.items!);
          invoiceItems.assignAll(passedInvoice.items!);
        }
      }
    }
  }

  @override
  void onClose() {
    // dispose customer controllers
    customerNameCtrl.dispose();
    customerEmailCtrl.dispose();
    customerPhoneCtrl.dispose();
    customerAddressCtrl.dispose();

    // dispose item controllers
    for (var m in editableItems) {
      m['itemName']?.dispose();
      m['qty']?.dispose();
      m['rate']?.dispose();
    }

    super.onClose();
  }

  Future<void> loadInvoiceItems(String invoiceId) async {
    try {
      isLoadingItems.value = true;
      // fetch items from your service
      final List<InvoiceItem> items = await GoogleSheetService.getInvoiceItemsByInvoiceId(invoiceId);

      invoiceItems.assignAll(items);

      // prepare editable items
      _setupEditableItemsFromLoaded(items);
    } catch (e, st) {
      print('Error loading items: $e\n$st');
      Get.snackbar('Error', 'Failed to load invoice items');
    } finally {
      isLoadingItems.value = false;
    }
  }

  void _setupEditableItemsFromLoaded(List<InvoiceItem> items) {
    // dispose previous controllers first
    for (var m in editableItems) {
      m['itemName']?.dispose();
      m['qty']?.dispose();
      m['rate']?.dispose();
    }

    final newList = <Map<String, TextEditingController>>[];

    if (items.isNotEmpty) {
      for (var item in items) {
        // FIX: Better handling of item name
        String itemName = '';
        if (item.itemName?.trim().isNotEmpty == true) {
          itemName = item.itemName!.trim();
        } else if (item.description?.trim().isNotEmpty == true) {
          itemName = item.description!.trim();
        }

        newList.add({
          'itemName': TextEditingController(text: itemName),
          'qty': TextEditingController(text: (item.quantity ?? 1).toString()),
          'rate': TextEditingController(text: (item.rate ?? 0.0).toStringAsFixed(2)),
        });
      }
    } else {
      // ensure at least one empty row for editing
      newList.add({
        'itemName': TextEditingController(),
        'qty': TextEditingController(text: '1'),
        'rate': TextEditingController(text: '0.00'),
      });
    }

    editableItems.value = newList;
    editableItems.refresh();
  }

  /// Call this from UI when user taps edit icon
  void enterEditMode() {
    // ensure editableItems prepared
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
      editableItems[index]['itemName']?.dispose();
      editableItems[index]['qty']?.dispose();
      editableItems[index]['rate']?.dispose();
      editableItems.removeAt(index);

      if (editableItems.isEmpty) addNewItem();
      editableItems.refresh();
    }
  }

  double calculateItemTotal(int index) {
    if (index < 0 || index >= editableItems.length) return 0.0;
    final qtyText = editableItems[index]['qty']?.text ?? '0';
    final rateText = editableItems[index]['rate']?.text ?? '0';
    final qty = double.tryParse(qtyText) ?? 0.0;
    final rate = double.tryParse(rateText) ?? 0.0;
    return qty * rate;
  }

  double get calculatedTotal {
    double t = 0.0;
    for (int i = 0; i < editableItems.length; i++) {
      t += calculateItemTotal(i);
    }
    return t;
  }

  /// Validate and persist the edited invoice + items
  Future<void> updateInvoice() async {
    try {
      final updatedInvoice = invoice.value;
      if (updatedInvoice == null) throw Exception("No invoice selected");

      // 1️⃣ Collect updated items from editable controllers
      final updatedItems = <InvoiceItem>[];
      for (int i = 0; i < editableItems.length; i++) {
        final ctrls = editableItems[i];

        final itemName = ctrls['itemName']?.text.trim() ?? '';
        final qty = int.tryParse(ctrls['qty']?.text ?? '0') ?? 0;
        final rate = double.tryParse(ctrls['rate']?.text ?? '0') ?? 0.0;

        // Skip empty rows
        if (itemName.isEmpty && qty == 0 && rate == 0) continue;

        // ✅ Preserve old itemId if available, else generate a new one
        final existingItemId = (i < invoiceItems.length)
            ? invoiceItems[i].itemId
            : DateTime.now().millisecondsSinceEpoch.toString();

        updatedItems.add(InvoiceItem(
          itemId: existingItemId,
          //invoiceId: updatedInvoice.invoiceId,
          itemName: itemName,
          description: itemName,
          quantity: qty,
          rate: rate,
          totalPrice: qty * rate,
        ));
      }

      // 2️⃣ Recalculate totals
      final subtotal = updatedItems.fold<double>(0, (s, it) => s + (it.totalPrice ?? 0));
      final tax = updatedInvoice.taxAmount ?? 0;
      final discount = updatedInvoice.discountAmount ?? 0;
      final total = subtotal + tax - discount;

      // 3️⃣ Prepare invoice data map
      final invoiceData = {
        'invoiceId': updatedInvoice.invoiceId,
        'customerName': updatedInvoice.customerName,
        'customerEmail': updatedInvoice.customerEmail,
        'customerPhone': updatedInvoice.mobile,
        'customerAddress': updatedInvoice.customerAddress,
        'issueDate': updatedInvoice.issueDate?.toIso8601String(),
        'dueDate': updatedInvoice.dueDate?.toIso8601String(),
        'subtotal': subtotal.toStringAsFixed(2),
        'taxAmount': tax.toStringAsFixed(2),
        'discountAmount': discount.toStringAsFixed(2),
        'totalAmount': total.toStringAsFixed(2),
        'status': selectedStatus.value,
      };

      // 4️⃣ Update Invoice sheet
      await GoogleSheetService.updateInvoice(invoiceData, AppConstants.userId);

      // 5️⃣ Update InvoiceItems sheet (overwrite old + add new)
      await GoogleSheetService.updateInvoiceItems(
        updatedInvoice.invoiceId!,
        updatedItems.map((e) => e.toMap()).toList(),
        AppConstants.userId,
      );

      // ✅ Refresh local state
      invoiceItems.assignAll(updatedItems);
      isEditMode.value = false;

      Get.snackbar("Success", "Invoice updated successfully!");
      print("✅ Invoice + Items updated successfully");

    } catch (e, st) {
      print("❌ Error in updateInvoice controller: $e\n$st");
      Get.snackbar("Error", "Failed to update invoice");
    }
  }






  // Manual calculation function for view mode
  double calculateViewModeSubtotal() {
    double total = 0.0;
    for (var item in invoiceItems) {
      final qty = (item.quantity ?? 0).toDouble();
      final rate = item.rate ?? 0.0;
      total += (qty * rate);
    }
    return total;
  }

  // FIX: Use manual calculation for view mode
  double get itemsSubtotal {
    if (isEditMode.value) {
      return calculatedTotal;
    } else {
      // Use manual calculation function for view mode
      return calculateViewModeSubtotal();
    }
  }

  void refreshInvoiceItems() {
    if ((invoice.value?.invoiceId ?? '').isNotEmpty) {
      loadInvoiceItems(invoice.value!.invoiceId!);
    }
  }

  // Debug method to check what's happening with totals
  void debugTotals() {
    print('=== DEBUG TOTALS ===');
    print('isEditMode: ${isEditMode.value}');
    print('invoiceItems.length: ${invoiceItems.length}');
    print('invoice.value?.totalAmount: ${invoice.value?.totalAmount}');

    if (invoiceItems.isNotEmpty) {
      for (int i = 0; i < invoiceItems.length; i++) {
        final item = invoiceItems[i];
        print('Item $i: ${item.itemName} - qty: ${item.quantity}, rate: ${item.rate}, totalPrice: ${item.totalPrice}');
      }
    }

    print('Calculated itemsSubtotal: ${itemsSubtotal}');
    print('==================');
  }
}

///
// class InvoiceDetailsController extends GetxController {
//   final invoice = Rxn<Invoice>();
//   final invoiceItems = <InvoiceItem>[].obs;
//   final isLoading = false.obs;
//   final isLoadingItems = false.obs;
//   final isEditMode = false.obs;
//
//   late TextEditingController customerNameCtrl;
//   late TextEditingController customerEmailCtrl;
//   late TextEditingController customerPhoneCtrl;
//   late TextEditingController customerAddressCtrl;
//
//   /// Editable items: map keys are consistent: "itemName", "qty", "rate"
//   var editableItems = <Map<String, TextEditingController>>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // init customer controllers
//     customerNameCtrl = TextEditingController();
//     customerEmailCtrl = TextEditingController();
//     customerPhoneCtrl = TextEditingController();
//     customerAddressCtrl = TextEditingController();
//
//     // get invoice from arguments (if any)
//     final Invoice? passedInvoice = Get.arguments as Invoice?;
//     if (passedInvoice != null) {
//       invoice.value = passedInvoice;
//
//       // populate customer fields
//       customerNameCtrl.text = passedInvoice.customerName ?? '';
//       customerEmailCtrl.text = passedInvoice.customerEmail ?? '';
//       customerPhoneCtrl.text = passedInvoice.mobile ?? '';
//       customerAddressCtrl.text = passedInvoice.customerAddress ?? '';
//
//       // load items (async)
//       if ((passedInvoice.invoiceId ?? '').isNotEmpty) {
//         loadInvoiceItems(passedInvoice.invoiceId!);
//       } else {
//         // if invoice has embedded items, prepare editable items from them
//         if ((passedInvoice.items ?? []).isNotEmpty) {
//           _setupEditableItemsFromLoaded(passedInvoice.items!);
//           invoiceItems.assignAll(passedInvoice.items!);
//         }
//       }
//     }
//   }
//
//   @override
//   void onClose() {
//     // dispose customer controllers
//     customerNameCtrl.dispose();
//     customerEmailCtrl.dispose();
//     customerPhoneCtrl.dispose();
//     customerAddressCtrl.dispose();
//
//     // dispose item controllers
//     for (var m in editableItems) {
//       m['itemName']?.dispose();
//       m['qty']?.dispose();
//       m['rate']?.dispose();
//     }
//
//     super.onClose();
//   }
//
//   Future<void> loadInvoiceItems(String invoiceId) async {
//     try {
//       isLoadingItems.value = true;
//       // fetch items from your service
//       final List<InvoiceItem> items = await GoogleSheetService.getInvoiceItemsByInvoiceId(invoiceId);
//
//       invoiceItems.assignAll(items);
//
//       // prepare editable items
//       _setupEditableItemsFromLoaded(items);
//     } catch (e, st) {
//       print('Error loading items: $e\n$st');
//       Get.snackbar('Error', 'Failed to load invoice items');
//     } finally {
//       isLoadingItems.value = false;
//     }
//   }
//
//   void _setupEditableItemsFromLoaded(List<InvoiceItem> items) {
//     // dispose previous controllers first
//     for (var m in editableItems) {
//       m['itemName']?.dispose();
//       m['qty']?.dispose();
//       m['rate']?.dispose();
//     }
//
//     final newList = <Map<String, TextEditingController>>[];
//
//     if (items.isNotEmpty) {
//       for (var item in items) {
//         // FIX: Better handling of item name
//         String itemName = '';
//         if (item.itemName?.trim().isNotEmpty == true) {
//           itemName = item.itemName!.trim();
//         } else if (item.description?.trim().isNotEmpty == true) {
//           itemName = item.description!.trim();
//         }
//
//         newList.add({
//           'itemName': TextEditingController(text: itemName),
//           'qty': TextEditingController(text: (item.quantity ?? 1).toString()),
//           'rate': TextEditingController(text: (item.rate ?? 0.0).toStringAsFixed(2)),
//         });
//       }
//     } else {
//       // ensure at least one empty row for editing
//       newList.add({
//         'itemName': TextEditingController(),
//         'qty': TextEditingController(text: '1'),
//         'rate': TextEditingController(text: '0.00'),
//       });
//     }
//
//     editableItems.value = newList;
//     editableItems.refresh();
//   }
//
//   /// Call this from UI when user taps edit icon
//   void enterEditMode() {
//     // ensure editableItems prepared
//     if (editableItems.isEmpty) {
//       if (invoiceItems.isNotEmpty) {
//         _setupEditableItemsFromLoaded(invoiceItems);
//       } else if ((invoice.value?.items ?? []).isNotEmpty) {
//         _setupEditableItemsFromLoaded(invoice.value!.items!);
//       } else {
//         addNewItem();
//       }
//     }
//
//     isEditMode.value = true;
//   }
//
//   void addNewItem() {
//     editableItems.add({
//       'itemName': TextEditingController(),
//       'qty': TextEditingController(text: '1'),
//       'rate': TextEditingController(text: '0.00'),
//     });
//     editableItems.refresh();
//   }
//
//   void removeItem(int index) {
//     if (index >= 0 && index < editableItems.length) {
//       editableItems[index]['itemName']?.dispose();
//       editableItems[index]['qty']?.dispose();
//       editableItems[index]['rate']?.dispose();
//       editableItems.removeAt(index);
//
//       if (editableItems.isEmpty) addNewItem();
//       editableItems.refresh();
//     }
//   }
//
//   double calculateItemTotal(int index) {
//     if (index < 0 || index >= editableItems.length) return 0.0;
//     final qtyText = editableItems[index]['qty']?.text ?? '0';
//     final rateText = editableItems[index]['rate']?.text ?? '0';
//     final qty = double.tryParse(qtyText) ?? 0.0;
//     final rate = double.tryParse(rateText) ?? 0.0;
//     return qty * rate;
//   }
//
//   double get calculatedTotal {
//     double t = 0.0;
//     for (int i = 0; i < editableItems.length; i++) {
//       t += calculateItemTotal(i);
//     }
//     return t;
//   }
//
//   /// Validate and persist the edited invoice + items
//   Future<void> updateInvoice() async {
//     if (invoice.value == null) return;
//
//     // basic validation
//     if (customerNameCtrl.text.trim().isEmpty) {
//       Get.snackbar('Error', 'Customer name is required');
//       return;
//     }
//
//     // Build updated items
//     final updatedItems = <InvoiceItem>[];
//
//     for (int i = 0; i < editableItems.length; i++) {
//       final m = editableItems[i];
//       final name = m['itemName']?.text.trim() ?? '';
//       final qtyText = m['qty']?.text.trim() ?? '';
//       final rateText = m['rate']?.text.trim() ?? '';
//
//       // skip completely empty rows
//       if (name.isEmpty && qtyText.isEmpty && rateText.isEmpty) continue;
//
//       if (name.isEmpty) {
//         Get.snackbar('Error', 'Please enter item name for row ${i + 1}');
//         return;
//       }
//
//       final qty = int.tryParse(qtyText) ?? (double.tryParse(qtyText)?.toInt() ?? null);
//       final rate = double.tryParse(rateText);
//
//       if (qty == null || qty <= 0) {
//         Get.snackbar('Error', 'Please enter valid quantity for row ${i + 1}');
//         return;
//       }
//       if (rate == null || rate < 0) {
//         Get.snackbar('Error', 'Please enter valid rate for row ${i + 1}');
//         return;
//       }
//
//       // preserve existing itemId when possible
//       final existingItemId = (i < invoiceItems.length) ? (invoiceItems[i].itemId ?? '') : '';
//
//       final totalPrice = qty * rate;
//
//       updatedItems.add(InvoiceItem(
//         itemId: existingItemId,
//         itemName: name,
//         description: name,
//         quantity: qty,
//         rate: rate,
//         totalPrice: totalPrice,
//       ));
//     }
//
//     if (updatedItems.isEmpty) {
//       Get.snackbar('Error', 'Please add at least one item');
//       return;
//     }
//
//     final newTotal = updatedItems.fold<double>(0.0, (s, it) => s + (it.totalPrice ?? 0.0));
//
//     final updatedInvoice = invoice.value!.copyWith(
//       customerName: customerNameCtrl.text.trim(),
//       customerEmail: customerEmailCtrl.text.trim(),
//       mobile: customerPhoneCtrl.text.trim(),
//       customerAddress: customerAddressCtrl.text.trim(),
//       items: updatedItems,
//       totalAmount: newTotal,
//     );
//
//     try {
//       isLoading.value = true;
//
//       // Persist to your backends
//       // await GoogleSheetService.updateInvoice(updatedInvoice);
//       // Optionally notify InvoiceListController if present:
//       try {
//         final listController = Get.find<dynamic>(tag: 'invoice_list');
//         if (listController != null) {
//           // If you have a proper typed controller, call its updateInvoice method
//           // listController.updateInvoice(updatedInvoice);
//         }
//       } catch (_) {}
//
//       // update local state
//       invoice.value = updatedInvoice;
//       invoiceItems.assignAll(updatedItems);
//
//       isEditMode.value = false;
//
//       Get.snackbar('Success', 'Invoice updated');
//     } catch (e, st) {
//       print('Error updating invoice: $e\n$st');
//       Get.snackbar('Error', 'Failed to update invoice');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // FIX: Getter for items subtotal that works in both modes
//   double get itemsSubtotal {
//     if (isEditMode.value) {
//       return calculatedTotal;
//     } else {
//       return invoiceItems.fold(0.0, (s, it) => s + (it.totalPrice ?? 0.0));
//     }
//   }
//
//   void refreshInvoiceItems() {
//     if ((invoice.value?.invoiceId ?? '').isNotEmpty) {
//       loadInvoiceItems(invoice.value!.invoiceId!);
//     }
//   }
// }


