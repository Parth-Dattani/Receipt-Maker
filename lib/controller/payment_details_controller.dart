////23/12 remove This bcs  tab bar Not Show
// import 'dart:io';
//
// import 'package:GetYourInvoice/services/remote_service.dart';
// import 'package:GetYourInvoice/utils/pdf_helper.dart';
// import 'package:excel/excel.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../model/model.dart';
// import '../utils/utils.dart';
// import '../widgets/widgets.dart';
// import 'controller.dart';
//
// // payment_details_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // payment_details_controller.dart
//
// // payment_details_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// import 'package:pdf/widgets.dart' as pw;
//
//
// class PaymentDetailsController extends GetxController {
//   var invoices = <Invoice>[].obs;
//   var isLoading = true.obs;
//   var searchQuery = ''.obs;
//
//   // ✅ NEW: Toggle between Invoice and Purchase view
//   var selectedTab = 'Invoice'.obs;  // 'Invoice' or 'Purchase'
//
//   // Report Generation State
//   var selectedExportFormat = 'PDF'.obs;
//   var fromDate = Rx<DateTime?>(null);
//   var toDate = Rx<DateTime?>(null);
//   var isGeneratingReport = false.obs;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   var companyData = <String, dynamic>{}.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadData();
//     loadCompanyData();
//     toDate.value = DateTime.now();
//     fromDate.value = DateTime.now().subtract(const Duration(days: 30));
//   }
//
//
//   // ✅ NEW: Load both invoices and purchases
//   Future<void> loadData() async {
//     try {
//       isLoading.value = true;
//
//       final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//       if (currentUserId == null) {
//         showCustomSnackbar(
//           title: "Error",
//           message: "User not logged in",
//           baseColor: Colors.red.shade700,
//           icon: Icons.error_outline,
//         );
//         return;
//       }
//
//       // Load invoices
//       List<Invoice> allInvoices = await GoogleSheetService.getInvoices(type: "INV");
//       if (allInvoices.isEmpty) {
//         allInvoices = await GoogleSheetService.getInvoices();
//       }
//       invoices.value = allInvoices.where((inv) => inv.userId == currentUserId).toList();
//
//
//       print("✅ Loaded ${invoices.length} invoices");
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load data: ${e.toString()}',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//         icon: Icon(Icons.error_outline, color: Colors.red.shade700),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//
//   Future<void> loadCompanyData() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
//       if (companyId.isEmpty) return;
//
//       final companyDoc = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("companies")
//           .doc(companyId)
//           .get();
//
//       if (companyDoc.exists) {
//         companyData.value = companyDoc.data() ?? {};
//       }
//     } catch (e) {
//       print("Error loading company data: $e");
//     }
//   }
//
//   // ✅ Get company name method
//   String getCompanyName() {
//     return companyData['companyName'] ??
//         companyData['businessName'] ??
//         companyData['name'] ??
//         'Your Company';
//   }
//
//   // ✅ Get company address method
//   String getCompanyAddress() {
//     return companyData['address'] ??
//         companyData['companyAddress'] ??
//         '';
//   }
//
//   // ✅ Get company contact method
//   String getCompanyContact() {
//     return companyData['phone'] ??
//         companyData['mobile'] ??
//         companyData['contactNumber'] ??
//         '';
//   }
//   // ✅ Get company email method
//   String getCompanyEmail() {
//     return companyData['email'] ??
//         companyData['companyEmail'] ??
//         '';
//   }
//
//   // ✅ NEW: Switch between Invoice and Purchase tabs
//   void switchTab(String tab) {
//     selectedTab.value = tab;
//   }
//
//   // ✅ NEW: Get filtered customer summaries for invoices
//   List<CustomerSummary> getFilteredInvoiceCustomerSummaries() {
//     final customerSummaries = CustomerDataGrouper.groupByCustomer(invoices);
//
//     if (searchQuery.value.isEmpty) {
//       return customerSummaries;
//     }
//
//     return customerSummaries.where((customer) {
//       final query = searchQuery.value.toLowerCase();
//       return customer.customerName.toLowerCase().contains(query) ||
//           customer.invoiceIds.any((id) => id.toLowerCase().contains(query));
//     }).toList();
//   }
//
//
//   void updateSearchQuery(String query) {
//     searchQuery.value = query;
//   }
//
//   Color getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'paid':
//       case 'accepted':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'overdue':
//         return Colors.red;
//       case 'partial':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   void selectExportFormat(String format) {
//     selectedExportFormat.value = format;
//   }
//
//   void setFromDate(DateTime date) {
//     fromDate.value = date;
//     if (toDate.value != null && date.isAfter(toDate.value!)) {
//       toDate.value = date;
//     }
//   }
//
//   void setToDate(DateTime date) {
//     toDate.value = date;
//     if (fromDate.value != null && date.isBefore(fromDate.value!)) {
//       fromDate.value = date;
//     }
//   }
//
//   List<Invoice> getFilteredInvoices() {
//     if (fromDate.value == null || toDate.value == null) {
//       return invoices;
//     }
//
//     return invoices.where((invoice) {
//       final invoiceDate = invoice.issueDate ?? DateTime.now();
//       return invoiceDate.isAfter(fromDate.value!) &&
//           invoiceDate.isBefore(toDate.value!.add(const Duration(days: 1)));
//     }).toList();
//   }
//
//   Future<void> generateReport() async {
//     try {
//       if (fromDate.value == null || toDate.value == null) {
//         Get.snackbar(
//           'Validation Error',
//           'Please select both from and to dates',
//           backgroundColor: Colors.orange.shade100,
//           colorText: Colors.orange.shade800,
//           icon: const Icon(Icons.warning_amber, color: Colors.orange),
//         );
//         return;
//       }
//
//       isGeneratingReport.value = true;
//
//       // ✅ Generate report based on selected tab
//       if (selectedTab.value == 'Invoice') {
//         final filteredInvoices = getFilteredInvoices();
//
//         if (filteredInvoices.isEmpty) {
//           Get.snackbar(
//             'No Data',
//             'No invoices found for the selected date range',
//             backgroundColor: Colors.blue.shade100,
//             colorText: Colors.blue.shade800,
//             icon: const Icon(Icons.info_outline, color: Colors.blue),
//           );
//           isGeneratingReport.value = false;
//           return;
//         }
//
//         await Future.delayed(const Duration(seconds: 1));
//
//         switch (selectedExportFormat.value) {
//           case 'PDF':
//             await _generateInvoicePDFReport(filteredInvoices);
//             break;
//           case 'Excel':
//             await _generateInvoiceExcelReport(filteredInvoices);
//             break;
//         }
//       }
//
//       Get.back();
//
//       Get.snackbar(
//         'Success',
//         'Payment Report generated successfully!',
//         backgroundColor: Colors.green.shade100,
//         colorText: Colors.green.shade800,
//         icon: const Icon(Icons.check_circle, color: Colors.green),
//         duration: const Duration(seconds: 3),
//       );
//
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to generate report: ${e.toString()}',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//         icon: const Icon(Icons.error_outline, color: Colors.red),
//       );
//     } finally {
//       isGeneratingReport.value = false;
//     }
//   }
//
//   // Invoice report methods (existing)
//   Future<void> _generateInvoicePDFReport(List<Invoice> invoices) async {
//     print("📄 Generating Invoice PDF report with ${invoices.length} invoices");
//
//     try {
//       // ✅ FIXED: Use company data
//       String companyName = getCompanyName();
//
//       await PdfHelper.generatePaymentReport(
//         invoices: invoices,
//         fromDate: fromDate.value!,
//         toDate: toDate.value!,
//         userCompanyName: companyName,
//       );
//
//       print("✅ PDF Report generated successfully!");
//     } catch (e) {
//       print("❌ Error generating PDF: $e");
//       throw e;
//     }
//   }
//
//   Future<void> _generateInvoiceExcelReport(List<Invoice> invoices) async {
//     print("📊 Generating Invoice Excel report with ${invoices.length} invoices");
//
//     try {
//       // ✅ FIXED: Use company data
//       String companyName = getCompanyName();
//
//       await ExcelReportService.generatePaymentReport(
//         invoices: invoices,
//         fromDate: fromDate.value!,
//         toDate: toDate.value!,
//         userCompanyName: companyName,
//       );
//
//       print("✅ Excel Report generated successfully!");
//     } catch (e) {
//       print("❌ Error generating Excel: $e");
//       throw e;
//     }
//   }
//
//   String getFormattedDate(DateTime? date) {
//     if (date == null) return 'Select Date';
//     return DateFormat('dd MMM yyyy').format(date);
//   }
// }
//
// class ReportDataCalculator {
//   static Map<String, dynamic> calculate(List<Invoice> invoices) {
//     double totalAmount = 0.0;
//     double receivedAmount = 0.0;
//     double pendingAmount = 0.0;
//     int paidCount = 0;
//     int pendingCount = 0;
//     int overdueCount = 0;
//     int partialCount = 0;
//
//     // Calculate amounts by status
//     double paidAmount = 0.0;
//     double pendingAmountByStatus = 0.0;
//     double overdueAmount = 0.0;
//     double partialAmount = 0.0;
//
//     for (var invoice in invoices) {
//       totalAmount += invoice.totalAmount ?? 0.0;
//       receivedAmount += invoice.receivedAmount ?? 0.0;
//       pendingAmount += invoice.pendingAmount ?? 0.0;
//
//       switch (invoice.status?.toLowerCase()) {
//         case 'paid':
//         case 'accepted':
//           paidCount++;
//           paidAmount += invoice.totalAmount ?? 0.0;
//           break;
//         case 'pending':
//           pendingCount++;
//           pendingAmountByStatus += invoice.totalAmount ?? 0.0;
//           break;
//         case 'overdue':
//           overdueCount++;
//           overdueAmount += invoice.totalAmount ?? 0.0;
//           break;
//         case 'partial':
//           partialCount++;
//           partialAmount += invoice.totalAmount ?? 0.0;
//           break;
//       }
//     }
//
//     return {
//       'totalInvoices': invoices.length,
//       'totalAmount': totalAmount,
//       'receivedAmount': receivedAmount,
//       'pendingAmount': pendingAmount,
//       'paidCount': paidCount,
//       'pendingCount': pendingCount,
//       'overdueCount': overdueCount,
//       'partialCount': partialCount,
//       'paidAmount': paidAmount,
//       'pendingAmountByStatus': pendingAmountByStatus,
//       'overdueAmount': overdueAmount,
//       'partialAmount': partialAmount,
//       'paymentRate': totalAmount > 0 ? (receivedAmount / totalAmount * 100) : 0,
//     };
//   }
// }
//
//
// // ==================== UPDATED EXCEL REPORT WITH AMOUNT COLUMNS ====================
// class ExcelReportService {
//   static Future<void> generatePaymentReport({
//     required List<Invoice> invoices,
//     required DateTime fromDate,
//     required DateTime toDate,
//     String? userCompanyName,
//   }) async {
//     var excel = Excel.createExcel();
//     final customerSummaries = CustomerDataGrouper.groupByCustomer(invoices);
//     final reportData = ReportDataCalculator.calculate(invoices);
//
//     Sheet sheetObject = excel['Payment Transaction Report'];
//
//     // Header
//     _addReportHeader(sheetObject, userCompanyName, 'Payment Transaction Report', fromDate, toDate);
//
//     // Summary Section
//     sheetObject.appendRow([TextCellValue('SUMMARY OVERVIEW')]);
//     sheetObject.appendRow([]);
//     sheetObject.appendRow([TextCellValue('Total Customers'), IntCellValue(customerSummaries.length)]);
//     sheetObject.appendRow([TextCellValue('Total Invoices'), IntCellValue(reportData['totalInvoices'])]);
//     sheetObject.appendRow([TextCellValue('Total Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['totalAmount'])}')]);
//     sheetObject.appendRow([TextCellValue('Received Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['receivedAmount'])}')]);
//     sheetObject.appendRow([TextCellValue('Pending Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['pendingAmount'])}')]);
//     sheetObject.appendRow([TextCellValue('Collection Rate'), TextCellValue('${reportData['paymentRate'].toStringAsFixed(1)}%')]);
//     sheetObject.appendRow([]);
//
//     // Customer-wise Transactions with Amount Columns
//     sheetObject.appendRow([TextCellValue('CUSTOMER-WISE PAYMENT TRANSACTIONS')]);
//     sheetObject.appendRow([
//       TextCellValue('Sr.No'),
//       TextCellValue('Date'),
//       TextCellValue('Customer Name'),
//       TextCellValue('Invoice Count'),
//       TextCellValue('Total Amount'),
//       TextCellValue('Received Amount'),
//       TextCellValue('Pending Amount'),
//       TextCellValue('Payment %'),
//       TextCellValue('Invoice IDs'),
//     ]);
//
//     int srNo = 0;
//     double grandTotal = 0.0;
//     double grandReceived = 0.0;
//     double grandPending = 0.0;
//
//     for (var customer in customerSummaries) {
//       srNo++;
//
//       sheetObject.appendRow([
//         IntCellValue(srNo),
//         TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now())),
//         TextCellValue(customer.customerName),
//         IntCellValue(customer.invoiceCount),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.totalAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.receivedAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.pendingAmount)}'),
//         TextCellValue('${customer.paymentPercentage.toStringAsFixed(1)}%'),
//         TextCellValue(customer.invoiceIds.join(', ')),
//       ]);
//
//       grandTotal += customer.totalAmount;
//       grandReceived += customer.receivedAmount;
//       grandPending += customer.pendingAmount;
//     }
//
//     // Grand Total Row
//     sheetObject.appendRow([]);
//     sheetObject.appendRow([
//       TextCellValue('GRAND TOTAL'),
//       TextCellValue(''),
//       TextCellValue(''),
//       IntCellValue(reportData['totalInvoices']),
//       TextCellValue('₹${AppUtil.formatCurrency(grandTotal)}'),
//       TextCellValue('₹${AppUtil.formatCurrency(grandReceived)}'),
//       TextCellValue('₹${AppUtil.formatCurrency(grandPending)}'),
//       TextCellValue('${(grandTotal > 0 ? (grandReceived / grandTotal * 100) : 0.0).toStringAsFixed(1)}%'),
//       TextCellValue(''),
//     ]);
//
//     await _saveExcel(excel, 'Payment_Transaction_Report');
//   }
//
//   // ✅ NEW: Generate Purchase Payment Report
//   static Future<void> generatePurchasePaymentReport({
//     required List<PurchaseEntry> purchases,
//     required DateTime fromDate,
//     required DateTime toDate,
//     String? userCompanyName,
//   }) async {
//     var excel = Excel.createExcel();
//     final vendorSummaries = VendorDataGrouper.groupByVendor(purchases);
//     final reportData = _calculatePurchaseReportData(purchases);
//
//     Sheet sheetObject = excel['Purchase Payment Report'];
//
//     // Header
//     _addReportHeader(sheetObject, userCompanyName, 'Purchase Payment Report', fromDate, toDate);
//
//     // Summary Section
//     sheetObject.appendRow([TextCellValue('SUMMARY OVERVIEW')]);
//     sheetObject.appendRow([]);
//     sheetObject.appendRow([TextCellValue('Total Vendors'), IntCellValue(vendorSummaries.length)]);
//     sheetObject.appendRow([TextCellValue('Total Purchases'), IntCellValue(reportData['totalPurchases'])]);
//     sheetObject.appendRow([TextCellValue('Total Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['totalAmount'])}')]);
//     sheetObject.appendRow([TextCellValue('Paid Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['paidAmount'])}')]);
//     sheetObject.appendRow([TextCellValue('Pending Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['pendingAmount'])}')]);
//     sheetObject.appendRow([TextCellValue('Payment Rate'), TextCellValue('${reportData['paymentRate'].toStringAsFixed(1)}%')]);
//     sheetObject.appendRow([]);
//
//     // Vendor-wise Transactions
//     sheetObject.appendRow([TextCellValue('VENDOR-WISE PAYMENT TRANSACTIONS')]);
//     sheetObject.appendRow([
//       TextCellValue('Sr.No'),
//       TextCellValue('Date'),
//       TextCellValue('Vendor Name'),
//       TextCellValue('Purchase Count'),
//       TextCellValue('Total Amount'),
//       TextCellValue('Paid Amount'),
//       TextCellValue('Pending Amount'),
//       TextCellValue('Payment %'),
//       TextCellValue('Purchase IDs'),
//     ]);
//
//     int srNo = 0;
//     double grandTotal = 0.0;
//     double grandPaid = 0.0;
//     double grandPending = 0.0;
//
//     for (var vendor in vendorSummaries) {
//       srNo++;
//
//       sheetObject.appendRow([
//         IntCellValue(srNo),
//         TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now())),
//         TextCellValue(vendor.vendorName),
//         IntCellValue(vendor.purchaseCount),
//         TextCellValue('₹${AppUtil.formatCurrency(vendor.totalAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(vendor.paidAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(vendor.pendingAmount)}'),
//         TextCellValue('${vendor.paymentPercentage.toStringAsFixed(1)}%'),
//         TextCellValue(vendor.purchaseIds.join(', ')),
//       ]);
//
//       grandTotal += vendor.totalAmount;
//       grandPaid += vendor.paidAmount;
//       grandPending += vendor.pendingAmount;
//     }
//
//     // Grand Total Row
//     sheetObject.appendRow([]);
//     sheetObject.appendRow([
//       TextCellValue('GRAND TOTAL'),
//       TextCellValue(''),
//       TextCellValue(''),
//       IntCellValue(reportData['totalPurchases']),
//       TextCellValue('₹${AppUtil.formatCurrency(grandTotal)}'),
//       TextCellValue('₹${AppUtil.formatCurrency(grandPaid)}'),
//       TextCellValue('₹${AppUtil.formatCurrency(grandPending)}'),
//       TextCellValue('${(grandTotal > 0 ? (grandPaid / grandTotal * 100) : 0.0).toStringAsFixed(1)}%'),
//       TextCellValue(''),
//     ]);
//
//     await _saveExcel(excel, 'Purchase_Payment_Report');
//   }
//
//   static Map<String, dynamic> _calculatePurchaseReportData(List<PurchaseEntry> purchases) {
//     double totalAmount = 0.0;
//     double paidAmount = 0.0;
//     double pendingAmount = 0.0;
//
//     for (var purchase in purchases) {
//       totalAmount += purchase.totalAmount ?? 0.0;
//       paidAmount += purchase.paidAmount ?? 0.0;
//       pendingAmount += purchase.pendingAmount ?? 0.0;
//     }
//
//     return {
//       'totalPurchases': purchases.length,
//       'totalAmount': totalAmount,
//       'paidAmount': paidAmount,
//       'pendingAmount': pendingAmount,
//       'paymentRate': totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0,
//     };
//   }
//
//   static void _addReportHeader(Sheet sheet, String? companyName, String title, DateTime fromDate, DateTime toDate) {
//     sheet.appendRow([TextCellValue(companyName ?? 'Your Company')]);
//     sheet.appendRow([TextCellValue(title)]);
//     sheet.appendRow([TextCellValue('Period: ${DateFormat('dd MMM yyyy').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}')]);
//     sheet.appendRow([TextCellValue('Generated on: ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}')]);
//     sheet.appendRow([]);
//   }
//
//   static Future<void> _saveExcel(Excel excel, String reportType) async {
//     try {
//       final output = await getTemporaryDirectory();
//       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//       final fileName = '${reportType}_$timestamp.xlsx';
//       final file = File('${output.path}/$fileName');
//
//       final fileBytes = excel.save();
//       if (fileBytes != null) {
//         await file.writeAsBytes(fileBytes);
//         print('✅ Excel saved at: ${file.path}');
//         await OpenFile.open(file.path);
//       }
//     } catch (e) {
//       print('❌ Error saving Excel: $e');
//       throw Exception('Failed to save Excel: $e');
//     }
//   }
//
// }
//
//
// // ==================== UPDATED PDF REPORT WITH AMOUNT COLUMNS ====================
// class PdfHelper {
//   static Future<void> generatePaymentReport({
//     required List<Invoice> invoices,
//     required DateTime fromDate,
//     required DateTime toDate,
//     String? userCompanyName,
//   }) async {
//     final pdf = pw.Document();
//
//     // Load font (same as InvoiceHelper - already supports ₹)
//     final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
//     final customFont = pw.Font.ttf(fontData.buffer.asByteData());
//
//     final theme = pw.ThemeData.withFont(
//       base: customFont,
//       bold: customFont,
//       italic: customFont,
//       boldItalic: customFont,
//     );
//
//     final customerSummaries = CustomerDataGrouper.groupByCustomer(invoices);
//     final reportData = ReportDataCalculator.calculate(invoices);
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(32),
//         theme: theme,
//         build: (context) => [
//           _buildHeader(userCompanyName ?? 'Your Company', 'Payment Transaction Report', fromDate, toDate),
//           pw.SizedBox(height: 20),
//
//           // Summary Overview
//           _buildSectionTitle('Summary Overview'),
//           pw.SizedBox(height: 10),
//           _buildSummaryCards(reportData, customerSummaries.length),
//           pw.SizedBox(height: 20),
//
//           // Customer-wise Transactions with Amount Columns
//           _buildSectionTitle('Customer-wise Payment Transactions'),
//           pw.SizedBox(height: 10),
//           _buildTransactionTable(customerSummaries),
//           pw.SizedBox(height: 20),
//
//           _buildFooter(),
//         ],
//       ),
//     );
//
//     await _savePdf(pdf, 'Payment_Transaction_Report');
//   }
//
//
//   static pw.Widget _buildSummaryCards(Map<String, dynamic> data, int customerCount) {
//     return pw.Container(
//       padding: pw.EdgeInsets.all(16),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.blue50,
//         borderRadius: pw.BorderRadius.circular(8),
//         border: pw.Border.all(color: PdfColors.blue300),
//       ),
//       child: pw.Column(
//         children: [
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummaryItem('Customers', '$customerCount', PdfColors.blue900),
//               _buildSummaryItem('Total Invoices', '${data['totalInvoices']}', PdfColors.blue900),
//             ],
//           ),
//           pw.SizedBox(height: 15),
//           pw.Divider(color: PdfColors.blue300),
//           pw.SizedBox(height: 15),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummaryItem('Total Amount', '₹${AppUtil.formatCurrency(data['totalAmount'])}', PdfColors.blue900),
//               _buildSummaryItem('Received', '₹${AppUtil.formatCurrency(data['receivedAmount'])}', PdfColors.green900),
//               _buildSummaryItem('Pending', '₹${AppUtil.formatCurrency(data['pendingAmount'])}', PdfColors.orange900),
//             ],
//           ),
//           pw.SizedBox(height: 15),
//           pw.Divider(color: PdfColors.blue300),
//           pw.SizedBox(height: 10),
//           pw.Text(
//             'Collection Rate: ${data['paymentRate'].toStringAsFixed(1)}%',
//             style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   static pw.Widget _buildTransactionTable(List<CustomerSummary> customers) {
//     int srNo = 0;
//     double grandTotal = 0.0;
//     double grandReceived = 0.0;
//     double grandPending = 0.0;
//
//     // Calculate grand totals
//     for (var customer in customers) {
//       grandTotal += customer.totalAmount;
//       grandReceived += customer.receivedAmount;
//       grandPending += customer.pendingAmount;
//     }
//
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(4),
//       ),
//       child: pw.Table(
//         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//         columnWidths: {
//           0: pw.FlexColumnWidth(0.6),
//           1: pw.FlexColumnWidth(2),
//           2: pw.FlexColumnWidth(1.5),
//           3: pw.FlexColumnWidth(1.5),
//           4: pw.FlexColumnWidth(1.5),
//           5: pw.FlexColumnWidth(1.2),
//           6: pw.FlexColumnWidth(1.5),
//         },
//         children: [
//           // Header Row
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//             children: [
//               _buildTableCell('Sr.', isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Customer Name', isHeader: true),
//               _buildTableCell('Total Amount', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Received', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Pending', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell("Invoice'\s", isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Payment %', isHeader: true, align: pw.TextAlign.right),
//             ],
//           ),
//           // Data Rows
//           ...customers.map((customer) {
//             srNo++;
//             return pw.TableRow(
//               decoration: srNo % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
//               children: [
//                 _buildTableCell('$srNo', align: pw.TextAlign.center, fontSize: 9),
//                 _buildTableCell(customer.customerName, fontSize: 9),
//                 _buildTableCell('₹${AppUtil.formatCurrency(customer.totalAmount)}', align: pw.TextAlign.right, fontSize: 9),
//                 _buildTableCell('₹${AppUtil.formatCurrency(customer.receivedAmount)}', align: pw.TextAlign.right, fontSize: 9, isBold: true, color: PdfColors.green900),
//                 _buildTableCell('₹${AppUtil.formatCurrency(customer.pendingAmount)}', align: pw.TextAlign.right, fontSize: 9, color: PdfColors.orange900),
//                 _buildTableCell('${customer.invoiceCount}', align: pw.TextAlign.center, fontSize: 9),
//                 _buildTableCell('${customer.paymentPercentage.toStringAsFixed(1)}%', align: pw.TextAlign.right, fontSize: 9),
//               ],
//             );
//           }).toList(),
//           // Grand Total Row
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.blue100),
//             children: [
//               _buildTableCell('', align: pw.TextAlign.center),
//               _buildTableCell('GRAND TOTAL', isBold: true, fontSize: 10),
//               _buildTableCell('₹${AppUtil.formatCurrency(grandTotal)}', align: pw.TextAlign.right, isBold: true, fontSize: 10),
//               _buildTableCell('₹${AppUtil.formatCurrency(grandReceived)}', align: pw.TextAlign.right, isBold: true, fontSize: 10, color: PdfColors.green900),
//               _buildTableCell('₹${AppUtil.formatCurrency(grandPending)}', align: pw.TextAlign.right, isBold: true, fontSize: 10, color: PdfColors.orange900),
//               _buildTableCell('${customers.length}', align: pw.TextAlign.center, isBold: true, fontSize: 10),
//               _buildTableCell('${(grandTotal > 0 ? (grandReceived / grandTotal * 100) : 0.0).toStringAsFixed(1)}%', align: pw.TextAlign.right, isBold: true, fontSize: 10),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ NEW: Generate Purchase Payment Report
//   static Future<void> generatePurchasePaymentReport({
//     required List<PurchaseEntry> purchases,
//     required DateTime fromDate,
//     required DateTime toDate,
//     String? userCompanyName,
//   }) async {
//     final pdf = pw.Document();
//
//     // Load font
//     final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
//     final customFont = pw.Font.ttf(fontData.buffer.asByteData());
//
//     final theme = pw.ThemeData.withFont(
//       base: customFont,
//       bold: customFont,
//       italic: customFont,
//       boldItalic: customFont,
//     );
//
//     final vendorSummaries = VendorDataGrouper.groupByVendor(purchases);
//     final reportData = _calculatePurchaseReportData(purchases, vendorSummaries.length);
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(32),
//         theme: theme,
//         build: (context) => [
//           _buildPurchaseHeader(userCompanyName ?? 'Your Company', 'Purchase Payment Report', fromDate, toDate),
//           pw.SizedBox(height: 20),
//
//           // Summary Overview
//           _buildSectionTitle('Summary Overview'),
//           pw.SizedBox(height: 10),
//           _buildPurchaseSummaryCards(reportData, vendorSummaries.length),
//           pw.SizedBox(height: 20),
//
//           // Vendor-wise Transactions
//           _buildSectionTitle('Vendor-wise Payment Transactions'),
//           pw.SizedBox(height: 10),
//           _buildPurchaseTransactionTable(vendorSummaries),
//           pw.SizedBox(height: 20),
//
//           _buildFooter(),
//         ],
//       ),
//     );
//
//     await _savePdf(pdf, 'Purchase_Payment_Report');
//   }
//
//   static Map<String, dynamic> _calculatePurchaseReportData(List<PurchaseEntry> purchases, int vendorCount) {
//     double totalAmount = 0.0;
//     double paidAmount = 0.0;
//     double pendingAmount = 0.0;
//     int paidCount = 0;
//     int pendingCount = 0;
//     int partialCount = 0;
//
//     for (var purchase in purchases) {
//       totalAmount += purchase.totalAmount ?? 0.0;
//       paidAmount += purchase.paidAmount ?? 0.0;
//       pendingAmount += purchase.pendingAmount ?? 0.0;
//
//       switch (purchase.paymentStatus?.toLowerCase()) {
//         case 'paid':
//           paidCount++;
//           break;
//         case 'pending':
//           pendingCount++;
//           break;
//         case 'partial':
//           partialCount++;
//           break;
//       }
//     }
//
//     return {
//       'totalPurchases': purchases.length,
//       'totalAmount': totalAmount,
//       'paidAmount': paidAmount,
//       'pendingAmount': pendingAmount,
//       'paidCount': paidCount,
//       'pendingCount': pendingCount,
//       'partialCount': partialCount,
//       'paymentRate': totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0,
//     };
//   }
//
//   static pw.Widget _buildPurchaseSummaryCards(Map<String, dynamic> data, int vendorCount) {
//     return pw.Container(
//       padding: pw.EdgeInsets.all(16),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.orange50,
//         borderRadius: pw.BorderRadius.circular(8),
//         border: pw.Border.all(color: PdfColors.orange300),
//       ),
//       child: pw.Column(
//         children: [
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummaryItem('Vendors', '$vendorCount', PdfColors.orange900),
//               _buildSummaryItem('Total Purchases', '${data['totalPurchases']}', PdfColors.orange900),
//             ],
//           ),
//           pw.SizedBox(height: 15),
//           pw.Divider(color: PdfColors.orange300),
//           pw.SizedBox(height: 15),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummaryItem('Total Amount', '₹${AppUtil.formatCurrency(data['totalAmount'])}', PdfColors.orange900),
//               _buildSummaryItem('Paid', '₹${AppUtil.formatCurrency(data['paidAmount'])}', PdfColors.green900),
//               _buildSummaryItem('Pending', '₹${AppUtil.formatCurrency(data['pendingAmount'])}', PdfColors.red900),
//             ],
//           ),
//           pw.SizedBox(height: 15),
//           pw.Divider(color: PdfColors.orange300),
//           pw.SizedBox(height: 10),
//           pw.Text(
//             'Payment Rate: ${data['paymentRate'].toStringAsFixed(1)}%',
//             style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _buildPurchaseTransactionTable(List<VendorSummary> vendors) {
//     int srNo = 0;
//     double grandTotal = 0.0;
//     double grandPaid = 0.0;
//     double grandPending = 0.0;
//
//     for (var vendor in vendors) {
//       grandTotal += vendor.totalAmount;
//       grandPaid += vendor.paidAmount;
//       grandPending += vendor.pendingAmount;
//     }
//
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(4),
//       ),
//       child: pw.Table(
//         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//         columnWidths: {
//           0: pw.FlexColumnWidth(0.6),
//           1: pw.FlexColumnWidth(2),
//           2: pw.FlexColumnWidth(1.5),
//           3: pw.FlexColumnWidth(1.5),
//           4: pw.FlexColumnWidth(1.5),
//           5: pw.FlexColumnWidth(1.2),
//           6: pw.FlexColumnWidth(1.2),
//         },
//         children: [
//           // Header Row
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//             children: [
//               _buildTableCell('Sr.', isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Vendor Name', isHeader: true),
//               _buildTableCell('Total Amount', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Paid', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Pending', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell("Purchase's", isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Payment %', isHeader: true, align: pw.TextAlign.right),
//             ],
//           ),
//           // Data Rows
//           ...vendors.map((vendor) {
//             srNo++;
//             return pw.TableRow(
//               decoration: srNo % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
//               children: [
//                 _buildTableCell('$srNo', align: pw.TextAlign.center, fontSize: 9),
//                 _buildTableCell(vendor.vendorName, fontSize: 9),
//                 _buildTableCell('₹${AppUtil.formatCurrency(vendor.totalAmount)}', align: pw.TextAlign.right, fontSize: 9),
//                 _buildTableCell('₹${AppUtil.formatCurrency(vendor.paidAmount)}', align: pw.TextAlign.right, fontSize: 9, isBold: true, color: PdfColors.green900),
//                 _buildTableCell('₹${AppUtil.formatCurrency(vendor.pendingAmount)}', align: pw.TextAlign.right, fontSize: 9, color: PdfColors.orange900),
//                 _buildTableCell('${vendor.purchaseCount}', align: pw.TextAlign.center, fontSize: 9),
//                 _buildTableCell('${vendor.paymentPercentage.toStringAsFixed(1)}%', align: pw.TextAlign.right, fontSize: 9),
//               ],
//             );
//           }).toList(),
//           // Grand Total Row
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.orange100),
//             children: [
//               _buildTableCell('', align: pw.TextAlign.center),
//               _buildTableCell('GRAND TOTAL', isBold: true, fontSize: 10),
//               _buildTableCell('₹${AppUtil.formatCurrency(grandTotal)}', align: pw.TextAlign.right, isBold: true, fontSize: 10),
//               _buildTableCell('₹${AppUtil.formatCurrency(grandPaid)}', align: pw.TextAlign.right, isBold: true, fontSize: 10, color: PdfColors.green900),
//               _buildTableCell('₹${AppUtil.formatCurrency(grandPending)}', align: pw.TextAlign.right, isBold: true, fontSize: 10, color: PdfColors.orange900),
//               _buildTableCell('${vendors.length}', align: pw.TextAlign.center, isBold: true, fontSize: 10),
//               _buildTableCell('${(grandTotal > 0 ? (grandPaid / grandTotal * 100) : 0.0).toStringAsFixed(1)}%', align: pw.TextAlign.right, isBold: true, fontSize: 10),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _buildPurchaseHeader(String companyName, String reportTitle, DateTime fromDate, DateTime toDate) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900)),
//                 pw.SizedBox(height: 5),
//                 pw.Text(reportTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
//               ],
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(10),
//               decoration: pw.BoxDecoration(color: PdfColors.orange100, borderRadius: pw.BorderRadius.circular(8)),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.end,
//                 children: [
//                   pw.Text('Report Period', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
//                   pw.Text(DateFormat('dd MMM yyyy').format(fromDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
//                   pw.Text('to', style: pw.TextStyle(fontSize: 9)),
//                   pw.Text(DateFormat('dd MMM yyyy').format(toDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 10),
//         pw.Divider(thickness: 2, color: PdfColors.orange900),
//       ],
//     );
//   }
//
//   // Existing helper methods remain the same...
//   static pw.Widget _buildSectionTitle(String title) {
//     return pw.Container(
//       padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.blue50,
//         border: pw.Border(left: pw.BorderSide(width: 4, color: PdfColors.blue700)),
//       ),
//       child: pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
//     );
//   }
//
//   static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
//     return pw.Column(
//       children: [
//         pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
//         pw.SizedBox(height: 4),
//         pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: color)),
//       ],
//     );
//   }
//
//   static pw.Widget _buildTableCell(
//       String text, {
//         bool isHeader = false,
//         double fontSize = 10,
//         bool isBold = false,
//         pw.TextAlign align = pw.TextAlign.left,
//         PdfColor color = PdfColors.black,
//       }) {
//     return pw.Container(
//       padding: pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: fontSize,
//           fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: isHeader ? PdfColors.grey800 : color,
//         ),
//         textAlign: align,
//       ),
//     );
//   }
//
//   static pw.Widget _buildFooter() {
//     return pw.Column(
//       children: [
//         pw.Divider(thickness: 2, color: PdfColors.blue900),
//         pw.SizedBox(height: 10),
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Text('System generated payment transaction report', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
//             pw.Text('Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   static Future<void> _savePdf(pw.Document pdf, String reportType) async {
//     try {
//       final output = await getTemporaryDirectory();
//       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//       final fileName = '${reportType}_$timestamp.pdf';
//       final file = File('${output.path}/$fileName');
//
//       await file.writeAsBytes(await pdf.save());
//       print('✅ PDF saved at: ${file.path}');
//       await OpenFile.open(file.path);
//     } catch (e) {
//       print('❌ Error saving PDF: $e');
//       throw Exception('Failed to save PDF: $e');
//     }
//   }
//
//   static pw.Widget _buildHeader(String companyName, String reportTitle, DateTime fromDate, DateTime toDate) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
//                 pw.SizedBox(height: 5),
//                 pw.Text(reportTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
//               ],
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(10),
//               decoration: pw.BoxDecoration(color: PdfColors.blue100, borderRadius: pw.BorderRadius.circular(8)),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.end,
//                 children: [
//                   pw.Text('Report Period', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
//                   pw.Text(DateFormat('dd MMM yyyy').format(fromDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
//                   pw.Text('to', style: pw.TextStyle(fontSize: 9)),
//                   pw.Text(DateFormat('dd MMM yyyy').format(toDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 10),
//         pw.Divider(thickness: 2, color: PdfColors.blue900),
//       ],
//     );
//   }
//
// // In PdfHelper class - make sure generateClientReport returns Future<File?>
//   static Future<File?> generateClientReport({
//     required List<dynamic> records,
//     required String customerName,
//     bool isInvoice = true,
//     DateTime? fromDate,
//     DateTime? toDate,
//     String? userCompanyName,
//   }) async {
//     final pdf = pw.Document();
//
//     // Load font
//     final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
//     final customFont = pw.Font.ttf(fontData.buffer.asByteData());
//
//     final theme = pw.ThemeData.withFont(
//       base: customFont,
//       bold: customFont,
//       italic: customFont,
//       boldItalic: customFont,
//     );
//
//     // Calculate report data
//     final reportData = _calculateClientReportData(records, isInvoice);
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(32),
//         theme: theme,
//         build: (context) => [
//           _buildClientHeader(
//             userCompanyName ?? 'Your Company',
//             '${isInvoice ? 'Customer' : 'Vendor'} Payment Report',
//             customerName,
//             fromDate ?? DateTime.now().subtract(const Duration(days: 365)),
//             toDate ?? DateTime.now(),
//           ),
//           pw.SizedBox(height: 20),
//
//           // Summary Overview
//           _buildSectionTitle('${isInvoice ? 'Customer' : 'Vendor'} Summary'),
//           pw.SizedBox(height: 10),
//           _buildClientSummaryCards(reportData, isInvoice),
//           pw.SizedBox(height: 20),
//
//           // Transaction Details
//           _buildSectionTitle('Transaction Details'),
//           pw.SizedBox(height: 10),
//           isInvoice
//               ? _buildClientInvoiceTable(records.cast<Invoice>(), customerName)
//               : _buildClientPurchaseTable(records.cast<PurchaseEntry>(), customerName),
//           pw.SizedBox(height: 20),
//
//           _buildFooter(),
//         ],
//       ),
//     );
//
//     return await _saveClientPdf(pdf, '${customerName.replaceAll(' ', '_')}_${isInvoice ? 'Customer' : 'Vendor'}_Report');
//   }
//
// // Make sure _saveClientPdf returns File?
//   static Future<File?> _saveClientPdf(pw.Document pdf, String fileName) async {
//     try {
//       final output = await getTemporaryDirectory();
//       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//       final finalFileName = '${fileName}_$timestamp.pdf';
//       final file = File('${output.path}/$finalFileName');
//
//       await file.writeAsBytes(await pdf.save());
//       print('✅ Client PDF saved at: ${file.path}');
//       return file;
//     } catch (e) {
//       print('❌ Error saving client PDF: $e');
//       return null;
//     }
//   }
//
// // Helper method to calculate client report data
//   static Map<String, dynamic> _calculateClientReportData(List<dynamic> records, bool isInvoice) {
//     double totalAmount = 0.0;
//     double paidReceivedAmount = 0.0;
//     double pendingAmount = 0.0;
//     int totalCount = records.length;
//     int paidCount = 0;
//     int pendingCount = 0;
//     int partialCount = 0;
//
//     for (var record in records) {
//       if (isInvoice) {
//         final invoice = record as Invoice;
//         totalAmount += invoice.totalAmount ?? 0.0;
//         paidReceivedAmount += invoice.receivedAmount ?? 0.0;
//         pendingAmount += invoice.pendingAmount ?? 0.0;
//
//         switch (invoice.status?.toLowerCase()) {
//           case 'paid':
//           case 'accepted':
//             paidCount++;
//             break;
//           case 'pending':
//             pendingCount++;
//             break;
//           case 'partial':
//             partialCount++;
//             break;
//         }
//       } else {
//         final purchase = record as PurchaseEntry;
//         totalAmount += purchase.totalAmount ?? 0.0;
//         paidReceivedAmount += purchase.paidAmount ?? 0.0;
//         pendingAmount += purchase.pendingAmount ?? 0.0;
//
//         switch (purchase.paymentStatus?.toLowerCase()) {
//           case 'paid':
//             paidCount++;
//             break;
//           case 'pending':
//             pendingCount++;
//             break;
//           case 'partial':
//             partialCount++;
//             break;
//         }
//       }
//     }
//
//     return {
//       'totalCount': totalCount,
//       'totalAmount': totalAmount,
//       'paidReceivedAmount': paidReceivedAmount,
//       'pendingAmount': pendingAmount,
//       'paidCount': paidCount,
//       'pendingCount': pendingCount,
//       'partialCount': partialCount,
//       'paymentRate': totalAmount > 0 ? (paidReceivedAmount / totalAmount * 100) : 0,
//     };
//   }
//
// // Client-specific header
//   static pw.Widget _buildClientHeader(String companyName, String reportTitle, String clientName, DateTime fromDate, DateTime toDate) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
//                 pw.SizedBox(height: 5),
//                 pw.Text(reportTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
//                 pw.SizedBox(height: 5),
//                 pw.Text(clientName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
//               ],
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(10),
//               decoration: pw.BoxDecoration(color: PdfColors.blue100, borderRadius: pw.BorderRadius.circular(8)),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.end,
//                 children: [
//                   pw.Text('Report Period', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
//                   pw.Text(DateFormat('dd MMM yyyy').format(fromDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
//                   pw.Text('to', style: pw.TextStyle(fontSize: 9)),
//                   pw.Text(DateFormat('dd MMM yyyy').format(toDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 10),
//         pw.Divider(thickness: 2, color: PdfColors.blue900),
//       ],
//     );
//   }
//
// // Client summary cards
//   static pw.Widget _buildClientSummaryCards(Map<String, dynamic> data, bool isInvoice) {
//     return pw.Container(
//       padding: pw.EdgeInsets.all(16),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.blue50,
//         borderRadius: pw.BorderRadius.circular(8),
//         border: pw.Border.all(color: PdfColors.blue300),
//       ),
//       child: pw.Column(
//         children: [
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummaryItem('Total ${isInvoice ? 'Invoices' : 'Purchases'}', '${data['totalCount']}', PdfColors.blue900),
//               _buildSummaryItem('Paid ${isInvoice ? 'Invoices' : 'Purchases'}', '${data['paidCount']}', PdfColors.green900),
//             ],
//           ),
//           pw.SizedBox(height: 15),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummaryItem('Pending ${isInvoice ? 'Invoices' : 'Purchases'}', '${data['pendingCount']}', PdfColors.orange900),
//               _buildSummaryItem('Partial ${isInvoice ? 'Invoices' : 'Purchases'}', '${data['partialCount']}', PdfColors.blue700),
//             ],
//           ),
//           pw.SizedBox(height: 15),
//           pw.Divider(color: PdfColors.blue300),
//           pw.SizedBox(height: 15),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummaryItem('Total Amount', '₹${AppUtil.formatCurrency(data['totalAmount'])}', PdfColors.blue900),
//               _buildSummaryItem(isInvoice ? 'Received' : 'Paid', '₹${AppUtil.formatCurrency(data['paidReceivedAmount'])}', PdfColors.green900),
//               _buildSummaryItem('Pending', '₹${AppUtil.formatCurrency(data['pendingAmount'])}', PdfColors.orange900),
//             ],
//           ),
//           pw.SizedBox(height: 15),
//           pw.Divider(color: PdfColors.blue300),
//           pw.SizedBox(height: 10),
//           pw.Text(
//             '${isInvoice ? 'Collection' : 'Payment'} Rate: ${data['paymentRate'].toStringAsFixed(1)}%',
//             style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
//           ),
//         ],
//       ),
//     );
//   }
//
// // Client invoice table
//   static pw.Widget _buildClientInvoiceTable(List<Invoice> invoices, String customerName) {
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(4),
//       ),
//       child: pw.Table(
//         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//         columnWidths: {
//           0: pw.FlexColumnWidth(1),
//           1: pw.FlexColumnWidth(1.2),
//           2: pw.FlexColumnWidth(1),
//           3: pw.FlexColumnWidth(1),
//           4: pw.FlexColumnWidth(1),
//           5: pw.FlexColumnWidth(1.2),
//         },
//         children: [
//           // Header Row
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//             children: [
//               _buildTableCell('Invoice ID', isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Date', isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Total Amount', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Received', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Pending', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Status', isHeader: true, align: pw.TextAlign.center),
//             ],
//           ),
//           // Data Rows
//           ...invoices.map((invoice) {
//             return pw.TableRow(
//               decoration: pw.BoxDecoration(color: PdfColors.white),
//               children: [
//                 _buildTableCell('INV-${invoice.invoiceId}', align: pw.TextAlign.center, fontSize: 9),
//                 _buildTableCell(DateFormat('dd/MM/yyyy').format(invoice.issueDate ?? DateTime.now()), align: pw.TextAlign.center, fontSize: 9),
//                 _buildTableCell('₹${AppUtil.formatCurrency(invoice.totalAmount ?? 0)}', align: pw.TextAlign.right, fontSize: 9),
//                 _buildTableCell('₹${AppUtil.formatCurrency(invoice.receivedAmount ?? 0)}', align: pw.TextAlign.right, fontSize: 9, color: PdfColors.green900),
//                 _buildTableCell('₹${AppUtil.formatCurrency(invoice.pendingAmount ?? 0)}', align: pw.TextAlign.right, fontSize: 9, color: PdfColors.orange900),
//                 _buildTableCell(
//                   invoice.status ?? 'Pending',
//                   align: pw.TextAlign.center,
//                   fontSize: 9,
//                   color: _getStatusPdfColor(invoice.status ?? 'Pending'),
//                   isBold: true,
//                 ),
//               ],
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
// // Client purchase table
//   static pw.Widget _buildClientPurchaseTable(List<PurchaseEntry> purchases, String vendorName) {
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(4),
//       ),
//       child: pw.Table(
//         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//         columnWidths: {
//           0: pw.FlexColumnWidth(1),
//           1: pw.FlexColumnWidth(1.2),
//           2: pw.FlexColumnWidth(1),
//           3: pw.FlexColumnWidth(1),
//           4: pw.FlexColumnWidth(1),
//           5: pw.FlexColumnWidth(1.2),
//         },
//         children: [
//           // Header Row
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//             children: [
//               _buildTableCell('Purchase ID', isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Date', isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Total Amount', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Paid', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Pending', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Status', isHeader: true, align: pw.TextAlign.center),
//             ],
//           ),
//           // Data Rows
//           ...purchases.map((purchase) {
//             return pw.TableRow(
//               decoration: pw.BoxDecoration(color: PdfColors.white),
//               children: [
//                 _buildTableCell('PUR-${purchase.purchaseId}', align: pw.TextAlign.center, fontSize: 9),
//                 _buildTableCell(DateFormat('dd/MM/yyyy').format(purchase.purchaseDate ?? DateTime.now()), align: pw.TextAlign.center, fontSize: 9),
//                 _buildTableCell('₹${AppUtil.formatCurrency(purchase.totalAmount ?? 0)}', align: pw.TextAlign.right, fontSize: 9),
//                 _buildTableCell('₹${AppUtil.formatCurrency(purchase.paidAmount ?? 0)}', align: pw.TextAlign.right, fontSize: 9, color: PdfColors.green900),
//                 _buildTableCell('₹${AppUtil.formatCurrency(purchase.pendingAmount ?? 0)}', align: pw.TextAlign.right, fontSize: 9, color: PdfColors.orange900),
//                 _buildTableCell(
//                   purchase.paymentStatus ?? 'Pending',
//                   align: pw.TextAlign.center,
//                   fontSize: 9,
//                   color: _getStatusPdfColor(purchase.paymentStatus ?? 'Pending'),
//                   isBold: true,
//                 ),
//               ],
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
// // Helper method to get status color for PDF
//   static PdfColor _getStatusPdfColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'paid':
//       case 'accepted':
//         return PdfColors.green900;
//       case 'pending':
//         return PdfColors.orange900;
//       case 'partial':
//         return PdfColors.blue900;
//       case 'overdue':
//         return PdfColors.red900;
//       default:
//         return PdfColors.grey900;
//     }
//   }
//
//
//
// }
//
//
// // ==================== CUSTOMER SUMMARY MODEL ====================
// class CustomerSummary {
//   final String customerName;
//   final int invoiceCount;
//   final double totalAmount;
//   final double receivedAmount;
//   final double pendingAmount;
//   final List<String> invoiceIds;
//   final List<String> statuses;
//
//   CustomerSummary({
//     required this.customerName,
//     required this.invoiceCount,
//     required this.totalAmount,
//     required this.receivedAmount,
//     required this.pendingAmount,
//     required this.invoiceIds,
//     required this.statuses,
//   });
//
//   String get overallStatus {
//     if (pendingAmount <= 0) return 'PAID';
//     if (receivedAmount <= 0) return 'PENDING';
//     return 'PARTIAL';
//   }
//
//   double get paymentPercentage => totalAmount > 0 ? (receivedAmount / totalAmount * 100) : 0.0;
// }
//
// // ==================== CUSTOMER DATA GROUPING UTILITY ====================
// class CustomerDataGrouper {
//   static List<CustomerSummary> groupByCustomer(List<Invoice> invoices) {
//     Map<String, List<Invoice>> grouped = {};
//
//     // Group invoices by customer name (case-insensitive and trim whitespace)
//     for (var invoice in invoices) {
//       String customerName = (invoice.customerName ?? 'Unknown Customer').trim();
//       String normalizedName = customerName.toLowerCase();
//
//       // Find if customer already exists (case-insensitive match)
//       String? existingKey;
//       for (var key in grouped.keys) {
//         if (key.toLowerCase() == normalizedName) {
//           existingKey = key;
//           break;
//         }
//       }
//
//       if (existingKey != null) {
//         grouped[existingKey]!.add(invoice);
//       } else {
//         grouped[customerName] = [invoice];
//       }
//     }
//
//     // Create customer summaries - ONE PER CUSTOMER
//     List<CustomerSummary> summaries = [];
//     grouped.forEach((customerName, customerInvoices) {
//       double total = 0.0;
//       double received = 0.0;
//       double pending = 0.0;
//       List<String> invoiceIds = [];
//       List<String> statuses = [];
//
//       for (var inv in customerInvoices) {
//         total += inv.totalAmount ?? 0.0;
//         received += inv.receivedAmount ?? 0.0;
//         pending += inv.pendingAmount ?? 0.0;
//         invoiceIds.add('INV-${inv.invoiceId ?? "N/A"}');
//         statuses.add(inv.status ?? 'Unknown');
//       }
//
//       summaries.add(CustomerSummary(
//         customerName: customerName,
//         invoiceCount: customerInvoices.length,
//         totalAmount: total,
//         receivedAmount: received,
//         pendingAmount: pending,
//         invoiceIds: invoiceIds,
//         statuses: statuses,
//       ));
//     });
//
//     // Sort by total amount descending (highest to lowest)
//     summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
//     return summaries;
//   }
// }
//
//
// // ✅ NEW: Vendor Summary Model (similar to CustomerSummary)
// class VendorSummary {
//   final String vendorName;
//   final int purchaseCount;
//   final double totalAmount;
//   final double paidAmount;
//   final double pendingAmount;
//   final List<String> purchaseIds;
//   final List<String> statuses;
//
//   VendorSummary({
//     required this.vendorName,
//     required this.purchaseCount,
//     required this.totalAmount,
//     required this.paidAmount,
//     required this.pendingAmount,
//     required this.purchaseIds,
//     required this.statuses,
//   });
//
//   String get overallStatus {
//     if (pendingAmount <= 0) return 'PAID';
//     if (paidAmount <= 0) return 'PENDING';
//     return 'PARTIAL';
//   }
//
//   double get paymentPercentage => totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0.0;
// }
//
// // ✅ NEW: Vendor Data Grouping Utility
// class VendorDataGrouper {
//   static List<VendorSummary> groupByVendor(List<PurchaseEntry> purchases) {
//     Map<String, List<PurchaseEntry>> grouped = {};
//
//     // Group purchases by vendor name (case-insensitive and trim whitespace)
//     for (var purchase in purchases) {
//       String vendorName = (purchase.vendorName ?? 'Unknown Vendor').trim();
//       String normalizedName = vendorName.toLowerCase();
//
//       // Find if vendor already exists (case-insensitive match)
//       String? existingKey;
//       for (var key in grouped.keys) {
//         if (key.toLowerCase() == normalizedName) {
//           existingKey = key;
//           break;
//         }
//       }
//
//       if (existingKey != null) {
//         grouped[existingKey]!.add(purchase);
//       } else {
//         grouped[vendorName] = [purchase];
//       }
//     }
//
//     // Create vendor summaries - ONE PER VENDOR
//     List<VendorSummary> summaries = [];
//     grouped.forEach((vendorName, vendorPurchases) {
//       double total = 0.0;
//       double paid = 0.0;
//       double pending = 0.0;
//       List<String> purchaseIds = [];
//       List<String> statuses = [];
//
//       for (var pur in vendorPurchases) {
//         total += pur.totalAmount ?? 0.0;
//         paid += pur.paidAmount ?? 0.0;
//         pending += pur.pendingAmount ?? 0.0;
//         purchaseIds.add('PUR-${pur.purchaseId ?? "N/A"}');
//         statuses.add(pur.paymentStatus ?? 'Unknown');
//       }
//
//       summaries.add(VendorSummary(
//         vendorName: vendorName,
//         purchaseCount: vendorPurchases.length,
//         totalAmount: total,
//         paidAmount: paid,
//         pendingAmount: pending,
//         purchaseIds: purchaseIds,
//         statuses: statuses,
//       ));
//     });
//
//     // Sort by total amount descending (highest to lowest)
//     summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
//     return summaries;
//   }
// }



///18/12 history
///
///
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GetYourInvoice/services/remote_service.dart';
import 'package:GetYourInvoice/utils/pdf_helper.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import '../constant/app_constant.dart';
import '../model/model.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'controller.dart';

// payment_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// payment_details_controller.dart

// payment_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:pdf/widgets.dart' as pw;


class PaymentDetailsController extends GetxController {
  var invoices = <Invoice>[].obs;
  var purchases = <PurchaseEntry>[].obs;  // ✅ NEW
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  // ✅ NEW: Toggle between Invoice and Purchase view
  var selectedTab = 'Invoice'.obs;  // 'Invoice' or 'Purchase'

  // Report Generation State
  var selectedExportFormat = 'PDF'.obs;
  var fromDate = Rx<DateTime?>(null);
  var toDate = Rx<DateTime?>(null);
  var isGeneratingReport = false.obs;
  var companyName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadCompanyName();
    // ✅ FIX: Set default dates based on Demo Mode
    if (AppConstants.isDemo.value) {
      // Demo Mode: Default to the allowed range (1990-1992)
      fromDate.value = DateTime(1990, 1, 1);
      toDate.value = DateTime(1992, 12, 31);
    } else {
      // Normal Mode: Default to last 30 days
      toDate.value = DateTime.now();
      fromDate.value = DateTime.now().subtract(const Duration(days: 30));
    }
  }

  // ✅ NEW: Load both invoices and purchases
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        showCustomSnackbar(
          title: "Error",
          message: "User not logged in",
          baseColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
        return;
      }

      // Load invoices
      List<Invoice> allInvoices = await GoogleSheetService.getInvoices(type: "INV");
      if (allInvoices.isEmpty) {
        allInvoices = await GoogleSheetService.getInvoices();
      }
      invoices.value = allInvoices.where((inv) => inv.userId == currentUserId).toList();

      // ✅ Load purchases
      List<PurchaseEntry> allPurchases = await GoogleSheetService.getPurchasesList();
      purchases.value = allPurchases.where((pur) => pur.userId == currentUserId).toList();

      print("✅ Loaded ${invoices.length} invoices and ${purchases.length} purchases");
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load data: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade700),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCompanyName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String companyId = await sharedPreferencesHelper.getPrefData("CompanyId") ?? "";
        if (companyId.isNotEmpty) {
          final companyDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("companies")
              .doc(companyId)
              .get();

          if (companyDoc.exists) {
            companyName.value = companyDoc.data()?['companyName'];
          }
        }
      }
    } catch (e) {
      print("Error loading company name: $e");
    }
  }

  // ✅ NEW: Switch between Invoice and Purchase tabs
  void switchTab(String tab) {
    selectedTab.value = tab;
  }

  // ✅ NEW: Get filtered customer summaries for invoices
  List<CustomerSummary> getFilteredInvoiceCustomerSummaries() {
    final customerSummaries = CustomerDataGrouper.groupByCustomer(invoices);

    if (searchQuery.value.isEmpty) {
      return customerSummaries;
    }

    return customerSummaries.where((customer) {
      final query = searchQuery.value.toLowerCase();
      return customer.customerName.toLowerCase().contains(query) ||
          customer.invoiceIds.any((id) => id.toLowerCase().contains(query));
    }).toList();
  }

  // ✅ NEW: Get filtered vendor summaries for purchases
  List<VendorSummary> getFilteredPurchaseVendorSummaries() {
    final vendorSummaries = VendorDataGrouper.groupByVendor(purchases);

    if (searchQuery.value.isEmpty) {
      return vendorSummaries;
    }

    return vendorSummaries.where((vendor) {
      final query = searchQuery.value.toLowerCase();
      return vendor.vendorName.toLowerCase().contains(query) ||
          vendor.purchaseIds.any((id) => id.toLowerCase().contains(query));
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void selectExportFormat(String format) {
    selectedExportFormat.value = format;
  }

  void setFromDate(DateTime date) {
    fromDate.value = date;
    if (toDate.value != null && date.isAfter(toDate.value!)) {
      toDate.value = date;
    }
  }

  void setToDate(DateTime date) {
    toDate.value = date;
    if (fromDate.value != null && date.isBefore(fromDate.value!)) {
      fromDate.value = date;
    }
  }

  List<Invoice> getFilteredInvoices() {
    if (fromDate.value == null || toDate.value == null) {
      return invoices;
    }

    return invoices.where((invoice) {
      final invoiceDate = invoice.issueDate ?? DateTime.now();
      return invoiceDate.isAfter(fromDate.value!) &&
          invoiceDate.isBefore(toDate.value!.add(const Duration(days: 1)));
    }).toList();
  }

  // ✅ NEW: Get filtered purchases
  List<PurchaseEntry> getFilteredPurchases() {
    if (fromDate.value == null || toDate.value == null) {
      return purchases;
    }

    return purchases.where((purchase) {
      final purchaseDate = purchase.purchaseDate ?? DateTime.now();
      return purchaseDate.isAfter(fromDate.value!) &&
          purchaseDate.isBefore(toDate.value!.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> generateReport() async {
    try {
      if (fromDate.value == null || toDate.value == null) {
        Get.snackbar(
          'Validation Error',
          'Please select both from and to dates',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          icon: const Icon(Icons.warning_amber, color: Colors.orange),
        );
        return;
      }

      isGeneratingReport.value = true;

      // ✅ Generate report based on selected tab
      if (selectedTab.value == 'Invoice') {
        final filteredInvoices = getFilteredInvoices();

        if (filteredInvoices.isEmpty) {
          Get.snackbar(
            'No Data',
            'No invoices found for the selected date range',
            backgroundColor: Colors.blue.shade100,
            colorText: Colors.blue.shade800,
            icon: const Icon(Icons.info_outline, color: Colors.blue),
          );
          isGeneratingReport.value = false;
          return;
        }

        await Future.delayed(const Duration(seconds: 1));

        switch (selectedExportFormat.value) {
          case 'PDF':
            await _generateInvoicePDFReport(filteredInvoices);
            break;
          case 'Excel':
            await _generateInvoiceExcelReport(filteredInvoices);
            break;
        }
      } else {
        // ✅ Purchase report
        final filteredPurchases = getFilteredPurchases();

        if (filteredPurchases.isEmpty) {
          Get.snackbar(
            'No Data',
            'No purchases found for the selected date range',
            backgroundColor: Colors.blue.shade100,
            colorText: Colors.blue.shade800,
            icon: const Icon(Icons.info_outline, color: Colors.blue),
          );
          isGeneratingReport.value = false;
          return;
        }

        await Future.delayed(const Duration(seconds: 1));

        switch (selectedExportFormat.value) {
          case 'PDF':
            await _generatePurchasePDFReport(filteredPurchases);
            break;
          case 'Excel':
            await _generatePurchaseExcelReport(filteredPurchases);
            break;
        }
      }

      Get.back();

      Get.snackbar(
        'Success',
        'Payment Report generated successfully!',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate report: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    } finally {
      isGeneratingReport.value = false;
    }
  }

  // Invoice report methods (existing)
  Future<void> _generateInvoicePDFReport(List<Invoice> invoices) async {
    print("📄 Generating Invoice PDF report with ${invoices.length} invoices");

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? companyName = user?.displayName ?? 'Your Company';

      await PdfHelper.generatePaymentReport(
        invoices: invoices,
        fromDate: fromDate.value!,
        toDate: toDate.value!,
        userCompanyName: companyName,
      );

      print("✅ PDF Report generated successfully!");
    } catch (e) {
      print("❌ Error generating PDF: $e");
      throw e;
    }
  }

  Future<void> _generateInvoiceExcelReport(List<Invoice> invoices) async {
    print("📊 Generating Invoice Excel report with ${invoices.length} invoices");

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? companyName = user?.displayName ?? 'Your Company';

      await ExcelReportService.generatePaymentReport(
        invoices: invoices,
        fromDate: fromDate.value!,
        toDate: toDate.value!,
        userCompanyName: companyName,
      );

      print("✅ Excel Report generated successfully!");
    } catch (e) {
      print("❌ Error generating Excel: $e");
      throw e;
    }
  }

  // ✅ NEW: Purchase report methods
  Future<void> _generatePurchasePDFReport(List<PurchaseEntry> purchases) async {
    print("📄 Generating Purchase PDF report with ${purchases.length} purchases");

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? companyName = user?.displayName ?? 'Your Company';

      await PdfHelper.generatePurchasePaymentReport(
        purchases: purchases,
        fromDate: fromDate.value!,
        toDate: toDate.value!,
        userCompanyName: companyName,
      );

      print("✅ Purchase PDF Report generated successfully!");
    } catch (e) {
      print("❌ Error generating Purchase PDF: $e");
      throw e;
    }
  }

  Future<void> _generatePurchaseExcelReport(List<PurchaseEntry> purchases) async {
    print("📊 Generating Purchase Excel report with ${purchases.length} purchases");

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? companyName = user?.displayName ?? 'Your Company';

      await ExcelReportService.generatePurchasePaymentReport(
        purchases: purchases,
        fromDate: fromDate.value!,
        toDate: toDate.value!,
        userCompanyName: companyName,
      );

      print("✅ Purchase Excel Report generated successfully!");
    } catch (e) {
      print("❌ Error generating Purchase Excel: $e");
      throw e;
    }
  }

  String getFormattedDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('dd MMM yyyy').format(date);
  }
}

class ReportDataCalculator {
  static Map<String, dynamic> calculate(List<Invoice> invoices) {
    double totalAmount = 0.0;
    double receivedAmount = 0.0;
    double pendingAmount = 0.0;
    int paidCount = 0;
    int pendingCount = 0;
    int overdueCount = 0;
    int partialCount = 0;

    // Calculate amounts by status
    double paidAmount = 0.0;
    double pendingAmountByStatus = 0.0;
    double overdueAmount = 0.0;
    double partialAmount = 0.0;

    for (var invoice in invoices) {
      totalAmount += invoice.totalAmount ?? 0.0;
      receivedAmount += invoice.receivedAmount ?? 0.0;
      pendingAmount += invoice.pendingAmount ?? 0.0;

      switch (invoice.status?.toLowerCase()) {
        case 'paid':
        case 'accepted':
          paidCount++;
          paidAmount += invoice.totalAmount ?? 0.0;
          break;
        case 'pending':
          pendingCount++;
          pendingAmountByStatus += invoice.totalAmount ?? 0.0;
          break;
        case 'overdue':
          overdueCount++;
          overdueAmount += invoice.totalAmount ?? 0.0;
          break;
        case 'partial':
          partialCount++;
          partialAmount += invoice.totalAmount ?? 0.0;
          break;
      }
    }

    return {
      'totalInvoices': invoices.length,
      'totalAmount': totalAmount,
      'receivedAmount': receivedAmount,
      'pendingAmount': pendingAmount,
      'paidCount': paidCount,
      'pendingCount': pendingCount,
      'overdueCount': overdueCount,
      'partialCount': partialCount,
      'paidAmount': paidAmount,
      'pendingAmountByStatus': pendingAmountByStatus,
      'overdueAmount': overdueAmount,
      'partialAmount': partialAmount,
      'paymentRate': totalAmount > 0 ? (receivedAmount / totalAmount * 100) : 0,
    };
  }
}

// ==================== UPDATED EXCEL REPORT WITH AMOUNT COLUMNS ====================
class ExcelReportService {
  static Future<void> generatePaymentReport({
    required List<Invoice> invoices,
    required DateTime fromDate,
    required DateTime toDate,
    String? userCompanyName,
  }) async {
    var excel = Excel.createExcel();
    final customerSummaries = CustomerDataGrouper.groupByCustomer(invoices);
    final reportData = ReportDataCalculator.calculate(invoices);

    Sheet sheetObject = excel['Payment Transaction Report'];

    // Header
    _addReportHeader(sheetObject, userCompanyName, 'Payment Transaction Report', fromDate, toDate);

    // Summary Section
    sheetObject.appendRow([TextCellValue('SUMMARY OVERVIEW')]);
    sheetObject.appendRow([]);
    sheetObject.appendRow([TextCellValue('Total Customers'), IntCellValue(customerSummaries.length)]);
    sheetObject.appendRow([TextCellValue('Total Invoices'), IntCellValue(reportData['totalInvoices'])]);
    sheetObject.appendRow([TextCellValue('Total Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['totalAmount'])}')]);
    sheetObject.appendRow([TextCellValue('Received Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['receivedAmount'])}')]);
    sheetObject.appendRow([TextCellValue('Pending Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['pendingAmount'])}')]);
    sheetObject.appendRow([TextCellValue('Collection Rate'), TextCellValue('${reportData['paymentRate'].toStringAsFixed(1)}%')]);
    sheetObject.appendRow([]);

    // Customer-wise Transactions with Amount Columns
    sheetObject.appendRow([TextCellValue('CUSTOMER-WISE PAYMENT TRANSACTIONS')]);
    sheetObject.appendRow([
      TextCellValue('Sr.No'),
      TextCellValue('Date'),
      TextCellValue('Customer Name'),
      TextCellValue('Invoice Count'),
      TextCellValue('Total Amount'),
      TextCellValue('Received Amount'),
      TextCellValue('Pending Amount'),
      TextCellValue('Payment %'),
      TextCellValue('Invoice IDs'),
    ]);

    int srNo = 0;
    double grandTotal = 0.0;
    double grandReceived = 0.0;
    double grandPending = 0.0;

    for (var customer in customerSummaries) {
      srNo++;

      sheetObject.appendRow([
        IntCellValue(srNo),
        TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now())),
        TextCellValue(customer.customerName),
        IntCellValue(customer.invoiceCount),
        TextCellValue('₹${AppUtil.formatCurrency(customer.totalAmount)}'),
        TextCellValue('₹${AppUtil.formatCurrency(customer.receivedAmount)}'),
        TextCellValue('₹${AppUtil.formatCurrency(customer.pendingAmount)}'),
        TextCellValue('${customer.paymentPercentage.toStringAsFixed(1)}%'),
        TextCellValue(customer.invoiceIds.join(', ')),
      ]);

      grandTotal += customer.totalAmount;
      grandReceived += customer.receivedAmount;
      grandPending += customer.pendingAmount;
    }

    // Grand Total Row
    sheetObject.appendRow([]);
    sheetObject.appendRow([
      TextCellValue('GRAND TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      IntCellValue(reportData['totalInvoices']),
      TextCellValue('₹${AppUtil.formatCurrency(grandTotal)}'),
      TextCellValue('₹${AppUtil.formatCurrency(grandReceived)}'),
      TextCellValue('₹${AppUtil.formatCurrency(grandPending)}'),
      TextCellValue('${(grandTotal > 0 ? (grandReceived / grandTotal * 100) : 0.0).toStringAsFixed(1)}%'),
      TextCellValue(''),
    ]);

    await _saveExcel(excel, 'Payment_Transaction_Report');
  }

  // ✅ NEW: Generate Purchase Payment Report
  static Future<void> generatePurchasePaymentReport({
    required List<PurchaseEntry> purchases,
    required DateTime fromDate,
    required DateTime toDate,
    String? userCompanyName,
  }) async {
    var excel = Excel.createExcel();
    final vendorSummaries = VendorDataGrouper.groupByVendor(purchases);
    final reportData = _calculatePurchaseReportData(purchases);

    Sheet sheetObject = excel['Purchase Payment Report'];

    // Header
    _addReportHeader(sheetObject, userCompanyName, 'Purchase Payment Report', fromDate, toDate);

    // Summary Section
    sheetObject.appendRow([TextCellValue('SUMMARY OVERVIEW')]);
    sheetObject.appendRow([]);
    sheetObject.appendRow([TextCellValue('Total Vendors'), IntCellValue(vendorSummaries.length)]);
    sheetObject.appendRow([TextCellValue('Total Purchases'), IntCellValue(reportData['totalPurchases'])]);
    sheetObject.appendRow([TextCellValue('Total Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['totalAmount'])}')]);
    sheetObject.appendRow([TextCellValue('Paid Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['paidAmount'])}')]);
    sheetObject.appendRow([TextCellValue('Pending Amount'), TextCellValue('₹${AppUtil.formatCurrency(reportData['pendingAmount'])}')]);
    sheetObject.appendRow([TextCellValue('Payment Rate'), TextCellValue('${reportData['paymentRate'].toStringAsFixed(1)}%')]);
    sheetObject.appendRow([]);

    // Vendor-wise Transactions
    sheetObject.appendRow([TextCellValue('VENDOR-WISE PAYMENT TRANSACTIONS')]);
    sheetObject.appendRow([
      TextCellValue('Sr.No'),
      TextCellValue('Date'),
      TextCellValue('Vendor Name'),
      TextCellValue('Purchase Count'),
      TextCellValue('Total Amount'),
      TextCellValue('Paid Amount'),
      TextCellValue('Pending Amount'),
      TextCellValue('Payment %'),
      TextCellValue('Purchase IDs'),
    ]);

    int srNo = 0;
    double grandTotal = 0.0;
    double grandPaid = 0.0;
    double grandPending = 0.0;

    for (var vendor in vendorSummaries) {
      srNo++;

      sheetObject.appendRow([
        IntCellValue(srNo),
        TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now())),
        TextCellValue(vendor.vendorName),
        IntCellValue(vendor.purchaseCount),
        TextCellValue('₹${AppUtil.formatCurrency(vendor.totalAmount)}'),
        TextCellValue('₹${AppUtil.formatCurrency(vendor.paidAmount)}'),
        TextCellValue('₹${AppUtil.formatCurrency(vendor.pendingAmount)}'),
        TextCellValue('${vendor.paymentPercentage.toStringAsFixed(1)}%'),
        TextCellValue(vendor.purchaseIds.join(', ')),
      ]);

      grandTotal += vendor.totalAmount;
      grandPaid += vendor.paidAmount;
      grandPending += vendor.pendingAmount;
    }

    // Grand Total Row
    sheetObject.appendRow([]);
    sheetObject.appendRow([
      TextCellValue('GRAND TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      IntCellValue(reportData['totalPurchases']),
      TextCellValue('₹${AppUtil.formatCurrency(grandTotal)}'),
      TextCellValue('₹${AppUtil.formatCurrency(grandPaid)}'),
      TextCellValue('₹${AppUtil.formatCurrency(grandPending)}'),
      TextCellValue('${(grandTotal > 0 ? (grandPaid / grandTotal * 100) : 0.0).toStringAsFixed(1)}%'),
      TextCellValue(''),
    ]);

    await _saveExcel(excel, 'Purchase_Payment_Report');
  }

  static Map<String, dynamic> _calculatePurchaseReportData(List<PurchaseEntry> purchases) {
    double totalAmount = 0.0;
    double paidAmount = 0.0;
    double pendingAmount = 0.0;

    for (var purchase in purchases) {
      totalAmount += purchase.totalAmount ?? 0.0;
      paidAmount += purchase.paidAmount ?? 0.0;
      pendingAmount += purchase.pendingAmount ?? 0.0;
    }

    return {
      'totalPurchases': purchases.length,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'paymentRate': totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0,
    };
  }

  static void _addReportHeader(Sheet sheet, String? companyName, String title, DateTime fromDate, DateTime toDate) {
    sheet.appendRow([TextCellValue(companyName ?? 'Your Company')]);
    sheet.appendRow([TextCellValue(title)]);
    sheet.appendRow([TextCellValue('Period: ${DateFormat('dd MMM yyyy').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}')]);
    sheet.appendRow([TextCellValue('Generated on: ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}')]);
    sheet.appendRow([]);
  }

  static Future<void> _saveExcel(Excel excel, String reportType) async {
    try {
      final output = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '${reportType}_$timestamp.xlsx';
      final file = File('${output.path}/$fileName');

      final fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        print('✅ Excel saved at: ${file.path}');
        await OpenFile.open(file.path);
      }
    } catch (e) {
      print('❌ Error saving Excel: $e');
      throw Exception('Failed to save Excel: $e');
    }
  }

}

// ==================== UPDATED PDF REPORT WITH AMOUNT COLUMNS ====================
class PdfHelper {
  static Future<void> generatePaymentReport({
    required List<Invoice> invoices,
    required DateTime fromDate,
    required DateTime toDate,
    String? userCompanyName,
  }) async {
    final pdf = pw.Document();

    // Load font (same as InvoiceHelper - already supports ₹)
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final customFont = pw.Font.ttf(fontData.buffer.asByteData());

    final theme = pw.ThemeData.withFont(
      base: customFont,
      bold: customFont,
      italic: customFont,
      boldItalic: customFont,
    );

    final customerSummaries = CustomerDataGrouper.groupByCustomer(invoices);
    final reportData = ReportDataCalculator.calculate(invoices);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        theme: theme,
        build: (context) => [
          _buildHeader(userCompanyName ?? 'Your Company', 'Payment Transaction Report', fromDate, toDate),
          pw.SizedBox(height: 20),

          // Summary Overview
          _buildSectionTitle('Summary Overview'),
          pw.SizedBox(height: 10),
          _buildSummaryCards(reportData, customerSummaries.length),
          pw.SizedBox(height: 20),

          // Customer-wise Transactions with Amount Columns
          _buildSectionTitle('Customer-wise Payment Transactions'),
          pw.SizedBox(height: 10),
          _buildTransactionTable(customerSummaries),
          pw.SizedBox(height: 20),

          _buildFooter(),
        ],
      ),
    );

    await _savePdf(pdf, 'Payment_Transaction_Report');
  }

  static pw.Widget _buildSummaryCards(Map<String, dynamic> data, int customerCount) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue300),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Customers', '$customerCount', PdfColors.blue900),
              _buildSummaryItem('Total Invoices', '${data['totalInvoices']}', PdfColors.blue900),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColors.blue300),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Amount', '₹${AppUtil.formatCurrency(data['totalAmount'])}', PdfColors.blue900),
              _buildSummaryItem('Received', '₹${AppUtil.formatCurrency(data['receivedAmount'])}', PdfColors.green900),
              _buildSummaryItem('Pending', '₹${AppUtil.formatCurrency(data['pendingAmount'])}', PdfColors.orange900),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColors.blue300),
          pw.SizedBox(height: 10),
          pw.Text(
            'Collection Rate: ${data['paymentRate'].toStringAsFixed(1)}%',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
          ),
        ],
      ),
    );
  }


  static pw.Widget _buildTransactionTable(List<CustomerSummary> customers) {
    int srNo = 0;
    double grandTotal = 0.0;
    double grandReceived = 0.0;
    double grandPending = 0.0;

    // Calculate grand totals
    for (var customer in customers) {
      grandTotal += customer.totalAmount;
      grandReceived += customer.receivedAmount;
      grandPending += customer.pendingAmount;
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
        columnWidths: {
          0: pw.FlexColumnWidth(0.6),
          1: pw.FlexColumnWidth(2),
          2: pw.FlexColumnWidth(1.5),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(1.5),
          5: pw.FlexColumnWidth(1.2),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          // Header Row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              _buildTableCell('Sr.', isHeader: true, align: pw.TextAlign.center),
              _buildTableCell('Customer Name', isHeader: true),
              _buildTableCell('Total Amount', isHeader: true, align: pw.TextAlign.right),
              _buildTableCell('Received', isHeader: true, align: pw.TextAlign.right),
              _buildTableCell('Pending', isHeader: true, align: pw.TextAlign.right),
              _buildTableCell("Invoice'\s", isHeader: true, align: pw.TextAlign.center),
              _buildTableCell('Payment %', isHeader: true, align: pw.TextAlign.right),
            ],
          ),
          // Data Rows
          ...customers.map((customer) {
            srNo++;
            return pw.TableRow(
              decoration: srNo % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
              children: [
                _buildTableCell('$srNo', align: pw.TextAlign.center, fontSize: 9),
                _buildTableCell(customer.customerName, fontSize: 9),
                _buildTableCell('₹${AppUtil.formatCurrency(customer.totalAmount)}', align: pw.TextAlign.right, fontSize: 9),
                _buildTableCell('₹${AppUtil.formatCurrency(customer.receivedAmount)}', align: pw.TextAlign.right, fontSize: 9, isBold: true, color: PdfColors.green900),
                _buildTableCell('₹${AppUtil.formatCurrency(customer.pendingAmount)}', align: pw.TextAlign.right, fontSize: 9, color: PdfColors.orange900),
                _buildTableCell('${customer.invoiceCount}', align: pw.TextAlign.center, fontSize: 9),
                _buildTableCell('${customer.paymentPercentage.toStringAsFixed(1)}%', align: pw.TextAlign.right, fontSize: 9),
              ],
            );
          }).toList(),
          // Grand Total Row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.blue100),
            children: [
              _buildTableCell('', align: pw.TextAlign.center),
              _buildTableCell('GRAND TOTAL', isBold: true, fontSize: 10),
              _buildTableCell('₹${AppUtil.formatCurrency(grandTotal)}', align: pw.TextAlign.right, isBold: true, fontSize: 10),
              _buildTableCell('₹${AppUtil.formatCurrency(grandReceived)}', align: pw.TextAlign.right, isBold: true, fontSize: 10, color: PdfColors.green900),
              _buildTableCell('₹${AppUtil.formatCurrency(grandPending)}', align: pw.TextAlign.right, isBold: true, fontSize: 10, color: PdfColors.orange900),
              _buildTableCell('${customers.length}', align: pw.TextAlign.center, isBold: true, fontSize: 10),
              _buildTableCell('${(grandTotal > 0 ? (grandReceived / grandTotal * 100) : 0.0).toStringAsFixed(1)}%', align: pw.TextAlign.right, isBold: true, fontSize: 10),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Generate Purchase Payment Report
  static Future<void> generatePurchasePaymentReport({
    required List<PurchaseEntry> purchases,
    required DateTime fromDate,
    required DateTime toDate,
    String? userCompanyName,
  }) async {
    final pdf = pw.Document();

    // Load font
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final customFont = pw.Font.ttf(fontData.buffer.asByteData());

    final theme = pw.ThemeData.withFont(
      base: customFont,
      bold: customFont,
      italic: customFont,
      boldItalic: customFont,
    );

    final vendorSummaries = VendorDataGrouper.groupByVendor(purchases);
    final reportData = _calculatePurchaseReportData(purchases, vendorSummaries.length);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        theme: theme,
        build: (context) => [
          _buildPurchaseHeader(userCompanyName ?? 'Your Company', 'Purchase Payment Report', fromDate, toDate),
          pw.SizedBox(height: 20),

          // Summary Overview
          _buildSectionTitle('Summary Overview'),
          pw.SizedBox(height: 10),
          _buildPurchaseSummaryCards(reportData, vendorSummaries.length),
          pw.SizedBox(height: 20),

          // Vendor-wise Transactions
          _buildSectionTitle('Vendor-wise Payment Transactions'),
          pw.SizedBox(height: 10),
          _buildPurchaseTransactionTable(vendorSummaries),
          pw.SizedBox(height: 20),

          _buildFooter(),
        ],
      ),
    );

    await _savePdf(pdf, 'Purchase_Payment_Report');
  }

  static Map<String, dynamic> _calculatePurchaseReportData(List<PurchaseEntry> purchases, int vendorCount) {
    double totalAmount = 0.0;
    double paidAmount = 0.0;
    double pendingAmount = 0.0;
    int paidCount = 0;
    int pendingCount = 0;
    int partialCount = 0;

    for (var purchase in purchases) {
      totalAmount += purchase.totalAmount ?? 0.0;
      paidAmount += purchase.paidAmount ?? 0.0;
      pendingAmount += purchase.pendingAmount ?? 0.0;

      switch (purchase.paymentStatus?.toLowerCase()) {
        case 'paid':
          paidCount++;
          break;
        case 'pending':
          pendingCount++;
          break;
        case 'partial':
          partialCount++;
          break;
      }
    }

    return {
      'totalPurchases': purchases.length,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'paidCount': paidCount,
      'pendingCount': pendingCount,
      'partialCount': partialCount,
      'paymentRate': totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0,
    };
  }

  static pw.Widget _buildPurchaseSummaryCards(Map<String, dynamic> data, int vendorCount) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.orange300),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Vendors', '$vendorCount', PdfColors.orange900),
              _buildSummaryItem('Total Purchases', '${data['totalPurchases']}', PdfColors.orange900),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColors.orange300),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Amount', '₹${AppUtil.formatCurrency(data['totalAmount'])}', PdfColors.orange900),
              _buildSummaryItem('Paid', '₹${AppUtil.formatCurrency(data['paidAmount'])}', PdfColors.green900),
              _buildSummaryItem('Pending', '₹${AppUtil.formatCurrency(data['pendingAmount'])}', PdfColors.red900),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColors.orange300),
          pw.SizedBox(height: 10),
          pw.Text(
            'Payment Rate: ${data['paymentRate'].toStringAsFixed(1)}%',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPurchaseTransactionTable(List<VendorSummary> vendors) {
    int srNo = 0;
    double grandTotal = 0.0;
    double grandPaid = 0.0;
    double grandPending = 0.0;

    for (var vendor in vendors) {
      grandTotal += vendor.totalAmount;
      grandPaid += vendor.paidAmount;
      grandPending += vendor.pendingAmount;
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
        columnWidths: {
          0: pw.FlexColumnWidth(0.6),
          1: pw.FlexColumnWidth(2),
          2: pw.FlexColumnWidth(1.5),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(1.5),
          5: pw.FlexColumnWidth(1.2),
          6: pw.FlexColumnWidth(1.2),
        },
        children: [
          // Header Row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              _buildTableCell('Sr.', isHeader: true, align: pw.TextAlign.center),
              _buildTableCell('Vendor Name', isHeader: true),
              _buildTableCell('Total Amount', isHeader: true, align: pw.TextAlign.right),
              _buildTableCell('Paid', isHeader: true, align: pw.TextAlign.right),
              _buildTableCell('Pending', isHeader: true, align: pw.TextAlign.right),
              _buildTableCell("Purchase's", isHeader: true, align: pw.TextAlign.center),
              _buildTableCell('Payment %', isHeader: true, align: pw.TextAlign.right),
            ],
          ),
          // Data Rows
          ...vendors.map((vendor) {
            srNo++;
            return pw.TableRow(
              decoration: srNo % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
              children: [
                _buildTableCell('$srNo', align: pw.TextAlign.center, fontSize: 9),
                _buildTableCell(vendor.vendorName, fontSize: 9),
                _buildTableCell('₹${AppUtil.formatCurrency(vendor.totalAmount)}', align: pw.TextAlign.right, fontSize: 9),
                _buildTableCell('₹${AppUtil.formatCurrency(vendor.paidAmount)}', align: pw.TextAlign.right, fontSize: 9, isBold: true, color: PdfColors.green900),
                _buildTableCell('₹${AppUtil.formatCurrency(vendor.pendingAmount)}', align: pw.TextAlign.right, fontSize: 9, color: PdfColors.orange900),
                _buildTableCell('${vendor.purchaseCount}', align: pw.TextAlign.center, fontSize: 9),
                _buildTableCell('${vendor.paymentPercentage.toStringAsFixed(1)}%', align: pw.TextAlign.right, fontSize: 9),
              ],
            );
          }).toList(),
          // Grand Total Row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.orange100),
            children: [
              _buildTableCell('', align: pw.TextAlign.center),
              _buildTableCell('GRAND TOTAL', isBold: true, fontSize: 10),
              _buildTableCell('₹${AppUtil.formatCurrency(grandTotal)}', align: pw.TextAlign.right, isBold: true, fontSize: 10),
              _buildTableCell('₹${AppUtil.formatCurrency(grandPaid)}', align: pw.TextAlign.right, isBold: true, fontSize: 10, color: PdfColors.green900),
              _buildTableCell('₹${AppUtil.formatCurrency(grandPending)}', align: pw.TextAlign.right, isBold: true, fontSize: 10, color: PdfColors.orange900),
              _buildTableCell('${vendors.length}', align: pw.TextAlign.center, isBold: true, fontSize: 10),
              _buildTableCell('${(grandTotal > 0 ? (grandPaid / grandTotal * 100) : 0.0).toStringAsFixed(1)}%', align: pw.TextAlign.right, isBold: true, fontSize: 10),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPurchaseHeader(String companyName, String reportTitle, DateTime fromDate, DateTime toDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900)),
                pw.SizedBox(height: 5),
                pw.Text(reportTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(color: PdfColors.orange100, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Report Period', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text(DateFormat('dd MMM yyyy').format(fromDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text('to', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(DateFormat('dd MMM yyyy').format(toDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.orange900),
      ],
    );
  }

  // Existing helper methods remain the same...
  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border(left: pw.BorderSide(width: 4, color: PdfColors.blue700)),
      ),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  static pw.Widget _buildTableCell(
      String text, {
        bool isHeader = false,
        double fontSize = 10,
        bool isBold = false,
        pw.TextAlign align = pw.TextAlign.left,
        PdfColor color = PdfColors.black,
      }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : color,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('System generated payment transaction report', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
            pw.Text('Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ],
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String reportType) async {
    try {
      final output = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '${reportType}_$timestamp.pdf';
      final file = File('${output.path}/$fileName');

      await file.writeAsBytes(await pdf.save());
      print('✅ PDF saved at: ${file.path}');
      await OpenFile.open(file.path);
    } catch (e) {
      print('❌ Error saving PDF: $e');
      throw Exception('Failed to save PDF: $e');
    }
  }

  static pw.Widget _buildHeader(String companyName, String reportTitle, DateTime fromDate, DateTime toDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 5),
                pw.Text(reportTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(color: PdfColors.blue100, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Report Period', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text(DateFormat('dd MMM yyyy').format(fromDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text('to', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(DateFormat('dd MMM yyyy').format(toDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

}


// ==================== CUSTOMER SUMMARY MODEL ====================
class CustomerSummary {
  final String customerName;
  final int invoiceCount;
  final double totalAmount;
  final double receivedAmount;
  final double pendingAmount;
  final List<String> invoiceIds;
  final List<String> statuses;

  CustomerSummary({
    required this.customerName,
    required this.invoiceCount,
    required this.totalAmount,
    required this.receivedAmount,
    required this.pendingAmount,
    required this.invoiceIds,
    required this.statuses,
  });

  String get overallStatus {
    if (pendingAmount <= 0) return 'PAID';
    if (receivedAmount <= 0) return 'PENDING';
    return 'PARTIAL';
  }

  double get paymentPercentage => totalAmount > 0 ? (receivedAmount / totalAmount * 100) : 0.0;
}

// ==================== CUSTOMER DATA GROUPING UTILITY ====================
class CustomerDataGrouper {
  static List<CustomerSummary> groupByCustomer(List<Invoice> invoices) {
    Map<String, List<Invoice>> grouped = {};

    // Group invoices by customer name (case-insensitive and trim whitespace)
    for (var invoice in invoices) {
      String customerName = (invoice.customerName ?? 'Unknown Customer').trim();
      String normalizedName = customerName.toLowerCase();

      // Find if customer already exists (case-insensitive match)
      String? existingKey;
      for (var key in grouped.keys) {
        if (key.toLowerCase() == normalizedName) {
          existingKey = key;
          break;
        }
      }

      if (existingKey != null) {
        grouped[existingKey]!.add(invoice);
      } else {
        grouped[customerName] = [invoice];
      }
    }

    // Create customer summaries - ONE PER CUSTOMER
    List<CustomerSummary> summaries = [];
    grouped.forEach((customerName, customerInvoices) {
      double total = 0.0;
      double received = 0.0;
      double pending = 0.0;
      List<String> invoiceIds = [];
      List<String> statuses = [];

      for (var inv in customerInvoices) {
        total += inv.totalAmount ?? 0.0;
        received += inv.receivedAmount ?? 0.0;
        pending += inv.pendingAmount ?? 0.0;
        invoiceIds.add('INV-${inv.invoiceId ?? "N/A"}');
        statuses.add(inv.status ?? 'Unknown');
      }

      summaries.add(CustomerSummary(
        customerName: customerName,
        invoiceCount: customerInvoices.length,
        totalAmount: total,
        receivedAmount: received,
        pendingAmount: pending,
        invoiceIds: invoiceIds,
        statuses: statuses,
      ));
    });

    // Sort by total amount descending (highest to lowest)
    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return summaries;
  }
}


// ✅ NEW: Vendor Summary Model (similar to CustomerSummary)
class VendorSummary {
  final String vendorName;
  final int purchaseCount;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final List<String> purchaseIds;
  final List<String> statuses;

  VendorSummary({
    required this.vendorName,
    required this.purchaseCount,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.purchaseIds,
    required this.statuses,
  });

  String get overallStatus {
    if (pendingAmount <= 0) return 'PAID';
    if (paidAmount <= 0) return 'PENDING';
    return 'PARTIAL';
  }

  double get paymentPercentage => totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0.0;
}

// ✅ NEW: Vendor Data Grouping Utility
class VendorDataGrouper {
  static List<VendorSummary> groupByVendor(List<PurchaseEntry> purchases) {
    Map<String, List<PurchaseEntry>> grouped = {};

    // Group purchases by vendor name (case-insensitive and trim whitespace)
    for (var purchase in purchases) {
      String vendorName = (purchase.vendorName ?? 'Unknown Vendor').trim();
      String normalizedName = vendorName.toLowerCase();

      // Find if vendor already exists (case-insensitive match)
      String? existingKey;
      for (var key in grouped.keys) {
        if (key.toLowerCase() == normalizedName) {
          existingKey = key;
          break;
        }
      }

      if (existingKey != null) {
        grouped[existingKey]!.add(purchase);
      } else {
        grouped[vendorName] = [purchase];
      }
    }

    // Create vendor summaries - ONE PER VENDOR
    List<VendorSummary> summaries = [];
    grouped.forEach((vendorName, vendorPurchases) {
      double total = 0.0;
      double paid = 0.0;
      double pending = 0.0;
      List<String> purchaseIds = [];
      List<String> statuses = [];

      for (var pur in vendorPurchases) {
        total += pur.totalAmount ?? 0.0;
        paid += pur.paidAmount ?? 0.0;
        pending += pur.pendingAmount ?? 0.0;
        purchaseIds.add('PUR-${pur.purchaseId ?? "N/A"}');
        statuses.add(pur.paymentStatus ?? 'Unknown');
      }

      summaries.add(VendorSummary(
        vendorName: vendorName,
        purchaseCount: vendorPurchases.length,
        totalAmount: total,
        paidAmount: paid,
        pendingAmount: pending,
        purchaseIds: purchaseIds,
        statuses: statuses,
      ));
    });

    // Sort by total amount descending (highest to lowest)
    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return summaries;
  }
}