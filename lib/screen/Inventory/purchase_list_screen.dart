import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';

import '../screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';


class PurchaseListScreen extends GetView<PurchaseListController> {
  static const String pageId = '/PurchaseListScreen';

  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: Text('purchases'.tr),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshPurchases,
            tooltip: 'Refresh',
          ),
          if (MediaQuery.of(context).size.width > 900)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/new-purchase'),
                icon: Icon(Icons.add, size: 18, color: AppColors.tealColor),
                label:  Text("New Purchase", style: TextStyle(color: AppColors.tealColor, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isDataLoading) {
            return LayoutBuilder(builder: (context, constraints) {
              return constraints.maxWidth > 900 ? _buildWebShimmer() : _buildFullShimmer();
            });
          }

          if (controller.filteredPurchaseList.isEmpty) {
            return _buildEmptyState();
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
      floatingActionButton: MediaQuery.of(context).size.width <= 900
          ? FloatingActionButton(
        onPressed: () => Get.toNamed('/new-purchase'),
        backgroundColor: AppColors.tealColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT
  // ===========================================================================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSearchFilterSection(),
        _buildStatisticsSection(isWeb: false),
        Expanded(child: _buildPurchaseList()), // No controller needed for mobile default
      ],
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Split View)
  // ===========================================================================
  Widget _buildWebLayout() {
    // 1. ✅ Create a ScrollController here
    final ScrollController scrollController = ScrollController();

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
                // 2. ✅ Connect Scrollbar to Controller
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  // 3. ✅ Pass Controller to List
                  child: _buildPurchaseList(scrollController: scrollController),
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
                      color: AppColors.tealColor,
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

  // ✅ Updated to accept optional ScrollController
  Widget _buildPurchaseList({ScrollController? scrollController}) {
    return Obx(() {
      // Use GridView for Web, ListView for Mobile
      if (MediaQuery.of(Get.context!).size.width > 900) {
        return GridView.builder(
          // 4. ✅ Assign Controller to GridView
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.filteredPurchaseList.length,
          itemBuilder: (context, index) {
            final purchase = controller.filteredPurchaseList[index];
            return _buildWebPurchaseCard(purchase);
          },
        );
      } else {
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: controller.filteredPurchaseList.length,
          itemBuilder: (context, index) {
            final purchase = controller.filteredPurchaseList[index];
            return _buildMobilePurchaseListItem(purchase);
          },
        );
      }
    });
  }

  Widget _buildStatisticsSection({required bool isWeb}) {
    return Obx(() {
      if (controller.isLoading.value) return _buildShimmerStatistics();

      if (isWeb) {
        return Column(
          children: [
            _buildWebStatCard('Total Purchases', controller.totalPurchases.toString(), AppColors.tealColor, Icons.shopping_bag),
            const SizedBox(height: 12),
            _buildWebStatCard('Paid Count', controller.completedPurchases.toString(), Colors.green, Icons.check_circle),
            const SizedBox(height: 12),
            _buildWebStatCard('Pending Count', controller.pendingPurchases.toString(), Colors.orange, Icons.pending),
            const SizedBox(height: 12),
            _buildWebStatCard('Partial Count', controller.partialPurchases.toString(), Colors.blue, Icons.timelapse),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _buildAmountStatItem('Total Amount', controller.totalPurchaseAmount, Colors.purple),
            const SizedBox(height: 16),
            _buildAmountStatItem('Paid Amount', controller.totalPaidAmount, Colors.green),
            const SizedBox(height: 16),
            _buildAmountStatItem('Pending Amount', controller.totalPendingAmount, Colors.red),
          ],
        );
      } else {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('total'.tr, controller.totalPurchases.toString(), AppColors.tealColor),
                  _buildStatItem('paid'.tr, controller.completedPurchases.toString(), Colors.green),
                  _buildStatItem('pending'.tr, controller.pendingPurchases.toString(), Colors.orange),
                  _buildStatItem('partial'.tr, controller.partialPurchases.toString(), Colors.blue),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAmountStatItem('Total Amount', controller.totalPurchaseAmount, Colors.purple),
                  _buildAmountStatItem('Paid', controller.totalPaidAmount, Colors.green),
                  _buildAmountStatItem('Pending', controller.totalPendingAmount, Colors.red),
                ],
              ),
            ],
          ),
        );
      }
    });
  }

  // ... [Other widgets: _buildWebStatCard, _buildStatItem, _buildAmountStatItem, _buildSearchFilterSection, _buildFilterChip, _buildEmptyState]
  // Use the same helper widgets from the previous code provided.
  // For brevity, I'm including the key ones below.

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
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildAmountStatItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(AppUtil.formatCurrency(amount), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search purchases...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: controller.filterPurchases,
          ),
          const SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all'.tr, controller.selectedFilter.value == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('paid'.tr, controller.selectedFilter.value == 'Paid'),
                const SizedBox(width: 8),
                _buildFilterChip('pending'.tr, controller.selectedFilter.value == 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('partial'.tr, controller.selectedFilter.value == 'Partial'),
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
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No purchases found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed('/new-purchase'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor),
            child: const Text("Create Purchase", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ MOBILE CARD STYLE
  Widget _buildMobilePurchaseListItem(PurchaseEntry purchase) {
    final statusColor = _getStatusColor(purchase.paymentStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.viewPurchaseDetails(purchase),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left Colored Bar
                  Container(width: 5, color: statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                                  "${purchase.purchaseId} - ${purchase.vendorName}",
                                  style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.tealColor),
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
                                  purchase.paymentStatus?.toUpperCase() ?? 'UNKNOWN',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Bottom Row: Date + Amount + Menu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(purchase.purchaseDate ?? DateTime.now()),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '₹${purchase.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTapDown: (details) => _showPopupMenu(details.globalPosition, purchase),
                                    child: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                  ),
                                ],
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

  // ✅ WEB CARD STYLE
  Widget _buildWebPurchaseCard(PurchaseEntry purchase) {
    final statusColor = _getStatusColor(purchase.paymentStatus);

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
            onTap: () => controller.viewPurchaseDetails(purchase),
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
                                      "${purchase.purchaseId} - ${purchase.vendorName}",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.tealColor),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Date: ${DateFormat('MMM dd, yyyy').format(purchase.purchaseDate ?? DateTime.now())}",
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
                                      purchase.paymentStatus?.toUpperCase() ?? "UNKNOWN",
                                      style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTapDown: (details) => _showPopupMenu(details.globalPosition, purchase),
                                    child: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade400),
                                  ),
                                ],
                              )
                            ],
                          ),
                          // Bottom
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Amount:", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              Text(
                                "₹${purchase.totalAmount?.toStringAsFixed(2) ?? '0.00'}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.tealColor),
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

  void _showPopupMenu(Offset offset, PurchaseEntry purchase) {
    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
      items: [
        PopupMenuItem(
          value: 'view',
          child: Row(children: [Icon(Icons.visibility, color: AppColors.tealColor), SizedBox(width: 8), Text('view_details')]),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(children: const [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Edit')]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: const [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete')]),
        ),
      ],
    ).then((value) {
      if (value == 'view') controller.viewPurchaseDetails(purchase);
      if (value == 'edit') controller.editPurchase(purchase);
      if (value == 'delete') controller.deletePurchase(purchase);
    });
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Shimmer widgets included as before...
  Widget _buildWebShimmer() => const Center(child: CircularProgressIndicator());
  Widget _buildFullShimmer() => const Center(child: CircularProgressIndicator());
  Widget _buildShimmerStatistics() => Container(); // Placeholder
}


///mobile View
// class PurchaseListScreen extends GetView<PurchaseListController> {
//   static const String pageId = '/PurchaseListScreen';
//
//   const PurchaseListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('purchases'.tr),
//         backgroundColor: AppColors.tealColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: controller.refreshPurchases,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isDataLoading) {
//           return _buildFullShimmer();
//         }
//
//         if (controller.filteredPurchaseList.isEmpty) {
//           return _buildEmptyState();
//         }
//
//         return Column(
//           children: [
//             _buildSearchFilterSection(),
//             _buildStatisticsSection(),
//             Expanded(child: _buildPurchaseList()),
//           ],
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Get.toNamed('/new-purchase'),
//         backgroundColor: AppColors.tealColor,
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildStatisticsSection() {
//     return Obx(() => Container(
//       padding: EdgeInsets.all(16),
//       color: Colors.grey.shade50,
//       child: controller.isLoading.value
//           ? _buildShimmerStatistics()
//           : Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatItem('total'.tr, controller.totalPurchases.toString(), AppColors.tealColor),
//               _buildStatItem('paid'.tr, controller.completedPurchases.toString(), Colors.green),
//               _buildStatItem('pending'.tr, controller.pendingPurchases.toString(), Colors.orange),
//               _buildStatItem('partial'.tr, controller.partialPurchases.toString(), Colors.blue),
//             ],
//           ),
//           SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildAmountStatItem('Total Amount', controller.totalPurchaseAmount, Colors.purple),
//               _buildAmountStatItem('Paid', controller.totalPaidAmount, Colors.green),
//               _buildAmountStatItem('Pending', controller.totalPendingAmount, Colors.red),
//             ],
//           ),
//         ],
//       ),
//     ));
//   }
//
//   Widget _buildStatItem(String title, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAmountStatItem(String title, double amount, Color color) {
//     return Column(
//       children: [
//         Text(
//           AppUtil.formatCurrency(amount),
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSearchFilterSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           // Search Bar
//           TextField(
//             decoration: InputDecoration(
//               hintText: 'Search purchases...',
//               prefixIcon: Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.grey.shade50,
//             ),
//             onChanged: controller.filterPurchases,
//           ),
//           SizedBox(height: 12),
//
//           // Filter Chips
//           Obx(() => SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildFilterChip('all'.tr, controller.selectedFilter.value == 'All'),
//                 SizedBox(width: 8),
//                 _buildFilterChip('paid'.tr, controller.selectedFilter.value == 'Paid'),
//                 SizedBox(width: 8),
//                 _buildFilterChip('pending'.tr, controller.selectedFilter.value == 'Pending'),
//                 SizedBox(width: 8),
//                 _buildFilterChip('partial'.tr, controller.selectedFilter.value == 'Partial'),
//               ],
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterChip(String label, bool selected) {
//     return ChoiceChip(
//       label: Text(label),
//       selected: selected,
//       onSelected: (_) => controller.filterByStatus(label),
//       selectedColor: AppColors.tealColor,
//       labelStyle: TextStyle(
//         color: selected ? Colors.white : Colors.black87,
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_bag, size: 64, color: Colors.grey.shade400),
//           SizedBox(height: 16),
//           Text(
//             'no_purchases_found'.tr,
//             style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'create_your_first_purchase_to_get_started'.tr,
//             style: TextStyle(color: Colors.grey.shade500),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () => Get.toNamed('/new-purchase'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.tealColor,
//               foregroundColor: Colors.white,
//             ),
//             child: Text('create_purchase'.tr),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPurchaseList() {
//     return Obx(() => ListView.builder(
//       padding: EdgeInsets.only(bottom: 80),
//       itemCount: controller.filteredPurchaseList.length,
//       itemBuilder: (context, index) {
//         final purchase = controller.filteredPurchaseList[index];
//         return _buildPurchaseListItem(purchase);
//       },
//     ));
//   }
//
//   Widget _buildPurchaseListItem(PurchaseEntry purchase) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.tealColor.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         borderRadius: BorderRadius.circular(18),
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => controller.viewPurchaseDetails(purchase),
//           borderRadius: BorderRadius.circular(18),
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Status indicator
//                 Container(
//                   width: 4,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(purchase.paymentStatus),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//
//                 // Purchase content
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               "${purchase.purchaseId} - ${purchase.vendorName}",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 color: AppColors.tealColor,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: _getStatusColor(purchase.paymentStatus).withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               purchase.paymentStatus?.toUpperCase() ?? 'UNKNOWN',
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold,
//                                 color: _getStatusColor(purchase.paymentStatus),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Total: ${AppUtil.formatCurrency(purchase.totalAmount ?? 0)}',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.purple,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Pending: ${AppUtil.formatCurrency(purchase.pendingAmount ?? 0)}',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.red.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             DateFormat('dd/MM/yyyy').format(purchase.purchaseDate ?? DateTime.now()),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 8),
//
//                 // Action button
//                 PopupMenuButton(
//                   icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       value: 'view',
//                       child: Row(
//                         children: [
//                           Icon(Icons.visibility, size: 20, color: AppColors.tealColor),
//                           SizedBox(width: 12),
//                           Text('view_details'.tr, style: TextStyle(color: AppColors.tealColor)),
//                         ],
//                       ),
//                     ),
//                     // PopupMenuItem(
//                     //   value: 'export_pdf',
//                     //   child: Row(
//                     //     children: [
//                     //       Icon(Icons.picture_as_pdf, size: 20, color: Colors.orange.shade700),
//                     //       SizedBox(width: 12),
//                     //       Text('export_as_pdf'.tr, style: TextStyle(color: Colors.orange.shade700)),
//                     //     ],
//                     //   ),
//                     // ),
//                     // PopupMenuItem(
//                     //   value: 'edit',
//                     //   child: Row(
//                     //     children: [
//                     //       Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
//                     //       SizedBox(width: 12),
//                     //       Text('edit'.tr, style: TextStyle(color: Colors.blue.shade700)),
//                     //     ],
//                     //   ),
//                     // ),
//                     // PopupMenuItem(
//                     //   value: 'delete',
//                     //   child: Row(
//                     //     children: [
//                     //       Icon(Icons.delete, size: 20, color: Colors.red.shade700),
//                     //       SizedBox(width: 12),
//                     //       Text('delete'.tr, style: TextStyle(color: Colors.red.shade700)),
//                     //     ],
//                     //   ),
//                     // ),
//                   ],
//                   onSelected: (value) {
//                     switch (value) {
//                       case 'view':
//                         controller.viewPurchaseDetails(purchase);
//                         break;
//                       // case 'export_pdf':
//                       //   controller.exportPurchaseAsPdf(purchase);
//                       //   break;
//                       case 'edit':
//                         controller.editPurchase(purchase);
//                         break;
//                       case 'delete':
//                         controller.deletePurchase(purchase);
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
//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'paid':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'partial':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   // FULL PAGE SHIMMER
//   Widget _buildFullShimmer() {
//     return Column(
//       children: [
//         _buildShimmerSearchFilterSection(),
//         _buildShimmerStatistics(),
//         Expanded(
//           child: _buildShimmerLoading(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildShimmerSearchFilterSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           Shimmer.fromColors(
//             baseColor: Colors.grey.shade300,
//             highlightColor: Colors.grey.shade100,
//             child: Container(
//               height: 40,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.grey,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: List.generate(
//               4,
//                   (_) => Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey.shade300,
//                   highlightColor: Colors.grey.shade100,
//                   child: Container(
//                     width: 60,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       color: Colors.grey,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildShimmerLoading() {
//     return ListView.builder(
//       padding: const EdgeInsets.only(bottom: 80),
//       itemCount: 6,
//       itemBuilder: (context, index) => _buildShimmerPurchaseListItem(),
//     );
//   }
//
//   Widget _buildShimmerPurchaseListItem() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.tealColor.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Shimmer.fromColors(
//               baseColor: Colors.grey.shade300,
//               highlightColor: Colors.grey.shade100,
//               child: Container(
//                 width: 4,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.grey,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Shimmer.fromColors(
//                     baseColor: Colors.grey.shade300,
//                     highlightColor: Colors.grey.shade100,
//                     child: Container(
//                       width: double.infinity,
//                       height: 16,
//                       decoration: BoxDecoration(
//                         color: Colors.grey,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Shimmer.fromColors(
//                         baseColor: Colors.grey.shade300,
//                         highlightColor: Colors.grey.shade100,
//                         child: Container(
//                           width: 100,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: Colors.grey,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ),
//                       Shimmer.fromColors(
//                         baseColor: Colors.grey.shade300,
//                         highlightColor: Colors.grey.shade100,
//                         child: Container(
//                           width: 60,
//                           height: 14,
//                           decoration: BoxDecoration(
//                             color: Colors.grey,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildShimmerStatistics() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.grey.shade50,
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(4, (_) => _buildShimmerStatItem()),
//           ),
//           SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(3, (_) => _buildShimmerStatItem()),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildShimmerStatItem() {
//     return Column(
//       children: [
//         Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//           child: Container(
//             width: 40,
//             height: 16,
//             decoration: BoxDecoration(
//               color: Colors.grey,
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//           child: Container(
//             width: 30,
//             height: 12,
//             decoration: BoxDecoration(
//               color: Colors.grey,
//               borderRadius: BorderRadius.circular(6),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


