import 'dart:async';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/controller/bash_controller.dart';
import 'package:demo_prac_getx/screen/Inventory/inventory_management_screen.dart';
import 'package:demo_prac_getx/screen/customer/customer_registration_screen.dart';
import 'package:demo_prac_getx/screen/item_screen.dart';
import 'package:demo_prac_getx/screen/payment/payment_details_screen.dart';
import 'package:demo_prac_getx/screen/setting/setting_screen.dart';
import 'package:excel/excel.dart' show Excel, Sheet, TextCellValue, IntCellValue, DoubleCellValue;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' show Font;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../constant/constant.dart';
import '../model/model.dart';
import '../screen/dashboard/widgets/revenue_chart_card.dart';
import '../screen/screen.dart';
import '../screen/setting/widgets/widgets.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'controller.dart';
import 'package:path_provider/path_provider.dart';

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
  var customerCount = 0.obs;

  var pendingCount = 0.obs;
  var paidCount = 0.obs;
  var overdueCount = 0.obs;

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

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInitializing = true;
  bool _hasInitialized = false;

  // Method to check if company is registered
  bool get isCompanyRegistered => companyId.value.isNotEmpty;

  // Method to get company name for display
  String get companyName => currentCompany.value?['companyName'] ?? 'No Company';

// Purchase data observables
  var totalPurchases = 0.obs;
  var paidPurchases = 0.obs;
  var pendingPurchases = 0.obs;
  var totalPurchaseAmount = 0.0.obs;
  var pendingPurchaseAmount = 0.0.obs;
  var purchaseList = <PurchaseEntry>[].obs;
  var overduePurchases = 0.obs;
  var overduePurchaseAmount = 0.0.obs;
  var appVersion = '1.0.0'.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  StreamSubscription<DocumentSnapshot>? _subscriptionListener;
  var todayCashAmount = 0.0.obs;
  var todayCashInvoices = 0.obs;
  var todayUpiAmount = 0.0.obs;
  var todayUpiInvoices = 0.obs;
  var todayCardAmount = 0.0.obs;
  var todayCardInvoices = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // 🔹 Initialize chart data with zeros
    invoiceStatusData.assignAll([
      ChartData("Paid", 0.0, Colors.green),
      ChartData("Pending", 0.0, Colors.orange),
      ChartData("Overdue", 0.0, Colors.red),
    ]);

    // 2️⃣ Start the Real-time Listener immediately
    checkSubscriptionStatus();

    _initializeDashboard();
    _loadAppVersion();
    // 🔹 FIXED: Only recalculate when NOT initializing
    ever(invoiceList, (_) {
      if (!_isInitializing && _hasInitialized) {
        calculateStats();
      }
    });
    ///loadChallanPreference();
    _startOverdueChecker();
    _setupLifecycleObserver();
  }

// ✅ NEW: Add lifecycle observer
  void _setupLifecycleObserver() {
    WidgetsBinding.instance.addObserver(
      _DashboardLifecycleObserver(
        onResumed: () {
          if (_hasInitialized) {
            print("🔄 App resumed, refreshing dashboard...");
            refreshDashboard();
          }
        },
      ),
    );
  }

  Future<void> _initializeDashboard() async {
    // 🆕 Prevent multiple initializations
    if (_hasInitialized) {
      print("⚠️ Dashboard already initialized, skipping...");
      return;
    }


    try {
      _isInitializing = true;
      isLoading.value = true;
      print("🔄 Starting dashboard initialization...");
      await _loadUserData();
      // Step 1: Load company first (await!)
      await _loadCompanyData();

      await loadCompanySettings();

      /// Step 2: Now load dashboard data
      await loadDashboardData();

      _hasInitialized = true;
      print("✅ Dashboard initialization complete");
    } catch (e) {
      print("❌ Error initializing dashboard: $e");
      _hasInitialized = false;
    }finally {
      _isInitializing = false;
      isLoading.value = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userEmail.value = user.email ?? '';

        // Try to get user name from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          userName.value = data?['username'] ?? data?['displayName'] ??
              user.displayName ??
              user.email!.split('@').first;
        } else {
          userName.value = user.displayName ?? user.email!.split('@').first;
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      final user = FirebaseAuth.instance.currentUser;
      userName.value = user?.displayName ?? user?.email?.split('@').first ?? 'User';
      userEmail.value = user?.email ?? '';
    }
  }

  // Add this method to save the challan preference to SharedPreferences
  Future<void> saveChallanPreference(bool isEnabled) async {
    print("Is Enable Valure : --------- ${isEnabled}");

    try {
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

  void _startOverdueChecker() {
    // Check once immediately
    _updateOverdueInvoices();
    _updateOverduePurchases();

    // Then check every hour
    Timer.periodic(Duration(hours: 1), (timer) {
      _updateOverdueInvoices();
      _updateOverduePurchases(); // ← Add this line
    });
  }

  Future<void> _updateOverdueInvoices() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool hasChanges = false;

    for (var invoice in invoiceList) {
      final status = invoice.status?.toLowerCase().trim();

      // Check if pending invoice is now overdue
      if ((status == "pending" || status == "unpaid") && invoice.dueDate != null) {
        final dueDate = DateTime(
          invoice.dueDate!.year,
          invoice.dueDate!.month,
          invoice.dueDate!.day,
        );

        // 🔹 FIXED: Check if TODAY is AFTER due date (not before)
        if (today.isAfter(dueDate) && status != "overdue") {
          print("⚠️ Invoice ${invoice.invoiceId} is now overdue! "
              "Due: ${_formatDate(dueDate)}, Today: ${_formatDate(today)}");
          hasChanges = true;

        }
      }
    }

    if (hasChanges) {
      // Recalculate stats
      calculateStats();
    }
  }

  Future<void> _updateOverduePurchases() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool hasChanges = false;

    for (var purchase in purchaseList) {
      final status = purchase.paymentStatus?.toLowerCase().trim();

      // Check if pending purchase is now overdue
      if ((status == "pending" || status == "unpaid") && purchase.dueDate != null) {
        final dueDate = DateTime(
          purchase.dueDate!.year,
          purchase.dueDate!.month,
          purchase.dueDate!.day,
        );

        if (today.isAfter(dueDate) && status != "overdue") {
          print("⚠️ Purchase ${purchase.purchaseId ?? 'N/A'} is now overdue! "
              "Due: ${_formatDate(dueDate)}, Today: ${_formatDate(today)}");
          hasChanges = true;

        }
      }
    }

    if (hasChanges) {
      // Recalculate stats
      _calculatePurchaseStats();
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    print("🎧 Starting Real-time Subscription Listener...");

    _subscriptionListener = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {

      if (snapshot.exists) {
        final data = snapshot.data();
        // Get the endDate from Firestore
        final endDateTimestamp = data?['endDate'] as Timestamp?;

        if (endDateTimestamp != null) {
          final endDate = endDateTimestamp.toDate();
          final now = DateTime.now();

          print("🔄 Real-time Status Check: Now($now) vs EndDate($endDate)");

          // Check if subscription has EXPIRED
          if (now.isAfter(endDate)) {
            print("❌ Subscription EXPIRED. Locking App.");

            if (Get.isDialogOpen != true) {
              Get.dialog(
                WillPopScope(
                  onWillPop: () async => false,
                  child: const SubscriptionDialog(),
                ),
                barrierDismissible: false, // Prevents clicking outside to close
              );
            }
          } else {
            print("✅ Subscription ACTIVE.");

            if (Get.isDialogOpen == true) {
              Get.back(); // Close the blocking dialog
            }
          }
        } else {
          print("⚠️ No 'endDate' field found in user document.");
        }
      }
    }, onError: (e) {
      print("❌ Error in subscription listener: $e");
    });
  }


  // Set current company and save to preferences
  void _setCurrentCompany(Map<String, dynamic> company) {
    currentCompany.value = company;
    companyId.value = company['id'];

    sharedPreferencesHelper.storePrefData("CompanyId" , company['id']);
    AppConstants.companyId = company['id'];

    print("Current company set: ${company['companyName']} (${company['id']})");
  }

  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = '${packageInfo.version} (${packageInfo.buildNumber})';
      print("📱 App Version: ${appVersion.value}");
    } catch (e) {
      print('❌ Error loading package info: $e');
      appVersion.value = '1.0.0';
    }
  }

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

          final businessType = data['businessType'] ?? 'Trading';
          await AppConstants.setBusinessType(businessType);
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

        String fetchedName = data['companyName'] ?? '';
        if (fetchedName.isNotEmpty) {
          await AppConstants.setCompanyName(fetchedName);
        }

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
      // 🆕 Don't show loading spinner if already initialized
      if (!_hasInitialized) {
        isLoading.value = true;
      }

      print("🔄 Loading dashboard data...");


      // 🔹 FIXED: Load invoices FIRST, then calculate everything once
      await loadInvoices();

      await loadPurchases();

      // 🔹 Now load other data in parallel (no invoice dependencies)
      await Future.wait([
        loadCustomerCount(),
        getMonthlyRevenueData(),
      ]);

    } catch (error) {
      print("Failed to load dashboard data: ${error.toString()}");

    } finally {
      if (!_isInitializing) {
        isLoading.value = false;
      }
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
        invoices = await GoogleSheetService.getInvoices(type: "INV");
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
    }
  }

  Future<void> loadPurchases() async {
    try {
      print("=== ATTEMPTING TO FETCH PURCHASES ===");

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

      // Fetch purchases from Google Sheets
      List<PurchaseEntry> purchases = await GoogleSheetService.getPurchasesList();

      // Filter by user
      List<PurchaseEntry> userPurchases = purchases
          .where((purchase) => purchase.userId == currentUserId)
          .toList();

      if (userPurchases.isEmpty) {
       _clearPurchaseStats();
        return;
      }

      purchaseList.assignAll(userPurchases);

      // Calculate purchase stats

      _calculatePurchaseStats();


    } catch (e) {
      print("Error in loadPurchases(): $e");
    }
  }

  void _clearPurchaseStats() {
    totalPurchases.value = 0;
    paidPurchases.value = 0;
    pendingPurchases.value = 0;
    totalPurchaseAmount.value = 0.0;
    pendingPurchaseAmount.value = 0.0;
    overduePurchases.value = 0;
    overduePurchaseAmount.value = 0.0;

    print("🧹 Purchase stats cleared");
  }

  void _calculatePurchaseStats() {
    int totalCount = 0;
    int paidCount = 0;
    int pendingCount = 0;
    int overdueCount = 0;

    double totalAmount = 0.0;
    double pendingAmount = 0.0;
    double overdueAmount = 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    print("🔍 PURCHASE STATS DEBUG:");
    print("   Today: ${_formatDate(today)}");
    print("   Total purchases: ${purchaseList.length}");

    for (var purchase in purchaseList) {
      totalCount++;
      totalAmount += purchase.totalAmount ?? 0.0;

      final status = purchase.paymentStatus?.toLowerCase().trim();
      final amount = purchase.totalAmount ?? 0.0;
      final pendingAmt = purchase.pendingAmount ?? amount;

      print("\n📦 Processing: ${purchase.purchaseId} | Status: $status");
      print("   Due Date: ${_formatDate(purchase.dueDate)}");
      print("   Total Amount: ₹${amount.toStringAsFixed(2)}");
      print("   Pending Amount: ₹${pendingAmt.toStringAsFixed(2)}");

      if (status == "paid" || status == "completed") {
        paidCount++;
        print("   ✅ COUNTED AS PAID");
      }
      else {
        bool isOverdue = false;

        // Check if purchase has a due date and is overdue
        if (purchase.dueDate != null) {
          final dueDate = DateTime(
            purchase.dueDate!.year,
            purchase.dueDate!.month,
            purchase.dueDate!.day,
          );

          isOverdue = today.isAfter(dueDate);

          if (isOverdue) {
            overdueCount++;
            overdueAmount += pendingAmt;
            print("   🔴 COUNTED AS OVERDUE");
          } else {
            pendingCount++;
            pendingAmount += pendingAmt;
            print("   🟡 COUNTED AS PENDING (not overdue yet)");
          }
        } else {
          pendingCount++;
          pendingAmount += pendingAmt;
          print("   🟡 COUNTED AS PENDING (no due date)");
        }

        // because they are still pending payment, just overdue
        if (isOverdue) {
          pendingAmount += pendingAmt; // Add overdue amount to pending total
          print("   💰 ADDED OVERDUE AMOUNT TO PENDING: ₹${pendingAmt.toStringAsFixed(2)}");
        }
      }
    }

    // Update observables
    totalPurchases.value = totalCount;
    paidPurchases.value = paidCount;
    pendingPurchases.value = pendingCount;
    totalPurchaseAmount.value = totalAmount;
    pendingPurchaseAmount.value = pendingAmount;
    overduePurchases.value = overdueCount;
    overduePurchaseAmount.value = overdueAmount;

    print("\n✅ FINAL Purchase Stats:");
    print("   Total: $totalCount, Paid: $paidCount, Pending: $pendingCount, Overdue: $overdueCount");
    print("   💰 Total Amount: ₹${totalAmount.toStringAsFixed(2)}");
    print("   💰 Pending Amount: ₹${pendingAmount.toStringAsFixed(2)}");
    print("   💰 Overdue Amount: ₹${overdueAmount.toStringAsFixed(2)}");
  }

  void _calculateTodayPaymentMethods() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double cashTotal = 0.0;
    int cashCount = 0;

    double upiTotal = 0.0;
    int upiCount = 0;

    double cardTotal = 0.0;
    int cardCount = 0;

    print("🔍 Calculating Today's Payment Methods:");
    print("   Today: ${_formatDate(today)}");

    for (var invoice in invoiceList) {
      if (invoice.issueDate == null) continue;

      final invoiceDate = DateTime(
        invoice.issueDate!.year,
        invoice.issueDate!.month,
        invoice.issueDate!.day,
      );

      // Check if invoice is from today
      if (invoiceDate.isAtSameMomentAs(today)) {
        // Safe string handling: convert to lowercase and trim whitespace
        final paymentMode = (invoice.paymentMode ?? "").toLowerCase().trim();
        final amount = invoice.totalAmount ?? 0.0;

        // 1. CASH
        if (paymentMode == "cash") {
          cashTotal += amount;
          cashCount++;
          print("   💵 Cash Invoice: ${invoice.invoiceId} | Amount: ₹${amount.toStringAsFixed(2)}");
        }
        // 2. UPI
        else if (paymentMode == "upi") {
          upiTotal += amount;
          upiCount++;
          print("   📱 UPI Invoice: ${invoice.invoiceId} | Amount: ₹${amount.toStringAsFixed(2)}");
        }
        // 3. CARD
        else if (paymentMode == "card") {
          cardTotal += amount;
          cardCount++;
          print("   💳 Card Invoice: ${invoice.invoiceId} | Amount: ₹${amount.toStringAsFixed(2)}");
        }
        // Any other payment mode (e.g., 'cheque', 'bank') is ignored for these specific counters
      }
    }

    // Update Observable Variables
    todayCashAmount.value = cashTotal;
    todayCashInvoices.value = cashCount;

    todayUpiAmount.value = upiTotal;
    todayUpiInvoices.value = upiCount;

    todayCardAmount.value = cardTotal;
    todayCardInvoices.value = cardCount;

    print("✅ Today's Payment Summary:");
    print("   Cash: ₹${cashTotal.toStringAsFixed(2)} ($cashCount invoices)");
    print("   UPI: ₹${upiTotal.toStringAsFixed(2)} ($upiCount invoices)");
    print("   Card: ₹${cardTotal.toStringAsFixed(2)} ($cardCount invoices)");
  }

  void _clearStats() {
    paidCount.value = 0;
    pendingCount.value = 0;
    overdueCount.value = 0;
    totalRevenue.value = 0.0;
    pendingAmount.value = 0.0;
    overdueAmount.value = 0.0;

    totalPurchases.value = 0;
    paidPurchases.value = 0;
    overduePurchases.value = 0;
    pendingPurchases.value = 0;
    totalPurchaseAmount.value = 0.0;
    pendingPurchaseAmount.value = 0.0;
    overduePurchaseAmount.value = 0.0;
    // 🔹 FIXED: Initialize with zero values instead of clearing
    invoiceStatusData.assignAll([
      ChartData("Paid", 0.0, Colors.green),
      ChartData("Pending", 0.0, Colors.orange),
      ChartData("Overdue", 0.0, Colors.red),
    ]);
  }

  // 🔹 NEW: Internal stats calculation (doesn't trigger reactive updates)
  void _calculateStatsInternal() {
    int paidCnt = 0;
    int pendingCnt = 0;
    int overdueCnt = 0;

    double totalRev = 0.0;
    double pendingAmt = 0.0;
    double overdueAmt = 0.0;

    final now = DateTime.now();
    // 🔹 FIXED: Use today at midnight for accurate date comparison
    final today = DateTime(now.year, now.month, now.day);

    for (var invoice in invoiceList) {
      final status = invoice.status?.toLowerCase().trim();
      final amount = invoice.totalAmount ?? 0.0;

      totalRev += amount;

      if (status == "paid") {
        paidCnt++;
      } else {
        // Check if invoice has a due date
        bool isOverdue = false;

        if (invoice.dueDate != null) {
          final dueDate = DateTime(
            invoice.dueDate!.year,
            invoice.dueDate!.month,
            invoice.dueDate!.day,
          );

          // 🔹 FIXED: Invoice is overdue if TODAY is AFTER the due date
          // Example: Issue: 1-Oct, Due: 15-Oct
          // - On 15-Oct (dueDate) → NOT overdue (isAfter returns false)
          // - On 16-Oct and beyond → OVERDUE (isAfter returns true)
          isOverdue = today.isAfter(dueDate);
        }

        if (isOverdue) {
          // Count as overdue (regardless of pending/partial/unpaid status)
          overdueCnt++;
          overdueAmt += amount;

          print("🔴 Overdue: ${invoice.invoiceId} | Status: $status | "
              "Issue: ${_formatDate(invoice.issueDate)} | "
              "Due: ${_formatDate(invoice.dueDate)} | "
              "Amount: ₹$amount");
        } else if (status == "pending" || status == "unpaid") {
          // Not yet overdue, just pending
          pendingCnt++;
          pendingAmt += amount;
        }

        // Partial payments count as pending but also check if overdue
        if (status == "partial" && !isOverdue) {
          pendingCnt++;
          pendingAmt += amount;
        }
      }
    }

    // Update observables
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
    _calculateTodayPaymentMethods();
    print("✅ Stats: Paid=$paidCnt, Pending=$pendingCnt, Overdue=$overdueCnt");
    print("   💰 Total Revenue: ₹${totalRev.toStringAsFixed(2)}");
    print("   💰 Pending Amount: ₹${pendingAmt.toStringAsFixed(2)}");
    print("   💰 Overdue Amount: ₹${overdueAmt.toStringAsFixed(2)}");
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
    _calculateTodayPaymentMethods();
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
  /// 🆕 IMPROVED: Better refresh management
  // Future<void> refreshDashboard() async {
  //   // 🆕 Prevent multiple simultaneous refreshes
  //   if (isLoading.value) {
  //     print("⚠️ Refresh already in progress, skipping...");
  //     return;
  //   }
  //
  //   try {
  //     print("🔄 Refreshing dashboard...");
  //     _isInitializing = true;
  //     isLoading.value = true;
  //
  //     await _loadCompanyData();
  //     await loadDashboardData();
  //     print("✅ Dashboard refreshed successfully");
  //
  //   } catch (e) {
  //     print("❌ Error refreshing dashboard: $e");
  //
  //   } finally {
  //     _isInitializing = false;
  //     isLoading.value = false;
  //   }
  // }
// ============================================
  Future<void> refreshDashboard() async {
    if (isLoading.value) {
      print("⚠️ Refresh already in progress, skipping...");
      return;
    }

    try {
      print("🔄 Refreshing dashboard...");
      isLoading.value = true;

      // ✅ Load company data
      await _loadCompanyData();
      await loadCompanySettings();

      // ✅ Load purchases AND invoices
      await Future.wait([
        loadPurchases(),
        loadInvoices(),
        loadCustomerCount(),
        getMonthlyRevenueData(),
      ]);

      print("✅ Dashboard refreshed");
      print("   📦 Purchases: ${totalPurchases.value}, ₹${totalPurchaseAmount.value.toStringAsFixed(2)}");
      print("   📄 Invoices: ${invoiceList.length}, ₹${totalRevenue.value.toStringAsFixed(2)}");
      print("   👥 Customers: ${customerCount.value}");

    } catch (e) {
      print("❌ Error refreshing dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  ///working
  Future<void> navigateToCreateInvoice() async {
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

    await Get.to(() => NewInvoiceScreen());
    print("🔄 Returned from Invoice Creation, refreshing...");
    await refreshDashboard();
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

  /// Navigate to Stock Report Screen
  Future<void> navigateToStockReport() async {
    if (companyId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please register a company first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!Get.isRegistered<StockReportController>()) {
      Get.put(StockReportController());
    }

    await Get.to(() => StockReportScreen());

    print("🔄 Returned from Stock Report, refreshing...");
    await refreshDashboard();
  }

  Future<void> navigateToInventoryMangment() async {
    Get.lazyPut<ItemController>(() => ItemController());

    // ✅ Wait for result from Purchase Entry screen
    final result = await Get.to(() => InventoryManagementScreen());

    /// ✅ If purchase was saved successfully, refresh dashboard
    //if (result == true) {
    print("🔄 Purchase saved, refreshing dashboard...");
    await refreshDashboard();
    //}
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

  Future<void> navigateToInvoiceList() async {
    Get.lazyPut<InvoiceListController>(() => InvoiceListController());
    await Get.to(InvoiceListScreen());
    // ✅ Always refresh when returning
    print("🔄 Returned from Invoice List, refreshing...");
    await refreshDashboard();
  }

  Future<void> navigateToInventory() async {
    Get.lazyPut<PurchaseEntryController>(() => PurchaseEntryController());
    await Get.to(() => PurchaseEntryScreen());

    /// ✅ If purchase was saved successfully, refresh dashboard
    //if (result == true) {
      print("🔄 Purchase saved, refreshing dashboard...");
      await refreshDashboard();
    //}
  }

  Future<void> navigateToPurchaseList() async {
    if (Get.isRegistered<PurchaseListController>()) {
    Get.delete<PurchaseListController>();
    }
    Get.put(PurchaseListController());
    await Get.to(() => PurchaseListScreen());

    // ✅ Refresh when returning
    print("🔄 Returned from Challan List, refreshing...");
    await refreshDashboard();
  }
  // Updated method to navigate to customer registration with company selection
  void navigateToCustomers() {
    /// Always show company selection screen
    Get.toNamed(CustomerRegistrationScreen.pageId);
  }

  /// New method specifically for adding a new customer
  // void navigateToAddNewCustomer() {
  //   // Always show company selection first
  //   Get.toNamed(CompanySelectionScreen.pageId);
  // }

  // Updated method for adding new customer
  Future<void> navigateToAddNewCustomer() async {
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
    await Get.toNamed(CompanySelectionScreen.pageId);

    // ✅ Refresh when returning
    print("🔄 Returned from Add Customer, refreshing...");
    await loadCustomerCount();
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
  Future<void> navigateToCustomerList() async {
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

    try {
      if (!Get.isRegistered<CustomerListController>()) {
        Get.put(CustomerListController());
      }

      // ✅ Wait for result from Customer List
      await Get.to(() => const CustomerListScreen());

      // ✅ Refresh customer count when returning
      print("🔄 Returned from Customer List, refreshing count...");
      await loadCustomerCount();

    } catch (e) {
      print("Error navigating to customer list: $e");
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
                    Get.to(() =>  CustomerListScreen());
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

  @override
  void onClose() {
    print("🔒 Closing DashboardController");
    _hasInitialized = false;
    _isInitializing = false;
    super.onClose();
  }

  Future<void> navigateToItems() async {
   await Get.toNamed(ItemScreen.pageId);
   // ✅ Refresh when returning
   print("🔄 Returned from Items, refreshing...");
   await refreshDashboard();
  }

  Future<void> navigateToChallanList() async {
    if (Get.isRegistered<ChallanListController>()) {
      Get.delete<ChallanListController>();
    }
    Get.put(ChallanListController());
    await Get.to(() => ChallanListScreen());

    // ✅ Refresh when returning
    print("🔄 Returned from Challan List, refreshing...");
    await refreshDashboard();
  }


  Future<void> navigateToQuotList() async {
    if (Get.isRegistered<QuotationListController>()) {
      Get.delete<QuotationListController>();
    }
    Get.put(QuotationListController());
    await Get.to(() => QuotationListScreen());

    // ✅ Refresh when returning
    print("🔄 Returned from Quotation List, refreshing...");
    await refreshDashboard();
  }

  Future<void> navigateToPaymentDetails() async {
    if (Get.isRegistered<PaymentDetailsController>()) {
      Get.delete<PaymentDetailsController>();
    }
    Get.put(PaymentDetailsController());
    await Get.to(() => PaymentDetailsScreen());

    // ✅ Refresh when returning
    print("🔄 Returned from Payment Details, refreshing...");
    await refreshDashboard();
  }


  Future<void> navigateToNewChallan() async {
    if (Get.isRegistered<NewChallanController>()) {
      Get.delete<NewChallanController>();
    }
    Get.put(NewChallanController());

    await Get.to(() => NewChallanScreen());

    // ✅ Refresh when returning
    print("🔄 Returned from New Challan, refreshing...");
    await refreshDashboard();
    // Get.to(
    //       () => NewChallanScreen(),
    //   transition: Transition.rightToLeft,
    //   duration: Duration(milliseconds: 300),
    // );
  }

  void navigateToEditCompany(Map<String, dynamic> companyData, String companyId) async {
    final result = await Get.toNamed(
      CompanyRegistrationScreen.pageId,
      arguments: {
        'isEdit': true,
        'companyData': companyData,
        'companyId': companyId,
      },
    );

    // If update was successful, refresh dashboard
    if (result == true) {
      print("Company updated, refreshing dashboard...");
      refreshDashboard();
    }
  }

  // ✅ Updated Export Function for Traders App (Web + Mobile)
  Future<void> exportInvoiceDataWithDateFilter(DateTime fromDate, DateTime toDate) async {
    try {
      // 1. Get Data
      final invoices = await GoogleSheetService.getInvoices(type: "INV");
      final items = await GoogleSheetService.getInvoiceItems();

      if (invoices.isEmpty) {
        Get.snackbar("Error", "No invoices found");
        return;
      }

      // 2. Filter Logic
      final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
      final end = DateTime(toDate.year, toDate.month, toDate.day);

      print("📅 Filtering invoices from ${_formatDate(start)} to ${_formatDate(end)}");

      final filteredInvoices = invoices.where((inv) {
        if (inv.issueDate == null) return false;
        final issueDate = DateTime(inv.issueDate!.year, inv.issueDate!.month, inv.issueDate!.day);
        return (issueDate.isAtSameMomentAs(start) || issueDate.isAfter(start)) &&
            (issueDate.isAtSameMomentAs(end) || issueDate.isBefore(end));
      }).toList();

      if (filteredInvoices.isEmpty) {
        Get.snackbar("Info", "No invoices found in date range");
        return;
      }

      // 3. Create Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Invoice_Export'];

      // Add Headers
      sheetObject.appendRow([
        TextCellValue('Invoice ID'),
        TextCellValue('Customer Name'),
        TextCellValue('Issue Date'),
        TextCellValue('Status'),
        TextCellValue('Item Name'),
        TextCellValue('Quantity'),
        TextCellValue('Rate'),
        TextCellValue('Total'),
        TextCellValue('GST Rate'),
        TextCellValue('GST Amount'),
        TextCellValue('Amount With GST'),
      ]);

      // Add Data Rows
      int rowCount = 0;
      for (var inv in filteredInvoices) {
        final invItems = items.where((it) => it.invoiceId == inv.invoiceId).toList();
        String dateStr = _formatDate(inv.issueDate);

        if (invItems.isEmpty) {
          sheetObject.appendRow([
            TextCellValue(inv.invoiceId ?? ""),
            TextCellValue(inv.customerName ?? ""),
            TextCellValue(dateStr),
            TextCellValue(inv.status ?? ""),
            TextCellValue(""),
            DoubleCellValue(0), DoubleCellValue(0), DoubleCellValue(0),
            DoubleCellValue(0), DoubleCellValue(0), DoubleCellValue(0),
          ]);
          rowCount++;
        } else {
          for (var item in invItems) {
            sheetObject.appendRow([
              TextCellValue(inv.invoiceId ?? ""),
              TextCellValue(inv.customerName ?? ""),
              TextCellValue(dateStr),
              TextCellValue(inv.status ?? ""),
              TextCellValue(item.itemName ?? ""),
              DoubleCellValue(item.quantity ?? 0),
              DoubleCellValue(item.rate ?? 0),
              DoubleCellValue(item.totalPrice ?? 0),
              DoubleCellValue(item.gstRate ?? 0),
              DoubleCellValue(item.gstAmount ?? 0),
              DoubleCellValue(item.amountWithGst ?? 0),
            ]);
            rowCount++;
          }
        }
      }
      print("✅ Exported $rowCount rows");

      // ---------------------------------------------------------
      // ✅ 4. SAVE FILE (Unified Filename Logic)
      // ---------------------------------------------------------
      String fromDateStr = _formatDateForFilename(start);
      String toDateStr = _formatDateForFilename(end);
      String fileName = "Invoice_Export_${fromDateStr}_to_${toDateStr}.xlsx";

      // 🔹 Use encode() instead of save() to prevent auto-download of 'FlutterExcel.xlsx'
      var fileBytes = excel.encode();

      if (fileBytes == null) {
        Get.snackbar("Error", "Failed to generate excel file");
        return;
      }

      if (kIsWeb) {
        // 🌐 WEB LOGIC
        final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName; // ✅ Web Filename

        html.document.body?.children.add(anchor);
        anchor.click();

        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        Get.snackbar('Success', 'Excel downloaded: $fileName', backgroundColor: Colors.green.shade100);
      } else {
        // 📱 MOBILE LOGIC
        final dir = await getApplicationDocumentsDirectory();
        String outputFile = "${dir.path}/$fileName"; // ✅ Mobile Filename

        File(outputFile)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        print("✅ Export saved at $outputFile");
        Get.snackbar('Success', 'Saved to Documents', backgroundColor: Colors.green.shade100);
        OpenFile.open(outputFile);
      }

    } catch (e) {
      print("❌ Error exporting excel: $e");
      Get.snackbar('Error', 'Failed to export: $e', backgroundColor: Colors.red.shade100);
    }
  }

// 🔹 Helper function to format date as dd/MM/yyyy for display
  String _formatDate(DateTime? date) {
    if (date == null) return "";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

// 🔹 Helper function to format date for filename (dd-MM-yyyy)
  String _formatDateForFilename(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }


  Future<void> exportGSTReportWithDateFilter(DateTime fromDate, DateTime toDate) async {
    try {
      // Get invoices and items
      final invoices = await GoogleSheetService.getInvoices(type: "INV");
      final items = await GoogleSheetService.getInvoiceItems();

      if (invoices.isEmpty) {
        Get.snackbar('No Data', 'No invoices found to export',
            backgroundColor: Colors.orange.shade100);
        return;
      }

      // Normalize dates
      final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
      final end = DateTime(toDate.year, toDate.month, toDate.day);

      print("📅 Generating GST Report from ${_formatDate(start)} to ${_formatDate(end)}");

      // Filter invoices by date range
      final filteredInvoices = invoices.where((inv) {
        if (inv.issueDate == null) return false;

        final issueDate = DateTime(
          inv.issueDate!.year,
          inv.issueDate!.month,
          inv.issueDate!.day,
        );

        return (issueDate.isAtSameMomentAs(start) || issueDate.isAfter(start)) &&
            (issueDate.isAtSameMomentAs(end) || issueDate.isBefore(end));
      }).toList();

      if (filteredInvoices.isEmpty) {
        Get.snackbar('No Data', 'No invoices found in selected date range',
            backgroundColor: Colors.orange.shade100);
        return;
      }

      print("✅ Found ${filteredInvoices.length} invoices");

      // Create PDF document
      final pdf = pw.Document();

      // Calculate totals
      double grandSubtotal = 0;
      double grandCGST = 0;
      double grandSGST = 0;
      double grandTotal = 0;
      int rowCount = 0;

      // ✅ NEW: Payment Mode Totals Variables
      double totalCashCollection = 0;
      double totalUpiCollection = 0;
      double totalCardCollection = 0;

      // Group by GST Rate for summary
      Map<double, Map<String, double>> gstRateSummary = {};

      for (var inv in filteredInvoices) {
        // ✅ NEW: Calculate Payment Mode Totals (Per Invoice)
        // We do this in the outer loop so we don't count the same invoice amount multiple times
        String mode = (inv.paymentMode ?? "").toLowerCase().trim();
        double invAmount = inv.totalAmount ?? 0.0;

        if (mode == "cash") {
          totalCashCollection += invAmount;
        } else if (mode == "upi") {
          totalUpiCollection += invAmount;
        } else if (mode == "card") {
          totalCardCollection += invAmount;
        }

        // --- Existing Logic for Items ---
        final invItems = items.where((it) => it.invoiceId == inv.invoiceId).toList();

        for (var item in invItems) {
          double qty = item.quantity ?? 0;
          double rate = item.rate ?? 0;
          double subtotal = rate * qty;
          double gstRate = item.gstRate ?? 0;
          double totalGST = subtotal * gstRate / 100;
          double cgst = totalGST / 2;
          double sgst = totalGST / 2;
          double total = subtotal + totalGST;

          grandSubtotal += subtotal;
          grandCGST += cgst;
          grandSGST += sgst;
          grandTotal += total;
          rowCount++;

          if (!gstRateSummary.containsKey(gstRate)) {
            gstRateSummary[gstRate] = {
              'subtotal': 0,
              'cgst': 0,
              'sgst': 0,
              'total': 0,
            };
          }

          gstRateSummary[gstRate]!['subtotal'] =
              (gstRateSummary[gstRate]!['subtotal'] ?? 0) + subtotal;
          gstRateSummary[gstRate]!['cgst'] =
              (gstRateSummary[gstRate]!['cgst'] ?? 0) + cgst;
          gstRateSummary[gstRate]!['sgst'] =
              (gstRateSummary[gstRate]!['sgst'] ?? 0) + sgst;
          gstRateSummary[gstRate]!['total'] =
              (gstRateSummary[gstRate]!['total'] ?? 0) + total;
        }
      }

      // ========== PAGE 1: GST SUMMARY ==========
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue900,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName.isNotEmpty
                            ? companyName
                            : 'GST SUMMARY REPORT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Period: ${_formatDate(start)} to ${_formatDate(end)}',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Report Info
                pw.Container(
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    children: [
                      _buildInfoRow('Total Invoices:', '${filteredInvoices.length}'),
                      _buildInfoRow('Total Items:', '$rowCount'),
                      _buildInfoRow(
                        'Invoice Range:',
                        '${filteredInvoices.first.invoiceId ?? "N/A"} to ${filteredInvoices.last.invoiceId ?? "N/A"}',
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // ✅ NEW: Payment Collection Summary Row
                pw.Text(
                  'Collection Summary',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),

                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Cash Box
                      pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green50,
                              border: pw.Border.all(color: PdfColors.green700),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Column(
                                children: [
                                  pw.Text("CASH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                                  pw.SizedBox(height: 4),
                                  pw.Text(AppUtil.formatCurrency(totalCashCollection), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                ]
                            )
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      // UPI Box
                      pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue50,
                              border: pw.Border.all(color: PdfColors.blue700),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Column(
                                children: [
                                  pw.Text("UPI", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                                  pw.SizedBox(height: 4),
                                  pw.Text(AppUtil.formatCurrency(totalUpiCollection), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                ]
                            )
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      // Card Box
                      pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.orange50,
                              border: pw.Border.all(color: PdfColors.orange700),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Column(
                                children: [
                                  pw.Text("CARD", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.orange900)),
                                  pw.SizedBox(height: 4),
                                  pw.Text(AppUtil.formatCurrency(totalCardCollection), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                ]
                            )
                        ),
                      ),
                    ]
                ),

                pw.SizedBox(height: 20),

                // GST Rate-wise Summary Table
                pw.Text(
                  'GST Rate-wise Summary',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableCell('GST Rate (%)', isHeader: true),
                        _buildTableCell('Taxable Amount', isHeader: true),
                        _buildTableCell('CGST', isHeader: true),
                        _buildTableCell('SGST', isHeader: true),
                        _buildTableCell('Total Amount', isHeader: true),
                      ],
                    ),
                    // Data rows
                    ...(gstRateSummary.keys.toList()..sort()).map((gstRate) {
                      var data = gstRateSummary[gstRate]!;
                      return pw.TableRow(
                        children: [
                          _buildTableCell('${gstRate.toStringAsFixed(2)}%'),
                          _buildTableCell(AppUtil.formatCurrency(data['subtotal']!)),
                          _buildTableCell(AppUtil.formatCurrency(data['cgst']!)),
                          _buildTableCell(AppUtil.formatCurrency(data['sgst']!)),
                          _buildTableCell(AppUtil.formatCurrency(data['total']!)),
                        ],
                      );
                    }).toList(),
                    // Total row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTableCell('TOTAL', isHeader: true),
                        _buildTableCell(AppUtil.formatCurrency(grandSubtotal), isHeader: true),
                        _buildTableCell(AppUtil.formatCurrency(grandCGST), isHeader: true),
                        _buildTableCell(AppUtil.formatCurrency(grandSGST), isHeader: true),
                        _buildTableCell(AppUtil.formatCurrency(grandTotal), isHeader: true),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // ========== PAGE 2+: DETAILED INVOICE REPORT ==========
      List<pw.TableRow> detailRows = [];

      // Header
      detailRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Invoice ID', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.left),
            _buildTableCell('Customer', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.left),
            _buildTableCell('Date', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.center),
            _buildTableCell('Item', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.left),
            _buildTableCell('Qty', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.right),
            _buildTableCell('Rate', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.right),
            _buildTableCell('Subtotal', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.right),
            _buildTableCell('GST%', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.right),
            _buildTableCell('CGST', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.right),
            _buildTableCell('SGST', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.right),
            _buildTableCell('Total', isHeader: true, fontSize: 7, textAlign: pw.TextAlign.right),
          ],
        ),
      );

      // Data rows
      for (var inv in filteredInvoices) {
        final invItems = items.where((it) => it.invoiceId == inv.invoiceId).toList();
        String dateStr = _formatDate(inv.issueDate);

        if (invItems.isEmpty) {
          detailRows.add(
            pw.TableRow(
              children: [
                _buildTableCell(inv.invoiceId ?? "", fontSize: 7, textAlign: pw.TextAlign.left),
                _buildTableCell(inv.customerName ?? "", fontSize: 7, textAlign: pw.TextAlign.left),
                _buildTableCell(dateStr, fontSize: 7, textAlign: pw.TextAlign.center),
                _buildTableCell("No Items", fontSize: 7, textAlign: pw.TextAlign.left),
                _buildTableCell("0", fontSize: 7, textAlign: pw.TextAlign.right),
                _buildTableCell("0.00", fontSize: 7, textAlign: pw.TextAlign.right),
                _buildTableCell("0.00", fontSize: 7, textAlign: pw.TextAlign.right),
                _buildTableCell("0", fontSize: 7, textAlign: pw.TextAlign.right),
                _buildTableCell("0.00", fontSize: 7, textAlign: pw.TextAlign.right),
                _buildTableCell("0.00", fontSize: 7, textAlign: pw.TextAlign.right),
                _buildTableCell("0.00", fontSize: 7, textAlign: pw.TextAlign.right),
              ],
            ),
          );
        } else {
          for (var item in invItems) {
            double qty = item.quantity ?? 0;
            double rate = item.rate ?? 0;
            double subtotal = rate * qty;
            double gstRate = item.gstRate ?? 0;
            double totalGST = subtotal * gstRate / 100;
            double cgst = totalGST / 2;
            double sgst = totalGST / 2;
            double total = subtotal + totalGST;

            detailRows.add(
              pw.TableRow(
                children: [
                  _buildTableCell(inv.invoiceId ?? "", fontSize: 7, textAlign: pw.TextAlign.left),
                  _buildTableCell(inv.customerName ?? "", fontSize: 7, textAlign: pw.TextAlign.left),
                  _buildTableCell(dateStr, fontSize: 7, textAlign: pw.TextAlign.center),
                  _buildTableCell(item.itemName ?? "", fontSize: 7, textAlign: pw.TextAlign.left),
                  _buildTableCell(qty.toStringAsFixed(0), fontSize: 7, textAlign: pw.TextAlign.right),
                  _buildTableCell(AppUtil.formatCurrency(rate), fontSize: 7, textAlign: pw.TextAlign.right),
                  _buildTableCell(AppUtil.formatCurrency(subtotal), fontSize: 7, textAlign: pw.TextAlign.right),
                  _buildTableCell('${gstRate.toStringAsFixed(0)}%', fontSize: 7, textAlign: pw.TextAlign.right),
                  _buildTableCell(AppUtil.formatCurrency(cgst), fontSize: 7, textAlign: pw.TextAlign.right),
                  _buildTableCell(AppUtil.formatCurrency(sgst), fontSize: 7, textAlign: pw.TextAlign.right),
                  _buildTableCell(AppUtil.formatCurrency(total), fontSize: 7, textAlign: pw.TextAlign.right),
                ],
              ),
            );
          }
        }
      }

      // Total row
      detailRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('', fontSize: 7),
            _buildTableCell('', fontSize: 7),
            _buildTableCell('', fontSize: 7),
            _buildTableCell('GRAND TOTAL', isHeader: true, fontSize: 8, textAlign: pw.TextAlign.left),
            _buildTableCell('', fontSize: 7),
            _buildTableCell('', fontSize: 7),
            _buildTableCell(AppUtil.formatCurrency(grandSubtotal), isHeader: true, fontSize: 8, textAlign: pw.TextAlign.right),
            _buildTableCell('', fontSize: 7),
            _buildTableCell(AppUtil.formatCurrency(grandCGST), isHeader: true, fontSize: 8, textAlign: pw.TextAlign.right),
            _buildTableCell(AppUtil.formatCurrency(grandSGST), isHeader: true, fontSize: 8, textAlign: pw.TextAlign.right),
            _buildTableCell(AppUtil.formatCurrency(grandTotal), isHeader: true, fontSize: 8, textAlign: pw.TextAlign.right),
          ],
        ),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) => [
            pw.Text(
              'Detailed Invoice Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: pw.FixedColumnWidth(50),   // Invoice ID
                1: pw.FixedColumnWidth(60),   // Customer
                2: pw.FixedColumnWidth(45),   // Date
                3: pw.FixedColumnWidth(70),   // Item
                4: pw.FixedColumnWidth(28),   // Qty
                5: pw.FixedColumnWidth(40),   // Rate
                6: pw.FixedColumnWidth(45),   // Subtotal
                7: pw.FixedColumnWidth(30),   // GST%
                8: pw.FixedColumnWidth(42),   // CGST
                9: pw.FixedColumnWidth(42),   // SGST
                10: pw.FixedColumnWidth(48),  // Total
              },
              children: detailRows,
            ),
          ],
        ),
      );

      // Save PDF file
     // final dir = await getApplicationDocumentsDirectory();
      String fromDateStr = _formatDateForFilename(start);
      String toDateStr = _formatDateForFilename(end);
      String fileName = "${companyName.isNotEmpty ? companyName : 'SUMMARY'}_Report_${fromDateStr}_to_${toDateStr}.pdf";

      if (kIsWeb) {
        // ✅ WEB: Open Browser Print Preview
        print("🖨️ Web Mode: Opening Print Preview");
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: fileName,
        );
      }
      else {
        // 📱 MOBILE: Save to File
        final dir = await getApplicationDocumentsDirectory();
        String outputFile = "${dir.path}/$fileName";
        final file = File(outputFile);
        await file.writeAsBytes(await pdf.save());
        print("✅ Saved to: $outputFile");
        OpenFile.open(outputFile);
      }

      Get.snackbar(
        'Success',
        'GST Report PDF exported successfully',
        backgroundColor: Colors.green.shade100,
        icon: Icon(Icons.check_circle, color: Colors.green),
      );


    } catch (e, st) {
      print("❌ Error generating GST report: $e");
      print(st);
      Get.snackbar(
        'Error',
        'Failed to generate report: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

// Helper function to build table cells
  pw.Widget _buildTableCell(String text, {bool isHeader = false, double fontSize = 10, pw.TextAlign? textAlign}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: textAlign ?? pw.TextAlign.center,
      ),
    );
  }

// Helper function to build info rows
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }


  void viewInvoiceDetails(Invoice invoice) {

    Get.lazyPut<InvoiceDetailsController>(() => InvoiceDetailsController());
    Get.to(() => InvoiceDetailsScreen(), arguments: invoice);
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

  Future<void> updateLanguagePreference(bool isGujarati) async {
    await AppConstants.setLanguage(isGujarati);

    // Also update in Firestore
    final user = _auth.currentUser;
    if (user != null && companyId.value.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(companyId.value)
          .update({'isGujarati': isGujarati});
    }

    print("✅ Language Updated → Gujarati: $isGujarati");
  }

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

// ============================================
class _DashboardLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResumed;

  _DashboardLifecycleObserver({required this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
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
