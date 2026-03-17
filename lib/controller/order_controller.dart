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
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

// ─────────────────────────────────────────────
// ItemModel
// ─────────────────────────────────────────────
class ItemModel {
  final String itemId;
  final String itemName;
  final double price;
  final String unit;
  final String category;

  ItemModel({
    required this.itemId,
    required this.itemName,
    required this.price,
    this.unit = '',
    this.category = '',
  });

  // Google Sheets row: A=itemId, B=itemName, C=price, D=sellPrice, E=gstPercent, F=unitOfMeasure
  factory ItemModel.fromSheetRow(List<dynamic> row) {
    return ItemModel(
      itemId:   row.length > 0 ? row[0].toString() : '',
      itemName: row.length > 1 ? row[1].toString() : '',
      price:    row.length > 3 ? double.tryParse(row[3].toString()) ?? 0.0 : 0.0, // D = sellPrice
      unit:     row.length > 5 ? row[5].toString() : '', // F = unitOfMeasure
      category: row.length > 4 ? row[4].toString() : '', // E = gstPercent
    );
  }
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
  var itemList       = <ItemModel>[].obs;
  var cart = <String, int>{}.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Your actual JSON file name in assets/
  static const _serviceAccountAssetPath =
      'assets/getyourinvoice-8f128-3dfb21843bde.json';

  // Show/Hide price setting (fetched from Firestore companies doc)
  var showPriceToCustomer = true.obs;

  @override
  void onInit() {
    super.onInit();
    companyId.value  = Get.parameters['cid'] ?? '';
    customerId.value = Get.parameters['uid'] ?? '';

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

      // First get spreadsheetId + price setting (from Firestore)
      final spreadsheetId = await _fetchSpreadsheetId();

      // Then load credentials once
      final jsonStr = await rootBundle.loadString(_serviceAccountAssetPath);
      final credentialsJson = json.decode(jsonStr) as Map<String, dynamic>;

      // Run all in parallel
      await Future.wait([
        _fetchCustomerNameFromSheet(spreadsheetId, credentialsJson),
        _fetchItemsFromSheet(spreadsheetId, credentialsJson),
        _fetchPriceSetting(),
      ]);
    } catch (e) {
      print('❌ initPage error: $e');
      Get.snackbar('Error', 'Failed to load page: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // spreadsheetId from Firestore: users/{cid}
  // ─────────────────────────────────────────────
  Future<String> _fetchSpreadsheetId() async {
    final doc = await _firestore
        .collection('users')
        .doc(companyId.value)
        .get();

    final spreadsheetId = doc.data()?['spreadsheetId']?.toString() ?? '';
    if (spreadsheetId.isEmpty) {
      throw Exception('spreadsheetId not found for companyId: ${companyId.value}');
    }
    print('📊 spreadsheetId: $spreadsheetId');
    return spreadsheetId;
  }

  // ─────────────────────────────────────────────
  // Fetch showPriceToCustomer from Firestore
  // users/{cid}/companies/{companyId} → showPriceToCustomer
  // ─────────────────────────────────────────────
  Future<void> _fetchPriceSetting() async {
    try {
      // Get companies subcollection (first company doc)
      final companiesSnap = await _firestore
          .collection('users')
          .doc(companyId.value)
          .collection('companies')
          .limit(1)
          .get();

      if (companiesSnap.docs.isNotEmpty) {
        final data = companiesSnap.docs.first.data();
        // Default true if field not set
        showPriceToCustomer.value =
            data['showPriceToCustomer'] as bool? ?? true;
        print('💰 showPriceToCustomer: ${showPriceToCustomer.value}');
      }
    } catch (e) {
      print('❌ fetchPriceSetting error: $e');
      showPriceToCustomer.value = true; // default: show
    }
  }

  // ─────────────────────────────────────────────
  // Customer name from "Customer" sheet
  // Sheet columns: A=customerId, B=companyId, C=companyName, D=name, E=address...
  // ─────────────────────────────────────────────
  Future<void> _fetchCustomerNameFromSheet(
      String spreadsheetId,
      Map<String, dynamic> credentialsJson,
      ) async {
    try {
      final accountCredentials = ServiceAccountCredentials.fromJson(credentialsJson);
      final scopes = [sheets.SheetsApi.spreadsheetsReadonlyScope];
      final authClient = await clientViaServiceAccount(accountCredentials, scopes);

      try {
        final sheetsApi = sheets.SheetsApi(authClient);

        // A=customerId, B=companyId, C=companyName, D=name
        final response = await sheetsApi.spreadsheets.values.get(
          spreadsheetId,
          'Customer!A2:D',
        );

        final rows = response.values ?? [];

        for (final row in rows) {
          // Match by customerId (column A) only
          // URL cid = userId (TozLIGsQq4...), NOT companyId (Oe6p4np...)
          final rowCustomerId = row.length > 0 ? row[0].toString() : '';

          if (rowCustomerId == customerId.value) {
            customerName.value =
            row.length > 3 ? row[3].toString() : 'Customer';
            print('✅ Customer found: ${customerName.value}');
            return;
          }
        }

        print('⚠️ Customer not found, customerId: ${customerId.value}');
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
  // Items from "Item" sheet
  // Sheet columns: A=itemId, B=itemName, C=price, D=unit, E=category
  // ─────────────────────────────────────────────
  Future<void> _fetchItemsFromSheet(
      String spreadsheetId,
      Map<String, dynamic> credentialsJson,
      ) async {
    try {
      final accountCredentials = ServiceAccountCredentials.fromJson(credentialsJson);
      final scopes = [sheets.SheetsApi.spreadsheetsReadonlyScope];
      final authClient = await clientViaServiceAccount(accountCredentials, scopes);

      try {
        final sheetsApi = sheets.SheetsApi(authClient);

        final response = await sheetsApi.spreadsheets.values.get(
          spreadsheetId,
          'Item!A2:E',
        );

        final rows = response.values ?? [];
        print('✅ Fetched ${rows.length} items from Google Sheets');

        itemList.value = rows
            .where((row) => row.isNotEmpty && row[0].toString().isNotEmpty)
            .map((row) => ItemModel.fromSheetRow(row))
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
  // Cart helpers
  // ─────────────────────────────────────────────
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
      if (item != null) total += item.price * entry.value;
    }
    return total;
  }

  // ─────────────────────────────────────────────
  // Place Order → Firestore: public_orders
  // ─────────────────────────────────────────────
  Future<void> placeOrder() async {
    if (cart.isEmpty) {
      Get.snackbar('Empty Cart', 'Please add at least one item.');
      return;
    }

    try {
      isPlacingOrder.value = true;

      final List<Map<String, dynamic>> orderItems = [];
      for (final entry in cart.entries) {
        final item = itemList.firstWhereOrNull((i) => i.itemId == entry.key);
        if (item != null) {
          orderItems.add({
            'itemId':   item.itemId,
            'itemName': item.itemName,
            'price':    item.price,
            'quantity': entry.value,
            'subtotal': item.price * entry.value,
          });
        }
      }

      await _firestore.collection('public_orders').add({
        'companyId':    companyId.value,
        'customerId':   customerId.value,
        'customerName': customerName.value,
        'items':        orderItems,
        'totalAmount':  totalAmount,
        'status':       'pending',
        'timestamp':    FieldValue.serverTimestamp(),
      });

      print('✅ Order placed successfully');
      cart.clear();
      Get.offNamed(OrderSuccessScreen.pageId);

    } catch (e) {
      print('❌ placeOrder error: $e');
      Get.snackbar('Error', 'Failed to place order. Please try again.',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isPlacingOrder.value = false;
    }
  }
}