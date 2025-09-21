import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/screen.dart';
import '../utils/shared_preferences_helper.dart';
import 'controller.dart';

///04/09 working Code
class CustomerListController extends BaseController {
  var customers = <Map<String, dynamic>>[].obs;
  var customerCount = 0.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      // Get current company ID from SharedPreferences or arguments
      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
      print("Company ID: $companyId");

      print("--------CL----Cmpny ID: ${companyId}");
      if (companyId.isEmpty) {
        // No company selected, show message
        Get.snackbar(
          'Company Required',
          'Please register a company first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Load customers from Firebase
      final customersSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .collection("customers")
          //.where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      customers.clear();
      for (var doc in customersSnapshot.docs) {
        final customerData = doc.data();
        customerData['id'] = doc.id;
        customers.add(customerData);
      }

      customerCount.value = customers.length;

    } catch (e) {
      print("Error loading customers: $e");
      Get.snackbar(
        'Error',
        'Failed to load customers',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCustomers() async {
    await loadCustomers();
  }

  void navigateToAddNewCustomer() {
    // Navigate to company selection screen first
    Get.toNamed(CompanySelectionScreen.pageId);
  }

  void viewCustomerDetails(Map<String, dynamic> customer) {
    // Navigate to customer details screen
    // Get.toNamed(CustomerDetailsScreen.pageId, arguments: customer);

    // For now, show customer info
    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text('Name: ${customer['name'] ?? 'N/A'}'),
              Text('Mobile: ${customer['mobile1'] ?? 'N/A'}'),
              Text('Email: ${customer['email'] ?? 'N/A'}'),
              Text('Address: ${customer['address'] ?? 'N/A'}'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void editCustomer(Map<String, dynamic> customer) {
    // Navigate to edit customer screen
    Get.snackbar(
      'Info',
      'Edit customer feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

    // Alternative: Direct edit in dialog (simpler approach)
  void editCustomerDialog(Map<String, dynamic> customer) {
    final nameController = TextEditingController(text: customer['name'] ?? '');
    final mobileController = TextEditingController(text: customer['mobile1'] ?? '');
    final emailController = TextEditingController(text: customer['email'] ?? '');
    final addressController = TextEditingController(text: customer['address'] ?? '');

    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Customer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _performUpdateCustomer(
                        customer['id'],
                        nameController.text,
                        mobileController.text,
                        emailController.text,
                        addressController.text,
                      );
                      Get.back();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

    Future<void> _performUpdateCustomer(
      String customerId,
      String name,
      String mobile,
      String email,
      String address,
      ) async {
    try {
      if (name.isEmpty) {
        Get.snackbar(
          'Error',
          'Name is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final user = _auth.currentUser;
      if (user == null) return;

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";

      final updatedData = {
        'name': name,
        'mobile1': mobile,
        'email': email,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .collection("customers")
          .doc(customerId)
          .update(updatedData);

      // Update local list
      final index = customers.indexWhere((c) => c['id'] == customerId);
      if (index != -1) {
        customers[index] = {
          ...customers[index],
          ...updatedData,
        };
        customers.refresh(); // Notify listeners
      }

      Get.snackbar(
        'Success',
        'Customer updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error updating customer: $e");
      Get.snackbar(
        'Error',
        'Failed to update customer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void createInvoiceForCustomer(Map<String, dynamic> customer) {
    // Navigate to create invoice with pre-selected customer
    Get.toNamed(ItemScreen.pageId, arguments: {'customerId': customer['id']});
  }

  void deleteCustomer(Map<String, dynamic> customer) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performDeleteCustomer(customer);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteCustomer(Map<String, dynamic> customer) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      String companyId = await sharedPreferencesHelper.getPrefData("CompanyId").toString();

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .doc(companyId)
          .collection("customers")
          .doc(customer['id'])
          .update({'isActive': false});

      customers.removeWhere((c) => c['id'] == customer['id']);
      customerCount.value = customers.length;

      Get.snackbar(
        'Success',
        'Customer deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error deleting customer: $e");
      Get.snackbar(
        'Error',
        'Failed to delete customer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}


///new Code not Workig update
// class CustomerListController extends BaseController {
//   var customers = <Map<String, dynamic>>[].obs;
//   var customerCount = 0.obs;
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
//   Future<void> loadCustomers() async {
//     try {
//       isLoading.value = true;
//
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       // Get current company ID from SharedPreferences or arguments
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       print("Company ID: $companyId");
//
//       print("--------CL----Cmpny ID: ${companyId}");
//       if (companyId.isEmpty) {
//         // No company selected, show message
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
//       // Load customers from Firebase
//       final customersSnapshot = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers")
//           .where('isActive', isEqualTo: true)
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       customers.clear();
//       for (var doc in customersSnapshot.docs) {
//         final customerData = doc.data();
//         customerData['id'] = doc.id;
//         customers.add(customerData);
//       }
//
//       customerCount.value = customers.length;
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
//     }
//   }
//
//   Future<void> refreshCustomers() async {
//     await loadCustomers();
//   }
//
//   void navigateToAddNewCustomer() {
//     // Navigate to company selection screen first
//     Get.toNamed(CompanySelectionScreen.pageId);
//   }
//
//   void viewCustomerDetails(Map<String, dynamic> customer) {
//     // Navigate to customer details screen
//     // Get.toNamed(CustomerDetailsScreen.pageId, arguments: customer);
//
//     // For now, show customer info
//     Get.dialog(
//       Dialog(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Customer Details',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 16),
//               Text('Name: ${customer['name'] ?? 'N/A'}'),
//               Text('Mobile: ${customer['mobile'] ?? 'N/A'}'),
//               Text('Email: ${customer['email'] ?? 'N/A'}'),
//               Text('Address: ${customer['address'] ?? 'N/A'}'),
//               SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Get.back(),
//                     child: Text('Close'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void editCustomer(Map<String, dynamic> customer) {
//     // Navigate to edit customer screen with customer data
//     Get.toNamed(
//       AddEditCustomerScreen.pageId, // You'll need to create this screen
//       arguments: {
//         'customer': customer,
//         'isEditing': true,
//       },
//     )?.then((result) {
//       // Refresh customers list after editing
//       if (result == true) {
//         loadCustomers();
//       }
//     });
//   }
//
//   // Alternative: Direct edit in dialog (simpler approach)
//   void editCustomerDialog(Map<String, dynamic> customer) {
//     final nameController = TextEditingController(text: customer['name'] ?? '');
//     final mobileController = TextEditingController(text: customer['mobile'] ?? '');
//     final emailController = TextEditingController(text: customer['email'] ?? '');
//     final addressController = TextEditingController(text: customer['address'] ?? '');
//
//     Get.dialog(
//       Dialog(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Edit Customer',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: mobileController,
//                 decoration: InputDecoration(
//                   labelText: 'Mobile',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: addressController,
//                 decoration: InputDecoration(
//                   labelText: 'Address',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Get.back(),
//                     child: Text('Cancel'),
//                   ),
//                   SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                       await _performUpdateCustomer(
//                         customer['id'],
//                         nameController.text,
//                         mobileController.text,
//                         emailController.text,
//                         addressController.text,
//                       );
//                       Get.back();
//                     },
//                     child: Text('Save'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _performUpdateCustomer(
//       String customerId,
//       String name,
//       String mobile,
//       String email,
//       String address,
//       ) async {
//     try {
//       if (name.isEmpty) {
//         Get.snackbar(
//           'Error',
//           'Name is required',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         return;
//       }
//
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//
//       final updatedData = {
//         'name': name,
//         'mobile': mobile,
//         'email': email,
//         'address': address,
//         'updatedAt': FieldValue.serverTimestamp(),
//       };
//
//       await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers")
//           .doc(customerId)
//           .update(updatedData);
//
//       // Update local list
//       final index = customers.indexWhere((c) => c['id'] == customerId);
//       if (index != -1) {
//         customers[index] = {
//           ...customers[index],
//           ...updatedData,
//         };
//         customers.refresh(); // Notify listeners
//       }
//
//       Get.snackbar(
//         'Success',
//         'Customer updated successfully',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       print("Error updating customer: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to update customer',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   void createInvoiceForCustomer(Map<String, dynamic> customer) {
//     // Navigate to create invoice with pre-selected customer
//     Get.toNamed(ItemScreen.pageId, arguments: {'customerId': customer['id']});
//   }
//
//   void deleteCustomer(Map<String, dynamic> customer) {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Delete Customer'),
//         content: Text('Are you sure you want to delete ${customer['name']}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Get.back();
//               await _performDeleteCustomer(customer);
//             },
//             child: Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _performDeleteCustomer(Map<String, dynamic> customer) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId").toString();
//
//       await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .collection("customers")
//           .doc(customer['id'])
//           .update({'isActive': false});
//
//       customers.removeWhere((c) => c['id'] == customer['id']);
//       customerCount.value = customers.length;
//
//       Get.snackbar(
//         'Success',
//         'Customer deleted successfully',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       print("Error deleting customer: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to delete customer',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
// }