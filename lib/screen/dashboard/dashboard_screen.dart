import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../model/model.dart';
import '../../services/google_sheets_service.dart';
import '../receipt/new_receipt_screen.dart';
import '../screen.dart';

class DashboardScreen extends GetView<DashboardController> {
  static const pageId = "/dashboard";
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // 📐 મોટી સ્ક્રીન (વેબ/ટેબ્લેટ) માટે ડાયનેમિક ગ્રીડ કાઉન્ટ સેટિંગ
    int gridCrossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);
    double gridAspectRatio = screenWidth > 900 ? 1.8 : (screenWidth > 600 ? 1.5 : 1.6);

    return Scaffold(
      backgroundColor: AppColors.whiteColor2,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        centerTitle: screenWidth > 600 ? true : false,
        title: Column(
          // ✅ એલાઈનમેન્ટ ફિક્સ: હવે પ્યોર ક્લીન CrossAxisAlignment સેટ છે
          crossAxisAlignment: screenWidth > 600 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(AppStrings.appName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(AppStrings.trustName, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadStats,
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 8),
        ],
      ),

      // 🚪 સ્માર્ટ અને મોર્ડન રિસ્પોન્સિવ ડ્રોઅર
      drawer: _buildResponsiveDrawer(context),

      // ... (ઉપરના Imports એમનેમ)

      body: RefreshIndicator(
        onRefresh: controller.loadStats,
        color: AppColors.appTheame,
        child: Obx(() {
          return Skeletonizer(
            enabled: controller.isLoading.value,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── 🌟 Header Banner ────────────────
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        decoration: BoxDecoration(
                          color: AppColors.appTheame,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Overview', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 14),
                            _mainStatCard(),
                          ],
                        ),
                      ),
                    ),

                    // ── 📊 Stats Grid ────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      sliver: SliverGrid.count(
                        crossAxisCount: gridCrossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: gridAspectRatio,
                        children: [
                          _statCard('Today', controller.todayAmount.value, Icons.today_rounded, Colors.orange),
                          _statCard('This Month', controller.monthAmount.value, Icons.calendar_month_rounded, Colors.blue),
                          _statCard('Total Receipts', controller.totalReceipts.value.toDouble(), Icons.receipt_long_rounded, Colors.green, isCount: true),
                          _statCard('PDF Reports', 0, Icons.picture_as_pdf_rounded, Colors.deepPurple, isAction: true, onTap: () => controller.showExportDialog(context)),
                        ],
                      ),
                    ),

                    // ── 📝 Recent Receipts Header ────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Recent Receipts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.appTheame)),
                            TextButton(
                              onPressed: () => Get.toNamed(HistoryScreen.pageId),
                              child: Text('View All', style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── 🗂️ 🚀 FIXED: Recent Receipts List (Skeletonizer Compatible) ────────────────
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            // જો ડેટા લોડ થતો હશે, તો ડમી રસીદ બતાવશે જે Skeletonizer સ્કેલેટન કરી દેશે
                            final receipt = controller.isLoading.value
                                ? ReceiptModel(
                                id: 'dummy', recNo: 0, date: '00/00/0000', donorName: 'Loading Data...',
                                panNo: '', mobileNo: '', amount: 0, amountInWords: '',
                                paymentType: '', bankName: '', chequeNo: '', remarks: '',
                                donationType: '', createdAt: DateTime.now(), updatedAt: DateTime.now()
                            )
                                : controller.recentReceipts[index];

                            return Center(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 1100),
                                child: _receiptTile(receipt),
                              ),
                            );
                          },
                          // લોડિંગ વખતે ૫ ડમી કાર્ડ્સ દેખાશે
                          childCount: controller.isLoading.value ? 5 : controller.recentReceipts.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),

      floatingActionButton: Container(
        margin: EdgeInsets.only(right: screenWidth > 1100 ? (screenWidth - 1100) / 2 : 0),
        child: FloatingActionButton.extended(
          onPressed: () {
            // 🚀 અલ્ટીમેટ સેફગાર્ડ: જો બાઈન્ડિંગ લોડ ન થયું હોય તો ક્રેશ થવાના બદલે આપોઆપ put થઈ જશે!
            final receiptCtrl = Get.isRegistered<ReceiptController>()
                ? Get.find<ReceiptController>()
                : Get.put(ReceiptController());

            receiptCtrl.setupForNewReceipt(); // ફોર્મ સાફ કરીને સીરીયલ ગણશે
            Get.toNamed(NewReceiptScreen.pageId);
          },
          backgroundColor: AppColors.appTheame,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Receipt', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
      ),
    );
  }

  // 🚪 🌟 PixelMechanic Responsive Drawer (૧૦૦% જેસ્ચર અને ટૅપ પ્રૂફ)
  Widget _buildResponsiveDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // User Profile Header
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, size: 40, color: AppColors.appTheame),
            ),
            accountName: Text(
              AppStrings.appName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              controller.userEmail,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
            ),
            decoration: BoxDecoration(
              color: AppColors.appTheame,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),

          // મેનુ આઇટમ્સ લિસ્ટ
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _drawerTile(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () => Get.back(),
                  selected: true,
                ),
                _drawerTile(
                  icon: Icons.add_box_rounded,
                  title: 'New Receipt',
                  onTap: () {
                    Get.back();
                    Get.toNamed(NewReceiptScreen.pageId);
                  },
                ),
                _drawerTile(
                  icon: Icons.history_rounded,
                  title: 'Receipts History',
                  onTap: () {
                    Get.back();
                    Get.toNamed(HistoryScreen.pageId);
                  },
                ),
                _drawerTile(
                  icon: Icons.insert_chart_outlined_rounded,
                  title: 'Reports',
                  onTap: () {
                    Get.back();
                    controller.showExportDialog(context);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Divider(thickness: 0.8),
                ),
                _drawerTile(
                  icon: Icons.settings_suggest_rounded,
                  title: 'Settings',
                  onTap: () {
                    Get.back();
                    Get.toNamed(SettingsScreen.pageId);
                  },
                ),
              ],
            ),
          ),

          // 🚪 🛡️ બોટમ સેક્શન (૧૦૦% સિસ્ટમ નેવિગેશન જેસ્ચર અને ટૅપ પ્રૂફ ઝોન)
          SafeArea(
            top: false,
            bottom: true, // 🚀 નવા નેવિગેશન બારથી ડ્રોઅરને સેફલી ઉપર રાખશે
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, thickness: 0.8),
                  const SizedBox(height: 16),

                  // લાલ બેકગ્રાઉન્ડ પટ્ટી (કન્ટેનર હવે પ્યોર નોન-ક્લિકેબલ છે)
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // 🎯 ફક્ત ટેક્સ્ટ અને આઇકન જ ક્લિક પકડશે, સાઇડનો લાલ ભાગ ફ્રીઝ!
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop(); // ૧. ડ્રોઅર બંધ કરો
                          try {
                            // ૨. બધા લોગઆઉટ સેશન ક્લીન કરો
                            await GoogleSignIn().signOut();
                            await FirebaseAuth.instance.signOut();
                            GoogleSheetsService.reset();

                            // 🚀 ૩. મોટો ફિક્સ: યુઝરને ડાયરેક્ટ લોગિન સ્ક્રીન પર મોકલી દો અને સ્ટેક ક્લીન કરો
                            Get.offAllNamed('/login'); // 👈 તારા પ્રોજેક્ટનો પ્યોર Login Page Route આઈડી નાખવો (દા.ત. LoginScreen.pageId)
                          } catch (e) {
                            debugPrint('Logout Error: $e');
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: Icon(Icons.logout_rounded, color: AppColors.errorColor, size: 18),
                        label: Text(
                          'Logout', // 👈 પ્યોર એન્ડ ક્લીન 'Logout' ટેક્સ્ટ
                          style: TextStyle(
                              color: AppColors.errorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.3
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'v2.0.26 • PixelPerfect Apps',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      selected: selected,
      selectedTileColor: AppColors.appTheame.withOpacity(0.08),
      selectedColor: AppColors.appTheame,
      iconColor: Colors.grey.shade600,
      textColor: Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
      onTap: onTap,
    );
  }

  Widget _mainStatCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text('Total Collection', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##,###.##').format(controller.totalAmount.value)}',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.appTheame, letterSpacing: 0.5),
          ),

          // 🚀 હવે અહિયાં માત્ર 'Active FY' જ દેખાશે, Sync Status નીકળી ગયું છે!
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Text('Active FY: 2026-27', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statCard(String title, double value, IconData icon, Color color, {bool isCount = false, bool isAction = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAction ? 'Reports' : (isCount ? value.toInt().toString() : '₹${NumberFormat('#,##,###').format(value.toInt())}'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isAction ? Colors.grey.shade700 : color, letterSpacing: 0.2),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptTile(ReceiptModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: AppColors.appTheame.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text('#${r.recNo}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.appTheame))),
        ),
        title: Text(r.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.2)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${r.date}  •  ${r.paymentType}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ),
        trailing: Text(
          '₹${NumberFormat('#,##,###').format(r.amount.toInt())}',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appTheame, fontSize: 15),
        ),
        onTap: () {},
      ),
    );
  }

  void _showSnack(String title, String msg, MaterialColor color) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.shade100,
      colorText: color.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
}
