import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../services/service.dart';
import '../../utils/utils.dart';
import '../../widgets/web_screen_wrapper.dart';
import 'dart:io';







class PaymentDetailsScreen extends GetView<PaymentDetailsController> {
  static const String pageId = '/PaymentDetailsScreen';
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        // Check if it's web layout (width > 900)
        bool isWeb = constraints.maxWidth > 900;

        return Scaffold(
          appBar: _buildAppBar(context, isWeb),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppColors.customeBackground,
            child: SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) return _buildLoadingShimmer();

                // ✅ Check both invoices and purchases
                bool hasData = controller.invoices.isNotEmpty || controller.purchases.isNotEmpty;
                if (!hasData) return _buildEmptyState();

                return Column(
                  children: [
                    _buildTabBar(),  // Tab selector
                    _buildSearchBar(),
                    Expanded(child: _buildTransactionTable()),
                  ],
                );
              }),
            ),
          ),
          floatingActionButton: _buildFAB(),
        );
      },
    );
    if (kIsWeb) return webScreenWrapper(currentRoute: pageId, child: content);
    return content;
  }

  AppBar _buildAppBar(BuildContext context, bool isWeb) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.appTheame,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          const Text(
            'Payment Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          if (isWeb) ...[
            const Spacer(),
            Obx(() => Text(
              controller.companyName.value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            )),
          ],
        ],
      ),
      centerTitle: !isWeb,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

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
          Expanded(child: _buildTabButton('Invoice', controller.selectedTab.value == 'Invoice', Icons.receipt_long)),
          const SizedBox(width: 8),
          Expanded(child: _buildTabButton('Purchase', controller.selectedTab.value == 'Purchase', Icons.shopping_cart)),
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
          color: isSelected ? AppColors.appTheame : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey.shade600),
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
          icon: Icon(Icons.search, color: AppColors.appTheame),
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

  Widget _buildTransactionTable() {
    return Obx(() {
      if (controller.selectedTab.value == 'Invoice') {
        return _buildInvoiceList();
      } else {
        return _buildPurchaseList();
      }
    });
  }

  // ✅ Updated: Invoice List with Payment Mode logic
  Widget _buildInvoiceList() {
    return Obx(() {
      final customerSummaries = controller.getFilteredInvoiceCustomerSummaries();

      if (customerSummaries.isEmpty) return _buildNoResultsFound();

      return RefreshIndicator(
        onRefresh: controller.loadData,
        color: AppColors.appTheame,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: customerSummaries.length,
          itemBuilder: (context, index) {
            final customer = customerSummaries[index];

            // 🔹 Get payment mode from first invoice
            String paymentMode = "";
            if (customer.invoiceIds.isNotEmpty) {
              final inv = controller.invoices.firstWhereOrNull((i) => i.invoiceId == customer.invoiceIds.first);
              paymentMode = inv?.paymentMode ?? "";
            }

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
              paymentMode: paymentMode, // ✅ Pass Mode
            );
          },
        ),
      );
    });
  }

  // ✅ Updated: Purchase List with Payment Mode logic
  Widget _buildPurchaseList() {
    return Obx(() {
      final vendorSummaries = controller.getFilteredPurchaseVendorSummaries();

      if (vendorSummaries.isEmpty) return _buildNoResultsFound();

      return RefreshIndicator(
        onRefresh: controller.loadData,
        color: AppColors.appTheame,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: vendorSummaries.length,
          itemBuilder: (context, index) {
            final vendor = vendorSummaries[index];

            // 🔹 Get payment mode from first purchase
            String paymentMode = "";
            if (vendor.purchaseIds.isNotEmpty) {
              final pur = controller.purchases.firstWhereOrNull((p) => p.purchaseId == vendor.purchaseIds.first);
              paymentMode = pur?.paymentMethod ?? "";
            }

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
              paymentMode: paymentMode, // ✅ Pass Mode
            );
          },
        ),
      );
    });
  }

  // ✅ Updated: Card UI shows Payment Mode Badge
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
    required String paymentMode, // ✅ New Parameter
  }) {
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
            isInvoice: isInvoice,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
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
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: transactionColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Meta Row
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(DateFormat('dd MMM').format(DateTime.now()), style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  const SizedBox(width: 16),
                  Icon(Icons.receipt_long, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text('$count $countLabel', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),

                  // ✅ Payment Mode Badge
                  if (paymentMode.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.payment, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        paymentMode,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ],
              ),
              const Divider(height: 24),
              // Amounts Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Amount', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text('₹${AppUtil.formatCurrency(totalAmount)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: transactionColor)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(isInvoice ? 'Received: ' : 'Paid: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          Text('₹${AppUtil.formatCurrency(receivedAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Pending: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          Text('₹${AppUtil.formatCurrency(pendingAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
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
          Text('No results found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Try searching with different keywords', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() => const Center(child: CircularProgressIndicator());

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text("No Transactions Found", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 8),
        Text("Your payment transactions will appear here", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ],
    ),
  );

  Widget _buildFAB() => FloatingActionButton(
    backgroundColor: AppColors.appTheame,
    onPressed: () => _generateReport(),
    child: const Icon(Icons.download, color: Colors.white),
  );

  void _generateReport() {
    if (Get.context == null) return;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text('Generate ${controller.selectedTab.value} Report', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87))),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              if (AppConstants.isDemo.value)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.orange.shade800),
                      const SizedBox(width: 10),
                      const Expanded(child: Text("Demo Mode: Reports limited to 1990-1992", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13))),
                    ],
                  ),
                ),
              const Text('Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: [
                  Expanded(child: _buildDateField('From Date', Icons.calendar_today, controller.getFormattedDate(controller.fromDate.value), () => _selectFromDate())),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDateField('To Date', Icons.calendar_today, controller.getFormattedDate(controller.toDate.value), () => _selectToDate())),
                ],
              )),
              const SizedBox(height: 20),
              const Text('Export Format', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: [
                  Expanded(child: _buildFormatChip('PDF', Icons.picture_as_pdf, controller.selectedExportFormat.value == 'PDF')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildFormatChip('Excel', Icons.table_chart, controller.selectedExportFormat.value == 'Excel')),
                ],
              )),
              const SizedBox(height: 30),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isGeneratingReport.value ? null : () => controller.generateReport(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.appTheame, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: controller.isGeneratingReport.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.download, color: Colors.white), SizedBox(width: 8), Text('Generate Report', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))]),
                ),
              )),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildFormatChip(String title, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () => controller.selectExportFormat(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appTheame.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.appTheame : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Column(children: [Icon(icon, size: 24, color: isSelected ? AppColors.appTheame : Colors.grey[700]), const SizedBox(height: 4), Text(title, style: TextStyle(color: isSelected ? AppColors.appTheame : Colors.grey[700], fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, fontSize: 12))]),
      ),
    );
  }

  Widget _buildDateField(String label, IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: Row(children: [Icon(icon, size: 18, color: AppColors.appTheame), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))]))]),
      ),
    );
  }

  void _selectFromDate() async {
    final bool isDemo = AppConstants.isDemo.value;
    final DateTime firstDate = isDemo ? DateTime(1990, 1, 1) : DateTime(2000);
    final DateTime lastDate = isDemo ? DateTime(1992, 12, 31) : DateTime.now();
    DateTime initialDate = controller.fromDate.value ?? DateTime.now();
    if (initialDate.isBefore(firstDate) || initialDate.isAfter(lastDate)) initialDate = isDemo ? DateTime(1990, 1, 1) : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: Get.context!, initialDate: initialDate, firstDate: firstDate, lastDate: lastDate,
      helpText: isDemo ? 'Select From Date (Demo: 1990-1992)' : 'Select From Date',
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppColors.appTheame, onPrimary: Colors.white)), child: child!),
    );
    if (picked != null) controller.setFromDate(picked);
  }

  void _selectToDate() async {
    final bool isDemo = AppConstants.isDemo.value;
    final DateTime startLimit = isDemo ? DateTime(1990, 1, 1) : DateTime(2000);
    final DateTime firstDate = controller.fromDate.value != null && controller.fromDate.value!.isAfter(startLimit) ? controller.fromDate.value! : startLimit;
    final DateTime lastDate = isDemo ? DateTime(1992, 12, 31) : DateTime.now();
    DateTime initialDate = controller.toDate.value ?? DateTime.now();
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final DateTime? picked = await showDatePicker(
      context: Get.context!, initialDate: initialDate, firstDate: firstDate, lastDate: lastDate,
      helpText: isDemo ? 'Select To Date (Demo: 1990-1992)' : 'Select To Date',
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppColors.appTheame, onPrimary: Colors.white)), child: child!),
    );
    if (picked != null) controller.setToDate(picked);
  }
}

class PaymentDetailsBottomSheet {
  static void show({
    required String customerName,
    required String paymentMethod,
    required String amount,
    required String date,
    required String notes,
    required List<String> invoiceIds,
    double? currentReceived,
    double? currentPending,
    required bool isInvoice,
  }) async {
    Get.dialog(Center(child: Container(padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
        child: CircularProgressIndicator(color: AppColors.appTheame))),
        barrierDismissible: false);

    final TextEditingController receivedAmountController = TextEditingController();
    final Set<String> selectedInvoiceIds = {};
    final double totalAmount = double.tryParse(amount.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
    final double alreadyReceived = currentReceived ?? 0.0;
    final double alreadyPending = currentPending ?? totalAmount;

    double receivedAmount = 0.0;
    double pendingAmount = alreadyPending;
    String errorMessage = '';

    // ✅ NEW Variable for Payment Mode Selection
    String selectedPaymentMode = 'Cash';

    List<dynamic> records = [];

    try {
      if (isInvoice) {
        final allInvoices = await GoogleSheetService.getInvoices(type: "INV");
        for (String id in invoiceIds) {
          final cleanId = id.replaceFirst('INV-', '');
          final invoice = allInvoices.firstWhereOrNull((inv) => inv.invoiceId == cleanId);
          if (invoice != null) records.add(invoice);
        }
      } else {
        final allPurchases = await GoogleSheetService.getPurchasesList();
        for (String id in invoiceIds) {
          final cleanId = id.replaceFirst('PUR-', '');
          final purchase = allPurchases.firstWhereOrNull((pur) => pur.purchaseId == cleanId);
          if (purchase != null) records.add(purchase);
        }
      }
    } catch (e) {
      print("Error loading data: $e");
    }

    if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(isInvoice ? "Payment Details" : "Purchase Payment", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context))]),
                    const SizedBox(height: 20),
                    _infoRow(isInvoice ? "Customer" : "Vendor", customerName),
                    _infoRow("Transaction Type", paymentMethod),
                    const Divider(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [
                        _summaryRow("Total Amount", totalAmount, Colors.blue.shade700),
                        const Divider(),
                        _summaryRow(isInvoice ? "Already Received" : "Already Paid", alreadyReceived, Colors.green.shade700),
                        const Divider(),
                        _summaryRow("Currently Pending", alreadyPending, Colors.orange.shade700),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // ✅ PAYMENT MODE SELECTION
                    const Text("Select Payment Mode", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildRadioBtn("Cash", selectedPaymentMode, (val) => setState(() => selectedPaymentMode = val)),
                        const SizedBox(width: 12),
                        _buildRadioBtn("UPI", selectedPaymentMode, (val) => setState(() => selectedPaymentMode = val)),
                        const SizedBox(width: 12),
                        _buildRadioBtn("Card", selectedPaymentMode, (val) => setState(() => selectedPaymentMode = val)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text("New Payment Amount", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: receivedAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(prefixText: "₹ ", hintText: "Enter amount", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), errorText: errorMessage.isNotEmpty ? errorMessage : null),
                      onChanged: (value) {
                        setState(() {
                          receivedAmount = double.tryParse(value) ?? 0.0;
                          if (receivedAmount > alreadyPending) {
                            errorMessage = 'Cannot exceed pending amount';
                            receivedAmount = alreadyPending;
                            receivedAmountController.text = alreadyPending.toStringAsFixed(2);
                          } else {
                            errorMessage = '';
                          }
                          pendingAmount = alreadyPending - receivedAmount;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(isInvoice ? "Select Related Invoices" : "Select Related Purchases", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: records.map((record) {
                        String recordId;
                        double recordPending;
                        if (isInvoice) {
                          final inv = record as Invoice;
                          recordId = 'INV-${inv.invoiceId}';
                          recordPending = inv.pendingAmount ?? inv.totalAmount ?? 0.0;
                        } else {
                          final pur = record as PurchaseEntry;
                          recordId = 'PUR-${pur.purchaseId}';
                          recordPending = pur.pendingAmount ?? pur.totalAmount ?? 0.0;
                        }
                        final isSelected = selectedInvoiceIds.contains(recordId);
                        final isPaid = recordPending <= 0.01;
                        return GestureDetector(
                          onTap: isPaid ? null : () => setState(() => isSelected ? selectedInvoiceIds.remove(recordId) : selectedInvoiceIds.add(recordId)),
                          child: Opacity(
                            opacity: isPaid ? 0.5 : 1.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: isSelected ? AppColors.appTheame : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                              child: Text("$recordId (${isPaid ? 'PAID' : 'Pending: ${recordPending.toStringAsFixed(2)}'})", style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.appTheame, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () async {
                          if (selectedInvoiceIds.isEmpty) { Get.snackbar("Error", "Select at least one record", backgroundColor: Colors.red.shade100); return; }
                          if (receivedAmount <= 0) { Get.snackbar("Error", "Enter valid amount", backgroundColor: Colors.red.shade100); return; }

                          Navigator.of(context).pop();
                          Get.dialog(Center(child: Card(child: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: AppColors.appTheame), SizedBox(height: 16), Text("Saving payment...")])))), barrierDismissible: false);

                          try {
                            if (isInvoice) {
                              await _updateInvoiceStatuses(selectedInvoiceIds.toList(), receivedAmount, totalAmount, selectedPaymentMode);
                            } else {
                              await _updatePurchaseStatuses(selectedInvoiceIds.toList(), receivedAmount, totalAmount, selectedPaymentMode);
                            }
                            if (Get.isRegistered<PaymentDetailsController>()) await Get.find<PaymentDetailsController>().loadData();
                            if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();
                            Get.snackbar("Success", "Payment saved successfully!", backgroundColor: Colors.green.shade100);
                          } catch (e) {
                            if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();
                            Get.snackbar("Error", "Failed to save: $e", backgroundColor: Colors.red.shade100);
                          }
                        },
                        label: const Text("Save Payment", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true, isDismissible: true,
    );
  }

  // ✅ Helper for Radio Buttons
  static Widget _buildRadioBtn(String label, String groupValue, Function(String) onChanged) {
    return InkWell(
      onTap: () => onChanged(label),
      child: Row(
        children: [
          Radio<String>(
            value: label,
            groupValue: groupValue,
            activeColor: AppColors.appTheame,
            visualDensity: VisualDensity.compact,
            onChanged: (val) => onChanged(val!),
          ),
          Text(label),
        ],
      ),
    );
  }

  static Future<void> _updateInvoiceStatuses(List<String> invoiceIds, double receivedAmount, double totalAmount, String paymentMode) async {
    final allInvoices = await GoogleSheetService.getInvoices(type: "INV");
    List<Invoice> selectedInvoices = [];
    for (String id in invoiceIds) {
      final cleanId = id.replaceFirst('INV-', '');
      final inv = allInvoices.firstWhereOrNull((i) => i.invoiceId == cleanId);
      if (inv != null) selectedInvoices.add(inv);
    }
    double remainingAmount = receivedAmount;
    for (final invoice in selectedInvoices) {
      if (remainingAmount <= 0) break;
      final total = invoice.totalAmount ?? 0.0;
      final pending = invoice.pendingAmount ?? total;
      final currentReceived = invoice.receivedAmount ?? 0.0;
      final payment = remainingAmount >= pending ? pending : remainingAmount;
      final newReceived = currentReceived + payment;
      final newPending = total - newReceived;
      remainingAmount -= payment;
      String status = newPending <= 0.01 ? 'Paid' : 'Partial';

      final now = DateTime.now();
      final updatedAtStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);

      final updateData = {
        'invoiceId': invoice.invoiceId,
        //'customerId': invoice.customerId ?? '',
        'receivedAmount': newReceived.toString(),
        'pendingAmount': newPending.toString(),
        'status': status,
        'paymentMode': paymentMode, // ✅ Save Mode
        'updatedAt': updatedAtStr, // ✅ So "Today's Collection" shows payment date
        //'userId': AppConstants.userId,
      };
      await GoogleSheetService.updateInvoice(updateData, AppConstants.userId);
    }
  }

  static Future<void> _updatePurchaseStatuses(List<String> purchaseIds, double paidAmount, double totalAmount, String paymentMode) async {
    final allPurchases = await GoogleSheetService.getPurchasesList();
    List<PurchaseEntry> selectedPurchases = [];
    for (String id in purchaseIds) {
      final cleanId = id.replaceFirst('PUR-', '');
      final pur = allPurchases.firstWhereOrNull((p) => p.purchaseId == cleanId);
      if (pur != null) selectedPurchases.add(pur);
    }
    double remainingAmount = paidAmount;
    for (final purchase in selectedPurchases) {
      if (remainingAmount <= 0) break;
      final total = purchase.totalAmount ?? 0.0;
      final pending = purchase.pendingAmount ?? total;
      final currentPaid = purchase.paidAmount ?? 0.0;
      final payment = remainingAmount >= pending ? pending : remainingAmount;
      final newPaid = currentPaid + payment;
      final newPending = total - newPaid;
      remainingAmount -= payment;
      String status = newPending <= 0.01 ? 'Paid' : 'Partial';

      final updateData = {
        'purchaseId': purchase.purchaseId,
        'vendorId': purchase.vendorId ?? '',
        'paidAmount': newPaid.toString(),
        'pendingAmount': newPending.toString(),
        'paymentStatus': status,
        'paymentMethod': paymentMode, // ✅ Save Mode (ensure Sheet column matches)
        'userId': AppConstants.userId,
      };
      await GoogleSheetService.updatePurchase(updateData, AppConstants.userId);
    }
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }

  static Widget _summaryRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), Text("₹${AppUtil.formatCurrency(amount)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15))]),
    );
  }
}

// class PaymentDetailsScreen extends GetView<PaymentDetailsController> {
//   static const String pageId = '/PaymentDetailsScreen';
//   const PaymentDetailsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Check if it's web layout (width > 900)
//         bool isWeb = constraints.maxWidth > 900;
//
//         return Scaffold(
//           backgroundColor: const Color(0xFFF8FAFD),
//           appBar: _buildAppBar(isWeb),
//           body: SafeArea(
//             child: Obx(() {
//               if (controller.isLoading.value) return _buildLoadingShimmer();
//
//               // ✅ Check both invoices and purchases
//               bool hasData = controller.invoices.isNotEmpty || controller.purchases.isNotEmpty;
//               if (!hasData) return _buildEmptyState();
//
//               return Column(
//                 children: [
//                   _buildTabBar(),  // ✅ NEW: Tab selector
//                   _buildSearchBar(),
//                   Expanded(child: _buildTransactionTable()),
//                 ],
//               );
//             }),
//           ),
//           floatingActionButton: _buildFAB(),
//         );
//       },
//     );
//   }
//
//   // ✅ UPDATED: AppBar with company name for web layout
//   AppBar _buildAppBar(bool isWeb) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: AppColors.appTheame,
//       foregroundColor: Colors.white,
//       title: Row(
//         children: [
//           // Left side: Title
//           Text(
//             'Payment Transactions',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//
//           // ✅ NEW: Add company name on right side for web layout
//           if (isWeb) ...[
//             Spacer(),
//             Obx(() {
//               // Get company name from Firebase/SharedPreferences
//               return Text(
//                 controller.companyName.value,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               );
//             }),
//           ],
//         ],
//       ),
//       centerTitle: !isWeb, // Center only on mobile
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back, color: Colors.white),
//         onPressed: () => Get.back(),
//       ),
//     );
//   }
//
//
//
//   // ✅ NEW: Tab Bar for Invoice/Purchase switch
//   Widget _buildTabBar() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Obx(() => Row(
//         children: [
//           Expanded(
//             child: _buildTabButton(
//               'Invoice',
//               controller.selectedTab.value == 'Invoice',
//               Icons.receipt_long,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _buildTabButton(
//               'Purchase',
//               controller.selectedTab.value == 'Purchase',
//               Icons.shopping_cart,
//             ),
//           ),
//         ],
//       )),
//     );
//   }
//
//   Widget _buildTabButton(String label, bool isSelected, IconData icon) {
//     return GestureDetector(
//       onTap: () => controller.switchTab(label),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.appTheame : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 18,
//               color: isSelected ? Colors.white : Colors.grey.shade600,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.grey.shade600,
//                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return Obx(() => Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: TextField(
//         onChanged: (value) => controller.updateSearchQuery(value),
//         decoration: InputDecoration(
//           hintText: controller.selectedTab.value == 'Invoice'
//               ? 'Search by customer name or invoice ID...'
//               : 'Search by vendor name or purchase ID...',
//           hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//           border: InputBorder.none,
//           icon: Icon(Icons.search, color: AppColors.appTheame),
//           suffixIcon: controller.searchQuery.value.isNotEmpty
//               ? IconButton(
//             icon: Icon(Icons.clear, color: Colors.grey.shade600),
//             onPressed: () => controller.updateSearchQuery(''),
//           )
//               : const SizedBox.shrink(),
//         ),
//       ),
//     ));
//   }
//
//   // ✅ UPDATED: Transaction table with both invoice and purchase views
//   Widget _buildTransactionTable() {
//     return Obx(() {
//       if (controller.selectedTab.value == 'Invoice') {
//         return _buildInvoiceList();
//       } else {
//         return _buildPurchaseList();
//       }
//     });
//   }
//
//   // ✅ Invoice List (existing logic)
//   Widget _buildInvoiceList() {
//     return Obx(() {
//       final customerSummaries = controller.getFilteredInvoiceCustomerSummaries();
//
//       if (customerSummaries.isEmpty) {
//         return _buildNoResultsFound();
//       }
//
//       return RefreshIndicator(
//         onRefresh: controller.loadData,
//         color: AppColors.appTheame,
//         child: ListView.builder(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
//           itemCount: customerSummaries.length,
//           itemBuilder: (context, index) {
//             final customer = customerSummaries[index];
//
//             return _buildTransactionCard(
//               title: customer.customerName,
//               transactionType: 'Receipt',
//               transactionColor: Colors.green,
//               count: customer.invoiceCount,
//               countLabel: 'Invoice',
//               totalAmount: customer.totalAmount,
//               receivedAmount: customer.receivedAmount,
//               pendingAmount: customer.pendingAmount,
//               ids: customer.invoiceIds,
//             );
//           },
//         ),
//       );
//     });
//   }
//
//   // ✅ NEW: Purchase List
//   Widget _buildPurchaseList() {
//     return Obx(() {
//       final vendorSummaries = controller.getFilteredPurchaseVendorSummaries();
//
//       if (vendorSummaries.isEmpty) {
//         return _buildNoResultsFound();
//       }
//
//       return RefreshIndicator(
//         onRefresh: controller.loadData,
//         color: AppColors.appTheame,
//         child: ListView.builder(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
//           itemCount: vendorSummaries.length,
//           itemBuilder: (context, index) {
//             final vendor = vendorSummaries[index];
//
//             return _buildTransactionCard(
//               title: vendor.vendorName,
//               transactionType: 'Payment',
//               transactionColor: Colors.orange,
//               count: vendor.purchaseCount,
//               countLabel: 'Purchase',
//               totalAmount: vendor.totalAmount,
//               receivedAmount: vendor.paidAmount,
//               pendingAmount: vendor.pendingAmount,
//               ids: vendor.purchaseIds,
//             );
//           },
//         ),
//       );
//     });
//   }
//
//   // ✅ Unified transaction card widget
//   Widget _buildTransactionCard({
//     required String title,
//     required String transactionType,
//     required Color transactionColor,
//     required int count,
//     required String countLabel,
//     required double totalAmount,
//     required double receivedAmount,
//     required double pendingAmount,
//     required List<String> ids,
//   }) {
//     // Determine if this is Invoice or Purchase based on transactionType
//     final isInvoice = transactionType == 'Receipt';
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: InkWell(
//         onTap: () {
//           PaymentDetailsBottomSheet.show(
//             customerName: title,
//             paymentMethod: transactionType,
//             amount: '₹${AppUtil.formatCurrency(totalAmount)}',
//             date: DateFormat('dd MMM yyyy').format(DateTime.now()),
//             notes: '',
//             invoiceIds: ids,
//             currentReceived: receivedAmount,
//             currentPending: pendingAmount,
//             isInvoice: isInvoice, // ✅ NEW: Pass transaction type
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: transactionColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       transactionType.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: transactionColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
//                   const SizedBox(width: 6),
//                   Text(
//                     DateFormat('dd MMM yyyy').format(DateTime.now()),
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Icon(Icons.receipt_long, size: 14, color: Colors.grey.shade600),
//                   const SizedBox(width: 6),
//                   Text(
//                     '$count ${countLabel}${count > 1 ? 's' : ''}',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//               const Divider(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Total Amount',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '₹${AppUtil.formatCurrency(totalAmount)}',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: transactionColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // ✅ DYNAMIC: Show "Received" for Invoice, "Paid" for Purchase
//                       Row(
//                         children: [
//                           Text(
//                             isInvoice ? 'Received: ' : 'Paid: ',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           Text(
//                             '₹${AppUtil.formatCurrency(receivedAmount)}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Text(
//                             'Pending: ',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           Text(
//                             '₹${AppUtil.formatCurrency(pendingAmount)}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoResultsFound() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           Text(
//             'No results found',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Try searching with different keywords',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLoadingShimmer() => const Center(
//     child: CircularProgressIndicator(),
//   );
//
//   Widget _buildEmptyState() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           Icons.receipt_long_outlined,
//           size: 80,
//           color: Colors.grey.shade300,
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           "No Transactions Found",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "Your payment transactions will appear here",
//           style: TextStyle(
//             color: Colors.grey.shade600,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _buildFAB() => FloatingActionButton(
//     backgroundColor: AppColors.appTheame,
//     onPressed: () => _generateReport(),
//     child: const Icon(Icons.download, color: Colors.white),
//   );
//
//   // Generate report dialog (same as before, but now works for both tabs)
//   void _generateReport() {
//     // Ensure context is available
//     if (Get.context == null) {
//       Get.snackbar(
//         'Error',
//         'Unable to open report generator',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//       );
//       return;
//     }
//
//     // Show the bottom sheet
//     Get.bottomSheet(
//       Container(
//         height: MediaQuery.of(Get.context!).size.height * 0.6,
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Obx(() => Text(
//                     'Generate ${controller.selectedTab.value} Report',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black87,
//                     ),
//                   )),
//                   IconButton(
//                     onPressed: () => Get.back(),
//                     icon: const Icon(Icons.close, color: Colors.grey),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               if (AppConstants.isDemo.value)
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.orange.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.info_outline, size: 20, color: Colors.orange.shade800),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           "Demo Mode: Reports limited to 1990-1992",
//                           style: TextStyle(
//                             color: Colors.orange.shade900,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//               const Text(
//                 'Date Range',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Obx(() => Row(
//                 children: [
//                   Expanded(
//                     child: _buildDateField(
//                       'From Date',
//                       Icons.calendar_today,
//                       controller.getFormattedDate(controller.fromDate.value),
//                           () => _selectFromDate(),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _buildDateField(
//                       'To Date',
//                       Icons.calendar_today,
//                       controller.getFormattedDate(controller.toDate.value),
//                           () => _selectToDate(),
//                     ),
//                   ),
//                 ],
//               )),
//
//               const SizedBox(height: 20),
//
//               const Text(
//                 'Export Format',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Obx(() => Row(
//                 children: [
//                   Expanded(
//                     child: _buildFormatChip(
//                       'PDF',
//                       Icons.picture_as_pdf,
//                       controller.selectedExportFormat.value == 'PDF',
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _buildFormatChip(
//                       'Excel',
//                       Icons.table_chart,
//                       controller.selectedExportFormat.value == 'Excel',
//                     ),
//                   ),
//                 ],
//               )),
//
//               const SizedBox(height: 30),
//
//               Obx(() => SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: controller.isGeneratingReport.value
//                       ? null
//                       : () => controller.generateReport(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.appTheame,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     disabledBackgroundColor: Colors.grey.shade300,
//                   ),
//                   child: controller.isGeneratingReport.value
//                       ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                       : const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.download, color: Colors.white),
//                       SizedBox(width: 8),
//                       Text(
//                         'Generate Report',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )),
//             ],
//           ),
//         ),
//       ),
//       isDismissible: true,
//       enableDrag: true,
//     ); // ✅ Make sure this closing parenthesis is here
//   }
//
//   Widget _buildFormatChip(String title, IconData icon, bool isSelected) {
//     return InkWell(
//       onTap: () => controller.selectExportFormat(title),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.appTheame.withOpacity(0.15)
//               : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.appTheame : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 24,
//               color: isSelected ? AppColors.appTheame : Colors.grey[700],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: TextStyle(
//                 color: isSelected ? AppColors.appTheame : Colors.grey[700],
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDateField(String label, IconData icon, String value, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.white,
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 18, color: AppColors.appTheame),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _selectFromDate() async {
//     final bool isDemo = AppConstants.isDemo.value;
//
//     // Define constraints
//     final DateTime firstDate = isDemo ? DateTime(1990, 1, 1) : DateTime(2000);
//     final DateTime lastDate = isDemo ? DateTime(1992, 12, 31) : DateTime.now();
//
//     // Ensure initial date is valid
//     DateTime initialDate = controller.fromDate.value ?? DateTime.now();
//     if (initialDate.isBefore(firstDate) || initialDate.isAfter(lastDate)) {
//       initialDate = isDemo ? DateTime(1990, 1, 1) : DateTime.now();
//     }
//
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//       helpText: isDemo ? 'Select From Date (Demo: 1990-1992)' : 'Select From Date',
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.appTheame,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       controller.setFromDate(picked);
//     }
//   }
//
//   void _selectToDate() async {
//     final bool isDemo = AppConstants.isDemo.value;
//
//     // Define constraints
//     // For 'firstDate', we usually want it to be at least the 'fromDate'
//     // But in demo mode, hard constraint to 1990 is safer
//     final DateTime startLimit = isDemo ? DateTime(1990, 1, 1) : DateTime(2000);
//
//     final DateTime firstDate = controller.fromDate.value != null && controller.fromDate.value!.isAfter(startLimit)
//         ? controller.fromDate.value!
//         : startLimit;
//
//     final DateTime lastDate = isDemo ? DateTime(1992, 12, 31) : DateTime.now();
//
//     // Ensure initial date is valid
//     DateTime initialDate = controller.toDate.value ?? DateTime.now();
//     if (initialDate.isBefore(firstDate)) initialDate = firstDate;
//     if (initialDate.isAfter(lastDate)) initialDate = lastDate;
//
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//       helpText: isDemo ? 'Select To Date (Demo: 1990-1992)' : 'Select To Date',
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.appTheame,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       controller.setToDate(picked);
//     }
//   }
// }
//
//
// class PaymentDetailsBottomSheet {
//   static void show({
//     required String customerName,
//     required String paymentMethod,
//     required String amount,
//     required String date,
//     required String notes,
//     required List<String> invoiceIds,
//     double? currentReceived,
//     double? currentPending,
//     required bool isInvoice,
//   }) async {
//     // 1. Show Loading Dialog for Data Fetching
//     Get.dialog(
//        Center(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
//           child: CircularProgressIndicator(color: AppColors.appTheame),
//         ),
//       ),
//       barrierDismissible: false,
//     );
//
//     final TextEditingController noteController = TextEditingController(text: notes);
//     final TextEditingController receivedAmountController = TextEditingController();
//     final Set<String> selectedInvoiceIds = {};
//
//     final double totalAmount = double.tryParse(amount.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
//     final double alreadyReceived = currentReceived ?? 0.0;
//     final double alreadyPending = currentPending ?? totalAmount;
//
//     double receivedAmount = 0.0;
//     double pendingAmount = alreadyPending;
//     String errorMessage = '';
//
//     List<dynamic> records = [];
//
//     try {
//       if (isInvoice) {
//         final allInvoices = await GoogleSheetService.getInvoices(type: "INV");
//         for (String invoiceIdWithPrefix in invoiceIds) {
//           final invoiceId = invoiceIdWithPrefix.replaceFirst('INV-', '');
//           final invoice = allInvoices.firstWhereOrNull((inv) => inv.invoiceId == invoiceId);
//           if (invoice != null) records.add(invoice);
//         }
//       } else {
//         final allPurchases = await GoogleSheetService.getPurchasesList();
//         for (String purchaseIdWithPrefix in invoiceIds) {
//           final purchaseId = purchaseIdWithPrefix.replaceFirst('PUR-', '');
//           final purchase = allPurchases.firstWhereOrNull((pur) => pur.purchaseId == purchaseId);
//           if (purchase != null) records.add(purchase);
//         }
//       }
//     } catch (e) {
//       print("Error loading data: $e");
//     }
//
//     // 2. Close Loading Dialog (Using Navigator to be safe)
//     if (Get.isDialogOpen == true) {
//       Navigator.of(Get.overlayContext!).pop();
//     }
//
//     // 3. Show Bottom Sheet
//     Get.bottomSheet(
//       StatefulBuilder(
//         builder: (context, setState) {
//           return SafeArea(
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(isInvoice ? "Payment Details" : "Purchase Payment", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                         IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     _infoRow(isInvoice ? "Customer" : "Vendor", customerName),
//                     _infoRow("Payment Method", paymentMethod),
//                     const Divider(height: 30),
//
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
//                       child: Column(
//                         children: [
//                           _summaryRow("Total Amount", totalAmount, Colors.blue.shade700),
//                           const Divider(),
//                           _summaryRow(isInvoice ? "Already Received" : "Already Paid", alreadyReceived, Colors.green.shade700),
//                           const Divider(),
//                           _summaryRow("Currently Pending", alreadyPending, Colors.orange.shade700),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//
//                     Text("New Payment Amount", style: const TextStyle(fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: receivedAmountController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         prefixText: "₹ ",
//                         hintText: "Enter amount",
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         errorText: errorMessage.isNotEmpty ? errorMessage : null,
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           receivedAmount = double.tryParse(value) ?? 0.0;
//                           if (receivedAmount > alreadyPending) {
//                             errorMessage = 'Cannot exceed pending amount';
//                             receivedAmount = alreadyPending;
//                             receivedAmountController.text = alreadyPending.toStringAsFixed(2);
//                           } else {
//                             errorMessage = '';
//                           }
//                           pendingAmount = alreadyPending - receivedAmount;
//                         });
//                       },
//                     ),
//
//                     const SizedBox(height: 20),
//                     Text(isInvoice ? "Select Related Invoices" : "Select Related Purchases", style: const TextStyle(fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: records.map((record) {
//                         String recordId;
//                         double recordPending;
//                         if (isInvoice) {
//                           final inv = record as Invoice;
//                           recordId = 'INV-${inv.invoiceId}';
//                           recordPending = inv.pendingAmount ?? inv.totalAmount ?? 0.0;
//                         } else {
//                           final pur = record as PurchaseEntry;
//                           recordId = 'PUR-${pur.purchaseId}';
//                           recordPending = pur.pendingAmount ?? pur.totalAmount ?? 0.0;
//                         }
//
//                         final isSelected = selectedInvoiceIds.contains(recordId);
//                         final isPaid = recordPending <= 0.01;
//
//                         return GestureDetector(
//                           onTap: isPaid ? null : () {
//                             setState(() {
//                               isSelected ? selectedInvoiceIds.remove(recordId) : selectedInvoiceIds.add(recordId);
//                             });
//                           },
//                           child: Opacity(
//                             opacity: isPaid ? 0.5 : 1.0,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                               decoration: BoxDecoration(
//                                 color: isSelected ? AppColors.appTheame : Colors.grey.shade200,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 "$recordId (${isPaid ? 'PAID' : 'Pending: ${recordPending.toStringAsFixed(0)}'})",
//                                 style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // =========================================================
//                     // ✅ FIXED SAVE BUTTON LOGIC (Native Navigation)
//                     // =========================================================
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.save, color: Colors.white),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.appTheame,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                         onPressed: () async {
//                           // Validation
//                           if (selectedInvoiceIds.isEmpty) {
//                             Get.snackbar("Error", "Please select at least one record", backgroundColor: Colors.red.shade100, colorText: Colors.red[900]);
//                             return;
//                           }
//                           if (receivedAmount <= 0) {
//                             Get.snackbar("Error", "Enter valid amount", backgroundColor: Colors.red.shade100, colorText: Colors.red[900]);
//                             return;
//                           }
//
//                           // 1. Close the Bottom Sheet (Use native pop to avoid GetX conflicts)
//                           Navigator.of(context).pop();
//
//                           // 2. Open "Saving..." Dialog (Non-dismissible)
//                           Get.dialog(
//                             Center(
//                               child: Card(
//                                 child: Padding(
//                                   padding: EdgeInsets.all(20),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       CircularProgressIndicator(color: AppColors.appTheame),
//                                       SizedBox(height: 16),
//                                       Text("Saving payment..."),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             barrierDismissible: false,
//                           );
//
//                           try {
//                             // 3. Perform Async Operations
//                             if (isInvoice) {
//                               await _updateInvoiceStatuses(selectedInvoiceIds.toList(), receivedAmount, totalAmount);
//                             } else {
//                               await _updatePurchaseStatuses(selectedInvoiceIds.toList(), receivedAmount, totalAmount);
//                             }
//
//                             // 4. Refresh Data
//                             if (Get.isRegistered<PaymentDetailsController>()) {
//                               await Get.find<PaymentDetailsController>().loadData();
//                             }
//
//                             // 5. Close Saving Dialog (CRITICAL FIX: Use Native Pop)
//                             if (Get.isDialogOpen == true) {
//                               Navigator.of(Get.overlayContext!).pop();
//                             }
//
//                             Get.snackbar(
//                               "Success",
//                               "Payment saved successfully!",
//                               backgroundColor: Colors.green.shade100,
//                               colorText: Colors.green[900],
//                               duration: const Duration(seconds: 2),
//                             );
//
//                           } catch (e) {
//                             // 6. Close Saving Dialog on Error (CRITICAL FIX: Use Native Pop)
//                             if (Get.isDialogOpen == true) {
//                               Navigator.of(Get.overlayContext!).pop();
//                             }
//
//                             print("Error saving: $e");
//                             Get.snackbar("Error", "Failed to save: $e", backgroundColor: Colors.red.shade100, colorText: Colors.red[900]);
//                           }
//                         },
//                         label: const Text("Save Payment", style: TextStyle(color: Colors.white, fontSize: 16)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//       isScrollControlled: true,
//       isDismissible: true,
//     );
//   }
//
//   // ===========================================================================
//   // ✅ HELPERS (No Changes Needed Here)
//   // ===========================================================================
//
//   static Future<void> _updateInvoiceStatuses(List<String> invoiceIds, double receivedAmount, double totalAmount) async {
//     final allInvoices = await GoogleSheetService.getInvoices(type: "INV");
//     List<Invoice> selectedInvoices = [];
//
//     for (String id in invoiceIds) {
//       final cleanId = id.replaceFirst('INV-', '');
//       final inv = allInvoices.firstWhereOrNull((i) => i.invoiceId == cleanId);
//       if (inv != null) selectedInvoices.add(inv);
//     }
//
//     double remainingAmount = receivedAmount;
//
//     for (final invoice in selectedInvoices) {
//       if (remainingAmount <= 0) break;
//
//       final total = invoice.totalAmount ?? 0.0;
//       final pending = invoice.pendingAmount ?? total;
//       final currentReceived = invoice.receivedAmount ?? 0.0;
//
//       final payment = remainingAmount >= pending ? pending : remainingAmount;
//       final newReceived = currentReceived + payment;
//       final newPending = total - newReceived;
//
//       remainingAmount -= payment;
//
//       String status = newPending <= 0.01 ? 'Paid' : (newReceived > 0 ? 'Partial' : 'Pending');
//
//       final updateData = {
//         'invoiceId': invoice.invoiceId,
//         'customerId': invoice.customerId ?? '',
//         'customerName': invoice.customerName ?? '',
//         'customerEmail': invoice.customerEmail ?? '',
//         'customerPan': invoice.customerPan ?? '',
//         'customerGst': invoice.customerGst ?? '',
//         'mobile': invoice.mobile ?? '',
//         'customerAddress': invoice.customerAddress ?? '',
//         'issueDate': invoice.issueDate?.toIso8601String() ?? '',
//         'dueDate': invoice.dueDate?.toIso8601String() ?? '',
//         'subtotal': (invoice.subtotal ?? 0.0).toString(),
//         'gstAmount': (invoice.gstAmount ?? 0.0).toString(),
//         'totalAmount': total.toString(),
//         'receivedAmount': newReceived.toString(),
//         'pendingAmount': newPending.toString(),
//         'status': status,
//         'notes': invoice.notes ?? '',
//       };
//
//       await GoogleSheetService.updateInvoice(updateData, AppConstants.userId);
//     }
//   }
//
//   static Future<void> _updatePurchaseStatuses(List<String> purchaseIds, double paidAmount, double totalAmount) async {
//     final allPurchases = await GoogleSheetService.getPurchasesList();
//     List<PurchaseEntry> selectedPurchases = [];
//
//     for (String id in purchaseIds) {
//       final cleanId = id.replaceFirst('PUR-', '');
//       final pur = allPurchases.firstWhereOrNull((p) => p.purchaseId == cleanId);
//       if (pur != null) selectedPurchases.add(pur);
//     }
//
//     double remainingAmount = paidAmount;
//
//     for (final purchase in selectedPurchases) {
//       if (remainingAmount <= 0) break;
//
//       final total = purchase.totalAmount ?? 0.0;
//       final pending = purchase.pendingAmount ?? total;
//       final currentPaid = purchase.paidAmount ?? 0.0;
//
//       final payment = remainingAmount >= pending ? pending : remainingAmount;
//       final newPaid = currentPaid + payment;
//       final newPending = total - newPaid;
//
//       remainingAmount -= payment;
//
//       String status = newPending <= 0.01 ? 'Paid' : (newPaid > 0 ? 'Partial' : 'Pending');
//
//       final updateData = {
//         'purchaseId': purchase.purchaseId,
//         'vendorId': purchase.vendorId ?? '',
//         'vendorName': purchase.vendorName ?? '',
//         'vendorEmail': purchase.vendorEmail ?? '',
//         'vendorMobile': purchase.vendorMobile ?? '',
//         'vendorAddress': purchase.vendorAddress ?? '',
//         'purchaseDate': purchase.purchaseDate?.toIso8601String() ?? '',
//         'dueDate': purchase.dueDate?.toIso8601String() ?? '',
//         'subtotal': (purchase.subtotal ?? 0.0).toString(),
//         'gstRate': (purchase.gstRate ?? 0.0).toString(),
//         'gstAmount': (purchase.gstAmount ?? 0.0).toString(),
//         'totalAmount': total.toString(),
//         'paidAmount': newPaid.toString(),
//         'pendingAmount': newPending.toString(),
//         'paymentStatus': status,
//         'notes': purchase.notes ?? '',
//         'userId': AppConstants.userId,
//       };
//
//       await GoogleSheetService.updatePurchase(updateData, AppConstants.userId);
//     }
//   }
//
//   // --- Visual Helpers ---
//   static Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   static Widget _summaryRow(String label, double amount, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//           Text("₹${AppUtil.formatCurrency(amount)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
//         ],
//       ),
//     );
//   }
//
//   static String _getPaymentStatus(double received, double total) {
//     if (received >= total) return 'PAID';
//     if (received > 0) return 'PARTIAL';
//     return 'PENDING';
//   }
//
//   static Color _getStatusColor(double received, double total) {
//     if (received >= total) return Colors.green;
//     if (received > 0) return Colors.orange;
//     return Colors.red;
//   }
// }



