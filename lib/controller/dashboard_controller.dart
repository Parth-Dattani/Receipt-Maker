
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/controller/bash_controller.dart';
import 'package:demo_prac_getx/screen/customer/customer_registration_screen.dart';
import 'package:demo_prac_getx/screen/item_screen.dart';
import 'package:demo_prac_getx/screen/setting/setting_screen.dart';
import 'package:excel/excel.dart' show Excel, Sheet, TextCellValue, IntCellValue, DoubleCellValue;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import '../constant/constant.dart';
import '../model/model.dart';
import '../screen/dashboard/widgets/revenue_chart_card.dart';
import '../screen/screen.dart';
import '../screen/setting/widgets/widgets.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import '../widgets/widgets.dart';
import 'controller.dart';
import 'package:path_provider/path_provider.dart';

// class DashboardController extends BaseController {
//   // Observable variables
//   var totalInvoices = 0.obs;
//   var paidInvoices = 0.obs;
//   var unpaidInvoices = 0.obs;
//   var overdueInvoices = 0.obs;
//   var draftInvoices = 0.obs;
//   var totalRevenue = 0.0.obs;
//   var pendingAmount = 0.0.obs;
//   var overdueAmount = 0.0.obs;
//
//   // Recent invoices list
//   var recentInvoices = <Invoice>[].obs;
//
//   // Chart data
//   var monthlyRevenue = <double>[].obs;
//   var invoiceStatusData = <ChartData>[].obs;
//
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadDashboardData();
//   }
//
//   void loadDashboardData() async {
//     try {
//       isLoading.value = true;
//
//       // Simulate API call
//       await Future.delayed(Duration(seconds: 1));
//
//       // Load dashboard statistics
//       totalInvoices.value = 156;
//       paidInvoices.value = 89;
//       unpaidInvoices.value = 45;
//       overdueInvoices.value = 12;
//       draftInvoices.value = 10;
//       totalRevenue.value = 125430.50;
//       pendingAmount.value = 34560.75;
//       overdueAmount.value = 8945.25;
//
//       // Load recent invoices
//       recentInvoices.value = [
//         Invoice(
//           invoiceId: 'INV-001',
//           customerName: 'John Doe',
//           price: 1500.0,
//           itemId: '', qty: 11,
//           mobile: '', itemName: '',
//           //status: 'Paid',
//           //date: DateTime.now().subtract(Duration(days: 1)),
//         ),
//         Invoice(
//           invoiceId: 'INV-002',
//           customerName: 'Johnaaa Doe',
//           price: 160.0,
//           itemId: '', qty: 1,
//           mobile: '', itemName: '',
//
//         ),
//       ];
//
//       // Load chart data
//       monthlyRevenue.value = [15000, 18500, 22000, 19500, 25000, 28000];
//       invoiceStatusData.value = [
//         ChartData('Paid', paidInvoices.value.toDouble(), Colors.green),
//         ChartData('Pending', unpaidInvoices.value.toDouble(), Colors.orange),
//         ChartData('Overdue', overdueInvoices.value.toDouble(), Colors.red),
//         ChartData('Draft', draftInvoices.value.toDouble(), Colors.grey),
//       ];
//
//     } catch (error) {
//       Get.snackbar(
//         'Error',
//         'Failed to load dashboard data: ${error.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//
//   void refreshDashboard() {
//     loadDashboardData();
//   }
//
//   void navigateToCreateInvoice() {
//     Get.toNamed(ItemScreen.pageId);
//   }
//
//   void navigateToInvoiceList() {
//     Get.toNamed(ItemScreen.pageId);
//   }
//
//   void navigateToCustomers() {
//     Get.toNamed(CustomerRegistrationScreen.pageId);
//   }
//
//   void navigateToReports() {
//     Get.toNamed(ItemScreen.pageId);
//   }
//
//   void navigateToSettings() {
//     Get.to(
//           () => TemplatePreviewScreen(templateId: 2),
//       transition: Transition.rightToLeft,
//       duration: Duration(milliseconds: 300),
//     );
//     //Get.toNamed(SettingsScreen.pageId);
//   }
//
//   void viewInvoiceDetails(String invoiceId) {
//     Get.toNamed('/invoice-details/$invoiceId');
//   }
// }
//
// class ChartData {
//   final String label;
//   final double value;
//   final Color color;
//
//   ChartData(this.label, this.value, this.color);
// }

class DashboardController extends BaseController {
  // Observable variables
  var monthlyRevenueData = <RevenueData>[].obs;
  var totalInvoices = 0.obs;
  var paidInvoices = 0.obs;
  var unpaidInvoices = 0.obs;
  var overdueInvoices = 0.obs;
  var draftInvoices = 0.obs;
  var totalRevenue = 0.0.obs;
  var pendingAmount = 0.0.obs;
  var overdueAmount = 0.0.obs;
  // Add customer count observable
  var customerCount = 0.obs;

  var pendingCount = 0.obs;
  var paidCount = 0.obs;
  var overdueCount = 0.obs;

  // Recent invoices list
  var recentInvoices = <Invoice>[].obs;

  // Chart data
  var monthlyRevenue = <double>[].obs;
  var invoiceStatusData = <ChartData>[].obs;

  // Company data
  var currentCompany = Rxn<Map<String, dynamic>>();
  var companyId = ''.obs;
  var allUserCompanies = <Map<String, dynamic>>[].obs; // Store all companies
  var hasMultipleCompanies = false.obs; // Track if user has multiple companies
  var invoiceList = <Invoice>[].obs;
  var companyData = <String, dynamic>{}.obs;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInitializing = true;

  @override
  void onInit() {
    super.onInit();
    _initializeDashboard();
    // Auto-calculate whenever invoices change
    // 🔹 FIXED: Only recalculate when NOT initializing
    ever(invoiceList, (_) {
      if (!_isInitializing) {
        calculateStats();
      }
    });
    ///loadChallanPreference();
  }

  Future<void> _initializeDashboard() async {
    try {
      _isInitializing = true;
      // Step 1: Load company first (await!)
      await _loadCompanyData();

      await loadCompanySettings();

      /// Step 2: Now load dashboard data
      await loadDashboardData();
    } catch (e) {
      print("Error initializing dashboard: $e");
    }finally {
      _isInitializing = false;
    }
  }

  // Add this method to save the challan preference to SharedPreferences
  Future<void> saveChallanPreference(bool isEnabled) async {
   print("Is Enable Valure : --------- ${isEnabled}");

    try {
      // await sharedPreferencesHelper.storeBoolPrefData('isChallanEnabled', isEnabled);
      // AppConstants.isChallan.value = isEnabled;

      await updateCompanyPreference('isChallanEnabled', isEnabled);

      /// Also update in Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && companyId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('companies')
            .doc(companyId.toString())
            .update({'isChallanEnabled': isEnabled});
      }

      print('Challan preference saved: $isEnabled');
    } catch (e) {
      print('Error saving challan preference to SharedPreferences: $e');
    }
  }




  Future<void> updateCompanyPreference(String key, bool value) async {
    // Update local cache
    await sharedPreferencesHelper.storeBoolPrefData(key, value);

    // Update local observable
    if (key == 'isChallanEnabled') AppConstants.isChallan.value = value;
    if (key == 'isGstEnabled') AppConstants.withGST.value = value;

    // Update Firestore
    final user = _auth.currentUser;
    if (user != null && companyId.value.isNotEmpty) {  // ✅ use companyId.value
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId.value) // ✅ not AppConstants.companyId
          .update({key: value});
    }

    print("✅ Company Preference Updated → $key = $value "
        "(Local: ${AppConstants.isChallan.value}, GST: ${AppConstants.withGST.value})");
  }



  Future<void> checkSubscriptionStatus() async {
    // Get user creation date from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (userDoc.exists) {
      final createdAt = userDoc.data()?['createdAt'] as Timestamp?;
      if (createdAt != null) {
        final accountCreationDate = createdAt.toDate();
        final trialEndDate = accountCreationDate.add(Duration(days: 30));
        final now = DateTime.now();

        // Show dialog if trial has ended
        if (now.isAfter(trialEndDate)) {
          // Use a small delay to ensure widget is fully built
          Future.delayed(Duration(milliseconds: 500), () {
            showDialog(
              context: Get.context!,
              barrierDismissible: false, // This prevents tapping outside to dismiss
              builder: (BuildContext context) {
                return SubscriptionDialog();
              },
            );
          });
        }
      }
    }
  }

  // Load all companies and set current company
  Future<void> _loadAllCompaniesAndSetCurrent() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Load all user companies
      final companiesSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .where('isActive', isEqualTo: true)
          .get();

      allUserCompanies.clear();
      for (var doc in companiesSnapshot.docs) {
        final companyData = doc.data();
        companyData['id'] = doc.id;
        allUserCompanies.add(companyData);
      }

      hasMultipleCompanies.value = allUserCompanies.length > 1;

      // Try to get current company from SharedPreferences
      String savedCompanyId = await sharedPreferencesHelper.getPrefData("CompanyId").toString();

      if (savedCompanyId.isNotEmpty) {
        // Find saved company in the list
        final savedCompany = allUserCompanies.firstWhereOrNull(
                (company) => company['id'] == savedCompanyId
        );

        if (savedCompany != null) {
          _setCurrentCompany(savedCompany);

        } else if (allUserCompanies.isNotEmpty) {
          // Saved company not found, use first available
          _setCurrentCompany(allUserCompanies.first);
        }
      } else if (allUserCompanies.isNotEmpty) {
        // No saved company, use first available
        _setCurrentCompany(allUserCompanies.first);
      }

      // Load dashboard data after setting company
      if (companyId.value.isNotEmpty) {
        loadDashboardData();
      }

    } catch (e) {
      print("Error loading companies: $e");
    }
  }

  // Set current company and save to preferences
  void _setCurrentCompany(Map<String, dynamic> company) {
    currentCompany.value = company;
    companyId.value = company['id'];

    // Save to SharedPreferences
    sharedPreferencesHelper.storePrefData("CompanyId" , company['id']);
    AppConstants.companyId = company['id'];

    print("Current company set: ${company['companyName']} (${company['id']})");
  }


  // 🔹 REMOVED: Redundant _loadDashboardStatistics()
  // All stats now come from invoiceList via calculateStats()

  Future<void> loadCompanySettings() async {
    try {
      final user = _auth.currentUser;
      if (user == null || companyId.value.isEmpty) return;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId.value)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final isChallanEnabled = data['isChallanEnabled'] ?? false;
          final isGstEnabled = data['isGstEnabled'] ?? false;

          await sharedPreferencesHelper.storeBoolPrefData('isChallanEnabled', isChallanEnabled);
          await sharedPreferencesHelper.storeBoolPrefData('isGstEnabled', isGstEnabled);

          AppConstants.isChallan.value = isChallanEnabled;
          AppConstants.withGST.value = isGstEnabled;
        }
      }
    } catch (e) {
      print('Error loading company settings: $e');
    }
  }

  Future<void> _loadCompanyData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final companyDocs = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (companyDocs.docs.isNotEmpty) {
        final doc = companyDocs.docs.first;
        final data = doc.data();

        currentCompany.value = data;
        currentCompany.value!['id'] = doc.id;
        companyId.value = doc.id;

        AppConstants.companyId = companyId.value;
        await sharedPreferencesHelper.storePrefData("CompanyId", doc.id);

        print("Active company loaded: ${data['companyName'] ?? 'Unknown'}");
      }
    } catch (e) {
      print("Error loading active company: $e");
    }
  }


  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // 🔹 FIXED: Load invoices FIRST, then calculate everything once
      await loadInvoices();

      // 🔹 Now load other data in parallel (no invoice dependencies)
      await Future.wait([
        loadCustomerCount(),
        getMonthlyRevenueData(),
      ]);

    } catch (error) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInvoices() async {
    try {
      print("=== ATTEMPTING TO FETCH INVOICES ===");

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        showCustomSnackbar(
          title: "Error",
          message: "User not logged in",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
        return;
      }

      List<Invoice> invoices = [];

      // Try Google Sheets first
      try {
        invoices = await GoogleSheetService.getInvoices();
      } catch (e) {
        print("Google Sheets failed: $e");
        invoices = await GoogleSheetService.getInvoices();
      }

      // Filter by user
      List<Invoice> userInvoices = invoices
          .where((invoice) => invoice.userId == currentUserId)
          .toList();

      if (userInvoices.isEmpty) {
        invoiceList.clear();
        totalRevenue.value = 0.0;
        _clearStats();
        return;
      }

      // 🔹 FIXED: Update list once, calculate stats once
      invoiceList.assignAll(userInvoices);

      // 🔹 Calculate everything in one pass (not during initialization trigger)
      if (!_isInitializing) {
        calculateStats();
      } else {
        // During init, calculate manually without triggering observers
        _calculateStatsInternal();
      }

    } catch (e) {
      print("Error in loadInvoices(): $e");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to load invoices: ${e.toString()}",
        baseColor: Colors.red.shade700,
        icon: Icons.error_outline,
      );
    }
  }



  void _clearStats() {
    paidCount.value = 0;
    pendingCount.value = 0;
    overdueCount.value = 0;
    totalRevenue.value = 0.0;
    pendingAmount.value = 0.0;
    overdueAmount.value = 0.0;
    invoiceStatusData.clear();
  }

  // 🔹 NEW: Internal stats calculation (doesn't trigger reactive updates)
  void _calculateStatsInternal() {
    int paidCnt = 0;
    int pendingCnt = 0;
    int overdueCnt = 0;

    double totalRev = 0.0;
    double pendingAmt = 0.0;
    double overdueAmt = 0.0;

    for (var invoice in invoiceList) {
      final status = invoice.status?.toLowerCase().trim();
      final amount = invoice.totalAmount ?? 0.0;

      totalRev += amount;

      if (status == "paid") {
        paidCnt++;
      } else if (status == "pending") {
        pendingCnt++;
        pendingAmt += amount;
      } else if (status == "overdue") {
        overdueCnt++;
        overdueAmt += amount;
      }
    }

    // 🔹 Batch update all observables at once
    paidCount.value = paidCnt;
    pendingCount.value = pendingCnt;
    overdueCount.value = overdueCnt;
    totalRevenue.value = totalRev;
    pendingAmount.value = pendingAmt;
    overdueAmount.value = overdueAmt;

    invoiceStatusData.assignAll([
      ChartData("Paid", paidCnt.toDouble(), Colors.green),
      ChartData("Pending", pendingCnt.toDouble(), Colors.orange),
      ChartData("Overdue", overdueCnt.toDouble(), Colors.red),
    ]);
  }

  double calculateTotalRevenue() {
    double total = 0.0;
    for (var invoice in invoiceList) {
      total += invoice.totalAmount ?? 0.0;
    }
    return total;
  }

  void calculateStats() {
    _calculateStatsInternal();
  }


  double calculatePendingAmount() {
    double total = 0.0;
    for (var invoice in invoiceList) {
      if (invoice.status?.toLowerCase() == "pending" ||
          invoice.status?.toLowerCase() == "unpaid") {
        total += invoice.totalAmount ?? 0.0;
      }
    }
    pendingAmount.value = total; // update observable
    return total;
  }

  double calculatePaidAmount() {
    double total = 0.0;
    for (var invoice in invoiceList) {
      if (invoice.status?.toLowerCase() == "paid") {
        total += invoice.totalAmount ?? 0.0;
      }
    }
    return total;
  }

  double calculateOverdueAmount() {
    double total = 0.0;
    for (var invoice in invoiceList) {
      if (invoice.status?.toLowerCase() == "overdue") {
        total += invoice.totalAmount ?? 0.0;
      }
    }
    overdueAmount.value = total;
    return total;
  }


// You can also add a reactive getter
  double get totalRevenueFromList => calculateTotalRevenue();

  // Switch to a different company
  Future<void> switchCompany(Map<String, dynamic> newCompany) async {
    try {
      isLoading.value = true;

      // Set new current company
      _setCurrentCompany(newCompany);

      // Reload dashboard data for new company
       loadDashboardData();


      showCustomSnackbar(
        title: "Company Switched",
        message: "Switched to ${newCompany['companyName']}",
        baseColor: AppColors.greenColor2,
        icon: Icons.business,
      );

    } catch (e) {
      print("Error switching company: $e");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to switch company",
        baseColor: AppColors.errorColor,
        icon: Icons.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Show company selection dialog
  void showCompanySwitcher() {
    if (!hasMultipleCompanies.value) {
      showCustomSnackbar(
        title: "Info",
        message: "You only have one company registered",
        baseColor: AppColors.appColor,
        icon: Icons.info,
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.swap_horiz, color: Colors.blue.shade700, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Switch Company",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Company list
              Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: allUserCompanies.map((company) {
                      final isCurrentCompany = company['id'] == companyId.value;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: isCurrentCompany ? null : () {
                            Get.back();
                            switchCompany(company);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCurrentCompany
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrentCompany
                                    ? Colors.blue.shade300
                                    : Colors.grey.shade300,
                                width: isCurrentCompany ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCurrentCompany
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.business,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        company['companyName'] ?? 'Unknown Company',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isCurrentCompany
                                              ? Colors.blue.shade700
                                              : Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        company['companyCode'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrentCompany)
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Add new company button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(CompanyRegistrationScreen.pageId);
                  },
                  icon: Icon(Icons.add_business),
                  label: Text("Add New Company"),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.blue.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }


  // Load actual dashboard statistics from Firebase
  Future<void> _loadDashboardStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null || companyId.value.isEmpty) {
        // Use mock data if no company
        _loadMockData();
        return;
      }

      // Load actual invoices from Firebase
      final invoicesSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId.value)
          .collection("invoices")
          .get();

      // Calculate statistics from actual data
      int totalCount = invoicesSnapshot.docs.length;
      int paidCount = 0;
      int unpaidCount = 0;
      int overdueCount = 0;
      int draftCount = 0;
      double totalRev = 0.0;
      double pendingAmt = 0.0;
      double overdueAmt = 0.0;

      List<Invoice> recentInvoicesList = [];

      for (var doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'draft';
        final amount = (data['totalAmount'] ?? 0.0).toDouble();

        // Add to total revenue regardless of status
        totalRev += amount;

        switch (status.toLowerCase()) {
          case 'paid':
            paidCount++;
            //totalRev += amount;
            break;
          case 'pending':
          case 'unpaid':
            unpaidCount++;
            pendingAmt += amount;
            break;
          case 'overdue':
            overdueCount++;
            overdueAmt += amount;
            break;
          case 'draft':
            draftCount++;
            break;
        }

        // Add to recent invoices (limit to 10)
        if (recentInvoicesList.length < 10) {
          recentInvoicesList.add(Invoice(
            invoiceId: data['invoiceId'] ?? doc.id,
            customerName: data['customerName'] ?? 'Unknown',
            price: amount,
            itemId: data['itemId'] ?? '',
            qty: data['qty'] ?? 1,
            mobile: data['customerMobile'] ?? '',
            itemName: data['itemName'] ?? '',
            totalAmount: amount,
          ));
        }
      }

      // Update observable variables
      totalInvoices.value = totalCount;
      paidInvoices.value = paidCount;
      unpaidInvoices.value = unpaidCount;
      overdueInvoices.value = overdueCount;
      draftInvoices.value = draftCount;
      totalRevenue.value = totalRev;
      pendingAmount.value = pendingAmt;
      overdueAmount.value = overdueAmt;
      recentInvoices.value = recentInvoicesList;

      // Update chart data
      invoiceStatusData.value = [
        ChartData('Paid', paidCount.toDouble(), Colors.green),
        ChartData('Pending', unpaidCount.toDouble(), Colors.orange),
        ChartData('Overdue', overdueCount.toDouble(), Colors.red),
        ChartData('Draft', draftCount.toDouble(), Colors.grey),
      ];

      // Mock monthly revenue for now (you can implement actual monthly calculation)
      monthlyRevenue.value = [15000, 18500, 22000, 19500, 25000, totalRev];

    } catch (e) {
      print("Error loading dashboard statistics: $e");
      _loadMockData(); // Fallback to mock data
    }
  }

  // Fallback mock data
  void _loadMockData() {
    totalInvoices.value = 0;
    paidInvoices.value = 0;
    unpaidInvoices.value = 0;
    overdueInvoices.value = 0;
    draftInvoices.value = 0;
    totalRevenue.value = 0.0;
    pendingAmount.value = 0.0;
    overdueAmount.value = 0.0;

    recentInvoices.value = [
      Invoice(
        invoiceId: 'INV-001',
        customerName: 'John Doe',
        price: 1500.0,
        itemId: '',
        qty: 11,
        mobile: '',
        itemName: '',
      ),
      Invoice(
        invoiceId: 'INV-002',
        customerName: 'Jane Smith',
        price: 160.0,
        itemId: '',
        qty: 1,
        mobile: '',
        itemName: '',
      ),
    ];

    monthlyRevenue.value = [15000, 18500, 22000, 19500, 25000, 28000];
    invoiceStatusData.value = [
      ChartData('Paid', paidInvoices.value.toDouble(), Colors.green),
      ChartData('Pending', unpaidInvoices.value.toDouble(), Colors.orange),
      ChartData('Overdue', overdueInvoices.value.toDouble(), Colors.red),
      ChartData('Draft', draftInvoices.value.toDouble(), Colors.grey),
    ];
  }

  // 🔹 FIXED: refreshDashboard now properly reloads
  void refreshDashboard() async {
    _isInitializing = true;
    await _loadCompanyData();
    await loadDashboardData();
    _isInitializing = false;
  }
  ///working
  void navigateToCreateInvoice() {
    print("Compny--------:${companyId.value}");
    if (companyId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please register a company first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.toNamed(CompanyRegistrationScreen.pageId);
      return;
    }
    Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());

    Get.to(() => NewInvoiceScreen());
    //Get.toNamed(NewInvoiceScreen.pageId);
  }

  void navigateToCreateInvoice22() {
    print("Company--------:${companyId.value}");
    if (companyId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please register a company first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Get.toNamed(CompanyRegistrationScreen.pageId);
      return;
    }
    // Show the preview dialog before navigating
    showInvoiceOptions();
  }

  void showInvoiceOptions() {
    Get.dialog(
      InvoicePreviewScreen(
        // onOptionSelected: (option) {
        //   Get.back(); // Close the dialog
        //   Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());
        //   //Get.to(() => NewInvoiceScreen(pdfOption: option));
        // },
      ),
    );
  }

  void navigateToInvoiceList() {
    Get.lazyPut<InvoiceListController>(() => InvoiceListController());
    Get.to(InvoiceListScreen());
  }

  // Updated method to navigate to customer registration with company selection
  void navigateToCustomers() {
    // Always show company selection screen
    Get.toNamed(CompanySelectionScreen.pageId);
  }

  /// New method specifically for adding a new customer
  // void navigateToAddNewCustomer() {
  //   // Always show company selection first
  //   Get.toNamed(CompanySelectionScreen.pageId);
  // }

  // Updated method for adding new customer
  void navigateToAddNewCustomer() {
    if (companyId.value.isEmpty) {
      Get.snackbar(
        'Company Required',
        'Please register a company first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Get.toNamed(CompanyRegistrationScreen.pageId);
      return;
    }

    // Navigate directly to company selection or customer registration
    Get.toNamed(CompanySelectionScreen.pageId);
  }

  // Updated method to get customer count and load it in dashboard
  Future<void> loadCustomerCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null || companyId.value.isEmpty) {
        customerCount.value = 0;
        return;
      }

      final customersSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId.value)
          .collection("customers")
          .where('isActive', isEqualTo: true)
          .get();

      customerCount.value = customersSnapshot.docs.length;
    } catch (e) {
      print("Error getting customer count: $e");
      customerCount.value = 0;
    }
  }

  // Updated method to navigate to customer list
  void navigateToCustomerList() {
    if (companyId.value.isEmpty) {
      print("companyId.value: ${companyId.value}");
      Get.snackbar(
        'Company Required',
        'Please register a company first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Get.toNamed(CompanyRegistrationScreen.pageId);
      return;
    }

    print("Navigating to Customer List Screen");

    // Try direct navigation first
    try {
      // Make sure the controller is initialized
      if (!Get.isRegistered<CustomerListController>()) {
        Get.put(CustomerListController());
      }

      // Navigate to the screen
      Get.to(() => const CustomerListScreen());
    } catch (e) {
      print("Error navigating to customer list: $e");
      // Fallback - show a simple dialog with customer count
      _showSimpleCustomerDialog();
    }
  }

  // 3. Add this fallback method to your DashboardController:
  void _showSimpleCustomerDialog() async {
    // Load customer count first
    await loadCustomerCount();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.people, color: Colors.orange.shade700, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Customer Count Display
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.orange.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people,
                      size: 40,
                      color: Colors.orange.shade700,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Total Customers',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Obx(() => Text(
                      '${customerCount.value}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    )),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Add New Customer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back(); // Close dialog
                    navigateToAddNewCustomer();
                  },
                  icon: Icon(Icons.person_add),
                  label: Text('Add New Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              // View All Customers Button (if you want to try navigation again)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back(); // Close dialog
                    // Try to navigate to full customer list
                    Get.to(() => const CustomerListScreen());
                  },
                  icon: Icon(Icons.list),
                  label: Text('View All Customers'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                    side: BorderSide(color: Colors.orange.shade700),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToItems() {
    Get.toNamed(ItemScreen.pageId);
  }

  void navigateToChallanList() {
    if (!Get.isRegistered<ChallanListController>()) {
      Get.put(ChallanListController());
    }
    Get.to(() => ChallanListScreen());
  }


  void navigateToNewChallan() {
    Get.lazyPut<NewChallanController>(() => NewChallanController());

    Get.to(() => NewChallanScreen(),);
    // Get.to(
    //       () => NewChallanScreen(),
    //   transition: Transition.rightToLeft,
    //   duration: Duration(milliseconds: 300),
    // );
  }

  // Example of navigating to edit mode from a company list screen
  void navigateToEditCompany(Map<String, dynamic> companyData, String companyId) {
    Get.toNamed(
      CompanyRegistrationScreen.pageId,
      arguments: {
        'isEdit': true,
        'companyData': companyData,
        'companyId': companyId,
      },
    );
  }





  Future<void> exportInvoiceData() async {
    final invoices = await GoogleSheetService.getInvoices(type: "INV");

    if (invoices.isEmpty) {
      print("⚠️ No invoices found to export");
      return;
    }

    // Create Excel workbook
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Invoices'];

    // Add header row
    sheetObject.appendRow([
      TextCellValue('Invoice ID'),
      TextCellValue('Customer ID'),
      TextCellValue('Customer Name'),
      TextCellValue('Mobile'),
      TextCellValue("total Amount"), // placeholder, will be overwritten per-row
      TextCellValue('Customer Email'),
      TextCellValue('Customer Address'),
      TextCellValue('Issue Date'),
      TextCellValue("subtotal"), // subtotal
      TextCellValue("gstRate"), // gstRate
      TextCellValue("gstAmount"), // gstAmount
      TextCellValue('Notes'),
      TextCellValue('Status'),
      TextCellValue('User ID'),
    ]);

    // Add invoice rows
    for (var inv in invoices) {
      sheetObject.appendRow([
        TextCellValue(inv.invoiceId),
        TextCellValue(inv.customerId),
        TextCellValue(inv.customerName),
        TextCellValue(inv.mobile),
        DoubleCellValue(inv.totalAmount ?? 0.0),
        TextCellValue(inv.customerEmail ?? ""),
        TextCellValue(inv.customerAddress ?? ""),
        TextCellValue(inv.issueDate != null ? inv.issueDate!.toIso8601String().split("T").first : ""),
        DoubleCellValue(inv.subtotal ?? 0.0),
        DoubleCellValue(inv.gstRate ?? 0.0),
        DoubleCellValue(inv.gstAmount ?? 0.0),
        TextCellValue(inv.notes ?? ""),
        TextCellValue(inv.status ?? ""),
        TextCellValue(inv.userId ?? ""),
      ]);
    }

    // Save file
    final dir = await getApplicationDocumentsDirectory();
    String outputFile = "${dir.path}/Invoices_FullExport.xlsx";
    File(outputFile)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    print("✅ Invoice data exported to $outputFile");
    // After saving
    OpenFile.open(outputFile);
  }

  void viewInvoiceDetails(String invoiceId) {
    Get.toNamed('/invoice-details/$invoiceId');
  }

  // Method to get customer count for dashboard display
  Future<int> getCustomerCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null || companyId.value.isEmpty) return 0;

      final customersSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId.value)
          .collection("customers")
          .where('isActive', isEqualTo: true)
          .get();

      return customersSnapshot.docs.length;
    } catch (e) {
      print("Error getting customer count: $e");
      return 0;
    }
  }

  // Method to check if company is registered
  bool get isCompanyRegistered => companyId.value.isNotEmpty;

  // Method to get company name for display
  String get companyName => currentCompany.value?['companyName'] ?? 'No Company';

  Future<void> logout() async {
    try {
      // 🔹 Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // 🔹 Clear SharedPreferences
      await sharedPreferencesHelper.clearPrefData();

      // 🔹 Reset AppConstants
      AppConstants.userId = "";
      AppConstants.companyId = "";
      AppConstants.appId = "";
      AppConstants.spreadsheetId = "";
      AppConstants.accessKey = "";
      AppConstants.isChallan.value = false;
      AppConstants.withGST.value = false;

      // 🔹 (Optional) Clear any controller states if needed
      Get.deleteAll(force: true); // removes all GetX controllers

      // 🔹 Navigate back to Auth screen
      Get.offAllNamed(AuthScreen.pageId);

      print("✅ Logout completed. State cleared.");
    } catch (e) {
      print("❌ Logout failed: $e");
      Get.snackbar("Error", "Logout failed, please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  final List<RevenueData> revenueData = [
    RevenueData(month: 'Jan',year: 2025, revenue: 5000),
    RevenueData(month: 'Feb',year: 2025, revenue: 7500),
    RevenueData(month: 'Mar', year: 2025,revenue: 10000),
    RevenueData(month: 'Apr',year: 2025, revenue: 8200),

  ];


  // Add this method to generate revenue data dynamically
  /// Method to generate month-based revenue data

  Future<List<RevenueData>> getMonthlyRevenueData({
    int monthsBack = 12,
    String? statusFilter,
    bool includeCurrentMonth = true,
  }) async {
    try {
      if (invoiceList.isEmpty) return [];

      final now = DateTime.now();
      final List<RevenueData> result = [];

      int startMonth = includeCurrentMonth ? monthsBack - 1 : monthsBack;

      for (int i = startMonth; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthName = DateFormat('MMM yyyy').format(monthDate);
        final year = monthDate.year;

        double monthlyTotal = 0;
        for (var invoice in invoiceList) {
          final isSameMonth = invoice.issueDate != null &&
              invoice.issueDate!.year == monthDate.year &&
              invoice.issueDate!.month == monthDate.month;

          final matchesStatus = statusFilter == null ||
              (invoice.status?.toLowerCase() == statusFilter.toLowerCase());

          if (isSameMonth && matchesStatus) {
            monthlyTotal += invoice.totalAmount ?? 0;
          }
        }

        result.add(RevenueData(
          month: monthName,
          revenue: monthlyTotal,
          year: year,
        ));
      }

      monthlyRevenueData.assignAll(result);
      return result;

    } catch (e) {
      print("Error in getMonthlyRevenueData: $e");
      return [];
    }
  }


  // Get total revenue for current month
  double get currentMonthRevenue {
    if (monthlyRevenueData.isEmpty) return 0;
    return monthlyRevenueData.last.revenue;
  }

// Get revenue growth compared to previous month
  double get monthlyGrowth {
    if (monthlyRevenueData.length < 2) return 0;

    final current = monthlyRevenueData.last.revenue;
    final previous = monthlyRevenueData[monthlyRevenueData.length - 2].revenue;

    if (previous == 0) return current > 0 ? 100 : 0;

    return ((current - previous) / previous * 100);
  }

// Get best performing month
  RevenueData? get bestPerformingMonth {
    if (monthlyRevenueData.isEmpty) return null;

    return monthlyRevenueData.reduce((a, b) =>
    a.revenue > b.revenue ? a : b
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}




class InvoicePreviewScreen extends StatefulWidget {
  @override
  _InvoicePreviewScreenState createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  PdfOption _selectedOption = PdfOption.standard;

  Widget _buildStandardInvoicePreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Standard Invoice Preview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          // In a real app, you would use: Image.asset("assets/images/inv_1.png")
          // For this example, I'm creating a placeholder
          Container(
            width: 300,
            height: 400,
            color: Colors.grey.shade100,
            child: Image.asset("assets/images/inv_2.png"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInvoicePreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Detailed Invoice Preview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          // In a real app, you would use: Image.asset("assets/images/inv_3.png")
          // For this example, I'm creating a placeholder
          Container(
            width: 300,
            height: 400,
            color: Colors.grey.shade100,
            child: Image.asset("assets/images/inv_3.png"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Preview'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Invoice Type:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<PdfOption>(
                    title: Text('Standard Invoice'),
                    value: PdfOption.standard,
                    groupValue: _selectedOption,
                    onChanged: (PdfOption? value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<PdfOption>(
                    title: Text('Detailed Invoice'),
                    value: PdfOption.detailed,
                    groupValue: _selectedOption,
                    onChanged: (PdfOption? value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Center(
              child: _selectedOption == PdfOption.standard
                  ? _buildStandardInvoicePreview()
                  : _buildDetailedInvoicePreview(),
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                'Note: Make sure to add your images to the assets/images folder\nand update the pubspec.yaml file accordingly.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PdfOption { standard, detailed }
