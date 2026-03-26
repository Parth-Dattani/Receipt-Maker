import 'dart:io' as io;
import 'dart:convert';
import 'dart:ui';
import 'package:GetYourInvoice/utils/calculations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';




class InvoiceHelper {

  /// When isCashMemoEnabled: Paid → "Cash Memo", else → "Debit Memo". Otherwise "INVOICE" (or "QUOTATION").
  static String getInvoiceDocumentTitle(InvoiceType invoiceType, String? paymentStatus) {
    if (invoiceType == InvoiceType.quotation) return 'QUOTATION';
    if (AppConstants.isCashMemo.value) {
      if (paymentStatus == 'Paid') return 'Cash Memo';
      return 'Debit Memo';
    }
    return 'INVOICE';
  }

  /// Load company logo image bytes from URL or data:base64 string for PDF.
  static Future<Uint8List?> _loadLogoBytes(String? logo) async {
    if (logo == null || logo.trim().isEmpty) return null;
    final s = logo.trim();
    try {
      // data:image/png;base64,... or data:image/jpeg;base64,... (flexible)
      if (s.startsWith('data:') && s.contains('base64,')) {
        final idx = s.indexOf('base64,');
        if (idx >= 0) {
          final base64 = s.substring(idx + 7).trim();
          if (base64.isNotEmpty) return Uint8List.fromList(base64Decode(base64));
        }
        return null;
      }
      if (s.startsWith('http://') || s.startsWith('https://')) {
        final response = await http.get(Uri.parse(s)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  /// Format quantity using the same decimalPlaces setting as amounts.
  static String _formatQty(num qty) =>
      qty.toStringAsFixed(AppConstants.decimalPlaces);

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
      String companyUpi = companyData['upiId'] ?? 'Upi Id';
      String companyIfsc = companyData['ifsc'] ?? 'IFSC Code';
      String companyPan = companyData['pan'] ?? 'PAN Number';

      // Load company logo for header (URL or data:base64)
      final Uint8List? logoBytes = await _loadLogoBytes(companyData['logo']?.toString());

      // Neutral Colors
      final PdfColor primaryColor = PdfColors.grey800;
      final PdfColor headerBg = PdfColors.grey100;
      final PdfColor borderColor = PdfColors.grey300;
      final PdfColor rowAlt = PdfColors.grey50;

      final String documentTitle = getInvoiceDocumentTitle(
          invoiceType,
          invoices.isNotEmpty ? invoices.first.status : null);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.all(25),
          footer: _buildFooter,
          build: (pw.Context context) {
            return [
              /// Header
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: headerBg,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Company logo (B&W invoice)
                    if (logoBytes != null)
                      pw.Container(
                        margin: pw.EdgeInsets.only(right: 14),
                        width: 70,
                        height: 70,
                        child: pw.Image(
                          pw.MemoryImage(logoBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
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
                          pw.SizedBox(height: 3),
                          pw.Text(companyAddress,
                              style: pw.TextStyle(color: primaryColor, fontSize: 8.5)),
                          pw.Text('$companyCity, $companyState - $companyPin',
                              style: pw.TextStyle(color: primaryColor, fontSize: 8.5)),
                          pw.SizedBox(height: 3),
                          pw.Text("Phone: $companyPhone",
                              style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                          pw.Text("Email: $companyEmail",
                              style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                          if (companyPan.isNotEmpty)
                            pw.Text("PAN: $companyPan",
                              style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                          if (companyGst.isNotEmpty)
                            pw.Text("GST: $companyGst",
                              style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
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
                          // ✅ DUE DATE - Only show if enabled
                            if (AppConstants.isDueDateEnabled.value) ...[
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              /// Bill To
              pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                            fontSize: 12)),
                    pw.SizedBox(height: 6),
                    pw.Text(userName,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    if (customerAddress.isNotEmpty)
                      pw.Text(customerAddress, style: pw.TextStyle(fontSize: 8.5)),
                    pw.SizedBox(height: 3),
                    pw.Text('Phone: $phoneNumber',
                        style: pw.TextStyle(fontSize: 8.5),),
                    if (customerEmail.isNotEmpty)
                      pw.Text('Email: $customerEmail',
                          style: pw.TextStyle(fontSize: 8.5)),
                    if (customerPAN.isNotEmpty)
                      pw.Text('PAN: $customerPAN',
                          style: pw.TextStyle(fontSize: 8.5)),
                    if (customerGST.isNotEmpty)
                      pw.Text('GST: $customerGST',
                          style: pw.TextStyle(fontSize: 8.5)),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

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
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Main item name in bold
                                pw.Text(
                                  displayItemName,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
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
                          _tableCell(_formatQty(item.qty ?? 0), align: pw.TextAlign.right),
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

                          // ✅ Show Bank Details only if any bank data exists
                          if ((companyBank.toString().trim().isNotEmpty) ||
                              (companyAccount.toString().trim().isNotEmpty) ||
                              (companyIfsc.toString().trim().isNotEmpty) ||
                              (companyUpi.toString().trim().isNotEmpty)) ...[
                            pw.Text('BANK DETAILS',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11)),
                            pw.SizedBox(height: 5),
                            if (companyBank.isNotEmpty)
                              pw.Text('Bank: $companyBank',
                                  style: pw.TextStyle(fontSize: 9)),
                            if (companyAccount.isNotEmpty)
                              pw.Text('A/C: $companyAccount',
                                  style: pw.TextStyle(fontSize: 9)),
                            if (companyIfsc.isNotEmpty)
                              pw.Text('IFSC: $companyIfsc',
                                  style: pw.TextStyle(fontSize: 9)),
                            if (companyUpi.isNotEmpty)
                              pw.Text('Upi: $companyUpi',
                                  style: pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 15),
                          ],
                          // ✅ Show NOTES only when there is note content
                          if ((notes.trim().isNotEmpty) ||
                              (companyData['isExtraNotesEnabled'] == true &&
                                  ((companyData['extraNote1'] ?? '').toString().trim().isNotEmpty ||
                                      (companyData['extraNote2'] ?? '').toString().trim().isNotEmpty ||
                                      (companyData['extraNote3'] ?? '').toString().trim().isNotEmpty))) ...[
                            pw.Text('NOTES',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11)),
                            pw.SizedBox(height: 6),
                            if (notes.trim().isNotEmpty)
                              pw.Text(notes, style: pw.TextStyle(fontSize: 7.5)),
                            if (companyData['isExtraNotesEnabled'] == true) ...[
                              if ((companyData['extraNote1'] ?? '').toString().trim().isNotEmpty) ...[
                                pw.SizedBox(height: 3.5),
                                pw.Row(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('• ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                                    pw.Expanded(
                                      child: pw.Text(
                                        companyData['extraNote1'].toString().trim(),
                                        style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if ((companyData['extraNote2'] ?? '').toString().trim().isNotEmpty) ...[
                                pw.SizedBox(height: 6),
                                pw.Row(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('• ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                                    pw.Expanded(
                                      child: pw.Text(
                                        companyData['extraNote2'].toString().trim(),
                                        style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if ((companyData['extraNote3'] ?? '').toString().trim().isNotEmpty) ...[
                                pw.SizedBox(height: 6),
                                pw.Row(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('• ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                                    pw.Expanded(
                                      child: pw.Text(
                                        companyData['extraNote3'].toString().trim(),
                                        style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],

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
                          pw.SizedBox(height: 10),
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

              pw.SizedBox(height: 15),

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

              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business! • This is a computer generated invoice',
                  style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                      fontStyle: pw.FontStyle.italic),
                ),
              ),

              ///this footer Is Only Last page
              //pw.Spacer(),

              /// Advertise Footer - Single Line Compact
              // pw.Container(
              //   padding: pw.EdgeInsets.symmetric(vertical: 8),
              //   decoration: pw.BoxDecoration(
              //     color: PdfColors.grey50,
              //     border: pw.Border(
              //       top: pw.BorderSide(color: borderColor, width: 1),
              //     ),
              //   ),
              //   child: pw.Row(
              //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              //     children: [
              //       // Left side - Application By & Address
              //       pw.Column(
              //         crossAxisAlignment: pw.CrossAxisAlignment.start,
              //         mainAxisSize: pw.MainAxisSize.min,
              //         children: [
              //           // 1st Line: App Name
              //           pw.Text(
              //             "Application By: Intelligent Tech",
              //             style: pw.TextStyle(
              //               fontSize: 9,
              //               color: primaryColor,
              //               fontWeight: pw.FontWeight.bold,
              //             ),
              //           ),
              //           pw.SizedBox(height: 2),
              //           // 2nd Line: Address
              //           pw.Text(
              //             "252, NEO Square, P.N.Marg Jamnagar",
              //             style: pw.TextStyle(
              //               fontSize: 7,
              //               color: PdfColors.grey600,
              //             ),
              //           ),
              //         ],
              //       ),
              //
              //       // Right side - Website & Email
              //       pw.Column(
              //         crossAxisAlignment: pw.CrossAxisAlignment.end, // Align text to the right
              //         mainAxisSize: pw.MainAxisSize.min,
              //         children: [
              //           // 1st Line: Website
              //           pw.Text(
              //             "www.intelligenttech.in",
              //             style: pw.TextStyle(
              //               fontSize: 9,
              //               color: PdfColors.blue700,
              //               fontWeight: pw.FontWeight.bold,
              //             ),
              //           ),
              //           pw.SizedBox(height: 2),
              //           // 2nd Line: Email
              //           pw.Text(
              //             "info@intelligenttech.in",
              //             style: pw.TextStyle(
              //               fontSize: 8,
              //               color: PdfColors.blue700,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ];
          },
        ),
      );

      /// Save PDF
      /// 1. Generate PDF Bytes
      final Uint8List bytes = await pdf.save();

      //final directory = await getApplicationDocumentsDirectory();
      final String filePrefix = invoiceType == InvoiceType.quotation ? 'Quotation' : 'Invoice';

      // 1. Sanitize the Date: Replace slashes '/' with hyphens '-' to prevent path errors
      String safeDate = invoiceDate.replaceAll('/', '_').replaceAll(' ', '_');

      // 2. Sanitize the Name: Replace spaces with underscores for better file handling
      String safeName = userName.replaceAll(' ', '_').replaceAll('/', '-');

     // final filePath = '${directory.path}/${filePrefix}_${invoiceId}_${safeName}_${safeDate}.pdf';
      final String filename = '${filePrefix}_${invoiceId}_${safeName}_${safeDate}.pdf';

      // if (kIsWeb) {
      //   // -------------------------------------------
      //   // 💻 WEB: Download the PDF
      //   // -------------------------------------------
      //
      //   // Create Blob from bytes
      //   final blob = html.Blob([bytes], 'application/pdf');
      //
      //   // Create an object URL for the Blob
      //   final url = html.Url.createObjectUrlFromBlob(blob);
      //
      //   // Create a hidden anchor element to trigger download
      //   final anchor = html.AnchorElement()
      //     ..href = url
      //     ..style.display = 'none'
      //     ..download = filename; // This attribute forces download
      //
      //   // Add to DOM, click, and remove
      //   html.document.body?.children.add(anchor);
      //   anchor.click();
      //   html.document.body?.children.remove(anchor);
      //
      //   // Revoke the URL to free memory
      //   html.Url.revokeObjectUrl(url);
      //
      //   print("✅ Web Download Triggered: $filename");
      //
      // }
      if (kIsWeb) {
        try {
          print("🌐 Opening print dialog for: $filename");

          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => bytes,
            name: filename,
          );

          print("✅ Print dialog opened successfully");

          Get.snackbar(
            'Ready to Print',
            'Print dialog opened successfully',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            icon: Icon(Icons.print, color: Colors.green.shade700),
          );

        } catch (e) {
          print("❌ Error opening print dialog: $e");

          Get.snackbar(
            'Print Error',
            'Could not open print dialog: ${e.toString()}',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            icon: Icon(Icons.error_outline, color: Colors.red.shade700),
          );
        }

        return null;
      }
    else {
        // -------------------------------------------
        // 📱 MOBILE: Save to Storage & Share
        // -------------------------------------------

        // Get Document Directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';

        // Write to File
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);

        print("✅ Mobile File Saved: $filePath");

        // Open Share Sheet
        await Share.shareXFiles(
            [XFile(filePath)],
            text: '$documentTitle - $invoiceId'
        );
      }
      // final file = File(filePath);
      // await file.writeAsBytes(await pdf.save());
      //
      // print("✅ PDF Saved: $filePath");
      //
      // await Share.shareXFiles([XFile(filePath)], text: '$documentTitle - $invoiceId');
      //

    } catch (e) {
      print("❌ Error generating PDF: $e");
    }
  }

  /// Same as [generateAndShareInvoice] but with teal/color theme (header, borders, table header, totals).
  /// Use this for a colored PDF; keep [generateAndShareInvoice] for black & white.
  static Future<void> generateAndShareInvoiceColor(
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
      String dueDate,
      ) async {
    try {
      final pdf = pw.Document();

      final String mainFontPath = AppConstants.isGujarati.value
          ? "assets/fonts/NotoSansGujarati-Regular.ttf"
          : "assets/fonts/NotoSans-Regular.ttf";

      final fontData = await rootBundle.load(mainFontPath);
      final iconData = await rootBundle.load("assets/fonts/NotoEmoji-Regular.ttf");

      // Fallback માટે બીજો ફોન્ટ (મિક્સ ટેક્સ્ટ હોય તો કામ લાગે)
      final fallbackFontData = await rootBundle.load(
          AppConstants.isGujarati.value ? "assets/fonts/NotoSans-Regular.ttf" : "assets/fonts/NotoSansGujarati-Regular.ttf"
      );
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());
      final notoEmoji  = pw.Font.ttf(iconData.buffer.asByteData());
      final fallbackFont = pw.Font.ttf(fallbackFontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont, bold: customFont,
        italic: customFont, boldItalic: customFont,fontFallback: [fallbackFont, notoEmoji],
      );

      final String invoiceId = invoices.isNotEmpty ? invoices.first.invoiceId : "UNKNOWN";

      String companyName    = companyData['companyName']   ?? 'Your Company Name';
      String companyAddress = companyData['address']       ?? 'Company Address';
      String companyCity    = companyData['city']          ?? 'City';
      String companyState   = companyData['state']         ?? 'State';
      String companyPin     = companyData['pincode']       ?? 'PIN Code';
      String companyPhone   = companyData['phone']         ?? '+91 XXXXXXXXXX';
      String companyEmail   = companyData['userEmail']     ?? 'company@email.com';
      String companyGst     = companyData['gst']           ?? 'XXXXXXXXXXXXXXX';
      String companyBank    = companyData['bankName']      ?? 'Bank Name';
      String companyAccount = companyData['accountNumber'] ?? 'Account Number';
      String companyUpi     = companyData['upiId']         ?? 'Upi Id';
      String companyIfsc    = companyData['ifsc']          ?? 'IFSC Code';
      String companyPan     = companyData['pan']           ?? 'PAN Number';

      final bool isGuj = AppConstants.isGujarati.value;

// ગુજરાતી અને ઇંગ્લિશ હેડર્સ
      final String hNo      = '#';
      final String hDesc    = 'DESCRIPTION';
      final String hQty     = 'QTY';
      final String hPrice   = 'PRICE';
      final String hAmount  = 'AMOUNT';
      final String hGst     = 'GST'; // GST ને GST જ રખાય અથવા 'ટેક્સ'
      final String hNet     ='NET';

      final Uint8List? logoBytes = await _loadLogoBytes(companyData['logo']?.toString());

      // ── Theme colors ──
      final PdfColor darkRed     = PdfColor.fromHex('#B71C1C');
      final PdfColor darkBrown   = PdfColor.fromHex('#5D4037');
      final PdfColor darkBlue    = PdfColor.fromHex('#1565C0');
      final PdfColor green       = PdfColor.fromHex('#2E7D32');
      final PdfColor beigeBox    = PdfColor.fromHex('#FFF8E7');
      final PdfColor borderColor = PdfColor.fromHex('#D7CCC8');
      final PdfColor blackBorder = PdfColor.fromHex('#1A1A1A');
      final PdfColor white       = PdfColors.white;
      final PdfColor textMuted   = PdfColor.fromHex('#6D4C41');
      final PdfColor maroon      = PdfColor.fromHex('#8B0000');

      final String documentTitle = getInvoiceDocumentTitle(
          invoiceType, invoices.isNotEmpty ? invoices.first.status : null);

      // ── CHANGE 1: Badge title — "Invoice" → "Tax Invoice", બાકી same ──
      final String badgeTitle = (documentTitle.toLowerCase() == 'invoice')
          ? 'Tax Invoice'
          : documentTitle;

      // ── Fetch selected PDF template from Firestore (company document)
      // Logo layout is controlled by the template ID (Center is default).
      String selectedPdfTemplate = 'Classic';
      try {
        final user = FirebaseAuth.instance.currentUser;
        final companyId = AppConstants.companyId;
        if (user != null && companyId.isNotEmpty) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('companies')
              .doc(companyId)
              .get();
          final data = doc.data();
          final t = data?['selectedPdfTemplate']?.toString();
          if (t == 'Modern' ||
              t == 'Classic' ||
              t == 'ClassicLeftLogo' ||
              t == 'ClassicRightLogo' ||
              t == 'Minimal' ||
              t == 'Professional' ||
              t == 'Elegant') {
            selectedPdfTemplate = t!;
          }
        }
      } catch (_) {}

      // Logo layout derived from selectedPdfTemplate (no separate setting).
      final String logoPosition = (selectedPdfTemplate == 'ClassicLeftLogo')
          ? 'Left'
          : (selectedPdfTemplate == 'ClassicRightLogo')
              ? 'Right'
              : 'Center';

      // ── Theme colors by template only
      final PdfColor primaryColor;
      final PdfColor headerBgColor;
      final PdfColor tableHeaderBg;
      final PdfColor dividerColor;
      switch (selectedPdfTemplate) {
        case 'Modern':
          primaryColor = PdfColor.fromHex('#00897B');
          headerBgColor = PdfColors.white;
          tableHeaderBg = PdfColor.fromHex('#00897B');
          dividerColor = PdfColor.fromHex('#00897B');
          break;
        case 'Minimal':
          primaryColor = PdfColor.fromHex('#424242');
          headerBgColor = PdfColors.grey100;
          tableHeaderBg = PdfColor.fromHex('#616161');
          dividerColor = PdfColor.fromHex('#9E9E9E');
          break;
        case 'Professional':
          primaryColor = PdfColor.fromHex('#1565C0');
          headerBgColor = PdfColors.white;
          tableHeaderBg = PdfColor.fromHex('#1565C0');
          dividerColor = PdfColor.fromHex('#1565C0');
          break;
        case 'Elegant':
          primaryColor = PdfColor.fromHex('#4527A0');
          headerBgColor = PdfColor.fromHex('#EDE7F6');
          tableHeaderBg = PdfColor.fromHex('#4527A0');
          dividerColor = PdfColor.fromHex('#4527A0');
          break;
        case 'ClassicLeftLogo':
        case 'ClassicRightLogo':
        default: // Classic
          primaryColor = maroon;
          headerBgColor = beigeBox;
          tableHeaderBg = darkBlue;
          dividerColor = maroon;
          break;
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.all(25),
          build: (pw.Context context) {
            final int shownItemRows = invoices.length > 16 ? 16 : invoices.length;

            // ── Footer widget (theme colors) ──
            pw.Widget footerWidget() => pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Application By: Intelligent Tech, 252, NEO Square, P.N.Marg Jamnagar, 7383915985',
                    style: pw.TextStyle(fontSize: 8, color: primaryColor, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Container(height: 2, width: double.infinity, color: primaryColor),
                pw.Container(height: 2, width: double.infinity, color: headerBgColor),
                pw.Container(height: 2, width: double.infinity, color: primaryColor),
              ],
            );

            // ── Notes/Totals builder ──
            final bool hasBankDetails =
                companyBank.toString().trim().isNotEmpty ||
                    companyAccount.toString().trim().isNotEmpty ||
                    companyIfsc.toString().trim().isNotEmpty ||
                    companyUpi.toString().trim().isNotEmpty;

            final List<String> allNoteItems = [];
            if (notes.trim().isNotEmpty) {
              allNoteItems.addAll(notes.trim().split('\n').where((l) => l.trim().isNotEmpty));
            }
            if (companyData['isExtraNotesEnabled'] == true) {
              if ((companyData['extraNote1'] ?? '').toString().trim().isNotEmpty)
                allNoteItems.add(companyData['extraNote1'].toString().trim());
              if ((companyData['extraNote2'] ?? '').toString().trim().isNotEmpty)
                allNoteItems.add(companyData['extraNote2'].toString().trim());
              if ((companyData['extraNote3'] ?? '').toString().trim().isNotEmpty)
                allNoteItems.add(companyData['extraNote3'].toString().trim());
            }
            final bool showNotesBox = hasBankDetails || allNoteItems.isNotEmpty;

            pw.Widget noteItem(String text) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                  pw.Expanded(child: pw.Text(text, style: pw.TextStyle(fontSize: 7, color: textMuted))),
                ],
              ),
            );

            pw.Widget buildZigzagNotes() {
              if (allNoteItems.isEmpty) return pw.SizedBox.shrink();
              final List<pw.Widget> rows = [];
              for (int i = 0; i < allNoteItems.length; i += 2) {
                final String leftText = allNoteItems[i];
                final String? rightText = i + 1 < allNoteItems.length ? allNoteItems[i + 1] : null;
                rows.add(pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: noteItem(leftText)),
                    pw.SizedBox(width: 4),
                    pw.Expanded(child: rightText != null ? noteItem(rightText) : pw.SizedBox.shrink()),
                  ],
                ));
              }
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rows);
            }

            pw.Widget notesColumn() => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (hasBankDetails) ...[
                  pw.Text('BANK DETAILS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: primaryColor)),
                  pw.SizedBox(height: 2),
                  if (companyBank.isNotEmpty) pw.Text('Bank: $companyBank', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                  if (companyAccount.isNotEmpty) pw.Text('A/C: $companyAccount', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                  if (companyIfsc.isNotEmpty) pw.Text('IFSC: $companyIfsc', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                  if (companyUpi.isNotEmpty) pw.Text('Upi: $companyUpi', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                  pw.SizedBox(height: 4),
                ],
                if (allNoteItems.isNotEmpty) ...[
                  pw.Text('NOTES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: primaryColor)),
                  pw.SizedBox(height: 2),
                  buildZigzagNotes(),
                ],
              ],
            );

            pw.Widget totalsColumn() => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('TOTALS SUMMARY:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: primaryColor)),
                pw.SizedBox(height: 4),
                _buildTotalRow('Subtotal', subtotal, formatted: true, primaryColor: primaryColor),
                if (AppConstants.withGST.value)
                  _buildTotalRow('CGST', gstAmount / 2, formatted: true, primaryColor: primaryColor),
                if (AppConstants.withGST.value)
                  _buildTotalRow('SGST', gstAmount / 2, formatted: true, primaryColor: primaryColor),
                pw.Divider(color: borderColor, height: 10),
                _buildTotalRow('TOTAL', totalAmount, formatted: true, isTotal: true, isBold: true, primaryColor: primaryColor),
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: white,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: borderColor, width: 0.5),
                  ),
                  child: pw.Text(
                    'Amount in Words: ${_numberToWords(totalAmount)}',
                    style: pw.TextStyle(fontSize: 7, color: textMuted),
                    textAlign: pw.TextAlign.center,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                  ),
                ),
              ],
            );

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Top striped border (theme) ──
                pw.Container(height: 2, width: double.infinity, color: primaryColor),
                pw.Container(height: 2, width: double.infinity, color: headerBgColor),
                pw.Container(height: 2, width: double.infinity, color: primaryColor),
                pw.SizedBox(height: 8),

                // ── Header by logo position: Left, Center, Right, TopLeft, TopCenter ──
                _buildColorInvoiceHeader(
                  logoPosition: logoPosition,
                  logoBytes: logoBytes,
                  companyName: companyName,
                  companyAddress: companyAddress,
                  companyCity: companyCity,
                  companyState: companyState,
                  companyPin: companyPin,
                  companyPhone: companyPhone,
                  companyEmail: companyEmail,
                  companyGst: companyGst,
                  companyPan: companyPan,
                  primaryColor: primaryColor,
                  textMuted: textMuted,
                ),

                pw.SizedBox(height: 8),
                pw.Container(height: 2, width: double.infinity, color: dividerColor),
                pw.SizedBox(height: 10),

                // ── Info Box: TO (left) + Invoice Badge (right) ──
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: white,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: blackBorder, width: 1),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // LEFT: TO
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: primaryColor)),
                            pw.SizedBox(height: 4),
                            pw.Text(userName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: primaryColor)),
                            if (customerAddress.isNotEmpty) pw.Text(customerAddress, style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            pw.SizedBox(height: 2),
                            if (phoneNumber.toString().trim().isNotEmpty) pw.Text('Phone: $phoneNumber', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            if (customerEmail.isNotEmpty) pw.Text('Email: $customerEmail', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            if (customerPAN.isNotEmpty) pw.Text('PAN: $customerPAN', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            if (customerGST.isNotEmpty) pw.Text('GST: $customerGST', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                          ],
                        ),
                      ),

                      // RIGHT: Invoice Badge
                      // CHANGE 2: documentTitle "Invoice"/"invoice" → "Tax Invoice" show karo
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: pw.BoxDecoration(
                            color: headerBgColor,
                            borderRadius: pw.BorderRadius.circular(6),
                            border: pw.Border.all(color: blackBorder, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                badgeTitle, // ← "Tax Invoice" if Invoice, else Quotation/Credit Note etc.
                                style: pw.TextStyle(color: primaryColor, fontSize: 14, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 6),
                              pw.Text('#$invoiceId', style: pw.TextStyle(color: textMuted, fontSize: 10)),
                              pw.SizedBox(height: 4),
                              pw.Text('Date: $invoiceDate', style: pw.TextStyle(color: textMuted, fontSize: 9)),
                              if (AppConstants.isDueDateEnabled.value) ...[
                                pw.SizedBox(height: 2),
                                pw.Text('Due: $dueDate', style: pw.TextStyle(color: PdfColors.red700, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 8),

                // ── Items Table ──
                pw.Container(
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: blackBorder, width: 1),
                  ),
                  child: pw.Table(
                    border: pw.TableBorder(
                      top: pw.BorderSide(color: blackBorder, width: 0.5),
                      bottom: pw.BorderSide(color: blackBorder, width: 0.5),
                      left: pw.BorderSide(color: blackBorder, width: 0.5),
                      right: pw.BorderSide(color: blackBorder, width: 0.5),
                      horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
                      verticalInside: pw.BorderSide(color: borderColor, width: 0.5),
                    ),
                    columnWidths: AppConstants.withGST.value
                        ? {
                      0: const pw.FlexColumnWidth(0.25),
                      1: const pw.FlexColumnWidth(2.2),
                      2: const pw.FlexColumnWidth(0.5),
                      3: const pw.FlexColumnWidth(0.6),
                      4: const pw.FlexColumnWidth(0.7),
                      5: const pw.FlexColumnWidth(0.5),
                      6: const pw.FlexColumnWidth(0.75),
                    }
                        : {
                      0: const pw.FlexColumnWidth(0.25),
                      1: const pw.FlexColumnWidth(2.8),
                      2: const pw.FlexColumnWidth(0.55),
                      3: const pw.FlexColumnWidth(0.75),
                      4: const pw.FlexColumnWidth(0.9),
                    },
                    children: [
                      pw.TableRow(

                        decoration: pw.BoxDecoration(color: tableHeaderBg),
                        children: [
                          _tableHeaderColored(hNo,           bgColor: tableHeaderBg, textColor: white, align: pw.TextAlign.center),
                          _tableHeaderColored(hDesc, bgColor: tableHeaderBg, textColor: white, align: pw.TextAlign.left),
                          _tableHeaderColored(hQty,         bgColor: tableHeaderBg, textColor: white, align: pw.TextAlign.right),
                          _tableHeaderColored(hPrice,       bgColor: tableHeaderBg, textColor: white, align: pw.TextAlign.right),
                          _tableHeaderColored(hAmount,      bgColor: tableHeaderBg, textColor: white, align: pw.TextAlign.right),
                          if (AppConstants.withGST.value)
                            _tableHeaderColored(hGst,       bgColor: tableHeaderBg, textColor: white, align: pw.TextAlign.right),
                          if (AppConstants.withGST.value)
                            _tableHeaderColored(hNet,       bgColor: tableHeaderBg, textColor: white, align: pw.TextAlign.right),
                        ],
                      ),
                      ...List<pw.TableRow>.generate(shownItemRows, (int index) {
                        Invoice item = invoices[index];
                        double baseAmount = (item.price! * item.qty!);
                        double gstValue = baseAmount * (item.gst ?? 0) / 100;
                        double netAmount = baseAmount + gstValue;
                        InvoiceItem? actualItem;
                        if (item.items != null && item.items!.isNotEmpty) actualItem = item.items!.first;
                        String displayItemName = actualItem?.itemName ?? item.itemName ?? '';
                        bool hasServiceDescription = actualItem != null &&
                            actualItem.description.isNotEmpty &&
                            actualItem.description != actualItem.itemName &&
                            actualItem.description.trim() != displayItemName.trim();
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(color: white),
                          children: [
                            _tableCellColored('${index + 1}',                        align: pw.TextAlign.center, textColor: textMuted),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(displayItemName,
                                      style: pw.TextStyle(fontSize: 8.5, color: primaryColor, fontWeight: pw.FontWeight.bold)),
                                  if (hasServiceDescription) ...[
                                    pw.SizedBox(height: 3),
                                    pw.Text(actualItem!.description,
                                        style: pw.TextStyle(fontSize: 8, color: textMuted, fontStyle: pw.FontStyle.italic, height: 1.2),
                                        maxLines: 3),
                                  ],
                                ],
                              ),
                            ),
                            _tableCellColored(_formatQty(item.qty ?? 0),             align: pw.TextAlign.right, textColor: textMuted),
                            _tableCellColored(AppUtil.formatCurrency(item.price!),   align: pw.TextAlign.right, textColor: textMuted),
                            _tableCellColored(AppUtil.formatCurrency(baseAmount),    align: pw.TextAlign.right, textColor: textMuted),
                            if (AppConstants.withGST.value)
                              _tableCellColored(AppUtil.formatCurrency(gstValue),    align: pw.TextAlign.right, textColor: textMuted),
                            if (AppConstants.withGST.value)
                              _tableCellColored(AppUtil.formatCurrency(netAmount),   align: pw.TextAlign.right, textColor: textMuted),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                // ── Blank area expands to fill remaining space ──
                pw.Expanded(
                  child: pw.Container(
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      color: white,
                      border: pw.Border(
                        left: pw.BorderSide(color: blackBorder, width: 1),
                        right: pw.BorderSide(color: blackBorder, width: 1),
                        bottom: pw.BorderSide(color: blackBorder, width: 1),
                      ),
                    ),
                    child: pw.Row(
                      children: AppConstants.withGST.value
                          ? [
                        pw.Expanded(flex: 25,  child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 220, child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 50,  child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 60,  child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 70,  child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 50,  child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 75,  child: pw.Container()),
                      ]
                          : [
                        pw.Expanded(flex: 25,  child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 280, child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 55,  child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 75,  child: pw.Container()),
                        pw.Container(width: 0.5, color: borderColor),
                        pw.Expanded(flex: 90,  child: pw.Container()),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 8),

                // ── Notes + Totals ──
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: white,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: blackBorder, width: 1),
                  ),
                  child: showNotesBox
                      ? pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FixedColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                    },
                    border: pw.TableBorder(
                      verticalInside: pw.BorderSide(color: borderColor, width: 1),
                    ),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(padding: pw.EdgeInsets.only(right: 10), child: notesColumn()),
                          pw.SizedBox.shrink(),
                          pw.Padding(padding: pw.EdgeInsets.only(left: 10), child: totalsColumn()),
                        ],
                      ),
                    ],
                  )
                      : totalsColumn(),
                ),

                pw.SizedBox(height: 8),

                // ── Signatures ──
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                      pw.Container(width: 150, height: 1, color: borderColor),
                      pw.SizedBox(height: 5),
                      pw.Text('Customer Signature', style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                      pw.Container(width: 150, height: 1, color: borderColor),
                      pw.SizedBox(height: 5),
                      pw.Text('Authorized Signature', style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                    ]),
                  ],
                ),

                pw.SizedBox(height: 8),

                // ── Footer ──
                footerWidget(),
              ],
            );
          },
        ),
      );

      final Uint8List bytes = await pdf.save();
      final String filePrefix = invoiceType == InvoiceType.quotation ? 'Quotation' : 'Invoice';
      String safeDate = invoiceDate.replaceAll('/', '_').replaceAll(' ', '_');
      String safeName = userName.replaceAll(' ', '_').replaceAll('/', '-');
      final String filename = '${filePrefix}_${invoiceId}_${safeName}_${safeDate}.pdf';

      if (kIsWeb) {
        try {
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => bytes,
            name: filename,
          );
          Get.snackbar(
            'Ready to Print', 'Print dialog opened successfully',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            icon: Icon(Icons.print, color: Colors.green.shade700),
          );
        } catch (e) {
          print("❌ Error opening print dialog: $e");
          Get.snackbar(
            'Print Error', 'Could not open print dialog: ${e.toString()}',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            icon: Icon(Icons.error_outline, color: Colors.red.shade700),
          );
        }
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      final filePath  = '${directory.path}/$filename';
      final file      = io.File(filePath);
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(filePath)], text: '$documentTitle - $invoiceId');

    } catch (e) {
      print("❌ Error generating PDF (color): $e");
    }
  }

  static Future<void> generateAndShareInvoicePrint(
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
      String dueDate,
      ) async {
    try {
      final pdf = pw.Document();

      final bool isGuj = AppConstants.isGujarati.value;
      final String mainFontPath = isGuj
          ? "assets/fonts/NotoSansGujarati-Regular.ttf"
          : "assets/fonts/NotoSans-Regular.ttf";

      // Load Fonts
      final fontData = await rootBundle.load(mainFontPath);
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());
      // Fallback for mixed text
      final fallbackFontData = await rootBundle.load(
          isGuj ? "assets/fonts/NotoSans-Regular.ttf" : "assets/fonts/NotoSansGujarati-Regular.ttf"
      );
      final fallbackFont = pw.Font.ttf(fallbackFontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String hItem    = isGuj ? 'વિગત' : 'Item';
      final String hQty     = isGuj ? 'જથ્થો' : 'Qty';
      final String hPrice   = isGuj ? 'ભાવ' : 'Rate';
      final String hTotal   = isGuj ? 'કુલ' : 'TOTAL';
      final String hBillTo  = isGuj ? 'ગ્રાહક:' : 'Bill To:';
      final String hBank    = isGuj ? 'બેંક વિગત:' : 'BANK DETAILS:';

      final String invoiceId = invoices.isNotEmpty ? invoices.first.invoiceId : "UNKNOWN";
      final String documentTitle = getInvoiceDocumentTitle(
          invoiceType,
          invoices.isNotEmpty ? invoices.first.status : null);

      // Company Data
      String companyName = companyData['companyName'] ?? '';
      String companyAddress = companyData['address'] ?? '';
      String companyCity = companyData['city'] ?? '';
      String companyPhone = companyData['phone'] ?? '';
      String companyEmail = companyData['userEmail'] ?? '';
      String companyGst = companyData['gst'] ?? '';
      String companyPan = companyData['pan'] ?? '';

      // Bank Data
      String companyBank = companyData['bankName'] ?? '';
      String companyAccount = companyData['accountNumber'] ?? '';
      String companyIfsc = companyData['ifsc'] ?? '';
      String companyUpi = companyData['upiId'] ?? '';

      // ✅ 80mm Page Setup (Updated from 58mm)
      final PdfPageFormat roll80mm = PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm // Increased margins for 80mm
      );

      pdf.addPage(
        pw.Page(
          pageFormat: roll80mm,
          theme: theme,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ---------------- 1. HEADER (13 -> 15) ----------------
                pw.Text(companyName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold), // Increased to 15
                    textAlign: pw.TextAlign.center),

                if(companyAddress.isNotEmpty)
                  pw.Text("$companyAddress, $companyCity",
                      style: pw.TextStyle(fontSize: 9), // Increased to 9
                      textAlign: pw.TextAlign.center),

                pw.SizedBox(height: 3),

                // Contact & Tax Info (7 -> 9)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if(companyPhone.isNotEmpty)
                      pw.Text("Mo: $companyPhone", style: pw.TextStyle(fontSize: 9)),
                    if(companyEmail.isNotEmpty)
                      pw.Text("Email: $companyEmail", style: pw.TextStyle(fontSize: 9)),
                    if(companyGst.isNotEmpty)
                      pw.Text("GST: $companyGst", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    if(companyPan.isNotEmpty)
                      pw.Text("PAN: $companyPan", style: pw.TextStyle(fontSize: 9)),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 2. INVOICE META (11 -> 13) ----------------
                pw.Text(documentTitle, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)), // Increased to 13
                pw.SizedBox(height: 2),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("No: #$invoiceId", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)), // Increased to 11
                    pw.Text("Date: $invoiceDate", style: pw.TextStyle(fontSize: 11)), // Increased to 11
                  ],
                ),
                if (AppConstants.isDueDateEnabled.value)
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text("Due: $dueDate", style: pw.TextStyle(fontSize: 10, color: PdfColors.black)), // Increased to 10
                  ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 3. CUSTOMER DETAILS (10 -> 12) ----------------
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Bill To: $userName", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)), // Increased to 12
                      if(customerAddress.isNotEmpty)
                        pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)), // Increased to 10
                      if(phoneNumber.isNotEmpty)
                        pw.Text("Mo: $phoneNumber", style: pw.TextStyle(fontSize: 10)), // Increased to 10
                      if(customerGST.isNotEmpty)
                        pw.Text("GST: $customerGST", style: pw.TextStyle(fontSize: 10)), // Increased to 10
                    ],
                  ),
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 4. ITEMS TABLE (8 -> 10) ----------------
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),   // Item Name (More space)
                    1: const pw.FixedColumnWidth(30), // Qty (Wider)
                    2: const pw.FixedColumnWidth(50), // Rate (Wider)
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text(hItem, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), // Increased to 10
                        pw.Text(hQty, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        pw.Text(hPrice, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ],
                    ),
                    pw.TableRow(children: [pw.SizedBox(height: 4), pw.SizedBox(), pw.SizedBox()]), // Slightly more spacing

                    ...invoices.map((item) {
                      InvoiceItem? actualItem;
                      if (item.items != null && item.items!.isNotEmpty) {
                        actualItem = item.items!.first;
                      }
                      String displayItemName = actualItem?.itemName ?? item.itemName ?? '';

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Text(displayItemName, style: pw.TextStyle(fontSize: 10), maxLines: 2), // Increased to 10
                          ),
                          pw.Text(_formatQty(item.qty ?? 0), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                          pw.Text(AppUtil.formatCurrency(item.price!), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 5. TOTALS SECTION (8 -> 10, 14 -> 16) ----------------
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Subtotal", style: pw.TextStyle(fontSize: 10)), // Increased to 10
                            pw.Text(AppUtil.formatCurrency(subtotal), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          ]
                      ),

                      if (AppConstants.withGST.value && gstAmount > 0) ...[
                        pw.SizedBox(height: 1),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("CGST", style: pw.TextStyle(fontSize: 10)),
                              pw.Text(AppUtil.formatCurrency(gstAmount / 2), style: pw.TextStyle(fontSize: 10)),
                            ]
                        ),
                        pw.SizedBox(height: 1),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("SGST", style: pw.TextStyle(fontSize: 10)),
                              pw.Text(AppUtil.formatCurrency(gstAmount / 2), style: pw.TextStyle(fontSize: 10)),
                            ]
                        ),
                      ],

                      pw.Divider(color: PdfColors.grey400, thickness: 0.5),

                      // TOTAL
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("TOTAL", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)), // Increased to 14
                            pw.Text(AppUtil.formatCurrency(totalAmount), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)), // Increased to 16
                          ]
                      ),
                    ],
                  ),
                ),

                // Amount in Words
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                      "(${_numberToWords(totalAmount)})",
                      style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic), // Increased to 9
                      textAlign: pw.TextAlign.right
                  ),
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 6. BANK DETAILS (8 -> 10) ----------------
                if (companyBank.isNotEmpty || companyUpi.isNotEmpty) ...[
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("BANK DETAILS:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), // Increased to 10
                        if(companyBank.isNotEmpty) pw.Text("Bank: $companyBank", style: pw.TextStyle(fontSize: 9)), // Increased to 9
                        if(companyAccount.isNotEmpty) pw.Text("A/C: $companyAccount", style: pw.TextStyle(fontSize: 9)),
                        if(companyIfsc.isNotEmpty) pw.Text("IFSC: $companyIfsc", style: pw.TextStyle(fontSize: 9)),
                        if(companyUpi.isNotEmpty) pw.Text("UPI: $companyUpi", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],

                // ---------------- 7. NOTES & EXTRAS ----------------
                if (notes.isNotEmpty) ...[
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                  pw.Text("NOTES:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), // Header
                  pw.Container(
                      width: double.infinity,
                      margin: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(notes, style: pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.left) // Increased to 9
                  ),
                ],

                if (companyData['isExtraNotesEnabled'] == true) ...[
                  if ((companyData['extraNote1'] ?? '').toString().trim().isNotEmpty)
                    pw.Text("* ${companyData['extraNote1']}", style: pw.TextStyle(fontSize: 8)), // Increased to 8
                  if ((companyData['extraNote2'] ?? '').toString().trim().isNotEmpty)
                    pw.Text("* ${companyData['extraNote2']}", style: pw.TextStyle(fontSize: 8)),
                ],

                pw.SizedBox(height: 10),

                // ---------------- 8. FOOTER (Left Aligned) ----------------
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 5),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.5, style: pw.BorderStyle.dashed))
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start, // ✅ LEFT ALIGNED
                    children: [
                      pw.Center(
                          child: pw.Text("Thank you for your business!", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)) // Increased to 11
                      ),
                      pw.SizedBox(height: 5),

                      pw.Text(
                        "Application By: Intelligent Tech",
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800), // Increased to 10
                      ),
                      pw.SizedBox(height: 1),

                      pw.Text(
                        "252, NEO Square, P.N.Marg Jamnagar",
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.black), // Increased to 8
                      ),

                      pw.SizedBox(height: 1),

                      pw.Text(
                        "www.intelligenttech.in | info@intelligenttech.in",
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.black), // Increased to 8
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save & Share Logic...
      final Uint8List bytes = await pdf.save();
      final String filePrefix = invoiceType == InvoiceType.quotation ? 'Quotation' : 'Invoice';
      String safeDate = invoiceDate.replaceAll('/', '_');
      String safeName = userName.replaceAll(' ', '_');
      final String filename = '${filePrefix}_${invoiceId}_${safeName}_${safeDate}.pdf';
      
        await Printing.layoutPdf(
            onLayout: (format) async => bytes,
            name: filename, format: roll80mm);



    } catch (e) {
      print("❌ Error generating Print PDF: $e");
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
      {String? paymentStatus}
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
      String companyUpi = companyData['upiId'] ?? 'Upi Id';
      String companyIfsc = companyData['ifsc'] ?? 'IFSC Code';
      String companyPan = companyData['pan'] ?? 'PAN Number';

      // Neutral Colors
      final PdfColor primaryColor = PdfColors.grey800;
      final PdfColor headerBg = PdfColors.grey100;
      final PdfColor borderColor = PdfColors.grey300;
      final PdfColor rowAlt = PdfColors.grey50;

      final String documentTitle = getInvoiceDocumentTitle(invoiceType, paymentStatus);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.all(25),
          footer: _buildFooter,
          build: (pw.Context context) {
            return [
              /// Header
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                          pw.SizedBox(height: 3),
                          pw.Text(companyAddress,
                              style: pw.TextStyle(color: primaryColor, fontSize: 8.5)),
                          pw.Text('$companyCity, $companyState - $companyPin',
                              style: pw.TextStyle(color: primaryColor, fontSize: 8.5)),
                          pw.SizedBox(height: 3),
                          pw.Text("Phone: $companyPhone",
                              style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                          pw.Text("Email: $companyEmail",
                              style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                          if (companyPan.isNotEmpty)
                          pw.Text("PAN: $companyPan",
                              style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                          if (companyGst.isNotEmpty)
                          pw.Text("GST: $companyGst",
                              style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
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
                padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                                  fontSize: 12)),
                          pw.SizedBox(height: 6),
                          pw.Text(userName,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          if (customerAddress.isNotEmpty)
                            pw.Text(customerAddress, style: pw.TextStyle(fontSize: 8.5)),
                          pw.SizedBox(height: 3),
                          if (phoneNumber.isNotEmpty)
                            pw.Text('Phone: $phoneNumber',
                                style: pw.TextStyle(fontSize: 8.5)),
                          if (customerEmail.isNotEmpty)
                            pw.Text('Email: $customerEmail',
                                style: pw.TextStyle(fontSize: 8.5)),
                          if (customerPAN.isNotEmpty)
                            pw.Text('PAN: $customerPAN',
                                style: pw.TextStyle(fontSize: 8.5)),
                          if (customerGST.isNotEmpty)
                            pw.Text('GST: $customerGST',
                                style: pw.TextStyle(fontSize: 8.5)),
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
                                fontSize: 10)),
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

              pw.SizedBox(height: 10),

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
                          _tableCell(_formatQty(qty), align: pw.TextAlign.right),
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
                          pw.Text('BANK DETAILS',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 11)),
                          pw.SizedBox(height: 5),
                          if (companyBank.isNotEmpty)
                            pw.Text('Bank: $companyBank',
                                style: pw.TextStyle(fontSize: 9)),
                          if (companyAccount.isNotEmpty)
                            pw.Text('A/C: $companyAccount',
                                style: pw.TextStyle(fontSize: 9)),
                          if (companyIfsc.isNotEmpty)
                            pw.Text('IFSC: $companyIfsc',
                                style: pw.TextStyle(fontSize: 9)),
                          if (companyUpi.isNotEmpty)
                            pw.Text('Upi: $companyUpi',
                                style: pw.TextStyle(fontSize: 9)),

                          pw.SizedBox(height: 15),
                          pw.Text('NOTES',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 11)),
                          pw.SizedBox(height: 6),
                          // Main invoice notes
                          if (notes.isNotEmpty.toString().trim().isNotEmpty)

                            pw.Text(notes, style: pw.TextStyle(fontSize: 7.5)),

                          // 🆕 EXTRA NOTES - Only show if enabled
                          if (companyData['isExtraNotesEnabled'] == true) ...[
                            // Extra Note 1
                            if ((companyData['extraNote1'] ?? '').toString().trim().isNotEmpty) ...[
                              pw.SizedBox(height: 3.5),
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('• ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                                  pw.Expanded(
                                    child: pw.Text(
                                      companyData['extraNote1'].toString().trim(),
                                      style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Extra Note 2
                            if ((companyData['extraNote2'] ?? '').toString().trim().isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('• ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                                  pw.Expanded(
                                    child: pw.Text(
                                      companyData['extraNote2'].toString().trim(),
                                      style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Extra Note 3
                            if ((companyData['extraNote3'] ?? '').toString().trim().isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('• ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                                  pw.Expanded(
                                    child: pw.Text(
                                      companyData['extraNote3'].toString().trim(),
                                      style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],


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

              pw.SizedBox(height: 15),

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

              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business! • This is a computer generated invoice',
                  style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                      fontStyle: pw.FontStyle.italic),
                ),
              ),

              // pw.Spacer(),
              //
              // /// Advertise Footer - Single Line Compact
              // pw.Container(
              //   padding: pw.EdgeInsets.symmetric(vertical: 8),
              //   decoration: pw.BoxDecoration(
              //     color: PdfColors.grey50,
              //     border: pw.Border(
              //       top: pw.BorderSide(color: borderColor, width: 1),
              //     ),
              //   ),
              //   child: pw.Row(
              //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              //     children: [
              //       // Left side - Application By & Address
              //       pw.Column(
              //         crossAxisAlignment: pw.CrossAxisAlignment.start,
              //         mainAxisSize: pw.MainAxisSize.min,
              //         children: [
              //           // 1st Line: App Name
              //           pw.Text(
              //             "Application By: Intelligent Tech",
              //             style: pw.TextStyle(
              //               fontSize: 9,
              //               color: primaryColor,
              //               fontWeight: pw.FontWeight.bold,
              //             ),
              //           ),
              //           pw.SizedBox(height: 2),
              //           // 2nd Line: Address
              //           pw.Text(
              //             "252, NEO Square, P.N.Marg Jamnagar",
              //             style: pw.TextStyle(
              //               fontSize: 7,
              //               color: PdfColors.grey600,
              //             ),
              //           ),
              //         ],
              //       ),
              //
              //       // Right side - Website & Email
              //       pw.Column(
              //         crossAxisAlignment: pw.CrossAxisAlignment.end, // Align text to the right
              //         mainAxisSize: pw.MainAxisSize.min,
              //         children: [
              //           // 1st Line: Website
              //           pw.Text(
              //             "www.intelligenttech.in",
              //             style: pw.TextStyle(
              //               fontSize: 9,
              //               color: PdfColors.blue700,
              //               fontWeight: pw.FontWeight.bold,
              //             ),
              //           ),
              //           pw.SizedBox(height: 2),
              //           // 2nd Line: Email
              //           pw.Text(
              //             "info@intelligenttech.in",
              //             style: pw.TextStyle(
              //               fontSize: 8,
              //               color: PdfColors.blue700,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ];
          },
        ),
      );

      /// Save PDF
      // 1. Generate PDF Bytes
      final Uint8List bytes = await pdf.save();
      //final directory = await getApplicationDocumentsDirectory();
      final String filePrefix =
      invoiceType == InvoiceType.quotation ? 'Quotation' : 'Invoice';

      // 1. Sanitize the Date: Replace slashes '/' with hyphens '-' to prevent path errors
      String safeDate = invoiceDate.replaceAll('/', '_').replaceAll(' ', '_');

      // 2. Sanitize the Name: Replace spaces with underscores for better file handling
      String safeName = userName.replaceAll(' ', '_').replaceAll('/', '-');

      final filename = '${filePrefix}_${invoiceId}_${safeName}_${safeDate}.pdf';

      // if (kIsWeb) {
      //   // -------------------------------------------
      //   // 💻 WEB: Download the PDF
      //   // -------------------------------------------
      //
      //   // Create Blob from bytes
      //   final blob = html.Blob([bytes], 'application/pdf');
      //
      //   // Create an object URL for the Blob
      //   final url = html.Url.createObjectUrlFromBlob(blob);
      //
      //   // Create a hidden anchor element to trigger download
      //   final anchor = html.AnchorElement()
      //     ..href = url
      //     ..style.display = 'none'
      //     ..download = filename; // This attribute forces download
      //
      //   // Add to DOM, click, and remove
      //   html.document.body?.children.add(anchor);
      //   anchor.click();
      //   html.document.body?.children.remove(anchor);
      //
      //   // Revoke the URL to free memory
      //   html.Url.revokeObjectUrl(url);
      //
      //   print("✅ Web Download Triggered: $filename");
      //
      // }
      if (kIsWeb) {
        try {
          print("🌐 Opening print dialog for: $filename");

          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => bytes,
            name: filename,
          );

          print("✅ Print dialog opened successfully");

          Get.snackbar(
            'Ready to Print',
            'Print dialog opened successfully',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            icon: Icon(Icons.print, color: Colors.green.shade700),
          );

        } catch (e) {
          print("❌ Error opening print dialog: $e");

          Get.snackbar(
            'Print Error',
            'Could not open print dialog: ${e.toString()}',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            icon: Icon(Icons.error_outline, color: Colors.red.shade700),
          );
        }

        return null;
      }
      else {
        // -------------------------------------------
        // 📱 MOBILE: Save to Storage & Share
        // -------------------------------------------

        // Get Document Directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';

        // Write to File using 'io.File'
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);

        print("✅ Mobile File Saved: $filePath");

        // Open Share Sheet
        await Share.shareXFiles(
            [XFile(filePath)],
            text: '$documentTitle - $invoiceId'
        );
      }

      // final file = File(filePath);
      // await file.writeAsBytes(await pdf.save());
      //
      // print("✅ PDF Saved: $filePath");
      //
      // await Share.shareXFiles([XFile(filePath)], text: '$documentTitle - $invoiceId');

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
          footer: _buildFooter,
          build: (pw.Context context) {
            return [
              /// Header
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                          pw.SizedBox(height: 3),
                          pw.Text(companyAddress,
                              style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                          pw.Text('$companyCity, $companyState - $companyPin',
                              style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                          pw.SizedBox(height: 3),
                          pw.Text("Phone: $companyPhone",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          pw.Text("Email: $companyEmail",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          if (companyPan.isNotEmpty)
                          pw.Text("PAN: $companyPan",
                              style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                          if (companyGst.isNotEmpty)
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
                padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                            fontSize: 12)),
                    pw.SizedBox(height: 6),
                    pw.Text(userName,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    if (customerAddress.isNotEmpty)
                      pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                    pw.Text('Phone: $phoneNumber',
                        style: pw.TextStyle(fontSize: 8.5)),
                    if (customerEmail.isNotEmpty)
                      pw.Text('Email: $customerEmail',
                          style: pw.TextStyle(fontSize: 8.5)),
                    if (customerPan.isNotEmpty)
                      pw.Text('PAN: $customerPan',
                          style: pw.TextStyle(fontSize: 8.5)),
                    if (customerGst.isNotEmpty)
                      pw.Text('GST: $customerGst',
                          style: pw.TextStyle(fontSize: 8.5)),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

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
                          _tableCell(_formatQty(item.qty ?? 0), align: pw.TextAlign.right),
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

              pw.SizedBox(height: 15),

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

              // /// Advertise Footer - Single Line Compact
              // pw.Container(
              //   padding: pw.EdgeInsets.symmetric(vertical: 8),
              //   decoration: pw.BoxDecoration(
              //     color: PdfColors.grey50,
              //     border: pw.Border(
              //       top: pw.BorderSide(color: borderColor, width: 1),
              //     ),
              //   ),
              //   child: pw.Row(
              //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              //     children: [
              //       // Left side - Application By & Address
              //       pw.Column(
              //         crossAxisAlignment: pw.CrossAxisAlignment.start,
              //         mainAxisSize: pw.MainAxisSize.min,
              //         children: [
              //           // 1st Line: App Name
              //           pw.Text(
              //             "Application By: Intelligent Tech",
              //             style: pw.TextStyle(
              //               fontSize: 9,
              //               color: primaryColor,
              //               fontWeight: pw.FontWeight.bold,
              //             ),
              //           ),
              //           pw.SizedBox(height: 2),
              //           // 2nd Line: Address
              //           pw.Text(
              //             "252, NEO Square, P.N.Marg Jamnagar",
              //             style: pw.TextStyle(
              //               fontSize: 7,
              //               color: PdfColors.grey600,
              //             ),
              //           ),
              //         ],
              //       ),
              //
              //       // Right side - Website & Email
              //       pw.Column(
              //         crossAxisAlignment: pw.CrossAxisAlignment.end, // Align text to the right
              //         mainAxisSize: pw.MainAxisSize.min,
              //         children: [
              //           // 1st Line: Website
              //           pw.Text(
              //             "www.intelligenttech.in",
              //             style: pw.TextStyle(
              //               fontSize: 9,
              //               color: PdfColors.blue700,
              //               fontWeight: pw.FontWeight.bold,
              //             ),
              //           ),
              //           pw.SizedBox(height: 2),
              //           // 2nd Line: Email
              //           pw.Text(
              //             "info@intelligenttech.in",
              //             style: pw.TextStyle(
              //               fontSize: 8,
              //               color: PdfColors.blue700,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ];
          },
        ),
      );

      // Save PDF
      final Uint8List bytes = await pdf.save();
      //final directory = await getApplicationDocumentsDirectory();
      final filename = 'Challan_${challanId}_$userName.pdf';

      // if (kIsWeb) {
      //   // -------------------------------------------
      //   // 💻 WEB: Download the PDF
      //   // -------------------------------------------
      //   final blob = html.Blob([bytes], 'application/pdf');
      //   final url = html.Url.createObjectUrlFromBlob(blob);
      //   final anchor = html.AnchorElement()
      //     ..href = url
      //     ..style.display = 'none'
      //     ..download = filename;
      //
      //   html.document.body?.children.add(anchor);
      //   anchor.click();
      //   html.document.body?.children.remove(anchor);
      //   html.Url.revokeObjectUrl(url);
      //
      //   print("✅ Web Download Triggered: $filename");
      //
      // }
      if (kIsWeb) {
        try {
          print("🌐 Opening print dialog for: $filename");

          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => bytes,
            name: filename,
          );

          print("✅ Print dialog opened successfully");

          Get.snackbar(
            'Ready to Print',
            'Print dialog opened successfully',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            icon: Icon(Icons.print, color: Colors.green.shade700),
          );

        } catch (e) {
          print("❌ Error opening print dialog: $e");

          Get.snackbar(
            'Print Error',
            'Could not open print dialog: ${e.toString()}',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            icon: Icon(Icons.error_outline, color: Colors.red.shade700),
          );
        }

        return null;
      }
      else {
        // -------------------------------------------
        // 📱 MOBILE: Save to Storage & Share
        // -------------------------------------------
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';

        // ✅ Use io.File to prevent conflict
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);

        print("✅ Mobile File Saved: $filePath");

        // Open Share Sheet
        await Share.shareXFiles([XFile(filePath)], text: 'Challan - $challanId');
      }

    } catch (e) {
      print("❌ Error generating Challan PDF: $e");
    }
  }

  static Future<void> generateAndShareChallanPrintOld(
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

      // Load Fonts
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String challanId = challans.isNotEmpty ? challans.first.challanId : "UNKNOWN";

      // Company Data
      String companyName = companyData['companyName'] ?? '';
      String companyAddress = companyData['address'] ?? '';
      String companyCity = companyData['city'] ?? '';
      String companyPhone = companyData['phone'] ?? '';
      String companyEmail = companyData['userEmail'] ?? '';
      String companyGst = companyData['gst'] ?? '';

      // 80mm Page Setup (SHREYANS 3inch)
      final PdfPageFormat roll80mm = PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm
      );

      pdf.addPage(
        pw.Page(
          pageFormat: roll80mm,
          theme: theme,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ---------------- 1. HEADER (13 -> 15) ----------------
                pw.Text(companyName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center),

                if(companyAddress.isNotEmpty)
                  pw.Text("$companyAddress, $companyCity",
                      style: pw.TextStyle(fontSize: 9), // 7 -> 9
                      textAlign: pw.TextAlign.center),

                pw.SizedBox(height: 3),

                // Contact & Tax Info (7 -> 9)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if(companyPhone.isNotEmpty)
                      pw.Text("Mo: $companyPhone", style: pw.TextStyle(fontSize: 9)),
                    if(companyEmail.isNotEmpty)
                      pw.Text("Email: $companyEmail", style: pw.TextStyle(fontSize: 9)),
                    if(companyGst.isNotEmpty)
                      pw.Text("GST: $companyGst", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 2. CHALLAN META (11 -> 13) ----------------
                pw.Text("CHALLAN", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("No: #$challanId", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)), // 9 -> 11
                    pw.Text("Date: $challanDate", style: pw.TextStyle(fontSize: 11)), // 9 -> 11
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 3. CUSTOMER DETAILS (10 -> 12) ----------------
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("To: $userName", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      if(customerAddress.isNotEmpty)
                        pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)), // 8 -> 10
                      if(phoneNumber.isNotEmpty)
                        pw.Text("Mo: $phoneNumber", style: pw.TextStyle(fontSize: 10)), // 8 -> 10
                      if(customerGst.isNotEmpty)
                        pw.Text("GST: $customerGst", style: pw.TextStyle(fontSize: 10)), // 8 -> 10
                    ],
                  ),
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 4. ITEMS TABLE (8 -> 10) ----------------
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FixedColumnWidth(30),
                    2: const pw.FixedColumnWidth(50),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('Item', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Qty', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        pw.Text('Rate', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ],
                    ),
                    pw.TableRow(children: [pw.SizedBox(height: 4), pw.SizedBox(), pw.SizedBox()]),

                    ...challans.map((challanEntry) {

                      // Fixed Item Type Logic
                      dynamic actualItem;
                      if (challanEntry.items != null && challanEntry.items!.isNotEmpty) {
                        actualItem = challanEntry.items!.first;
                      }

                      String displayItemName = actualItem?.itemName ?? challanEntry.itemName ?? '';
                      double qty = challanEntry.qty ?? 0.0;
                      double price = challanEntry.price ?? 0.0;

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Text(displayItemName, style: pw.TextStyle(fontSize: 10), maxLines: 2), // 8 -> 10
                          ),
                          pw.Text(_formatQty(qty), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                          pw.Text(AppUtil.formatCurrency(price), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 5. TOTALS SECTION (8 -> 10) ----------------
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Subtotal", style: pw.TextStyle(fontSize: 10)),
                            pw.Text(AppUtil.formatCurrency(subtotal), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          ]
                      ),

                      if (AppConstants.withGST.value && gstAmount > 0) ...[
                        pw.SizedBox(height: 1),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("CGST", style: pw.TextStyle(fontSize: 10)),
                              pw.Text(AppUtil.formatCurrency(gstAmount / 2), style: pw.TextStyle(fontSize: 10)),
                            ]
                        ),
                        pw.SizedBox(height: 1),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("SGST", style: pw.TextStyle(fontSize: 10)),
                              pw.Text(AppUtil.formatCurrency(gstAmount / 2), style: pw.TextStyle(fontSize: 10)),
                            ]
                        ),
                      ],

                      pw.Divider(color: PdfColors.grey400, thickness: 0.5),

                      // TOTAL (12 -> 14, 14 -> 16)
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("TOTAL", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            pw.Text(AppUtil.formatCurrency(totalAmount), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          ]
                      ),
                    ],
                  ),
                ),

                // Amount in Words
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                      "(${_numberToWords(totalAmount)})",
                      style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic), // 7 -> 9
                      textAlign: pw.TextAlign.right
                  ),
                ),

                // Payment Status
                pw.SizedBox(height: 5),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Status: ${paymentStatus.toUpperCase()}",
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                ),

                // ---------------- 6. NOTES & FOOTER ----------------

                if (notes.isNotEmpty) ...[
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                  pw.Text("NOTES:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), // Added Header
                  pw.Container(
                      width: double.infinity,
                      margin: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(notes, style: pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.left) // 7 -> 9
                  ),
                ],

                if (companyData['isExtraNotesEnabled'] == true) ...[
                  if ((companyData['extraNote1'] ?? '').toString().trim().isNotEmpty)
                    pw.Text("* ${companyData['extraNote1']}", style: pw.TextStyle(fontSize: 8)), // 6 -> 8
                  if ((companyData['extraNote2'] ?? '').toString().trim().isNotEmpty)
                    pw.Text("* ${companyData['extraNote2']}", style: pw.TextStyle(fontSize: 8)),
                ],

                pw.SizedBox(height: 10),

                // ---------------- 7. FOOTER (Left Aligned - Clear) ----------------
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 5),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.5, style: pw.BorderStyle.dashed))
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start, // ✅ LEFT ALIGNED
                    children: [
                      pw.Center(
                          child: pw.Text("Thank you!", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)) // 9 -> 11
                      ),
                      pw.SizedBox(height: 5),

                      pw.Text(
                        "Application By: Intelligent Tech",
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800), // 7 -> 9
                      ),
                      pw.SizedBox(height: 1),

                      pw.Text(
                        "252, NEO Square, P.N.Marg Jamnagar",
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.black), // 6 -> 8
                      ),

                      pw.SizedBox(height: 1),

                      pw.Text(
                        "www.intelligenttech.in | info@intelligenttech.in",
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.black), // 6 -> 8
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save & Share Logic
      final Uint8List bytes = await pdf.save();
      final String filename = 'Challan_${challanId}_$userName.pdf';

      if (kIsWeb) {
        await Printing.layoutPdf(onLayout: (format) async => bytes, name: filename, format: roll80mm);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(filePath)], text: 'Challan #$challanId');
      }

    } catch (e) {
      print("❌ Error generating Challan Print PDF: $e");
    }
  }

  static Future<void> generateAndShareChallanPrint(
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

      // Load Fonts
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String challanId = challans.isNotEmpty ? challans.first.challanId : "UNKNOWN";

      // Company Data
      String companyName = companyData['companyName'] ?? '';
      String companyAddress = companyData['address'] ?? '';
      String companyCity = companyData['city'] ?? '';
      String companyPhone = companyData['phone'] ?? '';
      String companyEmail = companyData['userEmail'] ?? '';
      String companyGst = companyData['gst'] ?? '';

      // 80mm Page Setup
      final PdfPageFormat roll80mm = PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm
      );

      pdf.addPage(
        pw.Page(
          pageFormat: roll80mm,
          theme: theme,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ---------------- 1. HEADER ----------------
                pw.Text(companyName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center),

                if(companyAddress.isNotEmpty)
                  pw.Text("$companyAddress, $companyCity",
                      style: pw.TextStyle(fontSize: 9),
                      textAlign: pw.TextAlign.center),

                pw.SizedBox(height: 3),

                // Contact & Tax Info
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if(companyPhone.isNotEmpty)
                      pw.Text("Mo: $companyPhone", style: pw.TextStyle(fontSize: 9)),
                    if(companyEmail.isNotEmpty)
                      pw.Text("Email: $companyEmail", style: pw.TextStyle(fontSize: 9)),
                    if(companyGst.isNotEmpty)
                      pw.Text("GST: $companyGst", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 2. CHALLAN META ----------------
                pw.Text("CHALLAN", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("No: #$challanId", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Date: $challanDate", style: pw.TextStyle(fontSize: 11)),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 3. CUSTOMER DETAILS ----------------
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("To: $userName", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      if(customerAddress.isNotEmpty)
                        pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)),
                      if(phoneNumber.isNotEmpty)
                        pw.Text("Mo: $phoneNumber", style: pw.TextStyle(fontSize: 10)),
                      if(customerGst.isNotEmpty)
                        pw.Text("GST: $customerGst", style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 4. ITEMS TABLE (Adjusted Widths) ----------------
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),   // Item Name (Wider)
                    1: const pw.FixedColumnWidth(30), // Qty
                    2: const pw.FixedColumnWidth(50), // Rate
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('Item', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Qty', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        pw.Text('Rate', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ],
                    ),
                    pw.TableRow(children: [pw.SizedBox(height: 4), pw.SizedBox(), pw.SizedBox()]),

                    ...challans.map((challanEntry) {

                      // Safe Item Data Extraction
                      dynamic actualItem;
                      if (challanEntry.items != null && challanEntry.items!.isNotEmpty) {
                        actualItem = challanEntry.items!.first;
                      }
                      String displayItemName = actualItem?.itemName ?? challanEntry.itemName ?? '';

                      double qty = challanEntry.qty ?? 0.0;
                      double price = challanEntry.price ?? 0.0;

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Text(displayItemName, style: pw.TextStyle(fontSize: 10), maxLines: 2),
                          ),
                          pw.Text(_formatQty(qty), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                          pw.Text(AppUtil.formatCurrency(price), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- 5. TOTALS SECTION ----------------
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Subtotal", style: pw.TextStyle(fontSize: 10)),
                            pw.Text(AppUtil.formatCurrency(subtotal), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          ]
                      ),

                      if (AppConstants.withGST.value && gstAmount > 0) ...[
                        pw.SizedBox(height: 1),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("CGST", style: pw.TextStyle(fontSize: 10)),
                              pw.Text(AppUtil.formatCurrency(gstAmount / 2), style: pw.TextStyle(fontSize: 10)),
                            ]
                        ),
                        pw.SizedBox(height: 1),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("SGST", style: pw.TextStyle(fontSize: 10)),
                              pw.Text(AppUtil.formatCurrency(gstAmount / 2), style: pw.TextStyle(fontSize: 10)),
                            ]
                        ),
                      ],

                      pw.Divider(color: PdfColors.grey400, thickness: 0.5),

                      // ✅ GRAND TOTAL (Correct Value Used)
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("TOTAL", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            pw.Text(AppUtil.formatCurrency(totalAmount), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          ]
                      ),
                    ],
                  ),
                ),

                // Amount in Words
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                      "(${_numberToWords(totalAmount)})",
                      style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
                      textAlign: pw.TextAlign.right
                  ),
                ),

                // Payment Status
                pw.SizedBox(height: 5),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Status: ${paymentStatus.toUpperCase()}",
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                ),

                // ---------------- 6. NOTES & FOOTER ----------------

                if (notes.isNotEmpty) ...[
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                  pw.Text("NOTES:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Container(
                      width: double.infinity,
                      margin: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(notes, style: pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.left)
                  ),
                ],

                if (companyData['isExtraNotesEnabled'] == true) ...[
                  if ((companyData['extraNote1'] ?? '').toString().trim().isNotEmpty)
                    pw.Text("* ${companyData['extraNote1']}", style: pw.TextStyle(fontSize: 8)),
                  if ((companyData['extraNote2'] ?? '').toString().trim().isNotEmpty)
                    pw.Text("* ${companyData['extraNote2']}", style: pw.TextStyle(fontSize: 8)),
                ],

                pw.SizedBox(height: 10),

                // ---------------- 7. FOOTER ----------------
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 5),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.5, style: pw.BorderStyle.dashed))
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(
                          child: pw.Text("Thank you!", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Application By: Intelligent Tech",
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        "252, NEO Square, P.N.Marg Jamnagar",
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.black),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        "www.intelligenttech.in | info@intelligenttech.in",
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.black),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save & Print Logic
      final Uint8List bytes = await pdf.save();
      final String filename = 'Challan_${challanId}_$userName.pdf';

      // ✅ DIRECT PRINT
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: filename,
        format: roll80mm,
      );

    } catch (e) {
      print("❌ Error generating Challan Print PDF: $e");
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

      final String documentTitle = getInvoiceDocumentTitle(
          InvoiceType.invoice,
          invoices.isNotEmpty ? invoices.first.status : null);

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
                          documentTitle,
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
      final Uint8List bytes = await pdf.save();
      //final directory = await getApplicationDocumentsDirectory();
      final filename = '/Modern_Invoice_${invoiceId}_${userName}.pdf';

      if (kIsWeb) {
        // -------------------------------------------
        // 💻 WEB: Download the PDF
        // -------------------------------------------
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = filename;

        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        print("✅ Web Download Triggered: $filename");

      } else {
        // -------------------------------------------
        // 📱 MOBILE: Save to Storage & Open
        // -------------------------------------------
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';

        final file = io.File(filePath);
        await file.writeAsBytes(bytes);

        print("✅ Modern PDF saved: $filePath");

        await OpenFile.open(filePath);
      }

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



  static Future<io.File?> generateDocument({
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
    String companyUpi = companyData['upiId'] ?? 'Upi Id';
    String companyIfsc = companyData['ifsc'] ?? 'IFSC Code';
    String companyPan = companyData['pan'] ?? 'PAN Number';

    // Neutral Colors
    final PdfColor primaryColor = PdfColors.grey800;
    final PdfColor headerBg = PdfColors.grey100;
    final PdfColor borderColor = PdfColors.grey300;
    final PdfColor rowAlt = PdfColors.grey50;

    // Document details
    final docTitle = isChallan ? "CHALLAN" : getInvoiceDocumentTitle(InvoiceType.invoice, invoice?.status);
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
        footer: _buildFooter,
        build: (pw.Context context) {
          return [
            /// Header
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                        pw.SizedBox(height: 3),
                        pw.Text(companyAddress,
                            style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                        pw.Text('$companyCity, $companyState - $companyPin',
                            style: pw.TextStyle(color: primaryColor, fontSize: 10)),
                        pw.SizedBox(height: 3),
                        pw.Text("Phone: $companyPhone",
                            style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                        pw.Text("Email: $companyEmail",
                            style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                        if (companyPan.isNotEmpty)
                        pw.Text("PAN: $companyPan",
                            style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
                        if (companyPan.isNotEmpty)
                        pw.Text("GST: $companyGst",
                            style: pw.TextStyle(fontSize: 8.5, color: primaryColor)),
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
              padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                                fontSize: 12)),
                        pw.SizedBox(height: 6),
                        pw.Text(customerName,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        if (customerAddress.isNotEmpty)
                          pw.Text(customerAddress, style: pw.TextStyle(fontSize: 8.5)),
                        pw.SizedBox(height: 3),
                        pw.Text('Phone: $customerPhone',
                            style: pw.TextStyle(fontSize: 8.5)),
                        if (customerEmail.isNotEmpty)
                          pw.Text('Email: $customerEmail',
                              style: pw.TextStyle(fontSize: 8.5)),
                        if (customerPAN.isNotEmpty)
                          pw.Text('PAN: $customerPAN',
                              style: pw.TextStyle(fontSize: 8.5)),

                        if (customerGST.isNotEmpty)
                          pw.Text('GST: $customerGST',
                              style: pw.TextStyle(fontSize: 8.5)),

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
                        _tableCell(_formatQty(qty), align: pw.TextAlign.right),
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

                        pw.Text('BANK DETAILS',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11)),
                        pw.SizedBox(height: 5),
                        if (companyBank.isNotEmpty)
                          pw.Text('Bank: $companyBank',
                              style: pw.TextStyle(fontSize: 9)),
                        if (companyAccount.isNotEmpty)
                          pw.Text('A/C: $companyAccount',
                              style: pw.TextStyle(fontSize: 9)),
                        if (companyIfsc.isNotEmpty)
                          pw.Text('IFSC: $companyIfsc',
                              style: pw.TextStyle(fontSize: 9)),
                        if (companyUpi.isNotEmpty)
                          pw.Text('Upi: $companyUpi',
                              style: pw.TextStyle(fontSize: 9)),

                        pw.SizedBox(height: 15),

                        pw.Text('NOTES',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
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

            pw.SizedBox(height: 15),

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

            pw.SizedBox(height: 15),
            pw.Center(
              child: pw.Text(
                'Thank you for your business! • This is a computer generated ${docTitle.toLowerCase()}',
                style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                    fontStyle: pw.FontStyle.italic),
              ),
            ),

            // /// Spacer pushes footer to bottom
            // pw.Spacer(),
            //
            // /// Advertise Footer
            // pw.Container(
            //   padding: pw.EdgeInsets.symmetric(vertical: 8),
            //   decoration: pw.BoxDecoration(
            //     color: PdfColors.grey50,
            //     border: pw.Border(
            //       top: pw.BorderSide(color: borderColor, width: 1),
            //     ),
            //   ),
            //   child: pw.Row(
            //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            //     children: [
            //       // Left side - Application info
            //       pw.Column(
            //         crossAxisAlignment: pw.CrossAxisAlignment.start,
            //         mainAxisSize: pw.MainAxisSize.min,
            //         children: [
            //           pw.Text(
            //             "Application By: www.intelligenttech.in",
            //             style: pw.TextStyle(
            //               fontSize: 9,
            //               color: primaryColor,
            //               fontWeight: pw.FontWeight.bold,
            //             ),
            //           ),
            //           pw.SizedBox(height: 2),
            //           pw.Text(
            //             "iNTELLIGENTTECH tECH. 252, NEO Square, Jamnagar-8",
            //             style: pw.TextStyle(
            //               fontSize: 7,
            //               color: PdfColors.grey600,
            //             ),
            //           ),
            //         ],
            //       ),
            //
            //       // Right side - Contact
            //       pw.Text(
            //         "info@intelligenttech.in",
            //         style: pw.TextStyle(
            //           fontSize: 8,
            //           color: PdfColors.blue700,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ];
        },
      ),
    );

    // Save PDF
    final Uint8List bytes = await pdf.save();
    String safeDate = DateFormat('yyyyMMdd').format(docDate);
    String safeName = customerName?.replaceAll(' ', '_').replaceAll('/', '-') ?? 'Customer';
    final String filename = '${docTitle}_${docId}_${safeName}_${safeDate}.pdf';
    // if (kIsWeb) {
    //   // -------------------------------------------
    //   // 💻 WEB: Download the PDF
    //   // -------------------------------------------
    //   final blob = html.Blob([bytes], 'application/pdf');
    //   final url = html.Url.createObjectUrlFromBlob(blob);
    //   final anchor = html.AnchorElement()
    //     ..href = url
    //     ..style.display = 'none'
    //     ..download = filename;
    //
    //   html.document.body?.children.add(anchor);
    //   anchor.click();
    //   html.document.body?.children.remove(anchor);
    //   html.Url.revokeObjectUrl(url);
    //
    //   print("✅ Web Download Triggered: $filename");
    //   return null; // No File object on Web
    //
    // }
    if (kIsWeb) {
      try {
        print("🌐 Opening print dialog for: $filename");

        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => bytes,
          name: filename,
        );

        print("✅ Print dialog opened successfully");

        Get.snackbar(
          'Ready to Print',
          'Print dialog opened successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          icon: Icon(Icons.print, color: Colors.green.shade700),
        );

      } catch (e) {
        print("❌ Error opening print dialog: $e");

        Get.snackbar(
          'Print Error',
          'Could not open print dialog: ${e.toString()}',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          icon: Icon(Icons.error_outline, color: Colors.red.shade700),
        );
      }

      return null;
    }
    else {
      // -------------------------------------------
      // 📱 MOBILE: Save to Storage
      // -------------------------------------------
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      final file = io.File(filePath);
      await file.writeAsBytes(bytes);

      print("✅ Mobile File Saved: $filePath");
      return file;
    }

  }

  static Future<io.File?> generateDocumentPrint({
    required bool isChallan,
    Invoice? invoice,
    Challan? challan,
    List<InvoiceItem>? invoiceItems,
    List<ChallanItem>? challanItems,
    required Map<String, dynamic> companyData,
  }) async {
    try {
      final pdf = pw.Document();

      // Load Fonts
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      // Data Extraction
      final String docTitle = isChallan ? "DELIVERY CHALLAN" : getInvoiceDocumentTitle(InvoiceType.invoice, invoice?.status);
      final String docId = isChallan ? (challan?.challanId ?? "UNK") : (invoice?.invoiceId ?? "UNK");
      final String docDate = isChallan
          ? (challan?.challanDate != null ? DateFormat('dd-MM-yyyy').format(challan!.challanDate!) : "")
          : (invoice?.issueDate != null ? DateFormat('dd-MM-yyyy').format(invoice!.issueDate!) : "");

      // Customer
      final String customerName = isChallan ? (challan?.customerName ?? "") : (invoice?.customerName ?? "");
      final String customerPhone = isChallan ? (challan?.customerMobile ?? "") : (invoice?.mobile ?? "");
      final String customerAddress = isChallan ? (challan?.customerAddress ?? "") : (invoice?.customerAddress ?? "");
      final String customerGst = !isChallan ? (invoice?.customerGst ?? "") : "";

      // Financials
      final double subtotal = isChallan ? (challan?.subtotal ?? 0.0) : (invoice?.subtotal ?? 0.0);
      final double gstAmount = isChallan ? (challan?.gstAmount ?? 0.0) : (invoice?.gstAmount ?? 0.0);
      final double totalAmount = subtotal + gstAmount;
      final String notes = !isChallan ? (invoice?.notes ?? "") : (challan?.notes ?? "");

      // Company Data
      String companyName = companyData['companyName'] ?? '';
      String companyAddress = companyData['address'] ?? '';
      String companyCity = companyData['city'] ?? '';
      String companyPhone = companyData['phone'] ?? '';
      String companyEmail = companyData['userEmail'] ?? '';
      String companyGst = companyData['gst'] ?? '';
      String companyPan = companyData['pan'] ?? '';

      // Bank
      String companyBank = companyData['bankName'] ?? '';
      String companyAccount = companyData['accountNumber'] ?? '';
      String companyIfsc = companyData['ifsc'] ?? '';
      String companyUpi = companyData['upiId'] ?? '';

      // ✅ 80mm Page Setup (Updated from 58mm)
      final PdfPageFormat roll80mm = PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm // Margins slightly increased for 80mm
      );

      pdf.addPage(
        pw.Page(
          pageFormat: roll80mm,
          theme: theme,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ---------------- HEADER ----------------
                pw.Text(companyName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold), // Big Header
                    textAlign: pw.TextAlign.center),

                if(companyAddress.isNotEmpty)
                  pw.Text("$companyAddress, $companyCity",
                      style: pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center),

                pw.SizedBox(height: 3),

                // Contact & Tax Info
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if(companyPhone.isNotEmpty)
                      pw.Text("Mo: $companyPhone", style: pw.TextStyle(fontSize: 10)),
                    if(companyEmail.isNotEmpty)
                      pw.Text("Email: $companyEmail", style: pw.TextStyle(fontSize: 10)),
                    if(companyGst.isNotEmpty)
                      pw.Text("GST: $companyGst", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    if(companyPan.isNotEmpty)
                      pw.Text("PAN: $companyPan", style: pw.TextStyle(fontSize: 10)),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- META ----------------
                pw.Text(docTitle, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("#$docId", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Dt: $docDate", style: pw.TextStyle(fontSize: 11)),
                  ],
                ),
                if (!isChallan && invoice?.dueDate != null)
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text("Due: ${DateFormat('dd-MM-yyyy').format(invoice!.dueDate!)}",
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                  ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- CUSTOMER ----------------
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("To: $customerName", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      if(customerAddress.isNotEmpty)
                        pw.Text(customerAddress, style: pw.TextStyle(fontSize: 10)),
                      if(customerPhone.isNotEmpty)
                        pw.Text("Mo: $customerPhone", style: pw.TextStyle(fontSize: 10)),
                      if(customerGst.isNotEmpty)
                        pw.Text("GST: $customerGst", style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- ITEMS TABLE (Adjusted for 80mm) ----------------
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),   // Item Name (More space)
                    1: const pw.FixedColumnWidth(30), // Qty (Wider)
                    2: const pw.FixedColumnWidth(50), // Rate/Amount (Wider)
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('Item', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Qty', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        pw.Text('Rate', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ],
                    ),
                    pw.TableRow(children: [pw.SizedBox(height: 4), pw.SizedBox(), pw.SizedBox()]),

                    ...(isChallan ? challanItems! : invoiceItems!).map((item) {
                      String itemName;
                      double qty, price;

                      if (isChallan) {
                        final cItem = item as ChallanItem;
                        itemName = cItem.itemName ?? '';
                        qty = cItem.quantity ?? 0;
                        price = cItem.price ?? 0;
                      } else {
                        final iItem = item as InvoiceItem;
                        itemName = iItem.itemName ?? '';
                        qty = iItem.quantity ?? 0;
                        price = iItem.rate ?? 0;
                      }

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Text(itemName, style: pw.TextStyle(fontSize: 11), maxLines: 2),
                          ),
                          pw.Text(_formatQty(qty), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.right),
                          pw.Text(AppUtil.formatCurrency(price), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- TOTALS ----------------
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Subtotal", style: pw.TextStyle(fontSize: 11)),
                            pw.Text(AppUtil.formatCurrency(subtotal), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          ]
                      ),

                      if (AppConstants.withGST.value && gstAmount > 0) ...[
                        pw.SizedBox(height: 1),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("CGST", style: pw.TextStyle(fontSize: 11)),
                              pw.Text(AppUtil.formatCurrency(gstAmount / 2), style: pw.TextStyle(fontSize: 11)),
                            ]
                        ),
                        pw.SizedBox(height: 1),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("SGST", style: pw.TextStyle(fontSize: 11)),
                              pw.Text(AppUtil.formatCurrency(gstAmount / 2), style: pw.TextStyle(fontSize: 11)),
                            ]
                        ),
                      ],

                      pw.Divider(color: PdfColors.grey400, thickness: 0.5),

                      // Grand Total
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("TOTAL", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                            pw.Text(AppUtil.formatCurrency(totalAmount), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          ]
                      ),
                    ],
                  ),
                ),

                // Amount in Words
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                      "(${_numberToWords(totalAmount)})",
                      style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                      textAlign: pw.TextAlign.right
                  ),
                ),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                // ---------------- BANK ----------------
                if (companyBank.isNotEmpty || companyUpi.isNotEmpty) ...[
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("BANK DETAILS:", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        if(companyBank.isNotEmpty) pw.Text("Bank: $companyBank", style: pw.TextStyle(fontSize: 10)),
                        if(companyAccount.isNotEmpty) pw.Text("A/C: $companyAccount", style: pw.TextStyle(fontSize: 10)),
                        if(companyIfsc.isNotEmpty) pw.Text("IFSC: $companyIfsc", style: pw.TextStyle(fontSize: 10)),
                        if(companyUpi.isNotEmpty) pw.Text("UPI: $companyUpi", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],

                // ---------------- NOTES ----------------
                if (notes.isNotEmpty) ...[
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                  pw.Text("NOTES:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Container(
                      width: double.infinity,
                      margin: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(notes, style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.left)
                  ),
                ],

                if (companyData['isExtraNotesEnabled'] == true) ...[
                  if ((companyData['extraNote1'] ?? '').toString().trim().isNotEmpty)
                    pw.Text("* ${companyData['extraNote1']}", style: pw.TextStyle(fontSize: 9)),
                  if ((companyData['extraNote2'] ?? '').toString().trim().isNotEmpty)
                    pw.Text("* ${companyData['extraNote2']}", style: pw.TextStyle(fontSize: 9)),
                ],

                pw.SizedBox(height: 10),

                // ---------------- FOOTER ----------------
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 5),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.5, style: pw.BorderStyle.dashed))
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(
                          child: pw.Text("Thank you for your business!", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))
                      ),
                      pw.SizedBox(height: 5),

                      pw.Text(
                        "Application By: Intelligent Tech",
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                      ),
                      pw.Text(
                        "252, NEO Square, P.N.Marg Jamnagar",
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.black),
                      ),
                      pw.Text(
                        "www.intelligenttech.in | info@intelligenttech.in",
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.black),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save & Return Logic
      final Uint8List bytes = await pdf.save();
      final String filename = '${isChallan ? "Challan" : "Invoice"}_$docId.pdf';

      if (kIsWeb) {
        await Printing.layoutPdf(onLayout: (format) async => bytes, name: filename, format: roll80mm);
        return null;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);
        print("✅ Print PDF Saved (80mm): $filePath");
        return file;
      }

    } catch (e) {
      print("❌ Error generating Print PDF: $e");
      return null;
    }
  }

  static Future<io.File?> generate(Invoice invoice,
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

    final String documentTitle = getInvoiceDocumentTitle(InvoiceType.invoice, invoice.status);

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
                            documentTitle,
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
    final Uint8List bytes = await pdf.save();
    //final directory = await getApplicationDocumentsDirectory();
    String safeName = (invoice.customerName ?? 'Customer').replaceAll(' ', '_').replaceAll('/', '-');
    final String filename = 'invoice_${invoice.invoiceId}_$safeName.pdf';

    if (kIsWeb) {
      // -------------------------------------------
      // 💻 WEB: Download the PDF
      // -------------------------------------------
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = filename;

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      print("✅ Web Download Triggered: $filename");
      return null;

    }
    else {
      // -------------------------------------------
      // 📱 MOBILE: Save to Storage
      // -------------------------------------------
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      // ✅ Use io.File to prevent conflict
      final file = io.File(filePath);
      await file.writeAsBytes(bytes);

      print("✅ Mobile File Saved: $filePath");
      return file;
    }
  }

  static Future<io.File?> generateChallan(
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
    final Uint8List bytes = await pdf.save();

    // 2. Prepare Filename
    String safeName = (challan.customerName ?? 'Customer').replaceAll(' ', '_').replaceAll('/', '-');
    final String filename = 'challan_${challan.challanId}_$safeName.pdf';

    if (kIsWeb) {
      // -------------------------------------------
      // 💻 WEB: Download the PDF
      // -------------------------------------------
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = filename;

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      print("✅ Web Download Triggered: $filename");
      return null;

    } else {
      // -------------------------------------------
      // 📱 MOBILE: Save to Storage
      // -------------------------------------------
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      // ✅ Use io.File to prevent conflict
      final file = io.File(filePath);
      await file.writeAsBytes(bytes);

      print("✅ Mobile File Saved: $filePath");
      return file;
    }
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

  /// Build invoice header by logo position (Left, Center, Right, TopLeft, TopCenter).
  static pw.Widget _buildColorInvoiceHeader({
    required String logoPosition,
    required Uint8List? logoBytes,
    required String companyName,
    required String companyAddress,
    required String companyCity,
    required String companyState,
    required String companyPin,
    required String companyPhone,
    required String companyEmail,
    required String companyGst,
    required String companyPan,
    required PdfColor primaryColor,
    required PdfColor textMuted,
  }) {
    pw.Widget companyInfoColumn({pw.CrossAxisAlignment align = pw.CrossAxisAlignment.start}) => pw.Column(
      crossAxisAlignment: align,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(companyName.toUpperCase(),
            style: pw.TextStyle(color: primaryColor, fontSize: align == pw.CrossAxisAlignment.center ? 22 : 18, fontWeight: pw.FontWeight.bold),
            textAlign: align == pw.CrossAxisAlignment.center ? pw.TextAlign.center : pw.TextAlign.left),
        pw.SizedBox(height: 4),
        pw.Text(
          [companyAddress, companyCity, companyState, companyPin].where((s) => s.toString().trim().isNotEmpty).join(', '),
          style: pw.TextStyle(fontSize: 8, color: textMuted),
          textAlign: align == pw.CrossAxisAlignment.center ? pw.TextAlign.center : pw.TextAlign.left,
        ),
        if (companyPhone.toString().trim().isNotEmpty)
          pw.Text('Phone: $companyPhone', style: pw.TextStyle(fontSize: 8, color: textMuted)),
        if (companyEmail.toString().trim().isNotEmpty)
          pw.Text('Email: $companyEmail', style: pw.TextStyle(fontSize: 8, color: textMuted)),
        if ((companyGst.isNotEmpty && companyGst != 'XXXXXXXXXXXXXXX') || (companyPan.isNotEmpty && companyPan != 'PAN Number'))
          pw.Text(
            [
              if (companyGst.isNotEmpty && companyGst != 'XXXXXXXXXXXXXXX') 'GST: $companyGst',
              if (companyPan.isNotEmpty && companyPan != 'PAN Number') ' PAN: $companyPan',
            ].join(' - '),
            style: pw.TextStyle(fontSize: 8, color: textMuted),
          ),
      ],
    );

    final addressLine = [
      if (companyAddress.toString().trim().isNotEmpty) companyAddress.toString().trim(),
      if (companyCity.toString().trim().isNotEmpty) companyCity.toString().trim(),
      if (companyState.toString().trim().isNotEmpty) companyState.toString().trim(),
      if (companyPin.toString().trim().isNotEmpty) companyPin.toString().trim(),
    ].join(' ');
    final contactLine = [
      if (companyPhone.toString().trim().isNotEmpty) 'Phone: $companyPhone',
      if (companyEmail.toString().trim().isNotEmpty) 'Email: $companyEmail',
    ].join(' - ');
    final gstPanLine = [
      if (companyGst.isNotEmpty && companyGst != 'XXXXXXXXXXXXXXX') 'GST: $companyGst',
      if (companyPan.isNotEmpty && companyPan != 'PAN Number') 'PAN: $companyPan',
    ].join(' - ');

    pw.Widget logoBox({
      required double width,
      required double height,
      pw.EdgeInsets? margin,
    }) {
      if (logoBytes == null) return pw.SizedBox.shrink();
      return pw.Container(
        width: width,
        height: height,
        margin: margin,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Image(
          pw.MemoryImage(logoBytes),
          fit: pw.BoxFit.contain,
        ),
      );
    }

    switch (logoPosition) {
      case 'Left':
        // Left: larger logo (140x100) so it's visible like Center; details in Expanded.
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.SizedBox(
                width: 140,
                height: 100,
                child: logoBytes == null
                    ? pw.SizedBox.shrink()
                    : pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(child: companyInfoColumn(align: pw.CrossAxisAlignment.start)),
          ],
        );
      case 'Right':
        // Right: larger logo (140x100); details Expanded on left.
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: companyInfoColumn(align: pw.CrossAxisAlignment.start)),
            pw.SizedBox(width: 12),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.SizedBox(
                width: 140,
                height: 100,
                child: logoBytes == null
                    ? pw.SizedBox.shrink()
                    : pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
              ),
            ),
          ],
        );
      case 'TopLeft':
        // TopLeft: larger logo (100x100) so it's not too small; space below for TO section.
        return pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                logoBox(
                  width: 100,
                  height: 100,
                  margin: const pw.EdgeInsets.only(right: 16),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        companyName.toUpperCase(),
                        style: pw.TextStyle(color: primaryColor, fontSize: 14, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.left,
                      ),
                      pw.SizedBox(height: 2),
                      if (addressLine.trim().isNotEmpty)
                        pw.Text(addressLine, style: pw.TextStyle(fontSize: 7, color: textMuted)),
                      if (contactLine.isNotEmpty)
                        pw.Text(contactLine, style: pw.TextStyle(fontSize: 7, color: textMuted)),
                      if (gstPanLine.isNotEmpty)
                        pw.Text(gstPanLine, style: pw.TextStyle(fontSize: 7, color: textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
          ],
        );
      case 'TopCenter':
        // TopCenter: larger logo (120x100) so it's visible; space below for TO section.
        return pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            if (logoBytes != null)
              pw.Center(child: logoBox(width: 120, height: 100))
            else
              pw.Center(
                child: pw.Text(
                  companyName.toUpperCase(),
                  style: pw.TextStyle(color: primaryColor, fontSize: 20, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                [addressLine.trim(), contactLine, gstPanLine].where((s) => s.isNotEmpty).join(' • '),
                style: pw.TextStyle(fontSize: 8, color: textMuted),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 10),
          ],
        );
      default: // Center
        // Restore original Center layout (full-width centered logo + address block).
        return pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            if (logoBytes != null)
              pw.Center(
                child: pw.Container(
                  width: double.infinity,
                  constraints: pw.BoxConstraints(maxHeight: 100),
                  child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
                ),
              )
            else
              pw.Center(
                child: pw.Text(
                  companyName.toUpperCase(),
                  style: pw.TextStyle(color: primaryColor, fontSize: 22, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                [addressLine.trim(), contactLine, gstPanLine].where((s) => s.isNotEmpty).join(' - '),
                style: pw.TextStyle(fontSize: 9, color: textMuted),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        );
    }
  }

  /// Table header with custom bg and text color (for color PDF)
  static pw.Widget _tableHeaderColored(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    required PdfColor bgColor,
    required PdfColor textColor,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      color: bgColor,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          color: textColor,
        ),
        textAlign: align,
      ),
    );
  }

  /// Table cell with optional text color (for color PDF)
  static pw.Widget _tableCellColored(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor? textColor,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: textColor ?? PdfColors.grey800,
        ),
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

  // Add this method inside your InvoiceHelper class
  static pw.Widget _buildFooter(pw.Context context) {
    final PdfColor primaryColor = PdfColors.grey800;
    final PdfColor borderColor = PdfColors.grey300;

    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border(
          top: pw.BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Application By & Address
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                "Application By: iNTELLIGNT tECH",
                style: pw.TextStyle(
                  fontSize: 9,
                  color: primaryColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "252, NEO Square, P.N.Marg Jamnagar",
                style: pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),

          // Right side - Website & Email
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                "www.intelligenttech.in",
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.blue700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "info@intelligenttech.in",
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.blue700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}




