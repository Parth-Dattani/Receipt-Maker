import 'dart:io';
import 'dart:ui';
import 'package:demo_prac_getx/utils/calculations.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' show Font;
import 'package:open_file/open_file.dart';
import '../constant/constant.dart';
import '../controller/new_invoice_controller.dart';
import '../model/model.dart';

import 'package:printing/printing.dart';

import '../services/service.dart';




class InvoiceHelper {

  static Future<void> generateAndShareInvoice(
      List<Invoice> invoices,
      String userName,
      String phoneNumber,
      String customerEmail,
      String customerPAN,
      String customerGST,
      String customerAddress,
      double subtotal,
      String invoiceDate,
      double totalAmount,
      String notes,
      Map<String, dynamic> companyData,
      InvoiceType invoiceType,
      double gstAmount,
      String dueDate,  // ✅ ADD THIS PARAMETER
      ) async {
    try {
      final pdf = pw.Document();

      // Load custom font (Rupee + Emoji)
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final iconData = await rootBundle.load("assets/fonts/NotoEmoji-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());
      final notoEmoji = pw.Font.ttf(iconData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String invoiceId = invoices.isNotEmpty ? invoices.first.invoiceId : "UNKNOWN";

      // Company Info
      String companyName = companyData['companyName'] ?? 'Your Company Name';
      String companyAddress = companyData['address'] ?? 'Company Address';
      String companyCity = companyData['city'] ?? 'City';
      String companyState = companyData['state'] ?? 'State';
      String companyPin = companyData['pincode'] ?? 'PIN Code';
      String companyPhone = companyData['phone'] ?? '+91 XXXXXXXXXX';
      String companyEmail = companyData['userEmail'] ?? 'company@email.com';
      String companyGst = companyData['gst'] ?? 'XXXXXXXXXXXXXXX';
      String companyBank = companyData['bankName'] ?? 'Bank Name';
      String companyAccount = companyData['accountNumber'] ?? 'Account Number';
      String companyIfsc = companyData['ifsc'] ?? 'IFSC Code';
      String companyPan = companyData['pan'] ?? 'PAN Number';

      // Neutral Colors
      final PdfColor primaryColor = PdfColors.grey800;
      final PdfColor headerBg = PdfColors.grey100;
      final PdfColor borderColor = PdfColors.grey300;
      final PdfColor rowAlt = PdfColors.grey50;

      final String documentTitle =
      invoiceType == InvoiceType.quotation ? 'QUOTATION' : 'INVOICE';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.all(25),
          build: (pw.Context context) {
            return [
              /// Header
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: headerBg,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    /// Company Info
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(companyName.toUpperCase(),
                              style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text(companyAddress,
                              style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                          pw.Text('$companyCity, $companyState - $companyPin',
                              style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                          pw.SizedBox(height: 3),
                          pw.Text("Phone: $companyPhone",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("Email: $companyEmail",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("PAN: $companyPan",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("GST: $companyGst",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                        ],
                      ),
                    ),

                    /// Invoice Badge - ✅ UPDATED WITH DUE DATE
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(documentTitle,
                              style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('#$invoiceId',
                              style: pw.TextStyle(
                                  color: PdfColors.grey600, fontSize: 10)),
                          pw.SizedBox(height: 6),
                          // ✅ Invoice Date
                          pw.Row(
                            children: [
                              pw.Text('Date: ',
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.grey600,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(invoiceDate,
                                  style: pw.TextStyle(
                                      color: PdfColors.grey700, fontSize: 9)),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          // ✅ Due Date
                          pw.Row(
                            children: [
                              pw.Text('Due: ',
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.grey600,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(dueDate,
                                  style: pw.TextStyle(
                                      color: PdfColors.red700,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              /// Bill To
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TO:',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                            fontSize: 12)),
                    pw.SizedBox(height: 6),
                    pw.Text(userName,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    if (customerAddress.isNotEmpty)
                      pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                    pw.Text('Phone: $phoneNumber',
                        style: pw.TextStyle(fontSize: 9)),
                    if (customerEmail.isNotEmpty)
                      pw.Text('Email: $customerEmail',
                          style: pw.TextStyle(fontSize: 9)),
                    if (customerPAN.isNotEmpty)
                      pw.Text('PAN: $customerPAN',
                          style: pw.TextStyle(fontSize: 9)),
                    if (customerGST.isNotEmpty)
                      pw.Text('GST: $customerGST',
                          style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              /// Items Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
                    verticalInside: pw.BorderSide(color: borderColor, width: 0.5),
                  ),
                  columnWidths: AppConstants.withGST.value
                      ? {
                    0: pw.FixedColumnWidth(25),
                    1: pw.FlexColumnWidth(3.5),
                    2: pw.FixedColumnWidth(50),
                    3: pw.FixedColumnWidth(70),
                    4: pw.FixedColumnWidth(85),
                    5: pw.FixedColumnWidth(70),
                    6: pw.FixedColumnWidth(85),
                  }
                      : {
                    0: pw.FixedColumnWidth(25),
                    1: pw.FlexColumnWidth(4),
                    2: pw.FixedColumnWidth(60),
                    3: pw.FixedColumnWidth(85),
                    4: pw.FixedColumnWidth(95),
                  },
                  children: [
                    /// Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _tableHeader('#'),
                        _tableHeader('DESCRIPTION'),
                        _tableHeader('QTY', align: pw.TextAlign.right),
                        _tableHeader('PRICE', align: pw.TextAlign.right),
                        _tableHeader('AMOUNT', align: pw.TextAlign.right),
                        if (AppConstants.withGST.value)
                          _tableHeader('GST', align: pw.TextAlign.right),
                        if (AppConstants.withGST.value)
                          _tableHeader('NET', align: pw.TextAlign.right),
                      ],
                    ),

                    /// Data Rows
                    ...invoices.asMap().entries.map((entry) {
                      int index = entry.key;
                      Invoice item = entry.value;
                      final isEven = index % 2 == 0;

                      double baseAmount = (item.price! * item.qty!);
                      double gstValue = baseAmount * (item.gst ?? 0) / 100;
                      double netAmount = baseAmount + gstValue;

                      InvoiceItem? actualItem;
                      if (item.items != null && item.items!.isNotEmpty) {
                        actualItem = item.items!.first;
                      }
                      // ✅ FIX: Use actualItem.itemName for the main name
                      String displayItemName = actualItem?.itemName ?? item.itemName ?? '';


                      // ✅ FIX: Check if there's a DIFFERENT description (not the same as item name)
                      bool hasServiceDescription = actualItem != null &&
                          actualItem.description.isNotEmpty &&
                          actualItem.description != actualItem.itemName &&
                          actualItem.description.trim() != displayItemName.trim();

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isEven ? PdfColors.white : rowAlt,
                        ),
                        children: [
                          _tableCell('${index + 1}', align: pw.TextAlign.center),

                          // ✅ FIXED: Show item name + optional description
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Main item name in bold
                                pw.Text(
                                  displayItemName,
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    color: primaryColor,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                // Description below in italic (ONLY if different from item name)
                                if (hasServiceDescription) ...[
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    actualItem!.description,
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      color: PdfColors.grey700,
                                      fontStyle: pw.FontStyle.italic,
                                      height: 1.2,
                                    ),
                                    maxLines: 3,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          //_tableCell(item.itemName ?? '', align: pw.TextAlign.left),
                          _tableCell(item.qty!.toStringAsFixed(3), align: pw.TextAlign.right),
                          _tableCell(AppUtil.formatCurrency(item.price!), align: pw.TextAlign.right),
                          _tableCell(AppUtil.formatCurrency(baseAmount), align: pw.TextAlign.right),
                          if (AppConstants.withGST.value)
                            _tableCell(AppUtil.formatCurrency(gstValue), align: pw.TextAlign.right),
                          if (AppConstants.withGST.value)
                            _tableCell(AppUtil.formatCurrency(netAmount), align: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              /// Notes + Totals
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  /// Notes & Bank
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('NOTES',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 11)),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            notes.isNotEmpty
                                ? notes
                                : 'Thank you for your business!',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.SizedBox(height: 15),
                          pw.Text('BANK DETAILS',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 11)),
                          pw.SizedBox(height: 5),
                          pw.Text('Bank: $companyBank',
                              style: pw.TextStyle(fontSize: 9)),
                          pw.Text('A/C: $companyAccount',
                              style: pw.TextStyle(fontSize: 9)),
                          pw.Text('IFSC: $companyIfsc',
                              style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  /// Totals
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildTotalRow('Subtotal', subtotal, formatted: true),
                          if (AppConstants.withGST.value)
                            _buildTotalRow('CGST', gstAmount / 2, formatted: true),
                          if (AppConstants.withGST.value)
                            _buildTotalRow('SGST', gstAmount / 2, formatted: true),
                          pw.Divider(color: borderColor, height: 20),
                          _buildTotalRow('TOTAL', totalAmount,
                              formatted: true,
                              isTotal: true,
                              isBold: true,
                              primaryColor: primaryColor),
                          pw.SizedBox(height: 12),
                          pw.Container(
                            width: double.infinity,
                            padding: pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(5),
                            ),
                            child: pw.Text(
                              'Amount in Words:\n${_numberToWords(totalAmount)}',
                              style: pw.TextStyle(fontSize: 8, color: primaryColor),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 25),

              /// Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 5),
                      pw.Text('Customer Signature',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 5),
                      pw.Text('Authorized Signature',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business! • This is a computer generated invoice',
                  style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                      fontStyle: pw.FontStyle.italic),
                ),
              ),

              pw.Spacer(),

              /// Advertise Footer
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("inteligenttech.in",
                        style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text("+91 9876543210",
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final String filePrefix =
      invoiceType == InvoiceType.quotation ? 'Quotation' : 'Invoice';
      final filePath = '${directory.path}/${filePrefix}_${invoiceId}_$userName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ PDF Saved: $filePath");

      await Share.shareXFiles([XFile(filePath)], text: '$documentTitle - $invoiceId');
    } catch (e) {
      print("❌ Error generating PDF: $e");
    }
  }

  ///// Generate PDF specifically for challan-based invoiceItems
  static Future<void> generateAndShareInvoiceFromChallan(
      List<dynamic> invoiceItems,
      String invoiceId,
      String invoiceDate,
      String fromDate,
      String toDate,
      String userName,
      String phoneNumber,
      String customerEmail,
      String customerPAN,
      String customerGST,
      String customerAddress,
      double subtotal,
      double taxAmount,
      double totalAmount,
      String notes,
      Map<String, dynamic> companyData,
      InvoiceType invoiceType,
      double gstAmount,
      String dueDate,  // ✅ ADD THIS PARAMETER
      ) async {
    try {
      final pdf = pw.Document();

      // Load custom font (Rupee + Emoji)
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final iconData = await rootBundle.load("assets/fonts/NotoEmoji-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());
      final notoEmoji = pw.Font.ttf(iconData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      // Company Info
      String companyName = companyData['companyName'] ?? 'Your Company Name';
      String companyAddress = companyData['address'] ?? 'Company Address';
      String companyCity = companyData['city'] ?? 'City';
      String companyState = companyData['state'] ?? 'State';
      String companyPin = companyData['pincode'] ?? 'PIN Code';
      String companyPhone = companyData['phone'] ?? '+91 XXXXXXXXXX';
      String companyEmail = companyData['userEmail'] ?? 'company@email.com';
      String companyGst = companyData['gst'] ?? 'XXXXXXXXXXXXXXX';
      String companyBank = companyData['bankName'] ?? 'Bank Name';
      String companyAccount = companyData['accountNumber'] ?? 'Account Number';
      String companyIfsc = companyData['ifsc'] ?? 'IFSC Code';
      String companyPan = companyData['pan'] ?? 'PAN Number';

      // Neutral Colors
      final PdfColor primaryColor = PdfColors.grey800;
      final PdfColor headerBg = PdfColors.grey100;
      final PdfColor borderColor = PdfColors.grey300;
      final PdfColor rowAlt = PdfColors.grey50;

      final String documentTitle =
      invoiceType == InvoiceType.quotation ? 'QUOTATION' : 'INVOICE';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.all(25),
          build: (pw.Context context) {
            return [
              /// Header
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: headerBg,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    /// Company Info
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(companyName.toUpperCase(),
                              style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text(companyAddress,
                              style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                          pw.Text('$companyCity, $companyState - $companyPin',
                              style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                          pw.SizedBox(height: 3),
                          pw.Text("Phone: $companyPhone",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("Email: $companyEmail",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("PAN: $companyPan",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("GST: $companyGst",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                        ],
                      ),
                    ),

                    /// Invoice Badge - ✅ UPDATED WITH DUE DATE
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(documentTitle,
                              style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('#$invoiceId',
                              style: pw.TextStyle(
                                  color: PdfColors.grey600, fontSize: 10)),
                          pw.SizedBox(height: 6),
                          // ✅ Invoice Date
                          pw.Row(
                            children: [
                              pw.Text('Date: ',
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.grey600,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(invoiceDate,
                                  style: pw.TextStyle(
                                      color: PdfColors.grey700, fontSize: 9)),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          // ✅ Due Date
                          pw.Row(
                            children: [
                              pw.Text('Due: ',
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.grey600,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(dueDate,
                                  style: pw.TextStyle(
                                      color: PdfColors.red700,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              /// Bill To & Challan Date Range
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    /// Left - Customer Details
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('TO:',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 12)),
                          pw.SizedBox(height: 6),
                          pw.Text(userName,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          if (customerAddress.isNotEmpty)
                            pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 3),
                          if (phoneNumber.isNotEmpty)
                            pw.Text('Phone: $phoneNumber',
                                style: pw.TextStyle(fontSize: 9)),
                          if (customerEmail.isNotEmpty)
                            pw.Text('Email: $customerEmail',
                                style: pw.TextStyle(fontSize: 9)),
                          if (customerPAN.isNotEmpty)
                            pw.Text('PAN: $customerPAN',
                                style: pw.TextStyle(fontSize: 9)),
                          if (customerGST.isNotEmpty)
                            pw.Text('GST: $customerGST',
                                style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),

                    /// Right - Challan Date Range
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Challan:',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                                fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text('From: ${AppUtil.formatDate(fromDate)}',
                            style: pw.TextStyle(fontSize: 9)),
                        pw.Text('To: ${AppUtil.formatDate(toDate)}',
                            style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              /// Items Table - FIXED COLUMN WIDTHS
              pw.Container(
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
                    verticalInside: pw.BorderSide(color: borderColor, width: 0.5),
                  ),
                  columnWidths: AppConstants.withGST.value
                      ? {
                    0: pw.FixedColumnWidth(25),
                    1: pw.FixedColumnWidth(70),
                    2: pw.FlexColumnWidth(3),
                    3: pw.FixedColumnWidth(45),
                    4: pw.FixedColumnWidth(60),
                    5: pw.FixedColumnWidth(70),
                    6: pw.FixedColumnWidth(60),
                    7: pw.FixedColumnWidth(75),
                  }
                      : {
                    0: pw.FixedColumnWidth(25),
                    1: pw.FixedColumnWidth(75),
                    2: pw.FlexColumnWidth(3.5),
                    3: pw.FixedColumnWidth(50),
                    4: pw.FixedColumnWidth(70),
                    5: pw.FixedColumnWidth(85),
                  },
                  children: [
                    /// Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _tableHeader('#'),
                        _tableHeader('CHALLAN'),
                        _tableHeader('ITEM'),
                        _tableHeader('QTY', align: pw.TextAlign.right),
                        _tableHeader('RATE', align: pw.TextAlign.right),
                        _tableHeader('AMOUNT', align: pw.TextAlign.right),
                        if (AppConstants.withGST.value)
                          _tableHeader('GST', align: pw.TextAlign.right),
                        if (AppConstants.withGST.value)
                          _tableHeader('NET', align: pw.TextAlign.right),
                      ],
                    ),

                    /// Data Rows
                    ...invoiceItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      dynamic value = entry.value;
                      final isEven = index % 2 == 0;

                      // Parse item data
                      String challanId = '';
                      String itemName = '';
                      double qty = 0, rate = 0, gst = 0, amount = 0;

                      try {
                        if (value is InvoiceItem) {
                          challanId = value.challanId ?? '';
                          itemName = value.itemName ?? value.description ?? '';
                          qty = value.quantity;
                          rate = (value.rate ?? 0).toDouble();
                          gst = value.gstRate ?? 0;
                          amount = (value.totalPrice ?? (qty * rate)).toDouble();
                        } else if (value is Invoice) {
                          challanId = value.challanId ?? '';
                          itemName = value.itemName ?? '';
                          qty = value.qty ?? 0;
                          rate = (value.price ?? 0).toDouble();
                          gst = (value.gst ?? 0).toDouble();
                          amount = (value.totalAmount ?? (qty * rate)).toDouble();
                        } else if (value is Map) {
                          challanId = value['challanId'] ?? '';
                          itemName = value['itemName'] ?? value['description'] ?? '';
                          qty = double.tryParse((value['quantity'] ?? '0').toString()) ?? 0;
                          rate = double.tryParse((value['price'] ?? '0').toString()) ?? 0;
                          gst = double.tryParse((value['gst'] ?? '0').toString()) ?? 0;
                          amount = double.tryParse(
                            (value['totalPrice'] ?? (qty * rate)).toString(),
                          ) ??
                              (qty * rate);
                        }
                      } catch (e) {
                        challanId = '';
                        itemName = value.toString();
                        qty = 0;
                        rate = 0;
                        gst = 0;
                        amount = 0;
                      }

                      double gstValue = amount * gst / 100;
                      double netAmount = amount + gstValue;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isEven ? PdfColors.white : rowAlt,
                        ),
                        children: [
                          _tableCell('${index + 1}', align: pw.TextAlign.center),
                          _tableCell(challanId.isNotEmpty ? challanId : '-',
                              align: pw.TextAlign.center),
                          _tableCell(itemName, align: pw.TextAlign.left),
                          _tableCell(qty.toStringAsFixed(3), align: pw.TextAlign.right),
                          _tableCell(AppUtil.formatCurrency(rate),
                              align: pw.TextAlign.right),
                          _tableCell(AppUtil.formatCurrency(amount),
                              align: pw.TextAlign.right),
                          if (AppConstants.withGST.value)
                            _tableCell(AppUtil.formatCurrency(gstValue),
                                align: pw.TextAlign.right),
                          if (AppConstants.withGST.value)
                            _tableCell(AppUtil.formatCurrency(netAmount),
                                align: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              /// Notes + Totals
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  /// Notes & Bank
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('NOTES',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 11)),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            notes.isNotEmpty
                                ? notes
                                : 'Thank you for your business!',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.SizedBox(height: 15),
                          pw.Text('BANK DETAILS',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 11)),
                          pw.SizedBox(height: 5),
                          pw.Text('Bank: $companyBank',
                              style: pw.TextStyle(fontSize: 9)),
                          pw.Text('A/C: $companyAccount',
                              style: pw.TextStyle(fontSize: 9)),
                          pw.Text('IFSC: $companyIfsc',
                              style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  /// Totals
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildTotalRow('Subtotal', subtotal, formatted: true),
                          if (AppConstants.withGST.value)
                            _buildTotalRow('CGST', gstAmount / 2, formatted: true),
                          if (AppConstants.withGST.value)
                            _buildTotalRow('SGST', gstAmount / 2, formatted: true),
                          pw.Divider(color: borderColor, height: 20),
                          _buildTotalRow('TOTAL', totalAmount,
                              formatted: true,
                              isTotal: true,
                              isBold: true,
                              primaryColor: primaryColor),
                          pw.SizedBox(height: 12),
                          pw.Container(
                            width: double.infinity,
                            padding: pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(5),
                            ),
                            child: pw.Text(
                              'Amount in Words:\n${_numberToWords(totalAmount)}',
                              style: pw.TextStyle(fontSize: 8, color: primaryColor),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 25),

              /// Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 5),
                      pw.Text('Customer Signature',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 5),
                      pw.Text('Authorized Signature',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business! • This is a computer generated invoice',
                  style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                      fontStyle: pw.FontStyle.italic),
                ),
              ),

              pw.Spacer(),

              /// Advertise Footer
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("inteligenttech.in",
                        style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text("+91 9876543210",
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final String filePrefix =
      invoiceType == InvoiceType.quotation ? 'Quotation' : 'Invoice';
      final filePath = '${directory.path}/${filePrefix}_${invoiceId}_$userName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ PDF Saved: $filePath");

      await Share.shareXFiles([XFile(filePath)], text: '$documentTitle - $invoiceId');
    } catch (e) {
      print("❌ Error generating PDF: $e");
    }
  }


  static Future<void> generateAndShareChallan(
      List<Challan> challans,
      String userName,
      String phoneNumber,
      String customerEmail,
      String customerPan,
      String customerGst,
      String customerAddress,
      double subtotal,
      String challanDate,
      double totalAmount,
      String paymentStatus,
      String notes,
      Map<String, dynamic> companyData,
      double gstAmount,
      ) async {
    try {
      final pdf = pw.Document();

      // Load fonts
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final iconData = await rootBundle.load("assets/fonts/NotoEmoji-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());
      final notoEmoji = pw.Font.ttf(iconData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String challanId =
      challans.isNotEmpty ? challans.first.challanId : "UNKNOWN";

      // Company Info
      String companyName = companyData['companyName'] ?? 'Your Company Name';
      String companyAddress = companyData['address'] ?? 'Company Address';
      String companyCity = companyData['city'] ?? 'City';
      String companyState = companyData['state'] ?? 'State';
      String companyPin = companyData['pincode'] ?? 'PIN Code';
      String companyPhone = companyData['phone'] ?? '+91 XXXXXXXXXX';
      String companyEmail = companyData['userEmail'] ?? 'company@email.com';
      String companyGst = companyData['gst'] ?? 'XXXXXXXXXXXXXXX';
      String companyPan = companyData['pan'] ?? 'PAN Number';

      // Neutral colors (same as invoice)
      final PdfColor primaryColor = PdfColors.grey800;
      final PdfColor headerBg = PdfColors.grey100;
      final PdfColor borderColor = PdfColors.grey300;
      final PdfColor rowAlt = PdfColors.grey50;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.all(25),
          build: (pw.Context context) {
            return [
              /// Header
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: headerBg,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    /// Company Info
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(companyName.toUpperCase(),
                              style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text(companyAddress,
                              style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                          pw.Text('$companyCity, $companyState - $companyPin',
                              style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                          pw.SizedBox(height: 3),
                          pw.Text("Phone: $companyPhone",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("Email: $companyEmail",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("PAN: $companyPan",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("GST: $companyGst",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                        ],
                      ),
                    ),

                    /// Challan Badge
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text("CHALLAN",
                              style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('#$challanId',
                              style: pw.TextStyle(
                                  color: PdfColors.grey600, fontSize: 10)),
                          pw.Text(challanDate,
                              style: pw.TextStyle(
                                  color: PdfColors.grey500, fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              /// To Section
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TO:',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                            fontSize: 12)),
                    pw.SizedBox(height: 6),
                    pw.Text(userName,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    if (customerAddress.isNotEmpty)
                      pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                    pw.Text('Phone: $phoneNumber',
                        style: pw.TextStyle(fontSize: 9)),
                    if (customerEmail.isNotEmpty)
                      pw.Text('Email: $customerEmail',
                          style: pw.TextStyle(fontSize: 9)),
                    if (customerPan.isNotEmpty)
                      pw.Text('PAN: $customerPan',
                          style: pw.TextStyle(fontSize: 9)),
                    if (customerGst.isNotEmpty)
                      pw.Text('GST: $customerGst',
                          style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              /// Items Table - FIXED COLUMN WIDTHS
              pw.Container(
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
                    verticalInside: pw.BorderSide(color: borderColor, width: 0.5),
                  ),
                  // Fixed column widths
                  columnWidths: AppConstants.withGST.value
                      ? {
                    0: pw.FixedColumnWidth(25),       // #
                    1: pw.FlexColumnWidth(3.5),       // DESCRIPTION
                    2: pw.FixedColumnWidth(50),       // QTY
                    3: pw.FixedColumnWidth(70),       // RATE
                    4: pw.FixedColumnWidth(85),       // AMOUNT
                    5: pw.FixedColumnWidth(70),       // GST
                    6: pw.FixedColumnWidth(85),       // NET
                  }
                      : {
                    0: pw.FixedColumnWidth(25),       // #
                    1: pw.FlexColumnWidth(4),         // DESCRIPTION
                    2: pw.FixedColumnWidth(60),       // QTY
                    3: pw.FixedColumnWidth(85),       // RATE
                    4: pw.FixedColumnWidth(95),       // AMOUNT
                  },
                  children: [
                    /// Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _tableHeader('#', align: pw.TextAlign.center),
                        _tableHeader('DESCRIPTION', align: pw.TextAlign.left),
                        _tableHeader('QTY', align: pw.TextAlign.right),
                        _tableHeader('RATE', align: pw.TextAlign.right),
                        _tableHeader('AMOUNT', align: pw.TextAlign.right),
                        if (AppConstants.withGST.value)
                          _tableHeader('GST', align: pw.TextAlign.right),
                        if (AppConstants.withGST.value)
                          _tableHeader('NET', align: pw.TextAlign.right),
                      ],
                    ),

                    /// Data Rows
                    ...challans.asMap().entries.map((entry) {
                      int index = entry.key;
                      Challan item = entry.value;
                      final isEven = index % 2 == 0;

                      double baseAmount = (item.price! * item.qty!);
                      double gstValue = baseAmount * (item.gst ?? 0) / 100;
                      double netAmount = baseAmount + gstValue;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isEven ? PdfColors.white : rowAlt,
                        ),
                        children: [
                          _tableCell('${index + 1}', align: pw.TextAlign.center),
                          _tableCell(item.itemName ?? '', align: pw.TextAlign.left),
                          _tableCell(item.qty!.toStringAsFixed(3), align: pw.TextAlign.right),
                          _tableCell(AppUtil.formatCurrency(item.price!), align: pw.TextAlign.right),
                          _tableCell(AppUtil.formatCurrency(baseAmount), align: pw.TextAlign.right),
                          if (AppConstants.withGST.value)
                            _tableCell(AppUtil.formatCurrency(gstValue), align: pw.TextAlign.right),
                          if (AppConstants.withGST.value)
                            _tableCell(AppUtil.formatCurrency(netAmount), align: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              /// Notes + Totals
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  /// Notes
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('NOTES',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 11)),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            notes.isNotEmpty
                                ? notes
                                : 'This is a delivery challan, not a tax invoice.',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.SizedBox(height: 15),
                          pw.Text('PAYMENT STATUS',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 11)),
                          pw.SizedBox(height: 5),
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: paymentStatus.toLowerCase() == 'paid'
                                  ? PdfColors.green100
                                  : PdfColors.orange100,
                              borderRadius: pw.BorderRadius.circular(5),
                              border: pw.Border.all(
                                color: paymentStatus.toLowerCase() == 'paid'
                                    ? PdfColors.green700
                                    : PdfColors.orange700,
                                width: 1,
                              ),
                            ),
                            child: pw.Text(paymentStatus.toUpperCase(),
                                style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: paymentStatus.toLowerCase() == 'paid'
                                        ? PdfColors.green700
                                        : PdfColors.orange700)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  /// Totals
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildTotalRow('Subtotal', subtotal, formatted: true),
                          if (AppConstants.withGST.value)
                            _buildTotalRow('CGST', gstAmount / 2, formatted: true),
                          if (AppConstants.withGST.value)
                            _buildTotalRow('SGST', gstAmount / 2, formatted: true),
                          pw.Divider(color: borderColor, height: 20),
                          _buildTotalRow('TOTAL', totalAmount,
                              isTotal: true,
                              isBold: true,
                              formatted: true,
                              primaryColor: primaryColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 25),

              /// Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 5),
                      pw.Text('Receiver Signature',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 5),
                      pw.Text('Delivery Person Signature',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Valid only with authorized signature',
                  style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                      fontStyle: pw.FontStyle.italic),
                ),
              ),

              /// Spacer pushes footer to bottom
              pw.Spacer(),

              /// Advertise Footer
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("inteligenttech.in",
                        style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text("+91 9876543210",
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Challan_${challanId}_$userName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ Challan PDF saved: $filePath");

      await Share.shareXFiles([XFile(filePath)], text: 'Challan - $challanId');
    } catch (e) {
      print("❌ Error generating Challan PDF: $e");
    }
  }


  // NEW METHOD: Modern Minimalist Invoice Format
  static Future<void> generateModernInvoice(List<Invoice> invoices,
      String userName,
      String phoneNumber,
      String customerEmail,
      String customerAddress,
      double subtotal,
      double taxAmount,
      double discountAmount,
      double totalAmount,
      double taxRate,
      String discountType,
      String notes,
      Map<String, dynamic> companyData,) async {
    try {
      final pdf = pw.Document();

      // Load custom font
      final fontData = await rootBundle.load(
          "assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String invoiceId = invoices.isNotEmpty
          ? invoices.first.invoiceId
          : "UNKNOWN";

      // Extract company information
      String companyName = companyData['companyName'] ?? 'Your Company Name';
      String companyAddress = companyData['address'] ?? 'Company Address';
      String companyCity = companyData['city'] ?? 'City';
      String companyState = companyData['state'] ?? 'State';
      String companyPin = companyData['pincode'] ?? 'PIN Code';
      String companyPhone = companyData['phone'] ?? '+91 XXXXXXXXXX';
      String companyEmail = companyData['email'] ?? 'company@email.com';
      String companyGst = companyData['gstNumber'] ?? 'GSTIN: XXXXXXXXXXXXXX';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Minimalist Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          companyName,
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          companyAddress,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          '$companyCity, $companyState - $companyPin',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          '$companyPhone • $companyEmail',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey500,
                          ),
                        ),
                      ],
                    ),

                    // Invoice Details
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          '#$invoiceId',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Divider
                pw.Container(
                  width: double.infinity,
                  height: 1,
                  color: PdfColors.grey300,
                ),

                pw.SizedBox(height: 25),

                // Bill To Section
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILL TO:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            userName,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (customerAddress.isNotEmpty)
                            pw.Text(
                              customerAddress,
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Phone: $phoneNumber',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          if (customerEmail.isNotEmpty)
                            pw.Text(
                              'Email: $customerEmail',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                        ],
                      ),
                    ),

                    // Due Date (if applicable)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Due Date:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          DateFormat('dd MMM yyyy').format(
                              DateTime.now().add(Duration(days: 15))),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Items Table with Clean Design
                pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(
                        color: PdfColors.grey200, width: 1),
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(0.5),
                    1: pw.FlexColumnWidth(3),
                    2: pw.FlexColumnWidth(0.8),
                    3: pw.FlexColumnWidth(1.2),
                    4: pw.FlexColumnWidth(1.2),
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                      ),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(10),
                          child: pw.Text(
                            '#',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(10),
                          child: pw.Text(
                            'DESCRIPTION',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(10),
                          child: pw.Text(
                            'QTY',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(10),
                          child: pw.Text(
                            'UNIT PRICE',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(10),
                          child: pw.Text(
                            'AMOUNT',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Table Rows
                    ...invoices
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      Invoice item = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '${index + 1}',
                              style: pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              item.itemName!,
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '${item.qty}',
                              style: pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '₹${item.price!.toStringAsFixed(2)}',
                              style: pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '₹${(item.price! * item.qty!).toStringAsFixed(
                                  2)}',
                              style: pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 25),

                // Totals Section - Right Aligned
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildModernTotalRow('Subtotal', subtotal),
                      if (taxAmount > 0)
                        _buildModernTotalRow(
                            'Tax (${taxRate.toStringAsFixed(1)}%)', taxAmount),
                      if (discountAmount > 0)
                        _buildModernTotalRow(
                            'Discount', -discountAmount, isDiscount: true),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: 200,
                        padding: pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue50,
                          border: pw.Border.all(color: PdfColors.blue200),
                        ),
                        child: pw.Column(
                          children: [
                            _buildModernTotalRow(
                              'TOTAL',
                              totalAmount,
                              isTotal: true,
                              isBold: true,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Amount due in 15 days',
                              style: pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 25),

                // Notes Section
                if (notes.isNotEmpty)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Notes:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        notes,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),

                pw.SizedBox(height: 20),

                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Thank you for your business!',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Please make payment within 15 days of receiving this invoice',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'This is a computer generated invoice',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey500,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save and open PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory
          .path}/Modern_Invoice_${invoiceId}_${userName}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ Modern PDF saved: $filePath");
      await OpenFile.open(filePath);
    } catch (e) {
      print("Error generating modern PDF: $e");
    }
  }

  static pw.Widget _buildModernTotalRow(String label, double amount,
      {bool isTotal = false, bool isBold = false, bool isDiscount = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue900 : PdfColors.grey700,
            ),
          ),
          pw.SizedBox(width: 80),
          pw.Text(
            '${isDiscount ? '-' : ''}₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue900 : (isDiscount
                  ? PdfColors.red
                  : PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }

// NEW METHOD: Colorful Premium Invoice Format
  static Future<void> generateColorfulInvoice(List<Invoice> invoices,
      String userName,
      String phoneNumber,
      String customerEmail,
      String customerAddress,
      double subtotal,
      double taxAmount,
      double discountAmount,
      double totalAmount,
      double taxRate,
      String discountType,
      String notes,
      Map<String, dynamic> companyData,) async {
    try {
      final pdf = pw.Document();

      // Load custom font
      final fontData = await rootBundle.load(
          "assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String invoiceId = invoices.isNotEmpty
          ? invoices.first.invoiceId
          : "UNKNOWN";
      // Extract company information
      String companyName = companyData['companyName'] ?? 'Samira Hadid';
      String companyAddress = companyData['address'] ??
          '123 Anywhere St., Any City';
      String companyPhone = companyData['phone'] ?? '+123-456-7890';
      String companyEmail = companyData['email'] ?? 'company@email.com';
      String companyBank = companyData['bankName'] ?? 'Name Bank';
      String companyAccount = companyData['accountNumber'] ?? '123-456-7890';
      String companyWebsite = companyData['website'] ?? 'reallygreatsite.com';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Colorful Header with gradient
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(25),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [PdfColors.blue700, PdfColors.purple700],
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                    ),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 36,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'NO: $invoiceId',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // From and To Sections with colored cards
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Bill To Section - Blue card
                    pw.Container(
                      width: 250,
                      padding: pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(
                            color: PdfColors.blue200, width: 2),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Bill To:',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                            ),
                          ),
                          pw.SizedBox(height: 15),
                          pw.Text(
                            userName.isEmpty ? 'Esterlie Darcy' : userName,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            phoneNumber.isEmpty ? '+123-456-7890' : phoneNumber,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            customerAddress.isEmpty
                                ? '123 Anywhere St., Any City'
                                : customerAddress,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          if (customerEmail.isNotEmpty) pw.SizedBox(height: 8),
                          if (customerEmail.isNotEmpty)
                            pw.Text(
                              'Email: $customerEmail',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),

                    // From Section - Purple card
                    pw.Container(
                      width: 250,
                      padding: pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.purple50,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(
                            color: PdfColors.purple200, width: 2),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'From:',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.purple800,
                            ),
                          ),
                          pw.SizedBox(height: 15),
                          pw.Text(
                            companyName,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            companyPhone,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            companyAddress,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Email: $companyEmail',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Date - Right aligned with color
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        'Date: ${DateFormat('dd MMMM yyyy').format(
                            DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Items Table with colorful header and alternating row colors
                pw.Container(
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColors.grey300,
                        blurRadius: 5,

                        ///offset: pw.Offset(0, 2),
                      ),
                    ],
                  ),
                  child: pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey200,
                      width: 1,

                      ///borderRadius: pw.BorderRadius.circular(8),
                    ),
                    columnWidths: {
                      0: pw.FlexColumnWidth(3),
                      1: pw.FlexColumnWidth(1),
                      2: pw.FlexColumnWidth(1.5),
                      3: pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      // Table Header with gradient
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          gradient: pw.LinearGradient(
                            colors: [PdfColors.blue600, PdfColors.purple600],
                            begin: pw.Alignment.centerLeft,
                            end: pw.Alignment.centerRight,
                          ),
                          borderRadius: pw.BorderRadius.only(
                            topLeft: pw.Radius.circular(8),
                            topRight: pw.Radius.circular(8),
                          ),
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(12),
                            child: pw.Text(
                              'Description',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(12),
                            child: pw.Text(
                              'Qty',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: PdfColors.white,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(12),
                            child: pw.Text(
                              'Price',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: PdfColors.white,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(12),
                            child: pw.Text(
                              'Total',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: PdfColors.white,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      // Table Rows - Only show actual items (no empty rows)
                      ...invoices
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        Invoice item = entry.value;
                        final isEven = index % 2 == 0;
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: isEven ? PdfColors.grey50 : PdfColors.white,
                          ),
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(12),
                              child: pw.Text(
                                item.itemName!,
                                style: pw.TextStyle(fontSize: 12),
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(12),
                              child: pw.Text(
                                '${item.qty}',
                                style: pw.TextStyle(fontSize: 12),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(12),
                              child: pw.Text(
                                '\$${item.price!.toStringAsFixed(2)}',
                                style: pw.TextStyle(fontSize: 12),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(12),
                              child: pw.Text(
                                '\$${(item.price! * item.qty!).toStringAsFixed(
                                    2)}',
                                style: pw.TextStyle(fontSize: 12),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // Show message if no items
                if (invoices.isEmpty) pw.SizedBox(height: 20),
                if (invoices.isEmpty)
                  pw.Center(
                    child: pw.Text(
                      'No items in this invoice',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey,
                      ),
                    ),
                  ),

                pw.SizedBox(height: 20),

                // Total Section with colorful background
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 250,
                      padding: pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        gradient: pw.LinearGradient(
                          colors: [PdfColors.blue50, PdfColors.purple50],
                          begin: pw.Alignment.topLeft,
                          end: pw.Alignment.bottomRight,
                        ),
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(
                            color: PdfColors.blue200, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildColorfulTotalRow('Sub Total:', subtotal),
                          if (taxAmount > 0)
                            _buildColorfulTotalRow('Tax (${taxRate
                                .toStringAsFixed(1)}%):', taxAmount),
                          if (discountAmount > 0)
                            _buildColorfulTotalRow(
                                'Discount:', -discountAmount, isDiscount: true),
                          pw.Divider(color: PdfColors.blue300, height: 20),
                          _buildColorfulTotalRow(
                            'TOTAL:',
                            totalAmount,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 40),

                // Notes and Payment Information with colored backgrounds
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Notes Section - Blue background
                    pw.Expanded(
                      child: pw.Container(
                        padding: pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue50,
                          borderRadius: pw.BorderRadius.circular(10),
                          border: pw.Border.all(color: PdfColors.blue200,
                              width: 1),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Notes:',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              notes.isNotEmpty
                                  ? notes
                                  : 'Thank you for your business!',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                    pw.SizedBox(width: 20),

                    // Payment Information - Purple background
                    pw.Expanded(
                      child: pw.Container(
                        padding: pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.purple50,
                          borderRadius: pw.BorderRadius.circular(10),
                          border: pw.Border.all(color: PdfColors.purple200,
                              width: 1),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Payment Information:',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.purple800,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Bank: $companyBank',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                            pw.Text(
                              'Account No: $companyAccount',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                            pw.Text(
                              'Email: $companyEmail',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                            pw.Text(
                              'Website: $companyWebsite',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 40),

                // Thank You Message with gradient background
                pw.Center(
                  child: pw.Container(
                    padding: pw.EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        colors: [PdfColors.blue700, PdfColors.purple700],
                        begin: pw.Alignment.centerLeft,
                        end: pw.Alignment.centerRight,
                      ),
                      borderRadius: pw.BorderRadius.circular(25),
                    ),
                    child: pw.Text(
                      'Thank You!',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save and open PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Invoice_${invoiceId}_${userName}.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ Colorful PDF saved: $filePath");
      await OpenFile.open(filePath);
    } catch (e) {
      print("Error generating colorful PDF: $e");
    }
  }

  static pw.Widget _buildColorfulTotalRow(String label, double amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue900 : PdfColors.grey700,
            ),
          ),
          pw.Text(
            '${isDiscount ? '-' : ''}\$${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue900 : (isDiscount
                  ? PdfColors.red
                  : PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }


/// FIXED PDF GENERATION METHOD For Challan/INvoice
//   static Future<File> generateDocument({
//     required bool isChallan,
//     Invoice? invoice,
//     Challan? challan,
//     List<InvoiceItem>? invoiceItems,
//     List<ChallanItem>? challanItems,
//     required Map<String, dynamic> companyData,
//   }) async {
//
//
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
//     // Company details
//     final companyName = companyData["companyName"] ?? 'Your Company Name';
//     final companyAddress = companyData["address"] ?? '123 Business Street';
//     final companyCity = companyData["city"] ?? 'City';
//     final companyState = companyData["state"] ?? 'State';
//     final companyPin = companyData["pincode"] ?? 'PIN Code';
//     final companyPhone = companyData["phone"] ?? '+91 XXXXXXXXXX';
//     final companyEmail = companyData["userEmail"] ?? 'company@email.com';
//     final companyGst = companyData["gst"] ?? 'GSTIN: XXXXXXXXXXXXXX';
//     final companyBank = companyData["bankName"] ?? 'Bank Name';
//     final companyAccount = companyData["accountNumber"] ?? 'Account Number';
//     final companyIfsc = companyData["ifsc"] ?? 'IFSC Code';
//     final companyPan = companyData["pan"] ?? 'PAN Number';
//
//     // Document details
//     final docTitle = isChallan ? "CHALLAN" : "INVOICE";
//     final docId = isChallan ? challan!.challanId : invoice!.invoiceId;
//     final docDate = isChallan
//         ? challan!.challanDate ?? DateTime.now()
//         : invoice!.issueDate ?? DateTime.now();
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         theme: theme,
//         margin: const pw.EdgeInsets.all(25),
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Modern Header
//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(20),
//                 decoration: pw.BoxDecoration(
//                   gradient: pw.LinearGradient(
//                     colors: isChallan
//                         ? [PdfColors.green700, PdfColors.green900]
//                         : [PdfColors.blue700, PdfColors.blue900],
//                     begin: pw.Alignment.topLeft,
//                     end: pw.Alignment.bottomRight,
//                   ),
//                   borderRadius: pw.BorderRadius.circular(10),
//                 ),
//                 child: pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     // Company Info
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(companyName.toUpperCase(),
//                             style: pw.TextStyle(
//                                 color: PdfColors.white,
//                                 fontSize: 18,
//                                 fontWeight: pw.FontWeight.bold)),
//                         pw.SizedBox(height: 5),
//                         pw.Text(companyAddress,
//                             style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
//                         pw.Text('$companyCity, $companyState - $companyPin',
//                             style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
//                         pw.SizedBox(height: 3),
//                         pw.Text('📞 $companyPhone | 📧 $companyEmail',
//                             style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
//                         pw.Text(companyGst,
//                             style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
//                       ],
//                     ),
//
//                     // Invoice/Challan Badge
//                     pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                       decoration: pw.BoxDecoration(
//                         color: PdfColors.white,
//                         borderRadius: pw.BorderRadius.circular(20),
//                       ),
//                       child: pw.Column(
//                         children: [
//                           pw.Text(docTitle,
//                               style: pw.TextStyle(
//                                   color: isChallan ? PdfColors.green800 : PdfColors.blue800,
//                                   fontSize: 16,
//                                   fontWeight: pw.FontWeight.bold)),
//                           pw.SizedBox(height: 3),
//                           pw.Text("#$docId",
//                               style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
//                           pw.Text(DateFormat("dd MMM yyyy").format(docDate),
//                               style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               pw.SizedBox(height: 25),
//
//               // FROM / TO Section
//               pw.Row(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   // FROM
//                   pw.Expanded(
//                     child: pw.Container(
//                       padding: const pw.EdgeInsets.all(15),
//                       decoration: pw.BoxDecoration(
//                         color: PdfColors.grey50,
//                         borderRadius: pw.BorderRadius.circular(8),
//                         border: pw.Border.all(color: PdfColors.grey300, width: 1),
//                       ),
//                       child: pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text("FROM:",
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: isChallan ? PdfColors.green800 : PdfColors.blue800,
//                                   fontSize: 12)),
//                           pw.SizedBox(height: 8),
//                           pw.Text(companyName,
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold, fontSize: 12)),
//                           pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 10)),
//                           pw.Text('$companyCity, $companyState - $companyPin',
//                               style: const pw.TextStyle(fontSize: 10)),
//                           pw.Text("Phone: $companyPhone",
//                               style: const pw.TextStyle(fontSize: 9)),
//                           pw.Text("Email: $companyEmail",
//                               style: const pw.TextStyle(fontSize: 9)),
//                           pw.Text("GST: $companyGst",
//                               style: const pw.TextStyle(fontSize: 9)),
//                         ],
//                       ),
//                     ),
//                   ),
//                   pw.SizedBox(width: 15),
//                   // TO
//                   pw.Expanded(
//                     child: pw.Container(
//                       padding: const pw.EdgeInsets.all(15),
//                       decoration: pw.BoxDecoration(
//                         color: PdfColors.grey50,
//                         borderRadius: pw.BorderRadius.circular(8),
//                         border: pw.Border.all(color: PdfColors.grey300, width: 1),
//                       ),
//                       child: pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text("TO:",
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: isChallan ? PdfColors.green800 : PdfColors.blue800,
//                                   fontSize: 12)),
//                           pw.SizedBox(height: 8),
//                           pw.Text(
//                             isChallan ? challan!.customerName : invoice!.customerName,
//                             style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold, fontSize: 12),
//                           ),
//                           if ((isChallan
//                               ? challan!.customerAddress ?? ''
//                               : invoice!.customerAddress ?? '')
//                               .isNotEmpty)
//                             pw.Text(
//                                 isChallan
//                                     ? challan!.customerAddress
//                                     : invoice!.customerAddress!,
//                                 style: const pw.TextStyle(fontSize: 10)),
//                           pw.Text(
//                               "Phone: ${isChallan ? challan!.customerMobile : invoice!.mobile}",
//                               style: const pw.TextStyle(fontSize: 9)),
//                           if (!isChallan &&
//                               (invoice!.customerEmail ?? '').isNotEmpty)
//                             pw.Text("Email: ${invoice.customerEmail}",
//                                 style: const pw.TextStyle(fontSize: 9)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               pw.SizedBox(height: 25),
//
//               // Status and Date info
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Issue Date (Challan vs Invoice)
//                   pw.Text(
//                     'Issue Date: ${DateFormat('MMM dd, yyyy').format(
//                       isChallan
//                           ? (challan!.challanDate ?? DateTime.now())
//                           : (invoice!.issueDate ?? DateTime.now()),
//                     )}',
//                     style: const pw.TextStyle(fontSize: 10),
//                   ),
//
//                   // Due Date (only for Invoice)
//                   if (!isChallan && invoice!.dueDate != null)
//                     pw.Text(
//                       'Due Date: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate!)}',
//                       style: const pw.TextStyle(fontSize: 10),
//                     ),
//
//                   // Status Badge
//                   pw.Container(
//                     padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: pw.BoxDecoration(
//                       color: _getStatusColor(
//                         isChallan ? challan!.paymentStatus : invoice!.status,
//                       ),
//                       borderRadius: pw.BorderRadius.circular(20),
//                     ),
//                     child: pw.Text(
//                       (isChallan ? challan!.paymentStatus : invoice!.status)?.toUpperCase() ?? 'ISSUED',
//                       style: pw.TextStyle(
//                         color: PdfColors.white,
//                         fontSize: 10,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               pw.SizedBox(height: 20),
//
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   borderRadius: pw.BorderRadius.circular(8),
//                   border: pw.Border.all(color: PdfColors.grey300, width: 1),
//                 ),
//                 child: pw.Table(
//                   border: pw.TableBorder(
//                     horizontalInside: const pw.BorderSide(color: PdfColors.grey200, width: 1),
//                     verticalInside: const pw.BorderSide(color: PdfColors.grey200, width: 1),
//                     left: pw.BorderSide.none,
//                     right: pw.BorderSide.none,
//                     top: pw.BorderSide.none,
//                     bottom: pw.BorderSide.none,
//                   ),
//                   columnWidths:
//           AppConstants.withGST.value ?
//                   {
//                     0: const pw.FlexColumnWidth(0.4),  // #
//                     1: const pw.FlexColumnWidth(2.0),  // Description
//                     2: const pw.FlexColumnWidth(0.6),  // QTY
//                     3: const pw.FlexColumnWidth(0.8),  // Rate
//                     4: const pw.FlexColumnWidth(0.8),  // GST %
//                     5: const pw.FlexColumnWidth(0.8),  // GST Amount
//                     6: const pw.FlexColumnWidth(1.0),  // Total Amount
//                   }
//           :
//           {
//           0: const pw.FlexColumnWidth(0.4),  // #
//           1: const pw.FlexColumnWidth(2.0),  // Description
//           2: const pw.FlexColumnWidth(0.6),  // QTY
//           3: const pw.FlexColumnWidth(0.8),  // Rate
//           4: const pw.FlexColumnWidth(0.8),  // GST %
//           },
//                   children: [
//                     // Header
//                     pw.TableRow(
//                       decoration: pw.BoxDecoration(
//                         color: isChallan ? PdfColors.green50 : PdfColors.blue50,
//                         borderRadius: const pw.BorderRadius.only(
//                             topLeft: pw.Radius.circular(8),
//                             topRight: pw.Radius.circular(8)),
//                       ),
//                       children: [
//                         _tableHeader('#'),
//                         _tableHeader('DESCRIPTION'),
//                         _tableHeader('QTY', align: pw.TextAlign.center),
//                         _tableHeader('RATE', align: pw.TextAlign.right),
//                         _tableHeader('GST%', align: pw.TextAlign.right),
//                         if (AppConstants.withGST.value)
//                           _tableHeader('GST', align: pw.TextAlign.right),
//                         if (AppConstants.withGST.value)
//                           _tableHeader('TOTAL', align: pw.TextAlign.right),
//                       ],
//                     ),
//
//                     // Items - FIXED GST READING FROM GOOGLE SHEETS
//                     ...(isChallan ? challanItems! : invoiceItems!)
//                         .asMap()
//                         .entries
//                         .map((entry) {
//                       int index = entry.key;
//                       final item = entry.value;
//
//                       if (isChallan) {
//                         final challanItem = item as ChallanItem;
//
//                         return pw.TableRow(
//                           decoration: pw.BoxDecoration(
//                             color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
//                           ),
//                           children: [
//                             _tableCell('${index + 1}', align: pw.TextAlign.center),
//                             _tableCell(challanItem.itemName ?? 'Item ${index + 1}'),
//                             _tableCell('${challanItem.quantity ?? 1}', align: pw.TextAlign.center),
//                             _tableCell('₹${(challanItem.price ?? 0.0).toStringAsFixed(2)}', align: pw.TextAlign.right),
//                             _tableCell('${challanItem.gstRate}%', align: pw.TextAlign.right),
//                             if (AppConstants.withGST.value)
//                               _tableCell('₹${challanItem.gstAmount}', align: pw.TextAlign.right),
//                             if (AppConstants.withGST.value)
//                             _tableCell('₹${challanItem.totalPrice}', align: pw.TextAlign.right),
//                           ],
//                         );
//                       } else {
//                         final invoiceItem = item as InvoiceItem;
//                         return pw.TableRow(
//                           decoration: pw.BoxDecoration(
//                             color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
//                           ),
//                           children: [
//                             _tableCell('${index + 1}', align: pw.TextAlign.center),
//                             _tableCell(invoiceItem.itemName ?? 'Item ${index + 1}'),
//                             _tableCell('${invoiceItem.quantity ?? 1}', align: pw.TextAlign.center),
//                             _tableCell('₹${(invoiceItem.rate ?? 0.0).toStringAsFixed(2)}', align: pw.TextAlign.right),
//                             _tableCell('${invoiceItem.gstRate}%', align: pw.TextAlign.right),
//           if (AppConstants.withGST.value)
//             _tableCell('₹${invoiceItem.gstAmount}', align: pw.TextAlign.right),
//           if (AppConstants.withGST.value)
//                             _tableCell('₹${invoiceItem.totalPrice}', align: pw.TextAlign.right),
//                           ],
//                         );
//                       }
//                     }),
//                   ],
//                 ),
//               ),
//
//               pw.SizedBox(height: 20),
//
//               // Totals + Notes + Bank
//               pw.Row(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Expanded(
//                     flex: 2,
//                     child: pw.Container(
//                       padding: const pw.EdgeInsets.all(15),
//                       decoration: pw.BoxDecoration(
//                         color: PdfColors.grey50,
//                         borderRadius: pw.BorderRadius.circular(8),
//                         border: pw.Border.all(color: PdfColors.grey300, width: 1),
//                       ),
//                       child: pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text("NOTES",
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: isChallan ? PdfColors.green800 : PdfColors.blue800,
//                                   fontSize: 11)),
//                           pw.SizedBox(height: 8),
//                           pw.Text(
//                               !isChallan
//                                   ? ((invoice!.notes ?? '').isNotEmpty
//                                   ? invoice.notes!
//                                   : "Thank you for your business!")
//                                   : "Delivered as requested.",
//                               style: const pw.TextStyle(fontSize: 10)),
//                           pw.SizedBox(height: 15),
//                           pw.Text("BANK DETAILS",
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: isChallan ? PdfColors.green800 : PdfColors.blue800,
//                                   fontSize: 11)),
//                           pw.SizedBox(height: 5),
//                           pw.Text("Bank: $companyBank",
//                               style: const pw.TextStyle(fontSize: 9)),
//                           pw.Text("A/C: $companyAccount",
//                               style: const pw.TextStyle(fontSize: 9)),
//                           pw.Text("IFSC: $companyIfsc",
//                               style: const pw.TextStyle(fontSize: 9)),
//                           pw.Text("PAN: $companyPan",
//                               style: const pw.TextStyle(fontSize: 9)),
//                         ],
//                       ),
//                     ),
//                   ),
//                   pw.SizedBox(width: 20),
//                   pw.Expanded(
//                     flex: 1,
//                     child: pw.Container(
//                       padding: const pw.EdgeInsets.all(15),
//                       decoration: pw.BoxDecoration(
//                         color: isChallan ? PdfColors.green50 : PdfColors.blue50,
//                         borderRadius: pw.BorderRadius.circular(8),
//                         border: pw.Border.all(
//                             color:
//                             isChallan ? PdfColors.green200 : PdfColors.blue200,
//                             width: 1),
//                       ),
//                       child: pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.end,
//                         children: [
//                           // Use the passed parameters for accurate totals
//                           _buildTotalRow("Subtotal", isChallan ? (challan!.subtotal ?? 0.0) : (invoice!.subtotal ?? 0.0),),
//           if (AppConstants.withGST.value)
//             _buildTotalRow("GST",   isChallan ? (challan!.gstAmount ?? 0.0) : (invoice!.gstAmount ?? 0.0),),
//                           pw.Divider(
//                               color: isChallan ? PdfColors.green300 : PdfColors.blue300,
//                               height: 20),
//                           _buildTotalRow("TOTAL ",  isChallan ? (challan!.subtotal + challan.gstAmount ?? 0.0) : (invoice!.subtotal! + invoice.gstAmount! ?? 0.0),
//                               isTotal: true, isBold: true),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               pw.SizedBox(height: 25),
//
//               // Footer
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                 children: [
//                   pw.Column(
//                     children: [
//                       pw.Container(width: 150, height: 1, color: PdfColors.grey400),
//                       pw.SizedBox(height: 5),
//                       pw.Text("Customer Signature",
//                           style:
//                           const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
//                     ],
//                   ),
//                   pw.Column(
//                     children: [
//                       pw.Container(width: 150, height: 1, color: PdfColors.grey400),
//                       pw.SizedBox(height: 5),
//                       pw.Text("Authorized Signature",
//                           style:
//                           const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
//                     ],
//                   ),
//                 ],
//               ),
//
//               pw.SizedBox(height: 20),
//               pw.Center(
//                 child: pw.Text(
//                   "Thank you for your business! • This is a computer generated ${docTitle.toLowerCase()}",
//                   style: pw.TextStyle(
//                       fontSize: 8,
//                       color: PdfColors.grey500,
//                       fontStyle: pw.FontStyle.italic),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     // Save
//     final dir = await getApplicationDocumentsDirectory();
//     final path = "${dir.path}/${docTitle.toLowerCase()}_$docId.pdf";
//     final file = File(path);
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

  static Future<File> generateDocument({
    required bool isChallan,
    Invoice? invoice,
    Challan? challan,
    List<InvoiceItem>? invoiceItems,
    List<ChallanItem>? challanItems,
    required Map<String, dynamic> companyData,
  }) async {
    final pdf = pw.Document();

    // Load custom font (Rupee + Emoji)
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final iconData = await rootBundle.load("assets/fonts/NotoEmoji-Regular.ttf");
    final customFont = pw.Font.ttf(fontData.buffer.asByteData());
    final notoEmoji = pw.Font.ttf(iconData.buffer.asByteData());

    final theme = pw.ThemeData.withFont(
      base: customFont,
      bold: customFont,
      italic: customFont,
      boldItalic: customFont,
    );

    // Company Info
    String companyName = companyData['companyName'] ?? 'Your Company Name';
    String companyAddress = companyData['address'] ?? 'Company Address';
    String companyCity = companyData['city'] ?? 'City';
    String companyState = companyData['state'] ?? 'State';
    String companyPin = companyData['pincode'] ?? 'PIN Code';
    String companyPhone = companyData['phone'] ?? '+91 XXXXXXXXXX';
    String companyEmail = companyData['userEmail'] ?? 'company@email.com';
    String companyGst = companyData['gst'] ?? 'XXXXXXXXXXXXXXX';
    String companyBank = companyData['bankName'] ?? 'Bank Name';
    String companyAccount = companyData['accountNumber'] ?? 'Account Number';
    String companyIfsc = companyData['ifsc'] ?? 'IFSC Code';
    String companyPan = companyData['pan'] ?? 'PAN Number';

    // Neutral Colors
    final PdfColor primaryColor = PdfColors.grey800;
    final PdfColor headerBg = PdfColors.grey100;
    final PdfColor borderColor = PdfColors.grey300;
    final PdfColor rowAlt = PdfColors.grey50;

    // Document details
    final docTitle = isChallan ? "CHALLAN" : "INVOICE";
    final docId = isChallan ? challan!.challanId : invoice!.invoiceId;
    final docDate = isChallan
        ? challan!.challanDate ?? DateTime.now()
        : invoice!.issueDate ?? DateTime.now();

    // Customer details
    final customerName = isChallan ? challan!.customerName : invoice!.customerName;
    final customerAddress = isChallan
        ? (challan!.customerAddress ?? '')
        : (invoice!.customerAddress ?? '');
    final customerPhone = isChallan ? challan!.customerMobile : invoice!.mobile;
    final customerEmail = !isChallan ? (invoice!.customerEmail ?? '') : '';
    final customerPAN = !isChallan ? (invoice!.customerPan ?? '') : '';
    final customerGST = !isChallan ? (invoice!.customerGst ?? '') : '';

    // Calculate totals
    double subtotal = isChallan ? (challan!.subtotal ?? 0.0) : (invoice!.subtotal ?? 0.0);
    double gstAmount = isChallan ? (challan!.gstAmount ?? 0.0) : (invoice!.gstAmount ?? 0.0);
    double totalAmount = subtotal + gstAmount;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: pw.EdgeInsets.all(25),
        build: (pw.Context context) {
          return [
            /// Header
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: headerBg,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: borderColor, width: 1),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  /// Company Info
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(companyName.toUpperCase(),
                            style: pw.TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(companyAddress,
                            style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                        pw.Text('$companyCity, $companyState - $companyPin',
                            style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                        pw.SizedBox(height: 3),
                        pw.Text("Phone: $companyPhone",
                            style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                        pw.Text("Email: $companyEmail",
                            style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                        pw.Text("PAN: $companyPan",
                            style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                        pw.Text("GST: $companyGst",
                            style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                      ],
                    ),
                  ),

                  /// Document Badge
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: borderColor, width: 1),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(docTitle,
                            style: pw.TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('#$docId',
                            style: pw.TextStyle(
                                color: PdfColors.grey600, fontSize: 10)),
                        pw.Text(DateFormat("dd MMM yyyy").format(docDate),
                            style: pw.TextStyle(
                                color: PdfColors.grey500, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 25),

            /// Bill To Section
            pw.Container(
              padding: pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderColor, width: 1),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  /// Customer Details
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('TO:',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                                fontSize: 12)),
                        pw.SizedBox(height: 6),
                        pw.Text(customerName,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        if (customerAddress.isNotEmpty)
                          pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 3),
                        pw.Text('Phone: $customerPhone',
                            style: pw.TextStyle(fontSize: 9)),
                        if (customerEmail.isNotEmpty)
                          pw.Text('Email: $customerEmail',
                              style: pw.TextStyle(fontSize: 9)),
                        if (customerPAN.isNotEmpty)
                          pw.Text('PAN: $customerPAN',
                              style: pw.TextStyle(fontSize: 9)),

                        if (customerGST.isNotEmpty)
                          pw.Text('GST: $customerGST',
                              style: pw.TextStyle(fontSize: 9)),

                      ],
                    ),
                  ),

                  /// Status & Dates
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // Status Badge
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: _getStatusColor(
                            isChallan ? challan!.paymentStatus : invoice!.status,
                          ),
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Text(
                          (isChallan ? challan!.paymentStatus : invoice!.status)
                              ?.toUpperCase() ??
                              'ISSUED',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      // Due Date (only for Invoice)
                      if (!isChallan && invoice!.dueDate != null)
                        pw.Text(
                          'Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate!)}',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 25),

            /// Items Table - FIXED COLUMN WIDTHS
            pw.Container(
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderColor, width: 1),
              ),
              child: pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
                  verticalInside: pw.BorderSide(color: borderColor, width: 0.5),
                ),
                columnWidths: AppConstants.withGST.value
                    ? {
                  0: pw.FixedColumnWidth(25),       // # - Fixed width
                  1: pw.FlexColumnWidth(3.5),       // DESCRIPTION - Flexible
                  2: pw.FixedColumnWidth(50),       // QTY - Fixed
                  3: pw.FixedColumnWidth(70),       // PRICE - Fixed
                  4: pw.FixedColumnWidth(85),       // AMOUNT - Fixed
                  5: pw.FixedColumnWidth(70),       // GST - Fixed
                  6: pw.FixedColumnWidth(85),       // NET - Fixed
                }
                    : {
                  0: pw.FixedColumnWidth(25),       // #
                  1: pw.FlexColumnWidth(4),         // DESCRIPTION
                  2: pw.FixedColumnWidth(60),       // QTY
                  3: pw.FixedColumnWidth(85),       // PRICE
                  4: pw.FixedColumnWidth(95),       // AMOUNT
                },
                children: [
                  /// Header Row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _tableHeader('#'),
                      _tableHeader('DESCRIPTION'),
                      _tableHeader('QTY', align: pw.TextAlign.right),
                      _tableHeader('PRICE', align: pw.TextAlign.right),
                      _tableHeader('AMOUNT', align: pw.TextAlign.right),
                      if (AppConstants.withGST.value)
                        _tableHeader('GST', align: pw.TextAlign.right),
                      if (AppConstants.withGST.value)
                        _tableHeader('NET', align: pw.TextAlign.right),
                    ],
                  ),

                  /// Data Rows
                  ...(isChallan ? challanItems! : invoiceItems!)
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    final item = entry.value;
                    final isEven = index % 2 == 0;

                    String itemName;
                    double qty, price, gstRate, baseAmount, gstValue, netAmount;

                    if (isChallan) {
                      final challanItem = item as ChallanItem;
                      itemName = challanItem.itemName ?? 'Item ${index + 1}';
                      qty = challanItem.quantity ?? 1;
                      price = challanItem.price ?? 0.0;
                      gstRate = challanItem.gstRate ?? 0.0;
                      baseAmount = qty * price;
                      gstValue = challanItem.gstAmount ?? (baseAmount * gstRate / 100);
                      netAmount = challanItem.totalPrice ?? (baseAmount + gstValue);
                    } else {
                      final invoiceItem = item as InvoiceItem;
                      itemName = invoiceItem.itemName ?? 'Item ${index + 1}';
                      qty = invoiceItem.quantity ?? 1;
                      price = invoiceItem.rate ?? 0.0;
                      gstRate = invoiceItem.gstRate ?? 0.0;
                      baseAmount = qty * price;
                      gstValue = invoiceItem.gstAmount ?? (baseAmount * gstRate / 100);
                      netAmount = invoiceItem.totalPrice ?? (baseAmount + gstValue);
                    }

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : rowAlt,
                      ),
                      children: [
                        _tableCell('${index + 1}', align: pw.TextAlign.center),
                        _tableCell(itemName, align: pw.TextAlign.left),
                        _tableCell(qty.toStringAsFixed(1), align: pw.TextAlign.right),
                        _tableCell(AppUtil.formatCurrency(price), align: pw.TextAlign.right),
                        _tableCell(AppUtil.formatCurrency(baseAmount), align: pw.TextAlign.right),
                        if (AppConstants.withGST.value)
                          _tableCell(AppUtil.formatCurrency(gstValue), align: pw.TextAlign.right),
                        if (AppConstants.withGST.value)
                          _tableCell(AppUtil.formatCurrency(netAmount), align: pw.TextAlign.right),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            /// Notes + Totals
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                /// Notes & Bank
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: borderColor, width: 1),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('NOTES',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                                fontSize: 11)),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          !isChallan
                              ? ((invoice!.notes ?? '').isNotEmpty
                              ? invoice.notes!
                              : "Thank you for your business!")
                              : "Delivered as requested.",
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Text('BANK DETAILS',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                                fontSize: 11)),
                        pw.SizedBox(height: 5),
                        pw.Text('Bank: $companyBank',
                            style: pw.TextStyle(fontSize: 9)),
                        pw.Text('A/C: $companyAccount',
                            style: pw.TextStyle(fontSize: 9)),
                        pw.Text('IFSC: $companyIfsc',
                            style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(width: 20),

                /// Totals
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: borderColor, width: 1),
                    ),
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Subtotal', subtotal, formatted: true),
                        if (AppConstants.withGST.value)
                          _buildTotalRow('CGST', gstAmount / 2, formatted: true),
                        if (AppConstants.withGST.value)
                          _buildTotalRow('SGST', gstAmount / 2, formatted: true),
                        pw.Divider(color: borderColor, height: 20),
                        _buildTotalRow('TOTAL', totalAmount,
                            formatted: true,
                            isTotal: true,
                            isBold: true,
                            primaryColor: primaryColor),
                        pw.SizedBox(height: 12),
                        pw.Container(
                          width: double.infinity,
                          padding: pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                          child: pw.Text(
                            'Amount in Words:\n${_numberToWords(totalAmount)}',
                            style: pw.TextStyle(fontSize: 8, color: primaryColor),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            /// Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 5),
                    pw.Text('Customer Signature',
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 5),
                    pw.Text('Authorized Signature',
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'Thank you for your business! • This is a computer generated ${docTitle.toLowerCase()}',
                style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                    fontStyle: pw.FontStyle.italic),
              ),
            ),

            /// Spacer pushes footer to bottom
            pw.Spacer(),

            /// Advertise Footer
            pw.Container(
              padding: pw.EdgeInsets.symmetric(vertical: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("inteligenttech.in",
                      style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text("+91 9876543210",
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Save PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${docTitle.toLowerCase()}_$docId.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print("✅ PDF Saved: $filePath");

    return file;
  }

  static Future<File> generate(Invoice invoice,
      List<InvoiceItem> invoiceItems,
      Map<String, dynamic> companyData,
      {
  required double subtotal,
  required double gstAmount,
  required double total,
  double discount = 0.0,
}
) async {
    final pdf = pw.Document();

    // Load custom font that supports rupee symbol
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final customFont = pw.Font.ttf(fontData.buffer.asByteData());

    // Use the custom font
    final theme = pw.ThemeData.withFont(
      base: customFont,
      bold: customFont,
      italic: customFont,
      boldItalic: customFont,
    );

    String companyName = companyData["companyName"] ?? 'Your Company Name';
    String companyAddress = companyData["address"] ?? '123 Business Street';
    String companyCity = companyData["city"] ?? 'City';
    String companyState = companyData["state"] ?? 'State';
    String companyPin = companyData["pincode"] ?? 'PIN Code';
    String companyPhone = companyData["phone"] ?? '+91 XXXXXXXXXX';
    String companyEmail = companyData["userEmail"] ?? 'company@email.com';
    String companyGst = companyData["gst"] ?? 'GSTIN: XXXXXXXXXXXXXX';
    String companyBank = companyData["bankName"] ?? 'Bank Name';
    String companyAccount = companyData["accountNumber"] ?? 'Account Number';
    String companyIfsc = companyData["ifsc"] ?? 'IFSC Code';
    String companyPan = companyData["pan"] ?? 'PAN Number';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: pw.EdgeInsets.all(25),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Modern Header with Gradient Background
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColors.blue700, PdfColors.blue900],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Company Info
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          companyName.toUpperCase(),
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          companyAddress,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                        pw.Text(
                          '$companyCity, $companyState - $companyPin',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          '📞 $companyPhone | 📧 $companyEmail',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          companyGst,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),

                    // Invoice Badge
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'INVOICE',
                            style: pw.TextStyle(
                              color: PdfColors.blue800,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            '#${invoice.invoiceId}',
                            style: pw.TextStyle(
                              color: PdfColors.grey700,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            DateFormat('dd MMM yyyy').format(invoice.issueDate ?? DateTime.now()),
                            style: pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // Two-column layout for From/To
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // From Section
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'FROM:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 12,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            companyName,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(
                            companyAddress,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            '$companyCity, $companyState - $companyPin',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Phone: $companyPhone',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            'Email: $companyEmail',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            'GST: $companyGst',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 15),

                  // To Section
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILL TO:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 12,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            invoice.customerName,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if ((invoice.customerAddress ?? '').isNotEmpty)
                            pw.Text(
                              invoice.customerAddress!,
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Phone: ${invoice.mobile}',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                          if ((invoice.customerEmail ?? '').isNotEmpty)
                            pw.Text(
                              'Email: ${invoice.customerEmail}',
                              style: pw.TextStyle(fontSize: 9),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 25),

              // Invoice Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Issue Date: ${DateFormat('MMM dd, yyyy').format(invoice.issueDate ?? DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  if (invoice.dueDate != null)
                    pw.Text(
                      'Due Date: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate!)}',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: _getStatusColor(invoice.status),
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      invoice.status?.toUpperCase() ?? 'ISSUED',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Items Table with Modern Design - Now supports multiple items
              pw.Container(
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                ),
                child: pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
                    verticalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
                    left: pw.BorderSide.none,
                    right: pw.BorderSide.none,
                    top: pw.BorderSide.none,
                    bottom: pw.BorderSide.none,
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(0.4),
                    1: pw.FlexColumnWidth(2.5),
                    2: pw.FlexColumnWidth(0.6),
                    3: pw.FlexColumnWidth(1),
                    4: pw.FlexColumnWidth(0.8),
                    5: pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(8),
                          topRight: pw.Radius.circular(8),
                        ),
                      ),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(12),
                          child: pw.Text(
                            '#',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(12),
                          child: pw.Text(
                            'DESCRIPTION',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(12),
                          child: pw.Text(
                            'QTY',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(12),
                          child: pw.Text(
                            'RATE',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        _tableHeader('GST AMT', align: pw.TextAlign.right),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(12),
                          child: pw.Text(
                            'AMOUNT',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),

                    // Generate rows for all invoice items
                    ...invoiceItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      InvoiceItem item = entry.value;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '${index + 1}',
                              style: pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              //item.description  ?? 'Item ${index + 1}',
                              item.itemName ?? 'Item ${index + 1}',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '${item.quantity?.toString() ?? '1'}',
                              style: pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '₹${(item.rate ?? 0.0).toStringAsFixed(2)}',
                              style: pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          _tableCell('₹${item.gstAmount}', align: pw.TextAlign.right),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '₹${((item.rate ?? 0.0) * (item.quantity ?? 1)).toStringAsFixed(2)}',
                              style: pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Totals Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Notes Section
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'NOTES',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 11,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            (invoice.notes ?? '').isNotEmpty ? invoice.notes! : 'Thank you for your business!',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.SizedBox(height: 15),
                          pw.Text(
                            'BANK DETAILS',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                              fontSize: 11,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text('Bank: $companyBank', style: pw.TextStyle(fontSize: 9)),
                          pw.Text('A/C: $companyAccount', style: pw.TextStyle(fontSize: 9)),
                          pw.Text('IFSC: $companyIfsc', style: pw.TextStyle(fontSize: 9)),
                          pw.Text('PAN: $companyPan', style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  // Totals
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.blue200, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                            _buildTotalRow('Subtotal', invoice.subtotal ?? 0),
                            if ((invoice.gstAmount ?? 0) > 0)
                              _buildTotalRow('GST ',invoice.gstAmount ?? 0),

                            pw.Divider(color: PdfColors.blue300, height: 20),
                            _buildTotalRow('TOTAL ', invoice.totalAmount ?? 0,
                                isTotal: true, isBold: true),

                        ],
                      ),
                    ),
                  ),


                ],
              ),

              pw.SizedBox(height: 25),

              // Footer with Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Customer Signature',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business! • This is a computer generated invoice',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/invoice_${invoice.invoiceId}.pdf';
    final file = File(path);

    await file.writeAsBytes(await pdf.save());
   /// await Share.shareXFiles([XFile(path)], text: 'Invoice - ${invoice.invoiceId}');
    return file;
  }

  static Future<File> generateChallan(
      Challan challan, List<ChallanItem> challanItems, Map<String, dynamic> companyData) async {
    final pdf = pw.Document();

    // Load custom font (reuse same)
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final customFont = pw.Font.ttf(fontData.buffer.asByteData());

    final theme = pw.ThemeData.withFont(
      base: customFont,
      bold: customFont,
      italic: customFont,
      boldItalic: customFont,
    );

    String companyName = companyData["companyName"] ?? 'Your Company Name';
    String companyAddress = companyData["address"] ?? '123 Business Street';
    String companyCity = companyData["city"] ?? 'City';
    String companyState = companyData["state"] ?? 'State';
    String companyPin = companyData["pincode"] ?? 'PIN Code';
    String companyPhone = companyData["phone"] ?? '+91 XXXXXXXXXX';
    String companyEmail = companyData["userEmail"] ?? 'company@email.com';
    String companyGst = companyData["gst"] ?? 'GSTIN: XXXXXXXXXXXXXX';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: pw.EdgeInsets.all(25),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 🔵 Header
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColors.blue700, PdfColors.blue900],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Company Info
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(companyName.toUpperCase(),
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(companyAddress,
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                        pw.Text('$companyCity, $companyState - $companyPin',
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                        pw.SizedBox(height: 3),
                        pw.Text('📞 $companyPhone | 📧 $companyEmail',
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                        pw.Text(companyGst,
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                      ],
                    ),

                    // 🔵 Challan Badge
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text("CHALLAN",
                              style: pw.TextStyle(
                                  color: PdfColors.blue800,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 3),
                          pw.Text('#${challan.challanId}',
                              style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                          pw.Text(
                              DateFormat('dd MMM yyyy')
                                  .format(challan.challanDate ?? DateTime.now()),
                              style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // 🔵 Customer Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // From (Company)
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("FROM:",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue800,
                                  fontSize: 12)),
                          pw.SizedBox(height: 8),
                          pw.Text(companyName,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.Text(companyAddress, style: pw.TextStyle(fontSize: 10)),
                          pw.Text('$companyCity, $companyState - $companyPin',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 3),
                          pw.Text('Phone: $companyPhone', style: pw.TextStyle(fontSize: 9)),
                          pw.Text('Email: $companyEmail', style: pw.TextStyle(fontSize: 9)),
                          pw.Text('GST: $companyGst', style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 15),

                  // To (Customer)
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("TO:",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue800,
                                  fontSize: 12)),
                          pw.SizedBox(height: 8),
                          pw.Text(challan.customerName,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          if ((challan.customerAddress ?? '').isNotEmpty)
                            pw.Text(challan.customerAddress!,
                                style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 3),
                          pw.Text('Phone: ${challan.customerMobile}',
                              style: pw.TextStyle(fontSize: 9)),
                          if ((challan.customerEmail ?? '').isNotEmpty)
                            pw.Text('Email: ${challan.customerEmail}',
                                style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 25),

              // 🔵 Items Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                ),
                child: pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
                    verticalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
                    left: pw.BorderSide.none,
                    right: pw.BorderSide.none,
                    top: pw.BorderSide.none,
                    bottom: pw.BorderSide.none,
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(0.4),
                    1: pw.FlexColumnWidth(2.5),
                    2: pw.FlexColumnWidth(0.6),
                    3: pw.FlexColumnWidth(1),
                    4: pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(8),
                          topRight: pw.Radius.circular(8),
                        ),
                      ),
                      children: [
                        _tableHeader('#'),
                        _tableHeader('DESCRIPTION'),
                        _tableHeader('QTY'),
                        _tableHeader('RATE', align: pw.TextAlign.right),
                        _tableHeader('AMOUNT', align: pw.TextAlign.right),
                      ],
                    ),

                    // Items Rows
                    ...challanItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      ChallanItem item = entry.value;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                        ),
                        children: [
                          _tableCell('${index + 1}', align: pw.TextAlign.center),
                          _tableCell(item.itemName ?? 'Item ${index + 1}'),
                          _tableCell('${item.quantity ?? 1}',
                              align: pw.TextAlign.center),
                          _tableCell('₹${(item.price ?? 0.0).toStringAsFixed(2)}',
                              align: pw.TextAlign.right),
                          _tableCell(
                              '₹${((item.price ?? 0.0) * (item.quantity ?? 1)).toStringAsFixed(2)}',
                              align: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // 🔵 Totals Section
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildTotalRow('Subtotal', challan.subtotal ?? 0,  formatted: true),
                    _buildTotalRow('Tax (${challan.gst?.toStringAsFixed(1) ?? '0'}%)',
                        challan.gstAmount ?? 0,  formatted: true),
                    pw.Divider(),
                    _buildTotalRow('Total', challan.subtotal ?? 0,
                        isBold: true, isTotal: true, formatted: true),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "Amount in words: ${_numberToWords(challan.subtotal ?? 0)} only",
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // 🔵 Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 5),
                    pw.Text('Customer Signature',
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ]),
                  pw.Column(children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 5),
                    pw.Text('Authorized Signature',
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save File
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/challan_${challan.challanId}.pdf';
    final file = File(path);

    await file.writeAsBytes(await pdf.save());
    return file;
  }




  // Helper methods (add these if not already present)
  static pw.Widget _tableHeader(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          color: PdfColors.grey800,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9),
        textAlign: align,
        maxLines: 2,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  static pw.Widget _buildTotalRow(
      String label,
      double amount, {
        bool formatted = false,
        bool isTotal = false,
        bool isBold = false,
        PdfColor? primaryColor,
      }) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 11 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: primaryColor ?? PdfColors.grey800,
            ),
          ),
          pw.Text(
            formatted
                ? "₹${AppUtil.formatCurrency(amount)}"
                : "₹${amount.toStringAsFixed(2)}",
           style: pw.TextStyle(
              fontSize: isTotal ? 11 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: primaryColor ?? PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  static String _numberToWords(double number) {
    // Simple number to words conversion (you can enhance this)
    final wholePart = number.toInt();
    final decimalPart = ((number - wholePart) * 100).round();

    if (wholePart == 0) return 'Zero Rupees';

    String words = _convertNumber(wholePart) + ' Rupees';
    if (decimalPart > 0) {
      words += ' and ${_convertNumber(decimalPart)} Paise';
    }
    return words + ' Only';
  }

  static String _convertNumber(int number) {
    // Simple number conversion logic (you can use a proper package for this)
    if (number < 20) {
      final units = [
        '',
        'One',
        'Two',
        'Three',
        'Four',
        'Five',
        'Six',
        'Seven',
        'Eight',
        'Nine',
        'Ten',
        'Eleven',
        'Twelve',
        'Thirteen',
        'Fourteen',
        'Fifteen',
        'Sixteen',
        'Seventeen',
        'Eighteen',
        'Nineteen'
      ];
      return units[number];
    }
    if (number < 100) {
      final tens = [
        '',
        '',
        'Twenty',
        'Thirty',
        'Forty',
        'Fifty',
        'Sixty',
        'Seventy',
        'Eighty',
        'Ninety'
      ];
      return '${tens[number ~/ 10]} ${_convertNumber(number % 10)}';
    }
    if (number < 1000) {
      return '${_convertNumber(number ~/ 100)} Hundred ${_convertNumber(
          number % 100)}';
    }
    if (number < 100000) {
      return '${_convertNumber(number ~/ 1000)} Thousand ${_convertNumber(
          number % 1000)}';
    }
    if (number < 10000000) {
      return '${_convertNumber(number ~/ 100000)} Lakh ${_convertNumber(
          number % 100000)}';
    }
    return '${_convertNumber(number ~/ 10000000)} Crore ${_convertNumber(
        number % 10000000)}';
  }

  /// Helper: Signature field
  static pw.Widget _signatureField(String label) {
    return pw.Column(
      children: [
        pw.Container(width: 150, height: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  static PdfColor _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return PdfColors.green;
      case 'pending':
        return PdfColors.orange;
      case 'overdue':
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }
}






