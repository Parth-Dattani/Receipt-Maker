import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';


class CustomerListScreen extends GetView<CustomerListController> {
  static const String pageId = '/CustomerListScreen';

  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoader(context);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildWebLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          );
        }),
      ),
    );
  }

  // Adaptive AppBar
  AppBar _buildAppBar(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 900;
    return AppBar(
      foregroundColor: Colors.white,
      elevation: 0,
      backgroundColor: AppColors.tealColor,
      title: Text(
        'customers'.tr,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
      ),
      centerTitle: !isWeb,
      actions: [
        if (!isWeb) ...[
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) => controller.sortCustomers(value),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'name_asc', child: _buildSortItemMobile(Icons.sort_by_alpha, 'Name (A-Z)')),
              PopupMenuItem(value: 'name_desc', child: _buildSortItemMobile(Icons.sort_by_alpha, 'Name (Z-A)')),
              PopupMenuItem(value: 'recent', child: _buildSortItemMobile(Icons.access_time, 'Recently Added')),
            ],
          ),
          const SizedBox(width: 12),
        ]
      ],
    );
  }

  Widget _buildSortItemMobile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.tealColor),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT
  // ===========================================================================
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(isWeb: false),
        _buildCustomerCountHeaderMobile(),
        _buildAddButtonMobile(),
        const SizedBox(height: 16),
        Expanded(child: _buildCustomerListMobile(context)),
      ],
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Sidebar + Grid)
  // ===========================================================================
  Widget _buildWebLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT SIDEBAR (Fixed Width) ---
        Container(
          width: 300,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Clients Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.tealColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.tealColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('total_customers'.tr, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          Obx(() => Text('${controller.filteredCustomerList.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Search Section
              const Text("Search & Filter", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              _buildSearchBar(isWeb: true),

              const SizedBox(height: 32),

              // Sort Section
              const Text("Sort By", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              _buildWebSortOption('name_asc', Icons.sort_by_alpha, "Name (A-Z)"),
              _buildWebSortOption('name_desc', Icons.sort_by_alpha, "Name (Z-A)"),
              _buildWebSortOption('recent', Icons.access_time, "Recently Added"),
            ],
          ),
        ),

        // --- RIGHT CONTENT (Grid) ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Customer Directory", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 20),
                Expanded(child: _buildCustomerGridWeb(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 🔍 DIALOG FIX: CUSTOMER DETAILS
  // ===========================================================================

  void _showCustomerDetailsDialog(BuildContext context, Map<String, dynamic> customer) {
    final name = customer['name'] ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          // ✅ KEY FIX: Limit width on Web, full width (with padding) on Mobile
          width: MediaQuery.of(context).size.width > 900 ? 600 : double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Avatar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.tealColor.withOpacity(0.1),
                      child: Text(initial, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 40),

                // Contact Info Section
                _buildSectionTitle("Contact Information"),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.phone, "Mobile", customer['mobile1']),
                _buildDetailRow(Icons.email, "Email", customer['email']),

                const SizedBox(height: 24),

                // Address Section
                _buildSectionTitle("Address"),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.home, "Address", customer['address'] ?? customer['customerAddress']), // Handle various key names
                _buildDetailRow(Icons.location_city, "City", customer['city']),
                _buildDetailRow(Icons.map, "State", customer['state']),
                _buildDetailRow(Icons.flag, "Country", "India"), // Assuming India default
                _buildDetailRow(Icons.pin_drop, "Pincode", customer['pincode']),

                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Close", style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.editCustomer(customer);
                      },
                      icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                      label: const Text("Edit", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.tealColor),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 🧩 WEB COMPONENTS
  // ===========================================================================

  Widget _buildWebSortOption(String sortKey, IconData icon, String label) {
    return InkWell(
      onTap: () => controller.sortCustomers(sortKey),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerGridWeb(BuildContext context) {
    return Obx(() {
      if (controller.filteredCustomerList.isEmpty) {
        return _buildEmptyState();
      }
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.filteredCustomerList.length,
        itemBuilder: (context, index) {
          final customer = controller.filteredCustomerList[index];
          return _buildWebCustomerCard(context, customer);
        },
      );
    });
  }

  Widget _buildWebCustomerCard(BuildContext context, Map<String, dynamic> customer) {
    final isActive = (customer['isActive']?.toString() ?? 'true').toLowerCase() == 'true';
    final name = customer['name'] ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Material( // ✅ Enable Ripple
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isActive ? () => _showCustomerDetailsDialog(context, customer) : null, // ✅ CALL LOCAL DIALOG
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.tealColor.withOpacity(0.1),
                      child: Text(initial, style: TextStyle(color: AppColors.tealColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    _buildPopupMenu(customer, isActive),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),
                // Details
                Flexible(child: _buildInfoRow(Icons.phone_outlined, customer['mobile1'] ?? 'No Mobile')),
                const SizedBox(height: 8),
                Flexible(child: _buildInfoRow(Icons.location_on_outlined, '${customer['city'] ?? ''}${customer['state'] != null && customer['state'].isNotEmpty ? ', ${customer['state']}' : ''}')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text.isEmpty ? 'N/A' : text,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 📱 MOBILE COMPONENTS
  // ===========================================================================

  Widget _buildSearchBar({required bool isWeb}) {
    return Container(
      margin: isWeb ? EdgeInsets.zero : const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 8 : 12),
        border: isWeb ? Border.all(color: Colors.grey.shade300) : null,
        boxShadow: isWeb ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: TextField(
        onChanged: (value) => controller.searchCustomers(value),
        decoration: InputDecoration(
          hintText: 'search_hint'.tr,
          prefixIcon:  Icon(Icons.search, color: AppColors.tealColor),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(icon:  Icon(Icons.clear, color: AppColors.tealColor), onPressed: controller.clearSearch)
              : const SizedBox()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCustomerCountHeaderMobile() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.tealColor, AppColors.tealColor.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: AppColors.tealColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.people, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('total_customers'.tr, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                // No Obx here, parent Obx handles it
                Text('${controller.filteredCustomerList.length}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                if (controller.searchQuery.value.isNotEmpty)
                  Text('of ${controller.customerCount.value} total', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButtonMobile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.navigateToAddNewCustomer,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text('add_new_customer'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _buildCustomerListMobile(BuildContext context) {
    return Obx(() {
      if (controller.filteredCustomerList.isEmpty) return _buildEmptyState();
      return RefreshIndicator(
        onRefresh: controller.refreshCustomers,
        color: AppColors.tealColor,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.filteredCustomerList.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.filteredCustomerList.length) {
              return Obx(() => controller.hasMore.value ? _buildLoadMoreButton() : const SizedBox(height: 20));
            }
            final customer = controller.filteredCustomerList[index];
            return _buildCustomerCardMobile(context, customer);
          },
        ),
      );
    });
  }

  Widget _buildCustomerCardMobile(BuildContext context, Map<String, dynamic> customer) {
    final isActive = (customer['isActive']?.toString() ?? 'true').toLowerCase() == 'true';
    final name = customer['name'] ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? Colors.white : Colors.red.shade50,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: isActive ? AppColors.tealColor.withOpacity(0.1) : Colors.grey.shade200,
            child: Text(initial, style: TextStyle(color: isActive ? AppColors.tealColor : Colors.grey.shade500, fontWeight: FontWeight.bold)),
          ),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: isActive ? Colors.black87 : Colors.grey)),
          subtitle: Text(customer['mobile1'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          trailing: _buildPopupMenu(customer, isActive),
          onTap: isActive ? () => _showCustomerDetailsDialog(context, customer) : null, // ✅ CALL LOCAL DIALOG
        ),
      ),
    );
  }

  Widget _buildPopupMenu(Map<String, dynamic> customer, bool isActive) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        if (isActive) ...[
          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.orange, size: 18), SizedBox(width: 8), Text('Edit')])),
          const PopupMenuItem(value: 'invoice', child: Row(children: [Icon(Icons.receipt, color: Colors.green, size: 18), SizedBox(width: 8), Text('Create Invoice')])),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete')])),
        ] else ...[
          const PopupMenuItem(value: 'restore', child: Row(children: [Icon(Icons.restore, color: Colors.green, size: 18), SizedBox(width: 8), Text('Restore')])),
        ],
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit': controller.editCustomer(customer); break;
          case 'invoice': controller.createInvoiceForCustomer(customer); break;
          case 'delete': controller.deleteCustomer(customer); break;
        }
      },
    );
  }

  Widget _buildShimmerLoader(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 900;
    return isWeb
        ? GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, childAspectRatio: 1.6, crossAxisSpacing: 20, mainAxisSpacing: 20),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Container(height: 80)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No Customers Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.navigateToAddNewCustomer,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor),
            child: const Text("Add Customer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tealColor))));
  }
}


