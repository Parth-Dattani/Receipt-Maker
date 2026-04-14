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
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import '../services/orders_sheet_service.dart';


// ─────────────────────────────────────────────
// OrderRow Model
// ─────────────────────────────────────────────
class OrderRow {
  Item? selectedItem;
  double qty;
  OrderRow({this.selectedItem, this.qty = 0});
}

// ─────────────────────────────────────────────
// Helper — top level (outside class)
// ─────────────────────────────────────────────
bool _isWholeUnit(String? unit) {
  const decimalUnits = {
    // Weight
    'kg', 'kgs', 'kilogram', 'kilograms',
    'g', 'gm', 'gms', 'gram', 'grams',
    'mg', 'milligram', 'milligrams',
    'quintal', 'ton', 'tonne', 'tons', 'tonnes',
    // Volume
    'l', 'lt', 'ltr', 'ltrs', 'liter', 'litre', 'liters', 'litres',
    'ml', 'milliliter', 'millilitre', 'milliliters', 'millilitres',
    // Length
    'm', 'mtr', 'meter', 'metre', 'meters', 'metres',
    'cm', 'centimeter', 'centimetre',
    'mm', 'millimeter', 'millimetre',
    'ft', 'feet', 'foot',
    'inch', 'inches', 'in',
    'yard', 'yd',
  };
  final u = (unit ?? '').toLowerCase().trim();
  if (u.isEmpty) return true; // no unit = pcs style = whole
  return !decimalUnits.contains(u);
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
  /// Bumped on qty changes so cart bar updates without rebuilding the whole order list (web scroll).
  var orderQtyTick = 0.obs;
  /// Non-empty when customer opened `/order?...&editOrderId=ORD-...` from My Orders.
  var editOrderIdParam = ''.obs;

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
    editOrderIdParam.value = (Get.parameters['editOrderId'] ?? '').trim();

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

      // Default 1 empty row, or load pending order for edit
      orderRows.value = [OrderRow()];
      if (editOrderIdParam.value.isNotEmpty) {
        await _loadPendingOrderIntoRows(editOrderIdParam.value);
      }

    } catch (e) {
      print('❌ initPage error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPendingOrderIntoRows(String orderId) async {
    try {
      final list = await OrdersSheetService.getCustomerOrders(
        companyId: companyId.value,
        customerId: customerId.value,
      );
      Map<String, dynamic>? found;
      for (final o in list) {
        if (o['orderId']?.toString() == orderId) {
          found = o;
          break;
        }
      }
      if (found == null) {
        Get.snackbar('Order not found',
            'આ ઓર્ડર મળ્યો નથી અથવા કાઢી દેવાયો છે.');
        editOrderIdParam.value = '';
        return;
      }
      if (!OrdersSheetService.isPendingOrderForCustomerEdit(found)) {
        Get.snackbar('ફેરફાર ન થઈ શકે',
            'ફક્ત Pending ઓર્ડર જ એડિટ / ડિલીટ થઈ શકે.');
        editOrderIdParam.value = '';
        return;
      }
      final rawItems = found['items'];
      if (rawItems is! List || rawItems.isEmpty) {
        Get.snackbar('Order', 'આ ઓર્ડરમાં લાઇન આઇટમ નથી.');
        editOrderIdParam.value = '';
        return;
      }

      final newRows = <OrderRow>[];
      for (final raw in rawItems) {
        if (raw is! Map) continue;
        final m = Map<String, dynamic>.from(raw);
        final id = m['itemId']?.toString() ?? '';
        final name = m['itemName']?.toString() ?? '';
        final price =
            double.tryParse(m['price']?.toString() ?? '0') ?? 0.0;
        final qty =
            double.tryParse(m['quantity']?.toString() ?? '0') ?? 0.0;
        if (qty <= 0) continue;

        Item? item = itemList.firstWhereOrNull((i) => i.itemId == id);
        item ??= Item(
          itemId: id.isEmpty ? 'unknown-${newRows.length}' : id,
          itemName: name.isEmpty ? 'Item' : name,
          price: price,
          sellPrice: price,
        );
        newRows.add(OrderRow(selectedItem: item, qty: qty));
      }

      if (newRows.isEmpty) {
        Get.snackbar('Order', 'આ ઓર્ડર લોડ થયો નથી.');
        editOrderIdParam.value = '';
        return;
      }
      orderRows.value = newRows;
      orderRows.refresh();
    } catch (e) {
      print('❌ _loadPendingOrderIntoRows: $e');
      Get.snackbar('Error', 'ઓર્ડર લોડ કરતાં ભૂલ.');
      editOrderIdParam.value = '';
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

        final headerResp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, 'Customer!A1:Z1',
        );
        final headers = (headerResp.values?.isNotEmpty == true)
            ? headerResp.values!.first
            .map((h) => h.toString().trim().toLowerCase())
            .toList()
            : <dynamic>[];
        print('📋 Customer headers: $headers');

        int hIdx(String n) => headers.indexOf(n);

        final idIdx      = hIdx('customerid');
        final nameIdx    = hIdx('name');
        final mobileIdx  = hIdx('mobile1');
        final addressIdx = hIdx('address');
        final emailIdx   = hIdx('email');

        print('📊 id:$idIdx name:$nameIdx mobile:$mobileIdx address:$addressIdx email:$emailIdx');

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
  // ✅ FIXED: Items from Sheet — header-based column mapping
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

        // Step 1: Header row
        final headerResp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, 'Item!A1:Z1',
        );
        final headers = (headerResp.values?.isNotEmpty == true)
            ? headerResp.values!.first
            .map((h) => h.toString().trim().toLowerCase())
            .toList()
            : <dynamic>[];

        print('📋 Item headers: $headers');

        // Step 2: Column indexes
        int idx(String name) => headers.indexOf(name);

        final itemIdIdx    = idx('itemid');
        final itemNameIdx  = idx('itemname');
        final priceIdx     = idx('price');
        final sellPriceIdx = idx('sellprice');
        final gstIdx       = idx('gstpercent');
        final unitIdx      = idx('unitofmeasurement');
        final isActiveIdx  = idx('isactive');

        print('📊 itemId:$itemIdIdx itemName:$itemNameIdx '
            'price:$priceIdx sellPrice:$sellPriceIdx '
            'unit:$unitIdx gst:$gstIdx isActive:$isActiveIdx');

        // Step 3: Data rows — valueRenderOption FORMATTED_VALUE
        final dataResp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, 'Item!A2:Z',
          valueRenderOption: 'FORMATTED_VALUE', // ✅ get actual cell text
        );
        final rows = dataResp.values ?? [];
        print('✅ Fetched ${rows.length} item rows');

        // Step 4: Map rows → Item ✅ FIXED filter + unit
        final mapped = <Item>[];
        for (final row in rows) {
          // Skip empty rows
          if (row.isEmpty) continue;

          // Safe cell reader
          String cell(int i) =>
              (i >= 0 && i < row.length) ? row[i].toString().trim() : '';

          // Skip if itemId empty
          final itemId = cell(itemIdIdx >= 0 ? itemIdIdx : 0);
          if (itemId.isEmpty) continue;

          // ✅ isActive filter — default true if column missing
          if (isActiveIdx >= 0 && isActiveIdx < row.length) {
            final activeVal = cell(isActiveIdx).toLowerCase();
            if (activeVal == 'false' || activeVal == '0' || activeVal == 'no') {
              continue; // skip inactive
            }
          }

          // Price logic: sellPrice first, fallback to price
          final sellStr  = cell(sellPriceIdx >= 0 ? sellPriceIdx : -1);
          final priceStr = cell(priceIdx >= 0 ? priceIdx : 2);
          final finalPrice = double.tryParse(
              sellStr.isNotEmpty ? sellStr : priceStr) ?? 0.0;

          // ✅ KEY FIX: unit read correctly
          // Guard: if cell value is numeric (currentstock leaked), treat as empty
          final rawUnit = cell(unitIdx >= 0 ? unitIdx : 5).trim();
          String unitValue = (double.tryParse(rawUnit) != null || rawUnit == '-1')
              ? ''
              : rawUnit;

          // ✅ FALLBACK: if unit empty, guess from item name
          if (unitValue.isEmpty) {
            final name = cell(itemNameIdx >= 0 ? itemNameIdx : 1).toLowerCase();
            // Common weight items → kg
            if (name.contains('kg') || name.contains('rice') ||
                name.contains('sugar') || name.contains('besan') ||
                name.contains('flour') || name.contains('atta') ||
                name.contains('dal') || name.contains('salt') ||
                name.contains('wheat') || name.contains('maida') ||
                name.contains('sooji') || name.contains('rawa') ||
                name.contains('rava') || name.contains('chawal') ||
                name.contains('gehu') || name.contains('chana') ||
                name.contains('moong') || name.contains('urad') ||
                name.contains('masoor') || name.contains('rajma') ||
                name.contains('chini') || name.contains('namak') ||
                name.contains('mirch') || name.contains('haldi') ||
                name.contains('jeera') || name.contains('dhaniya') ||
                name.contains('oil') || name.contains('ghee') ||
                name.contains('tel') || name.contains('teli') ||
                name.contains('liter') || name.contains('litre') ||
                name.contains('milk') || name.contains('dudh')) {
              unitValue = 'kg'; // treat as decimal unit
            }
          }


          mapped.add(Item(
            itemId:            itemId,
            itemName:          cell(itemNameIdx >= 0 ? itemNameIdx : 1),
            price:             double.tryParse(priceStr) ?? 0.0,
            sellPrice:         finalPrice,
            gstPercent:        double.tryParse(
                cell(gstIdx >= 0 ? gstIdx : 4)) ?? 0.0,
            unitOfMeasurement: unitValue, // ✅ correct unit
          ));
        }

        itemList.value = mapped;
        print('✅ itemList set: ${itemList.length} active items');

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

        await _ensureOrdersSheetExists(sheetsApi, spreadsheetId);

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
        print('✅ Order saved to Sheets: ${rows.length} rows');
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
    orderQtyTick.value++;
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

      final editId = editOrderIdParam.value.trim();
      if (editId.isNotEmpty) {
        await OrdersSheetService.replacePendingOrderInSheet(
          companyId: companyId.value,
          customerId: customerId.value,
          customerName: customerName.value,
          orderId: editId,
          orderItems: orderItems,
          total: total,
        );
        editOrderIdParam.value = '';
      } else {
        final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
        await _saveOrderToSheet(orderId, orderItems, total: total);
      }

      orderRows.value = [OrderRow()];
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
      print('⚠️ ensureOrdersSheet error: $e');
    }
  }
}