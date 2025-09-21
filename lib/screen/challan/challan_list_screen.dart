import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../controller/controller.dart';
import '../../model/model.dart';

class ChallanListScreen extends GetView<ChallanListController> {
  static const String pageId = '/ChallanListScreen';

  const ChallanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challans'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshChallans,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.toNamed('/new-challan'),
            tooltip: 'Create New Challan',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildFullShimmer();
        }
        return Column(
          children: [
            /// Search and Filter Section
            _buildSearchFilterSection(),
            /// Statistics Section
            _buildStatisticsSection(),

            Expanded(
              child: controller.filteredChallanList.isEmpty
                  ? _buildEmptyState()
                  : _buildChallanList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatisticsSection() {
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: controller.isLoading.value
          ? _buildShimmerStatistics()
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', controller.totalChallans.toString(), Colors.blue),
          _buildStatItem('Delivered', controller.deliveredChallans.toString(), Colors.green),
          _buildStatItem('Pending', controller.pendingChallans.toString(), Colors.orange),
          _buildStatItem('In Transit', controller.inTransitChallans.toString(), Colors.purple),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search challans...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: controller.filterChallans,
          ),
          SizedBox(height: 12),

          // Filter Chips
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', controller.selectedFilter.value == 'All'),
                SizedBox(width: 8),
                _buildFilterChip('Delivered', controller.selectedFilter.value == 'Delivered'),
                SizedBox(width: 8),
                _buildFilterChip('Pending', controller.selectedFilter.value == 'Pending'),
                SizedBox(width: 8),
                _buildFilterChip('In Transit', controller.selectedFilter.value == 'In Transit'),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => controller.filterByStatus(label),
      selectedColor: Colors.blue.shade700,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No challans found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first challan to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed('/new-challan'),
            child: Text('Create Challan'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallanList() {
    return Obx(() => ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      itemCount: controller.filteredChallanList.length,
      itemBuilder: (context, index) {
        final challan = controller.filteredChallanList[index];
        return _buildChallanListItem(challan);
      },
    ));
  }

  Widget _buildChallanListItem(Challan challan) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          onTap: () => controller.viewChallanDetails(challan),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getStatusColor(challan.status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 16),

                // Challan content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${challan.challanId} - ${challan.customerName}" ?? 'No ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(challan.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              challan.status?.toUpperCase() ?? 'UNKNOWN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(challan.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       DateFormat('MMM dd, yyyy').format(challan.issueDate ?? DateTime.now()),
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //         color: Colors.grey.shade600,
                      //       ),
                      //     ),
                      //     Text(
                      //       '${challan.totalItems ?? 0} Items',
                      //       style: TextStyle(
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.blue.shade700,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                // Action button
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 20, color: Colors.blue.shade700),
                          SizedBox(width: 12),
                          Text('View Details', style: TextStyle(color: Colors.blue.shade700)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'export_pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, size: 20, color: Colors.orange.shade700),
                          SizedBox(width: 12),
                          Text('Export as PDF', style: TextStyle(color: Colors.orange.shade700)),
                        ],
                      ),
                    ),
                    // PopupMenuItem(
                    //   value: 'edit',
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.edit, size: 20, color: Colors.green.shade700),
                    //       SizedBox(width: 12),
                    //       Text('Edit', style: TextStyle(color: Colors.green.shade700)),
                    //     ],
                    //   ),
                    // ),
                    // PopupMenuItem(
                    //   value: 'delete',
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                    //       SizedBox(width: 12),
                    //       Text('Delete', style: TextStyle(color: Colors.red.shade700)),
                    //     ],
                    //   ),
                    // ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        controller.viewChallanDetails(challan);
                        break;
                      case 'export_pdf':
                        controller.exportChallanAsPdf(challan);
                        break;
                      // case 'edit':
                      //   controller.editChallan(challan);
                      //   break;
                      // case 'delete':
                      //   controller.deleteChallan(challan);
                      //   break;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in transit':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // 🔹 FULL PAGE SHIMMER
  Widget _buildFullShimmer() {
    return Column(
      children: [
        _buildShimmerSearchFilterSection(),
        _buildShimmerStatistics(),
        Expanded(
          child: _buildShimmerLoading(),
        ),
      ],
    );
  }

  // 🔹 Shimmer for search + filter
  Widget _buildShimmerSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              3,
                  (_) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 60,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 🔹 Shimmer for challan list
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerChallanListItem(),
    );
  }

  Widget _buildShimmerChallanListItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: const CircleAvatar(
            backgroundColor: Colors.grey,
          ),
        ),
        title: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 150,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        trailing: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Shimmer for statistics
  Widget _buildShimmerStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (_) => _buildShimmerStatItem()),
      ),
    );
  }

  Widget _buildShimmerStatItem() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 40,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 30,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}