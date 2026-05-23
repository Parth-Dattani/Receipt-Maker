import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // જો તમારા પેકેજનું નામ અલગ હોય તો ચેક કરી લેવું
import '../../constant/constant.dart';
import '../../controller/receipt_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../../model/receipt_model.dart';
import '../screen.dart';

class ReceiptPreviewScreen extends GetView<ReceiptController> {
  static const pageId = "/receipt-preview";
  const ReceiptPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final receipt = args['receipt'] as ReceiptModel;
    final pdfPath = args['pdfPath'] as String;

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        title: Text('Receipt #${receipt.recNo} Preview',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => controller.printReceipt(pdfPath, receipt: receipt),
            tooltip: 'Print Receipt (2 Copies)',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 📄 1. PDF Viewer Section
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 650),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: PDFView(
                    filePath: pdfPath,
                    enableSwipe: true,
                    fitEachPage: true,
                    fitPolicy: FitPolicy.BOTH,
                  ),
                ),
              ),
            ),

            // ⚡ 2. Actions Bottom Panel
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔄 લાઈવ અપડેટ લોડર
                      Obx(() => controller.isLoading.value
                          ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.appTheame),
                            ),
                            const SizedBox(width: 8),
                            const Text('Syncing data with sheet...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                          : const SizedBox.shrink()),

                      // 📱 Responsive Buttons Row / Column
                      screenWidth > 500
                          ? Row(
                        children: [
                          Expanded(child: _buildWhatsAppButton(pdfPath, receipt.recNo.toString(), receipt.mobileNo)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCloseOrNewButton()),
                        ],
                      )
                          : Column(
                        children: [
                          SizedBox(width: double.infinity, child: _buildWhatsAppButton(pdfPath, receipt.recNo.toString(), receipt.mobileNo)),
                          const SizedBox(height: 12),
                          SizedBox(width: double.infinity, child: _buildCloseOrNewButton()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 WhatsApp Button Builder
  Widget _buildWhatsAppButton(String pdfPath, String recNo, String mobileNo) {
    return ElevatedButton.icon(
      onPressed: () => controller.shareWhatsApp(pdfPath, receiptNo: recNo, mobileNo: mobileNo),
      icon: const Icon(Icons.share, size: 18),
      label: const Text('Share on WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.whatsappColor, // WhatsApp Green
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 50),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 🔵 Dynamic New Receipt / Back to History Button Builder
  Widget _buildCloseOrNewButton() {
    return Obx(() {
      final isEdit = controller.isEditMode.value;

      return ElevatedButton.icon(
        onPressed: () {
          controller.resetForm(); // ફોર્મ પ્યોર ક્લીન અને રીસેટ થશે

          if (isEdit) {
            // 🔄 જો એડિટ કરીને આવ્યા હોય, તો સીધા હિસ્ટ્રી લોગ પર પાછા મોકલો
            Get.offAllNamed(HistoryScreen.pageId);
          } else {
            // 📥 જો નવી રસીદ બનાવી હોય, તો ડેશબોર્ડ ઓપન કરો
            Get.offAllNamed(DashboardScreen.pageId);
          }
        },
        // 🌟 એડિટ મોડ પ્રમાણે ડાયનેમિક આઇકન અને લખાણ સેટ કર્યું
        icon: Icon(isEdit ? Icons.check_circle_rounded : Icons.add, size: 18),
        label: Text(
            isEdit ? 'Back to History' : 'Create New Receipt',
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appTheame,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }
}