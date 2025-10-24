
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../services/service.dart';
import '../../utils/utils.dart';

class PaymentDetailsScreen extends GetView<PaymentDetailsController> {
  static const String pageId = '/PaymentDetailsScreen';
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) return _buildLoadingShimmer();

          // ✅ Check both invoices and purchases
          bool hasData = controller.invoices.isNotEmpty || controller.purchases.isNotEmpty;
          if (!hasData) return _buildEmptyState();

          return Column(
            children: [
              _buildTabBar(),  // ✅ NEW: Tab selector
              _buildSearchBar(),
              Expanded(child: _buildTransactionTable()),
            ],
          );
        }),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  AppBar _buildAppBar() => AppBar(
    title: const Text(
      'Payment Transactions',
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    backgroundColor: AppColors.tealColor,
    foregroundColor: Colors.white,
    elevation: 0,
  );

  // ✅ NEW: Tab Bar for Invoice/Purchase switch
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'Invoice',
              controller.selectedTab.value == 'Invoice',
              Icons.receipt_long,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              'Purchase',
              controller.selectedTab.value == 'Purchase',
              Icons.shopping_cart,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTabButton(String label, bool isSelected, IconData icon) {
    return GestureDetector(
      onTap: () => controller.switchTab(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tealColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        onChanged: (value) => controller.updateSearchQuery(value),
        decoration: InputDecoration(
          hintText: controller.selectedTab.value == 'Invoice'
              ? 'Search by customer name or invoice ID...'
              : 'Search by vendor name or purchase ID...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.tealColor),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey.shade600),
            onPressed: () => controller.updateSearchQuery(''),
          )
              : const SizedBox.shrink(),
        ),
      ),
    ));
  }

  // ✅ UPDATED: Transaction table with both invoice and purchase views
  Widget _buildTransactionTable() {
    return Obx(() {
      if (controller.selectedTab.value == 'Invoice') {
        return _buildInvoiceList();
      } else {
        return _buildPurchaseList();
      }
    });
  }

  // ✅ Invoice List (existing logic)
  Widget _buildInvoiceList() {
    return Obx(() {
      final customerSummaries = controller.getFilteredInvoiceCustomerSummaries();

      if (customerSummaries.isEmpty) {
        return _buildNoResultsFound();
      }

      return RefreshIndicator(
        onRefresh: controller.loadData,
        color: AppColors.tealColor,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: customerSummaries.length,
          itemBuilder: (context, index) {
            final customer = customerSummaries[index];

            return _buildTransactionCard(
              title: customer.customerName,
              transactionType: 'Receipt',
              transactionColor: Colors.green,
              count: customer.invoiceCount,
              countLabel: 'Invoice',
              totalAmount: customer.totalAmount,
              receivedAmount: customer.receivedAmount,
              pendingAmount: customer.pendingAmount,
              ids: customer.invoiceIds,
            );
          },
        ),
      );
    });
  }

  // ✅ NEW: Purchase List
  Widget _buildPurchaseList() {
    return Obx(() {
      final vendorSummaries = controller.getFilteredPurchaseVendorSummaries();

      if (vendorSummaries.isEmpty) {
        return _buildNoResultsFound();
      }

      return RefreshIndicator(
        onRefresh: controller.loadData,
        color: AppColors.tealColor,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: vendorSummaries.length,
          itemBuilder: (context, index) {
            final vendor = vendorSummaries[index];

            return _buildTransactionCard(
              title: vendor.vendorName,
              transactionType: 'Payment',
              transactionColor: Colors.orange,
              count: vendor.purchaseCount,
              countLabel: 'Purchase',
              totalAmount: vendor.totalAmount,
              receivedAmount: vendor.paidAmount,
              pendingAmount: vendor.pendingAmount,
              ids: vendor.purchaseIds,
            );
          },
        ),
      );
    });
  }

  // ✅ Unified transaction card widget
  Widget _buildTransactionCard({
    required String title,
    required String transactionType,
    required Color transactionColor,
    required int count,
    required String countLabel,
    required double totalAmount,
    required double receivedAmount,
    required double pendingAmount,
    required List<String> ids,
  }) {
    // Determine if this is Invoice or Purchase based on transactionType
    final isInvoice = transactionType == 'Receipt';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          PaymentDetailsBottomSheet.show(
            customerName: title,
            paymentMethod: transactionType,
            amount: '₹${AppUtil.formatCurrency(totalAmount)}',
            date: DateFormat('dd MMM yyyy').format(DateTime.now()),
            notes: '',
            invoiceIds: ids,
            currentReceived: receivedAmount,
            currentPending: pendingAmount,
            isInvoice: isInvoice, // ✅ NEW: Pass transaction type
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: transactionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      transactionType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: transactionColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.receipt_long, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '$count ${countLabel}${count > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${AppUtil.formatCurrency(totalAmount)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: transactionColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ✅ DYNAMIC: Show "Received" for Invoice, "Paid" for Purchase
                      Row(
                        children: [
                          Text(
                            isInvoice ? 'Received: ' : 'Paid: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '₹${AppUtil.formatCurrency(receivedAmount)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Pending: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '₹${AppUtil.formatCurrency(pendingAmount)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() => const Center(
    child: CircularProgressIndicator(),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        const Text(
          "No Transactions Found",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your payment transactions will appear here",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  Widget _buildFAB() => FloatingActionButton(
    backgroundColor: AppColors.tealColor,
    onPressed: () => _generateReport(),
    child: const Icon(Icons.download, color: Colors.white),
  );

  // Generate report dialog (same as before, but now works for both tabs)
  void _generateReport() {
    // Ensure context is available
    if (Get.context == null) {
      Get.snackbar(
        'Error',
        'Unable to open report generator',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    // Show the bottom sheet
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    'Generate ${controller.selectedTab.value} Report',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  )),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Date Range',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      'From Date',
                      Icons.calendar_today,
                      controller.getFormattedDate(controller.fromDate.value),
                          () => _selectFromDate(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDateField(
                      'To Date',
                      Icons.calendar_today,
                      controller.getFormattedDate(controller.toDate.value),
                          () => _selectToDate(),
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 20),

              const Text(
                'Export Format',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildFormatChip(
                      'PDF',
                      Icons.picture_as_pdf,
                      controller.selectedExportFormat.value == 'PDF',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormatChip(
                      'Excel',
                      Icons.table_chart,
                      controller.selectedExportFormat.value == 'Excel',
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 30),

              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isGeneratingReport.value
                      ? null
                      : () => controller.generateReport(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: controller.isGeneratingReport.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Generate Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    ); // ✅ Make sure this closing parenthesis is here
  }

  Widget _buildFormatChip(String title, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () => controller.selectExportFormat(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.tealColor.withOpacity(0.15)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.tealColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.tealColor : Colors.grey[700],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.tealColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.tealColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: controller.fromDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.tealColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setFromDate(picked);
    }
  }

  void _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: controller.toDate.value ?? DateTime.now(),
      firstDate: controller.fromDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.tealColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setToDate(picked);
    }
  }
}

class PaymentDetailsBottomSheet {
  // Replace the PaymentDetailsBottomSheet.show() method with this fixed version:

  static void show({
    required String customerName,
    required String paymentMethod,
    required String amount,
    required String date,
    required String notes,
    required List<String> invoiceIds,
    double? currentReceived,
    double? currentPending,
    required bool isInvoice, // ✅ Track if it's Invoice or Purchase
  }) async {
    // Show loading overlay
    Get.dialog(
      SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.tealColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  isInvoice ? 'Loading payment details...' : 'Loading purchase details...',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    final TextEditingController noteController = TextEditingController(text: notes);
    final TextEditingController receivedAmountController = TextEditingController();
    final Set<String> selectedInvoiceIds = {};

    // Parse total amount
    final double totalAmount = double.tryParse(amount.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
    final double alreadyReceived = currentReceived ?? 0.0;
    final double alreadyPending = currentPending ?? totalAmount;

    double receivedAmount = 0.0;
    double pendingAmount = alreadyPending;
    String errorMessage = '';

    // ✅ FIX: Fetch correct data based on type
    List<dynamic> records = []; // Can hold Invoice or PurchaseEntry
    try {
      if (isInvoice) {
        // Fetch invoices
        final allInvoices = await GoogleSheetService.getInvoices(type: "INV");
        for (String invoiceIdWithPrefix in invoiceIds) {
          final invoiceId = invoiceIdWithPrefix.replaceFirst('INV-', '');
          final invoice = allInvoices.firstWhereOrNull((inv) => inv.invoiceId == invoiceId);
          if (invoice != null) {
            records.add(invoice);
          }
        }
        print("✅ Loaded ${records.length} invoices for bottom sheet");
      } else {
        // ✅ Fetch purchases instead
        final allPurchases = await GoogleSheetService.getPurchasesList();
        for (String purchaseIdWithPrefix in invoiceIds) {
          final purchaseId = purchaseIdWithPrefix.replaceFirst('PUR-', '');
          final purchase = allPurchases.firstWhereOrNull((pur) => pur.purchaseId == purchaseId);
          if (purchase != null) {
            records.add(purchase);
          }
        }
        print("✅ Loaded ${records.length} purchases for bottom sheet");
      }
    } catch (e) {
      print("❌ Error loading ${isInvoice ? 'invoices' : 'purchases'}: $e");
    }

    Get.back(); // Close loading dialog

    // Show actual bottom sheet
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isInvoice ? "Payment Details" : "Purchase Payment Details",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _infoRow(isInvoice ? "Customer" : "Vendor", customerName),
                  _infoRow("Payment Method", paymentMethod),

                  const Divider(height: 30, thickness: 1),

                  // Amount Summary Section
                  const Text(
                    "Amount Summary",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _summaryRow("Total Amount", totalAmount, Colors.blue.shade700),
                        const Divider(height: 20),
                        _summaryRow(
                          isInvoice ? "Already Received" : "Already Paid",
                          alreadyReceived,
                          Colors.green.shade700,
                        ),
                        const Divider(height: 20),
                        _summaryRow("Currently Pending", alreadyPending, Colors.orange.shade700),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // New Payment Input
                  Text(
                    isInvoice ? "New Payment Amount" : "New Payment Amount",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: receivedAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      hintText: "Enter payment amount",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      errorText: errorMessage.isNotEmpty ? errorMessage : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        receivedAmount = double.tryParse(value) ?? 0.0;

                        if (receivedAmount > alreadyPending) {
                          errorMessage = 'Cannot exceed pending ₹${AppUtil.formatCurrency(alreadyPending)}';
                          receivedAmount = alreadyPending;
                          receivedAmountController.text = alreadyPending.toStringAsFixed(0);
                        } else if (receivedAmount < 0) {
                          errorMessage = 'Amount must be positive';
                          receivedAmount = 0;
                        } else {
                          errorMessage = '';
                        }

                        pendingAmount = alreadyPending - receivedAmount;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  // After Payment Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isInvoice ? "New Received Total:" : "New Paid Total:",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "₹${AppUtil.formatCurrency(alreadyReceived + receivedAmount)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Remaining Pending:", style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              "₹${AppUtil.formatCurrency(pendingAmount)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: pendingAmount > 0 ? Colors.orange.shade700 : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("New Status:", style: TextStyle(fontWeight: FontWeight.w600)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(alreadyReceived + receivedAmount, totalAmount).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getPaymentStatus(alreadyReceived + receivedAmount, totalAmount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(alreadyReceived + receivedAmount, totalAmount),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notes Input
                  const Text("Add Notes", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Enter notes here...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ✅ Invoice/Purchase Selection
                  Text(
                    isInvoice ? "Select Related Invoices" : "Select Related Purchases",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  if (records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        isInvoice ? "No invoices available" : "No purchases available",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: records.map((record) {
                        // ✅ Handle both Invoice and PurchaseEntry types
                        String recordId;
                        double recordPending;

                        if (isInvoice) {
                          final invoice = record as Invoice;
                          recordId = 'INV-${invoice.invoiceId}';
                          recordPending = invoice.pendingAmount ?? invoice.totalAmount ?? 0.0;
                        } else {
                          final purchase = record as PurchaseEntry;
                          recordId = 'PUR-${purchase.purchaseId}';
                          recordPending = purchase.pendingAmount ?? purchase.totalAmount ?? 0.0;
                        }

                        final isSelected = selectedInvoiceIds.contains(recordId);
                        final isPaid = recordPending <= 0.01;
                        final isDisabled = isPaid;

                        return GestureDetector(
                          onTap: isDisabled
                              ? null
                              : () {
                            setState(() {
                              if (isSelected) {
                                selectedInvoiceIds.remove(recordId);
                              } else {
                                selectedInvoiceIds.add(recordId);
                              }
                            });
                          },
                          child: Opacity(
                            opacity: isDisabled ? 0.5 : 1.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDisabled
                                    ? Colors.grey.shade300
                                    : (isSelected ? AppColors.tealColor : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDisabled
                                      ? Colors.grey.shade400
                                      : (isSelected ? AppColors.tealColor : Colors.grey.shade400),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        recordId,
                                        style: TextStyle(
                                          color: isDisabled
                                              ? Colors.grey.shade600
                                              : (isSelected ? Colors.white : Colors.black),
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          decoration: isDisabled ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      if (isPaid) ...[
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.green.shade700,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (!isPaid)
                                    Text(
                                      "Pending: ₹${AppUtil.formatCurrency(recordPending)}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected ? Colors.white70 : Colors.orange.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  else
                                    Text(
                                      "PAID",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final enteredNote = noteController.text.trim();

                        if (selectedInvoiceIds.isEmpty) {
                          Get.snackbar(
                            "Select ${isInvoice ? 'Invoice' : 'Purchase'}",
                            "Please select at least one ${isInvoice ? 'invoice' : 'purchase'} ID.",
                            backgroundColor: Colors.red.shade50,
                            colorText: Colors.red.shade800,
                          );
                          return;
                        }

                        if (receivedAmount <= 0) {
                          Get.snackbar(
                            "Invalid Amount",
                            "Please enter a valid payment amount.",
                            backgroundColor: Colors.red.shade50,
                            colorText: Colors.red.shade800,
                          );
                          return;
                        }

                        Get.back(); // Close bottom sheet

                        Get.dialog(
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.tealColor,
                                    strokeWidth: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Saving payment...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          barrierDismissible: false,
                        );

                        // ✅ CALL THE CORRECT METHOD BASED ON TYPE
                        if (isInvoice) {
                          await _updateInvoiceStatuses(
                            selectedInvoiceIds.toList(),
                            receivedAmount,
                            totalAmount,
                          );
                        } else {
                          await _updatePurchaseStatuses(
                            selectedInvoiceIds.toList(),
                            receivedAmount,
                            totalAmount,
                          );
                        }

                        // ✅ REFRESH THE SCREEN DATA
                        final controller = Get.find<PaymentDetailsController>();
                        await controller.loadData();
                        Get.back(); // Close loading dialog

                        Get.snackbar(
                          "Success",
                          "Payment recorded successfully!",
                          backgroundColor: Colors.green.shade50,
                          colorText: Colors.green.shade800,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      label: const Text(
                        "Save Payment",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      isDismissible: true,
    );
  }

  static String _getPaymentStatus(double received, double total) {
    if (received >= total) return 'PAID';
    if (received > 0 && received < total) return 'PARTIAL';
    return 'PENDING';
  }

  static Color _getStatusColor(double received, double total) {
    if (received >= total) return Colors.green;
    if (received > 0 && received < total) return Colors.orange;
    return Colors.red;
  }

  static Future<void> _updateInvoiceStatuses(
      List<String> invoiceIds,
      double receivedAmount,
      double totalAmount,
      ) async {
    try {
      print("🔄 Updating statuses for ${invoiceIds.length} invoices...");

      final allInvoices = await GoogleSheetService.getInvoices(type: "INV");

      List<Invoice> selectedInvoices = [];
      for (String invoiceIdWithPrefix in invoiceIds) {
        final invoiceId = invoiceIdWithPrefix.replaceFirst(RegExp(r'(INV|PUR)-'), '');
        final invoice = allInvoices.firstWhereOrNull((inv) => inv.invoiceId == invoiceId);
        if (invoice != null) {
          selectedInvoices.add(invoice);
        }
      }

      if (selectedInvoices.isEmpty) {
        print("⚠️ No invoices found to update");
        return;
      }

      double remainingAmount = receivedAmount;

      for (final invoice in selectedInvoices) {
        if (remainingAmount <= 0) break;

        final invoiceTotal = invoice.totalAmount ?? 0.0;
        final invoicePending = invoice.pendingAmount ?? invoiceTotal;
        final invoiceReceived = invoice.receivedAmount ?? 0.0;

        final actualPayment = remainingAmount >= invoicePending ? invoicePending : remainingAmount;
        final newReceivedAmount = invoiceReceived + actualPayment;
        final newPendingAmount = invoiceTotal - newReceivedAmount;

        remainingAmount -= actualPayment;

        String newStatus;
        if (newPendingAmount <= 0.01) {
          newStatus = 'Paid';
        } else if (newReceivedAmount > 0) {
          newStatus = 'Partial';
        } else {
          newStatus = 'Pending';
        }

        final updatedInvoiceData = {
          'invoiceId': invoice.invoiceId,
          'customerId': invoice.customerId ?? '',
          'customerName': invoice.customerName ?? '',
          'customerEmail': invoice.customerEmail ?? '',
          'customerPan': invoice.customerPan ?? '',
          'customerGst': invoice.customerGst ?? '',
          'mobile': invoice.mobile ?? '',
          'customerAddress': invoice.customerAddress ?? '',
          'issueDate': invoice.issueDate?.toIso8601String() ?? '',
          'dueDate': invoice.dueDate?.toIso8601String() ?? '',
          'subtotal': (invoice.subtotal ?? 0.0).toString(),
          'gstAmount': (invoice.gstAmount ?? 0.0).toString(),
          'totalAmount': invoiceTotal.toString(),
          'receivedAmount': newReceivedAmount.toString(),
          'pendingAmount': newPendingAmount.toString(),
          'status': newStatus,
          'notes': invoice.notes ?? '',
        };

        await GoogleSheetService.updateInvoice(
          updatedInvoiceData,
          AppConstants.userId,
        );

        print("✅ Updated ${invoice.invoiceId}");
      }

      print("✅ All statuses updated successfully");
    } catch (e) {
      print("❌ Error: $e");
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        "Error",
        "Failed to update: $e",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    }
  }

  // Add this method to PaymentDetailsBottomSheet class
// This handles updating PURCHASE records (not invoices)

// ✅ FIXED: Replace your existing _updatePurchaseStatuses method with this corrected version

  static Future<void> _updatePurchaseStatuses(
      List<String> purchaseIds,
      double paidAmount,
      double totalAmount,
      ) async {
    try {
      print("🔄 Updating payment status for ${purchaseIds.length} purchases...");
      print("💰 Payment amount to distribute: ₹$paidAmount");

      final allPurchases = await GoogleSheetService.getPurchasesList();

      List<PurchaseEntry> selectedPurchases = [];
      for (String purchaseIdWithPrefix in purchaseIds) {
        final purchaseId = purchaseIdWithPrefix.replaceFirst('PUR-', '');
        final purchase = allPurchases.firstWhereOrNull((pur) => pur.purchaseId == purchaseId);
        if (purchase != null) {
          selectedPurchases.add(purchase);
          print("✅ Found purchase: ${purchase.purchaseId} - Pending: ₹${purchase.pendingAmount}");
        }
      }

      if (selectedPurchases.isEmpty) {
        print("⚠️ No purchases found to update");
        return;
      }

      print("✅ Found ${selectedPurchases.length} purchases to update");

      double remainingAmount = paidAmount;

      for (final purchase in selectedPurchases) {
        if (remainingAmount <= 0) {
          print("⚠️ No remaining amount for ${purchase.purchaseId}");
          break;
        }

        final purchaseTotal = purchase.totalAmount ?? 0.0;
        final purchasePending = purchase.pendingAmount ?? purchaseTotal;
        final purchasePaid = purchase.paidAmount ?? 0.0;

        print("\n📝 Processing Purchase ${purchase.purchaseId}:");
        print("   Total Amount: ₹$purchaseTotal");
        print("   Already Paid: ₹$purchasePaid");
        print("   Pending: ₹$purchasePending");
        print("   Available to pay: ₹$remainingAmount");

        // Calculate actual payment to apply
        final actualPayment = remainingAmount >= purchasePending ? purchasePending : remainingAmount;

        final newPaidAmount = purchasePaid + actualPayment;
        final newPendingAmount = purchaseTotal - newPaidAmount;

        remainingAmount -= actualPayment;

        // Determine new status
        String newStatus;
        if (newPendingAmount <= 0.01) {
          newStatus = 'Paid';
        } else if (newPaidAmount > 0) {
          newStatus = 'Partial';
        } else {
          newStatus = 'Pending';
        }

        print("   Payment Applied: ₹$actualPayment");
        print("   New Status: $newStatus");
        print("   New Paid Amount: ₹$newPaidAmount");
        print("   New Pending Amount: ₹$newPendingAmount");

        // ✅ CRITICAL FIX: Make sure ALL fields are included in the update
        final updatedPurchaseData = {
          'purchaseId': purchase.purchaseId,
          'vendorId': purchase.vendorId ?? '',
          'vendorName': purchase.vendorName ?? '',
          'vendorEmail': purchase.vendorEmail ?? '',
          'vendorMobile': purchase.vendorMobile ?? '',
          'vendorAddress': purchase.vendorAddress ?? '',
          'purchaseDate': purchase.purchaseDate?.toIso8601String() ?? '',
          'dueDate': purchase.dueDate?.toIso8601String() ?? '',
          'subtotal': (purchase.subtotal ?? 0.0).toString(),
          'gstRate': (purchase.gstRate ?? 0.0).toString(),
          'gstAmount': (purchase.gstAmount ?? 0.0).toString(),
          'totalAmount': purchaseTotal.toString(),
          'paidAmount': newPaidAmount.toString(),       // ✅ UPDATE THIS
          'pendingAmount': newPendingAmount.toString(), // ✅ UPDATE THIS
          'paymentStatus': newStatus,                   // ✅ UPDATE THIS
          'notes': purchase.notes ?? '',
          'userId': AppConstants.userId,                // ✅ IMPORTANT: Add userId
        };

        print("📤 Sending update to Google Sheets...");

        // Update the purchase record
        await GoogleSheetService.updatePurchase(
          updatedPurchaseData,
          AppConstants.userId,
        );

        print("✅ Successfully updated ${purchase.purchaseId}");
      }

      print("\n✅ All purchase statuses updated successfully");
      print("💰 Remaining amount not used: ₹$remainingAmount");

    } catch (e, stackTrace) {
      print("❌ Error updating purchase statuses: $e");
      print("Stack trace: $stackTrace");

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        "Error",
        "Failed to update purchase statuses: $e",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
    }
  }

// ✅ UPDATE the onPressed in Save Button to handle BOTH invoices and purchases
// Replace the existing onPressed in your Save Payment button with this:


  static Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _summaryRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          "₹${AppUtil.formatCurrency(amount)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
