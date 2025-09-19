// import 'dart:io';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../model/model.dart';
//
//
// class PdfHelper {
//   static Future<void> generateInvoice(List<Item> items) async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text("Invoice", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 20),
//               pw.Table.fromTextArray(
//                 headers: ["Item", "Qty", "Price", "Total"],
//                 data: items.map((item) => [
//                   item.name,
//                   item.qty.toString(),
//                   item.price.toString(),
//                   (item.qty * item.price).toString()
//                 ]).toList(),
//               ),
//               pw.Divider(),
//               pw.Text(
//                 "Grand Total: ₹${items.fold(0.0, (sum, item) => sum + (item.price * item.qty)).toStringAsFixed(2)}",
//                 style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File("${dir.path}/invoice.pdf");
//     await file.writeAsBytes(await pdf.save());
//
//     await Share.shareXFiles([XFile(file.path)], text: "Here is your invoice");
//   }
// }

import 'dart:io';
import 'dart:ui';
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
import '../controller/new_invoice_controller.dart';
import '../model/model.dart';

import 'package:printing/printing.dart';

import '../services/service.dart';



///old Working
// class InvoiceHelper2 {
//   static Future<void> generateAndShareInvoice(
//       List<Invoice> invoices,
//       String userName,
//       String phoneNumber,
//       ) async {
//     final pdf = pw.Document();
//
//     // Load a font that supports ₹ symbol (make sure font is in assets/fonts)
//     final ttf = pw.Font.ttf(await rootBundle.load("assets/fonts/NotoSans-Regular.ttf"));
//
//     final theme = pw.ThemeData.withFont(
//       base: ttf,
//       bold: ttf,
//       italic: ttf,
//       boldItalic: ttf,
//     );
//
//     final String invoiceId = invoices.isNotEmpty
//         ? (invoices.first.invoiceId ?? "UNKNOWN")
//         : "UNKNOWN";
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         theme: theme, // ✅ Set theme so ₹ works everywhere
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Header
//               pw.Center(
//                 child: pw.Text(
//                   'INVOICE',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//
//               // Customer info
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('Customer: $userName'),
//                       pw.Text('Phone: $phoneNumber'),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
//                       pw.Text('Invoice #: $invoiceId'),
//                     ],
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 20),
//               pw.Divider(),
//
//               // Table header
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   pw.Expanded(flex: 1, child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   pw.Expanded(flex: 2, child: pw.Text('Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   pw.Expanded(flex: 2, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                 ],
//               ),
//               pw.Divider(),
//
//               // Items
//               ...invoices.map((item) {
//                 return pw.Padding(
//                   padding: const pw.EdgeInsets.symmetric(vertical: 4),
//                   child: pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Expanded(flex: 3, child: pw.Text(item.itemName)),
//                       pw.Expanded(flex: 1, child: pw.Text('${item.qty}', textAlign: pw.TextAlign.center)),
//                       pw.Expanded(flex: 2, child: pw.Text('₹${item.price.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
//                       pw.Expanded(flex: 2, child: pw.Text('₹${(item.price * item.qty).toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
//                     ],
//                   ),
//                 );
//               }),
//
//               pw.Divider(),
//
//               // Grand total
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.end,
//                 children: [
//                   pw.Text(
//                     'Grand Total: ₹${invoices.fold<double>(0, (sum, item) => sum + (item.price * item.qty)).toStringAsFixed(2)}',
//                     style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
//                   ),
//                 ],
//               ),
//
//               pw.SizedBox(height: 30),
//
//               pw.Center(
//                 child: pw.Text('Thank you for your business!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     // ✅ Show preview before sharing
//     // await Printing.layoutPdf(
//     //   onLayout: (PdfPageFormat format) async => pdf.save(),
//     // );
//     // /// Save to local file
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/$invoiceId.pdf';
//     final file = File(filePath);
//     await file.writeAsBytes(await pdf.save());
//
//     print("✅ PDF saved with filename: $invoiceId.pdf");
//
//     /// Share
//     await Share.shareXFiles([XFile(file.path)], text: "Here is your Invoice: $invoiceId");
//   }
//
//   static Future<void> generateAndPreviewInvoice(
//       List<Invoice> invoices,
//       String userName,
//       String phoneNumber,
//       ) async {
//     final pdf = pw.Document();
//
//     final ttf = pw.Font.ttf(await rootBundle.load("assets/fonts/NotoSans-Regular.ttf"));
//
//     pdf.addPage(
//       pw.Page(
//         build: (context) {
//           return pw.Column(
//             children: [
//               pw.Text("Invoice Preview", style: pw.TextStyle(font: ttf, fontSize: 22)),
//               pw.SizedBox(height: 20),
//               pw.Text("Customer: $userName"),
//               pw.Text("Phone: $phoneNumber"),
//               pw.SizedBox(height: 10),
//               ...invoices.map((e) => pw.Text(
//                 "${e.itemName} x${e.qty} = ₹${(e.price * e.qty).toStringAsFixed(2)}",
//                 style: pw.TextStyle(font: ttf),
//               )),
//               pw.SizedBox(height: 20),
//               pw.Text(
//                 'Grand Total: ₹${invoices.fold<double>(0, (sum, item) => sum + (item.price * item.qty)).toStringAsFixed(2)}',
//                 style: pw.TextStyle(font: ttf, fontSize: 18),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     // ✅ Show preview before sharing
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }
// }


//

class InvoiceHelper {
  // static Future<void> generateAndShareInvoice(
  //     List<Invoice> invoices,
  //     String userName,
  //     String phoneNumber,
  //     String customerEmail,
  //     String customerAddress,
  //     double subtotal,
  //     double taxAmount,
  //     double discountAmount,
  //     double totalAmount,
  //     double taxRate,
  //     String discountType,
  //     String notes,
  //     Map<String, dynamic> companyData,
  //     InvoiceType  invoiceType
  //     ) async {
  //   try {
  //     final pdf = pw.Document();
  //
  //     // Load custom font that supports rupee symbol
  //     final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
  //     final customFont = pw.Font.ttf(fontData.buffer.asByteData());
  //
  //     // Use the custom font that supports rupee symbol
  //     final theme = pw.ThemeData.withFont(
  //       base: customFont, // Use custom font instead of Helvetica
  //       bold: customFont,
  //       italic: customFont,
  //       boldItalic: customFont,
  //     );
  //
  //     final String invoiceId = invoices.isNotEmpty ? invoices.first.invoiceId : "UNKNOWN";
  //
  //     // Extract company information
  //     String companyName = companyData['companyName'] ?? 'Your Company Name';
  //     String companyAddress = companyData['address'] ?? 'Company Address';
  //     String companyCity = companyData['city'] ?? 'City';
  //     String companyState = companyData['state'] ?? 'State';
  //     String companyPin = companyData['pincode'] ?? 'PIN Code';
  //     String companyPhone = companyData['phone'] ?? '+91 XXXXXXXXXX';
  //     String companyEmail = companyData['userEmail'] ?? 'company@email.com';
  //     String companyGst = companyData['gst'] ?? 'GSTIN: XXXXXXXXXXXXXX';
  //     String companyBank = companyData['bankName'] ?? 'Bank Name';
  //     String companyAccount = companyData['accountNumber'] ?? 'Account Number';
  //     String companyIfsc = companyData['ifsc'] ?? 'IFSC Code';
  //     String companyPan = companyData['pan'] ?? 'PAN Number';
  //
  //     // Define colors based on invoice type
  //     final PdfColor primaryColor;
  //     final PdfColor headerColor;
  //     final String documentTitle;
  //
  //     switch (invoiceType) {
  //       case InvoiceType.quotation:
  //         primaryColor = PdfColors.orange700;
  //         headerColor = PdfColors.orange900;
  //         documentTitle = 'QUOTATION';
  //         break;
  //       case InvoiceType.invoice:
  //       default:
  //         primaryColor = PdfColors.blue700;
  //         headerColor = PdfColors.blue900;
  //         documentTitle = 'INVOICE';
  //     }
  //
  //     pdf.addPage(
  //       pw.Page(
  //         pageFormat: PdfPageFormat.a4,
  //         theme: theme, // Use the custom font theme
  //         margin: pw.EdgeInsets.all(25),
  //         build: (pw.Context context) {
  //           return pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               // Modern Header with Gradient Background
  //               pw.Container(
  //                 width: double.infinity,
  //                 padding: pw.EdgeInsets.all(20),
  //                 decoration: pw.BoxDecoration(
  //                   gradient: pw.LinearGradient(
  //                     colors: [primaryColor, headerColor],
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
  //                         pw.Text(
  //                           companyName.toUpperCase(),
  //                           style: pw.TextStyle(
  //                             color: PdfColors.white,
  //                             fontSize: 18,
  //                             fontWeight: pw.FontWeight.bold,
  //                           ),
  //                         ),
  //                         pw.SizedBox(height: 5),
  //                         pw.Text(
  //                           companyAddress,
  //                           style: pw.TextStyle(
  //                             color: PdfColors.white,
  //                             fontSize: 10,
  //                           ),
  //                         ),
  //                         pw.Text(
  //                           '$companyCity, $companyState - $companyPin',
  //                           style: pw.TextStyle(
  //                             color: PdfColors.white,
  //                             fontSize: 10,
  //                           ),
  //                         ),
  //                         pw.SizedBox(height: 3),
  //                         pw.Text(
  //                           '📞 $companyPhone | 📧 $companyEmail',
  //                           style: pw.TextStyle(
  //                             color: PdfColors.white,
  //                             fontSize: 9,
  //                           ),
  //                         ),
  //                         pw.Text(
  //                           companyGst,
  //                           style: pw.TextStyle(
  //                             color: PdfColors.white,
  //                             fontSize: 9,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //
  //                     // Invoice Badge
  //                     pw.Container(
  //                       padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
  //                       decoration: pw.BoxDecoration(
  //                         color: PdfColors.white,
  //                         borderRadius: pw.BorderRadius.circular(20),
  //                       ),
  //                       child: pw.Column(
  //                         children: [
  //                           pw.Text(
  //                             documentTitle,
  //                             style: pw.TextStyle(
  //                               color: PdfColors.blue800,
  //                               fontSize: 16,
  //                               fontWeight: pw.FontWeight.bold,
  //                             ),
  //                           ),
  //                           pw.SizedBox(height: 3),
  //                           pw.Text(
  //                             '#$invoiceId',
  //                             style: pw.TextStyle(
  //                               color: PdfColors.grey700,
  //                               fontSize: 10,
  //                             ),
  //                           ),
  //                           pw.Text(
  //                             DateFormat('dd MMM yyyy').format(DateTime.now()),
  //                             style: pw.TextStyle(
  //                               color: PdfColors.grey600,
  //                               fontSize: 9,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //
  //               pw.SizedBox(height: 25),
  //
  //               // Two-column layout for From/To
  //               pw.Row(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                 children: [
  //                   // From Section
  //                   pw.Expanded(
  //                     child: pw.Container(
  //                       padding: pw.EdgeInsets.all(15),
  //                       decoration: pw.BoxDecoration(
  //                         color: PdfColors.grey50,
  //                         borderRadius: pw.BorderRadius.circular(8),
  //                         border: pw.Border.all(color: PdfColors.grey300, width: 1),
  //                       ),
  //                       child: pw.Column(
  //                         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                         children: [
  //                           pw.Text(
  //                             'FROM:',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 12,
  //                             ),
  //                           ),
  //                           pw.SizedBox(height: 8),
  //                           pw.Text(
  //                             companyName,
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               fontSize: 12,
  //                             ),
  //                           ),
  //                           pw.Text(
  //                             companyAddress,
  //                             style: pw.TextStyle(fontSize: 10),
  //                           ),
  //                           pw.Text(
  //                             '$companyCity, $companyState - $companyPin',
  //                             style: pw.TextStyle(fontSize: 10),
  //                           ),
  //                           pw.SizedBox(height: 3),
  //                           pw.Text(
  //                             'Phone: $companyPhone',
  //                             style: pw.TextStyle(fontSize: 9),
  //                           ),
  //                           pw.Text(
  //                             'Email: $companyEmail',
  //                             style: pw.TextStyle(fontSize: 9),
  //                           ),
  //                           pw.Text(
  //                             'GST: $companyGst',
  //                             style: pw.TextStyle(fontSize: 9),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //
  //                   pw.SizedBox(width: 15),
  //
  //                   // To Section
  //                   pw.Expanded(
  //                     child: pw.Container(
  //                       padding: pw.EdgeInsets.all(15),
  //                       decoration: pw.BoxDecoration(
  //                         color: PdfColors.grey50,
  //                         borderRadius: pw.BorderRadius.circular(8),
  //                         border: pw.Border.all(color: PdfColors.grey300, width: 1),
  //                       ),
  //                       child: pw.Column(
  //                         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                         children: [
  //                           pw.Text(
  //                             'TO:',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 12,
  //                             ),
  //                           ),
  //                           pw.SizedBox(height: 8),
  //                           pw.Text(
  //                             userName,
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               fontSize: 12,
  //                             ),
  //                           ),
  //                           if (customerAddress.isNotEmpty)
  //                             pw.Text(
  //                               customerAddress,
  //                               style: pw.TextStyle(fontSize: 10),
  //                             ),
  //                           pw.SizedBox(height: 3),
  //                           pw.Text(
  //                             'Phone: $phoneNumber',
  //                             style: pw.TextStyle(fontSize: 9),
  //                           ),
  //                           if (customerEmail.isNotEmpty)
  //                             pw.Text(
  //                               'Email: $customerEmail',
  //                               style: pw.TextStyle(fontSize: 9),
  //                             ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //
  //               pw.SizedBox(height: 25),
  //
  //               // Items Table with Modern Design
  //               pw.Container(
  //                 decoration: pw.BoxDecoration(
  //                   borderRadius: pw.BorderRadius.circular(8),
  //                   border: pw.Border.all(color: PdfColors.grey300, width: 1),
  //                 ),
  //                 child: pw.Table(
  //                   border: pw.TableBorder(
  //                     horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
  //                     verticalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
  //                     left: pw.BorderSide.none,
  //                     right: pw.BorderSide.none,
  //                     top: pw.BorderSide.none,
  //                     bottom: pw.BorderSide.none,
  //                   ),
  //                   columnWidths: {
  //                     0: pw.FlexColumnWidth(0.4),
  //                     1: pw.FlexColumnWidth(2.5),
  //                     2: pw.FlexColumnWidth(0.6),
  //                     3: pw.FlexColumnWidth(1),
  //                     4: pw.FlexColumnWidth(1),
  //                   },
  //                   children: [
  //                     // Table Header
  //                     pw.TableRow(
  //                       decoration: pw.BoxDecoration(
  //                         color: PdfColors.blue50,
  //                         borderRadius: pw.BorderRadius.only(
  //                           topLeft: pw.Radius.circular(8),
  //                           topRight: pw.Radius.circular(8),
  //                         ),
  //                       ),
  //                       children: [
  //                         pw.Padding(
  //                           padding: pw.EdgeInsets.all(12),
  //                           child: pw.Text(
  //                             '#',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 11,
  //                             ),
  //                             textAlign: pw.TextAlign.center,
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: pw.EdgeInsets.all(12),
  //                           child: pw.Text(
  //                             'DESCRIPTION',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 11,
  //                             ),
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: pw.EdgeInsets.all(12),
  //                           child: pw.Text(
  //                             'QTY',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 11,
  //                             ),
  //                             textAlign: pw.TextAlign.center,
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: pw.EdgeInsets.all(12),
  //                           child: pw.Text(
  //                             'RATE',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 11,
  //                             ),
  //                             textAlign: pw.TextAlign.right,
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: pw.EdgeInsets.all(12),
  //                           child: pw.Text(
  //                             'AMOUNT',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 11,
  //                             ),
  //                             textAlign: pw.TextAlign.right,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //
  //                     // Table Rows
  //                     ...invoices.asMap().entries.map((entry) {
  //                       int index = entry.key;
  //                       Invoice item = entry.value;
  //                       final isEven = index % 2 == 0;
  //                       return pw.TableRow(
  //                         decoration: pw.BoxDecoration(
  //                           color: isEven ? PdfColors.white : PdfColors.grey50,
  //                         ),
  //                         children: [
  //                           pw.Padding(
  //                             padding: pw.EdgeInsets.all(10),
  //                             child: pw.Text(
  //                               '${index + 1}',
  //                               style: pw.TextStyle(fontSize: 10),
  //                               textAlign: pw.TextAlign.center,
  //                             ),
  //                           ),
  //                           pw.Padding(
  //                             padding: pw.EdgeInsets.all(10),
  //                             child: pw.Text(
  //                               item.itemName!,
  //                               style: pw.TextStyle(fontSize: 10),
  //                             ),
  //                           ),
  //                           pw.Padding(
  //                             padding: pw.EdgeInsets.all(10),
  //                             child: pw.Text(
  //                               '${item.qty}',
  //                               style: pw.TextStyle(fontSize: 10),
  //                               textAlign: pw.TextAlign.center,
  //                             ),
  //                           ),
  //                           pw.Padding(
  //                             padding: pw.EdgeInsets.all(10),
  //                             child: pw.Text(
  //                               '${item.price!.toStringAsFixed(2)}',
  //                               style: pw.TextStyle(fontSize: 10),
  //                               textAlign: pw.TextAlign.right,
  //                             ),
  //                           ),
  //                           pw.Padding(
  //                             padding: pw.EdgeInsets.all(10),
  //                             child: pw.Text(
  //                               '${(item.price! * item.qty!).toStringAsFixed(2)}',
  //                               style: pw.TextStyle(fontSize: 10),
  //                               textAlign: pw.TextAlign.right,
  //                             ),
  //                           ),
  //                         ],
  //                       );
  //                     }).toList(),
  //                   ],
  //                 ),
  //               ),
  //
  //               pw.SizedBox(height: 20),
  //
  //               // Totals Section
  //               pw.Row(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                 children: [
  //                   // Notes Section
  //                   pw.Expanded(
  //                     flex: 2,
  //                     child: pw.Container(
  //                       padding: pw.EdgeInsets.all(15),
  //                       decoration: pw.BoxDecoration(
  //                         color: PdfColors.grey50,
  //                         borderRadius: pw.BorderRadius.circular(8),
  //                         border: pw.Border.all(color: PdfColors.grey300, width: 1),
  //                       ),
  //                       child: pw.Column(
  //                         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                         children: [
  //                           pw.Text(
  //                             'NOTES',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 11,
  //                             ),
  //                           ),
  //                           pw.SizedBox(height: 8),
  //                           pw.Text(
  //                             notes.isNotEmpty ? notes : 'Thank you for your business!',
  //                             style: pw.TextStyle(fontSize: 10),
  //                           ),
  //                           pw.SizedBox(height: 15),
  //                           pw.Text(
  //                             'BANK DETAILS',
  //                             style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: primaryColor,
  //                               fontSize: 11,
  //                             ),
  //                           ),
  //                           pw.SizedBox(height: 5),
  //                           pw.Text('Bank: $companyBank', style: pw.TextStyle(fontSize: 9)),
  //                           pw.Text('A/C: $companyAccount', style: pw.TextStyle(fontSize: 9)),
  //                           pw.Text('IFSC: $companyIfsc', style: pw.TextStyle(fontSize: 9)),
  //                           pw.Text('PAN: $companyPan', style: pw.TextStyle(fontSize: 9)),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //
  //                   pw.SizedBox(width: 20),
  //
  //                   // Totals
  //                   pw.Expanded(
  //                     flex: 1,
  //                     child: pw.Container(
  //                       padding: pw.EdgeInsets.all(15),
  //                       decoration: pw.BoxDecoration(
  //                         color: PdfColors.blue50,
  //                         borderRadius: pw.BorderRadius.circular(8),
  //                         border: pw.Border.all(color: invoiceType == InvoiceType.quotation ? PdfColors.orange300: PdfColors.blue300 , width: 1),
  //                       ),
  //                       child: pw.Column(
  //                         children: [
  //                           _buildTotalRow('Subtotal', subtotal),
  //                           if (taxAmount > 0)
  //                             _buildTotalRow('Tax (${taxRate.toStringAsFixed(1)}%)', taxAmount),
  //                           if (discountAmount > 0)
  //                             _buildTotalRow('Discount', -discountAmount, isDiscount: true),
  //                           pw.Divider(color:invoiceType == InvoiceType.quotation ? PdfColors.orange300: PdfColors.blue300 , height: 20),
  //                           _buildTotalRow(
  //                             'TOTAL',
  //                             totalAmount,
  //                             isTotal: true,
  //                             isBold: true,
  //                             primaryColor: primaryColor,
  //                           ),
  //                           pw.SizedBox(height: 15),
  //                           pw.Container(
  //                             padding: pw.EdgeInsets.all(8),
  //                             decoration: pw.BoxDecoration(
  //                               color: PdfColors.blue100,
  //                               borderRadius: pw.BorderRadius.circular(4),
  //                             ),
  //                             child: pw.Text(
  //                               'Amount in Words:\n${_numberToWords(totalAmount)}',
  //                               style: pw.TextStyle(
  //                                 fontSize: 8,
  //                                 color: primaryColor,
  //                               ),
  //                               textAlign: pw.TextAlign.center,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //
  //               pw.SizedBox(height: 25),
  //
  //               // Footer with Signatures
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
  //                 children: [
  //                   pw.Column(
  //                     children: [
  //                       pw.Container(
  //                         width: 150,
  //                         height: 1,
  //                         color: PdfColors.grey400,
  //                       ),
  //                       pw.SizedBox(height: 5),
  //                       pw.Text(
  //                         'Customer Signature',
  //                         style: pw.TextStyle(
  //                           fontSize: 9,
  //                           color: PdfColors.grey600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   pw.Column(
  //                     children: [
  //                       pw.Container(
  //                         width: 150,
  //                         height: 1,
  //                         color: PdfColors.grey400,
  //                       ),
  //                       pw.SizedBox(height: 5),
  //                       pw.Text(
  //                         'Authorized Signature',
  //                         style: pw.TextStyle(
  //                           fontSize: 9,
  //                           color: PdfColors.grey600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //
  //               pw.SizedBox(height: 20),
  //               pw.Center(
  //                 child: pw.Text(
  //                   'Thank you for your business! • This is a computer generated invoice',
  //                   style: pw.TextStyle(
  //                     fontSize: 8,
  //                     color: PdfColors.grey500,
  //                     fontStyle: pw.FontStyle.italic,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     );
  //
  //     // Save and open PDF
  //     final directory = await getApplicationDocumentsDirectory();
  //     //final filePath = '${directory.path}/Invoice_${invoiceId}_${userName}.pdf';
  //     final String filePrefix = invoiceType == InvoiceType.quotation ? 'Quotation' : 'Invoice';
  //     final filePath = '${directory.path}/${filePrefix}_${invoiceId}_${userName}.pdf';
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //
  //     print("✅ Beautiful PDF saved: $filePath");
  //     ///      await OpenFile.open(filePath);
  //
  //     await Share.shareXFiles([XFile(filePath)], text: 'Invoice - $invoiceId');
  //
  //
  //   } catch (e) {
  //     print("Error generating beautiful PDF: $e");
  //   }
  // }

  static Future<void> generateAndShareInvoice(
      List<Invoice> invoices,
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
      Map<String, dynamic> companyData,
      InvoiceType  invoiceType
      ) async {
    try {
      final pdf = pw.Document();

      // Load custom font that supports rupee symbol
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      // Use the custom font that supports rupee symbol
      final theme = pw.ThemeData.withFont(
        base: customFont, // Use custom font instead of Helvetica
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String invoiceId = invoices.isNotEmpty ? invoices.first.invoiceId : "UNKNOWN";

      // Extract company information
      String companyName = companyData['companyName'] ?? 'Your Company Name';
      String companyAddress = companyData['address'] ?? 'Company Address';
      String companyCity = companyData['city'] ?? 'City';
      String companyState = companyData['state'] ?? 'State';
      String companyPin = companyData['pincode'] ?? 'PIN Code';
      String companyPhone = companyData['phone'] ?? '+91 XXXXXXXXXX';
      String companyEmail = companyData['userEmail'] ?? 'company@email.com';
      String companyGst = companyData['gst'] ?? 'GSTIN: XXXXXXXXXXXXXX';
      String companyBank = companyData['bankName'] ?? 'Bank Name';
      String companyAccount = companyData['accountNumber'] ?? 'Account Number';
      String companyIfsc = companyData['ifsc'] ?? 'IFSC Code';
      String companyPan = companyData['pan'] ?? 'PAN Number';

      // Define colors based on invoice type
      final PdfColor primaryColor;
      final PdfColor headerColor;
      final String documentTitle;

      switch (invoiceType) {
        case InvoiceType.quotation:
          primaryColor = PdfColors.orange700;
          headerColor = PdfColors.orange900;
          documentTitle = 'QUOTATION';
          break;
        case InvoiceType.invoice:
        default:
          primaryColor = PdfColors.blue700;
          headerColor = PdfColors.blue900;
          documentTitle = 'INVOICE';
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme, // Use the custom font theme
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
                      colors: [primaryColor, headerColor],
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
                              '#$invoiceId',
                              style: pw.TextStyle(
                                color: PdfColors.grey700,
                                fontSize: 10,
                              ),
                            ),
                            pw.Text(
                              DateFormat('dd MMM yyyy').format(DateTime.now()),
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
                                color: primaryColor,
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
                              'TO:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                                fontSize: 12,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              userName,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
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
                              style: pw.TextStyle(fontSize: 9),
                            ),
                            if (customerEmail.isNotEmpty)
                              pw.Text(
                                'Email: $customerEmail',
                                style: pw.TextStyle(fontSize: 9),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 25),

                // Items Table with Modern Design
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
                                color: primaryColor,
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
                                color: primaryColor,
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
                                color: primaryColor,
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
                                color: primaryColor,
                                fontSize: 11,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(12),
                            child: pw.Text(
                              'AMOUNT',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                                fontSize: 11,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),

                      /// Table Rows
                      ...invoices.asMap().entries.map((entry) {
                        int index = entry.key;
                        Invoice item = entry.value;
                        final isEven = index % 2 == 0;
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: isEven ? PdfColors.white : PdfColors.grey50,
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
                                '${item.price!.toStringAsFixed(2)}',
                                style: pw.TextStyle(fontSize: 10),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(10),
                              child: pw.Text(
                                '${(item.price! * item.qty!).toStringAsFixed(2)}',
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
                                color: primaryColor,
                                fontSize: 11,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              notes.isNotEmpty ? notes : 'Thank you for your business!',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                            pw.SizedBox(height: 15),
                            pw.Text(
                              'BANK DETAILS',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
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
                          border: pw.Border.all(color: invoiceType == InvoiceType.quotation ? PdfColors.orange300: PdfColors.blue300 , width: 1),
                        ),
                        child: pw.Column(
                          children: [
                            _buildTotalRow('Subtotal', subtotal),
                            if (taxAmount > 0)
                              _buildTotalRow('Tax (${taxRate.toStringAsFixed(1)}%)', taxAmount),
                            if (discountAmount > 0)
                              _buildTotalRow('Discount', -discountAmount, isDiscount: true),
                            pw.Divider(color:invoiceType == InvoiceType.quotation ? PdfColors.orange300: PdfColors.blue300 , height: 20),
                            _buildTotalRow(
                              'TOTAL',
                              totalAmount,
                              isTotal: true,
                              isBold: true,
                              primaryColor: primaryColor,
                            ),
                            pw.SizedBox(height: 15),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.blue100,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                'Amount in Words:\n${_numberToWords(totalAmount)}',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: primaryColor,
                                ),
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

      // Save and open PDF
      final directory = await getApplicationDocumentsDirectory();
      //final filePath = '${directory.path}/Invoice_${invoiceId}_${userName}.pdf';
      final String filePrefix = invoiceType == InvoiceType.quotation ? 'Quotation' : 'Invoice';
      final filePath = '${directory.path}/${filePrefix}_${invoiceId}_${userName}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ Beautiful PDF saved: $filePath");
      ///      await OpenFile.open(filePath);

      await Share.shareXFiles([XFile(filePath)], text: 'Invoice - $invoiceId');


    } catch (e) {
      print("Error generating beautiful PDF: $e");
    }
  }



  static Future<void> generateAndShareChallan(
      List<Challan> challans,
      String userName,
      String phoneNumber,
      String customerEmail,
      String customerAddress,
      double subtotal,
      double taxAmount,
      double totalAmount,
      double taxRate,
      String paymentStatus,
      String notes,
      Map<String, dynamic> companyData,
      ) async {
    try {
      final pdf = pw.Document();

      // Load custom font
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      // Use the custom font
      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String challanId = challans.isNotEmpty ? challans.first.challanId : "UNKNOWN";

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
          margin: pw.EdgeInsets.all(25),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with Different Color Scheme for Challan
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [PdfColors.green700, PdfColors.green900],
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

                      // Challan Badge
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'DELIVERY CHALLAN',
                              style: pw.TextStyle(
                                color: PdfColors.green800,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              '#$challanId',
                              style: pw.TextStyle(
                                color: PdfColors.grey700,
                                fontSize: 10,
                              ),
                            ),
                            pw.Text(
                              DateFormat('dd MMM yyyy').format(DateTime.now()),
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
                                color: PdfColors.green800,
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
                              'TO:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                                fontSize: 12,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              userName,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
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
                              style: pw.TextStyle(fontSize: 9),
                            ),
                            if (customerEmail.isNotEmpty)
                              pw.Text(
                                'Email: $customerEmail',
                                style: pw.TextStyle(fontSize: 9),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 25),

                // Items Table with Modern Design
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
                      // Table Header
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green50,
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
                                color: PdfColors.green800,
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
                                color: PdfColors.green800,
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
                                color: PdfColors.green800,
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
                                color: PdfColors.green800,
                                fontSize: 11,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(12),
                            child: pw.Text(
                              'AMOUNT',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                                fontSize: 11,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      // Table Rows
                      ...challans.asMap().entries.map((entry) {
                        int index = entry.key;
                        Challan item = entry.value;
                        final isEven = index % 2 == 0;
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: isEven ? PdfColors.white : PdfColors.grey50,
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
                                '₹${(item.price! * item.qty!).toStringAsFixed(2)}',
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
                                color: PdfColors.green800,
                                fontSize: 11,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              notes.isNotEmpty ? notes : 'Thank you for your business!',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                            pw.SizedBox(height: 15),
                            pw.Text(
                              'PAYMENT STATUS',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                                fontSize: 11,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              paymentStatus.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: paymentStatus == 'paid'
                                    ? PdfColors.green700
                                    : PdfColors.orange700,
                              ),
                            ),
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
                          color: PdfColors.green50,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: PdfColors.green200, width: 1),
                        ),
                        child: pw.Column(
                          children: [
                            _buildTotalRow('Subtotal', subtotal),
                            if (taxAmount > 0)
                              _buildTotalRow('Tax (${taxRate.toStringAsFixed(1)}%)', taxAmount),
                            pw.Divider(color: PdfColors.green300, height: 20),
                            _buildTotalRow(
                              'TOTAL AMOUNT',
                              totalAmount,
                              isTotal: true,
                              isBold: true,
                            ),
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
                          'Receiver Signature',
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
                          'Delivery Person Signature',
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
                    'This is a delivery challan, not a tax invoice • Valid only with authorized signature',
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

      // Save and open PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Challan_${challanId}_${userName}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ Beautiful Challan PDF saved: $filePath");

      /// First open the PDF, then offer sharing option
      //await OpenFile.open(filePath);

      /// Optionally, you can add a delay and then offer to share
      //await Future.delayed(Duration(seconds: 1));

      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'Delivery Challan - $challanId');

    } catch (e) {
      print("Error generating beautiful Challan PDF: $e");
    }
  }


  // Helper method for total rows (same as in invoice)
  static pw.Widget _buildTotalRow(String label, double amount, {bool isTotal = false, bool isBold = false, bool isDiscount = false,   PdfColor primaryColor = PdfColors.blue800,}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue900 : PdfColors.grey700,
            ),
          ),
          pw.Text(
            '${isDiscount ? '-' : ''}₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue900 : (isDiscount ? PdfColors.red : PdfColors.grey700),
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
      final units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
        'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
      return units[number];
    }
    if (number < 100) {
      final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
      return '${tens[number ~/ 10]} ${_convertNumber(number % 10)}';
    }
    if (number < 1000) {
      return '${_convertNumber(number ~/ 100)} Hundred ${_convertNumber(number % 100)}';
    }
    if (number < 100000) {
      return '${_convertNumber(number ~/ 1000)} Thousand ${_convertNumber(number % 1000)}';
    }
    if (number < 10000000) {
      return '${_convertNumber(number ~/ 100000)} Lakh ${_convertNumber(number % 100000)}';
    }
    return '${_convertNumber(number ~/ 10000000)} Crore ${_convertNumber(number % 10000000)}';
  }

  // NEW METHOD: Modern Minimalist Invoice Format
  static Future<void> generateModernInvoice(
      List<Invoice> invoices,
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
      Map<String, dynamic> companyData,
      ) async {
    try {
      final pdf = pw.Document();

      // Load custom font
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String invoiceId = invoices.isNotEmpty ? invoices.first.invoiceId : "UNKNOWN";

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
                          DateFormat('dd MMM yyyy').format(DateTime.now().add(Duration(days: 15))),
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
                    horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
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
                    ...invoices.asMap().entries.map((entry) {
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
                              '₹${(item.price! * item.qty!).toStringAsFixed(2)}',
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
                        _buildModernTotalRow('Tax (${taxRate.toStringAsFixed(1)}%)', taxAmount),
                      if (discountAmount > 0)
                        _buildModernTotalRow('Discount', -discountAmount, isDiscount: true),
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
      final filePath = '${directory.path}/Modern_Invoice_${invoiceId}_${userName}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ Modern PDF saved: $filePath");
      await OpenFile.open(filePath);

    } catch (e) {
      print("Error generating modern PDF: $e");
    }
  }

  static pw.Widget _buildModernTotalRow(String label, double amount, {bool isTotal = false, bool isBold = false, bool isDiscount = false}) {
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
              color: isTotal ? PdfColors.blue900 : (isDiscount ? PdfColors.red : PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }

// NEW METHOD: Colorful Premium Invoice Format
  static Future<void> generateColorfulInvoice(
      List<Invoice> invoices,
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
      Map<String, dynamic> companyData,
      ) async {
    try {
      final pdf = pw.Document();

      // Load custom font
      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final customFont = pw.Font.ttf(fontData.buffer.asByteData());

      final theme = pw.ThemeData.withFont(
        base: customFont,
        bold: customFont,
        italic: customFont,
        boldItalic: customFont,
      );

      final String invoiceId = invoices.isNotEmpty ? invoices.first.invoiceId : "UNKNOWN";
      // Extract company information
      String companyName = companyData['companyName'] ?? 'Samira Hadid';
      String companyAddress = companyData['address'] ?? '123 Anywhere St., Any City';
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
                        border: pw.Border.all(color: PdfColors.blue200, width: 2),
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
                            customerAddress.isEmpty ? '123 Anywhere St., Any City' : customerAddress,
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
                        border: pw.Border.all(color: PdfColors.purple200, width: 2),
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
                      padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        'Date: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
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
                      ...invoices.asMap().entries.map((entry) {
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
                                '\$${(item.price! * item.qty!).toStringAsFixed(2)}',
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
                        border: pw.Border.all(color: PdfColors.blue200, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildColorfulTotalRow('Sub Total:', subtotal),
                          if (taxAmount > 0)
                            _buildColorfulTotalRow('Tax (${taxRate.toStringAsFixed(1)}%):', taxAmount),
                          if (discountAmount > 0)
                            _buildColorfulTotalRow('Discount:', -discountAmount, isDiscount: true),
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
                          border: pw.Border.all(color: PdfColors.blue200, width: 1),
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
                              notes.isNotEmpty ? notes : 'Thank you for your business!',
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
                          border: pw.Border.all(color: PdfColors.purple200, width: 1),
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
                    padding: pw.EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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

  static pw.Widget _buildColorfulTotalRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
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
              color: isTotal ? PdfColors.blue900 : (isDiscount ? PdfColors.red : PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }




  static Future<File> generate(Invoice invoice, List<InvoiceItem> invoiceItems, Map<String, dynamic> companyData) async {
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
                    4: pw.FlexColumnWidth(1),
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
                        children: [
                          //_buildTotalRow('Subtotal', 'invoice.subtotal' ),
                          if ((invoice.taxAmount ?? 0) > 0)
                            _buildTotalRow('Tax (${invoice.taxRate?.toStringAsFixed(1) ?? '0.0'}%)', invoice.taxAmount ?? 0),
                          if ((invoice.discountAmount ?? 0) > 0)
                            _buildTotalRow('Discount', -(invoice.discountAmount ?? 0), isDiscount: true),
                          pw.Divider(color: PdfColors.blue300, height: 20),
                          _buildTotalRow(
                            'TOTAL AMOUNT ',
                            invoice.totalAmount!,
                            isTotal: true,
                            isBold: true,
                          ),
                          pw.SizedBox(height: 15),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue100,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(
                              'Amount in Words:\n${_numberToWords(invoice.totalAmount!)}',
                              style: pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.blue800,
                              ),
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


// Helper method to get status color
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
///
// class InvoiceHelper {
//   static Future<void> generateAndShareInvoice(
//       List<Invoice> invoices,
//       String userName,
//       String phoneNumber,
//       String customerEmail,
//       String customerAddress,
//       double subtotal,
//       double taxAmount,
//       double discountAmount,
//       double totalAmount,
//       double taxRate,
//       String discountType,
//       String notes,
//       Map<String, dynamic> companyData,
//       ) async {
//     try {
//       final pdf = pw.Document();
//
//       // Load a font that supports rupee symbol
//       final ttf = pw.Font.ttf(await rootBundle.load("assets/fonts/NotoSans-Regular.ttf"));
//
//
//       // Use nicer fonts (you can replace these with your preferred fonts)
//       final theme = pw.ThemeData.withFont(
//         base: pw.Font.helvetica(),
//         bold: pw.Font.helveticaBold(),
//         italic: pw.Font.helveticaOblique(),
//         boldItalic: pw.Font.helveticaBoldOblique(),
//       );
//
//       final String invoiceId = invoices.isNotEmpty ? invoices.first.invoiceId : "UNKNOWN";
//
//       // Extract company information
//       String companyName = companyData['companyName'] ?? 'Your Company Name';
//       String companyAddress = companyData['address'] ?? 'Company Address';
//       String companyCity = companyData['city'] ?? 'City';
//       String companyState = companyData['state'] ?? 'State';
//       String companyPin = companyData['pincode'] ?? 'PIN Code';
//       String companyPhone = companyData['phone'] ?? '+91 XXXXXXXXXX';
//       String companyEmail = companyData['email'] ?? 'company@email.com';
//       String companyGst = companyData['gstNumber'] ?? 'GSTIN: XXXXXXXXXXXXXX';
//       String companyBank = companyData['bankName'] ?? 'Bank Name';
//       String companyAccount = companyData['accountNumber'] ?? 'Account Number';
//       String companyIfsc = companyData['ifscCode'] ?? 'IFSC Code';
//       String companyPan = companyData['panNumber'] ?? 'PAN Number';
//
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           theme: theme,
//           margin: pw.EdgeInsets.all(25),
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Modern Header with Gradient Background
//                 pw.Container(
//                   width: double.infinity,
//                   padding: pw.EdgeInsets.all(20),
//                   decoration: pw.BoxDecoration(
//                     gradient: pw.LinearGradient(
//                       colors: [PdfColors.blue700, PdfColors.blue900],
//                       begin: pw.Alignment.topLeft,
//                       end: pw.Alignment.bottomRight,
//                     ),
//                     borderRadius: pw.BorderRadius.circular(10),
//                   ),
//                   child: pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       // Company Info
//                       pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             companyName.toUpperCase(),
//                             style: pw.TextStyle(
//                               color: PdfColors.white,
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                           pw.SizedBox(height: 5),
//                           pw.Text(
//                             companyAddress,
//                             style: pw.TextStyle(
//                               color: PdfColors.white,
//                               fontSize: 10,
//                             ),
//                           ),
//                           pw.Text(
//                             '$companyCity, $companyState - $companyPin',
//                             style: pw.TextStyle(
//                               color: PdfColors.white,
//                               fontSize: 10,
//                             ),
//                           ),
//                           pw.SizedBox(height: 3),
//                           pw.Text(
//                             '📞 $companyPhone | 📧 $companyEmail',
//                             style: pw.TextStyle(
//                               color: PdfColors.white,
//                               fontSize: 9,
//                             ),
//                           ),
//                           pw.Text(
//                             companyGst,
//                             style: pw.TextStyle(
//                               color: PdfColors.white,
//                               fontSize: 9,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       // Invoice Badge
//                       pw.Container(
//                         padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                         decoration: pw.BoxDecoration(
//                           color: PdfColors.white,
//                           borderRadius: pw.BorderRadius.circular(20),
//                         ),
//                         child: pw.Column(
//                           children: [
//                             pw.Text(
//                               'INVOICE',
//                               style: pw.TextStyle(
//                                 color: PdfColors.blue800,
//                                 fontSize: 16,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                             pw.SizedBox(height: 3),
//                             pw.Text(
//                               '#$invoiceId',
//                               style: pw.TextStyle(
//                                 color: PdfColors.grey700,
//                                 fontSize: 10,
//                               ),
//                             ),
//                             pw.Text(
//                               DateFormat('dd MMM yyyy').format(DateTime.now()),
//                               style: pw.TextStyle(
//                                 color: PdfColors.grey600,
//                                 fontSize: 9,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 pw.SizedBox(height: 25),
//
//                 // Two-column layout for From/To
//                 pw.Row(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     // From Section
//                     pw.Expanded(
//                       child: pw.Container(
//                         padding: pw.EdgeInsets.all(15),
//                         decoration: pw.BoxDecoration(
//                           color: PdfColors.grey50,
//                           borderRadius: pw.BorderRadius.circular(8),
//                           border: pw.Border.all(color: PdfColors.grey300, width: 1),
//                         ),
//                         child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text(
//                               'FROM:',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             pw.SizedBox(height: 8),
//                             pw.Text(
//                               companyName,
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             pw.Text(
//                               companyAddress,
//                               style: pw.TextStyle(fontSize: 10),
//                             ),
//                             pw.Text(
//                               '$companyCity, $companyState - $companyPin',
//                               style: pw.TextStyle(fontSize: 10),
//                             ),
//                             pw.SizedBox(height: 3),
//                             pw.Text(
//                               'Phone: $companyPhone',
//                               style: pw.TextStyle(fontSize: 9),
//                             ),
//                             pw.Text(
//                               'Email: $companyEmail',
//                               style: pw.TextStyle(fontSize: 9),
//                             ),
//                             pw.Text(
//                               'GST: $companyGst',
//                               style: pw.TextStyle(fontSize: 9),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     pw.SizedBox(width: 15),
//
//                     // To Section
//                     pw.Expanded(
//                       child: pw.Container(
//                         padding: pw.EdgeInsets.all(15),
//                         decoration: pw.BoxDecoration(
//                           color: PdfColors.grey50,
//                           borderRadius: pw.BorderRadius.circular(8),
//                           border: pw.Border.all(color: PdfColors.grey300, width: 1),
//                         ),
//                         child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text(
//                               'BILL TO:',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             pw.SizedBox(height: 8),
//                             pw.Text(
//                               userName,
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             if (customerAddress.isNotEmpty)
//                               pw.Text(
//                                 customerAddress,
//                                 style: pw.TextStyle(fontSize: 10),
//                               ),
//                             pw.SizedBox(height: 3),
//                             pw.Text(
//                               'Phone: $phoneNumber',
//                               style: pw.TextStyle(fontSize: 9),
//                             ),
//                             if (customerEmail.isNotEmpty)
//                               pw.Text(
//                                 'Email: $customerEmail',
//                                 style: pw.TextStyle(fontSize: 9),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 pw.SizedBox(height: 25),
//
//                 // Items Table with Modern Design
//                 pw.Container(
//                   decoration: pw.BoxDecoration(
//                     borderRadius: pw.BorderRadius.circular(8),
//                     border: pw.Border.all(color: PdfColors.grey300, width: 1),
//                   ),
//                   child: pw.Table(
//                     border: pw.TableBorder(
//                       horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
//                       verticalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
//                       left: pw.BorderSide.none,
//                       right: pw.BorderSide.none,
//                       top: pw.BorderSide.none,
//                       bottom: pw.BorderSide.none,
//                     ),
//                     columnWidths: {
//                       0: pw.FlexColumnWidth(0.4),
//                       1: pw.FlexColumnWidth(2.5),
//                       2: pw.FlexColumnWidth(0.6),
//                       3: pw.FlexColumnWidth(1),
//                       4: pw.FlexColumnWidth(1),
//                     },
//                     children: [
//                       // Table Header
//                       pw.TableRow(
//                         decoration: pw.BoxDecoration(
//                           color: PdfColors.blue50,
//                           borderRadius: pw.BorderRadius.only(
//                             topLeft: pw.Radius.circular(8),
//                             topRight: pw.Radius.circular(8),
//                           ),
//                         ),
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.all(12),
//                             child: pw.Text(
//                               '#',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 11,
//                               ),
//                               textAlign: pw.TextAlign.center,
//                             ),
//                           ),
//                           pw.Padding(
//                             padding: pw.EdgeInsets.all(12),
//                             child: pw.Text(
//                               'DESCRIPTION',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                           pw.Padding(
//                             padding: pw.EdgeInsets.all(12),
//                             child: pw.Text(
//                               'QTY',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 11,
//                               ),
//                               textAlign: pw.TextAlign.center,
//                             ),
//                           ),
//                           pw.Padding(
//                             padding: pw.EdgeInsets.all(12),
//                             child: pw.Text(
//                               'RATE',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 11,
//                               ),
//                               textAlign: pw.TextAlign.right,
//                             ),
//                           ),
//                           pw.Padding(
//                             padding: pw.EdgeInsets.all(12),
//                             child: pw.Text(
//                               'AMOUNT',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 11,
//                               ),
//                               textAlign: pw.TextAlign.right,
//                             ),
//                           ),
//                         ],
//                       ),
//                       // Table Rows
//                       ...invoices.asMap().entries.map((entry) {
//                         int index = entry.key;
//                         Invoice item = entry.value;
//                         final isEven = index % 2 == 0;
//                         return pw.TableRow(
//                           decoration: pw.BoxDecoration(
//                             color: isEven ? PdfColors.white : PdfColors.grey50,
//                           ),
//                           children: [
//                             pw.Padding(
//                               padding: pw.EdgeInsets.all(10),
//                               child: pw.Text(
//                                 '${index + 1}',
//                                 style: pw.TextStyle(fontSize: 10),
//                                 textAlign: pw.TextAlign.center,
//                               ),
//                             ),
//                             pw.Padding(
//                               padding: pw.EdgeInsets.all(10),
//                               child: pw.Text(
//                                 item.itemName,
//                                 style: pw.TextStyle(fontSize: 10),
//                               ),
//                             ),
//                             pw.Padding(
//                               padding: pw.EdgeInsets.all(10),
//                               child: pw.Text(
//                                 '${item.qty}',
//                                 style: pw.TextStyle(fontSize: 10),
//                                 textAlign: pw.TextAlign.center,
//                               ),
//                             ),
//                             pw.Padding(
//                               padding: pw.EdgeInsets.all(10),
//                               child: pw.Text(
//                                 '₹${item.price.toStringAsFixed(2)}',
//                                 style: pw.TextStyle(fontSize: 10),
//                                 textAlign: pw.TextAlign.right,
//                               ),
//                             ),
//                             pw.Padding(
//                               padding: pw.EdgeInsets.all(10),
//                               child: pw.Text(
//                                 '₹${(item.price * item.qty).toStringAsFixed(2)}',
//                                 style: pw.TextStyle(fontSize: 10),
//                                 textAlign: pw.TextAlign.right,
//                               ),
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//
//                 pw.SizedBox(height: 20),
//
//                 // Totals Section
//                 pw.Row(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     // Notes Section
//                     pw.Expanded(
//                       flex: 2,
//                       child: pw.Container(
//                         padding: pw.EdgeInsets.all(15),
//                         decoration: pw.BoxDecoration(
//                           color: PdfColors.grey50,
//                           borderRadius: pw.BorderRadius.circular(8),
//                           border: pw.Border.all(color: PdfColors.grey300, width: 1),
//                         ),
//                         child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text(
//                               'NOTES',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 11,
//                               ),
//                             ),
//                             pw.SizedBox(height: 8),
//                             pw.Text(
//                               notes.isNotEmpty ? notes : 'Thank you for your business!',
//                               style: pw.TextStyle(fontSize: 10),
//                             ),
//                             pw.SizedBox(height: 15),
//                             pw.Text(
//                               'BANK DETAILS',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.blue800,
//                                 fontSize: 11,
//                               ),
//                             ),
//                             pw.SizedBox(height: 5),
//                             pw.Text('Bank: $companyBank', style: pw.TextStyle(fontSize: 9)),
//                             pw.Text('A/C: $companyAccount', style: pw.TextStyle(fontSize: 9)),
//                             pw.Text('IFSC: $companyIfsc', style: pw.TextStyle(fontSize: 9)),
//                             pw.Text('PAN: $companyPan', style: pw.TextStyle(fontSize: 9)),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     pw.SizedBox(width: 20),
//
//                     // Totals
//                     pw.Expanded(
//                       flex: 1,
//                       child: pw.Container(
//                         padding: pw.EdgeInsets.all(15),
//                         decoration: pw.BoxDecoration(
//                           color: PdfColors.blue50,
//                           borderRadius: pw.BorderRadius.circular(8),
//                           border: pw.Border.all(color: PdfColors.blue200, width: 1),
//                         ),
//                         child: pw.Column(
//                           children: [
//                             _buildTotalRow('Subtotal', subtotal),
//                             if (taxAmount > 0)
//                               _buildTotalRow('Tax (${taxRate.toStringAsFixed(1)}%)', taxAmount),
//                             if (discountAmount > 0)
//                               _buildTotalRow('Discount', -discountAmount, isDiscount: true),
//                             pw.Divider(color: PdfColors.blue300, height: 20),
//                             _buildTotalRow(
//                               'TOTAL AMOUNT',
//                               totalAmount,
//                               isTotal: true,
//                               isBold: true,
//                             ),
//                             pw.SizedBox(height: 15),
//                             pw.Container(
//                               padding: pw.EdgeInsets.all(8),
//                               decoration: pw.BoxDecoration(
//                                 color: PdfColors.blue100,
//                                 borderRadius: pw.BorderRadius.circular(4),
//                               ),
//                               child: pw.Text(
//                                 'Amount in Words:\n${_numberToWords(totalAmount)}',
//                                 style: pw.TextStyle(
//                                   fontSize: 8,
//                                   color: PdfColors.blue800,
//                                 ),
//                                 textAlign: pw.TextAlign.center,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 pw.SizedBox(height: 25),
//
//                 // Footer with Signatures
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                   children: [
//                     pw.Column(
//                       children: [
//                         pw.Container(
//                           width: 150,
//                           height: 1,
//                           color: PdfColors.grey400,
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Text(
//                           'Customer Signature',
//                           style: pw.TextStyle(
//                             fontSize: 9,
//                             color: PdfColors.grey600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.Column(
//                       children: [
//                         pw.Container(
//                           width: 150,
//                           height: 1,
//                           color: PdfColors.grey400,
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Text(
//                           'Authorized Signature',
//                           style: pw.TextStyle(
//                             fontSize: 9,
//                             color: PdfColors.grey600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//
//                 pw.SizedBox(height: 20),
//                 pw.Center(
//                   child: pw.Text(
//                     'Thank you for your business! • This is a computer generated invoice',
//                     style: pw.TextStyle(
//                       fontSize: 8,
//                       color: PdfColors.grey500,
//                       fontStyle: pw.FontStyle.italic,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//
//       // Save and open PDF
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/Invoice_${invoiceId}_${userName}.pdf';
//       final file = File(filePath);
//       await file.writeAsBytes(await pdf.save());
//
//       print("✅ Beautiful PDF saved: $filePath");
//       await OpenFile.open(filePath);
//
//     } catch (e) {
//       print("Error generating beautiful PDF: $e");
//     }
//   }
//
//   static pw.Widget _buildTotalRow(String label, double amount, {bool isTotal = false, bool isBold = false, bool isDiscount = false}) {
//     return pw.Padding(
//       padding: pw.EdgeInsets.symmetric(vertical: 4),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(
//             label,
//             style: pw.TextStyle(
//               fontSize: isTotal ? 12 : 10,
//               fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//               color: isTotal ? PdfColors.blue900 : PdfColors.grey700,
//             ),
//           ),
//           pw.Text(
//             '${isDiscount ? '-' : ''}₹${amount.toStringAsFixed(2)}',
//             style: pw.TextStyle(
//               fontSize: isTotal ? 12 : 10,
//               fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//               color: isTotal ? PdfColors.blue900 : (isDiscount ? PdfColors.red : PdfColors.grey700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static String _numberToWords(double number) {
//     // Simple number to words conversion (you can enhance this)
//     final wholePart = number.toInt();
//     final decimalPart = ((number - wholePart) * 100).round();
//
//     if (wholePart == 0) return 'Zero Rupees';
//
//     String words = _convertNumber(wholePart) + ' Rupees';
//     if (decimalPart > 0) {
//       words += ' and ${_convertNumber(decimalPart)} Paise';
//     }
//     return words + ' Only';
//   }
//
//   static String _convertNumber(int number) {
//     // Simple number conversion logic (you can use a proper package for this)
//     if (number < 20) {
//       final units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
//         'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
//       return units[number];
//     }
//     if (number < 100) {
//       final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
//       return '${tens[number ~/ 10]} ${_convertNumber(number % 10)}';
//     }
//     if (number < 1000) {
//       return '${_convertNumber(number ~/ 100)} Hundred ${_convertNumber(number % 100)}';
//     }
//     if (number < 100000) {
//       return '${_convertNumber(number ~/ 1000)} Thousand ${_convertNumber(number % 1000)}';
//     }
//     if (number < 10000000) {
//       return '${_convertNumber(number ~/ 100000)} Lakh ${_convertNumber(number % 100000)}';
//     }
//     return '${_convertNumber(number ~/ 10000000)} Crore ${_convertNumber(number % 10000000)}';
//   }
// }