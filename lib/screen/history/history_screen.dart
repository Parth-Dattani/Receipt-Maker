import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constant/constant.dart';
import '../../controller/receipt_controller.dart';
import '../../model/receipt_model.dart';
import '../../utils/receipt_pdf_helper.dart';
import '../screen.dart';

class HistoryScreen extends GetView<ReceiptController> {
  static const pageId = "/history";
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor2,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        title: const Text('Receipt History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _searchAndSortPanel(),
          Expanded(
            child: Obx(() {
              final list = controller.filteredReceiptList;

              // 🚀 સ્કેલેટન ઇફેક્ટ: જો લોડિંગ હોય તો ૬ ડમી કાર્ડ્સ બતાવો
              return Skeletonizer(
                enabled: controller.isLoading.value,
                child: list.isEmpty && !controller.isLoading.value
                    ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No matching receipts found', style: TextStyle(color: Colors.grey, fontSize: 15)),
                ]))
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: controller.isLoading.value ? 6 : list.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final item = controller.isLoading.value
                        ? ReceiptModel.dummy()
                        : list[i];
                    return _receiptCard(item);}

                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 🔍 🚀 સુધારેલી રિસ્પોન્સિવ સર્ચબાર અને સોર્ટિંગ પેનલ
  Widget _searchAndSortPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.appTheame,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // 🔎 સર્ચ ઇનપુટ બોક્સ (બાકીની ઓટોમેટિક બધી સ્પેસ આ કવર કરી લેશે)
          Expanded(
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search by Name, No, Mobile...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.appTheame),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                  onPressed: () {
                    controller.searchQuery.value = '';
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 📊 🚀 અલ્ટીમેટ રિસ્પોન્સિવ ફિક્સ: Dropdown ની જગ્યાએ PopupMenuButton
          // આનાથી વિજેટ માત્ર ઓન્લી એક આઇકન જેટલી જ જગ્યા રોકશે, ઓવરફ્લો થવાનો ચાન્સ જ નથી!
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Theme(
              data: Theme.of(Get.context!).copyWith(
                cardColor: Colors.white, // પોપઅપ મેનૂનું બેકગ્રાઉન્ડ
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                tooltip: 'Sort Receipts',
                onSelected: (String newValue) {
                  controller.selectedSortType.value = newValue;
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                itemBuilder: (BuildContext context) {
                  return ['Latest', 'Oldest', 'Name (A-Z)'].map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Obx(() {
                        // જે સિલેક્ટેડ હોય એનો કલર હાઇલાઇટ થશે
                        final isSelected = controller.selectedSortType.value == value;
                        return Row(
                          children: [
                            Icon(
                              value == 'Name (A-Z)'
                                  ? Icons.sort_by_alpha_rounded
                                  : Icons.calendar_month_rounded,
                              size: 18,
                              color: isSelected ? AppColors.appTheame : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              value,
                              style: TextStyle(
                                color: isSelected ? AppColors.appTheame : Colors.black87,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 ક્લીન રસીદカード વ્યુ
  Widget _receiptCard(ReceiptModel r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // થોડો આછો શેડો
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      // 🚀 અહીંથી બોર્ડર એકદમ રીમુવ કરવા માટે Theme સેટિંગ્સ
      child: Theme(
        data: Theme.of(Get.context!).copyWith(
          dividerColor: Colors.transparent, // આ લાઈન બોર્ડર દૂર કરશે
          splashColor: Colors.transparent,  // ક્લિક પર બોર્ડર ન દેખાય
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          shape: const Border(), // 👈 આ ખાસ પ્રોપર્ટી બોર્ડરને સાવ કાઢી નાખશે
          collapsedShape: const Border(), // 👈 બંધ હોય ત્યારે પણ બોર્ડર નહીં દેખાય
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
                color: AppColors.appTheame.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Center(child: Text('#${r.recNo}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.appTheame))),
          ),
          title: Text(r.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
          subtitle: Text(r.date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${NumberFormat('#,##,###').format(r.amount.toInt())}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.appTheame, fontSize: 15)),
              const SizedBox(height: 2),
              Text(r.paymentType, style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(Icons.edit_note_rounded, 'Modify', Colors.blue.shade700, () {
                    controller.setupForEdit(r);
                    Get.toNamed(NewReceiptScreen.pageId);
                  }),
                  _actionButton(Icons.local_printshop_rounded, 'Print', Colors.blueGrey.shade700, () async {
                    // 🖨️ FIXED: 2 copies with Print parameter
                    final file = await ReceiptPdfHelper.generate(r, isPrint: true);
                    controller.printReceipt(file.path, receipt: r);
                  }),
                  _actionButton(Icons.share_rounded, 'Share', const Color(0xFF25D366), () async {
                    // 📄 FIXED: 1 copy for sharing
                    final file = await ReceiptPdfHelper.generate(r, isPrint: false);
                    controller.shareWhatsApp(file.path, receiptNo: r.recNo.toString(), mobileNo: r.mobileNo);
                  }),
                  _actionButton(Icons.delete_outline_rounded, 'Delete', Colors.red.shade700, () {
                    controller.deleteReceipt(r);
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))]),
    );
  }
}