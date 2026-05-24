import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../model/receipt_model.dart';

class ReceiptPdfHelper {
  static final _trustBlue = PdfColor.fromHex('#1a3a6b');

  static String _formatValue(String? val) {
    if (val == null || val.trim().isEmpty || val.trim().toUpperCase() == 'N/A') {
      return '-';
    }
    return val.trim();
  }

  // Returns bytes instead of File to support Web
  static Future<Uint8List> generateBytes(ReceiptModel receipt, {bool isPrint = false}) async {
    final pdf = pw.Document();

    pw.MemoryImage? logo;
    try {
      final data = await rootBundle.load('assets/images/app_logo_2.png');
      logo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {}

    pw.MemoryImage? qrImage;
    try {
      final qrData = await rootBundle.load('assets/images/qr.png');
      qrImage = pw.MemoryImage(qrData.buffer.asUint8List());
    } catch (_) {}

    final pageFormat = isPrint
        ? PdfPageFormat.a4
        : PdfPageFormat(
      PdfPageFormat.a4.width,
      380 * PdfPageFormat.point,
      marginAll: 0,
    );

    pdf.addPage(pw.Page(
      pageFormat: pageFormat,
      margin: isPrint 
          ? const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 25)
          : const pw.EdgeInsets.all(15),
      build: (context) {
        pw.Widget buildReceiptCard() {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _trustBlue, width: 1.5),
            ),
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (logo != null) pw.Image(logo, width: 55, height: 55),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text("Noor Education Trust - Jamnagar",
                              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _trustBlue)),
                          pw.SizedBox(height: 1),
                          pw.Text("Registered Under Section 80 (G) of the Income Tax Act 1961", style: const pw.TextStyle(fontSize: 7.5), textAlign: pw.TextAlign.center),
                          pw.Text("Regn. No. CIT (Exemption), Ahmedabad / 80 G / 2019-20/A/11023", style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
                          pw.Text("Registered Under the Bombay Public Trust Act 1956", style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
                          pw.Text("Reg. No. E/4326/Jamnagar", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _trustBlue)),
                        ],
                      ),
                    ),
                    if (logo != null) pw.Image(logo, width: 55, height: 55),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: _trustBlue, width: 0.8)),
                  child: pw.Text("Office Address : Nr. Bus Stand, Darbargadh, Jamnagar. M. : 98248 68786",
                      textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _trustBlue)),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _dottedField("No. :", receipt.recNo.toString(), width: 130),
                    _dottedField("Date :", receipt.date, width: 140),
                  ],
                ),
                pw.SizedBox(height: 8),
                _dottedField("Mr. / Ms. :", _formatValue(receipt.donorName)),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(child: _dottedField("Mob. :", _formatValue(receipt.mobileNo))),
                    pw.SizedBox(width: 20),
                    pw.Expanded(child: _dottedField("Pan No. :", _formatValue(receipt.panNo))),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(child: _dottedField("Donation Type :", _formatValue(receipt.donationType))),
                    pw.SizedBox(width: 20),
                    pw.Expanded(child: pw.SizedBox()), 
                  ],
                ),
                pw.SizedBox(height: 8),
                _dottedField("Amount Received in Words Rs.", _formatValue(receipt.amountInWords)),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(child: _dottedField("Bank Details :", _formatValue(receipt.bankName))),
                    pw.SizedBox(width: 20),
                    pw.Expanded(child: _dottedField("Chq. No. :", _formatValue(receipt.chequeNo))),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 140,
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: pw.BoxDecoration(
                            color: _trustBlue,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text("Rs. ", style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                              pw.Text(NumberFormat('#,##,###').format(receipt.amount.toInt()),
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (qrImage != null)
                              pw.Container(
                                margin: const pw.EdgeInsets.only(right: 6),
                                child: pw.Image(qrImage, width: 50, height: 50),
                              ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("PUNJAB NATIONAL BANK", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: _trustBlue)),
                                pw.Text("A/c. No. : 04912413000575", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.black)),
                                pw.Text("IFSC Code : PUNB0049110", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.black)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(
                      width: 220,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.SizedBox(height: 6),
                          pw.Text("Sign.", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _trustBlue)),
                          pw.SizedBox(height: 20),
                          pw.Text("Thank you for Contribution", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey800)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "Donation are Qualified for Deduction\nFrom Income Tax Under 80 (G) (50%)",
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (isPrint) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(flex: 1, child: pw.Center(child: buildReceiptCard())),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Text("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
                  style: pw.TextStyle(color: PdfColors.grey400, fontSize: 10)),
              ),
              pw.Expanded(flex: 1, child: pw.Center(child: buildReceiptCard())),
            ],
          );
        } else {
          return pw.Container(alignment: pw.Alignment.topCenter, child: buildReceiptCard());
        }
      },
    ));

    return pdf.save();
  }

  // Legacy method for mobile compatibility
  static Future<File> generate(ReceiptModel receipt, {bool isPrint = false}) async {
    final bytes = await generateBytes(receipt, isPrint: isPrint);
    
    if (kIsWeb) {
      throw UnsupportedError("dart:io File is not supported on Web. Use generateBytes instead.");
    }

    final dir = await getApplicationDocumentsDirectory();
    final receiptDir = Directory('${dir.path}/Receipts/PDF');
    if (!await receiptDir.exists()) await receiptDir.create(recursive: true);

    final suffix = isPrint ? '_print' : '_share';
    final file = File('${receiptDir.path}/receipt_${receipt.recNo}$suffix.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static pw.Widget _dottedField(String label, String value, {double? width}) {
    final bool isDash = value == '-';
    return pw.SizedBox(
      width: width,
      child: pw.Row(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8.5)),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.6, style: pw.BorderStyle.dotted)),
              ),
              padding: const pw.EdgeInsets.only(bottom: 1),
              alignment: isDash ? pw.Alignment.center : pw.Alignment.centerLeft,
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: isDash ? PdfColors.grey700 : PdfColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
