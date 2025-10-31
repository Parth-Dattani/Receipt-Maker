import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';


class ChallanListScreen extends GetView<ChallanListController> {
  static const String pageId = '/ChallanListScreen';

  const ChallanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('challans'.tr),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshChallans,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isDataLoading) { // ✅ computed bool
          return _buildFullShimmer();
        }

        if (controller.filteredChallanList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildSearchFilterSection(),
            _buildStatisticsSection(),
            Expanded(child: _buildChallanList()),
          ],
        );
      }),
    );
  }

  Widget _buildStatisticsSection() {
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: controller.isLoading.value // ✅ RxBool for actions
          ? _buildShimmerStatistics()
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('total'.tr, controller.totalChallans.toString(), AppColors.tealColor),
          _buildStatItem('delivered'.tr, controller.deliveredChallans.toString(), Colors.green),
          _buildStatItem('pending'.tr, controller.pendingChallans.toString(), Colors.orange),
          _buildStatItem('in_transit'.tr, controller.inTransitChallans.toString(), Colors.purple),
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
                _buildFilterChip('all'.tr, controller.selectedFilter.value == 'All'),
                SizedBox(width: 8),
                _buildFilterChip('delivered'.tr, controller.selectedFilter.value == 'Delivered'),
                SizedBox(width: 8),
                _buildFilterChip('pending'.tr, controller.selectedFilter.value == 'Pending'),
                SizedBox(width: 8),
                _buildFilterChip('in_transit'.tr, controller.selectedFilter.value == 'In Transit'),
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
      selectedColor: AppColors.tealColor,
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
            'no_challans_found'.tr,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            'create_your_first_challan_to_get_started'.tr,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed('/new-challan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealColor,
              foregroundColor: Colors.white,
            ),
            child: Text('create_challan'.tr),
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
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.tealColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.viewChallanDetails(challan),
          borderRadius: BorderRadius.circular(18),
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
                SizedBox(width: 12),

                // Challan content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${challan.challanId} - ${challan.customerName}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.tealColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(challan.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              challan.status?.toUpperCase() ?? 'UNKNOWN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(challan.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
                SizedBox(width: 8),

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
                          Icon(Icons.visibility, size: 20, color: AppColors.tealColor),
                          SizedBox(width: 12),
                          Text('view_details'.tr, style: TextStyle(color: AppColors.tealColor)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'export_pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, size: 20, color: Colors.orange.shade700),
                          SizedBox(width: 12),
                          Text('export_as_pdf'.tr, style: TextStyle(color: Colors.orange.shade700)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        controller.viewChallanDetails(challan);
                        break;
                      case 'export_pdf':
                        controller.exportChallanAsPdf(challan);
                        break;
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

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerChallanListItem(),
    );
  }

  Widget _buildShimmerChallanListItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.tealColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 60,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

