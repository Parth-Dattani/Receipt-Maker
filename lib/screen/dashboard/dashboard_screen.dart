import 'package:demo_prac_getx/constant/app_constant.dart' show AppConstants;
import 'package:demo_prac_getx/screen/dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controller/controller.dart';
import '../screen.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends GetView<DashboardController> {
  static const String pageId = '/DashboardScreen';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkSubscriptionStatus();
    });
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          controller.scaffoldKey.currentState?.openDrawer();
        },
            icon: Icon(Icons.menu)),
        title: Text('Invoice Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: controller.navigateToChallanList,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshDashboard,
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? const DashboardShimmer()
          : RefreshIndicator(
        onRefresh: () async => controller.refreshDashboard(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Here\'s your business overview',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Statistics Cards
              DashboardStatsCard(),

              SizedBox(height: 20),

              // Quick Actions
              QuickActionsGrid(),

              SizedBox(height: 20),

              // Charts Section
              Row(
                children: [
                  // Expanded(child: RevenueChartCard()),
                  // SizedBox(width: 10),
                  Expanded(
                      flex: 1,
                      child: InvoiceStatusChart()),
                Expanded(child: Container())
                ],
              ),

              SizedBox(height: 20),

              // Recent Invoices
              RecentInvoicesCard(),
            ],
          ),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.exportInvoiceData,
        backgroundColor: Colors.blue.shade700,
        child: Icon(Icons.download, color: Colors.white),
      ),
      drawer: buildDrawer(),
    );
  }

  // Add these methods to your Dashboard screen widget
  Widget _buildQuickActionsSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.person_add,
                    title: 'Add Customer',
                    subtitle: 'Register new customer',
                    color: Colors.green,
                    onTap: () => controller.navigateToAddNewCustomer(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.receipt_long,
                    title: 'New Invoice',
                    subtitle: 'Create invoice',
                    color: Colors.blue,
                    onTap: () => controller.navigateToCreateInvoice(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.people,
                    title: 'View Customers',
                    subtitle: 'Manage customers',
                    color: Colors.orange,
                    onTap: () => controller.navigateToCustomerList(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.analytics,
                    title: 'Reports',
                    subtitle: 'View analytics',
                    color: Colors.purple,
                    onTap: () => controller.navigateToItems(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

// Add this to your floating action button or main action area
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => controller.navigateToAddNewCustomer(),
      backgroundColor: Colors.green,
      icon: Icon(Icons.person_add),
      label: Text('Add Customer'),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with Company Info
          Obx(() => DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(
                      Icons.business,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    controller.companyName.isNotEmpty
                        ? controller.companyName
                        : "No Company Selected",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.hasMultipleCompanies.value)
                    GestureDetector(
                      onTap: controller.showCompanySwitcher,
                      child: Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Switch Company",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.dashboard, color: Colors.blue.shade700),
                  title: Text("Dashboard"),
                  onTap: () => Get.back(),
                ),
                ListTile(
                  leading: Icon(Icons.person_add, color: Colors.green),
                  title: Text("Add Customer"),
                  onTap: () {
                    Get.back();
                    controller.navigateToAddNewCustomer();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.receipt_long, color: Colors.blue),
                  title: Text("Create Invoice"),
                  onTap: () {
                    Get.back();
                    controller.navigateToCreateInvoice();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.people, color: Colors.orange),
                  title: Text("View Customers"),
                  onTap: () {
                    Get.back();
                    controller.navigateToCustomerList();
                  },
                ),

                // 🔹 Challan Toggle
                Obx(() => ListTile(
                  leading: Icon(Icons.list_alt, color: Colors.green),
                  title: Text("Enable Challan Feature"),
                  trailing: Switch(
                    value: AppConstants.isChallan.value,
                    onChanged: (value) async {
                      await controller.updateCompanyPreference('isChallanEnabled', value);
                    },
                    activeColor: Colors.white,                // thumb when active
                    activeTrackColor: Colors.green.shade600,  // track when active
                    inactiveThumbColor: Colors.white,         // thumb when inactive
                    inactiveTrackColor: Colors.grey.shade400, // track when inactive
                    splashRadius: 28,                         // ripple effect
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Icon(Icons.check, color: Colors.green); // ✅ when ON
                      }
                      return Icon(Icons.close, color: Colors.grey);    // ❌ when OFF
                    }),
                  ),
                )),

// 🔹 GST Toggle
                Obx(() => ListTile(
                  leading: Icon(Icons.attach_money, color: Colors.teal),
                  title: Text("Enable GST Feature"),
                  trailing: Switch(
                    value: AppConstants.withGST.value,
                    onChanged: (value) async {
                      await controller.updateCompanyPreference('isGstEnabled', value);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.teal.shade600,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade400,
                    splashRadius: 28,
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Icon(Icons.check, color: Colors.teal);
                      }
                      return Icon(Icons.close, color: Colors.grey);
                    }),
                  ),
                )),


                ListTile(
                  leading: Icon(Icons.analytics, color: Colors.purple),
                  title: Text("challans"),
                  onTap: () {
                    Get.back();
                    controller.navigateToChallanList();
                  },
                ),
                Divider(),

                // Company Management Section
                if (controller.hasMultipleCompanies.value)
                  ListTile(
                    leading: Icon(Icons.swap_horiz, color: Colors.indigo),
                    title: Text("Switch Company"),
                    onTap: () {
                      Get.back();
                      controller.showCompanySwitcher();
                    },
                  ),

                ListTile(
                  leading: Icon(Icons.add_business, color: Colors.teal),
                  title: Text("Edit Company Info"),
                  // onTap: () {
                  //   controller.navigateToEditCompany(
                  //       controller.companyData,
                  //       controller.companyData['id']);
                  //   // Get.back();
                  //   // Get.toNamed(CompanyRegistrationScreen.pageId);
                  // },
                  onTap: () {
                   // Get.back(); // always close the drawer first
                    final data = controller.companyData;

                    print("CompnyID0----------------:${AppConstants.companyId}");
                    print("CompnyID0-------------2---:${data}");

                    if (AppConstants.companyId.isNotEmpty) {
                      controller.navigateToEditCompany(data, AppConstants.companyId);
                    } else {
                      Get.snackbar(
                        "Error",
                        "No active company found to edit.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.shade100,
                      );
                    }
                  },
                ),

                Divider(),

                // ListTile(
                //   leading: Icon(Icons.settings, color: Colors.grey),
                //   title: Text("Settings"),
                //   onTap: () {
                //     Get.back();
                //     controller.navigateToNewChallan();
                //   },
                // ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        title: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Confirm Logout"),
                          ],
                        ),
                        content: Text(
                          "Are you sure you want to log out?",
                          style: TextStyle(fontSize: 15),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
                            onPressed: () => Get.back(),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Logout"),
                            onPressed: () async {
                              Get.back(); // close dialog
                              await controller.logout();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }


}

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top banner
          _shimmerBox(height: 100, width: double.infinity, borderRadius: 15),

          const SizedBox(height: 20),

          // Statistics cards row
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 100, borderRadius: 12)),
              const SizedBox(width: 10),
              Expanded(child: _shimmerBox(height: 100, borderRadius: 12)),
            ],
          ),

          const SizedBox(height: 20),

          // Quick actions
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => _shimmerBox(borderRadius: 12),
          ),

          const SizedBox(height: 20),

          // Chart placeholders
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 200, borderRadius: 12)),
              const SizedBox(width: 10),
              Expanded(child: _shimmerBox(height: 200, borderRadius: 12)),
            ],
          ),

          const SizedBox(height: 20),

          // Recent invoices list
          Column(
            children: List.generate(
              3,
                  (_) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _shimmerBox(height: 60, borderRadius: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({double height = 80, double? width, double borderRadius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}


class SubscriptionDialog extends StatelessWidget {
  const SubscriptionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium,
                  size: 50,
                  color: Colors.amber.shade300,
                ),
              ),

              SizedBox(height: 20),

              // Title with gradient text
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.amber.shade300, Colors.amber.shade100],
                ).createShader(bounds),
                child: Text(
                  'Premium Access Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 15),

              // Message
              Text(
                'Your 30-day trial period has ended. To continue enjoying all premium features, please contact your authorized representative.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),

              SizedBox(height: 25),

              // Contact card
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildContactInfo(Icons.person, 'Authorized Representative', 'Inteligent Tech'),
                    SizedBox(height: 12),
                    _buildContactInfo(Icons.phone, 'Phone No.', '+91 9512359792'),
                    SizedBox(height: 12),
                    _buildContactInfo(Icons.email, 'Email', 'dattaniparth2@gmail.com'),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Action button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // // Copy phone number to clipboard
                    // Clipboard.setData(ClipboardData(text: '+1 (555) 123-4567'));
                    //
                    // // Show confirmation with GetX
                    // Get.snackbar(
                    //   'Copied!',
                    //   'Phone number copied to clipboard',
                    //   snackPosition: SnackPosition.BOTTOM,
                    //   backgroundColor: Colors.green.shade600,
                    //   colorText: Colors.white,
                    //   borderRadius: 10,
                    //   margin: EdgeInsets.all(15),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade500,
                    foregroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contact_phone, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Contact Representative',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.amber.shade300,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}