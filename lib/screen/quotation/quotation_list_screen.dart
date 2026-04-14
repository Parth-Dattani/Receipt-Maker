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
      appBar: AppBar(
        title: Text('quotations'.tr),
        backgroundColor: AppColors.appTheame,
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
                icon:  Icon(Icons.add, size: 18, color: AppColors.appTheame),
                label:  Text("New Quotation", style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.bold)),
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
        _buildStatisticsSectionMobile(),
        Expanded(
          child: Obx(() {
            if (controller.filteredQuotationList.isEmpty) {
              return _buildFilteredEmptyState();
            }
            return _buildQuotationList();
          }),
        ),
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
              _buildWebStatItem('Total', controller.totalQuotations.toString(), AppColors.appTheame),
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
                    if (controller.filteredQuotationList.isEmpty) {
                      return _buildFilteredEmptyState();
                    }
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
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.appTheame),
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

  void _showPopupMenu(Offset offset, Invoice quotation) {
    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
      items: [
        PopupMenuItem(
          value: 'view',
          child: Row(children:  [Icon(Icons.visibility, color: AppColors.appTheame), SizedBox(width: 8), Text('view_details'.tr)]),
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
                _buildFilterChip('all'.tr, controller.selectedFilter.value == 'All', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('accepted'.tr, controller.selectedFilter.value == 'Accepted', 'Accepted'),
                const SizedBox(width: 8),
                _buildFilterChip('pending'.tr, controller.selectedFilter.value == 'Pending', 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('rejected'.tr, controller.selectedFilter.value == 'Rejected', 'Rejected'),
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

  Widget _buildStatisticsSectionMobile() {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('total'.tr, controller.totalQuotations.toString(), AppColors.appTheame),
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
                                    style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.appTheame),
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

  Widget _buildFullShimmer() {
    return Column(
      children: [
        _quotationShimmerSearchSection(chipCount: 4),
        _quotationShimmerStatsRow(itemCount: 4),
        Expanded(child: _quotationShimmerList(itemCount: 6)),
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
                child: _quotationShimmerBox(width: 72, height: 36, radius: 8),
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
                    _quotationShimmerBox(width: 80, height: 18, radius: 6),
                    const SizedBox(height: 16),
                    _quotationShimmerBox(width: double.infinity, height: 40, radius: 8),
                    const SizedBox(height: 24),
                    _quotationShimmerBox(width: 56, height: 14, radius: 6),
                    const SizedBox(height: 12),
                    ...List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            _quotationShimmerBox(width: 18, height: 18, radius: 9),
                            const SizedBox(width: 10),
                            _quotationShimmerBox(width: 100, height: 14, radius: 6),
                          ],
                        ),
                      ),
                    ),
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
                    itemBuilder: (_, __) => _quotationShimmerWebCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quotationShimmerBox({required double width, required double height, required double radius}) {
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

  Widget _quotationShimmerSearchSection({required int chipCount}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _quotationShimmerBox(width: double.infinity, height: 48, radius: 8),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              chipCount,
              (i) => Padding(
                padding: EdgeInsets.only(right: i < chipCount - 1 ? 8 : 0),
                child: _quotationShimmerBox(width: 72, height: 32, radius: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quotationShimmerStatsRow({required int itemCount}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(itemCount, (_) => _quotationShimmerStatPill()),
      ),
    );
  }

  Widget _quotationShimmerStatPill() {
    return Column(
      children: [
        _quotationShimmerBox(width: 36, height: 16, radius: 6),
        const SizedBox(height: 6),
        _quotationShimmerBox(width: 44, height: 12, radius: 6),
      ],
    );
  }

  Widget _quotationShimmerList({int itemCount = 6}) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: itemCount,
      itemBuilder: (_, __) => _quotationShimmerMobileCard(),
    );
  }

  Widget _quotationShimmerMobileCard() {
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
                      Expanded(child: _quotationShimmerBox(width: double.infinity, height: 16, radius: 8)),
                      const SizedBox(width: 8),
                      _quotationShimmerBox(width: 52, height: 22, radius: 8),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _quotationShimmerBox(width: 96, height: 12, radius: 6),
                      _quotationShimmerBox(width: 72, height: 14, radius: 6),
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

  Widget _quotationShimmerWebCard() {
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

  String _qEmptyMsgEnGu(String en, String gu) {
    return AppConstants.isGujarati.value ? gu : en;
  }

  Widget _buildFilteredEmptyState() {
    return Obx(() {
      final hasData = controller.quotationList.isNotEmpty;
      final filter = controller.selectedFilter.value;
      final q = controller.searchQuery.value.trim();

      late final String title;
      late final IconData icon;
      late final Color iconColor;

      if (!hasData) {
        title = 'no_quotations_found'.tr;
        icon = Icons.request_quote;
        iconColor = Colors.grey;
      } else if (q.isNotEmpty) {
        title = _qEmptyMsgEnGu(
          'No quotations match your search',
          'શોધ સાથે કોઈ ક્વોટેશન મળી નથી',
        );
        icon = Icons.search_off;
        iconColor = Colors.grey;
      } else {
        switch (filter) {
          case 'Accepted':
            title = _qEmptyMsgEnGu(
              'No accepted quotations',
              'કોઈ સ્વીકૃત ક્વોટેશન નથી',
            );
            icon = Icons.check_circle_outline;
            iconColor = Colors.green.shade300;
            break;
          case 'Pending':
            title = _qEmptyMsgEnGu(
              'No pending quotations',
              'કોઈ પેન્ડિંગ ક્વોટેશન નથી',
            );
            icon = Icons.hourglass_empty;
            iconColor = Colors.orange.shade300;
            break;
          case 'Rejected':
            title = _qEmptyMsgEnGu(
              'No rejected quotations',
              'કોઈ નકારેલી ક્વોટેશન નથી',
            );
            icon = Icons.cancel_outlined;
            iconColor = Colors.red.shade300;
            break;
          default:
            title = 'no_quotations_found'.tr;
            icon = Icons.request_quote;
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
                style: TextStyle(fontSize: 17, color: Colors.grey.shade700, height: 1.35),
              ),
              if (!hasData) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Get.lazyPut<NewInvoiceController>(() => NewInvoiceController());
                    await Get.toNamed(NewInvoiceScreen.pageId);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.appTheame),
                  child: Text('create_quotation'.tr, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}


