import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';
import '../../widgets/web_screen_wrapper.dart';



class StockReportScreen extends GetView<StockReportController> {
  static const String pageId = '/StockReportScreen';
  const StockReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;
    final content = Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Stock Report'),
            if (isWeb) ...[
              const Spacer(),
              Text(
                AppConstants.companyName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadStockReport,
            tooltip: 'Refresh Data',
          ),
          if (isWeb) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: controller.exportStockReportPDF,
              tooltip: 'Export PDF',
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              onPressed: controller.exportStockReportExcel,
              tooltip: 'Export Excel',
            ),
            const SizedBox(width: 8),
          ] else
            PopupMenuButton(
              icon: const Icon(Icons.download),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'pdf',
                  child: Row(children: const [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Export as PDF'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'excel',
                  child: Row(children: const [
                    Icon(Icons.table_chart, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Export as Excel'),
                  ]),
                ),
              ],
              onSelected: (value) {
                if (value == 'pdf') controller.exportStockReportPDF();
                else if (value == 'excel') controller.exportStockReportExcel();
              },
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.customeBackground,
        child: Obx(() {
          if (controller.isLoading.value && controller.stockItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) return _buildWebLayout();
              return _buildMobileLayout();
            },
          );
        }),
      ),
    );
    if (kIsWeb) return webScreenWrapper(currentRoute: pageId, child: content);
    return content;
  }

  // =========================================================================
  // 📱 MOBILE LAYOUT
  // =========================================================================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Items', '${controller.totalItems.value}', Icons.inventory_2_rounded, Colors.teal)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard('Total Value', '₹${AppUtil.formatCurrency(controller.totalStockValue.value)}', Icons.account_balance_wallet_rounded, Colors.green)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Low Stock', '${controller.lowStockItems.value}', Icons.warning_amber_rounded, Colors.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard('Out of Stock', '${controller.outOfStockItems.value}', Icons.error_outline_rounded, Colors.red)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: _buildSearchBar(),
        ),
        Expanded(
          child: Obx(() {
            if (controller.filteredItems.isEmpty) return _buildEmptyState();
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.filteredItems.length,
              itemBuilder: (context, index) {
                return _buildMobileStockCard(controller.filteredItems[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  // =========================================================================
  // 💻 WEB LAYOUT — IMPROVED
  // =========================================================================
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: Main content
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search + Filter chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    Obx(() => _buildFilterChips()),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              // Grid
              Expanded(
                child: Obx(() {
                  if (controller.filteredItems.isEmpty) return _buildEmptyState();
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: controller.filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildWebStockCard(controller.filteredItems[index]);
                    },
                  );
                }),
              ),
            ],
          ),
        ),

        // RIGHT: Sidebar
        Container(
          width: 220,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Colors.grey.shade200)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Text(
                  'OVERVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                // Stat cards
                Obx(() => Column(
                  children: [
                    _buildSidebarStatCard(
                      'Total Stock Value',
                      '₹${AppUtil.formatCurrency(controller.totalStockValue.value)}',
                      Icons.account_balance_wallet_outlined,
                      AppColors.appTheame,
                    ),
                    const SizedBox(height: 8),
                    _buildSidebarStatCard(
                      'Total Items',
                      '${controller.totalItems.value}',
                      Icons.inventory_2_outlined,
                      Colors.blue.shade600,
                    ),
                    const SizedBox(height: 8),
                    _buildSidebarStatCard(
                      'Low Stock',
                      '${controller.lowStockItems.value}',
                      Icons.warning_amber_outlined,
                      Colors.orange.shade600,
                      highlight: controller.lowStockItems.value > 0,
                    ),
                    const SizedBox(height: 8),
                    _buildSidebarStatCard(
                      'Out of Stock',
                      '${controller.outOfStockItems.value}',
                      Icons.error_outline,
                      Colors.red.shade600,
                      highlight: controller.outOfStockItems.value > 0,
                    ),
                  ],
                )),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                Text(
                  'EXPORT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.exportStockReportPDF,
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                    label: const Text('Export PDF', style: TextStyle(fontSize: 13, color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.exportStockReportExcel,
                    icon: const Icon(Icons.table_chart, color: Colors.green, size: 16),
                    label: const Text('Export Excel', style: TextStyle(fontSize: 13, color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter Chips ──
  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'In Stock', 'value': 'in_stock'},
      {'label': 'Low Stock', 'value': 'low_stock'},
      {'label': 'Out of Stock', 'value': 'out_of_stock'},
    ];
    return Row(
      children: filters.map((f) {
        final isSelected = controller.filterStatus.value == f['value'];
        Color chipColor = AppColors.appTheame;
        if (f['value'] == 'low_stock') chipColor = Colors.orange.shade600;
        if (f['value'] == 'out_of_stock') chipColor = Colors.red.shade600;
        if (f['value'] == 'in_stock') chipColor = Colors.green.shade600;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => controller.filterStatus.value = f['value']!,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? chipColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? chipColor : Colors.grey.shade300,
                ),
              ),
              child: Text(
                f['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Web Stock Card ──
  Widget _buildWebStockCard(Item item) {
    final stock = item.currentStock;
    final stockValue = item.price * stock;
    final unit = item.unitOfMeasurement.trim().isEmpty ? 'pcs' : item.unitOfMeasurement;
    final stockDisplay = _formatStockWithUnit(stock, unit);

    Color statusColor;
    String statusText;
    Color borderColor;

    if (stock == 0) {
      statusColor = Colors.red.shade600;
      statusText = 'Out of Stock';
      borderColor = Colors.red.shade200;
    } else if (stock < 10) {
      statusColor = Colors.orange.shade600;
      statusText = 'Low Stock';
      borderColor = Colors.orange.shade200;
    } else {
      statusColor = Colors.green.shade600;
      statusText = 'In Stock';
      borderColor = Colors.grey.shade200;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top: name + badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 6),

          // Bottom: 3 cols
          Row(
            children: [
              Expanded(
                child: _buildInfoCol(
                  'Price',
                  '₹${item.price.toStringAsFixed(0)}',
                  Colors.black87,
                ),
              ),
              Expanded(
                child: _buildInfoCol(
                  'Stock',
                  stockDisplay,
                  Colors.blue.shade700,
                ),
              ),
              Expanded(
                child: _buildInfoCol(
                  'Value',
                  '₹${AppUtil.formatCurrency(stockValue)}',
                  Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }

  // ── Sidebar Stat Card ──
  Widget _buildSidebarStatCard(String label, String value, IconData icon, Color color, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.06) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? color.withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: highlight ? color : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile Card ──
  Widget _buildMobileStockCard(Item item) {
    final stock = item.currentStock;
    final stockValue = item.price * stock;
    final unit = item.unitOfMeasurement.trim().isEmpty ? 'pcs' : item.unitOfMeasurement;
    final stockDisplay = _formatStockWithUnit(stock, unit);

    Color statusColor = stock == 0 ? Colors.red : stock < 10 ? Colors.orange : Colors.green;
    String statusText = stock == 0 ? 'Out of Stock' : stock < 10 ? 'Low Stock' : 'In Stock';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInfoCol('Price', '₹${item.price.toStringAsFixed(0)}', Colors.black87)),
              Expanded(child: _buildInfoCol('Stock', stockDisplay, Colors.blue.shade700)),
              Expanded(child: _buildInfoCol('Value', '₹${AppUtil.formatCurrency(stockValue)}', Colors.green.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared ──
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search items by name...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.appTheame),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
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
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No stock items found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  String _formatStockWithUnit(double stock, String unit) {
    final u = (unit.trim().isEmpty ? 'pcs' : unit).trim().toLowerCase();
    final isWhole = u == 'pcs' || u == 'box';
    final value = (isWhole || stock == stock.truncateToDouble())
        ? stock.toInt().toString()
        : stock.toStringAsFixed(2);
    final unitLabel = u.isEmpty ? 'Pcs' : (u.length == 1 ? u.toUpperCase() : u[0].toUpperCase() + u.substring(1));
    return '$value $unitLabel';
  }
}