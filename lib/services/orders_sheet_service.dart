import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';

class OrdersSheetService {
  OrdersSheetService._();

  static const _serviceAccountAssetPath =
      'assets/getyourinvoice-8f128-3dfb21843bde.json';

  static Future<String> _resolveSpreadsheetIdForCompany(String companyId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(companyId).get();
    final data = doc.data();
    if (data == null) throw Exception('User doc not found for companyId=$companyId');

    final now = DateTime.now();
    final fyYear = now.month >= 4 ? now.year : now.year - 1;
    final fy = '$fyYear-${(fyYear + 1).toString().substring(2)}';
    final byFy = data['spreadsheetIdsByFy'] as Map<String, dynamic>?;
    final spreadsheetId = (byFy != null && byFy.containsKey(fy))
        ? byFy[fy].toString()
        : data['spreadsheetId']?.toString() ?? '';
    if (spreadsheetId.isEmpty) throw Exception('spreadsheetId not found');
    return spreadsheetId;
  }

  static String _safeStr(dynamic v) => (v ?? '').toString().trim();

  static double _safeDbl(dynamic v) =>
      double.tryParse(_safeStr(v).replaceAll(',', '.')) ?? 0.0;

  /// Sheet format from `OrderController._saveOrderToSheet`: `dd/MM/yyyy HH:mm:ss`
  static DateTime? _parseSheetTimestamp(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final m = RegExp(
      r'^(\d{2})/(\d{2})/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})',
    ).firstMatch(s);
    if (m == null) return null;
    try {
      final day = int.parse(m.group(1)!);
      final month = int.parse(m.group(2)!);
      final year = int.parse(m.group(3)!);
      final h = int.parse(m.group(4)!);
      final min = int.parse(m.group(5)!);
      final sec = int.parse(m.group(6)!);
      return DateTime(year, month, day, h, min, sec);
    } catch (_) {
      return null;
    }
  }

  static int _maxTimestampMsForLines(List<Map<String, dynamic>> lines) {
    var best = 0;
    for (final l in lines) {
      final d = _parseSheetTimestamp(_safeStr(l['timestamp']));
      if (d != null) {
        final ms = d.millisecondsSinceEpoch;
        if (ms > best) best = ms;
      }
    }
    return best;
  }

  /// `ORD-<millisecondsSinceEpoch>` from sheet-only place order
  static int _sortKeyFromOrderId(String orderId) {
    if (orderId.startsWith('ORD-')) {
      final n = int.tryParse(orderId.substring(4));
      if (n != null) return n;
    }
    return 0;
  }

  static String _newestTimestampRawAmongLines(
    List<Map<String, dynamic>> lines,
  ) {
    DateTime? bestDt;
    var bestRaw = '';
    for (final l in lines) {
      final raw = _safeStr(l['timestamp']);
      final d = _parseSheetTimestamp(raw);
      if (d != null && (bestDt == null || d.isAfter(bestDt))) {
        bestDt = d;
        bestRaw = raw;
      }
    }
    if (bestRaw.isNotEmpty) return bestRaw;
    return lines.isNotEmpty ? _safeStr(lines.first['timestamp']) : '';
  }

  static bool _isCancelledLineStatus(String raw) {
    var s = _safeStr(raw).toLowerCase();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    if (s.isEmpty) return false;
    if (s == 'cancelled' || s == 'canceled' || s == 'cancel') return true;
    final letters = s.replaceAll(RegExp(r'[^a-z]'), '');
    return letters == 'cancelled' ||
        letters == 'canceled' ||
        letters == 'cancel';
  }

  static String _canonicalLineStatus(String raw) {
    final s = _safeStr(raw).toLowerCase();
    if (s.isEmpty) return 'pending';
    if (_isCancelledLineStatus(raw)) return 'cancelled';
    if (s == 'confirmed' || s == 'confirm') return 'confirmed';
    if (s == 'pending') return 'pending';
    if (s == 'delivered' || s == 'deliver') return 'delivered';
    return s;
  }

  static String _aggregateStatusFromLines(List<Map<String, dynamic>> activeLines) {
    if (activeLines.isEmpty) return 'cancelled';
    final set = activeLines
        .map((l) => _canonicalLineStatus(_safeStr(l['status'])))
        .where((s) => s.isNotEmpty && s != 'cancelled')
        .toSet();
    if (set.contains('delivered')) return 'delivered';
    if (set.contains('confirmed')) return 'confirmed';
    if (set.contains('pending')) return 'pending';
    return 'pending';
  }

  static Future<List<Map<String, dynamic>>> _readOrdersRows(
    String companyId, {
    String? customerId,
  }) async {
    final spreadsheetId = await _resolveSpreadsheetIdForCompany(companyId);
    final jsonStr = await rootBundle.loadString(_serviceAccountAssetPath);
    final credentials = json.decode(jsonStr) as Map<String, dynamic>;
    final authClient = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(credentials),
      [sheets.SheetsApi.spreadsheetsScope],
    );
    final api = sheets.SheetsApi(authClient);
    try {
      // Schema: A orderId, B companyId, C customerId, D customerName,
      // E itemId, F itemName, G quantity, H price, I subtotal,
      // J totalAmount, K status, L timestamp
      final resp = await api.spreadsheets.values.get(
        spreadsheetId,
        'Orders!A:L',
      );
      final values = resp.values ?? const <List<Object?>>[];
      if (values.isEmpty) return [];

      final header = values.first.map((e) => _safeStr(e).toLowerCase()).toList();
      int idxOf(String name, int fallback) {
        final i = header.indexOf(name);
        return i >= 0 ? i : fallback;
      }

      final orderIdIdx = idxOf('orderid', 0);
      final companyIdx = idxOf('companyid', 1);
      final customerIdx = idxOf('customerid', 2);
      final customerNameIdx = idxOf('customername', 3);
      final itemIdIdx = idxOf('itemid', 4);
      final itemNameIdx = idxOf('itemname', 5);
      final qtyIdx = idxOf('quantity', 6);
      final priceIdx = idxOf('price', 7);
      final subtotalIdx = idxOf('subtotal', 8);
      final totalIdx = idxOf('totalamount', 9);
      final statusIdx = idxOf('status', 10);
      final tsIdx = idxOf('timestamp', 11);

      final rows = <Map<String, dynamic>>[];
      for (var i = 1; i < values.length; i++) {
        final r = values[i];
        if (r.isEmpty) continue;
        String cell(int idx) => idx < r.length ? _safeStr(r[idx]) : '';

        final rowCompanyId = cell(companyIdx);
        if (rowCompanyId != companyId) continue;
        final rowCustomerId = cell(customerIdx);
        if (customerId != null && rowCustomerId != customerId) continue;

        rows.add({
          'orderId': cell(orderIdIdx),
          'companyId': rowCompanyId,
          'customerId': rowCustomerId,
          'customerName': cell(customerNameIdx),
          'itemId': cell(itemIdIdx),
          'itemName': cell(itemNameIdx),
          'quantity': _safeDbl(cell(qtyIdx)),
          'price': _safeDbl(cell(priceIdx)),
          'subtotal': _safeDbl(cell(subtotalIdx)),
          'totalAmount': _safeDbl(cell(totalIdx)),
          'status': cell(statusIdx).isEmpty
              ? 'pending'
              : _canonicalLineStatus(cell(statusIdx)),
          'timestamp': cell(tsIdx),
        });
      }
      return rows;
    } finally {
      authClient.close();
    }
  }

  static List<Map<String, dynamic>> _groupRowsToOrders(
    List<Map<String, dynamic>> rows,
  ) {
    final byOrderId = <String, List<Map<String, dynamic>>>{};
    for (final r in rows) {
      final oid = _safeStr(r['orderId']);
      if (oid.isEmpty) continue;
      (byOrderId[oid] ??= []).add(r);
    }

    final orders = <Map<String, dynamic>>[];
    byOrderId.forEach((orderId, lines) {
      final activeLines = lines
          .where((l) => !_isCancelledLineStatus(_safeStr(l['status'])))
          .toList();

      final items = activeLines
          .map((l) => <String, dynamic>{
                'itemId': l['itemId'],
                'itemName': l['itemName'],
                'quantity': l['quantity'],
                'price': l['price'],
                'subtotal': l['subtotal'],
              })
          .toList();

      var status = _aggregateStatusFromLines(activeLines).trim();
      // Sheet can have odd spacing/spellings; never show whole order cancelled if any line is still active.
      if (items.isNotEmpty && _isCancelledLineStatus(status)) {
        status = 'confirmed';
      }

      final fromItemsSubtotal =
          items.fold<double>(0, (s, m) => s + _safeDbl(m['subtotal']));
      double totalAmount = fromItemsSubtotal;
      if (totalAmount <= 0 &&
          activeLines.isNotEmpty &&
          _safeDbl(activeLines.first['totalAmount']) > 0) {
        totalAmount = _safeDbl(activeLines.first['totalAmount']);
      }

      final ts = _newestTimestampRawAmongLines(lines);

      orders.add({
        'id': orderId,
        'orderId': orderId,
        'companyId': _safeStr(lines.first['companyId']),
        'customerId': _safeStr(lines.first['customerId']),
        'customerName': _safeStr(lines.first['customerName']),
        'items': items,
        'totalAmount': totalAmount,
        'status': status.isEmpty ? 'pending' : status,
        'timestamp': ts,
      });
    });

    // Descending: latest order first (admin + customer lists)
    orders.sort((a, b) {
      final oidA = _safeStr(a['orderId']);
      final oidB = _safeStr(b['orderId']);
      final linesA = byOrderId[oidA] ?? [];
      final linesB = byOrderId[oidB] ?? [];
      final msA = _maxTimestampMsForLines(linesA);
      final msB = _maxTimestampMsForLines(linesB);
      if (msA != msB) return msB.compareTo(msA);
      final tie = _sortKeyFromOrderId(oidB).compareTo(_sortKeyFromOrderId(oidA));
      if (tie != 0) return tie;
      return oidB.compareTo(oidA);
    });
    return orders;
  }

  static Future<List<Map<String, dynamic>>> getAdminOrders(String companyId) async {
    final rows = await _readOrdersRows(companyId);
    return _groupRowsToOrders(rows);
  }

  static Future<List<Map<String, dynamic>>> getCustomerOrders({
    required String companyId,
    required String customerId,
  }) async {
    final rows = await _readOrdersRows(companyId, customerId: customerId);
    return _groupRowsToOrders(rows);
  }
}

