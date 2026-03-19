import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/item_model.dart';
import '../screen/order/order_success_screen.dart';
import '../widgets/custom_snackbar.dart';

// class OrderController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseFunctions _functions = FirebaseFunctions.instance;
//
//   var isLoading = true.obs;
//   var isPlacingOrder = false.obs;
//  
//   var cid = ''.obs;
//   var uid = ''.obs;
//   var customerName = ''.obs;
//  
//   var itemList = <Item>[].obs;
//   // Map of itemId to quantity
//   var cart = <String, int>{}.obs;
//  
//   double get totalAmount {
//     double total = 0.0;
//     cart.forEach((itemId, qty) {
//       final item = itemList.firstWhereOrNull((i) => i.itemId == itemId);
//       if (item != null) {
//         total += item.price * qty;
//       }
//     });
//     return total;
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//    
//     // Extract parameters from URL
//     final parameters = Get.parameters;
//     cid.value = parameters['cid'] ?? '';
//     uid.value = parameters['uid'] ?? '';
//    
//     if (cid.value.isNotEmpty && uid.value.isNotEmpty) {
//       _loadData();
//     } else {
//       isLoading.value = false;
//       showCustomSnackbar(
//         title: "Error",
//         message: "Invalid order link",
//         baseColor: Colors.red,
//         icon: Icons.error,
//       );
//     }
//   }
//
//   Future<void> _loadData() async {
//     try {
//       isLoading.value = true;
//      
//       // Load customer name + items via Cloud Function (no public Firestore reads; service account kept server-side)
//       try {
//         final callable = _functions.httpsCallable('publicGetOrderContext');
//         final res = await callable.call({'cid': cid.value, 'uid': uid.value});
//         final data = (res.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
//         final fetchedName = (data['customerName'] ?? '').toString().trim();
//         customerName.value = fetchedName.isEmpty ? 'Valued Customer' : fetchedName;
//         final rawItems = (data['items'] as List?) ?? const [];
//
//         Map<String, dynamic> normalizeKeys(Map input) {
//           final out = <String, dynamic>{};
//           input.forEach((k, v) {
//             final key = k.toString().trim().toLowerCase();
//             if (key.isEmpty) return;
//             out[key] = v;
//           });
//           return out;
//         }
//
//         final List<Item> items = rawItems
//             .whereType<Map>()
//             .map((m) {
//               final n = normalizeKeys(m);
//               // Map sheet headers (case-insensitive) to Item.fromMap expected keys
//               return Item.fromMap({
//                 'itemId': n['itemid'] ?? n['itemId'] ?? n['id'] ?? '',
//                 'itemName': n['itemname'] ?? n['name'] ?? '',
//                 'price': n['price'] ?? '0',
//                 'sellPrice': n['sellprice'] ?? '0',
//                 'gst': n['gstpercent'] ?? n['gst'] ?? '0',
//                 'unitOfMeasurement': n['unitofmeasurement'] ?? 'pcs',
//                 'currentStock': n['currentstock'] ?? '0',
//                 'detailRequirement': n['detailrequirement'] ?? '',
//                 'isActive': n['isactive'] ?? true,
//                 'userId': n['userid'] ?? n['userId'] ?? '',
//               });
//             })
//             .toList();
//         // Only show active items
//         itemList.value = items.where((item) => item.isActive == true).toList();
//       } catch (e) {
//         print("Error fetching order context: $e");
//         itemList.value = [];
//         customerName.value = 'Valued Customer';
//       }
//      
//       // Load cart from LocalStorage
//       await _loadCartFromStorage();
//      
//     } catch (e) {
//       print("Error loading data: $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to load catalog",
//         baseColor: Colors.red,
//         icon: Icons.error,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> _loadCartFromStorage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartData = prefs.getString('cart_${cid.value}_${uid.value}');
//     if (cartData != null) {
//       try {
//         final Map<String, dynamic> decoded = jsonDecode(cartData);
//         cart.value = decoded.map((key, value) => MapEntry(key, value as int));
//       } catch (e) {
//         print("Error decoding cart: $e");
//       }
//     }
//   }
//
//   Future<void> _saveCartToStorage() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('cart_${cid.value}_${uid.value}', jsonEncode(cart));
//   }
//
//   void incrementQuantity(String itemId) {
//     cart[itemId] = (cart[itemId] ?? 0) + 1;
//     _saveCartToStorage();
//   }
//
//   void decrementQuantity(String itemId) {
//     if (cart.containsKey(itemId) && cart[itemId]! > 0) {
//       cart[itemId] = cart[itemId]! - 1;
//       if (cart[itemId] == 0) {
//         cart.remove(itemId);
//       }
//       _saveCartToStorage();
//     }
//   }
//
//   int getQuantity(String itemId) {
//     return cart[itemId] ?? 0;
//   }
//
//   Future<void> placeOrder() async {
//     if (cart.isEmpty) {
//       showCustomSnackbar(
//         title: "Empty Cart",
//         message: "Please add some items to place an order",
//         baseColor: Colors.orange,
//         icon: Icons.warning,
//       );
//       return;
//     }
//
//     try {
//       isPlacingOrder.value = true;
//      
//       final orderItems = cart.entries.map((entry) {
//         final item = itemList.firstWhereOrNull((i) => i.itemId == entry.key);
//         return {
//           'itemId': entry.key,
//           'itemName': item?.itemName ?? 'Unknown Item',
//           'price': item?.price ?? 0.0,
//           'quantity': entry.value,
//           'totalPrice': (item?.price ?? 0.0) * entry.value,
//         };
//       }).toList();
//
//       final orderData = {
//         'companyId': cid.value,
//         'customerId': uid.value,
//         'customerName': customerName.value,
//         'items': orderItems,
//         'totalAmount': totalAmount,
//         'status': 'pending',
//         'timestamp': FieldValue.serverTimestamp(),
//       };
//
//       await _firestore.collection('public_orders').add(orderData);
//      
//       // Clear cart
//       cart.clear();
//       await _saveCartToStorage();
//      
//       // Navigate to Thank You screen
//       Get.offNamed('/order-success');
//      
//     } catch (e) {
//       print("Error placing order: $e");
//       showCustomSnackbar(
//         title: "Error",
//         message: "Failed to place order. Please try again.",
//         baseColor: Colors.red,
//         icon: Icons.error,
//       );
//     } finally {
//       isPlacingOrder.value = false;
//     }
//   }
// }

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;


import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

// Import your existing Item model
// import '../model/item_model.dart'; // ← uncomment with correct path

// ─────────────────────────────────────────────
// OrderRow Model
// ─────────────────────────────────────────────
class OrderRow {
  Item? selectedItem;
  double qty;
  OrderRow({this.selectedItem, this.qty = 0});
}

// ─────────────────────────────────────────────
// OrderController
// ─────────────────────────────────────────────
class OrderController extends GetxController {
  var companyId  = ''.obs;
  var customerId = ''.obs;

  var isLoading      = true.obs;
  var isPlacingOrder = false.obs;
  var customerName   = ''.obs;
  var companyName    = ''.obs;
  var customerMobile  = ''.obs;
  var customerAddress = ''.obs;
  var customerEmail   = ''.obs;
  var itemList       = <Item>[].obs;
  var showPriceToCustomer = true.obs;
  var orderRows    = <OrderRow>[].obs;

  // Old cart (kept for compatibility)
  var cart = <String, int>{}.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _serviceAccountAssetPath =
      'assets/getyourinvoice-8f128-3dfb21843bde.json';

  @override
  void onInit() {
    super.onInit();
    companyId.value  = (Get.parameters['cid'] ?? '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    customerId.value = (Get.parameters['uid'] ?? '')
        .replaceAll(RegExp(r'[^0-9]'), '');

    if (companyId.value.isEmpty || customerId.value.isEmpty) {
      Get.snackbar('Invalid Link', 'Order link is missing required parameters.',
          duration: const Duration(seconds: 5));
      isLoading.value = false;
      return;
    }
    _initPage();
  }

  Future<void> _initPage() async {
    try {
      isLoading.value = true;

      final jsonStr = await rootBundle.loadString(_serviceAccountAssetPath);
      final credentialsJson = json.decode(jsonStr) as Map<String, dynamic>;

      String spreadsheetId = '';
      try {
        spreadsheetId = await _fetchSpreadsheetId();
        print('✅ spreadsheetId: $spreadsheetId');
      } catch (e) {
        print('❌ spreadsheetId fetch failed: $e');
        Get.snackbar('Connection Error',
            'Could not connect. Check internet and try again.',
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red.shade100);
        isLoading.value = false;
        return;
      }

      // Fetch customer FIRST (sequential) so mobile/address available
      await _fetchCustomerNameFromSheet(spreadsheetId, credentialsJson);

      // Then load rest in parallel
      await Future.wait([
        _fetchItemsFromSheet(spreadsheetId, credentialsJson),
        _fetchPriceSetting(),
        _fetchCompanyName(),
      ]);

      // Default 1 empty row
      orderRows.value = [OrderRow()];

    } catch (e) {
      print('❌ initPage error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // spreadsheetId — FY based or direct
  // ─────────────────────────────────────────────
  Future<String> _fetchSpreadsheetId() async {
    Exception? lastError;
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print('📊 Firestore fetch attempt $attempt...');
        final doc = await _firestore
            .collection('users')
            .doc(companyId.value)
            .get()
            .timeout(Duration(seconds: attempt * 5));

        final data = doc.data();
        if (data == null) throw Exception('User doc not found');

        final now    = DateTime.now();
        final fyYear = now.month >= 4 ? now.year : now.year - 1;
        final currentFy = '$fyYear-${(fyYear + 1).toString().substring(2)}';

        final byFy = data['spreadsheetIdsByFy'] as Map<String, dynamic>?;
        if (byFy != null && byFy.containsKey(currentFy)) {
          final id = byFy[currentFy].toString();
          print('📊 spreadsheetId from FY $currentFy: $id');
          return id;
        }

        final direct = data['spreadsheetId']?.toString() ?? '';
        if (direct.isNotEmpty) {
          print('📊 spreadsheetId direct: $direct');
          return direct;
        }

        throw Exception('spreadsheetId not found');
      } catch (e) {
        lastError = Exception(e.toString());
        print('⚠️ Attempt $attempt failed: $e');
        if (attempt < 3) await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    throw lastError ?? Exception('Could not fetch spreadsheetId');
  }

  // ─────────────────────────────────────────────
  // Price setting
  // ─────────────────────────────────────────────
  Future<void> _fetchPriceSetting() async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(companyId.value)
          .collection('companies')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        showPriceToCustomer.value =
            snap.docs.first.data()['showPriceToCustomer'] as bool? ?? true;
        print('💰 showPriceToCustomer: ${showPriceToCustomer.value}');
      }
    } catch (e) {
      print('❌ fetchPriceSetting: $e');
      showPriceToCustomer.value = true;
    }
  }

  // ─────────────────────────────────────────────
  // Company name
  // ─────────────────────────────────────────────
  Future<void> _fetchCompanyName() async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(companyId.value)
          .collection('companies')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 8));
      if (snap.docs.isNotEmpty) {
        companyName.value =
            snap.docs.first.data()['companyName']?.toString() ?? '';
        print('🏢 companyName: ${companyName.value}');
      }
    } catch (e) {
      print('❌ fetchCompanyName: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Customer name from Sheet
  // ─────────────────────────────────────────────
  Future<void> _fetchCustomerNameFromSheet(
      String spreadsheetId,
      Map<String, dynamic> credentialsJson,
      ) async {
    try {
      final authClient = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentialsJson),
        [sheets.SheetsApi.spreadsheetsReadonlyScope],
      );
      try {
        final sheetsApi = sheets.SheetsApi(authClient);

        // ── Header row ──
        final headerResp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, 'Customer!A1:Z1',
        );
        final headers = (headerResp.values?.isNotEmpty == true)
            ? headerResp.values!.first
            .map((h) => h.toString().trim().toLowerCase())
            .toList()
            : <dynamic>[];
        print('📋 Customer headers: $headers');

        int hIdx(String n) {
          final i = headers.indexOf(n);
          return i;
        }

        final idIdx      = hIdx('customerid');
        final nameIdx    = hIdx('name');
        final mobileIdx  = hIdx('mobile1');
        final addressIdx = hIdx('address');
        final emailIdx   = hIdx('email');

        print('📊 id:$idIdx name:$nameIdx mobile:$mobileIdx address:$addressIdx email:$emailIdx');

        // ── Data rows ──
        final response = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, 'Customer!A2:Z',
        );
        final rows = response.values ?? [];
        print('🔍 customerId: "${customerId.value}" | rows: ${rows.length}');

        String safeCell(List row, int idx) =>
            (idx >= 0 && idx < row.length) ? row[idx].toString().trim() : '';

        for (final row in rows) {
          final id = safeCell(row, idIdx >= 0 ? idIdx : 0);
          if (id == customerId.value.trim()) {
            customerName.value    = safeCell(row, nameIdx    >= 0 ? nameIdx    : 3);
            customerMobile.value  = safeCell(row, mobileIdx  >= 0 ? mobileIdx  : 13);
            customerAddress.value = safeCell(row, addressIdx >= 0 ? addressIdx : 4);
            customerEmail.value   = safeCell(row, emailIdx   >= 0 ? emailIdx   : 15);
            print('✅ Customer: ${customerName.value}');
            print('📱 Mobile: ${customerMobile.value}');
            print('🏠 Address: ${customerAddress.value}');
            return;
          }
        }
        print('❌ No match for: "${customerId.value}"');
        customerName.value = 'Customer';
      } finally {
        authClient.close();
      }
    } catch (e) {
      print('❌ fetchCustomerName error: $e');
      customerName.value = 'Customer';
    }
  }

  // ─────────────────────────────────────────────
  // Items from Sheet — header-based column mapping
  // ─────────────────────────────────────────────
  Future<void> _fetchItemsFromSheet(
      String spreadsheetId,
      Map<String, dynamic> credentialsJson,
      ) async {
    try {
      final authClient = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentialsJson),
        [sheets.SheetsApi.spreadsheetsReadonlyScope],
      );
      try {
        final sheetsApi = sheets.SheetsApi(authClient);

        // ── Step 1: Fetch header row ──
        final headerResp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, 'Item!A1:Z1',
        );
        final headers = (headerResp.values?.isNotEmpty == true)
            ? headerResp.values!.first
            .map((h) => h.toString().trim().toLowerCase())
            .toList()
            : <dynamic>[];

        print('📋 Item headers: $headers');

        // ── Step 2: Find column indexes by header name ──
        int _idx(String name) => headers.indexOf(name);

        final itemIdIdx    = _idx('itemid');
        final itemNameIdx  = _idx('itemname');
        final priceIdx     = _idx('price');
        final sellPriceIdx = _idx('sellprice');
        final gstIdx       = _idx('gstpercent');
        final unitIdx      = _idx('unitofmeasurement');

        print('📊 itemId:$itemIdIdx itemName:$itemNameIdx '
            'price:$priceIdx sellPrice:$sellPriceIdx '
            'unit:$unitIdx gst:$gstIdx');

        // ── Step 3: Fetch data rows ──
        final dataResp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, 'Item!A2:Z',
        );
        final rows = dataResp.values ?? [];
        print('✅ Fetched ${rows.length} items');

        // ── Step 4: Map rows → Item ──
        itemList.value = rows
            .where((row) {
          if (row.isEmpty || row[0].toString().isEmpty) return false;
          // isActive check — default true if field missing
          final isActiveIdx = headers.indexOf('isactive');
          if (isActiveIdx >= 0 && isActiveIdx < row.length) {
            final val = row[isActiveIdx].toString().toLowerCase().trim();
            if (val == 'false' || val == '0' || val == 'no') return false;
          }
          return true;
        })
            .map((row) {
          // Helper: safe cell read
          String cell(int idx) =>
              (idx >= 0 && idx < row.length)
                  ? row[idx].toString().trim()
                  : '';

          // sellPrice first, fallback to price
          final sellStr  = cell(sellPriceIdx);
          final priceStr = cell(priceIdx >= 0 ? priceIdx : 2);
          final finalPrice = double.tryParse(
              sellStr.isNotEmpty ? sellStr : priceStr) ??
              0.0;

          return Item(
            itemId:            cell(itemIdIdx   >= 0 ? itemIdIdx   : 0),
            itemName:          cell(itemNameIdx >= 0 ? itemNameIdx : 1),
            price:             double.tryParse(priceStr) ?? 0.0,
            sellPrice:         finalPrice,
            gstPercent:        double.tryParse(cell(gstIdx  >= 0 ? gstIdx  : 3)) ?? 0.0,
            unitOfMeasurement: cell(unitIdx >= 0 ? unitIdx : 4),
          );
        })
            .toList();

      } finally {
        authClient.close();
      }
    } catch (e) {
      print('❌ fetchItems error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // Save Order to Google Sheets "Orders" tab
  // ─────────────────────────────────────────────
  Future<void> _saveOrderToSheet(
      String orderId,
      List<Map<String, dynamic>> orderItems, {
        double total = 0,
      }) async {
    try {
      final jsonStr      = await rootBundle.loadString(_serviceAccountAssetPath);
      final credentials  = json.decode(jsonStr) as Map<String, dynamic>;
      final spreadsheetId = await _fetchSpreadsheetId();

      final authClient = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentials),
        [sheets.SheetsApi.spreadsheetsScope],
      );
      try {
        final sheetsApi = sheets.SheetsApi(authClient);
        final now = DateTime.now();
        final ts  = '${now.day.toString().padLeft(2,'0')}/'
            '${now.month.toString().padLeft(2,'0')}/${now.year} '
            '${now.hour.toString().padLeft(2,'0')}:'
            '${now.minute.toString().padLeft(2,'0')}:'
            '${now.second.toString().padLeft(2,'0')}';

        // Use List<List<dynamic>> for Web compatibility
        final List<List<dynamic>> rows = orderItems.map<List<dynamic>>((item) => [
          orderId,
          companyId.value,
          customerId.value,
          customerName.value,
          item['itemId']   ?? '',
          item['itemName'] ?? '',
          item['quantity'] ?? 0,
          item['price']    ?? 0,
          item['subtotal'] ?? 0,
          total,
          'pending',
          ts,
        ]).toList();

        // ── Ensure Orders sheet exists ──
        await _ensureOrdersSheetExists(sheetsApi, spreadsheetId);

        // Web-compatible ValueRange
        final valueRange = sheets.ValueRange();
        valueRange.values = rows.map<List<Object?>>((r) =>
            r.map<Object?>((e) => e?.toString() ?? '').toList()
        ).toList();

        await sheetsApi.spreadsheets.values.append(
          valueRange,
          spreadsheetId,
          'Orders!A:L',
          valueInputOption: 'USER_ENTERED',
          insertDataOption: 'INSERT_ROWS',
        );
        print('✅ Order saved to Sheets: ' + rows.length.toString() + ' rows');
      } finally {
        authClient.close();
      }
    } catch (e) {
      print('⚠️ Sheet save failed (order still placed): $e');
    }
  }

  // ─────────────────────────────────────────────
  // Order Row Management
  // ─────────────────────────────────────────────
  void addNewRow() {
    orderRows.add(OrderRow());
    orderRows.refresh();
  }

  void removeRow(int index) {
    if (orderRows.length > 1) {
      orderRows.removeAt(index);
      orderRows.refresh();
    }
  }

  void selectItem(int index, Item item) {
    orderRows[index].selectedItem = item;
    orderRows[index].qty = 0;
    orderRows.refresh();
  }

  void setQty(int index, double qty) {
    orderRows[index].qty = qty;
    orderRows.refresh();
  }

  double get orderTotalAmount {
    double total = 0;
    for (final row in orderRows) {
      if (row.selectedItem != null && row.qty > 0) {
        total += row.selectedItem!.sellPrice * row.qty;
      }
    }
    return total;
  }

  // ─────────────────────────────────────────────
  // Place Order
  // ─────────────────────────────────────────────
  Future<void> placeOrderNew() async {
    final validRows = orderRows
        .where((r) => r.selectedItem != null && r.qty > 0)
        .toList();

    if (validRows.isEmpty) {
      Get.snackbar('Empty Order',
          'Please select at least one item with quantity.');
      return;
    }

    try {
      isPlacingOrder.value = true;

      final orderItems = validRows.map((r) => {
        'itemId':   r.selectedItem!.itemId,
        'itemName': r.selectedItem!.itemName,
        'price':    r.selectedItem!.sellPrice,
        'quantity': r.qty,
        'subtotal': r.selectedItem!.sellPrice * r.qty,
      }).toList();

      final total = validRows.fold<double>(
          0, (s, r) => s + r.selectedItem!.sellPrice * r.qty);

      final docRef = await _firestore.collection('public_orders').add({
        'companyId':       companyId.value,
        'customerId':      customerId.value,
        'customerName':    customerName.value,
        'customerMobile':  customerMobile.value,
        'customerAddress': customerAddress.value,
        'customerEmail':   customerEmail.value,
        'items':           orderItems,
        'totalAmount':     total,
        'status':          'pending',
        'timestamp':       FieldValue.serverTimestamp(),
      });

      await _saveOrderToSheet(docRef.id, orderItems, total: total);

      orderRows.value = [OrderRow()];
      // Pass cid/uid to success screen so "Order More" works
      Get.offNamed(
        OrderSuccessScreen.pageId,
        parameters: {
          'cid': companyId.value,
          'uid': customerId.value,
        },
      );

    } catch (e) {
      print('❌ placeOrderNew error: $e');
      Get.snackbar('Error', 'Failed to place order. Try again.',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: Colors.white);
    } finally {
      isPlacingOrder.value = false;
    }
  }

  // Old cart helpers (kept for compatibility)
  int getQuantity(String itemId) => cart[itemId] ?? 0;
  void incrementQuantity(String itemId) {
    cart[itemId] = (cart[itemId] ?? 0) + 1;
    cart.refresh();
  }
  void decrementQuantity(String itemId) {
    if ((cart[itemId] ?? 0) > 0) {
      cart[itemId] = cart[itemId]! - 1;
      if (cart[itemId] == 0) cart.remove(itemId);
      cart.refresh();
    }
  }
  double get totalAmount {
    double total = 0;
    for (final entry in cart.entries) {
      final item = itemList.firstWhereOrNull((i) => i.itemId == entry.key);
      if (item != null) total += item.sellPrice * entry.value;
    }
    return total;
  }

  // ── Auto-create Orders sheet if not exists ──
  Future<void> _ensureOrdersSheetExists(
      sheets.SheetsApi sheetsApi,
      String spreadsheetId,
      ) async {
    try {
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheetExists = spreadsheet.sheets?.any(
              (s) => s.properties?.title == 'Orders'
      ) ?? false;

      if (sheetExists) {
        print('✅ Orders sheet exists');
        return;
      }

      print('⚠️ Orders sheet missing — creating...');
      await sheetsApi.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(
          requests: [
            sheets.Request(
              addSheet: sheets.AddSheetRequest(
                properties: sheets.SheetProperties(
                  title: 'Orders',
                  gridProperties: sheets.GridProperties(
                    rowCount: 1000,
                    columnCount: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        spreadsheetId,
      );

      // Add headers
      final headerRange = sheets.ValueRange();
      headerRange.values = [
        <Object?>['orderId','companyId','customerId','customerName',
          'itemId','itemName','quantity','price','subtotal',
          'totalAmount','status','timestamp']
      ];
      await sheetsApi.spreadsheets.values.update(
        headerRange,
        spreadsheetId,
        'Orders!A1:L1',
        valueInputOption: 'RAW',
      );
      print('✅ Orders sheet created with headers');
    } catch (e) {
      print('⚠️ ensureOrdersSheet error: \$e');
    }
  }


}