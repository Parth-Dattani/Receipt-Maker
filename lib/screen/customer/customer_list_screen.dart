import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../services/service.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../widgets/web_screen_wrapper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../widgets/widgets.dart';
import '../screen.dart';


class CustomerListController extends BaseController {
  var customers = <Map<String, dynamic>>[].obs;
  var filteredCustomers = <Map<String, dynamic>>[].obs;
  var customerCount = 0.obs;
  var searchQuery = ''.obs;
  var showInactiveCustomers = false.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var itemsPerPage = 20;
  var totalPages = 1.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;

  // ── Price Toggle ──
  var showPriceToCustomer = true.obs;
  String _currentCompanyId = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
    _loadPriceSetting();
  }

  /// Computed getter for filtered customers based on active/inactive filter
  List<Map<String, dynamic>> get filteredCustomerList {
    if (showInactiveCustomers.value) {
      return filteredCustomers;
    }
    return filteredCustomers.where((customer) =>
    customer['isActive']?.toString().toLowerCase() == 'true'
    ).toList();
  }

  // ─────────────────────────────────────────────
  // Price Setting — Load & Toggle
  // ─────────────────────────────────────────────
  Future<void> _loadPriceSetting() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _currentCompanyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      if (_currentCompanyId.isEmpty) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(_currentCompanyId)
          .get();

      showPriceToCustomer.value =
          doc.data()?['showPriceToCustomer'] as bool? ?? true;

      print('💰 showPriceToCustomer: ${showPriceToCustomer.value}');
    } catch (e) {
      print('❌ loadPriceSetting: $e');
    }
  }

  Future<void> toggleShowPriceToCustomer() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (_currentCompanyId.isEmpty) {
        _currentCompanyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      }

      // Toggle locally first (instant UI)
      showPriceToCustomer.value = !showPriceToCustomer.value;

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('companies')
          .doc(_currentCompanyId)
          .update({'showPriceToCustomer': showPriceToCustomer.value});

      Get.snackbar(
        showPriceToCustomer.value ? '💰 Price Visible' : '🙈 Price Hidden',
        showPriceToCustomer.value
            ? 'Customers will see item prices in order portal'
            : 'Prices are hidden from customers in order portal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: showPriceToCustomer.value
            ? Colors.green.shade100
            : Colors.orange.shade100,
        colorText: Colors.black87,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Revert on error
      showPriceToCustomer.value = !showPriceToCustomer.value;
      Get.snackbar('Error', 'Failed to update: $e',
          backgroundColor: Colors.red.shade100);
    }
  }

  /// ✅ FIXED: Load customers from Google Sheets instead of Firebase
  Future<void> loadCustomers({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMore.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        customers.clear();
        hasMore.value = true;
        currentPage.value = 1;
      }

      final user = _auth.currentUser;
      if (user == null) {
        showCustomSnackbar(
          title: "Error",
          message: "Please login first!",
          baseColor: AppColors.errorColor,
          icon: Icons.error,
        );
        return;
      }

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      print("Company ID: $companyId");

      if (companyId.isEmpty) {
        Get.snackbar(
          'Company Required',
          'Please register a company first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Fetch customers from Google Sheets
      final allCustomers = await GoogleSheetService.getCustomers(
        companyId: companyId,
        userId: user.uid,
      );

      print("✅ Loaded ${allCustomers.length} customers from Google Sheets");

      if (allCustomers.isEmpty) {
        hasMore.value = false;
        customers.clear();
        filteredCustomers.clear();
        customerCount.value = 0;
        return;
      }

      // ✅ Sort by createdAt (most recent first)
      allCustomers.sort((a, b) {
        try {
          final dateA = _parseDate(a['createdAt']?.toString() ?? '');
          final dateB = _parseDate(b['createdAt']?.toString() ?? '');
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      // ✅ Handle pagination
      if (!loadMore) {
        customers.value = allCustomers.take(itemsPerPage).toList();
        customerCount.value = allCustomers.length;
        totalPages.value = (allCustomers.length / itemsPerPage).ceil();
        hasMore.value = allCustomers.length > itemsPerPage;
      } else {
        final startIndex = customers.length;
        final endIndex = (startIndex + itemsPerPage).clamp(0, allCustomers.length);
        customers.addAll(allCustomers.sublist(startIndex, endIndex));
        hasMore.value = endIndex < allCustomers.length;
        currentPage.value++;
      }

      filteredCustomers.value = customers;
      print("✅ Displayed ${customers.length} of ${allCustomers.length} customers");

    } catch (e) {
      print("Error loading customers: $e");
      Get.snackbar(
        'Error',
        'Failed to load customers: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Helper to parse dates from Google Sheets
  DateTime _parseDate(String dateString) {
    if (dateString.isEmpty) return DateTime.now();
    try {
      if (dateString.contains('/')) {
        return DateFormat('dd/MM/yyyy HH:mm:ss').parse(dateString);
      }
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> loadMoreCustomers() async {
    await loadCustomers(loadMore: true);
  }

  Future<void> refreshCustomers() async {
    await loadCustomers(loadMore: false);
  }

  void searchCustomers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCustomers.value = customers;
      return;
    }
    final lowercaseQuery = query.toLowerCase();
    filteredCustomers.value = customers.where((customer) {
      final name = (customer['name'] ?? '').toString().toLowerCase();
      final mobile = (customer['mobile1'] ?? '').toString().toLowerCase();
      final email = (customer['email'] ?? '').toString().toLowerCase();
      final city = (customer['city'] ?? '').toString().toLowerCase();
      final businessName = (customer['businessName'] ?? '').toString().toLowerCase();
      return name.contains(lowercaseQuery) ||
          mobile.contains(lowercaseQuery) ||
          email.contains(lowercaseQuery) ||
          city.contains(lowercaseQuery) ||
          businessName.contains(lowercaseQuery);
    }).toList();
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredCustomers.value = customers;
  }

  void sortCustomers(String sortType) {
    List<Map<String, dynamic>> sortedList = List.from(filteredCustomers);
    switch (sortType) {
      case 'name_asc':
        sortedList.sort((a, b) {
          final nameA = (a['name'] ?? '').toString().toLowerCase();
          final nameB = (b['name'] ?? '').toString().toLowerCase();
          return nameA.compareTo(nameB);
        });
        Get.snackbar('Sorted', 'Customers sorted A-Z',
            snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
        break;
      case 'name_desc':
        sortedList.sort((a, b) {
          final nameA = (a['name'] ?? '').toString().toLowerCase();
          final nameB = (b['name'] ?? '').toString().toLowerCase();
          return nameB.compareTo(nameA);
        });
        Get.snackbar('Sorted', 'Customers sorted Z-A',
            snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
        break;
      case 'recent':
        sortedList.sort((a, b) {
          try {
            final dateA = _parseDate(a['createdAt']?.toString() ?? '');
            final dateB = _parseDate(b['createdAt']?.toString() ?? '');
            return dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });
        Get.snackbar('Sorted', 'Showing recently added first',
            snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
        break;
    }
    filteredCustomers.value = sortedList;
  }

  Future<void> navigateToAddNewCustomer() async {
    final result = await Get.toNamed(CustomerRegistrationScreen.pageId);
    if (result == true) {
      print("🔄 Customer added/updated, refreshing list...");
      await loadCustomers();
      Get.snackbar('Success', 'Customer list updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: Duration(seconds: 2));
    }
  }

  void viewCustomerDetails(Map<String, dynamic> customer) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.tealColor.withOpacity(0.15),
                      child: Text(
                        (customer['name'] ?? 'U')[0].toUpperCase(),
                        style: TextStyle(color: AppColors.tealColor, fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer['name'] ?? 'Unknown',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (customer['businessName'] != null && customer['businessName'].toString().isNotEmpty)
                            Text(customer['businessName'].toString(),
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 32),
                _buildDetailSection('Contact Information', [
                  _buildDetailRow(Icons.phone, 'Mobile', customer['mobile1']?.toString()),
                  if (customer['mobile2'] != null && customer['mobile2'].toString().isNotEmpty)
                    _buildDetailRow(Icons.phone_android, 'Secondary', customer['mobile2'].toString()),
                  if (customer['email'] != null && customer['email'].toString().isNotEmpty)
                    _buildDetailRow(Icons.email, 'Email', customer['email'].toString()),
                  if (customer['website'] != null && customer['website'].toString().isNotEmpty)
                    _buildDetailRow(Icons.language, 'Website', customer['website'].toString()),
                ]),
                if (customer['address'] != null && customer['address'].toString().isNotEmpty)
                  _buildDetailSection('Address', [
                    _buildDetailRow(Icons.home, 'Address', customer['address']?.toString()),
                    _buildDetailRow(Icons.location_city, 'City', customer['city']?.toString()),
                    _buildDetailRow(Icons.map, 'State', customer['state']?.toString()),
                    _buildDetailRow(Icons.flag, 'Country', customer['country']?.toString()),
                    _buildDetailRow(Icons.pin_drop, 'Pincode', customer['pincode']?.toString()),
                  ]),
                if ((customer['gst'] != null && customer['gst'].toString().isNotEmpty) ||
                    (customer['pan'] != null && customer['pan'].toString().isNotEmpty))
                  _buildDetailSection('Business Information', [
                    if (customer['gst'] != null && customer['gst'].toString().isNotEmpty)
                      _buildDetailRow(Icons.receipt_long, 'GST', customer['gst'].toString()),
                    if (customer['pan'] != null && customer['pan'].toString().isNotEmpty)
                      _buildDetailRow(Icons.badge, 'PAN', customer['pan'].toString()),
                    if (customer['businessType'] != null && customer['businessType'].toString().isNotEmpty)
                      _buildDetailRow(Icons.category, 'Business Type', customer['businessType'].toString()),
                  ]),
                if (customer['notes'] != null && customer['notes'].toString().isNotEmpty)
                  _buildDetailSection('Notes', [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Text(customer['notes'].toString(), style: TextStyle(fontSize: 14)),
                    ),
                  ]),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: Text('Close')),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () { Get.back(); editCustomer(customer); },
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealColor, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
        SizedBox(height: 12),
        ...children,
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editCustomer(Map<String, dynamic> customer) async {
    String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
    print("🔧 Editing customer: ${customer['customerId']}");
    print("🔧 Customer data keys: ${customer.keys.toList()}");
    final result = await Get.toNamed(
      CustomerRegistrationScreen.pageId,
      arguments: {'isEdit': true, 'customerData': customer, 'companyId': companyId},
    );
    if (result == true) {
      print("🔄 Customer updated, refreshing list...");
      await loadCustomers();
    }
  }

  void createInvoiceForCustomer(Map<String, dynamic> customer) {
    if (Get.isRegistered<NewInvoiceController>()) {
      Get.delete<NewInvoiceController>(force: true);
    }
    Get.toNamed(NewInvoiceScreen.pageId, arguments: {
      'customerId': customer['customerId'],
      'customerData': customer,
    });
  }

  void shareOrderLink(Map<String, dynamic> customer) {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not authenticated',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final customerId = customer['customerId']?.toString() ?? customer['id']?.toString() ?? '';
    if (customerId.isEmpty) {
      Get.snackbar('Error', 'Customer ID not found',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final mainUrl = 'https://web.invoicesathi.com/#/order?cid=${user.uid}&uid=$customerId';
    final backupUrl = 'https://getyourinvoice-8f128.web.app/#/order?cid=${user.uid}&uid=$customerId';
    final message =
        'Hello ${customer['name']},\n\nYou can now place your order directly using this link:\n$mainUrl\n\n(Alternative Link: $backupUrl)';
    Share.share(message);
  }

  void deleteCustomer(Map<String, dynamic> customer) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Delete Customer'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this customer?'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.tealColor.withOpacity(0.15),
                    child: Text((customer['name'] ?? 'U')[0].toUpperCase(),
                        style: TextStyle(color: AppColors.tealColor, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer['name'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        if (customer['mobile1'] != null)
                          Text(customer['mobile1'].toString(),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('This action cannot be undone.',
                style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async { Get.back(); await _performDeleteCustomer(customer); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteCustomer(Map<String, dynamic> customer) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red, colorText: Colors.white,
            icon: Icon(Icons.error, color: Colors.white));
        return;
      }
      final customerId = customer['customerId']?.toString();
      if (customerId == null || customerId.isEmpty) {
        Get.snackbar('Error', 'Customer ID not found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      await GoogleSheetService.deleteCustomer(customerId, user.uid);
      customers.removeWhere((c) => c['customerId'] == customerId);
      filteredCustomers.removeWhere((c) => c['customerId'] == customerId);
      customerCount.value = customers.length;
      customers.refresh();
      filteredCustomers.refresh();
      Get.snackbar(
        'Customer Deleted', '${customer['name']} has been permanently deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green, colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print("Error deleting customer: $e");
      Get.snackbar('Error', 'Failed to delete customer: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red, colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
          duration: Duration(seconds: 4));
    } finally {
      isLoading.value = false;
    }
  }
}

