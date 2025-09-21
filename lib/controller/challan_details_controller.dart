import 'package:demo_prac_getx/controller/bash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../model/model.dart';
import '../services/service.dart';

class ChallanDetailsController extends GetxController {
  final challan = Rxn<Challan>();
  final challanItems = <ChallanItem>[].obs;
  final isLoading = false.obs;
  final isLoadingItems = false.obs;
  final isEditMode = false.obs;

  late TextEditingController customerNameCtrl;
  late TextEditingController customerEmailCtrl;
  late TextEditingController customerPhoneCtrl;
  late TextEditingController customerAddressCtrl;

  /// Editable items: keys: "itemName", "qty", "rate"
  var editableItems = <Map<String, TextEditingController>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // init customer controllers
    customerNameCtrl = TextEditingController();
    customerEmailCtrl = TextEditingController();
    customerPhoneCtrl = TextEditingController();
    customerAddressCtrl = TextEditingController();
    if (Get.arguments != null && Get.arguments is Challan) {
      challan.value = Get.arguments as Challan;
    }

    // get challan from arguments (if any)
    final Challan? passedChallan = Get.arguments as Challan?;
    if (passedChallan != null) {
      challan.value = passedChallan;

      // populate customer fields
      customerNameCtrl.text = passedChallan.customerName ?? '';
      customerEmailCtrl.text = passedChallan.customerEmail ?? '';
      customerPhoneCtrl.text = passedChallan.customerMobile ?? '';
      customerAddressCtrl.text = passedChallan.customerAddress ?? '';

      // load challan items (async)
      if ((passedChallan.challanId ?? '').isNotEmpty) {
        loadChallanItems(passedChallan.challanId!);
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

  Future<void> loadChallanItems(String challanId) async {
    try {
      isLoadingItems.value = true;
      final List<ChallanItem> items =
      await GoogleSheetService.getChallanItemsByChallanId(challanId);

      challanItems.assignAll(items);

      _setupEditableItemsFromLoaded(items);
    } catch (e, st) {
      print('❌ Error loading challan items: $e\n$st');
      Get.snackbar('Error', 'Failed to load challan items');
    } finally {
      isLoadingItems.value = false;
    }
  }

  void _setupEditableItemsFromLoaded(List<ChallanItem> items) {
    // dispose previous
    for (var m in editableItems) {
      m['itemName']?.dispose();
      m['qty']?.dispose();
      m['rate']?.dispose();
    }

    final newList = <Map<String, TextEditingController>>[];

    if (items.isNotEmpty) {
      for (var item in items) {
        newList.add({
          'itemName': TextEditingController(text: item.itemName ?? ''),
          'qty': TextEditingController(text: (item.quantity ?? 1).toString()),
          'rate': TextEditingController(
              text: (item.price ?? 0.0).toStringAsFixed(2)),
        });
      }
    } else {
      newList.add({
        'itemName': TextEditingController(),
        'qty': TextEditingController(text: '1'),
        'rate': TextEditingController(text: '0.00'),
      });
    }

    editableItems.value = newList;
    editableItems.refresh();
  }

  void enterEditMode() {
    if (editableItems.isEmpty) {
      if (challanItems.isNotEmpty) {
        _setupEditableItemsFromLoaded(challanItems);
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

  // Future<void> updateChallan() async {
  //   try {
  //     final updatedChallan = challan.value;
  //     if (updatedChallan == null) throw Exception("No challan selected");
  //
  //     // Collect items
  //     final updatedItems = <ChallanItem>[];
  //     for (int i = 0; i < editableItems.length; i++) {
  //       final ctrls = editableItems[i];
  //
  //       final itemName = ctrls['itemName']?.text.trim() ?? '';
  //       final qty = int.tryParse(ctrls['qty']?.text ?? '0') ?? 0;
  //       final rate = double.tryParse(ctrls['rate']?.text ?? '0') ?? 0.0;
  //
  //       if (itemName.isEmpty && qty == 0 && rate == 0) continue;
  //
  //       final existingItemId = (i < challanItems.length)
  //           ? challanItems[i].itemId
  //           : DateTime.now().millisecondsSinceEpoch.toString();
  //
  //       updatedItems.add(ChallanItem(
  //         itemId: existingItemId,
  //         challanId: updatedChallan.challanId,
  //         itemName: itemName,
  //         quantity: qty,
  //         price: rate,
  //         totalPrice: qty * rate,
  //         description: itemName,
  //         customerId: '',
  //       ));
  //     }
  //
  //     // Calculate totals
  //     final subtotal =
  //     updatedItems.fold<double>(0, (s, it) => s + (it.totalPrice ?? 0));
  //     final tax = updatedChallan.taxAmount ?? 0;
  //     final total = subtotal + tax;
  //
  //     final challanData = {
  //       'challanId': updatedChallan.challanId,
  //       'customerName': updatedChallan.customerName,
  //       'customerEmail': updatedChallan.customerEmail,
  //       'customerPhone': updatedChallan.customerMobile,
  //       'customerAddress': updatedChallan.customerAddress,
  //       'challanDate': updatedChallan.challanDate,
  //       'subtotal': subtotal.toStringAsFixed(2),
  //       'taxAmount': tax.toStringAsFixed(2),
  //       'totalAmount': total.toStringAsFixed(2),
  //       'status': updatedChallan.paymentStatus ?? 'Pending',
  //     };
  //
  //     // Update challan in Google Sheets
  //     await GoogleSheetService.updateChallan(challanData, AppConstants.userId);
  //
  //     // Update challan items in sheet
  //     await GoogleSheetService.updateChallanItems(
  //       updatedChallan.challanId!,
  //       updatedItems.map((e) => e.toMap()).toList(),
  //       AppConstants.userId,
  //     );
  //
  //     challanItems.assignAll(updatedItems);
  //     isEditMode.value = false;
  //
  //     Get.snackbar("Success", "Challan updated successfully!");
  //   } catch (e, st) {
  //     print("❌ Error in updateChallan: $e\n$st");
  //     Get.snackbar("Error", "Failed to update challan");
  //   }
  // }
}
