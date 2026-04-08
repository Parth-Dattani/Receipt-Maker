import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/orders_sheet_service.dart';
import '../services/public_order_status_sync.dart';
import '../utils/shared_preferences_helper.dart';

class AdminOrdersController extends GetxController {
  var isLoading = false.obs;
  var orders = <Map<String, dynamic>>[].obs;
  var filterStatus = 'all'.obs;

  int get pendingCount =>
      orders.where((o) => o['status'] == 'pending').length;
  int get confirmedCount =>
      orders.where((o) => o['status'] == 'confirmed').length;
  int get deliveredCount =>
      orders.where((o) => o['status'] == 'delivered').length;

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
      final docs = await OrdersSheetService.getAdminOrders(uid);
      orders.value = docs;
      print('✅ Admin orders loaded (sheet): ${docs.length}');
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

  // Firestore `public_orders` removed — status changes happen when
  // invoice/challan is created (sheet sync). Manual mark/reset removed.
  Future<void> resetOrderCreated(String orderId) async {
    try {
      await PublicOrderStatusSync.resetOrderCreated(orderId);
      Get.snackbar(
        'Reset ✅',
        'Order re-enabled (pending)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      await loadOrders();
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
