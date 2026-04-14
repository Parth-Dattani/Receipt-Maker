import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../widgets/web_screen_wrapper.dart';

import '../screen.dart';



class ChallanListScreen extends GetView<ChallanListController> {
  static const String pageId = '/ChallanListScreen';

  const ChallanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      appBar: AppBar(
        title: Text('challans'.tr),
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshChallans,
            tooltip: 'Refresh',
          ),
          // Web-specific "Add" button
          if (MediaQuery.of(context).size.width > 900)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (Get.isRegistered<NewChallanController>()) {
                    Get.delete<NewChallanController>();
                  }
                  Get.put(NewChallanController());

                  await Get.toNamed(NewChallanScreen.pageId);
                },
                icon: Icon(Icons.add, size: 18, color: AppColors.appTheame),
                label: Text("New Challan", style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.customeBackground,
        child: SafeArea(
          child: Obx(() {
            if (controller.isDataLoading) {
              return LayoutBuilder(builder: (context, constraints) {
                return constraints.maxWidth > 900 ? _buildWebShimmer() : _buildFullShimmer();
              });
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildWebLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            );
          }),
        ),
      ),

    );
    if (kIsWeb) return webScreenWrapper(currentRoute: pageId, child: content);
    return content;
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT
  // ===========================================================================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSearchFilterSection(),
        _buildStatisticsSection(isWeb: false),
        Expanded(
          child: Obx(() {
            if (controller.filteredChallanList.isEmpty) {
              return _buildFilteredEmptyState();
            }
            return _buildChallanList();
          }),
        ),
      ],
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Split View)
  // ===========================================================================
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: List Area (Flex 3)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildSearchFilterSection(),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: Obx(() {
                    if (controller.filteredChallanList.isEmpty) {
                      return _buildFilteredEmptyState();
                    }
                    return _buildChallanList();
                  }),
                ),
              ),
            ],
          ),
        ),

        // RIGHT: Statistics Panel (Flex 1 - Fixed)
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appTheame,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatisticsSection(isWeb: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 🧩 SHARED WIDGETS
  // ===========================================================================

  Widget _buildStatisticsSection({required bool isWeb}) {
    return Obx(() {
      if (controller.isLoading.value) return _buildShimmerStatistics();

      if (isWeb) {
        // Vertical Layout for Web Sidebar
        return Column(
          children: [
            _buildWebStatCard('total'.tr, controller.totalChallans.toString(), AppColors.appTheame, Icons.folder),
            const SizedBox(height: 12),
            _buildWebStatCard('delivered'.tr, controller.deliveredChallans.toString(), Colors.green, Icons.check_circle),
            const SizedBox(height: 12),
            _buildWebStatCard('pending'.tr, controller.pendingChallans.toString(), Colors.orange, Icons.pending),
            const SizedBox(height: 12),
            _buildWebStatCard('in_transit'.tr, controller.inTransitChallans.toString(), Colors.purple, Icons.local_shipping),
          ],
        );
      } else {
        // Horizontal Layout for Mobile Header
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('total'.tr, controller.totalChallans.toString(), AppColors.appTheame),
              _buildStatItem('delivered'.tr, controller.deliveredChallans.toString(), Colors.green),
              _buildStatItem('pending'.tr, controller.pendingChallans.toString(), Colors.orange),
              _buildStatItem('in_transit'.tr, controller.inTransitChallans.toString(), Colors.purple),
            ],
          ),
        );
      }
    });
  }

  // Helper for Web Stats
  Widget _buildWebStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          )
        ],
      ),
    );
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
        const SizedBox(height: 4),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            onChanged: controller.filterChallans,
            decoration: InputDecoration(
              hintText: 'Search challans...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all'.tr, controller.selectedFilter.value == 'All', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('delivered'.tr, controller.selectedFilter.value == 'Delivered', 'Delivered'),
                const SizedBox(width: 8),
                _buildFilterChip('pending'.tr, controller.selectedFilter.value == 'Pending', 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('in_transit'.tr, controller.selectedFilter.value == 'In Transit', 'In Transit'),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, String filterKey) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => controller.filterByStatus(filterKey),
      selectedColor: AppColors.appTheame,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? AppColors.appTheame : Colors.grey.shade300),
      ),
    );
  }

  String _chEmptyMsgEnGu(String en, String gu) {
    return AppConstants.isGujarati.value ? gu : en;
  }

  Widget _buildFilteredEmptyState() {
    return Obx(() {
      final hasData = controller.challanList.isNotEmpty;
      final filter = controller.selectedFilter.value;
      final q = controller.searchQuery.value.trim();

      late final String title;
      late final IconData icon;
      late final Color iconColor;

      if (!hasData) {
        title = 'no_challans_found'.tr;
        icon = Icons.local_shipping;
        iconColor = Colors.grey.shade400;
      } else if (q.isNotEmpty) {
        title = _chEmptyMsgEnGu(
          'No challans match your search',
          'શોધ સાથે કોઈ ચાલણ મળી નથી',
        );
        icon = Icons.search_off;
        iconColor = Colors.grey;
      } else {
        switch (filter) {
          case 'Delivered':
            title = _chEmptyMsgEnGu(
              'No delivered challans',
              'કોઈ ડિલિવર્ડ ચાલણ નથી',
            );
            icon = Icons.check_circle_outline;
            iconColor = Colors.green.shade300;
            break;
          case 'Pending':
            title = _chEmptyMsgEnGu(
              'No pending challans',
              'કોઈ પેન્ડિંગ ચાલણ નથી',
            );
            icon = Icons.hourglass_empty;
            iconColor = Colors.orange.shade300;
            break;
          case 'In Transit':
            title = _chEmptyMsgEnGu(
              'No challans in transit',
              'કોઈ ટ્રાન્ઝિટમાં ચાલણ નથી',
            );
            icon = Icons.local_shipping_outlined;
            iconColor = Colors.purple.shade300;
            break;
          default:
            title = 'no_challans_found'.tr;
            icon = Icons.local_shipping;
            iconColor = Colors.grey.shade400;
        }
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: Colors.grey.shade700, height: 1.35),
              ),
              if (!hasData) ...[
                const SizedBox(height: 8),
                Text(
                  'create_your_first_challan_to_get_started'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (Get.isRegistered<NewChallanController>()) {
                      Get.delete<NewChallanController>();
                    }
                    Get.put(NewChallanController());
                    await Get.toNamed(NewChallanScreen.pageId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appTheame,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('create_challan'.tr),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // Adaptive List Builder (Grid for Web, List for Mobile)
  Widget _buildChallanList() {
    return Obx(() {
      // Use GridView for Web, ListView for Mobile
      if (MediaQuery.of(Get.context!).size.width > 900) {
        return GridView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 4.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: controller.filteredChallanList.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.filteredChallanList.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: controller.isLoadingMore.value
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                ),
              );
            }
            final challan = controller.filteredChallanList[index];
            return _buildWebChallanCard(challan);
          },
        );
      } else {
        return ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: controller.filteredChallanList.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.filteredChallanList.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: controller.isLoadingMore.value
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                ),
              );
            }
            final challan = controller.filteredChallanList[index];
            return _buildMobileChallanListItem(challan);
          },
        );
      }
    });
  }

  // ✅ MOBILE CARD STYLE (Matches Invoice List with Click)
  Widget _buildMobileChallanListItem(Challan challan) {
    final statusColor = _getStatusColor(challan.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.viewChallanDetails(challan), // ✅ Added onTap here
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left Colored Bar
                  Container(width: 5, color: statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: ID/Name + Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "${challan.challanId} - ${challan.customerName}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.appTheame),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  challan.status.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Bottom Row: Date + Menu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(challan.challanDate ?? DateTime.now()),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              GestureDetector(
                                onTapDown: (details) => _showPopupMenu(details.globalPosition, challan),
                                child: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ WEB CARD STYLE (Matches Invoice Web Card with Click)
  Widget _buildWebChallanCard(Challan challan) {
    final statusColor = _getStatusColor(challan.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.viewChallanDetails(challan), // ✅ Added onTap here
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left Colored Bar
                  Container(width: 6, color: statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${challan.challanId} - ${challan.customerName}",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.appTheame),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Date: ${DateFormat('MMM dd, yyyy').format(challan.challanDate ?? DateTime.now())}",
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      challan.status.toUpperCase(),
                                      style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTapDown: (details) => _showPopupMenu(details.globalPosition, challan),
                                    child: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade400),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPopupMenu(Offset offset, Challan challan) {
    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
      items: [
        PopupMenuItem(
          value: 'view',
          child: Row(children: [Icon(Icons.visibility, color: AppColors.appTheame), SizedBox(width: 8), Text('view_details'.tr)]),
        ),
        PopupMenuItem(
          value: 'export_pdf',
          child: Row(children: [Icon(Icons.picture_as_pdf, color: Colors.orange), SizedBox(width: 8), Text('export_as_pdf'.tr)]),
        ),
      ],
    ).then((value) {
      if (value == 'view') controller.viewChallanDetails(challan);
      if (value == 'export_pdf') controller.exportChallanAsPdf(challan);
    });
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

  // ===========================================================================
  // 🌫️ SHIMMER LOADING
  // ===========================================================================

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

  Widget _buildWebShimmer() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildShimmerSearchFilterSection(),
              Expanded(child: _buildShimmerLoading()),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: List.generate(4, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )),
            ),
          ),
        )
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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


