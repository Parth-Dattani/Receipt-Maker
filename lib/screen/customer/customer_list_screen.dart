import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';

class CustomerListScreen extends GetView<CustomerListController> {
  static const String pageId = '/CustomerListScreen';

  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
        backgroundColor: Colors.blueAccent.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshCustomers,
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Customer Count Header
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.orange.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Customers',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${controller.customerCount.value}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Add New Customer Button
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.navigateToAddNewCustomer,
              icon: Icon(Icons.person_add, color: Colors.white),
              label: Text(
                'Add New Customer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Customer List
          Expanded(
            child: controller.customers.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: controller.refreshCustomers,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final customer = controller.customers[index];
                  return _buildCustomerCard(customer);
                },
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No Customers Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first customer to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.navigateToAddNewCustomer,
            icon: Icon(Icons.person_add),
            label: Text('Add Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Text(
            (customer['name'] ?? 'U')[0].toUpperCase(),
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer['name'] ?? 'Unknown Customer',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (customer['mobile1'] != null && customer['mobile1'].isNotEmpty)
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    customer['mobile1'],
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            if (customer['email'] != null && customer['email'].isNotEmpty)
              Row(
                children: [
                  Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    customer['email'],
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
              value: 'edit',
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.receipt, size: 20),
                  SizedBox(width: 8),
                  Text('Create Invoice'),
                ],
              ),
              value: 'invoice',
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
              value: 'delete',
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                controller.editCustomerDialog(customer);
                break;
              case 'invoice':
                controller.createInvoiceForCustomer(customer);
                break;
              case 'delete':
                controller.deleteCustomer(customer);
                break;
            }
          },
        ),
        onTap: () => controller.viewCustomerDetails(customer),
      ),
    );
  }
}


///new UI
// class CustomerListScreen extends GetView<CustomerListController> {
//   static const String pageId = '/CustomerListScreen';
//
//   const CustomerListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text(
//           'Customers',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: Colors.indigo.shade600,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed:
//             (){}
//             //controller.showSearchDialog
//             ,
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: controller.refreshCustomers,
//           ),
//         ],
//       ),
//       body: Obx(() => controller.isLoading.value
//           ? const Center(
//         child: CircularProgressIndicator(
//           color: Colors.indigo,
//         ),
//       )
//           : CustomScrollView(
//         slivers: [
//           // Header Stats Section
//           SliverToBoxAdapter(
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildStatsCard(
//                       icon: Icons.people_rounded,
//                       title: 'Total Customers',
//                       value: '${controller.customerCount.value}',
//                       color: Colors.indigo,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildStatsCard(
//                       icon: Icons.person_add_rounded,
//                       title: 'This Month',
//                       value: '${controller.customerCount.value}',
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Action Buttons Section
//           SliverToBoxAdapter(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: ElevatedButton.icon(
//                       onPressed: controller.navigateToAddNewCustomer,
//                       icon: const Icon(Icons.person_add_rounded),
//                       label: const Text('Add Customer'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.indigo.shade600,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 2,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: (){}, //controller.exportCustomers,
//                       icon: const Icon(Icons.download_rounded),
//                       label: const Text('Export'),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.indigo.shade600,
//                         side: BorderSide(color: Colors.indigo.shade600),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           const SliverToBoxAdapter(child: SizedBox(height: 20)),
//
//           // Customer List Section
//           controller.customers.isEmpty
//               ? SliverToBoxAdapter(child: _buildEmptyState())
//               : SliverList(
//             delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                 final customer = controller.customers[index];
//                 return _buildEnhancedCustomerCard(customer, index);
//               },
//               childCount: controller.customers.length,
//             ),
//           ),
//
//           const SliverToBoxAdapter(child: SizedBox(height: 80)),
//         ],
//       )),
//
//     );
//   }
//
//   Widget _buildStatsCard({
//     required IconData icon,
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade200,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               color: Colors.grey.shade800,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Container(
//       margin: const EdgeInsets.all(32),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.indigo.shade50,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.people_outline_rounded,
//               size: 64,
//               color: Colors.indigo.shade300,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No Customers Yet',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Start building your customer base by adding your first customer',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade500,
//               height: 1.4,
//             ),
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton.icon(
//             onPressed: controller.navigateToAddNewCustomer,
//             icon: const Icon(Icons.person_add_rounded),
//             label: const Text('Add Your First Customer'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.indigo.shade600,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEnhancedCustomerCard(Map<String, dynamic> customer, int index) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Card(
//         elevation: 2,
//         shadowColor: Colors.grey.shade200,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: InkWell(
//           onTap: () => controller.viewCustomerDetails(customer),
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Avatar with better design
//                 Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.indigo.shade400,
//                         Colors.indigo.shade600,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Center(
//                     child: Text(
//                       (customer['name'] ?? 'U')[0].toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//
//                 // Customer Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         customer['name'] ?? 'Unknown Customer',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       if (customer['mobile'] != null && customer['mobile'].isNotEmpty)
//                         Row(
//                           children: [
//                             Icon(Icons.phone_rounded,
//                                 size: 16, color: Colors.grey.shade600),
//                             const SizedBox(width: 6),
//                             Text(
//                               customer['mobile'],
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       if (customer['email'] != null && customer['email'].isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4),
//                           child: Row(
//                             children: [
//                               Icon(Icons.email_rounded,
//                                   size: 16, color: Colors.grey.shade600),
//                               const SizedBox(width: 6),
//                               Flexible(
//                                 child: Text(
//                                   customer['email'],
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 14,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//
//                 /// Action Menu
//                 PopupMenuButton(
//                   icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit_rounded, size: 20, color: Colors.blue),
//                           const SizedBox(width: 12),
//                           const Text('Edit'),
//                         ],
//                       ),
//                       value: 'edit',
//                     ),
//                     PopupMenuItem(
//                       child: Row(
//                         children: [
//                           Icon(Icons.receipt_long_rounded, size: 20, color: Colors.green),
//                           const SizedBox(width: 12),
//                           const Text('Create Invoice'),
//                         ],
//                       ),
//                       value: 'invoice',
//                     ),
//                     const PopupMenuDivider(),
//                     PopupMenuItem(
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete_rounded, size: 20, color: Colors.red),
//                           const SizedBox(width: 12),
//                           Text('Delete', style: TextStyle(color: Colors.red)),
//                         ],
//                       ),
//                       value: 'delete',
//                     ),
//                   ],
//                   onSelected: (value) {
//                     switch (value) {
//                       case 'edit':
//                         controller.editCustomer(customer);
//                         break;
//                       case 'invoice':
//                         controller.createInvoiceForCustomer(customer);
//                         break;
//                       case 'delete':
//                         controller.deleteCustomer(customer);
//                         break;
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
// }


///Editscreen Code
// class AddEditCustomerScreen extends StatelessWidget {
//   static const String pageId = '/addEditCustomer';
//
//   final Map<String, dynamic>? customer;
//   final bool isEditing;
//
//   AddEditCustomerScreen({Key? key, this.customer, this.isEditing = false}) : super(key: key);
//
//   final nameController = TextEditingController();
//   final mobileController = TextEditingController();
//   final emailController = TextEditingController();
//   final addressController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     // Pre-fill fields if editing
//     if (isEditing && customer != null) {
//       nameController.text = customer!['name'] ?? '';
//       mobileController.text = customer!['mobile'] ?? '';
//       emailController.text = customer!['email'] ?? '';
//       addressController.text = customer!['address'] ?? '';
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Name*'),
//             ),
//             TextField(
//               controller: mobileController,
//               decoration: InputDecoration(labelText: 'Mobile'),
//               keyboardType: TextInputType.phone,
//             ),
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             TextField(
//               controller: addressController,
//               decoration: InputDecoration(labelText: 'Address'),
//               maxLines: 3,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _saveCustomer(context),
//               child: Text(isEditing ? 'Update Customer' : 'Add Customer'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _saveCustomer(BuildContext context) async {
//     if (nameController.text.isEmpty) {
//       Get.snackbar('Error', 'Name is required');
//       return;
//     }
//
//     final controller = Get.find<CustomerListController>();
//
//     if (isEditing) {
//       await controller._performUpdateCustomer(
//         customer!['id'],
//         nameController.text,
//         mobileController.text,
//         emailController.text,
//         addressController.text,
//       );
//     } else {
//       // Add your add customer logic here
//     }
//
//     Get.back(result: true); // Return to previous screen with success result
//   }
// }


///------------
///
///
///
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