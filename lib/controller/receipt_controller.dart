import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';

import '../constant/app_colors.dart';
import '../constant/constant.dart';
import '../model/receipt_model.dart';
import '../services/google_sheets_service.dart';
import '../controller/dashboard_controller.dart';
import '../screen/receipt/new_receipt_screen.dart';
import '../services/service.dart';
import '../utils/amount_to_words.dart';
import '../utils/receipt_pdf_helper.dart';
import '../utils/shared_preferences_helper.dart';
import '../utils/utils.dart';

class ReceiptController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Input Controllers
  final recNoCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final donorNameCtrl = TextEditingController();
  final panNoCtrl = TextEditingController();
  final mobileNoCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final chequeNoCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  var currentRecNo = 0.obs;
  var isLoading = false.obs;
  var selectedPaymentType = 'Cash'.obs;
  var selectedDonationType = 'General'.obs;

  // Edit Mode Management Variables
  var isEditMode = false.obs;
  String? editingReceiptId;
  DateTime? originalCreatedAt;

  // History List Observable
  var receiptList = <ReceiptModel>[].obs;
  var donationTypes = <String>['General'].obs;

  // 🔍 📊 સર્ચ ક્વેરી અને સોર્ટિંગ ટાઇપ માટેના લાઈવ ઓબ્ઝર્વેબલ્સ
  var searchQuery = ''.obs;
  var selectedSortType = 'Latest'.obs;

  final paymentTypes = ['Bank Transfer', 'Cheque', 'UPI'];

  @override
  void onInit() {
    super.onInit();
    selectedPaymentType.value = 'UPI';
    _setToday();
    refreshData();
    loadDonationTypes();
  }

  void _setToday() {
    dateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> loadDonationTypes() async {
    final types = await FirebaseService.getDonationTypes();
    if (types.isNotEmpty) {
      donationTypes.value = types.toSet().toList();
      if (!donationTypes.contains(selectedDonationType.value)) {
        selectedDonationType.value = donationTypes.first;
      }
    }
  }

  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      final list = await GoogleSheetsService.fetchAllReceipts();
      receiptList.value = list;
    } catch (e) {
      debugPrint('[ReceiptController] Refresh Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<ReceiptModel> get filteredReceiptList {
    List<ReceiptModel> tempList = receiptList.where((receipt) {
      final nameMatch = receipt.donorName.toLowerCase().contains(searchQuery.value.toLowerCase());
      final noMatch = receipt.recNo.toString().contains(searchQuery.value);
      final phoneMatch = receipt.mobileNo.contains(searchQuery.value);
      return nameMatch || noMatch || phoneMatch;
    }).toList();

    if (selectedSortType.value == 'Latest') {
      tempList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (selectedSortType.value == 'Oldest') {
      tempList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (selectedSortType.value == 'Name (A-Z)') {
      tempList.sort((a, b) => a.donorName.toLowerCase().compareTo(b.donorName.toLowerCase()));
    }
    return tempList;
  }

  void setupForEdit(ReceiptModel receipt) {
    isEditMode.value = true;
    editingReceiptId = receipt.id;
    originalCreatedAt = receipt.createdAt;
    recNoCtrl.text = receipt.recNo.toString();
    dateCtrl.text = receipt.date;
    donorNameCtrl.text = receipt.donorName;
    panNoCtrl.text = (receipt.panNo == 'N/A' || receipt.panNo.isEmpty) ? '' : receipt.panNo;
    mobileNoCtrl.text = receipt.mobileNo;
    amountCtrl.text = receipt.amount.toString();
    selectedPaymentType.value = receipt.paymentType;
    selectedDonationType.value = receipt.donationType;
    bankNameCtrl.text = receipt.bankName == 'N/A' ? '' : receipt.bankName;
    chequeNoCtrl.text = receipt.chequeNo == 'N/A' ? '' : receipt.chequeNo;
    remarksCtrl.text = receipt.remarks == 'N/A' ? '' : receipt.remarks;
  }

  Future<void> setupForNewReceipt() async {
    int lastSavedNo = await FirebaseService.getLastReceiptNumber();
    await sharedPreferencesHelper.getSharedPreferencesInstance();
    String startRecStr = await sharedPreferencesHelper.getPrefData("start_rec_no") ?? "1";
    int startNo = int.tryParse(startRecStr) ?? 1;
    int nextNo = (lastSavedNo >= startNo) ? lastSavedNo + 1 : startNo;
    currentRecNo.value = nextNo;
    recNoCtrl.text = nextNo.toString();
    loadDonationTypes();
  }

  Future<void> pickDate(BuildContext context) async {
    if (isEditMode.value) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
  }

  Future<void> generateReceipt() async {
    if (!formKey.currentState!.validate()) return;
    _showBlurLoadingOverlay();

    try {
      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
      final int finalRecNo = int.tryParse(recNoCtrl.text.trim()) ?? currentRecNo.value;

      ReceiptModel initialReceipt = ReceiptModel(
        id: editingReceiptId,
        recNo: finalRecNo,
        date: dateCtrl.text.trim(),
        donorName: donorNameCtrl.text.trim(),
        panNo: panNoCtrl.text.trim().isEmpty ? 'N/A' : panNoCtrl.text.trim().toUpperCase(),
        mobileNo: mobileNoCtrl.text.trim(),
        amount: amount,
        amountInWords: AmountToWords.convert(amount),
        paymentType: selectedPaymentType.value,
        bankName: bankNameCtrl.text.trim().isEmpty ? 'N/A' : bankNameCtrl.text.trim(),
        chequeNo: chequeNoCtrl.text.trim().isEmpty ? 'N/A' : chequeNoCtrl.text.trim(),
        remarks: remarksCtrl.text.trim().isEmpty ? 'N/A' : remarksCtrl.text.trim(),
        donationType: selectedDonationType.value,
        createdAt: isEditMode.value ? (originalCreatedAt ?? DateTime.now()) : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Generate PDF Bytes (Platform Agnostic)
      final Uint8List pdfBytes = await ReceiptPdfHelper.generateBytes(initialReceipt, isPrint: false);
      final String fileName = "receipt_$finalRecNo.pdf";

      // ☁️ Upload PDF to Google Drive using bytes
      await GoogleSheetsService.uploadPdfToDrive(pdfBytes, fileName);

      bool isSuccess = await (isEditMode.value
          ? GoogleSheetsService.updateReceipt(initialReceipt)
          : GoogleSheetsService.insertReceipt(initialReceipt));

      if (isSuccess) {
        if (!isEditMode.value) await FirebaseService.updateLastReceiptNumber(finalRecNo);
        await refreshData();
        if (Get.isRegistered<DashboardController>()) Get.find<DashboardController>().loadStats();

        if (Get.isDialogOpen == true) Get.back();
        Get.back();

        String pdfPath = "";
        if (!kIsWeb) {
          final dir = await getApplicationDocumentsDirectory();
          final receiptDir = Directory('${dir.path}/Receipts/PDF');
          if (!await receiptDir.exists()) await receiptDir.create(recursive: true);
          final file = io.File('${receiptDir.path}/$fileName');
          await file.writeAsBytes(pdfBytes);
          pdfPath = file.path;
        }

        _showSuccessDialog(initialReceipt, pdfPath, finalRecNo.toString(), pdfBytes: pdfBytes);
        resetForm();
      } else {
        if (Get.isDialogOpen == true) Get.back();
        _showSnackBar('Sync Error', 'Google Sheet connection failed.', true);
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      _showSnackBar('Error', 'Transaction failed: $e', true);
    }
  }

  void _showSuccessDialog(ReceiptModel receipt, String pdfPath, String receiptNo, {Uint8List? pdfBytes}) {
    Get.dialog(
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 12))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 56),
              ),
              const SizedBox(height: 20),
              const Text('Receipt Generated Successfully!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, decoration: TextDecoration.none)),
              const SizedBox(height: 6),
              Text('Select output format:', style: TextStyle(fontSize: 13, color: Colors.grey.shade500, decoration: TextDecoration.none)),
              const SizedBox(height: 24),
              _invoiceSathiButton(
                icon: Icons.local_printshop_rounded,
                label: 'Print Receipt (2 Copies)',
                color: AppColors.appTheame,
                isPrimary: true,
                onTap: () {
                  Get.back();
                  printReceipt(pdfPath, receipt: receipt, pdfBytes: pdfBytes);
                },
              ),
              const SizedBox(height: 12),
              _invoiceSathiButton(
                icon: Icons.share_rounded,
                label: 'WhatsApp',
                color: AppColors.whatsappColor,
                isPrimary: false,
                onTap: () {
                  Get.back();
                  shareWhatsApp(pdfPath, receiptNo: receiptNo, mobileNo: receipt.mobileNo, pdfBytes: pdfBytes);
                },
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: () => Get.back(), child: const Text('Skip & Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _invoiceSathiButton({required IconData icon, required String label, required Color color, required bool isPrimary, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isPrimary 
          ? ElevatedButton.icon(onPressed: onTap, icon: Icon(icon, size: 20), label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))
          : OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 20, color: color), label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)), style: OutlinedButton.styleFrom(side: BorderSide(color: color, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
    );
  }

  Future<void> shareWhatsApp(String pdfPath, {String? receiptNo, String? mobileNo, Uint8List? pdfBytes}) async {
    try {
      final String no = receiptNo ?? recNoCtrl.text;
      final String phone = mobileNo ?? mobileNoCtrl.text;
      final String message = 'Noor Education Trust - Jamnagar\nThank you for your valuable contribution.\nReceipt No: #$no';

      if (!kIsWeb && phone.isNotEmpty && phone.trim().length >= 10) {
        String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanPhone.length == 10) cleanPhone = '91$cleanPhone';
        final Uri whatsappUrl = Uri.parse("whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}");
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl);
          await Future.delayed(const Duration(milliseconds: 1800));
        }
      }

      if (kIsWeb && pdfBytes != null) {
        await Share.shareXFiles([XFile.fromData(pdfBytes, name: "receipt_$no.pdf", mimeType: 'application/pdf')], text: message);
      } else if (pdfPath.isNotEmpty) {
        await Share.shareXFiles([XFile(pdfPath)], text: message);
      }
    } catch (e) {
      debugPrint('WhatsApp Share Error: $e');
    }
  }

  Future<void> printReceipt(String pdfPath, {String? receiptNo, ReceiptModel? receipt, Uint8List? pdfBytes}) async {
    try {
      final String no = receiptNo ?? (receipt?.recNo.toString() ?? recNoCtrl.text);
      if (receipt != null) {
        final freshPdfBytes = await ReceiptPdfHelper.generateBytes(receipt, isPrint: true);
        await Printing.layoutPdf(onLayout: (_) async => freshPdfBytes, name: 'Receipt_#$no');
      } else if (pdfBytes != null) {
        await Printing.layoutPdf(onLayout: (_) async => pdfBytes, name: 'Receipt_#$no');
      } else if (!kIsWeb && pdfPath.isNotEmpty) {
        final file = io.File(pdfPath);
        if (await file.exists()) await Printing.layoutPdf(onLayout: (_) async => await file.readAsBytes(), name: 'Receipt_#$no');
      }
    } catch (e) {
      debugPrint('Print Error: $e');
    }
  }

  void _showBlurLoadingOverlay({String msg = "Please wait, generating PDF"}) {
    Get.dialog(PopScope(canPop: false, child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26), decoration: BoxDecoration(color: Colors.black.withOpacity(0.82), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(color: Colors.white, strokeWidth: 3), const SizedBox(height: 18), Text(msg, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.none))])))), barrierDismissible: false, barrierColor: Colors.black.withOpacity(0.25));
  }

  void deleteReceipt(ReceiptModel receipt) {
    Get.dialog(AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text('Delete Receipt?', style: TextStyle(fontWeight: FontWeight.bold)), content: Text('Are you sure you want to delete receipt #${receipt.recNo} for ${receipt.donorName}?'), actions: [TextButton(onPressed: () => Get.back(), child: const Text('Cancel')), TextButton(onPressed: () async { Get.back(); _showBlurLoadingOverlay(msg: "Deleting Receipt..."); try { bool success = await GoogleSheetsService.deleteReceipt(receipt.recNo); if (success) { await refreshData(); if (Get.isRegistered<DashboardController>()) Get.find<DashboardController>().loadStats(); _showSnackBar('Success', 'Receipt deleted successfully', false); } else { _showSnackBar('Error', 'Failed to delete', true); } } finally { if (Get.isDialogOpen == true) Get.back(); } }, child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))]));
  }

  void _showSnackBar(String title, String message, bool isError) {
    if (Get.context != null) ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: isError ? const Color(0xFFC62828) : const Color(0xFF2E7D32), fontWeight: FontWeight.bold)), backgroundColor: isError ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9), behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(12)));
  }

  void resetForm() {
    isEditMode.value = false; editingReceiptId = null; originalCreatedAt = null;
    donorNameCtrl.clear(); panNoCtrl.clear(); mobileNoCtrl.clear(); amountCtrl.clear();
    bankNameCtrl.clear(); chequeNoCtrl.clear(); remarksCtrl.clear();
    selectedPaymentType.value = 'UPI'; selectedDonationType.value = 'General';
    _setToday(); setupForNewReceipt();
  }

  @override
  void onClose() {
    recNoCtrl.dispose(); dateCtrl.dispose(); donorNameCtrl.dispose(); panNoCtrl.dispose(); mobileNoCtrl.dispose(); amountCtrl.dispose(); bankNameCtrl.dispose(); chequeNoCtrl.dispose(); remarksCtrl.dispose();
    super.onClose();
  }
}
