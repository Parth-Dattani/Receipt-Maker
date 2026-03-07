import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class InventoryManagementScreen extends GetView<ItemController> {
  static const pageId = "/InventoryScreen";

  const InventoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 4,
          backgroundColor: AppColors.tealColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            ),
          ),
          title: const Text(
            "Inventory Management",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Dashboard", icon: Icon(Icons.dashboard)),
              Tab(text: "Transactions", icon: Icon(Icons.history)),
              Tab(text: "Low Stock", icon: Icon(Icons.warning_amber)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboardTab(context),
            _buildTransactionsTab(context),
            _buildLowStockTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: "Total Items",
                  value: "${controller.itemList.length}",
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildSummaryCard(
                  title: "Inventory Value",
                  value: "₹${controller.totalInventoryValue.toStringAsFixed(0)}",
                  icon: Icons.attach_money,
                  color: Colors.green,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Obx(() => _buildSummaryCard(
                  title: "Low Stock Items",
                  value: "${controller.lowStockItems.length}",
                  icon: Icons.warning_amber,
                  color: Colors.orange,
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildSummaryCard(
                  title: "Active Items",
                  value: "${controller.itemList.where((i) => i.isActive ?? false).length}",
                  icon: Icons.check_circle_outline,
                  color: Colors.teal,
                )),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Low Stock Threshold Adjustment
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Low Stock Threshold",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Slider(
                        value: controller.lowStockThreshold.value.toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: "${controller.lowStockThreshold.value} units",
                        activeColor: AppColors.tealColor,
                        onChanged: (value) {
                          controller.setLowStockThreshold(value.toInt());
                        },
                      )),
                    ),
                    Obx(() => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        "${controller.lowStockThreshold.value}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealColor,
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: "Add Stock",
                  color: Colors.green,
                  onTap: () => _showInventoryDialog(context, 'add'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.remove_circle_outline,
                  label: "Remove Stock",
                  color: Colors.red,
                  onTap: () => _showInventoryDialog(context, 'remove'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: "Adjust Stock",
                  color: Colors.blue,
                  onTap: () => _showInventoryDialog(context, 'adjust'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingTransactions.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.inventoryTransactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "No Transactions Yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.inventoryTransactions.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final txn = controller.inventoryTransactions[index];
          return _buildTransactionCard(txn);
        },
      );
    });
  }

  Widget _buildLowStockTab(BuildContext context) {
    return Obx(() {
      final lowStockItems = controller.lowStockItems;

      if (lowStockItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                "All Items Well Stocked!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "No items below threshold of ${controller.lowStockThreshold.value}",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: lowStockItems.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = lowStockItems[index];
          final stockPercentage = (item.currentStock / 100) * 100;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Stock: ${item.currentStock} ${item.unitOfMeasurement}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () => _showQuickAddStock(context, item),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: stockPercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.red.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        item.currentStock <= 5 ? Colors.red : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(InventoryTransaction txn) {
    final typeColors = {
      'add': Colors.green,
      'remove': Colors.red,
      'sale': Colors.orange,
      'return': Colors.blue,
      'adjustment': Colors.purple,
    };

    final typeIcons = {
      'add': Icons.add_circle_outline,
      'remove': Icons.remove_circle_outline,
      'sale': Icons.shopping_cart_checkout,
      'return': Icons.undo,
      'adjustment': Icons.edit_outlined,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColors[txn.type]?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                typeIcons[txn.type] ?? Icons.history,
                color: typeColors[txn.type],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.itemName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${txn.reason} • ${txn.quantity} units",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (txn.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      txn.notes,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${txn.quantity}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: typeColors[txn.type],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${txn.timestamp.hour}:${txn.timestamp.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInventoryDialog(BuildContext context, String type) {
    final itemCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    Item? selectedItem;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 500,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type == 'add'
                            ? "Add Stock"
                            : type == 'remove'
                            ? "Remove Stock"
                            : "Adjust Stock",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.tealColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Item Selection Dropdown
                  DropdownButtonFormField<Item>(
                    decoration: InputDecoration(
                      labelText: "Select Item *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: Icon(Icons.inventory_2_outlined,
                          color: AppColors.tealColor),
                    ),
                    value: selectedItem,
                    items: controller.itemList.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.itemName),
                      );
                    }).toList(),
                    onChanged: (item) {
                      setState(() => selectedItem = item);
                    },
                    validator: (value) =>
                    value == null ? "Please select an item" : null,
                  ),
                  const SizedBox(height: 16),
                  // Quantity Field
                  TextFormField(
                    controller: quantityCtrl,
                    decoration: InputDecoration(
                      labelText: type == 'adjust' ? "New Quantity *" : "Quantity *",
                      hintText: "Enter quantity",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon:
                      Icon(Icons.numbers, color: AppColors.tealColor),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return "Quantity required";
                      if (int.tryParse(value!) == null)
                        return "Enter valid number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Reason Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Reason *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _getReasons(type)
                        .map((reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => reasonCtrl.text = value ?? '');
                    },
                    validator: (value) =>
                    value == null ? "Please select a reason" : null,
                  ),
                  const SizedBox(height: 16),
                  // Notes Field
                  TextFormField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: "Notes (Optional)",
                      hintText: "Add any additional notes",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon:
                      Icon(Icons.notes_outlined, color: AppColors.tealColor),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (selectedItem == null || quantityCtrl.text.isEmpty) {
                            showCustomSnackbar(
                              title: "Error",
                              message: "Please fill all required fields",
                              baseColor: Colors.red.shade700,
                              icon: Icons.error_outline,
                            );
                            return;
                          }

                          final quantity = int.tryParse(quantityCtrl.text) ?? 0;
                          final quantityDouble = double.tryParse(quantityCtrl.text.replaceAll(',', '.')) ?? quantity.toDouble();
                          final reason = reasonCtrl.text;
                          final notes = notesCtrl.text;

                          try {
                            if (type == 'add') {
                              await controller.addInventory(
                                itemId: selectedItem!.itemId,
                                quantity: quantity,
                                reason: reason,
                                notes: notes,
                              );
                            } else if (type == 'remove') {
                              await controller.removeInventory(
                                itemId: selectedItem!.itemId,
                                quantity: quantity,
                                reason: reason,
                                notes: notes,
                              );
                            } else if (type == 'adjust') {
                              await controller.adjustInventory(
                                itemId: selectedItem!.itemId,
                                newQuantity: quantityDouble,
                                reason: reason,
                                notes: notes,
                              );
                            }
                            Navigator.pop(context);
                          } catch (e) {
                            print("Error: $e");
                          }
                        },
                        child: Text(
                          type == 'add'
                              ? "Add Stock"
                              : type == 'remove'
                              ? "Remove Stock"
                              : "Adjust Stock",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickAddStock(BuildContext context, Item item) {
    final quantityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Add Stock to ${item.itemName}"),
        content: TextFormField(
          controller: quantityCtrl,
          decoration: InputDecoration(
            labelText: "Quantity to Add",
            hintText: "Enter quantity",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.add_circle_outline, color: Colors.green),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (quantityCtrl.text.isEmpty) return;
              await controller.addInventory(
                itemId: item.itemId,
                quantity: int.parse(quantityCtrl.text),
                reason: "Quick Add",
              );
              Navigator.pop(context);
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<String> _getReasons(String type) {
    switch (type) {
      case 'add':
        return [
          'Purchase',
          'Return from Customer',
          'Stock Transfer',
          'Correction',
          'Other',
        ];
      case 'remove':
        return [
          'Sale',
          'Damage',
          'Loss',
          'Expiry',
          'Sample',
          'Other',
        ];
      case 'adjust':
        return [
          'Physical Count',
          'System Correction',
          'Inventory Audit',
          'Other',
        ];
      default:
        return [];
    }
  }
}


