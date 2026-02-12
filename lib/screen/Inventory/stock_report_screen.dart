import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';




class StockReportScreen extends GetView<StockReportController> {
  static const String pageId = '/StockReportScreen';

  const StockReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 900;
    return Scaffold(
    backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Stock Report'),
            if (isWeb) ...[
              const Spacer(),
              Text(
                AppConstants.companyName, // No Obx needed for static string
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadStockReport,
            tooltip: "Refresh Data",
          ),
          // Web Export Buttons
          if (MediaQuery.of(context).size.width > 900) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: controller.exportStockReportPDF,
              tooltip: "Export PDF",
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              onPressed: controller.exportStockReportExcel,
              tooltip: "Export Excel",
            ),
            const SizedBox(width: 16),
          ] else
          // Mobile Popup Menu
            PopupMenuButton(
              icon: const Icon(Icons.download),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: const [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Export as PDF'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'excel',
                  child: Row(
                    children: const [
                      Icon(Icons.table_chart, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Export as Excel'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'pdf') {
                  controller.exportStockReportPDF();
                } else if (value == 'excel') {
                  controller.exportStockReportExcel();
                }
              },
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stockItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
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
    );
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT
  // ===========================================================================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // --- Stats Header ---
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Items',
                      '${controller.totalItems.value}',
                      Icons.inventory_2_rounded,
                      Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'Total Value',
                      '₹${AppUtil.formatCurrency(controller.totalStockValue.value)}',
                      Icons.account_balance_wallet_rounded,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Low Stock',
                      '${controller.lowStockItems.value}',
                      Icons.warning_amber_rounded,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'Out of Stock',
                      '${controller.outOfStockItems.value}',
                      Icons.error_outline_rounded,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- Search Bar ---
        Padding(
          padding: const EdgeInsets.all(12),
          child: _buildSearchBar(),
        ),

        // --- Stock List ---
        Expanded(
          child: Obx(() {
            if (controller.filteredItems.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.filteredItems.length,
              itemBuilder: (context, index) {
                final item = controller.filteredItems[index];
                return _buildStockItemCard(item);
              },
            );
          }),
        ),
      ],
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT
  // ===========================================================================
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN: Grid of Items (Flex 3) ---
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.filteredItems.isEmpty) {
                    return _buildEmptyState();
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 Columns
                      childAspectRatio: 1.35, // ✅ FIX: Lower ratio = Taller card (Prevents Overflow)
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: controller.filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.filteredItems[index];
                      return _buildStockItemCard(item);
                    },
                  );
                }),
              ),
            ],
          ),
        ),

        // --- RIGHT COLUMN: Sidebar Stats (Flex 1) ---
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text("Overview",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealColor)),
                  const SizedBox(height: 24),
                  _buildWebStatRow(
                    'Total Stock Value',
                    '₹${AppUtil.formatCurrency(controller.totalStockValue.value)}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildWebStatRow(
                    'Total Items',
                    '${controller.totalItems.value}',
                    Icons.inventory_2,
                    AppColors.tealColor,
                  ),
                  const SizedBox(height: 16),
                  _buildWebStatRow(
                    'Low Stock Items',
                    '${controller.lowStockItems.value}',
                    Icons.warning_amber,
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildWebStatRow(
                    'Out of Stock',
                    '${controller.outOfStockItems.value}',
                    Icons.error_outline,
                    Colors.red,
                  ),
                  const Divider(height: 40),
                  const Text("Quick Export",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.exportStockReportPDF,
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      label: const Text("Export PDF", style: TextStyle(color: Colors.black87)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.exportStockReportExcel,
                      icon: const Icon(Icons.table_chart, color: Colors.green),
                      label: const Text("Export Excel", style: TextStyle(color: Colors.black87)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 🧩 SHARED COMPONENTS
  // ===========================================================================

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search items by name...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: controller.filterItems,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Web Sidebar Stat Row
  Widget _buildWebStatRow(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ OPTIMIZED Stock Item Card
  Widget _buildStockItemCard(Item item) {
    final stock = item.currentStock ?? 0;
    final stockValue = (item.price ?? 0) * stock;

    Color statusColor = stock == 0
        ? Colors.red
        : stock < 10
        ? Colors.orange
        : Colors.green;
    String statusText = stock == 0
        ? 'Out of Stock'
        : stock < 10
        ? 'Low Stock'
        : 'In Stock';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12), // ✅ Reduced padding from 16 to 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Ensure minimum size
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ✅ Distribute vertically
        children: [
          // Top Row: Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.itemName ?? 'N/A',
                  maxLines: 1, // ✅ Prevent wrap
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          // ✅ Reduced Height of Divider
          const Divider(height: 12),

          // Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildInfoColumn('Price', '₹${item.price?.toStringAsFixed(2) ?? "0.00"}')),
              // Expanded(child: _buildInfoColumn('GST', '${item.gstPercent?.toStringAsFixed(0) ?? "0"}%')),
              // Expanded(child: _buildInfoColumn('Unit', item.unitOfMeasurement ?? '-')),
              Expanded(
                child: _buildInfoColumn(
                  'Stock',
                  '${item.currentStock ?? 0}',
                  isHighlight: true,
                  highlightColor: Colors.blue.shade700,
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  'Total Value',
                  '₹${AppUtil.formatCurrency(stockValue)}',
                  isHighlight: true,
                  highlightColor: Colors.green.shade700,
                ),
              ),
            ],
          ),

          // // ✅ Reduced Height of Spacer
          // const SizedBox(height: 6),
          //
          // // Bottom Row: Stock & Value
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Expanded(
          //       child: _buildInfoColumn(
          //         'Stock',
          //         '${item.currentStock ?? 0}',
          //         isHighlight: true,
          //         highlightColor: Colors.blue.shade700,
          //       ),
          //     ),
          //     Expanded(
          //       child: _buildInfoColumn(
          //         'Total Value',
          //         '₹${AppUtil.formatCurrency(stockValue)}',
          //         isHighlight: true,
          //         highlightColor: Colors.green.shade700,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isHighlight = false, Color? highlightColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isHighlight ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: isHighlight ? highlightColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No stock items found',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
