import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';

class PurchaseDetailsScreen extends GetView<PurchaseDetailsController> {
  static const String pageId = '/PurchaseDetailsScreen';

  const PurchaseDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("purchase_details".tr),
        actions: [
          // Edit button
          Obx(() {
            final purchase = controller.purchase.value;
            return IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Purchase',
              onPressed: () => controller.navigateToEditMode(),
            );
          }),
          // Refresh button
          Obx(() => controller.isLoadingItems.value
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () async {
              print("🔄 MANUAL REFRESH TRIGGERED");
              await controller.loadPurchaseItems(
                  controller.purchase.value!.purchaseId!);
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
          final purchase = controller.purchase.value;
          if (purchase == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("purchase_not_found".tr,
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPurchaseHeader(purchase),
                const SizedBox(height: 24),
                _buildVendorInfo(purchase),
                const SizedBox(height: 24),
                _buildPurchaseItems(purchase),
                const SizedBox(height: 24),
                _buildPaymentSummary(purchase),
                const SizedBox(height: 24),
                _buildActionButtons(purchase),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Purchase header (ID, Date, Status)
  Widget _buildPurchaseHeader(PurchaseEntry purchase) {
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
                  "Purchase ${purchase.purchaseId ?? 'N/A'}",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tealColor),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(purchase.paymentStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    purchase.paymentStatus ?? "Unknown",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Date: ${_formatDate(purchase.purchaseDate)}",
              style: TextStyle(
                  color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Notes: ${purchase.notes}",
                style: TextStyle(
                    color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }

  /// Vendor details
  Widget _buildVendorInfo(PurchaseEntry purchase) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("vendor_information".tr,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor)),
            const SizedBox(height: 12),
            _buildInfoRow("name".tr, purchase.vendorName ?? "N/A"),
            _buildInfoRow("email".tr, purchase.vendorEmail ?? "N/A"),
            _buildInfoRow("phone".tr, purchase.vendorMobile ?? "N/A"),
            _buildInfoRow("address".tr, purchase.vendorAddress ?? "N/A"),
          ],
        ),
      ),
    );
  }

  /// Items list
  Widget _buildPurchaseItems(PurchaseEntry purchase) {
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
                Text("purchase_items".tr,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor)),
                Obx(() => controller.isLoadingItems.value
                    ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.tealColor))
                    : IconButton(
                  icon: Icon(Icons.refresh,
                      size: 20, color: AppColors.tealColor),
                  onPressed: controller.refreshPurchaseItems,
                  tooltip: "Refresh Items",
                )),
              ],
            ),
            const SizedBox(height: 12),

            /// Items list
            Obx(() {
              if (controller.isLoadingItems.value) {
                return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.tealColor),
                    ));
              }

              if (controller.purchaseItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text("No items found",
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // header
                  Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: AppColors.tealColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text("Item",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tealColor))),
                        Expanded(
                            flex: 1,
                            child: Text("Qty",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tealColor))),
                        Expanded(
                            flex: 2,
                            child: Text("Price",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tealColor))),
                        Expanded(
                            flex: 2,
                            child: Text("Total",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tealColor))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // items rows
                  Column(
                    children: controller.purchaseItems.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.itemName ?? "N/A",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    if (item.unit != null &&
                                        item.unit!.isNotEmpty)
                                      Text(
                                        "Unit: ${item.unit!.toUpperCase()}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                )),
                            Expanded(
                                flex: 1,
                                child: Text("${item.quantity ?? 0}",
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    "${(item.purchasePrice ?? 0).toStringAsFixed(2)}",
                                    textAlign: TextAlign.right)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    "${((item.quantity ?? 0) * (item.purchasePrice ?? 0)).toStringAsFixed(2)}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // subtotal
                  Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: AppColors.tealColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.tealColor.withOpacity(0.3))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Items Subtotal (${controller.purchaseItems.length} items):",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.tealColor)),
                        Text(
                            "₹${AppUtil.formatCurrency(_calculateItemsSubtotal().toDouble())}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.tealColor,
                                fontSize: 16)),
                      ],
                    ),
                  )
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  /// Payment summary
  Widget _buildPaymentSummary(PurchaseEntry purchase) {
    final subtotal = purchase.subtotal ?? _calculateItemsSubtotal();
    final tax = purchase.gstAmount ?? 0.0;
    final total = (subtotal + tax);
    final paidAmount = purchase.paidAmount ?? 0.0;
    final pendingAmount = purchase.pendingAmount ?? (total - paidAmount);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("payment_summary".tr,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor)),
            const SizedBox(height: 12),
            _buildInfoRow("Subtotal:", "₹${AppUtil.formatCurrency(subtotal)}"),
            if (tax > 0)
              _buildInfoRow("GST:", "₹${AppUtil.formatCurrency(tax)}"),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount:",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("₹${AppUtil.formatCurrency(total)}",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                "Paid Amount:", "₹${AppUtil.formatCurrency(paidAmount)}"),
            _buildInfoRow("Pending Amount:",
                "₹${AppUtil.formatCurrency(pendingAmount)}"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Payment Status:"),
                _getPaymentStatusBadge(purchase.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Action buttons
  Widget _buildActionButtons(PurchaseEntry purchase) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.downloadPurchasePdf(),
            icon: const Icon(Icons.download),
            label: const Text("Download PDF"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tealColor,
              side: BorderSide(color: AppColors.tealColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.sharePurchase(),
            icon: const Icon(Icons.share),
            label: const Text("Share Purchase"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  /// Payment status badge
  Widget _getPaymentStatusBadge(String? status) {
    final statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        status ?? "Unknown",
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "paid":
        return Colors.green;
      case "partial":
        return Colors.blue;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("MMM dd, yyyy").format(date);
  }

  double _calculateItemsSubtotal() {
    return controller.purchaseItems.fold(
      0.0,
          (sum, item) =>
      sum + ((item.quantity ?? 0) * (item.purchasePrice ?? 0.0)),
    );
  }
}