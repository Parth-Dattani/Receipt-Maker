import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';

import '../utils/shared_preferences_helper.dart';

/// Keeps Firestore `public_orders` and the Orders sheet column **status** in sync
/// when an admin creates an invoice/challan from a customer order.
class PublicOrderStatusSync {
  PublicOrderStatusSync._();

  static Future<String> _getCompanyUserId() async {
    try {
      final pref = await sharedPreferencesHelper.getPrefData("userId");
      if (pref != null && pref.toString().isNotEmpty) return pref.toString();
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  static Future<String> _resolveOrderSheetTitle(
    sheets.SheetsApi sheetsApi,
    String spreadsheetId,
  ) async {
    try {
      final meta = await sheetsApi.spreadsheets.get(spreadsheetId);
      final titles = meta.sheets
              ?.map((s) => s.properties?.title)
              .whereType<String>()
              .toList() ??
          [];
      for (final t in titles) {
        if (t.trim().toLowerCase() == 'orders') return t;
      }
      for (final t in titles) {
        if (t.trim().toLowerCase() == 'order') return t;
      }
    } catch (e) {
      // ignore
    }
    return 'Orders';
  }

  static String _a1Range(String sheetTitle, String a1Rest) {
    final t = sheetTitle.trim();
    if (t.isEmpty) return 'Orders!$a1Rest';
    final simple = RegExp(r'^[A-Za-z0-9_]+$').hasMatch(t);
    final name = simple ? t : "'${t.replaceAll("'", "''")}'";
    return '$name!$a1Rest';
  }

  static Future<void> _updateOrderStatusInSheet(
      String orderId, String newStatus) async {
    try {
      final jsonStr = await rootBundle.loadString(
          'assets/getyourinvoice-8f128-3dfb21843bde.json');
      final credentials = json.decode(jsonStr) as Map<String, dynamic>;

      final uid = await _getCompanyUserId();
      if (uid.isEmpty) return;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) return;

      final now = DateTime.now();
      final fyYear = now.month >= 4 ? now.year : now.year - 1;
      final fy = '$fyYear-${(fyYear + 1).toString().substring(2)}';
      final byFy = data['spreadsheetIdsByFy'] as Map<String, dynamic>?;
      final spreadsheetId = (byFy != null && byFy.containsKey(fy))
          ? byFy[fy].toString()
          : data['spreadsheetId']?.toString() ?? '';
      if (spreadsheetId.isEmpty) return;

      int? statusCol1Based;
      final authClient = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentials),
        [sheets.SheetsApi.spreadsheetsScope],
      );
      try {
        final sheetsApi = sheets.SheetsApi(authClient);
        final sheetTitle =
            await _resolveOrderSheetTitle(sheetsApi, spreadsheetId);

        final headerResp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId,
          _a1Range(sheetTitle, '1:1'),
        );
        final headerRow = headerResp.values?.isNotEmpty == true
            ? headerResp.values!.first
                .map((h) => h.toString().trim().toLowerCase())
                .toList()
            : <dynamic>[];
        final statusIdx = headerRow.indexOf('status');
        if (statusIdx >= 0) {
          statusCol1Based = statusIdx + 1;
        }

        final colLetter = statusCol1Based != null
            ? _columnLetterFromIndex(statusCol1Based)
            : 'K';

        final colARange = _a1Range(sheetTitle, 'A:A');
        final resp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId,
          colARange,
        );
        final rows = resp.values ?? [];

        var updatedCount = 0;
        for (var i = 0; i < rows.length; i++) {
          if (rows[i].isEmpty) continue;
          final cell0 = rows[i][0].toString().trim();
          if (i == 0 && cell0.toLowerCase() == 'orderid') continue;
          if (cell0 != orderId) continue;
          final rowNum = i + 1;
          final statusRange = sheets.ValueRange()..values = [[newStatus]];
          await sheetsApi.spreadsheets.values.update(
            statusRange,
            spreadsheetId,
            _a1Range(sheetTitle, '$colLetter$rowNum'),
            valueInputOption: 'RAW',
          );
          updatedCount++;
        }
        // ignore: avoid_print
        print(
            '✅ Order sheet "$sheetTitle" status: $orderId → $newStatus ($updatedCount rows, col $colLetter)');
      } finally {
        authClient.close();
      }
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Sheet status update failed: $e');
    }
  }

  static Future<void> _syncOrderLinesInSheet(
    String orderId, {
    required String overallStatus,
    List<Map<String, dynamic>>? fulfilledLineItems,
  }) async {
    if (fulfilledLineItems == null) {
      await _updateOrderStatusInSheet(orderId, overallStatus);
      return;
    }
    try {
      final jsonStr = await rootBundle.loadString(
          'assets/getyourinvoice-8f128-3dfb21843bde.json');
      final credentials = json.decode(jsonStr) as Map<String, dynamic>;

      final uid = await _getCompanyUserId();
      if (uid.isEmpty) return;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) return;

      final now = DateTime.now();
      final fyYear = now.month >= 4 ? now.year : now.year - 1;
      final fy = '$fyYear-${(fyYear + 1).toString().substring(2)}';
      final byFy = data['spreadsheetIdsByFy'] as Map<String, dynamic>?;
      final spreadsheetId = (byFy != null && byFy.containsKey(fy))
          ? byFy[fy].toString()
          : data['spreadsheetId']?.toString() ?? '';
      if (spreadsheetId.isEmpty) return;

      final authClient = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentials),
        [sheets.SheetsApi.spreadsheetsScope],
      );
      try {
        final sheetsApi = sheets.SheetsApi(authClient);
        final sheetTitle = await _resolveOrderSheetTitle(sheetsApi, spreadsheetId);

        // Read headers to locate columns (fallback to known schema if missing)
        final headerResp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId,
          _a1Range(sheetTitle, '1:1'),
        );
        final headerRow = headerResp.values?.isNotEmpty == true
            ? headerResp.values!.first
                .map((h) => h.toString().trim().toLowerCase())
                .toList()
            : <dynamic>[];

        int idxOf(String name, int fallback) {
          final i = headerRow.indexOf(name);
          return i >= 0 ? i : fallback;
        }

        // Default schema from OrderController._ensureOrdersSheetExists:
        // A orderId, B companyId, C customerId, D customerName, E itemId,
        // F itemName, G quantity, H price, I subtotal, J totalAmount,
        // K status, L timestamp
        final orderIdIdx = idxOf('orderid', 0);
        final itemIdIdx = idxOf('itemid', 4);
        final itemNameIdx = idxOf('itemname', 5);
        final qtyIdx = idxOf('quantity', 6);
        final priceIdx = idxOf('price', 7);
        final subtotalIdx = idxOf('subtotal', 8);
        final totalIdx = idxOf('totalamount', 9);
        final statusIdx = idxOf('status', 10);

        final newTotal = _totalFromOrderLineMaps(fulfilledLineItems);
        final fulfilledByItemId = <String, Map<String, dynamic>>{
          for (final m in fulfilledLineItems)
            (m['itemId']?.toString() ?? '').trim(): m,
        };

        // Get full sheet rows (limited to A:L as current schema)
        final resp = await sheetsApi.spreadsheets.values.get(
          spreadsheetId,
          _a1Range(sheetTitle, 'A:L'),
        );
        final rows = resp.values ?? [];

        final updates = <sheets.ValueRange>[];
        var touched = 0;
        for (var i = 0; i < rows.length; i++) {
          final row = rows[i];
          if (row.isEmpty) continue;
          final cell0 = orderIdIdx < row.length ? row[orderIdIdx].toString().trim() : '';
          if (i == 0 && cell0.toLowerCase() == 'orderid') continue;
          if (cell0 != orderId) continue;

          final rowNum = i + 1; // 1-based
          final existingItemId =
              itemIdIdx < row.length ? row[itemIdIdx].toString().trim() : '';
          final keep = existingItemId.isNotEmpty && fulfilledByItemId.containsKey(existingItemId);

          // Always update totalAmount + status per row
          updates.add(
            sheets.ValueRange()
              ..range = _a1Range(sheetTitle, '${_columnLetterFromIndex(totalIdx + 1)}$rowNum')
              ..values = [
                [newTotal]
              ],
          );

          updates.add(
            sheets.ValueRange()
              ..range = _a1Range(sheetTitle, '${_columnLetterFromIndex(statusIdx + 1)}$rowNum')
              ..values = [
                [keep ? overallStatus : 'cancelled']
              ],
          );

          if (keep) {
            final m = fulfilledByItemId[existingItemId]!;
            final itemName = m['itemName']?.toString() ?? '';
            final qty = m['quantity'];
            final price = m['price'];
            final subtotal = m['subtotal'];

            updates.add(
              sheets.ValueRange()
                ..range = _a1Range(sheetTitle, '${_columnLetterFromIndex(itemNameIdx + 1)}$rowNum')
                ..values = [
                  [itemName]
                ],
            );
            updates.add(
              sheets.ValueRange()
                ..range = _a1Range(sheetTitle, '${_columnLetterFromIndex(qtyIdx + 1)}$rowNum')
                ..values = [
                  [qty]
                ],
            );
            updates.add(
              sheets.ValueRange()
                ..range = _a1Range(sheetTitle, '${_columnLetterFromIndex(priceIdx + 1)}$rowNum')
                ..values = [
                  [price]
                ],
            );
            updates.add(
              sheets.ValueRange()
                ..range = _a1Range(sheetTitle, '${_columnLetterFromIndex(subtotalIdx + 1)}$rowNum')
                ..values = [
                  [subtotal]
                ],
            );
          }

          touched++;
        }

        if (updates.isEmpty) {
          // Fallback: status only (keeps prior behavior)
          await _updateOrderStatusInSheet(orderId, overallStatus);
          return;
        }

        await sheetsApi.spreadsheets.values.batchUpdate(
          sheets.BatchUpdateValuesRequest(
            valueInputOption: 'USER_ENTERED',
            data: updates,
          ),
          spreadsheetId,
        );

        // ignore: avoid_print
        print(
          '✅ Orders sheet "$sheetTitle" synced: $orderId (rows: $touched, keep: ${fulfilledLineItems.length})',
        );
      } finally {
        authClient.close();
      }
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Sheet line sync failed: $e');
      // Fallback to status-only so flow doesn't break
      await _updateOrderStatusInSheet(orderId, overallStatus);
    }
  }

  /// 1-based column index → A, B, … Z, AA, …
  static String _columnLetterFromIndex(int col1Based) {
    var result = '';
    var n = col1Based;
    while (n > 0) {
      n -= 1;
      result = String.fromCharCode(65 + n % 26) + result;
      n ~/= 26;
    }
    return result;
  }

  /// When [fulfilledLineItems] is set (same shape as customer `placeOrder` lines:
  /// itemId, itemName, price, quantity, subtotal), Firestore `items` and
  /// `totalAmount` are replaced so "My Orders" matches invoice/challan after
  /// admin removes out-of-stock lines.
  static double _totalFromOrderLineMaps(List<Map<String, dynamic>> lines) {
    var total = 0.0;
    for (final m in lines) {
      final sub = double.tryParse(m['subtotal']?.toString() ?? '');
      if (sub != null) {
        total += sub;
        continue;
      }
      final q = double.tryParse(m['quantity']?.toString() ?? '0') ?? 0;
      final p = double.tryParse(m['price']?.toString() ?? '0') ?? 0;
      total += q * p;
    }
    return total;
  }

  static Future<void> markInvoiceCreated(
    String orderId, {
    List<Map<String, dynamic>>? fulfilledLineItems,
  }) async {
    final id = orderId.trim();
    if (id.isEmpty) return;
    try {
      await _syncOrderLinesInSheet(
        id,
        overallStatus: 'confirmed',
        fulfilledLineItems: fulfilledLineItems,
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ markInvoiceCreated error: $e');
    }
  }

  static Future<void> markChallanCreated(
    String orderId, {
    List<Map<String, dynamic>>? fulfilledLineItems,
  }) async {
    final id = orderId.trim();
    if (id.isEmpty) return;
    try {
      await _syncOrderLinesInSheet(
        id,
        overallStatus: 'confirmed',
        fulfilledLineItems: fulfilledLineItems,
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ markChallanCreated error: $e');
    }
  }

  static Future<void> resetOrderCreated(String orderId) async {
    final id = orderId.trim();
    if (id.isEmpty) return;
    try {
      await _updateOrderStatusInSheet(id, 'pending');
    } catch (e) {
      // ignore: avoid_print
      print('❌ resetOrderCreated error: $e');
      rethrow;
    }
  }
}
