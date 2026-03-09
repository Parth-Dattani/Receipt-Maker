import 'package:GetYourInvoice/screen/invoice/new_invoice_screen.dart' show NewInvoiceScreen;
import 'package:GetYourInvoice/utils/calculations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../widgets/web_screen_wrapper.dart';


class QuotationListScreen extends GetView<QuotationListController> {
  static const String pageId = '/QuotationListScreen';

  const QuotationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: Text('quotations'.tr),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshQuotations,
            tooltip: 'refresh'.tr,
          ),
          // Web-specific "Add" button
          if (MediaQuery.of(context).size.width > 900)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());

                  await Get.toNamed(NewInvoiceScreen.pageId);
                },
                icon:  Icon(Icons.add, size: 18, color: AppColors.tealColor),
                label:  Text("New Quotation", style: TextStyle(color: AppColors.tealColor, fontWeight: FontWeight.bold)),
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
          if (controller.isLoadingQuotations.value) {
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

    );
    if (kIsWeb) return webScreenWrapper(currentRoute: pageId, child: content);
    return content;
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT
  // ===========================================================================
  Widget _buildMobileLayout() {
    if (controller.filteredQuotationList.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        _buildSearchFilterSection(),
        _buildStatisticsSectionMobile(),
        Expanded(child: _buildQuotationList()),
      ],
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Stats Top + Sidebar Filter + Grid)
  // ===========================================================================
  Widget _buildWebLayout() {
    return Column(
      children: [
        // 1. Top Stats Row
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWebStatItem('Total', controller.totalQuotations.toString(), AppColors.tealColor),
              _buildVerticalDivider(),
              _buildWebStatItem('Accepted', controller.acceptedQuotations.toString(), Colors.green),
              _buildVerticalDivider(),
              _buildWebStatItem('Pending', controller.pendingQuotations.toString(), Colors.orange),
              _buildVerticalDivider(),
              _buildWebStatItem('Value', '₹${AppUtil.formatCurrency(controller.totalValue)}', Colors.blue),
            ],
          ),
        ),

        // 2. Main Content Area
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Left Sidebar (Filters) ---
              Container(
                width: 280,
                margin: const EdgeInsets.only(top: 24, left: 24, bottom: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 16),
                    // Search
                    TextField(
                      onChanged: controller.filterQuotations,
                      decoration: InputDecoration(
                        hintText: "Search quotations...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text("Status", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 12),
                    // Radio Filters
                    Obx(() => Column(
                      children: [
                        _buildWebRadioFilter("All", controller.selectedFilter.value == "All"),
                        _buildWebRadioFilter("Accepted", controller.selectedFilter.value == "Accepted"),
                        _buildWebRadioFilter("Pending", controller.selectedFilter.value == "Pending"),
                        _buildWebRadioFilter("Rejected", controller.selectedFilter.value == "Rejected"),
                      ],
                    )),
                  ],
                ),
              ),

              // --- Right Grid (Content) ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Obx(() {
                    if (controller.filteredQuotationList.isEmpty) return _buildEmptyState();
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 Columns
                        childAspectRatio: 3.2, // Rectangular card
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: controller.filteredQuotationList.length,
                      itemBuilder: (context, index) {
                        final quotation = controller.filteredQuotationList[index];
                        return _buildWebQuotationCard(quotation);
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 🧩 WEB COMPONENTS
  // ===========================================================================

  Widget _buildWebStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildWebRadioFilter(String label, bool isSelected) {
    return InkWell(
      onTap: () => controller.filterByStatus(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.tealColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebQuotationCard(Invoice quotation) {
    final statusColor = _getStatusColor(quotation.status);

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
            onTap: () => controller.viewQuotationDetails(quotation), // ✅ NAVIGATE ON TAP
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
                          // Header: ID/Name + Badge + Menu
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${quotation.invoiceId} - ${quotation.customerName}",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.tealColor),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Created: ${DateFormat('MMM dd, yyyy').format(quotation.issueDate ?? DateTime.now())}",
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
                                      _getStatusText(quotation.status).toUpperCase(),
                                      style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTapDown: (details) => _showPopupMenu(details.globalPosition, quotation),
                                    child: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade400),
                                  ),
                                ],
                              )
                            ],
                          ),

                          // Bottom: Total Label + Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Amount:", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              Text(
                                "₹${quotation.totalAmount?.toStringAsFixed(2) ?? '0.00'}",
                                style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.tealColor),
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

  void _showPopupMenu(Offset offset, Invoice quotation) {
    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
      items: [
        PopupMenuItem(
          value: 'view',
          child: Row(children:  [Icon(Icons.visibility, color: AppColors.tealColor), SizedBox(width: 8), Text('view_details'.tr)]),
        ),
        if (quotation.status?.toLowerCase() != 'accepted')
          PopupMenuItem(
            value: 'convert',
            child: Row(children: [Icon(Icons.receipt_long, color: Colors.green.shade700), SizedBox(width: 8), Text('convert_to_invoice'.tr)]),
          ),
        PopupMenuItem(
          value: 'export',
          child: Row(children: [Icon(Icons.picture_as_pdf, color: Colors.orange), SizedBox(width: 8), Text('export_as_pdf'.tr)]),
        ),
      ],
    ).then((value) {
      if (value == 'view') controller.viewQuotationDetails(quotation);
      if (value == 'convert') controller.convertQuotationToInvoice(quotation);
      if (value == 'export') controller.exportQuotationAsPdf(quotation);
    });
  }

  // ===========================================================================
  // 📱 MOBILE COMPONENTS
  // ===========================================================================

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            onChanged: controller.filterQuotations,
            decoration: InputDecoration(
              hintText: 'Search quotations...',
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
                _buildFilterChip('all'.tr, controller.selectedFilter.value == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('accepted'.tr, controller.selectedFilter.value == 'Accepted'),
                const SizedBox(width: 8),
                _buildFilterChip('pending'.tr, controller.selectedFilter.value == 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('rejected'.tr, controller.selectedFilter.value == 'Rejected'),
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
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? AppColors.tealColor : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildStatisticsSectionMobile() {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('total'.tr, controller.totalQuotations.toString(), AppColors.tealColor),
          _buildStatItem('accepted'.tr, controller.acceptedQuotations.toString(), Colors.green),
          _buildStatItem('pending'.tr, controller.pendingQuotations.toString(), Colors.orange),
          _buildStatItem('value'.tr, '₹${AppUtil.formatCurrency(controller.totalValue)}', Colors.blue),
        ],
      ),
    ));
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

  Widget _buildQuotationList() {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: controller.filteredQuotationList.length,
      itemBuilder: (context, index) {
        final quotation = controller.filteredQuotationList[index];
        return _buildMobileQuotationListItem(quotation);
      },
    ));
  }

  // ✅ MATCHED MOBILE CARD STYLE (Same as InvoiceList)
  Widget _buildMobileQuotationListItem(Invoice quotation) {
    final statusColor = _getStatusColor(quotation.status);

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
            onTap: () => controller.viewQuotationDetails(quotation), // ✅ NAVIGATE ON TAP
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
                                  "${quotation.invoiceId} - ${quotation.customerName}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.tealColor),
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
                                  _getStatusText(quotation.status).toUpperCase(),
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
                                DateFormat('MMM dd, yyyy').format(quotation.issueDate ?? DateTime.now()),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '₹${AppUtil.formatCurrency(quotation.totalAmount!) ?? '0.00'}',
                                    style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.tealColor),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTapDown: (details) => _showPopupMenu(details.globalPosition, quotation),
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

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
      case 'approved':
        return 'accepted'.tr;
      case 'pending':
        return 'pending'.tr;
      case 'rejected':
      case 'declined':
        return 'rejected'.tr;
      default:
        return 'pending'.tr;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ===========================================================================
  // 🌫️ SHIMMER LOADING
  // ===========================================================================
  Widget _buildWebShimmer() => const Center(child: CircularProgressIndicator());
  Widget _buildFullShimmer() => const Center(child: CircularProgressIndicator());
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.request_quote, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('no_quotations_found'.tr, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());

              await Get.toNamed(NewInvoiceScreen.pageId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor),
            child: Text('create_quotation'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}


///mobile working
// class QuotationListScreen extends GetView<QuotationListController> {
//   static const String pageId = '/QuotationListScreen';
//
//   const QuotationListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('quotations'.tr),
//         backgroundColor: AppColors.tealColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: controller.refreshQuotations,
//             tooltip: 'refresh'.tr,
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Obx(() {
//           if (controller.isLoadingQuotations.value) {
//             return _buildFullShimmer();
//           }
//
//           if (controller.filteredQuotationList.isEmpty) {
//             return _buildEmptyState();
//           }
//
//           return Column(
//             children: [
//               _buildSearchFilterSection(),
//               _buildStatisticsSection(),
//               Expanded(child: _buildQuotationList()),
//             ],
//           );
//         }),
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
//           : Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem('total'.tr, controller.totalQuotations.toString(), AppColors.tealColor),
//           _buildStatItem('accepted'.tr, controller.acceptedQuotations.toString(), Colors.green),
//           _buildStatItem('pending'.tr, controller.pendingQuotations.toString(), Colors.orange),
//           _buildStatItem('value'.tr, '₹${AppUtil.formatCurrency(controller.totalValue)}', Colors.blue),
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
//   Widget _buildSearchFilterSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           TextField(
//             decoration: InputDecoration(
//               hintText: 'search_quotations'.tr,
//               prefixIcon: Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.grey.shade50,
//             ),
//             onChanged: controller.filterQuotations,
//           ),
//           SizedBox(height: 12),
//           Obx(() => SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildFilterChip('all'.tr, controller.selectedFilter.value == 'All'),
//                 SizedBox(width: 8),
//                 _buildFilterChip('accepted'.tr, controller.selectedFilter.value == 'Accepted'),
//                 SizedBox(width: 8),
//                 _buildFilterChip('pending'.tr, controller.selectedFilter.value == 'Pending'),
//                 SizedBox(width: 8),
//                 _buildFilterChip('rejected'.tr, controller.selectedFilter.value == 'Rejected'),
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
//           Icon(Icons.request_quote, size: 64, color: Colors.grey.shade400),
//           SizedBox(height: 16),
//           Text(
//             'no_quotations_found'.tr,
//             style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'create_first_quotation'.tr,
//             style: TextStyle(color: Colors.grey.shade500),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () => Get.toNamed('/new-quotation'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.tealColor,
//               foregroundColor: Colors.white,
//             ),
//             child: Text('create_quotation'.tr),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuotationList() {
//     return Obx(() => ListView.builder(
//       padding: EdgeInsets.only(bottom: 80),
//       itemCount: controller.filteredQuotationList.length,
//       itemBuilder: (context, index) {
//         final quotation = controller.filteredQuotationList[index];
//         return _buildQuotationListItem(quotation);
//       },
//     ));
//   }
//
//   Widget _buildQuotationListItem(Invoice quotation) {
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
//           onTap: () => controller.viewQuotationDetails(quotation),
//           borderRadius: BorderRadius.circular(18),
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(quotation.status),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               "${quotation.invoiceId} - ${quotation.customerName}",
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
//                               color: _getStatusColor(quotation.status).withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               _getStatusText(quotation.status).toUpperCase(),
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold,
//                                 color: _getStatusColor(quotation.status),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             DateFormat('MMM dd, yyyy').format(quotation.issueDate ?? DateTime.now()),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           Text(
//                             '₹${AppUtil.formatCurrency(quotation.totalAmount!.toDouble()) ?? '0.00'}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.tealColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 8),
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
//                     if (quotation.status?.toLowerCase() != 'accepted')
//                       PopupMenuItem(
//                         value: 'convert',
//                         child: Row(
//                           children: [
//                             Icon(Icons.receipt_long, size: 20, color: Colors.green.shade700),
//                             SizedBox(width: 12),
//                             Text('convert_to_invoice'.tr, style: TextStyle(color: Colors.green.shade700)),
//                           ],
//                         ),
//                       ),
//                     PopupMenuItem(
//                       value: 'export_pdf',
//                       child: Row(
//                         children: [
//                           Icon(Icons.picture_as_pdf, size: 20, color: Colors.orange.shade700),
//                           SizedBox(width: 12),
//                           Text('export_as_pdf'.tr, style: TextStyle(color: Colors.orange.shade700)),
//                         ],
//                       ),
//                     ),
//                   ],
//                   onSelected: (value) {
//                     switch (value) {
//                       case 'view':
//                         controller.viewQuotationDetails(quotation);
//                         break;
//                       case 'convert':
//                         controller.convertQuotationToInvoice(quotation);
//                         break;
//                       case 'export_pdf':
//                         controller.exportQuotationAsPdf(quotation);
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
//   String _getStatusText(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'accepted':
//       case 'approved':
//         return 'accepted'.tr;
//       case 'pending':
//         return 'pending'.tr;
//       case 'rejected':
//       case 'declined':
//         return 'rejected'.tr;
//       default:
//         return 'pending'.tr;
//     }
//   }
//
//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'accepted':
//       case 'approved':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'rejected':
//       case 'declined':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
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
//               3,
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
//       itemBuilder: (context, index) => _buildShimmerQuotationListItem(),
//     );
//   }
//
//   Widget _buildShimmerQuotationListItem() {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(4, (_) => _buildShimmerStatItem()),
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

