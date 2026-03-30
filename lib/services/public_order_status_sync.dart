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

  static Future<void> markInvoiceCreated(String orderId) async {
    final id = orderId.trim();
    if (id.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('public_orders')
          .doc(id)
          .update({
        'invoiceCreated': true,
        'status': 'confirmed',
      });
      await _updateOrderStatusInSheet(id, 'confirmed');
    } catch (e) {
      // ignore: avoid_print
      print('❌ markInvoiceCreated error: $e');
    }
  }

  static Future<void> markChallanCreated(String orderId) async {
    final id = orderId.trim();
    if (id.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('public_orders')
          .doc(id)
          .update({
        'challanCreated': true,
        'status': 'confirmed',
      });
      await _updateOrderStatusInSheet(id, 'confirmed');
    } catch (e) {
      // ignore: avoid_print
      print('❌ markChallanCreated error: $e');
    }
  }

  static Future<void> resetOrderCreated(String orderId) async {
    final id = orderId.trim();
    if (id.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('public_orders')
          .doc(id)
          .update({
        'invoiceCreated': false,
        'challanCreated': false,
        'status': 'pending',
      });
      await _updateOrderStatusInSheet(id, 'pending');
    } catch (e) {
      // ignore: avoid_print
      print('❌ resetOrderCreated error: $e');
      rethrow;
    }
  }
}
