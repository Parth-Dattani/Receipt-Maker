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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor,)),
        elevation: 4,
        backgroundColor: AppColors.tealColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          'Customers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // Toggle inactive customers visibility
          Obx(() => IconButton(
            icon: Icon(
              controller.showInactiveCustomers.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: controller.toggleShowInactive,
            tooltip: controller.showInactiveCustomers.value
                ? 'Hide Inactive Customers'
                : 'Show Inactive Customers',
          )),
          // Sort Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) => controller.sortCustomers(value),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name_asc',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha,
                        size: 20, color: AppColors.tealColor),
                    SizedBox(width: 8),
                    Text('Name (A-Z)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name_desc',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha,
                        size: 20, color: AppColors.tealColor),
                    SizedBox(width: 8),
                    Text('Name (Z-A)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 20, color: AppColors.tealColor),
                    SizedBox(width: 8),
                    Text('Recently Added'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoader();
          }
        
          return Column(
            children: [
              // Search Bar
              Container(
                margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  onChanged: (value) => controller.searchCustomers(value),
                  decoration: InputDecoration(
                    hintText: 'Search by name, mobile, or email...',
                    prefixIcon: Icon(Icons.search, color: AppColors.tealColor),
                    suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.tealColor),
                      onPressed: controller.clearSearch,
                    )
                        : SizedBox()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
        
              // Customer Count Header
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.tealColor,
                      AppColors.tealColor.withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tealColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Obx(() => Text(
                            '${controller.filteredCustomerList.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          if (controller.searchQuery.value.isNotEmpty)
                            Text(
                              'of ${controller.customerCount.value} total',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
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
                    backgroundColor: AppColors.tealColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: AppColors.tealColor.withOpacity(0.3),
                  ),
                ),
              ),
        
              SizedBox(height: 16),
        
              // Customer List
              Expanded(
                child: Obx(() {
                  if (controller.filteredCustomerList.isEmpty) {
                    return controller.searchQuery.value.isNotEmpty
                        ? _buildNoSearchResults()
                        : _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: controller.refreshCustomers,
                    color: AppColors.tealColor,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.filteredCustomerList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.filteredCustomerList.length) {
                          return Obx(() => controller.hasMore.value
                              ? _buildLoadMoreButton()
                              : _buildEndOfList());
                        }
        
                        final customer = controller.filteredCustomerList[index];
                        return _buildCustomerCard(customer, index);
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Stylish shimmer loader
  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 100,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 20),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.clearSearch,
            icon: Icon(Icons.clear),
            label: Text('Clear Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealColor,
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

  Widget _buildLoadMoreButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Obx(() => ElevatedButton.icon(
        onPressed: controller.isLoadingMore.value
            ? null
            : controller.loadMoreCustomers,
        icon: controller.isLoadingMore.value
            ? SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(Icons.arrow_downward),
        label: Text(
          controller.isLoadingMore.value
              ? 'Loading...'
              : 'Load More Customers',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )),
    );
  }

  Widget _buildEndOfList() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Divider(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.tealColor, size: 20),
              SizedBox(width: 8),
              Text(
                'All customers loaded',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 100,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 20),
          Text(
            'No Customers Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Add your first customer using the + button',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: controller.navigateToAddNewCustomer,
            icon: Icon(Icons.person_add),
            label: Text('Add Your First Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer, int index) {
    final isActive = customer['isActive'] ?? true;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: AppColors.tealColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isActive ? Colors.white : Colors.red.shade50,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isActive
                    ? AppColors.tealColor.withOpacity(0.15)
                    : Colors.grey.shade200,
                child: Text(
                  (customer['name'] ?? 'U')[0].toUpperCase(),
                  style: TextStyle(
                    color:
                    isActive ? AppColors.tealColor : Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              if (!isActive)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.block,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  customer['name'] ?? 'Unknown Customer',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isActive ? Colors.black87 : Colors.grey.shade500,
                    decoration: isActive
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                  ),
                ),
              ),
              if (customer['businessName'] != null &&
                  customer['businessName'].isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tealColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Business',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.tealColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              if (customer['mobile1'] != null && customer['mobile1'].isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                      SizedBox(width: 6),
                      Text(
                        customer['mobile1'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              if (customer['email'] != null && customer['email'].isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          customer['email'],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (customer['city'] != null && customer['city'].isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: Colors.grey.shade600),
                    SizedBox(width: 6),
                    Text(
                      '${customer['city']}${customer['state'] != null && customer['state'].isNotEmpty ? ', ${customer['state']}' : ''}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              if (isActive) ...[
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.orange),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                  value: 'edit',
                ),
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(Icons.receipt, size: 20, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Create Invoice'),
                    ],
                  ),
                  value: 'invoice',
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  value: 'delete',
                ),
              ] else ...[
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(Icons.restore, size: 20, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Restore Customer'),
                    ],
                  ),
                  value: 'restore',
                ),
              ],
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  controller.editCustomer(customer);
                  break;
                case 'invoice':
                  controller.createInvoiceForCustomer(customer);
                  break;
                case 'delete':
                  controller.deleteCustomer(customer);
                  break;
                case 'restore':
                  controller.restoreCustomer(customer);
                  break;
              }
            },
          ),
          onTap: isActive ? () => controller.viewCustomerDetails(customer) : null,
        ),
      ),
    );
  }
}