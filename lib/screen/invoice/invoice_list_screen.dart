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

import '../screen.dart';


class InvoiceListScreen extends GetView<InvoiceListController> {
  static const String pageId = '/InvoiceListScreen';

  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshInvoices,
            tooltip: 'Refresh',
          ),
          // Web Add Button
          if (MediaQuery.of(context).size.width > 900)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());

                  await Get.toNamed(NewInvoiceScreen.pageId);
                },
                icon:  Icon(Icons.add, size: 18, color: AppColors.appTheame),
                label:  Text("New Invoice", style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.bold)),
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
            if (controller.isLoading.value) {
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
        _buildSearchFilterSectionMobile(),
        _buildStatisticsSectionMobile(),
        Expanded(
          child: Obx(() {
            if (controller.filteredInvoiceList.isEmpty) {
              return _buildFilteredEmptyState();
            }
            return _buildInvoiceListMobile();
          }),
        ),
      ],
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT
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
              _buildWebStatItem('Total', controller.totalInvoices.toString(), AppColors.appTheame),
              _buildVerticalDivider(),
              _buildWebStatItem('Paid', controller.paidInvoices.toString(), Colors.green),
              _buildVerticalDivider(),
              _buildWebStatItem('Pending', controller.pendingInvoices.toString(), Colors.orange),
              _buildVerticalDivider(),
              _buildWebStatItem('Revenue', '₹${AppUtil.formatCurrency(controller.totalRevenue)}', Colors.purple),
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
                    TextField(
                      onChanged: controller.filterInvoices,
                      decoration: InputDecoration(
                        hintText: "Search invoices...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text("Status", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Obx(() => Column(
                      children: [
                        _buildWebRadioFilter("All", controller.selectedFilter.value == "All"),
                        _buildWebRadioFilter("Paid", controller.selectedFilter.value == "Paid"),
                        _buildWebRadioFilter("Pending", controller.selectedFilter.value == "Pending"),
                        _buildWebRadioFilter("Overdue", controller.selectedFilter.value == "Overdue"),
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
                    if (controller.filteredInvoiceList.isEmpty) {
                      return _buildFilteredEmptyState();
                    }
                    return GridView.builder(
                      controller: controller.scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: controller.filteredInvoiceList.length + (controller.hasMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= controller.filteredInvoiceList.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: controller.isLoadingMore.value
                                  ? const CircularProgressIndicator()
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }
                        final invoice = controller.filteredInvoiceList[index];
                        return _buildWebInvoiceCard(invoice);
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
              color: isSelected ? AppColors.appTheame : Colors.grey,
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

  // ✅ WEB INVOICE CARD WITH ONTAP
  Widget _buildWebInvoiceCard(Invoice invoice) {
    final statusColor = _getStatusColor(invoice.status);

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
            onTap: () => controller.viewInvoiceDetails(invoice), // ✅ CLICKABLE AREA
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 6, color: statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${invoice.invoiceId} - ${invoice.customerName}",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.appTheame),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Created: ${DateFormat('MMM dd, yyyy').format(invoice.issueDate ?? DateTime.now())}",
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
                                      invoice.status?.toUpperCase() ?? "UNKNOWN",
                                      style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTapDown: (details) => _showPopupMenu(details.globalPosition, invoice),
                                    child: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade400),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Amount:", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              Text(
                                "₹${invoice.totalAmount?.toStringAsFixed(2) ?? '0.00'}",
                                style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.appTheame),
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

  void _showPopupMenu(Offset offset, Invoice invoice) {
    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
      items: [
        PopupMenuItem(
          value: 'view',
          child: Row(children: [Icon(Icons.visibility, color: AppColors.appTheame), SizedBox(width: 8), Text('view_details'.tr)]),
        ),
        PopupMenuItem(
          value: 'export',
          child: Row(children: [Icon(Icons.picture_as_pdf, color: Colors.orange), SizedBox(width: 8), Text("export_as_pdf".tr)]),
        ),
      ],
    ).then((value) {
      if (value == 'view') controller.viewInvoiceDetails(invoice);
      if (value == 'export') controller.exportInvoiceAsPdf(invoice);
    });
  }

  // ===========================================================================
  // 📱 MOBILE COMPONENTS
  // ===========================================================================

  Widget _buildSearchFilterSectionMobile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: controller.filterInvoices,
            decoration: InputDecoration(
              hintText: 'Search invoices...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', controller.selectedFilter.value == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Paid', controller.selectedFilter.value == 'Paid'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', controller.selectedFilter.value == 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Overdue', controller.selectedFilter.value == 'Overdue'),
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
      selectedColor: AppColors.appTheame,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
    );
  }

  Widget _buildStatisticsSectionMobile() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMobileStatItem('Total', controller.totalInvoices.toString(), AppColors.appTheame),
          _buildMobileStatItem('Paid', controller.paidInvoices.toString(), Colors.green),
          _buildMobileStatItem('Pending', controller.pendingInvoices.toString(), Colors.orange),
          _buildMobileStatItem('Revenue', '₹${AppUtil.formatCurrency(controller.totalRevenue)}', Colors.purple),
        ],
      ),
    ));
  }

  Widget _buildMobileStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildInvoiceListMobile() {
    return Obx(() => ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: controller.filteredInvoiceList.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.filteredInvoiceList.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: controller.isLoadingMore.value
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                ),
              );
            }
            final invoice = controller.filteredInvoiceList[index];
            return _buildMobileInvoiceListItem(invoice);
          },
        ));
  }

  // ✅ MOBILE INVOICE CARD WITH ONTAP
  Widget _buildMobileInvoiceListItem(Invoice invoice) {
    final statusColor = _getStatusColor(invoice.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.appTheame.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.viewInvoiceDetails(invoice), // ✅ CLICKABLE AREA
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 5, color: statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "${invoice.invoiceId} - ${invoice.customerName}",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appTheame),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                child: Text(invoice.status?.toUpperCase() ?? "N/A", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('MMM dd, yyyy').format(invoice.issueDate ?? DateTime.now()), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              Row(
                                children: [
                                  Text('₹${invoice.totalAmount?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTapDown: (details) => _showPopupMenu(details.globalPosition, invoice),
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid': return Colors.green;
      case 'pending': return Colors.orange;
      case 'overdue': return Colors.red;
      default: return Colors.grey;
    }
  }

  // ===========================================================================
  // 🌫️ SHIMMER LOADING
  // ===========================================================================

  Widget _buildFullShimmer() {
    return Column(
      children: [
        _invoiceShimmerSearchSection(chipCount: 4),
        _invoiceShimmerStatsRow(itemCount: 4),
        Expanded(child: _invoiceShimmerList(itemCount: 6)),
      ],
    );
  }

  Widget _buildWebShimmer() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _invoiceShimmerBox(width: 72, height: 36, radius: 8),
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    _invoiceShimmerBox(width: 80, height: 18, radius: 6),
                    const SizedBox(height: 16),
                    _invoiceShimmerBox(width: double.infinity, height: 40, radius: 8),
                    const SizedBox(height: 24),
                    _invoiceShimmerBox(width: 56, height: 14, radius: 6),
                    const SizedBox(height: 12),
                    ...List.generate(4, (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              _invoiceShimmerBox(width: 18, height: 18, radius: 9),
                              const SizedBox(width: 10),
                              _invoiceShimmerBox(width: 100, height: 14, radius: 6),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, __) => _invoiceShimmerWebCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _invoiceShimmerBox({required double width, required double height, required double radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _invoiceShimmerSearchSection({required int chipCount}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _invoiceShimmerBox(width: double.infinity, height: 48, radius: 8),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              chipCount,
              (i) => Padding(
                padding: EdgeInsets.only(right: i < chipCount - 1 ? 8 : 0),
                child: _invoiceShimmerBox(width: 72, height: 32, radius: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceShimmerStatsRow({required int itemCount}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(itemCount, (_) => _invoiceShimmerStatPill()),
      ),
    );
  }

  Widget _invoiceShimmerStatPill() {
    return Column(
      children: [
        _invoiceShimmerBox(width: 36, height: 16, radius: 6),
        const SizedBox(height: 6),
        _invoiceShimmerBox(width: 44, height: 12, radius: 6),
      ],
    );
  }

  Widget _invoiceShimmerList({int itemCount = 6}) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: itemCount,
      itemBuilder: (_, __) => _invoiceShimmerMobileCard(),
    );
  }

  Widget _invoiceShimmerMobileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
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
                width: 5,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _invoiceShimmerBox(width: double.infinity, height: 16, radius: 8)),
                      const SizedBox(width: 8),
                      _invoiceShimmerBox(width: 52, height: 22, radius: 8),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _invoiceShimmerBox(width: 96, height: 12, radius: 6),
                      _invoiceShimmerBox(width: 72, height: 14, radius: 6),
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

  Widget _invoiceShimmerWebCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(width: 6, height: double.infinity, color: Colors.grey.shade400),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: double.infinity, color: Colors.grey),
                        const SizedBox(height: 8),
                        Container(height: 10, width: 120, color: Colors.grey),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(height: 10, width: 70, color: Colors.grey),
                        Container(height: 14, width: 64, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _emptyMsgEnGu(String en, String gu) {
    return AppConstants.isGujarati.value ? gu : en;
  }

  /// Empty list: no data at all vs filtered/search with no matches.
  Widget _buildFilteredEmptyState() {
    return Obx(() {
    final hasInvoices = controller.invoiceList.isNotEmpty;
    final filter = controller.selectedFilter.value;
    final q = controller.searchQuery.value.trim();

    late final String title;
    late final IconData icon;
    late final Color iconColor;

    if (!hasInvoices) {
      title = _emptyMsgEnGu('No invoices found', 'કોઈ ઇન્વૉઇસ મળી નથી');
      icon = Icons.receipt_long;
      iconColor = Colors.grey;
    } else if (q.isNotEmpty) {
      title = _emptyMsgEnGu(
        'No invoices match your search',
        'શોધ સાથે કોઈ ઇન્વૉઇસ મળી નથી',
      );
      icon = Icons.search_off;
      iconColor = Colors.grey;
    } else {
      switch (filter) {
        case 'Overdue':
          title = _emptyMsgEnGu(
            'No overdue invoices',
            'કોઈ ઓવરડ્યુ ઇન્વૉઇસ નથી',
          );
          icon = Icons.event_busy;
          iconColor = Colors.red.shade300;
          break;
        case 'Paid':
          title = _emptyMsgEnGu('No paid invoices', 'કોઈ પેડ ઇન્વૉઇસ નથી');
          icon = Icons.payments_outlined;
          iconColor = Colors.green.shade300;
          break;
        case 'Pending':
          title = _emptyMsgEnGu(
            'No pending invoices',
            'કોઈ પેન્ડિંગ ઇન્વૉઇસ નથી',
          );
          icon = Icons.hourglass_empty;
          iconColor = Colors.orange.shade300;
          break;
        default:
          title = _emptyMsgEnGu('No invoices found', 'કોઈ ઇન્વૉઇસ મળી નથી');
          icon = Icons.receipt_long;
          iconColor = Colors.grey;
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
              style: const TextStyle(fontSize: 17, color: Colors.grey, height: 1.35),
            ),
            if (!hasInvoices) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());
                  await Get.toNamed(NewInvoiceScreen.pageId);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.appTheame),
                child: Text(
                  _emptyMsgEnGu('Create Invoice', 'ઇન્વૉઇસ બનાવો'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    });
  }
}



