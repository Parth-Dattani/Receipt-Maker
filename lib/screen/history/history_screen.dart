import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constant/constant.dart';
import '../../controller/receipt_controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../model/receipt_model.dart';
import '../../utils/receipt_pdf_helper.dart';
import '../../widgets/web_app_sidebar.dart';
import '../receipt/new_receipt_screen.dart';
import '../screen.dart';

class HistoryScreen extends GetView<ReceiptController> {
  static const pageId = "/history";
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 900;

    if (isWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Row(
          children: [
            const WebAppSidebar(selectedItem: SidebarItem.history),
            Expanded(
              child: Column(
                children: [
                  _buildWebHeader(context),
                  Expanded(child: _buildMainContent()),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.whiteColor2,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        title: const Text('Receipt History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          const Text("Receipts History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
            onPressed: controller.refreshData,
            tooltip: "Refresh Data",
          ),
          const SizedBox(width: 16),
          const VerticalDivider(width: 1, indent: 20, endIndent: 20),
          const SizedBox(width: 16),
          Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.appTheame.withValues(alpha: 0.1), radius: 18, child: Icon(Icons.person_rounded, color: AppColors.appTheame, size: 20)),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(controller.userEmail, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _searchAndSortPanel(),
        Expanded(
          child: Obx(() {
            final list = controller.filteredReceiptList;
            final bool isWeb = MediaQuery.of(Get.context!).size.width > 900;

            if (list.isEmpty && !controller.isLoading.value) {
              return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
                SizedBox(height: 12),
                Text('No matching receipts found', style: TextStyle(color: Colors.grey, fontSize: 15)),
              ]));
            }

            return Skeletonizer(
              enabled: controller.isLoading.value,
              child: isWeb ? _buildWebTable(list) : _buildMobileList(list),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMobileList(List<ReceiptModel> list) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: controller.isLoading.value ? 6 : list.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = controller.isLoading.value ? ReceiptModel.dummy() : list[i];
        return _receiptCard(item);
      },
    );
  }

  Widget _buildWebTable(List<ReceiptModel> list) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.appTheame.withValues(alpha: 0.05)),
            dataRowMaxHeight: 65,
            horizontalMargin: 24,
            columns: const [
              DataColumn(label: Text('Receipt No', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Donor Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: list.map((r) {
              return DataRow(cells: [
                DataCell(Text('#${r.recNo}', style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.bold))),
                DataCell(Text(r.date)),
                DataCell(Text(r.donorName, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text('₹${NumberFormat('#,##,###').format(r.amount)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Text(r.paymentType, style: const TextStyle(fontSize: 11)),
                )),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _webActionButton(Icons.edit_note_rounded, Colors.blue, () {
                      controller.setupForEdit(r);
                      Get.toNamed(NewReceiptScreen.pageId);
                    }),
                    _webActionButton(Icons.local_printshop_rounded, Colors.blueGrey, () async {
                      final file = await ReceiptPdfHelper.generate(r, isPrint: true);
                      controller.printReceipt(file.path, receipt: r);
                    }),
                    _webActionButton(Icons.share_rounded, const Color(0xFF25D366), () async {
                      final file = await ReceiptPdfHelper.generate(r, isPrint: false);
                      controller.shareWhatsApp(file.path, receiptNo: r.recNo.toString(), mobileNo: r.mobileNo);
                    }),
                    _webActionButton(Icons.delete_outline_rounded, Colors.red, () => controller.deleteReceipt(r)),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _webActionButton(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onTap,
      hoverColor: color.withValues(alpha: 0.1),
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
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