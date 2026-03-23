import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/shared_preferences_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;


import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

class AdminOrdersController extends GetxController {
  var isLoading    = false.obs;
  var orders       = <Map<String, dynamic>>[].obs;
  var filterStatus = 'all'.obs;

  final _firestore = FirebaseFirestore.instance;

  int get pendingCount   => orders.where((o) => o['status'] == 'pending').length;
  int get confirmedCount => orders.where((o) => o['status'] == 'confirmed').length;
  int get deliveredCount => orders.where((o) => o['status'] == 'delivered').length;

  List<Map<String, dynamic>> get filteredOrders {
    if (filterStatus.value == 'all') return orders;
    return orders.where((o) => o['status'] == filterStatus.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final uid = await _getCompanyUserId();
      if (uid.isEmpty) {
        print('❌ No user ID found');
        return;
      }
      print('📦 Loading orders for uid: $uid');

      _firestore
          .collection('public_orders')
          .where('companyId', isEqualTo: uid)
          .snapshots()
          .listen((snap) {
        final docs = snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList();

        docs.sort((a, b) {
          final aTs = a['timestamp'] as Timestamp?;
          final bTs = b['timestamp'] as Timestamp?;
          if (aTs == null && bTs == null) return 0;
          if (aTs == null) return 1;
          if (bTs == null) return -1;
          return bTs.compareTo(aTs);
        });

        orders.value = docs;
        print('✅ Admin orders loaded: ${docs.length}');
      });
    } catch (e) {
      print('❌ loadOrders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _getCompanyUserId() async {
    try {
      final pref = await sharedPreferencesHelper.getPrefData("userId");
      if (pref != null && pref.toString().isNotEmpty) return pref.toString();
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('public_orders')
          .doc(orderId)
          .update({'status': newStatus});

      _updateOrderStatusInSheet(orderId, newStatus);

      Get.snackbar(
        'Updated ✅',
        'Order status: ${newStatus[0].toUpperCase()}${newStatus.substring(1)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black87,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e',
          backgroundColor: Colors.red.shade100);
    }
  }

  void _updateOrderStatusInSheet(String orderId, String newStatus) {
    Future.delayed(Duration.zero, () async {
      try {
        final jsonStr = await rootBundle.loadString(
            'assets/getyourinvoice-8f128-3dfb21843bde.json');
        final credentials = json.decode(jsonStr) as Map<String, dynamic>;

        final uid = await _getCompanyUserId();
        if (uid.isEmpty) return;

        final doc = await _firestore.collection('users').doc(uid).get();
        final data = doc.data();
        if (data == null) return;

        final now = DateTime.now();
        final fyYear = now.month >= 4 ? now.year : now.year - 1;
        final fy = fyYear.toString() + '-' +
            (fyYear + 1).toString().substring(2);
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

          final resp = await sheetsApi.spreadsheets.values.get(
            spreadsheetId, 'Orders!A:A',
          );
          final rows = resp.values ?? [];

          int updatedCount = 0;
          for (int i = 0; i < rows.length; i++) {
            if (rows[i].isNotEmpty &&
                rows[i][0].toString().trim() == orderId) {
              final rowNum = i + 1;
              final statusRange = sheets.ValueRange();
              statusRange.values = [[newStatus]];
              await sheetsApi.spreadsheets.values.update(
                statusRange,
                spreadsheetId,
                'Orders!K' + rowNum.toString(),
                valueInputOption: 'RAW',
              );
              updatedCount++;
            }
          }
          print('✅ Orders sheet updated: $orderId → $newStatus ($updatedCount rows)');
        } finally {
          authClient.close();
        }
      } catch (e) {
        print('⚠️ Sheet status update failed: $e');
      }
    });
  }

  Future<void> markInvoiceCreated(String orderId) async {
    try {
      await _firestore.collection('public_orders').doc(orderId).update({
        'invoiceCreated': true,
        'status': 'confirmed',
      });
      _updateOrderStatusInSheet(orderId, 'confirmed');
      print('✅ Invoice marked created: $orderId');
    } catch (e) {
      print('❌ markInvoiceCreated error: $e');
    }
  }

  Future<void> markChallanCreated(String orderId) async {
    try {
      await _firestore.collection('public_orders').doc(orderId).update({
        'challanCreated': true,
        'status': 'confirmed',
      });
      _updateOrderStatusInSheet(orderId, 'confirmed');
      print('✅ Challan marked created: $orderId');
    } catch (e) {
      print('❌ markChallanCreated error: $e');
    }
  }

  // ✅ NEW: Reset order — re-enable Invoice/Challan buttons
  Future<void> resetOrderCreated(String orderId) async {
    try {
      await _firestore.collection('public_orders').doc(orderId).update({
        'invoiceCreated': false,
        'challanCreated': false,
        'status': 'pending',
      });
      _updateOrderStatusInSheet(orderId, 'pending');
      Get.snackbar(
        'Reset ✅',
        'Order re-enabled for Invoice/Challan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.black87,
        duration: const Duration(seconds: 2),
      );
      print('✅ Order reset: $orderId');
    } catch (e) {
      print('❌ resetOrderCreated error: $e');
      Get.snackbar('Error', 'Failed to reset: $e',
          backgroundColor: Colors.red.shade100);
    }
  }
}
