// screens/invoice/invoice_list_screen.dart
import 'package:demo_prac_getx/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';

import 'package:shimmer/shimmer.dart'; // Add this import

class InvoiceListScreen extends GetView<InvoiceListController> {
  static const String pageId = '/InvoiceListScreen';

  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoices'),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshInvoices,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildFullShimmer();
          }

          if (controller.filteredInvoiceList.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSearchFilterSection(),
              _buildStatisticsSection(),
              Expanded(child: _buildInvoiceList()),
            ],
          );
        }),
      ),
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
          _buildStatItem('Total', controller.totalInvoices.toString(), AppColors.tealColor),
          _buildStatItem('Paid', controller.paidInvoices.toString(), Colors.green),
          _buildStatItem('Pending', controller.pendingInvoices.toString(), Colors.orange),
          _buildStatItem('Revenue', '₹${AppUtil.formatCurrency(controller.totalRevenue)}', Colors.purple),
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
          TextField(
            decoration: InputDecoration(
              hintText: 'Search invoices...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: controller.filterInvoices,
          ),
          SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', controller.selectedFilter.value == 'All'),
                SizedBox(width: 8),
                _buildFilterChip('Paid', controller.selectedFilter.value == 'Paid'),
                SizedBox(width: 8),
                _buildFilterChip('Pending', controller.selectedFilter.value == 'Pending'),
                SizedBox(width: 8),
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
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No invoices found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first invoice to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed('/new-invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Create Invoice'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    return Obx(() => ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      itemCount: controller.filteredInvoiceList.length,
      itemBuilder: (context, index) {
        final invoice = controller.filteredInvoiceList[index];
        return _buildInvoiceListItem(invoice);
      },
    ));
  }

  Widget _buildInvoiceListItem(Invoice invoice) {
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
          onTap: () => controller.viewInvoiceDetails(invoice),
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
                    color: _getStatusColor(invoice.status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),

                // Invoice content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${invoice.invoiceId} - ${invoice.customerName}",
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
                              color: _getStatusColor(invoice.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              invoice.status?.toUpperCase() ?? 'UNKNOWN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(invoice.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(invoice.issueDate ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '₹${invoice.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.tealColor,
                            ),
                          ),
                        ],
                      ),
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
                          Text('View Details', style: TextStyle(color: AppColors.tealColor)),
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
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        controller.viewInvoiceDetails(invoice);
                        break;
                      case 'export_pdf':
                        controller.exportInvoiceAsPdf(invoice);
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
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
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

  // 🔹 Shimmer for invoice list
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerInvoiceListItem(),
    );
  }

  Widget _buildShimmerInvoiceListItem() {
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