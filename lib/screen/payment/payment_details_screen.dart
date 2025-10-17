
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';


// class PaymentDetailsScreen extends GetView<PaymentDetailsController> {
//   static const String pageId = '/PaymentDetailsScreen';
//   const PaymentDetailsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFD),
//       appBar: _buildAppBar(),
//       body: SafeArea(
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return _buildLoadingShimmer();
//           }
//
//           if (controller.invoices.isEmpty) {
//             return _buildEmptyState();
//           }
//
//           return Column(
//             children: [
//               _buildSummaryCards(),
//               Expanded(child: _buildInvoiceList()),
//             ],
//           );
//         }),
//       ),
//       floatingActionButton: _buildFAB(),
//     );
//   }
//
//   // 🔹 APPBAR
//   AppBar _buildAppBar() => AppBar(
//     title: const Text(
//       'Payment',
//       style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
//     ),
//     backgroundColor: AppColors.tealColor,
//     foregroundColor: Colors.white,
//     elevation: 0,
//
//   );
//
//   // 🔹 SUMMARY CARDS
//   Widget _buildSummaryCards() => Container(
//     margin: const EdgeInsets.all(16),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.tealColor.withOpacity(0.1),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _summaryItem("Invoices", controller.invoices.length.toString(),
//             Icons.receipt_long, AppColors.tealColor),
//         _summaryItem("Total", "₹${_totalAmount().toStringAsFixed(2)}",
//             Icons.currency_rupee, Colors.green),
//         _summaryItem("Pending", "₹${_pendingAmount().toStringAsFixed(2)}",
//             Icons.pending_actions, Colors.orange),
//       ],
//     ),
//   );
//
//   Widget _summaryItem(
//       String title, String value, IconData icon, Color color) =>
//       Column(
//         children: [
//           CircleAvatar(
//             backgroundColor: color.withOpacity(0.1),
//             radius: 18,
//             child: Icon(icon, color: color, size: 18),
//           ),
//           const SizedBox(height: 6),
//           Text(value,
//               style: TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.bold, color: color)),
//           Text(title,
//               style: const TextStyle(
//                   fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))
//         ],
//       );
//
//   // 🔹 INVOICE LIST
//   Widget _buildInvoiceList() => RefreshIndicator(
//     onRefresh: controller.loadInvoices,
//     color: AppColors.tealColor,
//     child: ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: controller.invoices.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (context, index) =>
//           _invoiceCard(controller.invoices[index], index),
//     ),
//   );
//
//   Widget _invoiceCard(Invoice inv, int index) {
//     final statusColor = controller.getStatusColor(inv.status);
//     final isPending = (inv.pendingAmount ?? 0.0) > 0;
//     final paidPercentage =
//         (inv.receivedAmount ?? 0.0) / ((inv.totalAmount ?? 1.0));
//
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 250 + (index * 80)),
//       curve: Curves.easeInOut,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.tealColor.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(18),
//           onTap: () => _showInvoiceDetails(inv),
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("INV-${inv.invoiceId ?? 'N/A'}",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15,
//                                   color: AppColors.tealColor)),
//                           Text(inv.customerName ?? 'Unknown Customer',
//                               style: const TextStyle(
//                                   color: Colors.grey, fontSize: 13)),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(inv.status?.toUpperCase() ?? 'UNKNOWN',
//                           style: TextStyle(
//                               color: statusColor,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600)),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 // Amounts
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _amountText("Total", inv.totalAmount, AppColors.tealColor),
//                     _amountText("Received", inv.receivedAmount, Colors.green),
//                     _amountText("Pending", inv.pendingAmount,
//                         isPending ? Colors.orange : Colors.green),
//                   ],
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 // Progress bar
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: LinearProgressIndicator(
//                     value: paidPercentage,
//                     backgroundColor: Colors.grey.shade200,
//                     color: isPending ? Colors.orange : Colors.green,
//                     minHeight: 5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _amountText(String label, double? amount, Color color) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label,
//           style: const TextStyle(fontSize: 11, color: Colors.grey)),
//       Text("₹${amount?.toStringAsFixed(2) ?? '0.00'}",
//           style: TextStyle(
//               fontSize: 14, fontWeight: FontWeight.w700, color: color)),
//     ],
//   );
//
//   // 🔹 SHIMMER / LOADING
//   Widget _buildLoadingShimmer() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CircularProgressIndicator(color: AppColors.tealColor),
//         const SizedBox(height: 12),
//         const Text('Loading invoices...',
//             style: TextStyle(color: Colors.grey, fontSize: 14))
//       ],
//     ),
//   );
//
//   // 🔹 EMPTY STATE
//   Widget _buildEmptyState() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.receipt_long_outlined,
//             size: 80, color: Colors.grey.shade400),
//         const SizedBox(height: 10),
//         const Text("No Invoices Found",
//             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
//         const Text("Your invoices will appear here soon",
//             style: TextStyle(color: Colors.grey)),
//       ],
//     ),
//   );
//
//   // 🔹 FAB
//   Widget _buildFAB() => FloatingActionButton(
//     backgroundColor: AppColors.tealColor,
//     onPressed: _generateReport,
//     child: const Icon(Icons.analytics, color: Colors.white),
//   );
//
//   // 🔹 Helpers
//   double _totalAmount() => controller.invoices.fold(
//       0.0, (sum, i) => sum + (i.totalAmount ?? 0.0));
//
//   double _pendingAmount() => controller.invoices.fold(
//       0.0, (sum, i) => sum + (i.pendingAmount ?? 0.0));
//
//
//   void _showInvoiceDetails(Invoice inv) {
//     Get.defaultDialog(
//       title: "Invoice Details",
//       middleText:
//       "Invoice: ${inv.invoiceId}\nCustomer: ${inv.customerName}\nTotal: ₹${inv.totalAmount}\nPending: ₹${inv.pendingAmount}\nStatus: ${inv.status}",
//       textConfirm: "Close",
//       confirmTextColor: Colors.white,
//       buttonColor: AppColors.tealColor,
//       onConfirm: Get.back,
//     );
//   }
//
//   void _generateReport() {
//     Get.bottomSheet(
//       Container(
//         height: MediaQuery.of(Get.context!).size.height * 0.75,
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
//               // Header with close button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Generate Report',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Get.back(),
//                     icon: const Icon(Icons.close, color: Colors.grey),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//
//               // Report Type Selection
//               const Text(
//                 'Report Type',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Obx(() => Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: [
//                   _buildReportTypeChip(
//                     'Summary Report',
//                     Icons.summarize,
//                     controller.selectedReportType.value == 'Summary Report',
//                   ),
//                   _buildReportTypeChip(
//                     'Detailed Report',
//                     Icons.list_alt,
//                     controller.selectedReportType.value == 'Detailed Report',
//                   ),
//                   _buildReportTypeChip(
//                     'Payment Report',
//                     Icons.payment,
//                     controller.selectedReportType.value == 'Payment Report',
//                   ),
//                 ],
//               )),
//
//               const SizedBox(height: 20),
//
//               // Date Range
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
//               // Preview Statistics
//               Obx(() {
//                 final filteredInvoices = controller.getFilteredInvoices();
//                 final totalAmount = filteredInvoices.fold(0.0,
//                         (sum, inv) => sum + (inv.totalAmount ?? 0.0));
//
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppColors.tealColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Report Preview',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Invoices: ${filteredInvoices.length}',
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 13,
//                             ),
//                           ),
//                           Text(
//                             'Total: ₹${totalAmount.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//
//               const SizedBox(height: 20),
//
//               // Format Selection
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
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _buildFormatChip(
//                       'CSV',
//                       Icons.grid_on,
//                       controller.selectedExportFormat.value == 'CSV',
//                     ),
//                   ),
//                 ],
//               )),
//
//               const SizedBox(height: 30),
//
//               // Generate Button
//               Obx(() => Container(
//                 width: double.infinity,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.tealColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.tealColor.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ElevatedButton(
//                   onPressed: controller.isGeneratingReport.value
//                       ? null
//                       : () => controller.generateReport(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
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
//                       Icon(Icons.analytics, color: Colors.white),
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
//     );
//   }
//
//   Widget _buildReportTypeChip(String title, IconData icon, bool isSelected) {
//     return InkWell(
//       onTap: () => controller.selectReportType(title),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.tealColor.withOpacity(0.15)
//               : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.tealColor : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 18,
//               color: isSelected ? AppColors.tealColor : Colors.grey[700],
//             ),
//             const SizedBox(width: 6),
//             Text(
//               title,
//               style: TextStyle(
//                 color: isSelected ? AppColors.tealColor : Colors.grey[700],
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFormatChip(String title, IconData icon, bool isSelected) {
//     return InkWell(
//       onTap: () => controller.selectExportFormat(title),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.tealColor.withOpacity(0.15)
//               : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.tealColor : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 24,
//               color: isSelected ? AppColors.tealColor : Colors.grey[700],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: TextStyle(
//                 color: isSelected ? AppColors.tealColor : Colors.grey[700],
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
//             Icon(icon, size: 18, color: AppColors.tealColor),
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
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: controller.fromDate.value ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.tealColor,
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
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: controller.toDate.value ?? DateTime.now(),
//       firstDate: controller.fromDate.value ?? DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.tealColor,
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
          if (controller.isLoading.value) {
            return _buildLoadingShimmer();
          }

          if (controller.invoices.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSummaryCards(),
              Expanded(child: _buildCustomerList()),
            ],
          );
        }),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // 🔹 APPBAR
  AppBar _buildAppBar() => AppBar(
    title: const Text(
      'Payment - Customer View',
      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
    ),
    backgroundColor: AppColors.tealColor,
    foregroundColor: Colors.white,
    elevation: 0,
  );

  // 🔹 SUMMARY CARDS - Updated to show Customers
  Widget _buildSummaryCards() {
    final customerSummaries = CustomerDataGrouper.groupByCustomer(controller.invoices);
    final totalAmount = customerSummaries.fold(0.0, (sum, c) => sum + c.totalAmount);
    final pendingAmount = customerSummaries.fold(0.0, (sum, c) => sum + c.pendingAmount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
              "Customers",
              customerSummaries.length.toString(),
              Icons.people,
              AppColors.tealColor
          ),
          _summaryItem(
              "Total",
              "₹${totalAmount.toStringAsFixed(2)}",
              Icons.currency_rupee,
              Colors.green
          ),
          _summaryItem(
              "Pending",
              "₹${pendingAmount.toStringAsFixed(2)}",
              Icons.pending_actions,
              Colors.orange
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value, IconData icon, Color color) =>
      Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      );

  // 🔹 CUSTOMER LIST - Grouped by Customer
  Widget _buildCustomerList() {
    final customerSummaries = CustomerDataGrouper.groupByCustomer(controller.invoices);

    return RefreshIndicator(
      onRefresh: controller.loadInvoices,
      color: AppColors.tealColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: customerSummaries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) =>
            _customerCard(customerSummaries[index], index),
      ),
    );
  }

  Widget _customerCard(CustomerSummary customer, int index) {
    final statusColor = controller.getStatusColor(customer.overallStatus);
    final isPending = customer.pendingAmount > 0;
    final paidPercentage = customer.paymentPercentage / 100;

    return AnimatedContainer(
      duration: Duration(milliseconds: 250 + (index * 80)),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.tealColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showCustomerDetails(customer),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: AppColors.tealColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  customer.customerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.tealColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.receipt, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${customer.invoiceCount} Invoice${customer.invoiceCount > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.list_alt, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.invoiceIds.take(2).join(', ') +
                                      (customer.invoiceIds.length > 2 ? '...' : ''),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        customer.overallStatus.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Amounts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _amountText("Total", customer.totalAmount, AppColors.tealColor),
                    _amountText("Received", customer.receivedAmount, Colors.green),
                    _amountText(
                      "Pending",
                      customer.pendingAmount,
                      isPending ? Colors.orange : Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Progress bar with percentage
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: paidPercentage,
                          backgroundColor: Colors.grey.shade200,
                          color: isPending ? Colors.orange : Colors.green,
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${customer.paymentPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPending ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _amountText(String label, double? amount, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      Text(
        "₹${amount?.toStringAsFixed(2) ?? '0.00'}",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ],
  );

  // 🔹 SHIMMER / LOADING
  Widget _buildLoadingShimmer() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.tealColor),
        const SizedBox(height: 12),
        const Text(
          'Loading customer data...',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        )
      ],
    ),
  );

  // 🔹 EMPTY STATE
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        const Text(
          "No Customers Found",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const Text(
          "Your customer data will appear here",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );

  // 🔹 FAB
  Widget _buildFAB() => FloatingActionButton(
    backgroundColor: AppColors.tealColor,
    onPressed: _generateReport,
    child: const Icon(Icons.analytics, color: Colors.white),
  );

  // 🔹 CUSTOMER DETAILS DIALOG
  void _showCustomerDetails(CustomerSummary customer) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customer.customerName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _detailCard(
                    'Invoices',
                    customer.invoiceCount.toString(),
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _detailCard(
                    'Payment',
                    '${customer.paymentPercentage.toStringAsFixed(1)}%',
                    Icons.payment,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Financial Details
            const Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _financialRow('Total Amount', customer.totalAmount, AppColors.tealColor),
                  const Divider(),
                  _financialRow('Received Amount', customer.receivedAmount, Colors.green),
                  const Divider(),
                  _financialRow('Pending Amount', customer.pendingAmount, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Invoice IDs
            const Text(
              'Invoice IDs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: customer.invoiceIds.map((id) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tealColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.tealColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          id,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.tealColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _detailCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _financialRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // 🔹 GENERATE REPORT (Keep same as before)
  void _generateReport() {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.75,
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
                  const Text(
                    'Generate Report',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Report Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildReportTypeChip(
                    'Summary Report',
                    Icons.summarize,
                    controller.selectedReportType.value == 'Summary Report',
                  ),
                  _buildReportTypeChip(
                    'Detailed Report',
                    Icons.list_alt,
                    controller.selectedReportType.value == 'Detailed Report',
                  ),
                  _buildReportTypeChip(
                    'Payment Report',
                    Icons.payment,
                    controller.selectedReportType.value == 'Payment Report',
                  ),
                ],
              )),

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

              Obx(() {
                final filteredInvoices = controller.getFilteredInvoices();
                final customerSummaries = CustomerDataGrouper.groupByCustomer(filteredInvoices);
                final totalAmount = customerSummaries.fold(0.0, (sum, c) => sum + c.totalAmount);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.tealColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Preview',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customers: ${customerSummaries.length}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Total: ₹${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

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
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormatChip(
                      'CSV',
                      Icons.grid_on,
                      controller.selectedExportFormat.value == 'CSV',
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 30),

              Obx(() => Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.tealColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tealColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: controller.isGeneratingReport.value
                      ? null
                      : () => controller.generateReport(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
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
                      Icon(Icons.analytics, color: Colors.white),
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
    );
  }

  Widget _buildReportTypeChip(String title, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () => controller.selectReportType(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.tealColor : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.tealColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
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