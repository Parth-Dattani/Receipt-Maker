import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../model/receipt_model.dart';
import '../../services/google_sheets_service.dart';
import '../utils/shared_preferences_helper.dart';
import '../constant/app_colors.dart';
import '../constant/app_constant.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;

  // 📊 ઓબ્ઝર્વેબલ સ્ટેટ્સ વેરીએબલ્સ
  var totalReceipts = 0.obs;
  var totalAmount = 0.0.obs;
  var monthAmount = 0.0.obs;
  var todayAmount = 0.0.obs;
  var recentReceipts = <ReceiptModel>[].obs;
  var allReceiptsList = <ReceiptModel>[].obs;

  // 📅 Report Date Range variables
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();
  var selectedReportType = 'Detailed Report'.obs;

  // 👤 કરંટ યુઝર ઈમેલ ગેટર
  String get userEmail => FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    initAndLoadStats(); // 🚀 રીસ્ટાર્ટ વખતે ઓટો-કનેક્ટ અને સ્ટેટ્સ લોડ કરશે
  }

  /// 🔄 એપ રીસ્ટાર્ટ થાય ત્યારે ગૂગલ ડ્રાઈવ સાઇલન્ટ કનેક્ટ કરીને ડેટા લાવવાનું ફંક્શન
  Future<void> initAndLoadStats() async {
    try {
      isLoading.value = true;

      // SharedPreferences માંથી બધું લોડ કરો
      await sharedPreferencesHelper.getSharedPreferencesInstance();
      await AppConstants.loadFromPrefs();

      String currentYear = AppConstants.activeFy;

      if (!GoogleSheetsService.isSignedIn && userEmail.isNotEmpty) {
        bool isConnected = await GoogleSheetsService.signInSilentlyWithEmail(userEmail);
        if (isConnected) {
          String uId = FirebaseAuth.instance.currentUser?.uid ?? 'default_user';

          // Google Sheets માં એક્ટિવ શીટ સેટ કરો
          GoogleSheetsService.setActiveSheet("Receipts_$currentYear");

          await GoogleSheetsService.setupUserDriveAndSheet(uId, currentYear);
        }
      }
      
      // Ensure active sheet is correct even if already signed in
      GoogleSheetsService.setActiveSheet("Receipts_$currentYear");

      await loadStats();
    } catch (e) {
      debugPrint('[DashboardController] Initialization Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 📊 ગૂગલ શીટમાંથી લાઈવ ડેટા ખેંચીને ગણતરી કરવાનું મુખ્ય ફંક્શન
  Future<void> loadStats() async {
    try {
      isLoading.value = true;

      final allReceipts = await GoogleSheetsService.fetchAllReceipts();
      allReceiptsList.value = allReceipts;

      if (allReceipts.isNotEmpty) {
        totalReceipts.value = allReceipts.length;

        final now = DateTime.now();
        final String todayStr = DateFormat('dd/MM/yyyy').format(now);
        final String currentMonthStr = DateFormat('MM/yyyy').format(now);

        double calcTotalAmount = 0.0;
        double calcMonthAmount = 0.0;
        double calcTodayAmount = 0.0;

        for (var receipt in allReceipts) {
          final amt = receipt.amount;
          calcTotalAmount += amt;

          if (receipt.date == todayStr) {
            calcTodayAmount += amt;
          }

          if (receipt.date.endsWith(currentMonthStr)) {
            calcMonthAmount += amt;
          }
        }

        totalAmount.value = calcTotalAmount;
        todayAmount.value = calcTodayAmount;
        monthAmount.value = calcMonthAmount;

        final reversedList = allReceipts.reversed.toList();
        recentReceipts.value = reversedList.take(5).toList();
      } else {
        _resetStats();
      }
    } catch (e) {
      debugPrint('[DashboardController] Error calculation stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _resetStats() {
    totalReceipts.value = 0;
    totalAmount.value = 0.0;
    monthAmount.value = 0.0;
    todayAmount.value = 0.0;
    recentReceipts.clear();
    allReceiptsList.clear();
  }

  void refreshDashboard() => initAndLoadStats();

  // DashboardController.dart માં ઉમેરો
  void updateDashboardAfterSettings() {
    // સેટિંગ્સ બદલાયા પછી, જૂનો ડેટા સાફ કરીને નવું લોડ કરો
    _resetStats();
    initAndLoadStats();
  }

  // 📅 Report Logic
  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = picked;
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? DateTime.now(),
      firstDate: fromDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      toDate.value = picked;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Select date";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  int get selectedDaysCount {
    if (fromDate.value == null || toDate.value == null) return 0;
    return toDate.value!.difference(fromDate.value!).inDays + 1;
  }

  Future<void> exportToPdf() async {
    if (fromDate.value == null || toDate.value == null) {
      Get.snackbar("Error", "Please select date range first", 
        backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
      return;
    }

    try {
      isLoading.value = true;
      final pdf = pw.Document();

      // Load Logo
      pw.MemoryImage? logo;
      try {
        final data = await rootBundle.load('assets/images/app_logo_2.png');
        logo = pw.MemoryImage(data.buffer.asUint8List());
      } catch (_) {}

      // Filter Data
      List<ReceiptModel> filteredList = allReceiptsList.where((r) {
        DateTime receiptDate = DateFormat('dd/MM/yyyy').parse(r.date);
        return receiptDate.isAfter(fromDate.value!.subtract(const Duration(days: 1))) && 
               receiptDate.isBefore(toDate.value!.add(const Duration(days: 1)));
      }).toList();

      if (filteredList.isEmpty) {
        Get.snackbar("Info", "No data found for selected range",
          backgroundColor: Colors.orange.shade100, colorText: Colors.orange.shade900);
        isLoading.value = false;
        return;
      }

      double totalRangeAmount = filteredList.fold(0.0, (sum, item) => sum + item.amount);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(30),
          header: (context) => pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logo != null) pw.Image(logo, width: 48, height: 48),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(AppStrings.trustName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(
                          selectedReportType.value == 'Full Report' 
                              ? "Collection Report (Detailed)" 
                              : "Collection Report (Category-wise)", 
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
                      pw.Text("Period: ${formatDate(fromDate.value)} to ${formatDate(toDate.value)}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ]
                  ),
                  if (logo != null) pw.Image(logo, width: 48, height: 48),
                ]
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),
            ]
          ),
          footer: (context) => pw.Column(
            children: [
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Application By: iNTELLIGENT tECH", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  pw.Text("252, NEO Square, Jamnagar | Mo: 7383915985", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                ],
              ),
            ]
          ),
          build: (context) {
            if (selectedReportType.value == 'Full Report') {
              return [
                _buildReportTable(context, filteredList),
                pw.SizedBox(height: 15),
                _buildSummary(filteredList.length, totalRangeAmount),
              ];
            } else {
              // Group by category (Normalized to handle case-insensitivity)
              Map<String, List<ReceiptModel>> groupedData = {};
              for (var r in filteredList) {
                // Normalize key: Trim and uppercase to group 'general' and 'General' together
                String normalizedCategory = r.donationType.trim().toUpperCase();
                groupedData.putIfAbsent(normalizedCategory, () => []).add(r);
              }

              List<pw.Widget> content = [];
              groupedData.forEach((category, items) {
                double categoryTotal = items.fold(0.0, (sum, item) => sum + item.amount);
                
                // Use pw.Header to ensure category name stays with its table
                content.add(
                  pw.Header(
                    level: 1,
                    decoration: const pw.BoxDecoration(), // No bottom line
                    padding: const pw.EdgeInsets.only(top: 15, bottom: 8),
                    child: pw.Text(
                      category,
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                    ),
                  )
                );
                
                content.add(_buildReportTable(context, items));
                
                content.add(
                  pw.Container(
                    alignment: pw.Alignment.centerRight,
                    padding: const pw.EdgeInsets.only(top: 4, bottom: 15),
                    child: pw.Text(
                      "Category Total: Rs. ${NumberFormat('#,##,###.##').format(categoryTotal)}",
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  )
                );
              });

              content.add(pw.SizedBox(height: 10));
              content.add(pw.Divider(thickness: 1, color: PdfColors.blue900));
              content.add(_buildSummary(filteredList.length, totalRangeAmount));
              return content;
            }
          },
        ),
      );

      // Save and Share
      final directory = await getApplicationDocumentsDirectory();
      String typeSuffix = selectedReportType.value == 'Detailed Report' ? "Detailed" : "Category";
      String fileName = "Receipts_${typeSuffix}_Report_${DateFormat('ddMMyyyy').format(fromDate.value!)}_to_${DateFormat('ddMMyyyy').format(toDate.value!)}.pdf";
      String filePath = "${directory.path}/$fileName";
      
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      isLoading.value = false;
      
      // Open Share Sheet
      await Share.shareXFiles([XFile(filePath)], text: "Receipts Report from ${formatDate(fromDate.value)} to ${formatDate(toDate.value)}");

    } catch (e) {
      debugPrint("Export Error: $e");
      Get.snackbar("Export Failed", e.toString(),
        backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
    } finally {
      isLoading.value = false;
    }
  }

  pw.Widget _buildReportTable(pw.Context context, List<ReceiptModel> data) {
    return pw.TableHelper.fromTextArray(
      context: context,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
      cellStyle: const pw.TextStyle(fontSize: 8),
      columnWidths: {
        0: const pw.FixedColumnWidth(40),  // No
        1: const pw.FixedColumnWidth(60),  // Date
        2: const pw.FlexColumnWidth(3),    // Donor Name
        3: const pw.FixedColumnWidth(70),  // PAN
        4: const pw.FixedColumnWidth(70),  // Mobile
        5: const pw.FixedColumnWidth(60),  // Amount
        6: const pw.FixedColumnWidth(60),  // Payment
        7: const pw.FlexColumnWidth(2),    // Donation Type
      },
      headers: ['No', 'Date', 'Donor Name', 'PAN', 'Mobile', 'Amount', 'Payment', 'Category'],
      data: data.map((r) => [
        r.recNo.toString(),
        r.date,
        r.donorName,
        r.panNo,
        r.mobileNo,
        NumberFormat('#,##,###.##').format(r.amount),
        r.paymentType,
        r.donationType,
      ]).toList(),
    );
  }

  pw.Widget _buildSummary(int count, double total) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text("Grand Summary", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 5),
          pw.Text("Total Receipts: $count", style: const pw.TextStyle(fontSize: 9)),
          pw.Text("Total Collection: Rs. ${NumberFormat('#,##,###.##').format(total)}", 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blue900)),
        ],
      ),
    );
  }

  void showExportDialog(BuildContext context) {
    fromDate.value = null;
    toDate.value = null;
    selectedReportType.value = 'Full Report';
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                decoration: BoxDecoration(
                  color: AppColors.appTheame,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assessment_rounded, color: Colors.white, size: 24),
                        const SizedBox(width: 14),
                        const Text("Business Reports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Report Type", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 14),
                    
                    // Report Type Selection
                    _buildReportTypeTile(
                      title: "Full Report",
                      subtitle: "Complete chronological list of receipts",
                      icon: Icons.receipt_long_rounded,
                      type: 'Full Report',
                    ),
                    const SizedBox(height: 12),
                    _buildReportTypeTile(
                      title: "Donation Type Wise",
                      subtitle: "Grouped by category (Education, etc.)",
                      icon: Icons.category_rounded,
                      type: 'Donation Type Wise',
                    ),

                    const SizedBox(height: 28),
                    const Text("Select Duration", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 14),

                    // From Date Picker
                    _buildDateTile(
                      context: context,
                      label: "From Date",
                      onTap: () => selectFromDate(context),
                      icon: Icons.calendar_today_rounded,
                      dateObs: fromDate,
                    ),
                    
                    const SizedBox(height: 12),
                    _buildDateTile(
                      context: context,
                      label: "To Date",
                      onTap: () => selectToDate(context),
                      icon: Icons.event_rounded,
                      dateObs: toDate,
                    ),

                    const SizedBox(height: 28),
                    
                    // Export Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (fromDate.value == null || toDate.value == null) {
                            Get.snackbar("Range Required", "Please select both dates", 
                                snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade50);
                            return;
                          }
                          Get.back();
                          exportToPdf();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appTheame,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          shadowColor: AppColors.appTheame.withOpacity(0.3),
                        ),
                        child: const Text("Generate Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeTile({required String title, required String subtitle, required IconData icon, required String type}) {
    return Obx(() {
      bool isSelected = selectedReportType.value == type;
      return InkWell(
        onTap: () => selectedReportType.value = type,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.appTheame.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.appTheame : Colors.grey.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.appTheame : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? AppColors.appTheame : Colors.black87)),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: isSelected ? AppColors.appTheame.withOpacity(0.7) : Colors.grey)),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: AppColors.appTheame, size: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDateTile({required BuildContext context, required String label, required VoidCallback onTap, required IconData icon, required Rxn<DateTime> dateObs}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
              child: Icon(icon, color: AppColors.appTheame, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Obx(() => Text(
                  formatDate(dateObs.value),
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.bold, 
                    color: dateObs.value != null ? Colors.black87 : Colors.grey.shade400
                  ),
                )),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14),
          ],
        ),
      ),
    );
  }
}
