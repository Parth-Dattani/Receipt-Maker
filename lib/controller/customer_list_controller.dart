import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constant/constant.dart';
import '../screen/screen.dart';
import '../services/service.dart';
import '../utils/shared_preferences_helper.dart';
import '../widgets/widgets.dart';
import 'controller.dart';

// class CustomerListController extends BaseController {
//   var customers = <Map<String, dynamic>>[].obs;
//   var filteredCustomers = <Map<String, dynamic>>[].obs;
//   var customerCount = 0.obs;
//   var searchQuery = ''.obs;
//   var showInactiveCustomers = false.obs;
//
//   // Pagination variables
//   var currentPage = 1.obs;
//   var itemsPerPage = 20;
//   var totalPages = 1.obs;
//   var isLoadingMore = false.obs;
//   DocumentSnapshot? lastDocument;
//   var hasMore = true.obs;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadCustomers();
//   }
//
//   /// Computed getter for filtered customers based on active/inactive filter
//   List<Map<String, dynamic>> get filteredCustomerList {
//     if (showInactiveCustomers.value) {
//       return filteredCustomers;
//     }
//     return filteredCustomers.where((customer) => customer['isActive'] ?? true).toList();
//   }
//
//
//
//   Future<void> loadCustomers({bool loadMore = false}) async {
//     try {
//       if (loadMore) {
//         if (!hasMore.value || isLoadingMore.value) return;
//         isLoadingMore.value = true;
//       } else {
//         isLoading.value = true;
//         customers.clear();
//         lastDocument = null;
//         hasMore.value = true;
//         currentPage.value = 1;
//       }
//
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       print("Company ID: $companyId");
//
//       if (companyId.isEmpty) {
//         Get.snackbar(
//           'Company Required',
//           'Please register a company first',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//         return;
//       }
//
//       // Build query with pagination
//       Query query = _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers")
//           .orderBy('createdAt', descending: true)
//           .limit(itemsPerPage);
//
//       // If loading more, start after last document
//       if (loadMore && lastDocument != null) {
//         query = query.startAfterDocument(lastDocument!);
//       }
//
//       final customersSnapshot = await query.get();
//
//       if (customersSnapshot.docs.isEmpty) {
//         hasMore.value = false;
//         if (loadMore) {
//           Get.snackbar(
//             'End of List',
//             'No more customers to load',
//             snackPosition: SnackPosition.BOTTOM,
//             duration: Duration(seconds: 2),
//           );
//         }
//         return;
//       }
//
//       // Store last document for next pagination
//       if (customersSnapshot.docs.isNotEmpty) {
//         lastDocument = customersSnapshot.docs.last;
//       }
//
//       // Check if there are more documents
//       if (customersSnapshot.docs.length < itemsPerPage) {
//         hasMore.value = false;
//       }
//
//       for (var doc in customersSnapshot.docs) {
//         final customerData = doc.data() as Map<String, dynamic>;
//         customerData['id'] = doc.id;
//         customers.add(customerData);
//       }
//
//       // Get total count (only on first load)
//       if (!loadMore) {
//         final countSnapshot = await _firestore
//             .collection("users")
//             .doc(user.uid)
//             .collection("companies")
//             .doc(companyId)
//             .collection("customers")
//             .count()
//             .get();
//
//         customerCount.value = countSnapshot.count ?? 0;
//         totalPages.value = (customerCount.value / itemsPerPage).ceil();
//       }
//
//       filteredCustomers.value = customers;
//
//       if (loadMore) {
//         currentPage.value++;
//       }
//
//     } catch (e) {
//       print("Error loading customers: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to load customers',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//       isLoadingMore.value = false;
//     }
//   }
//
//   Future<void> loadMoreCustomers() async {
//     await loadCustomers(loadMore: true);
//   }
//
//   Future<void> refreshCustomers() async {
//     await loadCustomers(loadMore: false);
//   }
//
//   void searchCustomers(String query) {
//     searchQuery.value = query;
//
//     if (query.isEmpty) {
//       filteredCustomers.value = customers;
//       return;
//     }
//
//     final lowercaseQuery = query.toLowerCase();
//     filteredCustomers.value = customers.where((customer) {
//       final name = (customer['name'] ?? '').toLowerCase();
//       final mobile = (customer['mobile1'] ?? '').toLowerCase();
//       final email = (customer['email'] ?? '').toLowerCase();
//       final city = (customer['city'] ?? '').toLowerCase();
//       final businessName = (customer['businessName'] ?? '').toLowerCase();
//
//       return name.contains(lowercaseQuery) ||
//           mobile.contains(lowercaseQuery) ||
//           email.contains(lowercaseQuery) ||
//           city.contains(lowercaseQuery) ||
//           businessName.contains(lowercaseQuery);
//     }).toList();
//   }
//
//   void clearSearch() {
//     searchQuery.value = '';
//     filteredCustomers.value = customers;
//   }
//
//   void sortCustomers(String sortType) {
//     List<Map<String, dynamic>> sortedList = List.from(filteredCustomers);
//
//     switch (sortType) {
//       case 'name_asc':
//         sortedList.sort((a, b) {
//           final nameA = (a['name'] ?? '').toString().toLowerCase();
//           final nameB = (b['name'] ?? '').toString().toLowerCase();
//           return nameA.compareTo(nameB);
//         });
//         Get.snackbar(
//           'Sorted',
//           'Customers sorted A-Z',
//           snackPosition: SnackPosition.BOTTOM,
//           duration: Duration(seconds: 1),
//         );
//         break;
//
//       case 'name_desc':
//         sortedList.sort((a, b) {
//           final nameA = (a['name'] ?? '').toString().toLowerCase();
//           final nameB = (b['name'] ?? '').toString().toLowerCase();
//           return nameB.compareTo(nameA);
//         });
//         Get.snackbar(
//           'Sorted',
//           'Customers sorted Z-A',
//           snackPosition: SnackPosition.BOTTOM,
//           duration: Duration(seconds: 1),
//         );
//         break;
//
//       case 'recent':
//         sortedList.sort((a, b) {
//           final dateA = a['createdAt'] as Timestamp?;
//           final dateB = b['createdAt'] as Timestamp?;
//           if (dateA == null || dateB == null) return 0;
//           return dateB.compareTo(dateA);
//         });
//         Get.snackbar(
//           'Sorted',
//           'Showing recently added first',
//           snackPosition: SnackPosition.BOTTOM,
//           duration: Duration(seconds: 1),
//         );
//         break;
//     }
//
//     filteredCustomers.value = sortedList;
//   }
//
//   void navigateToAddNewCustomer() {
//
//     //Get.toNamed(CompanySelectionScreen.pageId);
//     Get.toNamed(CustomerRegistrationScreen.pageId);
//   }
//
//   void viewCustomerDetails(Map<String, dynamic> customer) {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Container(
//           padding: EdgeInsets.all(24),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundColor: AppColors.tealColor.withOpacity(0.15),
//                       child: Text(
//                         (customer['name'] ?? 'U')[0].toUpperCase(),
//                         style: TextStyle(
//                           color: AppColors.tealColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             customer['name'] ?? 'Unknown',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if (customer['businessName'] != null &&
//                               customer['businessName'].isNotEmpty)
//                             Text(
//                               customer['businessName'],
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Divider(height: 32),
//
//                 _buildDetailSection('Contact Information', [
//                   _buildDetailRow(Icons.phone, 'Mobile', customer['mobile1']),
//                   if (customer['mobile2'] != null && customer['mobile2'].isNotEmpty)
//                     _buildDetailRow(Icons.phone_android, 'Secondary', customer['mobile2']),
//                   if (customer['email'] != null && customer['email'].isNotEmpty)
//                     _buildDetailRow(Icons.email, 'Email', customer['email']),
//                   if (customer['website'] != null && customer['website'].isNotEmpty)
//                     _buildDetailRow(Icons.language, 'Website', customer['website']),
//                 ]),
//
//                 if (customer['address'] != null && customer['address'].isNotEmpty)
//                   _buildDetailSection('Address', [
//                     _buildDetailRow(Icons.home, 'Address', customer['address']),
//                     _buildDetailRow(Icons.location_city, 'City', customer['city']),
//                     _buildDetailRow(Icons.map, 'State', customer['state']),
//                     _buildDetailRow(Icons.flag, 'Country', customer['country']),
//                     _buildDetailRow(Icons.pin_drop, 'Pincode', customer['pincode']),
//                   ]),
//
//                 if ((customer['gst'] != null && customer['gst'].isNotEmpty) ||
//                     (customer['pan'] != null && customer['pan'].isNotEmpty))
//                   _buildDetailSection('Business Information', [
//                     if (customer['gst'] != null && customer['gst'].isNotEmpty)
//                       _buildDetailRow(Icons.receipt_long, 'GST', customer['gst']),
//                     if (customer['pan'] != null && customer['pan'].isNotEmpty)
//                       _buildDetailRow(Icons.badge, 'PAN', customer['pan']),
//                     if (customer['businessType'] != null && customer['businessType'].isNotEmpty)
//                       _buildDetailRow(Icons.category, 'Business Type', customer['businessType']),
//                   ]),
//
//                 if (customer['notes'] != null && customer['notes'].isNotEmpty)
//                   _buildDetailSection('Notes', [
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         customer['notes'],
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ]),
//
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Get.back(),
//                       child: Text('Close'),
//                     ),
//                     SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Get.back();
//                         editCustomer(customer);
//                       },
//                       icon: Icon(Icons.edit, size: 18),
//                       label: Text('Edit'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.tealColor,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: AppColors.tealColor,
//           ),
//         ),
//         SizedBox(height: 12),
//         ...children,
//         SizedBox(height: 20),
//       ],
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String label, String? value) {
//     if (value == null || value.isEmpty) return SizedBox.shrink();
//
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey.shade600),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void editCustomer(Map<String, dynamic> customer) async {
//     String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//
//     final user = _auth.currentUser;
//     Map<String, dynamic>? companyData;
//
//     if (user != null && companyId.isNotEmpty) {
//       final companyDoc = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .get();
//
//       if (companyDoc.exists) {
//         companyData = companyDoc.data();
//       }
//     }
//
//     final result = await Get.toNamed(
//       CustomerRegistrationScreen.pageId,
//       arguments: {
//         'isEdit': true,
//         'customerData': customer,
//         'companyId': companyId,
//         'companyData': companyData,
//       },
//     );
//
//     if (result == true) {
//       await refreshCustomers();
//     }
//   }
//
//   void createInvoiceForCustomer(Map<String, dynamic> customer) {
//     Get.toNamed(NewInvoiceScreen.pageId, arguments: {'customerId': customer['id']});
//   }
//
//   void deleteCustomer(Map<String, dynamic> customer) {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Row(
//           children: [
//             Icon(Icons.warning, color: Colors.orange),
//             SizedBox(width: 8),
//             Text('Delete Customer'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Are you sure you want to delete this customer?'),
//             SizedBox(height: 8),
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: AppColors.tealColor.withOpacity(0.15),
//                     child: Text(
//                       (customer['name'] ?? 'U')[0].toUpperCase(),
//                       style: TextStyle(
//                         color: AppColors.tealColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           customer['name'] ?? 'Unknown',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         if (customer['mobile1'] != null)
//                           Text(
//                             customer['mobile1'],
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               'This will mark the customer as inactive. You can restore it later.',
//               style: TextStyle(
//                 color: Colors.orange.shade700,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Get.back();
//               await _performDeleteCustomer(customer);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _performDeleteCustomer(Map<String, dynamic> customer) async {
//     try {
//       isLoading.value = true;
//
//       final user = _auth.currentUser;
//       if (user == null) {
//         Get.snackbar(
//           'Error',
//           'User not authenticated',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           icon: Icon(Icons.error, color: Colors.white),
//         );
//         return;
//       }
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//
//       if (companyId.isEmpty) {
//         Get.snackbar(
//           'Error',
//           'Company ID not found',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           icon: Icon(Icons.error, color: Colors.white),
//         );
//         return;
//       }
//
//       // PERMANENTLY DELETE from Firebase
//       await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers")
//           .doc(customer['id'])
//           .delete();
//
//       // Remove from local lists
//       customers.removeWhere((c) => c['id'] == customer['id']);
//       filteredCustomers.removeWhere((c) => c['id'] == customer['id']);
//
//       // Update customer count
//       customerCount.value = customers.length;
//
//       // Trigger UI update
//       customers.refresh();
//       filteredCustomers.refresh();
//
//       Get.snackbar(
//         'Customer Deleted',
//         '${customer['name']} has been permanently deleted',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         icon: Icon(Icons.check_circle, color: Colors.white),
//         duration: Duration(seconds: 3),
//       );
//
//     } catch (e) {
//       print("Error deleting customer: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to delete customer: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: Icon(Icons.error, color: Colors.white),
//         duration: Duration(seconds: 4),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   ///its temp Delete customer Iable TO restore Customer
//   // Future<void> _performDeleteCustomer(Map<String, dynamic> customer) async {
//   //   try {
//   //     final user = _auth.currentUser;
//   //     if (user == null) return;
//   //
//   //     String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//   //
//   //     await _firestore
//   //         .collection("users")
//   //         .doc(user.uid)
//   //         .collection("companies")
//   //         .doc(companyId)
//   //         .collection("customers")
//   //         .doc(customer['id'])
//   //         .update({'isActive': false});
//   //
//   //     // Update local data
//   //     final index = customers.indexWhere((c) => c['id'] == customer['id']);
//   //     if (index != -1) {
//   //       customers[index]['isActive'] = false;
//   //     }
//   //
//   //     final filteredIndex = filteredCustomers.indexWhere((c) => c['id'] == customer['id']);
//   //     if (filteredIndex != -1) {
//   //       filteredCustomers[filteredIndex]['isActive'] = false;
//   //     }
//   //
//   //     // Trigger UI update
//   //     filteredCustomers.refresh();
//   //     customers.refresh();
//   //
//   //     Get.snackbar(
//   //       'Customer Deleted',
//   //       'Customer marked as inactive',
//   //       snackPosition: SnackPosition.BOTTOM,
//   //       backgroundColor: Colors.orange,
//   //       colorText: Colors.white,
//   //       icon: Icon(Icons.info, color: Colors.white),
//   //       duration: Duration(seconds: 4),
//   //       mainButton: TextButton(
//   //         onPressed: () {
//   //           Get.back(); // Close snackbar
//   //           restoreCustomer(customer);
//   //         },
//   //         child: Text(
//   //           'RESTORE',
//   //           style: TextStyle(
//   //             color: Colors.white,
//   //             fontWeight: FontWeight.bold,
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     print("Error deleting customer: $e");
//   //     Get.snackbar(
//   //       'Error',
//   //       'Failed to delete customer',
//   //       snackPosition: SnackPosition.BOTTOM,
//   //       backgroundColor: Colors.red,
//   //       colorText: Colors.white,
//   //       icon: Icon(Icons.error, color: Colors.white),
//   //     );
//   //   }
//   // }
//
//   // Future<void> restoreCustomer(Map<String, dynamic> customer) async {
//   //   try {
//   //     final user = _auth.currentUser;
//   //     if (user == null) return;
//   //
//   //     String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//   //
//   //     await _firestore
//   //         .collection("users")
//   //         .doc(user.uid)
//   //         .collection("companies")
//   //         .doc(companyId)
//   //         .collection("customers")
//   //         .doc(customer['id'])
//   //         .update({'isActive': true});
//   //
//   //     // Update local data
//   //     final index = customers.indexWhere((c) => c['id'] == customer['id']);
//   //     if (index != -1) {
//   //       customers[index]['isActive'] = true;
//   //     }
//   //
//   //     final filteredIndex = filteredCustomers.indexWhere((c) => c['id'] == customer['id']);
//   //     if (filteredIndex != -1) {
//   //       filteredCustomers[filteredIndex]['isActive'] = true;
//   //     }
//   //
//   //     // Trigger UI update
//   //     filteredCustomers.refresh();
//   //     customers.refresh();
//   //
//   //     Get.snackbar(
//   //       'Success',
//   //       'Customer restored successfully',
//   //       snackPosition: SnackPosition.BOTTOM,
//   //       backgroundColor: Colors.green,
//   //       colorText: Colors.white,
//   //       icon: Icon(Icons.check_circle, color: Colors.white),
//   //     );
//   //   } catch (e) {
//   //     print("Error restoring customer: $e");
//   //     Get.snackbar(
//   //       'Error',
//   //       'Failed to restore customer',
//   //       snackPosition: SnackPosition.BOTTOM,
//   //       backgroundColor: Colors.red,
//   //       colorText: Colors.white,
//   //       icon: Icon(Icons.error, color: Colors.white),
//   //     );
//   //   }
//   // }
//
//   // void toggleShowInactive() {
//   //   showInactiveCustomers.value = !showInactiveCustomers.value;
//   //   Get.snackbar(
//   //     showInactiveCustomers.value ? 'Showing All' : 'Showing Active Only',
//   //     showInactiveCustomers.value
//   //         ? 'Inactive customers are now visible'
//   //         : 'Inactive customers are hidden',
//   //     snackPosition: SnackPosition.BOTTOM,
//   //     duration: Duration(seconds: 2),
//   //     backgroundColor: AppColors.tealColor,
//   //     colorText: Colors.white,
//   //   );
//   // }
// }

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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
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
        // First load
        customers.value = allCustomers.take(itemsPerPage).toList();
        customerCount.value = allCustomers.length;
        totalPages.value = (allCustomers.length / itemsPerPage).ceil();
        hasMore.value = allCustomers.length > itemsPerPage;
      } else {
        // Load more
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
      // Try dd/MM/yyyy HH:mm:ss
      if (dateString.contains('/')) {
        return DateFormat('dd/MM/yyyy HH:mm:ss').parse(dateString);
      }
      // Try ISO format
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
        Get.snackbar(
          'Sorted',
          'Customers sorted A-Z',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
        );
        break;

      case 'name_desc':
        sortedList.sort((a, b) {
          final nameA = (a['name'] ?? '').toString().toLowerCase();
          final nameB = (b['name'] ?? '').toString().toLowerCase();
          return nameB.compareTo(nameA);
        });
        Get.snackbar(
          'Sorted',
          'Customers sorted Z-A',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
        );
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
        Get.snackbar(
          'Sorted',
          'Showing recently added first',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
        );
        break;
    }

    filteredCustomers.value = sortedList;
  }

  Future<void> navigateToAddNewCustomer() async {
    // ✅ Wait for result from navigation
    final result = await Get.toNamed(CustomerRegistrationScreen.pageId);

    // ✅ If customer was added/updated, refresh the list
    if (result == true) {
      print("🔄 Customer added/updated, refreshing list...");
      await loadCustomers();

      Get.snackbar(
        'Success',
        'Customer list updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  void viewCustomerDetails(Map<String, dynamic> customer) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                        style: TextStyle(
                          color: AppColors.tealColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (customer['businessName'] != null &&
                              customer['businessName'].toString().isNotEmpty)
                            Text(
                              customer['businessName'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
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
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        customer['notes'].toString(),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ]),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Close'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        editCustomer(customer);
                      },
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealColor,
                        foregroundColor: Colors.white,
                      ),
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
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.tealColor,
          ),
        ),
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

    // ✅ Wait for result
    final result = await Get.toNamed(
      CustomerRegistrationScreen.pageId,
      arguments: {
        'isEdit': true,
        'customerData': customer,
        'companyId': companyId,
      },
    );

    // ✅ If customer was updated, refresh the list
    if (result == true) {
      print("🔄 Customer updated, refreshing list...");
      await loadCustomers();
    }
  }

  void createInvoiceForCustomer(Map<String, dynamic> customer) {
    Get.toNamed(NewInvoiceScreen.pageId, arguments: {'customerId': customer['customerId']});
  }

  /// ✅ FIXED: Delete from Google Sheets
  void deleteCustomer(Map<String, dynamic> customer) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Customer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this customer?'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.tealColor.withOpacity(0.15),
                    child: Text(
                      (customer['name'] ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.tealColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name'] ?? 'Unknown',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (customer['mobile1'] != null)
                          Text(
                            customer['mobile1'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performDeleteCustomer(customer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// ✅ FIXED: Delete from Google Sheets
  Future<void> _performDeleteCustomer(Map<String, dynamic> customer) async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'User not authenticated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
        );
        return;
      }

      final customerId = customer['customerId']?.toString();
      if (customerId == null || customerId.isEmpty) {
        Get.snackbar(
          'Error',
          'Customer ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ DELETE from Google Sheets
      await GoogleSheetService.deleteCustomer(customerId, user.uid);

      // Remove from local lists
      customers.removeWhere((c) => c['customerId'] == customerId);
      filteredCustomers.removeWhere((c) => c['customerId'] == customerId);

      // Update customer count
      customerCount.value = customers.length;

      // Trigger UI update
      customers.refresh();
      filteredCustomers.refresh();

      Get.snackbar(
        'Customer Deleted',
        '${customer['name']} has been permanently deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        duration: Duration(seconds: 3),
      );

    } catch (e) {
      print("Error deleting customer: $e");
      Get.snackbar(
        'Error',
        'Failed to delete customer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}


