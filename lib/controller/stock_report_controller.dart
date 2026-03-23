// ============================================
// 1. Add this method to DashboardController
// ============================================

// In DashboardController class, add these methods:


import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:GetYourInvoice/controller/bash_controller.dart';
import 'package:excel/excel.dart' show Sheet, Excel, TextCellValue, DoubleCellValue;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constant/app_colors.dart';
import '../model/model.dart';
import '../services/service.dart';
import '../utils/calculations.dart';
import 'controller.dart';

class StockReportController extends BaseController {
  final isLoading = false.obs;
  final stockItems = <Item>[].obs;
  final filteredItems = <Item>[].obs;
  final searchQuery = ''.obs;
  final filterStatus = 'all'.obs; // ✅ NEW: all, in_stock, low_stock, out_of_stock

  // Statistics
  final totalItems = 0.obs;
  final totalStockValue = 0.0.obs;
  final lowStockItems = 0.obs;
  final outOfStockItems = 0.obs;


  @override
  void onInit() {
    super.onInit();
    loadStockReport();
    // ✅ Re-apply filter when filterStatus changes
    ever(filterStatus, (_) => _applyFilters());
  }

  Future<void> loadStockReport() async {
    try {
      isLoading.value = true;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final items = await GoogleSheetService.getItems(userId: userId);
      stockItems.assignAll(items);
      _applyFilters();
      calculateStatistics();
    } catch (e) {
      print('❌ Error loading stock report: $e');
      Get.snackbar('Error', 'Failed to load stock report',
          backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  void calculateStatistics() {
    totalItems.value = stockItems.length;
    double totalValue = 0;
    int lowStock = 0;
    int outOfStock = 0;

    for (var item in stockItems) {
      totalValue += (item.price) * (item.currentStock);
      if (item.currentStock > 0 && item.currentStock < 10) lowStock++;
      if (item.currentStock == 0) outOfStock++;
    }

    totalStockValue.value = totalValue;
    lowStockItems.value = lowStock;
    outOfStockItems.value = outOfStock;
  }

  // ✅ Search — apply both search + status filter
  void filterItems(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // ✅ Combined filter: search + status chip
  void _applyFilters() {
    final query = searchQuery.value.toLowerCase();

    var result = stockItems.where((item) {
      // Search filter
      final matchSearch = query.isEmpty ||
          (item.itemName.toLowerCase().contains(query)) ||
          (item.itemId.toLowerCase().contains(query));

      // Status filter
      final stock = item.currentStock;
      bool matchStatus;
      switch (filterStatus.value) {
        case 'in_stock':
          matchStatus = stock >= 10;
          break;
        case 'low_stock':
          matchStatus = stock > 0 && stock < 10;
          break;
        case 'out_of_stock':
          matchStatus = stock == 0;
          break;
        default: // 'all'
          matchStatus = true;
      }

      return matchSearch && matchStatus;
    }).toList();

    filteredItems.assignAll(result);
  }

  // ── PDF Export ──
  Future<void> exportStockReportPDF() async {
    try {
      isLoading.value = true;

      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());
      final pdf = pw.Document();

      final dashController = Get.find<DashboardController>();
      final companyName = dashController.companyName;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) => [
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(color: PdfColors.teal700),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('STOCK REPORT', style: pw.TextStyle(font: customFont, fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 5),
                  pw.Text(companyName, style: pw.TextStyle(font: customFont, fontSize: 14, color: PdfColors.white)),
                  pw.SizedBox(height: 5),
                  pw.Text('Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: pw.TextStyle(font: customFont, fontSize: 10, color: PdfColors.white)),
                ],
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(20),
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox('Total Items', '${totalItems.value}', PdfColors.blue, customFont),
                      _buildStatBox('Total Value', '₹${AppUtil.formatCurrency(totalStockValue.value)}', PdfColors.green, customFont),
                      _buildStatBox('Low Stock', '${lowStockItems.value}', PdfColors.orange, customFont),
                      _buildStatBox('Out of Stock', '${outOfStockItems.value}', PdfColors.red, customFont),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: pw.FlexColumnWidth(2.5),
                      1: pw.FlexColumnWidth(1.2),
                      2: pw.FlexColumnWidth(1),
                      3: pw.FlexColumnWidth(1.2),
                      4: pw.FlexColumnWidth(1.5),
                      5: pw.FlexColumnWidth(1.3),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          _buildTableCell('Item Name', isHeader: true, font: customFont, align: pw.TextAlign.left),
                          _buildTableCell('Price', isHeader: true, font: customFont, align: pw.TextAlign.right),
                          _buildTableCell('Unit', isHeader: true, font: customFont),
                          _buildTableCell('Stock', isHeader: true, font: customFont),
                          _buildTableCell('Stock Value', isHeader: true, font: customFont, align: pw.TextAlign.right),
                          _buildTableCell('Status', isHeader: true, font: customFont),
                        ],
                      ),
                      ...stockItems.map((item) {
                        final stockValue = item.price * item.currentStock;
                        final stock = item.currentStock;
                        final status = stock == 0 ? 'Out of Stock' : stock < 10 ? 'Low Stock' : 'In Stock';
                        return pw.TableRow(
                          children: [
                            _buildTableCell(item.itemName, font: customFont, align: pw.TextAlign.left),
                            _buildTableCell('₹${item.price.toStringAsFixed(2)}', font: customFont, align: pw.TextAlign.right),
                            _buildTableCell(item.unitOfMeasurement.isEmpty ? '-' : item.unitOfMeasurement, font: customFont),
                            _buildTableCell('${item.currentStock}', font: customFont),
                            _buildTableCell('₹${AppUtil.formatCurrency(stockValue)}', font: customFont, align: pw.TextAlign.right),
                            _buildTableCell(status, font: customFont),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      if (kIsWeb) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Stock_Report_${DateFormat('ddMMyyyy').format(DateTime.now())}.pdf',
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/Stock_Report_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.pdf');
        await file.writeAsBytes(await pdf.save());
        Get.snackbar('Success', 'Stock report exported', backgroundColor: Colors.green.shade100);
        OpenFile.open(file.path);
      }
    } catch (e) {
      print('❌ Error exporting PDF: $e');
      Get.snackbar('Error', 'Failed to export: ${e.toString()}', backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  pw.Widget _buildStatBox(String label, String value, PdfColor color, pw.Font font) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: color), borderRadius: pw.BorderRadius.circular(5)),
      child: pw.Column(children: [
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
      ]),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, required pw.Font font, pw.TextAlign? align}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: isHeader ? 10 : 9, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal),
        textAlign: align ?? pw.TextAlign.center,
      ),
    );
  }

  // ── Excel Export ──
  Future<void> exportStockReportExcel() async {
    try {
      isLoading.value = true;

      var excel = Excel.createExcel();
      Sheet sheet = excel['Stock_Report'];

      sheet.appendRow([
        TextCellValue('Item Name'),
        TextCellValue('Price'),
        TextCellValue('GST %'),
        TextCellValue('Unit'),
        TextCellValue('Current Stock'),
        TextCellValue('Stock Value'),
        TextCellValue('Status'),
      ]);

      for (var item in stockItems) {
        final stockValue = item.price * item.currentStock;
        final stock = item.currentStock;
        final status = stock == 0 ? 'Out of Stock' : stock < 10 ? 'Low Stock' : 'In Stock';
        sheet.appendRow([
          TextCellValue(item.itemName),
          DoubleCellValue(item.price),
          DoubleCellValue(item.gstPercent ?? 0),
          TextCellValue(item.unitOfMeasurement.isEmpty ? '-' : item.unitOfMeasurement),
          DoubleCellValue(item.currentStock),
          DoubleCellValue(stockValue),
          TextCellValue(status),
        ]);
      }

      final fileName = 'Stock_Report_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      if (kIsWeb) {
        final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        Get.snackbar('Success', 'Excel downloaded: $fileName', backgroundColor: Colors.green.shade100);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        file.writeAsBytesSync(fileBytes);
        Get.snackbar('Success', 'Stock report exported', backgroundColor: Colors.green.shade100);
        OpenFile.open(file.path);
      }
    } catch (e) {
      print('❌ Error exporting Excel: $e');
      Get.snackbar('Error', 'Failed to export', backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }
}