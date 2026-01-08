import 'package:demo_prac_getx/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class ChallanDetailsScreen extends GetView<ChallanDetailsController> {
  static const String pageId = '/ChallanDetailsScreen';

  const ChallanDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("challan_details".tr),
        actions: [
          // Edit button
          Obx(() {
            final challan = controller.challan.value;
            // final isProgress = challan?.status?.toLowerCase() == 'progress';

            return IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Challan',
              onPressed: () => controller.navigateToEditMode(),
            );
          }),
          // Refresh button
          Obx(() => controller.isLoadingItems.value
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          )
              : IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () async {
              await controller.loadChallanItems(controller.challan.value!.challanId!);
              Get.snackbar('Success', 'Items refreshed from server');
            },
            tooltip: "Force Refresh Items",
          )),
        ],
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          final challan = controller.challan.value;
          if (challan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("challan_not_found".tr, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildWebLayout(challan);
              } else {
                return _buildMobileLayout(challan);
              }
            },
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT
  // ===========================================================================
  Widget _buildMobileLayout(Challan challan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChallanHeader(challan),
          const SizedBox(height: 24),
          _buildCustomerInfo(challan),
          const SizedBox(height: 24),
          _buildChallanItems(challan),
          const SizedBox(height: 24),
          _buildPaymentSummary(challan),
          // const SizedBox(height: 24),
          // _buildActionButtons(challan),
        ],
      ),
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Split View)
  // ===========================================================================
  Widget _buildWebLayout(Challan challan) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: Details Area (65%)
        Expanded(
          flex: 13,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildChallanHeader(challan),
                const SizedBox(height: 24),

                _buildChallanItems(challan),
              ],
            ),
          ),
        ),

        // RIGHT: Sidebar (35%) - Summary & Actions
        Expanded(
          flex: 7,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildCustomerInfo(challan),
                  const SizedBox(height: 24),
                  _buildPaymentSummary(challan),
                  // const SizedBox(height: 24),
                  // _buildActionButtons(challan), // Add actions if needed
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 🧩 WIDGET COMPONENTS
  // ===========================================================================

  Widget _buildChallanHeader(Challan challan) {
    return Card(
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
                Text(
                  "Challan ${challan.challanId ?? 'N/A'}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.tealColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(challan.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    challan.status ?? "Unknown",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Date: ${_formatDate(challan.challanDate)}",
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            if (challan.notes != null && challan.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Notes: ${challan.notes}",
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Challan challan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("customer_information".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
            const SizedBox(height: 12),
            _buildInfoRow("name".tr, challan.customerName ?? "N/A"),
            _buildInfoRow("email".tr, challan.customerEmail ?? "N/A"),
            _buildInfoRow("phone".tr, challan.customerMobile ?? "N/A"),
            _buildInfoRow("address".tr, challan.customerAddress ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildChallanItems(Challan challan) {
    return Card(
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
                Text("challan_items".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
                Obx(() => controller.isLoadingItems.value
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tealColor))
                    : IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: AppColors.tealColor),
                  onPressed: controller.refreshChallanItems,
                  tooltip: "Refresh Items",
                )),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoadingItems.value) {
                return Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.tealColor)));
              }

              if (controller.challanItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text("No items found", style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.tealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor))),
                        Expanded(flex: 1, child: Text("Qty", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor))),
                        Expanded(flex: 2, child: Text("Price", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor))),
                        Expanded(flex: 2, child: Text("Total", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...controller.challanItems.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item.itemName ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w500)),
                                if (item.unit != null && item.unit!.isNotEmpty)
                                  Text("Unit: ${item.unit!.toUpperCase()}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ])),
                          Expanded(flex: 1, child: Text("${item.quantity ?? 0}", textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text("${(item.price ?? 0).toStringAsFixed(2)}", textAlign: TextAlign.right)),
                          Expanded(
                              flex: 2,
                              child: Text("${((item.quantity ?? 0) * (item.price ?? 0)).toStringAsFixed(2)}",
                                  textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700))),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.tealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.tealColor.withOpacity(0.3))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("Items Subtotal (${controller.challanItems.length} items):", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor)),
                      Text("₹${AppUtil.formatCurrency(_calculateItemsSubtotal().toDouble())}", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor, fontSize: 16)),
                    ]),
                  )
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(Challan challan) {
    final subtotal = challan.subtotal ?? _calculateItemsSubtotal();
    final tax = challan.gstAmount ?? 0.0;
    final total = (subtotal + tax);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("payment_summary".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
            const SizedBox(height: 12),
            _buildInfoRow("Subtotal:", "₹${AppUtil.formatCurrency(subtotal)}"),
            if (tax > 0) _buildInfoRow("GST:", "₹${AppUtil.formatCurrency(tax)}"),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("₹${AppUtil.formatCurrency(total)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("MMM dd, yyyy").format(date);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "completed":
      case "delivered":
        return Colors.green;
      case "progress":
        return AppColors.tealColor;
      case "inprogress":
      case "pending":
        return Colors.orange;
      case "cancelled":
      case "rejected":
        return Colors.red;
      default:
        return AppColors.tealColor;
    }
  }

  double _calculateItemsSubtotal() {
    return controller.challanItems.fold(
      0.0,
          (sum, item) => sum + ((item.quantity ?? 0) * (item.price ?? 0.0)),
    );
  }
}


