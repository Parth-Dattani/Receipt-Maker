import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/model.dart';
import '../screen/screen.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import 'controller.dart';

class PurchaseListController extends BaseController {
  final purchaseList = <PurchaseEntry>[].obs;
  final filteredPurchaseList = <PurchaseEntry>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  var companyData = <String, dynamic>{}.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Separate loaders
  final isPurchaseLoading = false.obs;
  final isCompanyLoading = false.obs;

  /// UI loading (for shimmer/empty state)
  bool get isDataLoading => isPurchaseLoading.value || isCompanyLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadPurchases();
    loadCompanyData();
  }

  /// Load purchases from Google Sheets
  Future<void> loadPurchases() async {
    try {
      isPurchaseLoading.value = true;

      List<PurchaseEntry> purchases = await GoogleSheetService.getPurchasesList();
      purchaseList.assignAll(purchases);
      filteredPurchaseList.assignAll(purchases);

    } catch (e) {
      print("❌ Error loading purchases: $e");
    } finally {
      isPurchaseLoading.value = false;
    }
  }

  /// Load company data from Firestore
  Future<void> loadCompanyData() async {
    try {
      isCompanyLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      if (companyId.isEmpty) return;

      final companyDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .get();

      if (companyDoc.exists) {
        companyData.value = companyDoc.data() ?? {};
      }
    } catch (e) {
      print("Error loading company data: $e");
    } finally {
      isCompanyLoading.value = false;
    }
  }

  /// Refresh purchases
  Future<void> refreshPurchases() async {
    await loadPurchases();
  }

  /// Search purchases by ID or vendor name
  void filterPurchases(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredPurchaseList.assignAll(purchaseList);
      return;
    }

    final filtered = purchaseList.where((purchase) {
      return (purchase.purchaseId?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (purchase.vendorName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    filteredPurchaseList.assignAll(filtered);
  }

  /// Filter purchases by payment status
  void filterByStatus(String status) {
    selectedFilter.value = status;

    if (status == 'All') {
      filteredPurchaseList.assignAll(purchaseList);
      return;
    }

    final filtered = purchaseList.where((purchase) {
      return (purchase.paymentStatus?.toLowerCase() ?? '') == status.toLowerCase();
    }).toList();

    filteredPurchaseList.assignAll(filtered);
  }

  /// Actions for each purchase
  void viewPurchaseDetails(PurchaseEntry purchase) {
    if (Get.isRegistered<PurchaseDetailsController>()) {
      Get.delete<PurchaseDetailsController>(force: true);
    }
    Get.lazyPut<PurchaseDetailsController>(() => PurchaseDetailsController());
    Get.toNamed(PurchaseDetailsScreen.pageId, arguments: purchase);
  }

  void editPurchase(PurchaseEntry purchase) {
    Get.toNamed(PurchaseEntryScreen.pageId, arguments: purchase);
  }

  Future<void> deletePurchase(PurchaseEntry purchase) async {
    final confirmed = await Get.dialog(
      AlertDialog(
        title: Text('Delete Purchase?'),
        content: Text('Are you sure you want to delete purchase ${purchase.purchaseId}?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isLoading.value = true;

        purchaseList.remove(purchase);
        filteredPurchaseList.remove(purchase);

        Get.snackbar(
          'Deleted',
          'Purchase ${purchase.purchaseId} has been deleted',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete purchase: ${e.toString()}',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// Export purchase as PDF
  // Future<void> exportPurchaseAsPdf(PurchaseEntry purchase) async {
  //   try {
  //     isLoading.value = true;
  //
  //     print("Fetching purchase items for PDF: ${purchase.purchaseId}");
  //     List<PurchaseItem> fetchedPurchaseItems =
  //     await GoogleSheetService.getPurchaseItemsByPurchaseId(purchase.purchaseId);
  //
  //     final cleanedItems = fetchedPurchaseItems.map((item) {
  //       final fixedName = (item.itemName != null && item.itemName!.trim().isNotEmpty)
  //           ? item.itemName
  //           : (item.description ?? "Goods/Service");
  //
  //       return PurchaseItem(
  //         itemId: item.itemId,
  //         itemName: fixedName,
  //         description: item.description,
  //         quantity: item.quantity,
  //         purchasePrice: item.purchasePrice,
  //         totalPrice: item.totalPrice,
  //         gstRate: item.gstRate,
  //         unit: item.unit,
  //         purchaseDate: item.purchaseDate,
  //         vendorId: item.vendorId,
  //         purchaseId: item.purchaseId,
  //       );
  //     }).toList();
  //
  //     final subtotal = cleanedItems.fold<double>(0, (s, it) {
  //       final qty = (it.quantity ?? 0).toDouble();
  //       final rate = it.purchasePrice ?? 0.0;
  //       return s + (qty * rate);
  //     });
  //
  //     final gstTotal = cleanedItems.fold<double>(0, (s, it) {
  //       final qty = (it.quantity ?? 0).toDouble();
  //       final rate = it.purchasePrice ?? 0.0;
  //       final base = qty * rate;
  //       return s + ((base * (it.gstRate ?? 0)) / 100);
  //     });
  //
  //     final grandTotal = subtotal + gstTotal;
  //
  //     final pdfFile = await InvoiceHelper.generateDocument(
  //       isPurchase: true,
  //       purchase: purchase,
  //       purchaseItems: cleanedItems,
  //       companyData: companyData.value,
  //     );
  //
  //     await Share.shareXFiles([XFile(pdfFile.path)], text: 'Purchase - ${purchase.purchaseId}');
  //
  //     Get.snackbar(
  //       'Success',
  //       'Purchase exported as PDF',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.green,
  //       colorText: Colors.white,
  //     );
  //   } catch (e) {
  //     print("Error exporting Purchase PDF: $e");
  //     Get.snackbar(
  //       'Error',
  //       'Failed to export PDF: ${e.toString()}',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  /// Statistics
  int get totalPurchases => purchaseList.length;
  int get completedPurchases => purchaseList.where((p) => p.paymentStatus?.toLowerCase() == 'paid').length;
  int get pendingPurchases => purchaseList.where((p) => p.paymentStatus?.toLowerCase() == 'pending').length;
  int get partialPurchases => purchaseList.where((p) => p.paymentStatus?.toLowerCase() == 'partial').length;

  double get totalPurchaseAmount => purchaseList.fold<double>(0, (sum, p) => sum + (p.totalAmount ?? 0));
  double get totalPaidAmount => purchaseList.fold<double>(0, (sum, p) => sum + (p.paidAmount ?? 0));
  double get totalPendingAmount => purchaseList.fold<double>(0, (sum, p) => sum + (p.pendingAmount ?? 0));
}