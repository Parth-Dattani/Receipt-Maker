import 'package:GetYourInvoice/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';

class InvoiceDetailsScreen extends GetView<InvoiceDetailsController> {
  static const String pageId = '/invoiceDetails';

  const InvoiceDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => InvoiceDetailsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('invoice_details'.tr),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          },
        ),
        actions: [
          // Edit button
          Obx(() {
            if (controller.isLoading.value) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Invoice',
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
              await controller.loadInvoiceItems(controller.invoice.value!.invoiceId!);
            },
            tooltip: 'Force Refresh Items',
          )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.invoice.value == null) {
            return _buildShimmerLayout(context);
          }

          final inv = controller.invoice.value;
          if (inv == null) return _buildErrorState(context);

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildWebLayout(inv);
              } else {
                return _buildMobileLayout(inv);
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
  Widget _buildMobileLayout(Invoice inv) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvoiceHeader(inv),
          const SizedBox(height: 24),
          _buildCustomerInfo(inv),
          const SizedBox(height: 24),
          _buildInvoiceItems(inv),
          const SizedBox(height: 24),
          _buildPaymentInfo(inv),
        ],
      ),
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Split View)
  // ===========================================================================
  Widget _buildWebLayout(Invoice inv) {
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
                _buildInvoiceHeader(inv),
                const SizedBox(height: 24),
                _buildInvoiceItems(inv),
              ],
            ),
          ),
        ),

        // RIGHT: Sidebar (35%) - Fixed Payment Summary & Actions
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
                  _buildCustomerInfo(inv),
                  const SizedBox(height: 24),
                  _buildPaymentInfo(inv),
                  const SizedBox(height: 24),
                  // Add any extra web-specific actions here (Download PDF, Print, etc.)
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

  Widget _buildInvoiceHeader(Invoice invoice) {
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
                Expanded(
                  child: Text('Invoice ${invoice.invoiceId ?? 'N/A'}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getStatusColor(invoice.status), borderRadius: BorderRadius.circular(20)),
                  child: Text(invoice.status ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Issue Date:', style: TextStyle(color: Colors.grey.shade600)),
                      Text(DateFormat('MMM dd, yyyy').format(invoice.issueDate ?? DateTime.now()), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date:', style: TextStyle(color: Colors.grey.shade600)),
                      Text(DateFormat('MMM dd, yyyy').format(invoice.dueDate ?? DateTime.now()), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Invoice invoice) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('customer_information'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
            const SizedBox(height: 12),
            _buildInfoRow('name'.tr, invoice.customerName ?? 'N/A'),
            if (invoice.customerEmail!.isNotEmpty) _buildInfoRow('email'.tr, invoice.customerEmail ?? 'N/A'),
            if (invoice.mobile.isNotEmpty) _buildInfoRow('phone'.tr, invoice.mobile ?? 'N/A'),
            if (invoice.customerAddress!.isNotEmpty) _buildInfoRow('address'.tr, invoice.customerAddress ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItems(Invoice invoice) {
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
                Text('invoice_items'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
                Obx(() => controller.isLoadingItems.value
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tealColor))
                    : IconButton(
                    icon: Icon(Icons.refresh, size: 20, color: AppColors.tealColor),
                    onPressed: controller.refreshInvoiceItems,
                    tooltip: 'Refresh Items')),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoadingItems.value) return _buildShimmerItemsList();
              if (controller.invoiceItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No items found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  ]),
                );
              }

              final itemsSubtotal = controller.invoiceItems.fold(0.0, (s, it) => s + ((it.quantity ?? 0) * (it.rate ?? 0.0)));

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.tealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor))),
                      Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor), textAlign: TextAlign.right)),
                      Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor), textAlign: TextAlign.right))
                    ]),
                  ),
                  const SizedBox(height: 8),
                  ...controller.invoiceItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(children: [
                        Expanded(
                            flex: 3,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.itemName?.isNotEmpty == true ? item.itemName! : 'Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ])),
                        Expanded(flex: 1, child: Text('${item.quantity ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500))),
                        Expanded(flex: 2, child: Text('${(item.rate ?? 0.0).toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
                        Expanded(flex: 2, child: Text('${((item.quantity ?? 0) * (item.rate ?? 0.0)).toStringAsFixed(2)}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)))
                      ]),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.tealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.tealColor.withOpacity(0.3))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Items Subtotal:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor)),
                      Text('₹${AppUtil.formatCurrency(itemsSubtotal)}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor, fontSize: 16))
                    ]),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(Invoice invoice) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('payment_summary'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor)),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoadingItems.value) return _buildShimmerPaymentSummary();
              double subtotal = 0.0;
              double totalGst = 0.0;
              for (var item in controller.invoiceItems) {
                final qty = item.quantity ?? 0.0;
                final rate = item.rate ?? 0.0;
                final itemTotal = qty * rate;
                subtotal += itemTotal;
                if (AppConstants.withGST.value) {
                  final gstRate = item.gstRate ?? 0.0;
                  totalGst += (itemTotal * gstRate) / 100;
                }
              }
              final double discount = invoice.discountAmount ?? 0.0;
              final double total = subtotal + totalGst - discount;

              return Column(
                children: [
                  _buildInfoRow('Subtotal:', '₹${AppUtil.formatCurrency(subtotal)}'),
                  if (AppConstants.withGST.value) ...[
                    _buildInfoRow('CGST:', '₹${(totalGst / 2).toStringAsFixed(2)}'),
                    _buildInfoRow('SGST:', '₹${(totalGst / 2).toStringAsFixed(2)}'),
                  ],
                  if (discount > 0) _buildInfoRow('Discount:', '-₹${AppUtil.formatCurrency(discount)}'),
                  const Divider(thickness: 2),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('₹${AppUtil.formatCurrency(total)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700))
                  ]),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)))
        ],
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

  // Shimmer loading (kept for Invoice Detail - only Dashboard has no shimmer)
  Widget _buildShimmerLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildShimmerInvoiceHeader(),
          const SizedBox(height: 24),
          _buildShimmerCustomerInfo(),
          const SizedBox(height: 24),
          _buildShimmerInvoiceItems(),
        ],
      ),
    );
  }
  Widget _buildShimmerInvoiceHeader() => Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(height: 150, color: Colors.white));
  Widget _buildShimmerCustomerInfo() => Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(height: 120, color: Colors.white));
  Widget _buildShimmerInvoiceItems() => Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(height: 200, color: Colors.white));
  Widget _buildShimmerPaymentSummary() => Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(height: 100, color: Colors.white));
  Widget _buildShimmerItemsList() => Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(height: 100, color: Colors.white));

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Invoice not found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

}


