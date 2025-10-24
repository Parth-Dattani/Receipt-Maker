import 'dart:io';

import 'package:demo_prac_getx/services/remote_service.dart';
import 'package:demo_prac_getx/utils/pdf_helper.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

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


// class PaymentDetailsController extends GetxController {
//   var invoices = <Invoice>[].obs;
//   var isLoading = true.obs;
//
//   // Report Generation State
//   var selectedReportType = 'Summary Report'.obs;
//   var selectedExportFormat = 'PDF'.obs;
//   var fromDate = Rx<DateTime?>(null);
//   var toDate = Rx<DateTime?>(null);
//   var isGeneratingReport = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadInvoices();
//     toDate.value = DateTime.now();
//     fromDate.value = DateTime.now().subtract(const Duration(days: 30));
//   }
//
//   Future<void> loadInvoices() async {
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
//       List<Invoice> allInvoices = await GoogleSheetService.getInvoices(type: "INV");
//       if (allInvoices.isEmpty) {
//         allInvoices = await GoogleSheetService.getInvoices();
//       }
//
//       invoices.value = allInvoices.where((inv) => inv.userId == currentUserId).toList();
//
//       print("✅ Loaded ${invoices.length} user invoices");
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load invoices: ${e.toString()}',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//         icon: Icon(Icons.error_outline, color: Colors.red.shade700),
//       );
//     } finally {
//       isLoading.value = false;
//     }
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
//   void selectReportType(String type) {
//     selectedReportType.value = type;
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
//       final filteredInvoices = getFilteredInvoices();
//
//       if (filteredInvoices.isEmpty) {
//         Get.snackbar(
//           'No Data',
//           'No invoices found for the selected date range',
//           backgroundColor: Colors.blue.shade100,
//           colorText: Colors.blue.shade800,
//           icon: const Icon(Icons.info_outline, color: Colors.blue),
//         );
//         isGeneratingReport.value = false;
//         return;
//       }
//
//       await Future.delayed(const Duration(seconds: 2));
//
//       switch (selectedExportFormat.value) {
//         case 'PDF':
//           await _generatePDFReport(filteredInvoices);
//           break;
//         case 'Excel':
//           await _generateExcelReport(filteredInvoices);
//           break;
//         case 'CSV':
//           await _generateCSVReport(filteredInvoices);
//           break;
//       }
//
//       Get.back();
//
//       Get.snackbar(
//         'Success',
//         '${selectedReportType.value} generated successfully!',
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
//   Future<void> _generatePDFReport(List<Invoice> invoices) async {
//     print("📄 Generating PDF report with ${invoices.length} invoices");
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       String? companyName = user?.displayName ?? 'Your Company';
//
//       await PdfHelper.generateReport(
//         invoices: invoices,
//         reportType: selectedReportType.value,
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
//   Future<void> _generateExcelReport(List<Invoice> invoices) async {
//     print("📊 Generating Excel report with ${invoices.length} invoices");
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       String? companyName = user?.displayName ?? 'Your Company';
//
//       await ExcelReportService.generateReport(
//         invoices: invoices,
//         reportType: selectedReportType.value,
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
//   Future<void> _generateCSVReport(List<Invoice> invoices) async {
//     print("📋 Generating CSV report with ${invoices.length} invoices");
//     // Implement CSV generation if needed
//     print("✅ CSV Report generated successfully!");
//   }
//
//   String getFormattedDate(DateTime? date) {
//     if (date == null) return 'Select Date';
//     return DateFormat('dd MMM yyyy').format(date);
//   }
// }
//
//
//
// // ==================== SHARED REPORT DATA CALCULATOR ====================
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
//     for (var invoice in invoices) {
//       totalAmount += invoice.totalAmount ?? 0.0;
//       receivedAmount += invoice.receivedAmount ?? 0.0;
//       pendingAmount += invoice.pendingAmount ?? 0.0;
//
//       switch (invoice.status?.toLowerCase()) {
//         case 'paid':
//         case 'accepted':
//           paidCount++;
//           break;
//         case 'pending':
//           pendingCount++;
//           break;
//         case 'overdue':
//           overdueCount++;
//           break;
//         case 'partial':
//           partialCount++;
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
//       'paymentRate': totalAmount > 0 ? (receivedAmount / totalAmount * 100) : 0,
//     };
//   }
// }
// //
// // // ==================== EXCEL SERVICE ====================
// // class ExcelReportService {
// //   static Future<void> generateReport({
// //     required List<Invoice> invoices,
// //     required String reportType,
// //     required DateTime fromDate,
// //     required DateTime toDate,
// //     String? userCompanyName,
// //   }) async {
// //     var excel = Excel.createExcel();
// //
// //     switch (reportType) {
// //       case 'Summary Report':
// //         _generateSummaryReport(excel, invoices, fromDate, toDate, userCompanyName);
// //         break;
// //       case 'Detailed Report':
// //         _generateDetailedReport(excel, invoices, fromDate, toDate, userCompanyName);
// //         break;
// //       case 'Payment Report':
// //         _generatePaymentReport(excel, invoices, fromDate, toDate, userCompanyName);
// //         break;
// //     }
// //
// //     await _saveExcel(excel, reportType);
// //   }
// //
// //   // SUMMARY REPORT - Status Breakdown + Detailed Invoice List
// //   static void _generateSummaryReport(
// //       Excel excel,
// //       List<Invoice> invoices,
// //       DateTime fromDate,
// //       DateTime toDate,
// //       String? companyName,
// //       ) {
// //     Sheet sheetObject = excel['Summary Report'];
// //     final data = ReportDataCalculator.calculate(invoices);
// //
// //     // Header
// //     _addReportHeader(sheetObject, companyName, 'Invoice Summary Report', fromDate, toDate);
// //
// //     // Status Breakdown
// //     sheetObject.appendRow([TextCellValue('Status Breakdown')]);
// //     sheetObject.appendRow([TextCellValue('Status'), TextCellValue('Count'), TextCellValue('Percentage')]);
// //     sheetObject.appendRow([
// //       TextCellValue('Paid'),
// //       IntCellValue(data['paidCount']),
// //       TextCellValue('${((data['paidCount'] / data['totalInvoices']) * 100).toStringAsFixed(1)}%')
// //     ]);
// //     sheetObject.appendRow([
// //       TextCellValue('Pending'),
// //       IntCellValue(data['pendingCount']),
// //       TextCellValue('${((data['pendingCount'] / data['totalInvoices']) * 100).toStringAsFixed(1)}%')
// //     ]);
// //     sheetObject.appendRow([
// //       TextCellValue('Overdue'),
// //       IntCellValue(data['overdueCount']),
// //       TextCellValue('${((data['overdueCount'] / data['totalInvoices']) * 100).toStringAsFixed(1)}%')
// //     ]);
// //     sheetObject.appendRow([
// //       TextCellValue('Partial'),
// //       IntCellValue(data['partialCount']),
// //       TextCellValue('${((data['partialCount'] / data['totalInvoices']) * 100).toStringAsFixed(1)}%')
// //     ]);
// //     sheetObject.appendRow([]);
// //
// //     // Detailed Invoice List
// //     sheetObject.appendRow([TextCellValue('Detailed Invoice List')]);
// //     sheetObject.appendRow([
// //       TextCellValue('Invoice ID'),
// //       TextCellValue('Customer Name'),
// //       TextCellValue('Issue Date'),
// //       TextCellValue('Total Amount'),
// //       TextCellValue('Received Amount'),
// //       TextCellValue('Pending Amount'),
// //       TextCellValue('Payment %'),
// //       TextCellValue('Status'),
// //     ]);
// //
// //     for (var inv in invoices) {
// //       final paidPercentage = (inv.totalAmount ?? 0.0) > 0
// //           ? ((inv.receivedAmount ?? 0.0) / (inv.totalAmount ?? 1.0) * 100)
// //           : 0.0;
// //
// //       sheetObject.appendRow([
// //         TextCellValue('INV-${inv.invoiceId ?? "N/A"}'),
// //         TextCellValue(inv.customerName ?? 'Unknown'),
// //         TextCellValue(inv.issueDate != null ? DateFormat('dd MMM yyyy').format(inv.issueDate!) : 'N/A'),
// //         TextCellValue('₹${AppUtil.formatCurrency(inv.totalAmount ?? 0.0)}'),
// //         TextCellValue('₹${AppUtil.formatCurrency(inv.receivedAmount ?? 0.0)}'),
// //         TextCellValue('₹${AppUtil.formatCurrency(inv.pendingAmount ?? 0.0)}'),
// //         TextCellValue('${paidPercentage.toStringAsFixed(1)}%'),
// //         TextCellValue(inv.status?.toUpperCase() ?? 'N/A'),
// //       ]);
// //     }
// //
// //     // Summary Totals
// //     sheetObject.appendRow([]);
// //     sheetObject.appendRow([
// //       TextCellValue('TOTAL'),
// //       TextCellValue(''),
// //       TextCellValue(''),
// //       TextCellValue('₹${AppUtil.formatCurrency(data['totalAmount'])}'),
// //       TextCellValue('₹${AppUtil.formatCurrency(data['receivedAmount'])}'),
// //       TextCellValue('₹${AppUtil.formatCurrency(data['pendingAmount'])}'),
// //       TextCellValue(''),
// //       TextCellValue(''),
// //     ]);
// //   }
// //
// //   // DETAILED REPORT - Full invoice list
// //   static void _generateDetailedReport(
// //       Excel excel,
// //       List<Invoice> invoices,
// //       DateTime fromDate,
// //       DateTime toDate,
// //       String? companyName,
// //       ) {
// //     Sheet sheetObject = excel['Detailed Report'];
// //     final data = ReportDataCalculator.calculate(invoices);
// //
// //     _addReportHeader(sheetObject, companyName, 'Detailed Invoice Report', fromDate, toDate);
// //
// //     sheetObject.appendRow([
// //       TextCellValue('Invoice ID'),
// //       TextCellValue('Customer Name'),
// //       TextCellValue('Issue Date'),
// //       TextCellValue('Total Amount'),
// //       TextCellValue('Received Amount'),
// //       TextCellValue('Pending Amount'),
// //       TextCellValue('Payment %'),
// //       TextCellValue('Status'),
// //     ]);
// //
// //     for (var inv in invoices) {
// //       final paidPercentage = (inv.totalAmount ?? 0.0) > 0
// //           ? ((inv.receivedAmount ?? 0.0) / (inv.totalAmount ?? 1.0) * 100)
// //           : 0.0;
// //
// //       sheetObject.appendRow([
// //         TextCellValue('INV-${inv.invoiceId ?? "N/A"}'),
// //         TextCellValue(inv.customerName ?? 'Unknown'),
// //         TextCellValue(inv.issueDate != null ? DateFormat('dd MMM yyyy').format(inv.issueDate!) : 'N/A'),
// //         TextCellValue('₹${AppUtil.formatCurrency(inv.totalAmount ?? 0.0)}'),
// //         TextCellValue('₹${AppUtil.formatCurrency(inv.receivedAmount ?? 0.0)}'),
// //         TextCellValue('₹${AppUtil.formatCurrency(inv.pendingAmount ?? 0.0)}'),
// //         TextCellValue('${paidPercentage.toStringAsFixed(1)}%'),
// //         TextCellValue(inv.status?.toUpperCase() ?? 'N/A'),
// //       ]);
// //     }
// //
// //     sheetObject.appendRow([]);
// //     sheetObject.appendRow([
// //       TextCellValue('TOTAL'),
// //       TextCellValue(''),
// //       TextCellValue(''),
// //       TextCellValue('₹${AppUtil.formatCurrency(data['totalAmount'])}'),
// //       TextCellValue('₹${AppUtil.formatCurrency(data['receivedAmount'])}'),
// //       TextCellValue('₹${AppUtil.formatCurrency(data['pendingAmount'])}'),
// //       TextCellValue(''),
// //       TextCellValue(''),
// //     ]);
// //   }
// //
// //   // PAYMENT REPORT - Payment analytics
// //   static void _generatePaymentReport(
// //       Excel excel,
// //       List<Invoice> invoices,
// //       DateTime fromDate,
// //       DateTime toDate,
// //       String? companyName,
// //       ) {
// //     Sheet sheetObject = excel['Payment Report'];
// //     final data = ReportDataCalculator.calculate(invoices);
// //
// //     _addReportHeader(sheetObject, companyName, 'Payment Status Report', fromDate, toDate);
// //
// //     // Payment Overview
// //     sheetObject.appendRow([TextCellValue('Payment Overview')]);
// //     sheetObject.appendRow([TextCellValue('Total Billed'), TextCellValue('₹${AppUtil.formatCurrency(data['totalAmount'])}')]);
// //     sheetObject.appendRow([TextCellValue('Amount Received'), TextCellValue('₹${AppUtil.formatCurrency(data['receivedAmount'])}')]);
// //     sheetObject.appendRow([TextCellValue('Amount Pending'), TextCellValue('₹${AppUtil.formatCurrency(data['pendingAmount'])}')]);
// //     sheetObject.appendRow([TextCellValue('Collection Rate'), TextCellValue('${data['paymentRate'].toStringAsFixed(1)}%')]);
// //     sheetObject.appendRow([]);
// //
// //     // Payment Details
// //     sheetObject.appendRow([
// //       TextCellValue('Invoice ID'),
// //       TextCellValue('Customer'),
// //       TextCellValue('Paid Amount'),
// //       TextCellValue('Pending Amount'),
// //       TextCellValue('Paid %'),
// //       TextCellValue('Status'),
// //     ]);
// //
// //     for (var inv in invoices) {
// //       final paidPercentage = (inv.totalAmount ?? 0.0) > 0
// //           ? ((inv.receivedAmount ?? 0.0) / (inv.totalAmount ?? 1.0) * 100)
// //           : 0.0;
// //
// //       sheetObject.appendRow([
// //         TextCellValue('INV-${inv.invoiceId ?? "N/A"}'),
// //         TextCellValue(inv.customerName ?? 'Unknown'),
// //         TextCellValue('₹${AppUtil.formatCurrency(inv.receivedAmount ?? 0.0)}'),
// //         TextCellValue('₹${AppUtil.formatCurrency(inv.pendingAmount ?? 0.0)}'),
// //         TextCellValue('${paidPercentage.toStringAsFixed(1)}%'),
// //         TextCellValue(inv.status?.toUpperCase() ?? 'N/A'),
// //       ]);
// //     }
// //   }
// //
// //   static void _addReportHeader(Sheet sheet, String? companyName, String title, DateTime fromDate, DateTime toDate) {
// //     sheet.appendRow([TextCellValue(companyName ?? 'Your Company')]);
// //     sheet.appendRow([TextCellValue(title)]);
// //     sheet.appendRow([TextCellValue('Period: ${DateFormat('dd MMM yyyy').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}')]);
// //     sheet.appendRow([]);
// //   }
// //
// //   static Future<void> _saveExcel(Excel excel, String reportType) async {
// //     try {
// //       final output = await getTemporaryDirectory();
// //       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
// //       final fileName = '${reportType.replaceAll(' ', '_')}_$timestamp.xlsx';
// //       final file = File('${output.path}/$fileName');
// //
// //       final fileBytes = excel.save();
// //       if (fileBytes != null) {
// //         await file.writeAsBytes(fileBytes);
// //         print('✅ Excel saved at: ${file.path}');
// //         await OpenFile.open(file.path);
// //       }
// //     } catch (e) {
// //       print('❌ Error saving Excel: $e');
// //       throw Exception('Failed to save Excel: $e');
// //     }
// //   }
// // }
// //
// // // ==================== PDF SERVICE - FIXED CURRENCY FORMATTING ====================
// // class PdfHelper {
// //   static Future<void> generateReport({
// //     required List<Invoice> invoices,
// //     required String reportType,
// //     required DateTime fromDate,
// //     required DateTime toDate,
// //     String? userCompanyName,
// //   }) async {
// //     final pdf = pw.Document();
// //
// //     // Load custom fonts (Rupee + Emoji)
// //     final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
// //     final iconData = await rootBundle.load("assets/fonts/NotoEmoji-Regular.ttf");
// //     final customFont = pw.Font.ttf(fontData.buffer.asByteData());
// //     final notoEmoji = pw.Font.ttf(iconData.buffer.asByteData());
// //
// //     final theme = pw.ThemeData.withFont(
// //       base: customFont,
// //       bold: customFont,
// //       italic: customFont,
// //       boldItalic: customFont,
// //     );
// //
// //     switch (reportType) {
// //       case 'Summary Report':
// //         _generateSummaryReport(pdf, invoices, fromDate, toDate, userCompanyName, theme, notoEmoji);
// //         break;
// //       case 'Detailed Report':
// //         _generateDetailedReport(pdf, invoices, fromDate, toDate, userCompanyName, theme, notoEmoji);
// //         break;
// //       case 'Payment Report':
// //         _generatePaymentReport(pdf, invoices, fromDate, toDate, userCompanyName, theme, notoEmoji);
// //         break;
// //     }
// //
// //     await _savePdf(pdf, reportType);
// //   }
// //
// //   // ==================== SUMMARY REPORT: Status Breakdown + Detailed Invoice List ====================
// //   static void _generateSummaryReport(
// //       pw.Document pdf,
// //       List<Invoice> invoices,
// //       DateTime fromDate,
// //       DateTime toDate,
// //       String? companyName,
// //       pw.ThemeData theme,
// //       pw.Font emojiFont,
// //       ) {
// //     final data = ReportDataCalculator.calculate(invoices);
// //
// //     pdf.addPage(
// //       pw.MultiPage(
// //         pageFormat: PdfPageFormat.a4,
// //         margin: pw.EdgeInsets.all(32),
// //         theme: theme,
// //         build: (context) => [
// //           _buildHeader(companyName ?? 'Your Company', 'Summary Report', fromDate, toDate),
// //           pw.SizedBox(height: 25),
// //
// //           // Status Breakdown
// //           _buildSectionTitle('Status Breakdown'),
// //           pw.SizedBox(height: 10),
// //           _buildStatusBreakdownTable(data, emojiFont),
// //           pw.SizedBox(height: 25),
// //
// //           // Detailed Invoice List
// //           _buildSectionTitle('Detailed Invoice List'),
// //           pw.SizedBox(height: 10),
// //           _buildDetailedInvoiceTable(invoices),
// //           pw.SizedBox(height: 15),
// //
// //           // Summary Totals
// //           _buildTotalsSummary(data),
// //           pw.SizedBox(height: 25),
// //
// //           _buildFooter(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ==================== DETAILED REPORT ====================
// //   static void _generateDetailedReport(
// //       pw.Document pdf,
// //       List<Invoice> invoices,
// //       DateTime fromDate,
// //       DateTime toDate,
// //       String? companyName,
// //       pw.ThemeData theme,
// //       pw.Font emojiFont,
// //       ) {
// //     final data = ReportDataCalculator.calculate(invoices);
// //
// //     pdf.addPage(
// //       pw.MultiPage(
// //         pageFormat: PdfPageFormat.a4,
// //         margin: pw.EdgeInsets.all(32),
// //         theme: theme,
// //         build: (context) => [
// //           _buildHeader(companyName ?? 'Your Company', 'Detailed Invoice Report', fromDate, toDate),
// //           pw.SizedBox(height: 25),
// //
// //           _buildSectionTitle('Complete Invoice List'),
// //           pw.SizedBox(height: 10),
// //           _buildDetailedInvoiceTable(invoices),
// //           pw.SizedBox(height: 15),
// //
// //           _buildTotalsSummary(data),
// //           pw.SizedBox(height: 25),
// //
// //           _buildFooter(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ==================== PAYMENT REPORT ====================
// //   static void _generatePaymentReport(
// //       pw.Document pdf,
// //       List<Invoice> invoices,
// //       DateTime fromDate,
// //       DateTime toDate,
// //       String? companyName,
// //       pw.ThemeData theme,
// //       pw.Font emojiFont,
// //       ) {
// //     final data = ReportDataCalculator.calculate(invoices);
// //
// //     pdf.addPage(
// //       pw.MultiPage(
// //         pageFormat: PdfPageFormat.a4,
// //         margin: pw.EdgeInsets.all(32),
// //         theme: theme,
// //         build: (context) => [
// //           _buildHeader(companyName ?? 'Your Company', 'Payment Analysis Report', fromDate, toDate),
// //           pw.SizedBox(height: 25),
// //
// //           _buildSectionTitle('Payment Summary'),
// //           pw.SizedBox(height: 10),
// //           _buildPaymentOverviewCards(data),
// //           pw.SizedBox(height: 20),
// //
// //           _buildSectionTitle('Invoice Payment Status'),
// //           pw.SizedBox(height: 10),
// //           _buildPaymentStatusTable(invoices),
// //           pw.SizedBox(height: 25),
// //
// //           _buildFooter(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ==================== REUSABLE WIDGETS ====================
// //
// //   static pw.Widget _buildHeader(String companyName, String reportTitle, DateTime fromDate, DateTime toDate) {
// //     return pw.Column(
// //       crossAxisAlignment: pw.CrossAxisAlignment.start,
// //       children: [
// //         pw.Row(
// //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //           children: [
// //             pw.Column(
// //               crossAxisAlignment: pw.CrossAxisAlignment.start,
// //               children: [
// //                 pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
// //                 pw.SizedBox(height: 5),
// //                 pw.Text(reportTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
// //               ],
// //             ),
// //             pw.Container(
// //               padding: pw.EdgeInsets.all(10),
// //               decoration: pw.BoxDecoration(color: PdfColors.blue100, borderRadius: pw.BorderRadius.circular(8)),
// //               child: pw.Column(
// //                 crossAxisAlignment: pw.CrossAxisAlignment.end,
// //                 children: [
// //                   pw.Text('Report Period', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
// //                   pw.Text(DateFormat('dd MMM yyyy').format(fromDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
// //                   pw.Text('to', style: pw.TextStyle(fontSize: 9)),
// //                   pw.Text(DateFormat('dd MMM yyyy').format(toDate), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //         pw.SizedBox(height: 10),
// //         pw.Divider(thickness: 2, color: PdfColors.blue900),
// //       ],
// //     );
// //   }
// //
// //   static pw.Widget _buildSectionTitle(String title) {
// //     return pw.Container(
// //       padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
// //       decoration: pw.BoxDecoration(
// //         color: PdfColors.blue50,
// //         border: pw.Border(left: pw.BorderSide(width: 4, color: PdfColors.blue700)),
// //       ),
// //       child: pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
// //     );
// //   }
// //
// //   // ✅ FIXED: Status Breakdown Table with Proper Amount Column
// //   static pw.Widget _buildStatusBreakdownTable(Map<String, dynamic> data, pw.Font emojiFont) {
// //     final totalInvoices = data['totalInvoices'] ?? 1;
// //
// //     return pw.Container(
// //       decoration: pw.BoxDecoration(
// //           border: pw.Border.all(color: PdfColors.grey300),
// //           borderRadius: pw.BorderRadius.circular(4)
// //       ),
// //       child: pw.Table(
// //         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
// //         columnWidths: {
// //           0: pw.FlexColumnWidth(2),      // Status
// //           1: pw.FlexColumnWidth(1),      // Count
// //           2: pw.FlexColumnWidth(2.5),    // Amount
// //           3: pw.FlexColumnWidth(1.5),    // Percentage
// //         },
// //         children: [
// //           // Header Row
// //           pw.TableRow(
// //             decoration: pw.BoxDecoration(color: PdfColors.grey200),
// //             children: [
// //               _buildTableCell('Status', isHeader: true),
// //               _buildTableCell('Count', isHeader: true, align: pw.TextAlign.center),
// //               _buildTableCell('Amount', isHeader: true, align: pw.TextAlign.right),
// //               _buildTableCell('Percentage', isHeader: true, align: pw.TextAlign.center),
// //             ],
// //           ),
// //           // Paid Row
// //           pw.TableRow(
// //             decoration: pw.BoxDecoration(color: PdfColors.green50),
// //             children: [
// //               _buildTableCell(' Paid'),
// //               _buildTableCell('${data['paidCount'] ?? 0}', align: pw.TextAlign.center),
// //               _buildTableCell(
// //                   AppUtil.formatCurrency(data['paidAmount'] ?? 0.0),
// //                   align: pw.TextAlign.right
// //               ),
// //               _buildTableCell(
// //                   '${((data['paidCount'] ?? 0) / totalInvoices * 100).toStringAsFixed(1)}%',
// //                   align: pw.TextAlign.center
// //               ),
// //             ],
// //           ),
// //           // Pending Row
// //           pw.TableRow(
// //             children: [
// //               _buildTableCell('Pending'),
// //               _buildTableCell('${data['pendingCount'] ?? 0}', align: pw.TextAlign.center),
// //               _buildTableCell(
// //                   AppUtil.formatCurrency(data['pendingAmount'] ?? 0.0),
// //                   align: pw.TextAlign.right
// //               ),
// //               _buildTableCell(
// //                   '${((data['pendingCount'] ?? 0) / totalInvoices * 100).toStringAsFixed(1)}%',
// //                   align: pw.TextAlign.center
// //               ),
// //             ],
// //           ),
// //           // Overdue Row
// //           pw.TableRow(
// //             decoration: pw.BoxDecoration(color: PdfColors.red50),
// //             children: [
// //               _buildTableCell('Overdue'),
// //               _buildTableCell('${data['overdueCount'] ?? 0}', align: pw.TextAlign.center),
// //               _buildTableCell(
// //                   AppUtil.formatCurrency(data['overdueAmount'] ?? 0.0),
// //                   align: pw.TextAlign.right
// //               ),
// //               _buildTableCell(
// //                   '${((data['overdueCount'] ?? 0) / totalInvoices * 100).toStringAsFixed(1)}%',
// //                   align: pw.TextAlign.center
// //               ),
// //             ],
// //           ),
// //           // Partial Row
// //           pw.TableRow(
// //             children: [
// //               _buildTableCell('Partial'),
// //               _buildTableCell('${data['partialCount'] ?? 0}', align: pw.TextAlign.center),
// //               _buildTableCell(
// //                   AppUtil.formatCurrency(data['partialAmount'] ?? 0.0),
// //                   align: pw.TextAlign.right
// //               ),
// //               _buildTableCell(
// //                   '${((data['partialCount'] ?? 0) / totalInvoices * 100).toStringAsFixed(1)}%',
// //                   align: pw.TextAlign.center
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ✅ FIXED: Detailed Invoice Table with Proper Currency Formatting
// //   static pw.Widget _buildDetailedInvoiceTable(List<Invoice> invoices) {
// //     return pw.Container(
// //       decoration: pw.BoxDecoration(
// //           border: pw.Border.all(color: PdfColors.grey300),
// //           borderRadius: pw.BorderRadius.circular(4)
// //       ),
// //       child: pw.Table(
// //         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
// //         columnWidths: {
// //           0: pw.FlexColumnWidth(1.5),
// //           1: pw.FlexColumnWidth(2),
// //           2: pw.FlexColumnWidth(1.3),
// //           3: pw.FlexColumnWidth(1.5),
// //           4: pw.FlexColumnWidth(1.5),
// //           5: pw.FlexColumnWidth(1.5),
// //           6: pw.FlexColumnWidth(1),
// //           7: pw.FlexColumnWidth(1.2),
// //         },
// //         children: [
// //           pw.TableRow(
// //             decoration: pw.BoxDecoration(color: PdfColors.grey200),
// //             children: [
// //               _buildTableCell('Invoice ID', isHeader: true, fontSize: 9),
// //               _buildTableCell('Customer', isHeader: true, fontSize: 9),
// //               _buildTableCell('Date', isHeader: true, fontSize: 9),
// //               _buildTableCell('Total', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
// //               _buildTableCell('Received', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
// //               _buildTableCell('Pending', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
// //               _buildTableCell('Paid %', isHeader: true, fontSize: 9, align: pw.TextAlign.center),
// //               _buildTableCell('Status', isHeader: true, fontSize: 9),
// //             ],
// //           ),
// //           ...invoices.asMap().entries.map((entry) {
// //             final index = entry.key;
// //             final inv = entry.value;
// //             final paidPercentage = (inv.totalAmount ?? 0.0) > 0
// //                 ? ((inv.receivedAmount ?? 0.0) / (inv.totalAmount ?? 1.0) * 100)
// //                 : 0.0;
// //
// //             return pw.TableRow(
// //               decoration: index % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
// //               children: [
// //                 _buildTableCell('INV-${inv.invoiceId ?? "N/A"}', fontSize: 8),
// //                 _buildTableCell(inv.customerName ?? 'Unknown', fontSize: 8),
// //                 _buildTableCell(
// //                     inv.issueDate != null ? DateFormat('dd/MM/yy').format(inv.issueDate!) : 'N/A',
// //                     fontSize: 8
// //                 ),
// //                 // ✅ FIXED: Remove duplicate ₹ symbol
// //                 _buildTableCell(
// //                     AppUtil.formatCurrency(inv.totalAmount ?? 0.0),
// //                     fontSize: 8,
// //                     align: pw.TextAlign.right
// //                 ),
// //                 _buildTableCell(
// //                     AppUtil.formatCurrency(inv.receivedAmount ?? 0.0),
// //                     fontSize: 8,
// //                     align: pw.TextAlign.right
// //                 ),
// //                 _buildTableCell(
// //                     AppUtil.formatCurrency(inv.pendingAmount ?? 0.0),
// //                     fontSize: 8,
// //                     align: pw.TextAlign.right
// //                 ),
// //                 _buildTableCell(
// //                     '${paidPercentage.toStringAsFixed(1)}%',
// //                     fontSize: 8,
// //                     isBold: true,
// //                     align: pw.TextAlign.center
// //                 ),
// //                 _buildTableCell(inv.status?.toUpperCase() ?? 'N/A', fontSize: 8),
// //               ],
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ✅ FIXED: Payment Overview Cards with Proper Currency
// //   static pw.Widget _buildPaymentOverviewCards(Map<String, dynamic> data) {
// //     return pw.Row(
// //       children: [
// //         pw.Expanded(
// //             child: _buildCard(
// //                 'Total Billed',
// //                 AppUtil.formatCurrency(data['totalAmount'] ?? 0.0),
// //                 PdfColors.blue100,
// //                 PdfColors.blue900
// //             )
// //         ),
// //         pw.SizedBox(width: 10),
// //         pw.Expanded(
// //             child: _buildCard(
// //                 'Collected',
// //                 AppUtil.formatCurrency(data['receivedAmount'] ?? 0.0),
// //                 PdfColors.green100,
// //                 PdfColors.green900
// //             )
// //         ),
// //         pw.SizedBox(width: 10),
// //         pw.Expanded(
// //             child: _buildCard(
// //                 'Outstanding',
// //                 AppUtil.formatCurrency(data['pendingAmount'] ?? 0.0),
// //                 PdfColors.orange100,
// //                 PdfColors.orange900
// //             )
// //         ),
// //         pw.SizedBox(width: 10),
// //         pw.Expanded(
// //             child: _buildCard(
// //                 'Collection Rate',
// //                 '${(data['paymentRate'] ?? 0.0).toStringAsFixed(1)}%',
// //                 PdfColors.purple100,
// //                 PdfColors.purple900
// //             )
// //         ),
// //       ],
// //     );
// //   }
// //
// //   static pw.Widget _buildCard(String label, String value, PdfColor bgColor, PdfColor textColor) {
// //     return pw.Container(
// //       padding: pw.EdgeInsets.all(12),
// //       decoration: pw.BoxDecoration(
// //         color: bgColor,
// //         borderRadius: pw.BorderRadius.circular(8),
// //         border: pw.Border.all(color: textColor, width: 1),
// //       ),
// //       child: pw.Column(
// //         children: [
// //           pw.Text(
// //               label,
// //               style: pw.TextStyle(fontSize: 9, color: textColor),
// //               textAlign: pw.TextAlign.center
// //           ),
// //           pw.SizedBox(height: 6),
// //           pw.Text(
// //               value,
// //               style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textColor),
// //               textAlign: pw.TextAlign.center
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ✅ FIXED: Payment Status Table with Proper Currency
// //   static pw.Widget _buildPaymentStatusTable(List<Invoice> invoices) {
// //     return pw.Container(
// //       decoration: pw.BoxDecoration(
// //           border: pw.Border.all(color: PdfColors.grey300),
// //           borderRadius: pw.BorderRadius.circular(4)
// //       ),
// //       child: pw.Table(
// //         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
// //         columnWidths: {
// //           0: pw.FlexColumnWidth(1.5),
// //           1: pw.FlexColumnWidth(2.5),
// //           2: pw.FlexColumnWidth(1.5),
// //           3: pw.FlexColumnWidth(1.5),
// //           4: pw.FlexColumnWidth(1),
// //           5: pw.FlexColumnWidth(1.2),
// //         },
// //         children: [
// //           pw.TableRow(
// //             decoration: pw.BoxDecoration(color: PdfColors.grey200),
// //             children: [
// //               _buildTableCell('Invoice ID', isHeader: true, fontSize: 9),
// //               _buildTableCell('Customer', isHeader: true, fontSize: 9),
// //               _buildTableCell('Paid Amount', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
// //               _buildTableCell('Pending Amount', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
// //               _buildTableCell('Paid %', isHeader: true, fontSize: 9, align: pw.TextAlign.center),
// //               _buildTableCell('Status', isHeader: true, fontSize: 9),
// //             ],
// //           ),
// //           ...invoices.asMap().entries.map((entry) {
// //             final index = entry.key;
// //             final inv = entry.value;
// //             final paidPercentage = (inv.totalAmount ?? 0.0) > 0
// //                 ? ((inv.receivedAmount ?? 0.0) / (inv.totalAmount ?? 1.0) * 100)
// //                 : 0.0;
// //
// //             return pw.TableRow(
// //               decoration: index % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
// //               children: [
// //                 _buildTableCell('INV-${inv.invoiceId ?? "N/A"}', fontSize: 8),
// //                 _buildTableCell(inv.customerName ?? 'Unknown', fontSize: 8),
// //                 // ✅ FIXED: Remove duplicate ₹ symbol
// //                 _buildTableCell(
// //                     AppUtil.formatCurrency(inv.receivedAmount ?? 0.0),
// //                     fontSize: 8,
// //                     align: pw.TextAlign.right
// //                 ),
// //                 _buildTableCell(
// //                     AppUtil.formatCurrency(inv.pendingAmount ?? 0.0),
// //                     fontSize: 8,
// //                     align: pw.TextAlign.right
// //                 ),
// //                 _buildTableCell(
// //                     '${paidPercentage.toStringAsFixed(1)}%',
// //                     fontSize: 8,
// //                     isBold: true,
// //                     align: pw.TextAlign.center
// //                 ),
// //                 _buildTableCell(inv.status?.toUpperCase() ?? 'N/A', fontSize: 8),
// //               ],
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ✅ FIXED: Totals Summary with Proper Currency
// //   static pw.Widget _buildTotalsSummary(Map<String, dynamic> data) {
// //     return pw.Container(
// //       padding: pw.EdgeInsets.all(15),
// //       decoration: pw.BoxDecoration(
// //         color: PdfColors.blue50,
// //         borderRadius: pw.BorderRadius.circular(8),
// //         border: pw.Border.all(color: PdfColors.blue300, width: 2),
// //       ),
// //       child: pw.Row(
// //         mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
// //         children: [
// //           _buildSummaryItem(
// //               'TOTAL',
// //               AppUtil.formatCurrency(data['totalAmount'] ?? 0.0),
// //               PdfColors.blue900
// //           ),
// //           pw.Container(width: 2, height: 40, color: PdfColors.blue300),
// //           _buildSummaryItem(
// //               'RECEIVED',
// //               AppUtil.formatCurrency(data['receivedAmount'] ?? 0.0),
// //               PdfColors.green900
// //           ),
// //           pw.Container(width: 2, height: 40, color: PdfColors.blue300),
// //           _buildSummaryItem(
// //               'PENDING',
// //               AppUtil.formatCurrency(data['pendingAmount'] ?? 0.0),
// //               PdfColors.orange900
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
// //     return pw.Column(
// //       children: [
// //         pw.Text(
// //             label,
// //             style: pw.TextStyle(
// //                 fontSize: 10,
// //                 color: PdfColors.grey700,
// //                 fontWeight: pw.FontWeight.bold
// //             )
// //         ),
// //         pw.SizedBox(height: 6),
// //         pw.Text(
// //             value,
// //             style: pw.TextStyle(
// //                 fontSize: 14,
// //                 fontWeight: pw.FontWeight.bold,
// //                 color: color
// //             )
// //         ),
// //       ],
// //     );
// //   }
// //
// //   static pw.Widget _buildFooter() {
// //     return pw.Column(
// //       children: [
// //         pw.Divider(thickness: 2, color: PdfColors.blue900),
// //         pw.SizedBox(height: 10),
// //         pw.Row(
// //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //           children: [
// //             pw.Text(
// //               'This is a system generated report',
// //               style: pw.TextStyle(
// //                   fontSize: 9,
// //                   color: PdfColors.grey600,
// //                   fontStyle: pw.FontStyle.italic
// //               ),
// //             ),
// //             pw.Text(
// //               'Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
// //               style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// //
// //   // ✅ UPDATED: Table Cell with TextAlign support
// //   static pw.Widget _buildTableCell(
// //       String text, {
// //         bool isHeader = false,
// //         double fontSize = 10,
// //         bool isBold = false,
// //         pw.TextAlign align = pw.TextAlign.left,
// //       }) {
// //     return pw.Container(
// //       padding: pw.EdgeInsets.all(8),
// //       child: pw.Text(
// //         text,
// //         style: pw.TextStyle(
// //           fontSize: fontSize,
// //           fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
// //           color: isHeader ? PdfColors.grey800 : PdfColors.black,
// //         ),
// //         textAlign: align,
// //       ),
// //     );
// //   }
// //
// //   static pw.Widget _buildTableCellWithEmoji(String text, pw.Font emojiFont) {
// //     return pw.Container(
// //       padding: pw.EdgeInsets.all(8),
// //       child: pw.Text(
// //         text,
// //         style: pw.TextStyle(
// //           fontSize: 10,
// //           font: emojiFont,
// //           color: PdfColors.black,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ==================== SAVE PDF ====================
// //   static Future<void> _savePdf(pw.Document pdf, String reportType) async {
// //     try {
// //       final output = await getTemporaryDirectory();
// //       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
// //       final fileName = '${reportType.replaceAll(' ', '_')}_$timestamp.pdf';
// //       final file = File('${output.path}/$fileName');
// //
// //       await file.writeAsBytes(await pdf.save());
// //       print('✅ PDF saved at: ${file.path}');
// //       await OpenFile.open(file.path);
// //     } catch (e) {
// //       print('❌ Error saving PDF: $e');
// //       throw Exception('Failed to save PDF: $e');
// //     }
// //   }
// // }
//
// // ==================== CUSTOMER GROUPED DATA MODEL ====================
//
//
// // ==================== CUSTOMER GROUPED DATA MODEL ====================
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
// // ==================== UPDATED EXCEL SERVICE - ONE ENTRY PER CUSTOMER ====================
// class ExcelReportService {
//   static Future<void> generateReport({
//     required List<Invoice> invoices,
//     required String reportType,
//     required DateTime fromDate,
//     required DateTime toDate,
//     String? userCompanyName,
//   }) async {
//     var excel = Excel.createExcel();
//
//     // Group invoices by customer - THIS CREATES ONE ENTRY PER CUSTOMER
//     final customerSummaries = CustomerDataGrouper.groupByCustomer(invoices);
//
//     switch (reportType) {
//       case 'Summary Report':
//         _generateSummaryReport(excel, customerSummaries, fromDate, toDate, userCompanyName);
//         break;
//       case 'Detailed Report':
//         _generateDetailedReport(excel, customerSummaries, fromDate, toDate, userCompanyName);
//         break;
//       case 'Payment Report':
//         _generatePaymentReport(excel, customerSummaries, fromDate, toDate, userCompanyName);
//         break;
//     }
//
//     await _saveExcel(excel, reportType);
//   }
//
//   // SUMMARY REPORT - One row per customer with combined totals
//   static void _generateSummaryReport(
//       Excel excel,
//       List<CustomerSummary> customerSummaries,
//       DateTime fromDate,
//       DateTime toDate,
//       String? companyName,
//       ) {
//     Sheet sheetObject = excel['Summary Report'];
//
//     _addReportHeader(sheetObject, companyName, 'Customer-wise Invoice Summary', fromDate, toDate);
//
//     // Header
//     sheetObject.appendRow([TextCellValue('Customer Summary (One Entry Per Customer)')]);
//     sheetObject.appendRow([
//       TextCellValue('Customer Name'),
//       TextCellValue('Invoice Count'),
//       TextCellValue('Total Amount'),
//       TextCellValue('Received Amount'),
//       TextCellValue('Pending Amount'),
//       TextCellValue('Payment %'),
//       TextCellValue('Status'),
//     ]);
//
//     double grandTotal = 0.0;
//     double grandReceived = 0.0;
//     double grandPending = 0.0;
//     int totalInvoiceCount = 0;
//
//     // Each customer appears only ONCE with combined data
//     for (var customer in customerSummaries) {
//       sheetObject.appendRow([
//         TextCellValue(customer.customerName),
//         IntCellValue(customer.invoiceCount), // Shows how many invoices this customer has
//         TextCellValue('₹${AppUtil.formatCurrency(customer.totalAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.receivedAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.pendingAmount)}'),
//         TextCellValue('${customer.paymentPercentage.toStringAsFixed(1)}%'),
//         TextCellValue(customer.overallStatus),
//       ]);
//
//       grandTotal += customer.totalAmount;
//       grandReceived += customer.receivedAmount;
//       grandPending += customer.pendingAmount;
//       totalInvoiceCount += customer.invoiceCount;
//     }
//
//     // Grand Total Row
//     sheetObject.appendRow([]);
//     sheetObject.appendRow([
//       TextCellValue('GRAND TOTAL'),
//       IntCellValue(totalInvoiceCount),
//       TextCellValue('₹${AppUtil.formatCurrency(grandTotal)}'),
//       TextCellValue('₹${AppUtil.formatCurrency(grandReceived)}'),
//       TextCellValue('₹${AppUtil.formatCurrency(grandPending)}'),
//       TextCellValue('${(grandTotal > 0 ? (grandReceived / grandTotal * 100) : 0.0).toStringAsFixed(1)}%'),
//       TextCellValue(''),
//     ]);
//   }
//
//   // DETAILED REPORT - Shows all invoice IDs for each customer in one row
//   static void _generateDetailedReport(
//       Excel excel,
//       List<CustomerSummary> customerSummaries,
//       DateTime fromDate,
//       DateTime toDate,
//       String? companyName,
//       ) {
//     Sheet sheetObject = excel['Detailed Report'];
//
//     _addReportHeader(sheetObject, companyName, 'Detailed Customer Report', fromDate, toDate);
//
//     sheetObject.appendRow([TextCellValue('Detailed Customer Report (With All Invoice IDs)')]);
//     sheetObject.appendRow([
//       TextCellValue('Customer Name'),
//       TextCellValue('Invoice IDs'),
//       TextCellValue('Invoice Count'),
//       TextCellValue('Total Amount'),
//       TextCellValue('Received Amount'),
//       TextCellValue('Pending Amount'),
//       TextCellValue('Payment %'),
//       TextCellValue('Status'),
//     ]);
//
//     double grandTotal = 0.0;
//     double grandReceived = 0.0;
//     double grandPending = 0.0;
//     int totalInvoiceCount = 0;
//
//     // Each customer appears only ONCE with all their invoice IDs listed
//     for (var customer in customerSummaries) {
//       sheetObject.appendRow([
//         TextCellValue(customer.customerName),
//         TextCellValue(customer.invoiceIds.join(', ')), // All invoice IDs for this customer
//         IntCellValue(customer.invoiceCount),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.totalAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.receivedAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.pendingAmount)}'),
//         TextCellValue('${customer.paymentPercentage.toStringAsFixed(1)}%'),
//         TextCellValue(customer.overallStatus),
//       ]);
//
//       grandTotal += customer.totalAmount;
//       grandReceived += customer.receivedAmount;
//       grandPending += customer.pendingAmount;
//       totalInvoiceCount += customer.invoiceCount;
//     }
//
//     sheetObject.appendRow([]);
//     sheetObject.appendRow([
//       TextCellValue('GRAND TOTAL'),
//       TextCellValue(''),
//       IntCellValue(totalInvoiceCount),
//       TextCellValue('₹${AppUtil.formatCurrency(grandTotal)}'),
//       TextCellValue('₹${AppUtil.formatCurrency(grandReceived)}'),
//       TextCellValue('₹${AppUtil.formatCurrency(grandPending)}'),
//       TextCellValue('${(grandTotal > 0 ? (grandReceived / grandTotal * 100) : 0.0).toStringAsFixed(1)}%'),
//       TextCellValue(''),
//     ]);
//   }
//
//   // PAYMENT REPORT - Customer payment analytics
//   static void _generatePaymentReport(
//       Excel excel,
//       List<CustomerSummary> customerSummaries,
//       DateTime fromDate,
//       DateTime toDate,
//       String? companyName,
//       ) {
//     Sheet sheetObject = excel['Payment Report'];
//
//     _addReportHeader(sheetObject, companyName, 'Customer Payment Analysis', fromDate, toDate);
//
//     // Top 5 Customers by Amount
//     sheetObject.appendRow([TextCellValue('Top 5 Customers by Total Amount')]);
//     sheetObject.appendRow([
//       TextCellValue('Rank'),
//       TextCellValue('Customer Name'),
//       TextCellValue('Total Amount'),
//       TextCellValue('Payment Status'),
//     ]);
//
//     final topCustomers = customerSummaries.take(5).toList();
//     for (int i = 0; i < topCustomers.length; i++) {
//       final customer = topCustomers[i];
//       sheetObject.appendRow([
//         IntCellValue(i + 1),
//         TextCellValue(customer.customerName),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.totalAmount)}'),
//         TextCellValue('${customer.paymentPercentage.toStringAsFixed(1)}% Paid'),
//       ]);
//     }
//
//     // All Customers Payment Status
//     sheetObject.appendRow([]);
//     sheetObject.appendRow([TextCellValue('Complete Customer Payment Status (One Entry Per Customer)')]);
//     sheetObject.appendRow([
//       TextCellValue('Customer Name'),
//       TextCellValue('Invoices Count'),
//       TextCellValue('Paid Amount'),
//       TextCellValue('Pending Amount'),
//       TextCellValue('Paid %'),
//       TextCellValue('Status'),
//     ]);
//
//     for (var customer in customerSummaries) {
//       sheetObject.appendRow([
//         TextCellValue(customer.customerName),
//         IntCellValue(customer.invoiceCount),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.receivedAmount)}'),
//         TextCellValue('₹${AppUtil.formatCurrency(customer.pendingAmount)}'),
//         TextCellValue('${customer.paymentPercentage.toStringAsFixed(1)}%'),
//         TextCellValue(customer.overallStatus),
//       ]);
//     }
//   }
//
//   static void _addReportHeader(Sheet sheet, String? companyName, String title, DateTime fromDate, DateTime toDate) {
//     sheet.appendRow([TextCellValue(companyName ?? 'Your Company')]);
//     sheet.appendRow([TextCellValue(title)]);
//     sheet.appendRow([TextCellValue('Period: ${DateFormat('dd MMM yyyy').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}')]);
//     sheet.appendRow([]);
//   }
//
//   static Future<void> _saveExcel(Excel excel, String reportType) async {
//     try {
//       final output = await getTemporaryDirectory();
//       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//       final fileName = '${reportType.replaceAll(' ', '_')}_$timestamp.xlsx';
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
// }
//
//
// // ==================== UPDATED PDF SERVICE ====================
// class PdfHelper {
//   static Future<void> generateReport({
//     required List<Invoice> invoices,
//     required String reportType,
//     required DateTime fromDate,
//     required DateTime toDate,
//     String? userCompanyName,
//   }) async {
//     final pdf = pw.Document();
//
//     // Load fonts
//     final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
//     final customFont = pw.Font.ttf(fontData.buffer.asByteData());
//
//     final theme = pw.ThemeData.withFont(base: customFont);
//
//     // Group invoices by customer
//     final customerSummaries = CustomerDataGrouper.groupByCustomer(invoices);
//
//     switch (reportType) {
//       case 'Summary Report':
//         _generateSummaryReport(pdf, customerSummaries, fromDate, toDate, userCompanyName, theme);
//         break;
//       case 'Detailed Report':
//         _generateDetailedReport(pdf, customerSummaries, fromDate, toDate, userCompanyName, theme);
//         break;
//       case 'Payment Report':
//         _generatePaymentReport(pdf, customerSummaries, fromDate, toDate, userCompanyName, theme);
//         break;
//     }
//
//     await _savePdf(pdf, reportType);
//   }
//
//   static void _generateSummaryReport(
//       pw.Document pdf,
//       List<CustomerSummary> customerSummaries,
//       DateTime fromDate,
//       DateTime toDate,
//       String? companyName,
//       pw.ThemeData theme,
//       ) {
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(32),
//         theme: theme,
//         build: (context) => [
//           _buildHeader(companyName ?? 'Your Company', 'Customer-wise Summary Report', fromDate, toDate),
//           pw.SizedBox(height: 25),
//
//           _buildSectionTitle('Customer Summary (One Entry Per Customer)'),
//           pw.SizedBox(height: 10),
//           _buildCustomerSummaryTable(customerSummaries),
//           pw.SizedBox(height: 25),
//
//           _buildFooter(),
//         ],
//       ),
//     );
//   }
//
//   static void _generateDetailedReport(
//       pw.Document pdf,
//       List<CustomerSummary> customerSummaries,
//       DateTime fromDate,
//       DateTime toDate,
//       String? companyName,
//       pw.ThemeData theme,
//       ) {
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(32),
//         theme: theme,
//         build: (context) => [
//           _buildHeader(companyName ?? 'Your Company', 'Detailed Customer Report', fromDate, toDate),
//           pw.SizedBox(height: 25),
//
//           _buildSectionTitle('Customer Details with Invoice IDs'),
//           pw.SizedBox(height: 10),
//           _buildDetailedCustomerTable(customerSummaries),
//           pw.SizedBox(height: 25),
//
//           _buildFooter(),
//         ],
//       ),
//     );
//   }
//
//   static void _generatePaymentReport(
//       pw.Document pdf,
//       List<CustomerSummary> customerSummaries,
//       DateTime fromDate,
//       DateTime toDate,
//       String? companyName,
//       pw.ThemeData theme,
//       ) {
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(32),
//         theme: theme,
//         build: (context) => [
//           _buildHeader(companyName ?? 'Your Company', 'Customer Payment Analysis', fromDate, toDate),
//           pw.SizedBox(height: 25),
//
//           _buildSectionTitle('Top 5 Customers'),
//           pw.SizedBox(height: 10),
//           _buildTopCustomersTable(customerSummaries.take(5).toList()),
//           pw.SizedBox(height: 20),
//
//           _buildSectionTitle('All Customers Payment Status'),
//           pw.SizedBox(height: 10),
//           _buildPaymentStatusTable(customerSummaries),
//           pw.SizedBox(height: 25),
//
//           _buildFooter(),
//         ],
//       ),
//     );
//   }
//
//   // // Customer Summary Table
//   // static pw.Widget _buildCustomerSummaryTable(List<CustomerSummary> customers) {
//   //   return pw.Container(
//   //     decoration: pw.BoxDecoration(
//   //         border: pw.Border.all(color: PdfColors.grey300),
//   //         borderRadius: pw.BorderRadius.circular(4)
//   //     ),
//   //     child: pw.Table(
//   //       border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//   //       columnWidths: {
//   //         0: pw.FlexColumnWidth(2.5),
//   //         1: pw.FlexColumnWidth(1),
//   //         2: pw.FlexColumnWidth(1.5),
//   //         3: pw.FlexColumnWidth(1.5),
//   //         4: pw.FlexColumnWidth(1.5),
//   //         5: pw.FlexColumnWidth(1),
//   //         6: pw.FlexColumnWidth(1.2),
//   //       },
//   //       children: [
//   //         pw.TableRow(
//   //           decoration: pw.BoxDecoration(color: PdfColors.grey200),
//   //           children: [
//   //             _buildTableCell('Customer Name', isHeader: true),
//   //             _buildTableCell('Invoices', isHeader: true, align: pw.TextAlign.center),
//   //             _buildTableCell('Total', isHeader: true, align: pw.TextAlign.right),
//   //             _buildTableCell('Received', isHeader: true, align: pw.TextAlign.right),
//   //             _buildTableCell('Pending', isHeader: true, align: pw.TextAlign.right),
//   //             _buildTableCell('Paid %', isHeader: true, align: pw.TextAlign.center),
//   //             _buildTableCell('Status', isHeader: true),
//   //           ],
//   //         ),
//   //         ...customers.asMap().entries.map((entry) {
//   //           final index = entry.key;
//   //           final customer = entry.value;
//   //
//   //           return pw.TableRow(
//   //             decoration: index % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
//   //             children: [
//   //               _buildTableCell(customer.customerName),
//   //               _buildTableCell('${customer.invoiceCount}', align: pw.TextAlign.center, isBold: true),
//   //               _buildTableCell(AppUtil.formatCurrency(customer.totalAmount), align: pw.TextAlign.right),
//   //               _buildTableCell(AppUtil.formatCurrency(customer.receivedAmount), align: pw.TextAlign.right),
//   //               _buildTableCell(AppUtil.formatCurrency(customer.pendingAmount), align: pw.TextAlign.right),
//   //               _buildTableCell('${customer.paymentPercentage.toStringAsFixed(1)}%', align: pw.TextAlign.center, isBold: true),
//   //               _buildTableCell(customer.overallStatus),
//   //             ],
//   //           );
//   //         }),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   // Payment Transactions Table - NEW STRUCTURE
//   static pw.Widget _buildCustomerSummaryTable(List<CustomerSummary> customers) {
//     int srNo = 0;
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//           border: pw.Border.all(color: PdfColors.grey300),
//           borderRadius: pw.BorderRadius.circular(4)
//       ),
//       child: pw.Table(
//         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//         columnWidths: {
//           0: pw.FlexColumnWidth(0.8),  // Sr.No
//           1: pw.FlexColumnWidth(1.5),  // Date
//           2: pw.FlexColumnWidth(1.5),  // Payment/Receipt
//           3: pw.FlexColumnWidth(2.5),  // Customer Name
//           4: pw.FlexColumnWidth(1.5),  // Amount
//           5: pw.FlexColumnWidth(2),    // Remarks
//         },
//         children: [
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//             children: [
//               _buildTableCell('Sr.No', isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Date', isHeader: true),
//               _buildTableCell('Type', isHeader: true),
//               _buildTableCell('Customer Name', isHeader: true),
//               _buildTableCell('Amount', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Remarks', isHeader: true),
//             ],
//           ),
//           ...customers.expand((customer) {
//             srNo++;
//             return [
//               pw.TableRow(
//                 decoration: srNo % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
//                 children: [
//                   _buildTableCell('$srNo', align: pw.TextAlign.center),
//                   _buildTableCell(DateFormat('dd/MM/yy').format(DateTime.now()), fontSize: 9),
//                   _buildTableCell(customer.receivedAmount > 0 ? 'Receipt' : 'Payment', fontSize: 9),
//                   _buildTableCell(customer.customerName, fontSize: 9),
//                   _buildTableCell(AppUtil.formatCurrency(customer.totalAmount), align: pw.TextAlign.right, fontSize: 9),
//                   _buildTableCell('${customer.invoiceCount} Invoice(s): ${customer.invoiceIds.take(2).join(", ")}${customer.invoiceIds.length > 2 ? "..." : ""}', fontSize: 8),
//                 ],
//               ),
//             ];
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//   // Detailed Customer Table with Invoice IDs
//   static pw.Widget _buildDetailedCustomerTable(List<CustomerSummary> customers) {
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//           border: pw.Border.all(color: PdfColors.grey300),
//           borderRadius: pw.BorderRadius.circular(4)
//       ),
//       child: pw.Table(
//         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//         columnWidths: {
//           0: pw.FlexColumnWidth(2),
//           1: pw.FlexColumnWidth(3),
//           2: pw.FlexColumnWidth(1.5),
//           3: pw.FlexColumnWidth(1.5),
//           4: pw.FlexColumnWidth(1),
//           5: pw.FlexColumnWidth(1.2),
//         },
//         children: [
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//             children: [
//               _buildTableCell('Customer', isHeader: true, fontSize: 9),
//               _buildTableCell('Invoice IDs', isHeader: true, fontSize: 9),
//               _buildTableCell('Total', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
//               _buildTableCell('Pending', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
//               _buildTableCell('Paid %', isHeader: true, fontSize: 9, align: pw.TextAlign.center),
//               _buildTableCell('Status', isHeader: true, fontSize: 9),
//             ],
//           ),
//           ...customers.asMap().entries.map((entry) {
//             final index = entry.key;
//             final customer = entry.value;
//
//             return pw.TableRow(
//               decoration: index % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
//               children: [
//                 _buildTableCell(customer.customerName, fontSize: 8),
//                 _buildTableCell(customer.invoiceIds.take(3).join(', ') + (customer.invoiceIds.length > 3 ? '...' : ''), fontSize: 7),
//                 _buildTableCell(AppUtil.formatCurrency(customer.totalAmount), fontSize: 8, align: pw.TextAlign.right),
//                 _buildTableCell(AppUtil.formatCurrency(customer.pendingAmount), fontSize: 8, align: pw.TextAlign.right),
//                 _buildTableCell('${customer.paymentPercentage.toStringAsFixed(1)}%', fontSize: 8, align: pw.TextAlign.center, isBold: true),
//                 _buildTableCell(customer.overallStatus, fontSize: 8),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   // Top Customers Table
//   static pw.Widget _buildTopCustomersTable(List<CustomerSummary> topCustomers) {
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//           border: pw.Border.all(color: PdfColors.grey300),
//           borderRadius: pw.BorderRadius.circular(4)
//       ),
//       child: pw.Table(
//         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//         children: [
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//             children: [
//               _buildTableCell('Rank', isHeader: true, align: pw.TextAlign.center),
//               _buildTableCell('Customer Name', isHeader: true),
//               _buildTableCell('Total Amount', isHeader: true, align: pw.TextAlign.right),
//               _buildTableCell('Payment Status', isHeader: true, align: pw.TextAlign.center),
//             ],
//           ),
//           ...topCustomers.asMap().entries.map((entry) {
//             return pw.TableRow(
//               decoration: entry.key % 2 == 0 ? pw.BoxDecoration(color: PdfColors.blue50) : null,
//               children: [
//                 _buildTableCell('${entry.key + 1}', isBold: true, align: pw.TextAlign.center),
//                 _buildTableCell(entry.value.customerName),
//                 _buildTableCell(AppUtil.formatCurrency(entry.value.totalAmount), align: pw.TextAlign.right, isBold: true),
//                 _buildTableCell('${entry.value.paymentPercentage.toStringAsFixed(1)}% Paid', align: pw.TextAlign.center),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   // Payment Status Table
//   static pw.Widget _buildPaymentStatusTable(List<CustomerSummary> customers) {
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//           border: pw.Border.all(color: PdfColors.grey300),
//           borderRadius: pw.BorderRadius.circular(4)
//       ),
//       child: pw.Table(
//         border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey300)),
//         children: [
//           pw.TableRow(
//             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//             children: [
//               _buildTableCell('Customer', isHeader: true, fontSize: 9),
//               _buildTableCell('Invoices', isHeader: true, fontSize: 9, align: pw.TextAlign.center),
//               _buildTableCell('Paid', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
//               _buildTableCell('Pending', isHeader: true, fontSize: 9, align: pw.TextAlign.right),
//               _buildTableCell('Paid %', isHeader: true, fontSize: 9, align: pw.TextAlign.center),
//               _buildTableCell('Status', isHeader: true, fontSize: 9),
//             ],
//           ),
//           ...customers.asMap().entries.map((entry) {
//             final index = entry.key;
//             final customer = entry.value;
//
//             return pw.TableRow(
//               decoration: index % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
//               children: [
//                 _buildTableCell(customer.customerName, fontSize: 8),
//                 _buildTableCell('${customer.invoiceCount}', fontSize: 8, align: pw.TextAlign.center),
//                 _buildTableCell(AppUtil.formatCurrency(customer.receivedAmount), fontSize: 8, align: pw.TextAlign.right),
//                 _buildTableCell(AppUtil.formatCurrency(customer.pendingAmount), fontSize: 8, align: pw.TextAlign.right),
//                 _buildTableCell('${customer.paymentPercentage.toStringAsFixed(1)}%', fontSize: 8, align: pw.TextAlign.center, isBold: true),
//                 _buildTableCell(customer.overallStatus, fontSize: 8),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
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
//   static pw.Widget _buildTableCell(
//       String text, {
//         bool isHeader = false,
//         double fontSize = 10,
//         bool isBold = false,
//         pw.TextAlign align = pw.TextAlign.left,
//       }) {
//     return pw.Container(
//       padding: pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: fontSize,
//           fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: isHeader ? PdfColors.grey800 : PdfColors.black,
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
//             pw.Text(
//               'Customer-wise grouped report',
//               style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
//             ),
//             pw.Text(
//               'Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
//               style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
//             ),
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
//       final fileName = '${reportType.replaceAll(' ', '_')}_$timestamp.pdf';
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
// }

///21-10 12:28 working
// class PaymentDetailsController extends GetxController {
//   var invoices = <Invoice>[].obs;
//   var isLoading = true.obs;
//   var searchQuery = ''.obs;
//
//   // Report Generation State
//   var selectedExportFormat = 'PDF'.obs;
//   var fromDate = Rx<DateTime?>(null);
//   var toDate = Rx<DateTime?>(null);
//   var isGeneratingReport = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadInvoices();
//     toDate.value = DateTime.now();
//     fromDate.value = DateTime.now().subtract(const Duration(days: 30));
//   }
//
//   Future<void> loadInvoices() async {
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
//       List<Invoice> allInvoices = await GoogleSheetService.getInvoices(type: "INV");
//       if (allInvoices.isEmpty) {
//         allInvoices = await GoogleSheetService.getInvoices();
//       }
//
//       invoices.value = allInvoices.where((inv) => inv.userId == currentUserId).toList();
//
//       print("✅ Loaded ${invoices.length} user invoices");
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load invoices: ${e.toString()}',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade800,
//         icon: Icon(Icons.error_outline, color: Colors.red.shade700),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Get filtered customer summaries based on search
//   List<CustomerSummary> getFilteredCustomerSummaries() {
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
//       final filteredInvoices = getFilteredInvoices();
//
//       if (filteredInvoices.isEmpty) {
//         Get.snackbar(
//           'No Data',
//           'No invoices found for the selected date range',
//           backgroundColor: Colors.blue.shade100,
//           colorText: Colors.blue.shade800,
//           icon: const Icon(Icons.info_outline, color: Colors.blue),
//         );
//         isGeneratingReport.value = false;
//         return;
//       }
//
//       await Future.delayed(const Duration(seconds: 1));
//
//       switch (selectedExportFormat.value) {
//         case 'PDF':
//           await _generatePDFReport(filteredInvoices);
//           break;
//         case 'Excel':
//           await _generateExcelReport(filteredInvoices);
//           break;
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
//   Future<void> _generatePDFReport(List<Invoice> invoices) async {
//     print("📄 Generating PDF report with ${invoices.length} invoices");
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       String? companyName = user?.displayName ?? 'Your Company';
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
//   Future<void> _generateExcelReport(List<Invoice> invoices) async {
//     print("📊 Generating Excel report with ${invoices.length} invoices");
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       String? companyName = user?.displayName ?? 'Your Company';
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

// ==================== UPDATED REPORT DATA CALCULATOR ====================

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

  @override
  void onInit() {
    super.onInit();
    loadData();
    toDate.value = DateTime.now();
    fromDate.value = DateTime.now().subtract(const Duration(days: 30));
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