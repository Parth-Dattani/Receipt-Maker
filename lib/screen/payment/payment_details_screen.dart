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

///23/12
// class PaymentDetailsScreen extends GetView<PaymentDetailsController> {
//   static const String pageId = '/PaymentDetailsScreen';
//   const PaymentDetailsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFD),
//       // 📱 Mobile App Bar (Hidden on Web)
//       appBar: context.width < 900 ? _buildMobileAppBar() : null,
//       // 📱 Mobile FAB (Hidden on Web)
//       floatingActionButton: context.width < 900 ? _buildFAB() : null,
//       body: SafeArea(
//         child: Obx(() {
//           if (controller.isLoading.value) return _buildLoadingShimmer();
//
//           // Check if data exists
//           bool hasData = controller.invoices.isNotEmpty;
//           // Note: Add controller.purchases.isNotEmpty if you load purchases too
//
//           if (!hasData) return _buildEmptyState();
//
//           return LayoutBuilder(
//             builder: (context, constraints) {
//               // 📱 Mobile Layout (< 900px)
//               if (constraints.maxWidth < 900) {
//                 return _buildMobileLayout();
//               }
//               // 💻 Web Layout (>= 900px)
//               return _buildWebLayout(context);
//             },
//           );
//         }),
//       ),
//     );
//   }
//
//   // ===========================================================================
//   // 📱 MOBILE LAYOUT
//   // ===========================================================================
//
//   PreferredSizeWidget _buildMobileAppBar() => AppBar(
//     title: const Text(
//       'Payment Transactions',
//       style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 20),
//     ),
//     backgroundColor: AppColors.tealColor,
//     foregroundColor: Colors.white,
//     elevation: 0,
//   );
//
//   Widget _buildMobileLayout() {
//     return Column(
//       children: [
//         _buildSearchBar(isWeb: false),
//         Expanded(child: _buildTransactionList()),
//       ],
//     );
//   }
//
//   Widget _buildTransactionList() {
//     return Obx(() {
//       // Get summaries from controller
//       final customerSummaries = controller.getFilteredInvoiceCustomerSummaries();
//
//       if (customerSummaries.isEmpty) return _buildNoResultsFound();
//
//       return RefreshIndicator(
//         onRefresh: controller.loadData,
//         color: AppColors.tealColor,
//         child: ListView.builder(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
//           itemCount: customerSummaries.length,
//           itemBuilder: (context, index) {
//             final customer = customerSummaries[index];
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
//             isInvoice: isInvoice,
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
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//                   ),
//                   const SizedBox(width: 16),
//                   Icon(Icons.receipt_long, size: 14, color: Colors.grey.shade600),
//                   const SizedBox(width: 6),
//                   Text(
//                     '$count $countLabel${count > 1 ? 's' : ''}',
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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
//                       Text('Total Amount', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                       const SizedBox(height: 4),
//                       Text(
//                         '₹${AppUtil.formatCurrency(totalAmount)}',
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: transactionColor),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Row(
//                         children: [
//                           Text(isInvoice ? 'Received: ' : 'Paid: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                           Text(
//                             '₹${AppUtil.formatCurrency(receivedAmount)}',
//                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Text('Pending: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                           Text(
//                             '₹${AppUtil.formatCurrency(pendingAmount)}',
//                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange),
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
//   // ===========================================================================
//   // 💻 WEB LAYOUT (Data Table)
//   // ===========================================================================
//
//   Widget _buildWebLayout(BuildContext context) {
//     return Column(
//       children: [
//         // Web Header
//         Container(
//           height: 80,
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Payment Transactions',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: controller.loadData,
//                     icon: const Icon(Icons.refresh),
//                     tooltip: "Refresh",
//                   ),
//                   const SizedBox(width: 16),
//                   ElevatedButton.icon(
//                     onPressed: () => _generateReport(),
//                     icon: const Icon(Icons.download, size: 18),
//                     label: const Text("Generate Report"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.tealColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//                       elevation: 0,
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//
//         // Web Body (Table)
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(32.0),
//             child: Card(
//               elevation: 4,
//               shadowColor: Colors.black.withOpacity(0.05),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Search Bar
//                   Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: _buildSearchBar(isWeb: true),
//                   ),
//                   const Divider(height: 1),
//
//                   // Data Table
//                   Expanded(
//                     child: Obx(() {
//                       final summaries = controller.getFilteredInvoiceCustomerSummaries();
//
//                       if (summaries.isEmpty) return _buildNoResultsFound();
//
//                       return SingleChildScrollView(
//                         padding: const EdgeInsets.all(20),
//                         child: Theme(
//                           data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade200),
//                           child: DataTable(
//                             headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
//                             dataRowMinHeight: 60,
//                             dataRowMaxHeight: 60,
//                             columnSpacing: 20,
//                             columns: const [
//                               DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
//                               DataColumn(label: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold))),
//                               DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
//                               DataColumn(label: Text('Received', style: TextStyle(fontWeight: FontWeight.bold))),
//                               DataColumn(label: Text('Pending', style: TextStyle(fontWeight: FontWeight.bold))),
//                               DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
//                               DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
//                             ],
//                             rows: summaries.map((customer) {
//                               // Calculate Status
//                               bool isPaid = customer.pendingAmount <= 0;
//                               bool isPartial = customer.receivedAmount > 0 && !isPaid;
//
//                               return DataRow(
//                                 cells: [
//                                   DataCell(
//                                       Row(
//                                         children: [
//                                           CircleAvatar(
//                                             radius: 16,
//                                             backgroundColor: AppColors.tealColor.withOpacity(0.1),
//                                             child: Text(customer.customerName[0].toUpperCase(), style: TextStyle(fontSize: 12, color: AppColors.tealColor)),
//                                           ),
//                                           const SizedBox(width: 12),
//                                           Text(customer.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
//                                         ],
//                                       )
//                                   ),
//                                   DataCell(Text('${customer.invoiceCount} Invoices')),
//                                   DataCell(Text('₹${AppUtil.formatCurrency(customer.totalAmount)}', style: const TextStyle(fontWeight: FontWeight.bold))),
//                                   DataCell(Text('₹${AppUtil.formatCurrency(customer.receivedAmount)}', style: const TextStyle(color: Colors.green))),
//                                   DataCell(Text('₹${AppUtil.formatCurrency(customer.pendingAmount)}', style: const TextStyle(color: Colors.red))),
//                                   DataCell(
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                         decoration: BoxDecoration(
//                                           color: isPaid ? Colors.green.shade50 : (isPartial ? Colors.orange.shade50 : Colors.red.shade50),
//                                           borderRadius: BorderRadius.circular(4),
//                                           border: Border.all(color: isPaid ? Colors.green.shade200 : (isPartial ? Colors.orange.shade200 : Colors.red.shade200)),
//                                         ),
//                                         child: Text(
//                                           isPaid ? "Paid" : (isPartial ? "Partial" : "Pending"),
//                                           style: TextStyle(
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.bold,
//                                             color: isPaid ? Colors.green : (isPartial ? Colors.orange : Colors.red),
//                                           ),
//                                         ),
//                                       )
//                                   ),
//                                   DataCell(
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           PaymentDetailsBottomSheet.show(
//                                             customerName: customer.customerName,
//                                             paymentMethod: 'Receipt',
//                                             amount: '₹${AppUtil.formatCurrency(customer.totalAmount)}',
//                                             date: DateFormat('dd MMM yyyy').format(DateTime.now()),
//                                             notes: '',
//                                             invoiceIds: customer.invoiceIds,
//                                             currentReceived: customer.receivedAmount,
//                                             currentPending: customer.pendingAmount,
//                                             isInvoice: true,
//                                           );
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                             backgroundColor: AppColors.tealColor,
//                                             foregroundColor: Colors.white,
//                                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                             textStyle: const TextStyle(fontSize: 12)
//                                         ),
//                                         child: const Text("View Details"),
//                                       )
//                                   ),
//                                 ],
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ===========================================================================
//   // ⚙️ HELPERS
//   // ===========================================================================
//
//   Widget _buildSearchBar({required bool isWeb}) {
//     return Obx(() => Container(
//       margin: isWeb ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: TextField(
//         onChanged: (value) => controller.updateSearchQuery(value),
//         decoration: InputDecoration(
//           hintText: 'Search by customer name or invoice ID...',
//           hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//           border: InputBorder.none,
//           icon: Icon(Icons.search, color: AppColors.tealColor),
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
//   Widget _buildFAB() => FloatingActionButton(
//     backgroundColor: AppColors.tealColor,
//     onPressed: () => _generateReport(),
//     child: const Icon(Icons.download, color: Colors.white),
//   );
//
//   Widget _buildLoadingShimmer() => const Center(child: CircularProgressIndicator());
//
//   Widget _buildEmptyState() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
//         const SizedBox(height: 16),
//         const Text("No Transactions Found", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
//       ],
//     ),
//   );
//
//   Widget _buildNoResultsFound() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           Text('No results found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
//         ],
//       ),
//     );
//   }
//
//   // Report Generation Logic
//   void _generateReport() {
//     if (Get.context == null) return;
//
//     Get.bottomSheet(
//       SafeArea(
//         child: Container(
//           height: MediaQuery.of(Get.context!).size.height * 0.6,
//           padding: const EdgeInsets.all(20),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Generate Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//                     IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.grey)),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 10),
//                 Obx(() => Row(
//                   children: [
//                     Expanded(child: _buildDateField('From', Icons.calendar_today, controller.getFormattedDate(controller.fromDate.value), () => _selectFromDate())),
//                     const SizedBox(width: 10),
//                     Expanded(child: _buildDateField('To', Icons.calendar_today, controller.getFormattedDate(controller.toDate.value), () => _selectToDate())),
//                   ],
//                 )),
//                 const SizedBox(height: 30),
//                 Obx(() => SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: controller.isGeneratingReport.value ? null : () => controller.generateReport(),
//                     style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                     child: controller.isGeneratingReport.value
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text('Generate Report', style: TextStyle(color: Colors.white, fontSize: 16)),
//                   ),
//                 )),
//               ],
//             ),
//           ),
//         ),
//       ),
//       isDismissible: true,
//     );
//   }
//
//   Widget _buildDateField(String label, IconData icon, String value, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
//         child: Row(children: [Icon(icon, size: 18, color: AppColors.tealColor), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))])]),
//       ),
//     );
//   }
//
//   void _selectFromDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!, initialDate: controller.fromDate.value ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now(),
//       builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppColors.tealColor)), child: child!),
//     );
//     if (picked != null) controller.setFromDate(picked);
//   }
//
//   void _selectToDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!, initialDate: controller.toDate.value ?? DateTime.now(), firstDate: controller.fromDate.value ?? DateTime(2020), lastDate: DateTime.now(),
//       builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppColors.tealColor)), child: child!),
//     );
//     if (picked != null) controller.setToDate(picked);
//   }
// }
//
//
//
//
// class PaymentDetailsBottomSheet {
//   /// Replace the PaymentDetailsBottomSheet.show() method with this fixed version:
//
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
//     // Show loading overlay
//     Get.dialog(
//       SafeArea(
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(
//                   color: AppColors.tealColor,
//                   strokeWidth: 3,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   isInvoice ? 'Loading payment details...' : 'Loading purchase details...',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       barrierDismissible: false,
//     );
//
//     final TextEditingController noteController = TextEditingController(text: notes);
//     final TextEditingController receivedAmountController = TextEditingController();
//     final Set<String> selectedInvoiceIds = {};
//
//     // Parse total amount
//     final double totalAmount = double.tryParse(amount.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
//     final double alreadyReceived = currentReceived ?? 0.0;
//     final double alreadyPending = currentPending ?? totalAmount;
//
//     double receivedAmount = 0.0;
//     double pendingAmount = alreadyPending;
//     String errorMessage = '';
//
//     // ✅ FIX: Fetch correct data based on type
//     List<dynamic> records = []; // Can hold Invoice or PurchaseEntry
//     try {
//       if (isInvoice) {
//         // Fetch invoices
//         final allInvoices = await GoogleSheetService.getInvoices(type: "INV");
//         for (String invoiceIdWithPrefix in invoiceIds) {
//           final invoiceId = invoiceIdWithPrefix.replaceFirst('INV-', '');
//           final invoice = allInvoices.firstWhereOrNull((inv) => inv.invoiceId == invoiceId);
//           if (invoice != null) {
//             records.add(invoice);
//           }
//         }
//         print("✅ Loaded ${records.length} invoices for bottom sheet");
//       } else {
//         // ✅ Fetch purchases instead
//         final allPurchases = await GoogleSheetService.getPurchasesList();
//         for (String purchaseIdWithPrefix in invoiceIds) {
//           final purchaseId = purchaseIdWithPrefix.replaceFirst('PUR-', '');
//           final purchase = allPurchases.firstWhereOrNull((pur) => pur.purchaseId == purchaseId);
//           if (purchase != null) {
//             records.add(purchase);
//           }
//         }
//         print("✅ Loaded ${records.length} purchases for bottom sheet");
//       }
//     } catch (e) {
//       print("❌ Error loading ${isInvoice ? 'invoices' : 'purchases'}: $e");
//     }
//
//     Get.back(); // Close loading dialog
//
//     // Show actual bottom sheet
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
//                     // Header
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           isInvoice ? "Payment Details" : "Purchase Payment Details",
//                           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () => Get.back(),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//
//                     _infoRow(isInvoice ? "Customer" : "Vendor", customerName),
//                     _infoRow("Payment Method", paymentMethod),
//
//                     const Divider(height: 30, thickness: 1),
//
//                     // Amount Summary Section
//                     const Text(
//                       "Amount Summary",
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//                     ),
//                     const SizedBox(height: 12),
//
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: Column(
//                         children: [
//                           _summaryRow("Total Amount", totalAmount, Colors.blue.shade700),
//                           const Divider(height: 20),
//                           _summaryRow(
//                             isInvoice ? "Already Received" : "Already Paid",
//                             alreadyReceived,
//                             Colors.green.shade700,
//                           ),
//                           const Divider(height: 20),
//                           _summaryRow("Currently Pending", alreadyPending, Colors.orange.shade700),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // New Payment Input
//                     Text(
//                       isInvoice ? "New Payment Amount" : "New Payment Amount",
//                       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//                     ),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: receivedAmountController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         prefixText: "₹ ",
//                         hintText: "Enter payment amount",
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         errorText: errorMessage.isNotEmpty ? errorMessage : null,
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           receivedAmount = double.tryParse(value) ?? 0.0;
//
//                           if (receivedAmount > alreadyPending) {
//                             errorMessage = 'Cannot exceed pending ₹${AppUtil.formatCurrency(alreadyPending)}';
//                             receivedAmount = alreadyPending;
//                             receivedAmountController.text = alreadyPending.toStringAsFixed(0);
//                           } else if (receivedAmount < 0) {
//                             errorMessage = 'Amount must be positive';
//                             receivedAmount = 0;
//                           } else {
//                             errorMessage = '';
//                           }
//
//                           pendingAmount = alreadyPending - receivedAmount;
//                         });
//                       },
//                     ),
//
//                     const SizedBox(height: 15),
//
//                     // After Payment Summary
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue.shade200),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 isInvoice ? "New Received Total:" : "New Paid Total:",
//                                 style: const TextStyle(fontWeight: FontWeight.w600),
//                               ),
//                               Text(
//                                 "₹${AppUtil.formatCurrency(alreadyReceived + receivedAmount)}",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: Colors.green.shade700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Remaining Pending:", style: TextStyle(fontWeight: FontWeight.w600)),
//                               Text(
//                                 "₹${AppUtil.formatCurrency(pendingAmount)}",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: pendingAmount > 0 ? Colors.orange.shade700 : Colors.green.shade700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("New Status:", style: TextStyle(fontWeight: FontWeight.w600)),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: _getStatusColor(alreadyReceived + receivedAmount, totalAmount).withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   _getPaymentStatus(alreadyReceived + receivedAmount, totalAmount),
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: _getStatusColor(alreadyReceived + receivedAmount, totalAmount),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Notes Input
//                     const Text("Add Notes", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: noteController,
//                       maxLines: 2,
//                       decoration: InputDecoration(
//                         hintText: "Enter notes here...",
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//
//                     const SizedBox(height: 25),
//
//                     // ✅ Invoice/Purchase Selection
//                     Text(
//                       isInvoice ? "Select Related Invoices" : "Select Related Purchases",
//                       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//                     ),
//                     const SizedBox(height: 8),
//
//                     if (records.isEmpty)
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Text(
//                           isInvoice ? "No invoices available" : "No purchases available",
//                           style: TextStyle(color: Colors.grey.shade600),
//                         ),
//                       )
//                     else
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: records.map((record) {
//                           // ✅ Handle both Invoice and PurchaseEntry types
//                           String recordId;
//                           double recordPending;
//
//                           if (isInvoice) {
//                             final invoice = record as Invoice;
//                             recordId = 'INV-${invoice.invoiceId}';
//                             recordPending = invoice.pendingAmount ?? invoice.totalAmount ?? 0.0;
//                           } else {
//                             final purchase = record as PurchaseEntry;
//                             recordId = 'PUR-${purchase.purchaseId}';
//                             recordPending = purchase.pendingAmount ?? purchase.totalAmount ?? 0.0;
//                           }
//
//                           final isSelected = selectedInvoiceIds.contains(recordId);
//                           final isPaid = recordPending <= 0.01;
//                           final isDisabled = isPaid;
//
//                           return GestureDetector(
//                             onTap: isDisabled
//                                 ? null
//                                 : () {
//                               setState(() {
//                                 if (isSelected) {
//                                   selectedInvoiceIds.remove(recordId);
//                                 } else {
//                                   selectedInvoiceIds.add(recordId);
//                                 }
//                               });
//                             },
//                             child: Opacity(
//                               opacity: isDisabled ? 0.5 : 1.0,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                                 decoration: BoxDecoration(
//                                   color: isDisabled
//                                       ? Colors.grey.shade300
//                                       : (isSelected ? AppColors.tealColor : Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: isDisabled
//                                         ? Colors.grey.shade400
//                                         : (isSelected ? AppColors.tealColor : Colors.grey.shade400),
//                                     width: 1.2,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Text(
//                                           recordId,
//                                           style: TextStyle(
//                                             color: isDisabled
//                                                 ? Colors.grey.shade600
//                                                 : (isSelected ? Colors.white : Colors.black),
//                                             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                                             decoration: isDisabled ? TextDecoration.lineThrough : null,
//                                           ),
//                                         ),
//                                         if (isPaid) ...[
//                                           const SizedBox(width: 6),
//                                           Icon(
//                                             Icons.check_circle,
//                                             size: 16,
//                                             color: Colors.green.shade700,
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                     const SizedBox(height: 4),
//                                     if (!isPaid)
//                                       Text(
//                                         "Pending: ₹${AppUtil.formatCurrency(recordPending)}",
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: isSelected ? Colors.white70 : Colors.orange.shade700,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       )
//                                     else
//                                       Text(
//                                         "PAID",
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.green.shade700,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//
//                     const SizedBox(height: 30),
//
//                     // ✅ NEW: Generate Report Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.analytics_outlined),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                         onPressed: () {
//                           _generateClientReport(
//                             customerName: customerName,
//                             isInvoice: isInvoice,
//                             invoiceIds: invoiceIds,
//                             records: records,
//                           );
//                         },
//                         label: const Text(
//                           "Generate Client Report",
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     // Save Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.save),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.tealColor,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                         onPressed: () async {
//                           final enteredNote = noteController.text.trim();
//
//                           if (selectedInvoiceIds.isEmpty) {
//                             Get.snackbar(
//                               "Select ${isInvoice ? 'Invoice' : 'Purchase'}",
//                               "Please select at least one ${isInvoice ? 'invoice' : 'purchase'} ID.",
//                               backgroundColor: Colors.red.shade50,
//                               colorText: Colors.red.shade800,
//                             );
//                             return;
//                           }
//
//                           if (receivedAmount <= 0) {
//                             Get.snackbar(
//                               "Invalid Amount",
//                               "Please enter a valid payment amount.",
//                               backgroundColor: Colors.red.shade50,
//                               colorText: Colors.red.shade800,
//                             );
//                             return;
//                           }
//
//                           Get.back(); // Close bottom sheet
//
//                           Get.dialog(
//                             Center(
//                               child: Container(
//                                 padding: const EdgeInsets.all(24),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     CircularProgressIndicator(
//                                       color: AppColors.tealColor,
//                                       strokeWidth: 3,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     const Text(
//                                       'Saving payment...',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             barrierDismissible: false,
//                           );
//
//                           // ✅ CALL THE CORRECT METHOD BASED ON TYPE
//                           if (isInvoice) {
//                             await _updateInvoiceStatuses(
//                               selectedInvoiceIds.toList(),
//                               receivedAmount,
//                               totalAmount,
//                             );
//                           } else {
//                             await _updatePurchaseStatuses(
//                               selectedInvoiceIds.toList(),
//                               receivedAmount,
//                               totalAmount,
//                             );
//                           }
//
//                           // ✅ REFRESH THE SCREEN DATA
//                           final controller = Get.find<PaymentDetailsController>();
//                           await controller.loadData();
//                           Get.back(); // Close loading dialog
//
//                           Get.snackbar(
//                             "Success",
//                             "Payment recorded successfully!",
//                             backgroundColor: Colors.green.shade50,
//                             colorText: Colors.green.shade800,
//                             duration: const Duration(seconds: 2),
//                           );
//                         },
//                         label: const Text(
//                           "Save Payment",
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
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
// // ✅ NEW: Method to generate client-specific report
//   static void _generateClientReport({
//     required String customerName,
//     required bool isInvoice,
//     required List<String> invoiceIds,
//     required List<dynamic> records,
//   }) {
//     Get.back(); // Close the bottom sheet first
//
//     // Show report generation options
//     Get.bottomSheet(
//       SafeArea(
//         child: Container(
//           height: MediaQuery.of(Get.context!).size.height * 0.5,
//           padding: const EdgeInsets.all(20),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Generate ${isInvoice ? 'Customer' : 'Vendor'} Report',
//                     style: const TextStyle(
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
//               // Client/Vendor Info
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       isInvoice ? 'Customer Details' : 'Vendor Details',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Name: $customerName',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                     Text(
//                       'Total ${isInvoice ? 'Invoices' : 'Purchases'}: ${invoiceIds.length}',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
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
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildReportFormatChip(
//                       'PDF',
//                       Icons.picture_as_pdf,
//                       true, // Default selected
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _buildReportFormatChip(
//                       'Excel',
//                       Icons.table_chart,
//                       false,
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 30),
//
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Generate the client-specific report
//                     _generateClientSpecificReport(
//                       customerName: customerName,
//                       isInvoice: isInvoice,
//                       records: records,
//                       exportFormat: 'PDF', // You can make this dynamic
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.analytics_outlined, color: Colors.white),
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
//               ),
//             ],
//           ),
//         ),
//       ),
//       isDismissible: true,
//       enableDrag: true,
//     );
//   }
//
// // ✅ NEW: Helper method for report format chips
//   static Widget _buildReportFormatChip(String title, IconData icon, bool isSelected) {
//     return InkWell(
//       onTap: () {
//         // Handle format selection
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? Colors.orange.withOpacity(0.15)
//               : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Colors.orange : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 24,
//               color: isSelected ? Colors.orange : Colors.grey[700],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: TextStyle(
//                 color: isSelected ? Colors.orange : Colors.grey[700],
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
//
// // ✅ FIXED: Method to generate client-specific report with company data
//   static void _generateClientSpecificReport({
//     required String customerName,
//     required bool isInvoice,
//     required List<dynamic> records,
//     required String exportFormat,
//   }) async {
//     // Close the format selection bottom sheet
//     Get.back();
//
//     // Show loading
//     Get.dialog(
//       Center(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 color: Colors.orange,
//                 strokeWidth: 3,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Generating ${isInvoice ? 'Customer' : 'Vendor'} Report...',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       barrierDismissible: false,
//     );
//
//     try {
//       if (exportFormat == 'PDF') {
//         // ✅ FIXED: Get company name from controller
//         final PaymentDetailsController controller = Get.find<PaymentDetailsController>();
//         String companyName = controller.getCompanyName();
//
//         final File? file = await PdfHelper.generateClientReport(
//           records: records,
//           customerName: customerName,
//           isInvoice: isInvoice,
//           fromDate: DateTime.now().subtract(const Duration(days: 365)),
//           toDate: DateTime.now(),
//           userCompanyName: companyName, // ✅ Pass actual company name
//         );
//
//         Get.back(); // Close loading
//
//         if (file != null && file.existsSync()) {
//           // Show success dialog with share options
//           _shareReportFile(file, customerName, isInvoice);
//         } else {
//           Get.snackbar(
//             'Error',
//             'Failed to generate report file',
//             backgroundColor: Colors.red.shade50,
//             colorText: Colors.red.shade800,
//           );
//         }
//       } else {
//         // Handle Excel format here if needed
//         Get.back(); // Close loading
//         Get.snackbar(
//           'Info',
//           'Excel report generation for clients is coming soon!',
//           backgroundColor: Colors.blue.shade50,
//           colorText: Colors.blue.shade800,
//         );
//       }
//     } catch (e) {
//       Get.back(); // Close loading
//       Get.snackbar(
//         'Error',
//         'Failed to generate report: $e',
//         backgroundColor: Colors.red.shade50,
//         colorText: Colors.red.shade800,
//       );
//     }
//   }
//
//
//   // ✅ CORRECTED: Share report file method
//   static Future<void> _shareReportFile(File file, String customerName, bool isInvoice) async {
//     try {
//       final result = await Share.shareXFiles(
//         [XFile(file.path)],
//         text: '${isInvoice ? 'Customer' : 'Vendor'} Payment Report for $customerName\n\nGenerated on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
//         subject: '${isInvoice ? 'Customer' : 'Vendor'} Payment Report - $customerName',
//       );
//
//       if (result.status == ShareResultStatus.success) {
//         Get.snackbar(
//           'Success',
//           'Report shared successfully!',
//           backgroundColor: Colors.green.shade50,
//           colorText: Colors.green.shade800,
//         );
//       }
//     } catch (e) {
//       print('❌ Error sharing file: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to share report: $e',
//         backgroundColor: Colors.red.shade50,
//         colorText: Colors.red.shade800,
//       );
//     }
//   }
//
//
//
//
//   static String _getPaymentStatus(double received, double total) {
//     if (received >= total) return 'PAID';
//     if (received > 0 && received < total) return 'PARTIAL';
//     return 'PENDING';
//   }
//
//   static Color _getStatusColor(double received, double total) {
//     if (received >= total) return Colors.green;
//     if (received > 0 && received < total) return Colors.orange;
//     return Colors.red;
//   }
//
//   static Future<void> _updateInvoiceStatuses(
//       List<String> invoiceIds,
//       double receivedAmount,
//       double totalAmount,
//       ) async {
//     try {
//       print("🔄 Updating statuses for ${invoiceIds.length} invoices...");
//
//       final allInvoices = await GoogleSheetService.getInvoices(type: "INV");
//
//       List<Invoice> selectedInvoices = [];
//       for (String invoiceIdWithPrefix in invoiceIds) {
//         final invoiceId = invoiceIdWithPrefix.replaceFirst(RegExp(r'(INV|PUR)-'), '');
//         final invoice = allInvoices.firstWhereOrNull((inv) => inv.invoiceId == invoiceId);
//         if (invoice != null) {
//           selectedInvoices.add(invoice);
//         }
//       }
//
//       if (selectedInvoices.isEmpty) {
//         print("⚠️ No invoices found to update");
//         return;
//       }
//
//       double remainingAmount = receivedAmount;
//
//       for (final invoice in selectedInvoices) {
//         if (remainingAmount <= 0) break;
//
//         final invoiceTotal = invoice.totalAmount ?? 0.0;
//         final invoicePending = invoice.pendingAmount ?? invoiceTotal;
//         final invoiceReceived = invoice.receivedAmount ?? 0.0;
//
//         final actualPayment = remainingAmount >= invoicePending ? invoicePending : remainingAmount;
//         final newReceivedAmount = invoiceReceived + actualPayment;
//         final newPendingAmount = invoiceTotal - newReceivedAmount;
//
//         remainingAmount -= actualPayment;
//
//         String newStatus;
//         if (newPendingAmount <= 0.01) {
//           newStatus = 'Paid';
//         } else if (newReceivedAmount > 0) {
//           newStatus = 'Partial';
//         } else {
//           newStatus = 'Pending';
//         }
//
//         final updatedInvoiceData = {
//           'invoiceId': invoice.invoiceId,
//           'customerId': invoice.customerId ?? '',
//           'customerName': invoice.customerName ?? '',
//           'customerEmail': invoice.customerEmail ?? '',
//           'customerPan': invoice.customerPan ?? '',
//           'customerGst': invoice.customerGst ?? '',
//           'mobile': invoice.mobile ?? '',
//           'customerAddress': invoice.customerAddress ?? '',
//           'issueDate': invoice.issueDate?.toIso8601String() ?? '',
//           'dueDate': invoice.dueDate?.toIso8601String() ?? '',
//           'subtotal': (invoice.subtotal ?? 0.0).toString(),
//           'gstAmount': (invoice.gstAmount ?? 0.0).toString(),
//           'totalAmount': invoiceTotal.toString(),
//           'receivedAmount': newReceivedAmount.toString(),
//           'pendingAmount': newPendingAmount.toString(),
//           'status': newStatus,
//           'notes': invoice.notes ?? '',
//         };
//
//         await GoogleSheetService.updateInvoice(
//           updatedInvoiceData,
//           AppConstants.userId,
//         );
//
//         print("✅ Updated ${invoice.invoiceId}");
//       }
//
//       print("✅ All statuses updated successfully");
//     } catch (e) {
//       print("❌ Error: $e");
//       if (Get.isDialogOpen ?? false) Get.back();
//       Get.snackbar(
//         "Error",
//         "Failed to update: $e",
//         backgroundColor: Colors.red.shade50,
//         colorText: Colors.red.shade800,
//       );
//     }
//   }
//
// // ✅ FIXED: Replace your existing _updatePurchaseStatuses method with this corrected version
//
//   static Future<void> _updatePurchaseStatuses(
//       List<String> purchaseIds,
//       double paidAmount,
//       double totalAmount,
//       ) async {
//     try {
//       print("🔄 Updating payment status for ${purchaseIds.length} purchases...");
//       print("💰 Payment amount to distribute: ₹$paidAmount");
//
//       final allPurchases = await GoogleSheetService.getPurchasesList();
//
//       List<PurchaseEntry> selectedPurchases = [];
//       for (String purchaseIdWithPrefix in purchaseIds) {
//         final purchaseId = purchaseIdWithPrefix.replaceFirst('PUR-', '');
//         final purchase = allPurchases.firstWhereOrNull((pur) => pur.purchaseId == purchaseId);
//         if (purchase != null) {
//           selectedPurchases.add(purchase);
//           print("✅ Found purchase: ${purchase.purchaseId} - Pending: ₹${purchase.pendingAmount}");
//         }
//       }
//
//       if (selectedPurchases.isEmpty) {
//         print("⚠️ No purchases found to update");
//         return;
//       }
//
//       print("✅ Found ${selectedPurchases.length} purchases to update");
//
//       double remainingAmount = paidAmount;
//
//       for (final purchase in selectedPurchases) {
//         if (remainingAmount <= 0) {
//           print("⚠️ No remaining amount for ${purchase.purchaseId}");
//           break;
//         }
//
//         final purchaseTotal = purchase.totalAmount ?? 0.0;
//         final purchasePending = purchase.pendingAmount ?? purchaseTotal;
//         final purchasePaid = purchase.paidAmount ?? 0.0;
//
//         print("\n📝 Processing Purchase ${purchase.purchaseId}:");
//         print("   Total Amount: ₹$purchaseTotal");
//         print("   Already Paid: ₹$purchasePaid");
//         print("   Pending: ₹$purchasePending");
//         print("   Available to pay: ₹$remainingAmount");
//
//         // Calculate actual payment to apply
//         final actualPayment = remainingAmount >= purchasePending ? purchasePending : remainingAmount;
//
//         final newPaidAmount = purchasePaid + actualPayment;
//         final newPendingAmount = purchaseTotal - newPaidAmount;
//
//         remainingAmount -= actualPayment;
//
//         // Determine new status
//         String newStatus;
//         if (newPendingAmount <= 0.01) {
//           newStatus = 'Paid';
//         } else if (newPaidAmount > 0) {
//           newStatus = 'Partial';
//         } else {
//           newStatus = 'Pending';
//         }
//
//         print("   Payment Applied: ₹$actualPayment");
//         print("   New Status: $newStatus");
//         print("   New Paid Amount: ₹$newPaidAmount");
//         print("   New Pending Amount: ₹$newPendingAmount");
//
//         // ✅ CRITICAL FIX: Make sure ALL fields are included in the update
//         final updatedPurchaseData = {
//           'purchaseId': purchase.purchaseId,
//           'vendorId': purchase.vendorId ?? '',
//           'vendorName': purchase.vendorName ?? '',
//           'vendorEmail': purchase.vendorEmail ?? '',
//           'vendorMobile': purchase.vendorMobile ?? '',
//           'vendorAddress': purchase.vendorAddress ?? '',
//           'purchaseDate': purchase.purchaseDate?.toIso8601String() ?? '',
//           'dueDate': purchase.dueDate?.toIso8601String() ?? '',
//           'subtotal': (purchase.subtotal ?? 0.0).toString(),
//           'gstRate': (purchase.gstRate ?? 0.0).toString(),
//           'gstAmount': (purchase.gstAmount ?? 0.0).toString(),
//           'totalAmount': purchaseTotal.toString(),
//           'paidAmount': newPaidAmount.toString(),       // ✅ UPDATE THIS
//           'pendingAmount': newPendingAmount.toString(), // ✅ UPDATE THIS
//           'paymentStatus': newStatus,                   // ✅ UPDATE THIS
//           'notes': purchase.notes ?? '',
//           'userId': AppConstants.userId,                // ✅ IMPORTANT: Add userId
//         };
//
//         print("📤 Sending update to Google Sheets...");
//
//         // Update the purchase record
//         await GoogleSheetService.updatePurchase(
//           updatedPurchaseData,
//           AppConstants.userId,
//         );
//
//         print("✅ Successfully updated ${purchase.purchaseId}");
//       }
//
//       print("\n✅ All purchase statuses updated successfully");
//       print("💰 Remaining amount not used: ₹$remainingAmount");
//
//     } catch (e, stackTrace) {
//       print("❌ Error updating purchase statuses: $e");
//       print("Stack trace: $stackTrace");
//
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//
//       Get.snackbar(
//         "Error",
//         "Failed to update purchase statuses: $e",
//         backgroundColor: Colors.red.shade50,
//         colorText: Colors.red.shade800,
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }
//
// // ✅ UPDATE the onPressed in Save Button to handle BOTH invoices and purchases
// // Replace the existing onPressed in your Save Payment button with this:
//
//
//   static Widget _infoRow(String label, String value, {Color? valueColor}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: valueColor ?? Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static Widget _summaryRow(String label, double amount, Color color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         Text(
//           "₹${AppUtil.formatCurrency(amount)}",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }




///from history 18/12

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
    final content = LayoutBuilder(
      builder: (context, constraints) {
        // Check if it's web layout (width > 900)
        bool isWeb = constraints.maxWidth > 900;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          appBar: _buildAppBar(isWeb),
          body: SafeArea(
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
          floatingActionButton: _buildFAB(),
        );
      },
    );
    if (kIsWeb) return webScreenWrapper(currentRoute: pageId, child: content);
    return content;
  }

  AppBar _buildAppBar(bool isWeb) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.tealColor,
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
        onPressed: () => Get.back(),
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
          color: isSelected ? AppColors.tealColor : Colors.transparent,
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
        color: AppColors.tealColor,
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
        color: AppColors.tealColor,
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
    backgroundColor: AppColors.tealColor,
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
          color: isSelected ? AppColors.tealColor.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.tealColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Column(children: [Icon(icon, size: 24, color: isSelected ? AppColors.tealColor : Colors.grey[700]), const SizedBox(height: 4), Text(title, style: TextStyle(color: isSelected ? AppColors.tealColor : Colors.grey[700], fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, fontSize: 12))]),
      ),
    );
  }

  Widget _buildDateField(String label, IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: Row(children: [Icon(icon, size: 18, color: AppColors.tealColor), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))]))]),
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
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppColors.tealColor, onPrimary: Colors.white)), child: child!),
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
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppColors.tealColor, onPrimary: Colors.white)), child: child!),
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
        child: CircularProgressIndicator(color: AppColors.tealColor))),
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
                            receivedAmountController.text = alreadyPending.toStringAsFixed(0);
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
                              decoration: BoxDecoration(color: isSelected ? AppColors.tealColor : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                              child: Text("$recordId (${isPaid ? 'PAID' : 'Pending: ${recordPending.toStringAsFixed(0)}'})", style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
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
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () async {
                          if (selectedInvoiceIds.isEmpty) { Get.snackbar("Error", "Select at least one record", backgroundColor: Colors.red.shade100); return; }
                          if (receivedAmount <= 0) { Get.snackbar("Error", "Enter valid amount", backgroundColor: Colors.red.shade100); return; }

                          Navigator.of(context).pop();
                          Get.dialog(Center(child: Card(child: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: AppColors.tealColor), SizedBox(height: 16), Text("Saving payment...")])))), barrierDismissible: false);

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
            activeColor: AppColors.tealColor,
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

      final updateData = {
        'invoiceId': invoice.invoiceId,
        //'customerId': invoice.customerId ?? '',
        'receivedAmount': newReceived.toString(),
        'pendingAmount': newPending.toString(),
        'status': status,
        'paymentMode': paymentMode, // ✅ Save Mode
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
//       backgroundColor: AppColors.tealColor,
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
//           color: isSelected ? AppColors.tealColor : Colors.transparent,
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
//           icon: Icon(Icons.search, color: AppColors.tealColor),
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
//         color: AppColors.tealColor,
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
//         color: AppColors.tealColor,
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
//     backgroundColor: AppColors.tealColor,
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
//                     backgroundColor: AppColors.tealColor,
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
//           child: CircularProgressIndicator(color: AppColors.tealColor),
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
//                             receivedAmountController.text = alreadyPending.toStringAsFixed(0);
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
//                                 color: isSelected ? AppColors.tealColor : Colors.grey.shade200,
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
//                           backgroundColor: AppColors.tealColor,
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
//                                       CircularProgressIndicator(color: AppColors.tealColor),
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



