import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/shared_preferences_helper.dart';

// ─────────────────────────────────────────────
// AdminOrdersController
// ─────────────────────────────────────────────
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
      // Try sharedPreferences first
      final pref = await sharedPreferencesHelper.getPrefData("userId");
      if (pref != null && pref.toString().isNotEmpty) {
        return pref.toString();
      }
    } catch (_) {}
    // Fallback to FirebaseAuth
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('public_orders')
          .doc(orderId)
          .update({'status': newStatus});

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
}
