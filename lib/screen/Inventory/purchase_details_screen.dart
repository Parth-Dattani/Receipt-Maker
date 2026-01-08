import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class PurchaseDetailsScreen extends GetView<PurchaseDetailsController> {
  static const String pageId = '/PurchaseDetailsScreen';

  const PurchaseDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () async {
              print("🔄 MANUAL REFRESH TRIGGERED");
              await controller.loadPurchaseItems(controller.purchase.value!.purchaseId!);
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
                  Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("purchase_not_found".tr, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          // 🔄 RESPONSIVE LAYOUT BUILDER
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildWebLayout(purchase);
              } else {
                return _buildMobileLayout(purchase);
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
  Widget _buildMobileLayout(PurchaseEntry purchase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPurchaseHeader(purchase),
          const SizedBox(height: 16),
          _buildVendorInfo(purchase),
          const SizedBox(height: 16),
          _buildPurchaseItems(purchase),
          const SizedBox(height: 16),
          _buildPaymentSummary(purchase),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT - IMPROVED VERSION
  // ===========================================================================
  Widget _buildWebLayout(PurchaseEntry purchase) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1400),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================
            // LEFT COLUMN: Items List (60%)
            // ========================================
            Expanded(
              flex: 60,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildPurchaseItemsWeb(purchase),
                  ],
                ),
              ),
            ),

            // ========================================
            // RIGHT COLUMN: Details & Summary (40%)
            // ========================================
            Expanded(
              flex: 40,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey.shade300, width: 1)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildPurchaseHeaderWeb(purchase),
                            const SizedBox(height: 24),
                            _buildVendorInfoWeb(purchase),
                            const SizedBox(height: 24),
                            _buildPaymentSummaryWeb(purchase),
                          ],
                        ),
                      ),
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

  // ===========================================================================
  // 🧩 SHARED WIDGETS (Mobile Version)
  // ===========================================================================

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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.tealColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(purchase.paymentStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    purchase.paymentStatus ?? "Unknown",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Date: ${_formatDate(purchase.purchaseDate)}",
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Notes: ${purchase.notes}",
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }

  /// Vendor details
  Widget _buildVendorInfo(PurchaseEntry purchase) {
    // Check if we have any vendor info to display
    final hasName = purchase.vendorName != null && purchase.vendorName!.isNotEmpty;
    final hasEmail = purchase.vendorEmail != null && purchase.vendorEmail!.isNotEmpty;
    final hasPhone = purchase.vendorMobile != null && purchase.vendorMobile!.isNotEmpty;
    final hasAddress = purchase.vendorAddress != null && purchase.vendorAddress!.isNotEmpty;

    // If no vendor info at all, show a message
    if (!hasName && !hasEmail && !hasPhone && !hasAddress) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "vendor_information".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tealColor,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "No vendor information available",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "vendor_information".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.tealColor,
              ),
            ),
            const SizedBox(height: 12),
            // Only show rows that have data
            if (hasName) _buildInfoRow("name".tr, purchase.vendorName!),
            if (hasEmail) _buildInfoRow("email".tr, purchase.vendorEmail!),
            if (hasPhone) _buildInfoRow("phone".tr, purchase.vendorMobile!),
            if (hasAddress) _buildInfoRow("address".tr, purchase.vendorAddress!),
          ],
        ),
      ),
    );
  }

  /// Vendor Info - Web Version (FIXED)
  Widget _buildVendorInfoWeb(PurchaseEntry purchase) {
    // Check if we have any vendor info to display
    final hasName = purchase.vendorName != null && purchase.vendorName!.isNotEmpty;
    final hasEmail = purchase.vendorEmail != null && purchase.vendorEmail!.isNotEmpty;
    final hasPhone = purchase.vendorMobile != null && purchase.vendorMobile!.isNotEmpty;
    final hasAddress = purchase.vendorAddress != null && purchase.vendorAddress!.isNotEmpty;

    // If no vendor info at all, show a message
    if (!hasName && !hasEmail && !hasPhone && !hasAddress) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: AppColors.tealColor, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "vendor_information".tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tealColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, size: 40, color: Colors.grey.shade400),
                      SizedBox(height: 8),
                      Text(
                        "No vendor information available",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
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

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: AppColors.tealColor, size: 22),
                SizedBox(width: 8),
                Text(
                  "vendor_information".tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Only show rows that have data
            if (hasName)
              _buildInfoRowWeb(Icons.person, "Name", purchase.vendorName!),
            if (hasEmail)
              _buildInfoRowWeb(Icons.email, "Email", purchase.vendorEmail!),
            if (hasPhone)
              _buildInfoRowWeb(Icons.phone, "Phone", purchase.vendorMobile!),
            if (hasAddress)
              _buildInfoRowWeb(Icons.location_on, "Address", purchase.vendorAddress!),
          ],
        ),
      ),
    );
  }

  /// Items list (Mobile)
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
                Text("purchase_items".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
                Obx(() => controller.isLoadingItems.value
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tealColor))
                    : IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: AppColors.tealColor),
                  onPressed: controller.refreshPurchaseItems,
                  tooltip: "Refresh Items",
                )),
              ],
            ),
            const SizedBox(height: 12),

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
                      Text("No items found", style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // header
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

                  // items rows
                  Column(
                    children: controller.purchaseItems.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.itemName ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w500)),
                                    if (item.unit != null && item.unit!.isNotEmpty)
                                      Text(
                                        "Unit: ${item.unit!.toUpperCase()}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                )),
                            Expanded(flex: 1, child: Text("${item.quantity ?? 0}", textAlign: TextAlign.center)),
                            Expanded(flex: 2, child: Text("₹${(item.purchasePrice ?? 0).toStringAsFixed(2)}", textAlign: TextAlign.right)),
                            Expanded(
                                flex: 2,
                                child: Text("₹${((item.quantity ?? 0) * (item.purchasePrice ?? 0)).toStringAsFixed(2)}",
                                    textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // subtotal
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: AppColors.tealColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.tealColor.withOpacity(0.3))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Items Subtotal (${controller.purchaseItems.length} items):",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor)),
                        Text("₹${AppUtil.formatCurrency(_calculateItemsSubtotal().toDouble())}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor, fontSize: 16)),
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

  // ===========================================================================
  // 💻 WEB-SPECIFIC WIDGETS
  // ===========================================================================

  /// Purchase Header - Web Optimized
  Widget _buildPurchaseHeaderWeb(PurchaseEntry purchase) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        purchase.purchaseId ?? 'N/A',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tealColor
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 6),
                          Text(
                            _formatDate(purchase.purchaseDate),
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 14
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(purchase.paymentStatus),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(purchase.paymentStatus).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(
                    purchase.paymentStatus ?? "Unknown",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13
                    ),
                  ),
                ),
              ],
            ),
            if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 18, color: Colors.blue.shade700),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        purchase.notes!,
                        style: TextStyle(
                            color: Colors.blue.shade900,
                            fontStyle: FontStyle.italic,
                            fontSize: 13
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }


  /// Payment Summary - Web Optimized
  Widget _buildPaymentSummaryWeb(PurchaseEntry purchase) {
    final subtotal = purchase.subtotal ?? _calculateItemsSubtotal();
    final tax = purchase.gstAmount ?? 0.0;
    final total = (subtotal + tax);
    final paidAmount = purchase.paidAmount ?? 0.0;
    final pendingAmount = purchase.pendingAmount ?? (total - paidAmount);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppColors.tealColor, size: 22),
                SizedBox(width: 8),
                Text(
                    "payment_summary".tr,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor
                    )
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAmountRow("Subtotal", subtotal, false),
            if (tax > 0) _buildAmountRow("GST", tax, false),
            const Divider(thickness: 2, height: 24),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.purple.shade100],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Total Amount",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900
                      )
                  ),
                  Text(
                      "₹${AppUtil.formatCurrency(total)}",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700
                      )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow("Paid Amount", paidAmount, false, color: Colors.green.shade600),
            _buildAmountRow("Pending Amount", pendingAmount, false, color: Colors.orange.shade600),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Payment Status:",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
                ),
                _getPaymentStatusBadge(purchase.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Items List - Web Optimized (Table Layout)
  Widget _buildPurchaseItemsWeb(PurchaseEntry purchase) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: AppColors.tealColor, size: 22),
                    SizedBox(width: 8),
                    Text(
                        "purchase_items".tr,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tealColor
                        )
                    ),
                  ],
                ),
                Obx(() => controller.isLoadingItems.value
                    ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.tealColor
                    )
                )
                    : IconButton(
                  icon: Icon(Icons.refresh, size: 22, color: AppColors.tealColor),
                  onPressed: controller.refreshPurchaseItems,
                  tooltip: "Refresh Items",
                )),
              ],
            ),
            const SizedBox(height: 20),

            Obx(() {
              if (controller.isLoadingItems.value) {
                return Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.tealColor),
                    )
                );
              }

              if (controller.purchaseItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                          "No items found",
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16
                          )
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // ✅ TABLE HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.tealColor.withOpacity(0.15),
                          AppColors.tealColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 40), // Index column
                        Expanded(
                            flex: 4,
                            child: Text(
                                "Item Name",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tealColor,
                                    fontSize: 14
                                )
                            )
                        ),
                        Expanded(
                            flex: 1,
                            child: Text(
                                "Qty",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tealColor,
                                    fontSize: 14
                                )
                            )
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                                "Price",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tealColor,
                                    fontSize: 14
                                )
                            )
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                                "Total",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tealColor,
                                    fontSize: 14
                                )
                            )
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ TABLE ROWS
                  ...controller.purchaseItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    final itemTotal = (item.quantity ?? 0) * (item.purchasePrice ?? 0);

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Index Badge
                          Container(
                            width: 40,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tealColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${index + 1}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                          // Item Name & Unit
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.itemName ?? "N/A",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (item.unit != null && item.unit!.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Text(
                                          "Unit: ${item.unit!.toUpperCase()}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Quantity
                          Expanded(
                            flex: 1,
                            child: Text(
                              "${item.quantity ?? 0}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          // Price
                          Expanded(
                            flex: 2,
                            child: Text(
                              "₹${(item.purchasePrice ?? 0).toStringAsFixed(2)}",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),

                          // Total
                          Expanded(
                            flex: 2,
                            child: Text(
                              "₹${itemTotal.toStringAsFixed(2)}",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // ✅ SUBTOTAL FOOTER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.tealColor.withOpacity(0.15),
                          AppColors.tealColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.tealColor.withOpacity(0.3), width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_cart, color: AppColors.tealColor, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Items Subtotal (${controller.purchaseItems.length} items):",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.tealColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "₹${AppUtil.formatCurrency(_calculateItemsSubtotal().toDouble())}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.tealColor,
                            fontSize: 18,
                          ),
                        ),
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

  // ===========================================================================
  // 🧩 HELPER WIDGETS
  // ===========================================================================

  /// Payment summary (Mobile)
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
            Text("payment_summary".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
            const SizedBox(height: 12),
            _buildInfoRow("Subtotal:", "₹${AppUtil.formatCurrency(subtotal)}"),
            if (tax > 0) _buildInfoRow("GST:", "₹${AppUtil.formatCurrency(tax)}"),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("₹${AppUtil.formatCurrency(total)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow("Paid Amount:", "₹${AppUtil.formatCurrency(paidAmount)}"),
            _buildInfoRow("Pending Amount:", "₹${AppUtil.formatCurrency(pendingAmount)}"),
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

  /// Reusable info row (Simple)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  /// Info row with icon (Web)
  Widget _buildInfoRowWeb(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Amount row (Web)
  Widget _buildAmountRow(String label, double amount, bool isTotal, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.grey.shade700,
            ),
          ),
          Text(
            "₹${AppUtil.formatCurrency(amount)}",
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  /// Payment status badge
  Widget _getPaymentStatusBadge(String? status) {
    final statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1.5),
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
          (sum, item) => sum + ((item.quantity ?? 0) * (item.purchasePrice ?? 0.0)),
    );
  }
}
