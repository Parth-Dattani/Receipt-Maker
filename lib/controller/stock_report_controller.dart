// ============================================
// 1. Add this method to DashboardController
// ============================================

// In DashboardController class, add these methods:


import 'dart:io';

import 'package:demo_prac_getx/controller/bash_controller.dart';
import 'package:excel/excel.dart' show Sheet, Excel, TextCellValue, DoubleCellValue, IntCellValue;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constant/app_colors.dart';
import '../model/model.dart';
import '../services/service.dart';
import '../utils/calculations.dart';
import 'controller.dart';

class StockReportController extends BaseController  {
  final isLoading = false.obs;
  final stockItems = <Item>[].obs;
  final filteredItems = <Item>[].obs;
  final searchQuery = ''.obs;

  // Statistics
  final totalItems = 0.obs;
  final totalStockValue = 0.0.obs;
  final lowStockItems = 0.obs;
  final outOfStockItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStockReport();
  }

  Future<void> loadStockReport() async {
    try {
      isLoading.value = true;

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Fetch items from Google Sheets
      final items = await GoogleSheetService.getItems(userId: userId);

      stockItems.assignAll(items);
      filteredItems.assignAll(items);

      calculateStatistics();

    } catch (e) {
      print("❌ Error loading stock report: $e");
      Get.snackbar(
        'Error',
        'Failed to load stock report',
        backgroundColor: Colors.red.shade100,
      );
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
      // Calculate total stock value
      totalValue += (item.price ?? 0) * (item.currentStock ?? 0);

      // Count low stock items (less than 10)
      if ((item.currentStock ?? 0) > 0 && (item.currentStock ?? 0) < 10) {
        lowStock++;
      }

      // Count out of stock items
      if ((item.currentStock ?? 0) == 0) {
        outOfStock++;
      }
    }

    totalStockValue.value = totalValue;
    lowStockItems.value = lowStock;
    outOfStockItems.value = outOfStock;
  }

  void filterItems(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredItems.assignAll(stockItems);
      return;
    }

    final filtered = stockItems.where((item) {
      return (item.itemName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (item.itemId?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    filteredItems.assignAll(filtered);
  }

  Future<void> exportStockReportPDF() async {
    try {
      isLoading.value = true;

      // ✅ Load custom fonts for Rupee symbol
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final iconData = await rootBundle.load("assets/fonts/NotoEmoji-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());
      final notoEmoji = pw.Font.ttf(iconData.buffer.asByteData());

      final pdf = pw.Document();

      // Get company data
      final dashController = Get.find<DashboardController>();
      final companyName = dashController.companyName;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(0), // ✅ Remove default margin for full-width header
          build: (pw.Context context) => [
            // ✅ FULL-WIDTH Header
            pw.Container(
              width: double.infinity, // ✅ Full width
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.teal700,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'STOCK REPORT',
                    style: pw.TextStyle(
                      font: customFont,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                      font: customFont,
                      fontSize: 14,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: customFont,
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.Padding(
              padding: pw.EdgeInsets.all(20), // ✅ Add padding for content below header
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 10),

                  // Statistics
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

                  // ✅ Table WITHOUT Item ID column
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: pw.FlexColumnWidth(2.5), // Item Name - wider
                      1: pw.FlexColumnWidth(1.2), // Price
                      2: pw.FlexColumnWidth(1), // Unit
                      3: pw.FlexColumnWidth(1.2), // Current Stock
                      4: pw.FlexColumnWidth(1.5), // Stock Value
                      5: pw.FlexColumnWidth(1.3), // Status
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          _buildTableCell('Item Name', isHeader: true, font: customFont, align: pw.TextAlign.left),
                          _buildTableCell('Price', isHeader: true, font: customFont, align: pw.TextAlign.right),
                          _buildTableCell('Unit', isHeader: true, font: customFont),
                          _buildTableCell('Current Stock', isHeader: true, font: customFont),
                          _buildTableCell('Stock Value', isHeader: true, font: customFont, align: pw.TextAlign.right),
                          _buildTableCell('Status', isHeader: true, font: customFont),
                        ],
                      ),

                      // ✅ Data rows - WITHOUT Item ID
                      ...stockItems.map((item) {
                        final stockValue = (item.price ?? 0) * (item.currentStock ?? 0);
                        final stock = item.currentStock ?? 0;
                        String status = stock == 0 ? 'Out of Stock' :
                        stock < 10 ? 'Low Stock' : 'In Stock';

                        return pw.TableRow(
                          children: [
                            _buildTableCell(item.itemName ?? '-', font: customFont, align: pw.TextAlign.left),
                            _buildTableCell('₹${item.price?.toStringAsFixed(2) ?? "0.00"}', font: customFont, align: pw.TextAlign.right),
                          _buildTableCell(item.unitOfMeasurement ?? '-', font: customFont),
                            _buildTableCell('${item.currentStock ?? 0}', font: customFont),
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

      // Save and open PDF
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Stock_Report_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      Get.snackbar(
        'Success',
        'Stock report exported successfully',
        backgroundColor: Colors.green.shade100,
        icon: Icon(Icons.check_circle, color: Colors.green),
      );

      OpenFile.open(file.path);

    } catch (e) {
      print("❌ Error exporting stock report: $e");
      Get.snackbar(
        'Error',
        'Failed to export report: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  pw.Widget _buildStatBox(String label, String value, PdfColor color, pw.Font font) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font, // ✅ Use custom font
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font, // ✅ Use custom font
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, required pw.Font font, pw.TextAlign? align}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font, // ✅ Use custom font for Rupee symbol
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align ?? pw.TextAlign.center,
      ),
    );
  }

  Future<void> exportStockReportExcel() async {
    try {
      isLoading.value = true;

      var excel = Excel.createExcel();
      Sheet sheet = excel['Stock_Report'];

      // ✅ Header row WITHOUT Item ID
      sheet.appendRow([
        TextCellValue('Item Name'),
        TextCellValue('Price'),
        TextCellValue('GST %'),
        TextCellValue('Unit'),
        TextCellValue('Current Stock'),
        TextCellValue('Stock Value'),
        TextCellValue('Status'),
      ]);

      // ✅ Data rows WITHOUT Item ID
      for (var item in stockItems) {
        final stockValue = (item.price ?? 0) * (item.currentStock ?? 0);
        final stock = item.currentStock ?? 0;
        String status = stock == 0 ? 'Out of Stock' :
        stock < 10 ? 'Low Stock' : 'In Stock';

        sheet.appendRow([
          TextCellValue(item.itemName ?? '-'),
          DoubleCellValue(item.price ?? 0),
          DoubleCellValue(item.gstPercent ?? 0),
          TextCellValue(item.unitOfMeasurement ?? '-'),
          IntCellValue(item.currentStock ?? 0),
          DoubleCellValue(stockValue),
          TextCellValue(status),
        ]);
      }

      // Save file
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Stock_Report_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.xlsx');
      file.writeAsBytesSync(excel.encode()!);

      Get.snackbar(
        'Success',
        'Stock report exported successfully',
        backgroundColor: Colors.green.shade100,
        icon: Icon(Icons.check_circle, color: Colors.green),
      );

      OpenFile.open(file.path);

    } catch (e) {
      print("❌ Error exporting stock report: $e");
      Get.snackbar(
        'Error',
        'Failed to export report',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }
}