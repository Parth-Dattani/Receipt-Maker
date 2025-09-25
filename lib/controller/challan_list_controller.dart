
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/utils/pdf_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../model/model.dart';
import '../screen/screen.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import '../widgets/widgets.dart';
import 'controller.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChallanListController extends BaseController {
  final isLoading = false.obs;
  final challanList = <Challan>[].obs;
  final filteredChallanList = <Challan>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  var companyData = <String, dynamic>{}.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  void onInit() {
    super.onInit();
    loadChallans();
    loadCompanyData();
  }

  /// 🔹 Load challans from Google Sheets
  Future<void> loadChallans() async {
    try {
      isLoading.value = true;
      print("=== LOADING CHALLANS ===");

      List<Challan> challans = await GoogleSheetService.getChallansList();
      print("Challans fetched: ${challans.length}");
      if (challans.isEmpty) {
        print("No challans found, trying again...");
        challans = await GoogleSheetService.getChallansList();
      }

      challanList.assignAll(challans);
      filteredChallanList.assignAll(challans);

      print("✅ Loaded ${challans.length} challans");

      if (challans.isEmpty) {
        Get.snackbar(
          'No Challans',
          'No challans found in the system',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          icon: Icon(Icons.info_outline, color: Colors.orange.shade700),
        );
      }
    } catch (e) {
      print("❌ Error loading challans: $e");
      Get.snackbar(
        'Error',
        'Failed to load challans: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade700),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCompanyData() async {
    try {
      isLoading.value = true;
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
        print("Company data loaded: ${companyData.value}");
      }
    } catch (e) {
      print("Error loading company data: $e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Refresh challans
  void refreshChallans() async {
    await loadChallans();
  }

  /// 🔹 Search challans by ID or customer name
  void filterChallans(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredChallanList.assignAll(challanList);
      return;
    }

    final filtered = challanList.where((challan) {
      return (challan.challanId?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (challan.customerName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    filteredChallanList.assignAll(filtered);
  }

  /// 🔹 Filter challans by status
  void filterByStatus(String status) {
    selectedFilter.value = status;

    if (status == 'All') {
      filteredChallanList.assignAll(challanList);
      return;
    }

    final filtered = challanList.where((challan) {
      return (challan.status?.toLowerCase() ?? '') == status.toLowerCase();
    }).toList();

    filteredChallanList.assignAll(filtered);
  }

  /// 🔹 Actions for each challan
  void viewChallanDetails(Challan challan) {
    Get.lazyPut<ChallanDetailsController>(() => ChallanDetailsController());
    Get.to(() => ChallanDetailsScreen(), arguments: challan);

    //Get.toNamed(ChallanDetailsScreen.pageId, arguments: challan);
  }

  void editChallan(Challan challan) {
    Get.toNamed('/edit-challan', arguments: challan);
  }

  Future<void> deleteChallan(Challan challan) async {
    final confirmed = await Get.dialog(
      AlertDialog(
        title: Text('Delete Challan?'),
        content: Text('Are you sure you want to delete challan ${challan.challanId}?'),
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

        // TODO: Add actual delete logic from Google Sheet
        challanList.remove(challan);
        filteredChallanList.remove(challan);

        Get.snackbar(
          'Deleted',
          'Challan ${challan.challanId} has been deleted',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete challan: ${e.toString()}',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// 🔹 Export challan as PDF --- Challan
  Future<void> exportChallanAsPdf(Challan challan) async {
    try {
      // Show loading indicator
      isLoading.value = true;

      // Fetch the challan items for this specific challan
      print("Fetching challan items for PDF: ${challan.challanId}");
      List<ChallanItem> fetchedChallanItems =
      await GoogleSheetService.getChallanItemsByChallanId(challan.challanId);

      print("Fettttttt----ITem======= :${fetchedChallanItems[0].gstAmount}");
      
      // ✅ Fix: Fallback itemName -> description if blank
      final cleanedItems = fetchedChallanItems.map((item) {
        final fixedName = (item.itemName != null && item.itemName.trim().isNotEmpty)
            ? item.itemName
            : (item.description ?? "Goods/Service");

        return ChallanItem(
          itemId: item.itemId,
          itemName: fixedName,
          description: item.description,
          quantity: item.quantity,
          price: item.price,
          customerId: '', totalPrice: item.totalPrice,
          gstRate: item.gstRate,
          gstAmount: item.gstAmount,
          amountWithGst: item.amountWithGst,
          challanDate: item.challanDate,
        );
      }).toList();

      print("Found ${cleanedItems.length} items for challan ${challan.challanId}");
      for (var item in cleanedItems) {
        print("PDF Item -> name: ${item.itemName}, desc: ${item.description}, qty: ${item.quantity}, price: ${item.price}-----GSt: ${item.gstAmount}---tot: ${item.totalPrice}");
      }

      print("--------=================-----------");
      print(cleanedItems, );
      // ✅ Calculate totals
      final subtotal = cleanedItems.fold<double>(0, (s, it) {
        final qty = (it.quantity ?? 0).toDouble();
        final rate = it.price ?? 0.0;
        return s + (qty * rate);
      });

      final gstTotal = cleanedItems.fold<double>(0, (s, it) {
        final qty = (it.quantity ?? 0).toDouble();
        final rate = it.price ?? 0.0;
        final base = qty * rate;
        return s + ((base * (it.gstRate ?? 0)) / 100);
      });


      final grandTotal = subtotal + gstTotal ;


      // Generate PDF with the complete challan data including items
      final pdfFile = await InvoiceHelper.generateDocument(
          isChallan:  true,
          challan:  challan,
          challanItems: cleanedItems,
          companyData : companyData.value,
       /* subtotal:subtotal,
        gstAmount: gstTotal,
        total: grandTotal,*/
      );

      // Share or open the file
      await Share.shareXFiles([XFile(pdfFile.path)], text: 'Challan - ${challan.challanId}');

      // Show success message
      Get.snackbar(
        'Success',
        'Challan exported as PDF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Show error message
      print("Error exporting Challan PDF: $e");
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Statistics
  int get totalChallans => challanList.length;
  int get deliveredChallans => challanList.where((c) => c.status?.toLowerCase() == 'delivered').length;
  int get pendingChallans => challanList.where((c) => c.status?.toLowerCase() == 'pending').length;
  int get inTransitChallans => challanList.where((c) => c.status?.toLowerCase() == 'in transit').length;
}
