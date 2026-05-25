import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constant/constant.dart';
import '../../controller/auth_controller.dart';
import '../../controller/controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../model/model.dart';
import '../../widgets/web_app_sidebar.dart';
import '../receipt/new_receipt_screen.dart';
import '../screen.dart';

class DashboardScreen extends GetView<DashboardController> {
  static const pageId = "/dashboard";
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 900;

    return Scaffold(
      backgroundColor: isWeb ? const Color(0xFFF8F9FA) : AppColors.whiteColor2,
      appBar: isWeb ? null : _buildMobileAppBar(context),
      drawer: isWeb ? null : _buildResponsiveDrawer(context),
      body: isWeb ? _buildWebBody(context) : _buildMobileBody(context),
      floatingActionButton: isWeb ? null : _buildMobileFAB(screenWidth),
    );
  }

  // 📱 ── Mobile App Bar ──
  AppBar _buildMobileAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.appTheame,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.appName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(AppStrings.trustName, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: controller.loadStats),
        const SizedBox(width: 8),
      ],
    );
  }

  // 📱 ── Mobile FAB ──
  Widget _buildMobileFAB(double screenWidth) {
    return FloatingActionButton.extended(
      onPressed: _navigateToNewReceipt,
      backgroundColor: AppColors.appTheame,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text('New Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // 🌐 ── WEB / DESKTOP VIEW ──
  Widget _buildWebBody(BuildContext context) {
    return Row(
      children: [
        // 1. Sidebar (Fixed)
        const WebAppSidebar(selectedItem: SidebarItem.dashboard),
        
        // 2. Main Content Area
        Expanded(
          child: Column(
            children: [
              // Top Header
              _buildWebHeader(context),
              
              // Scrolling Content
              Expanded(
                child: Obx(() => Skeletonizer(
                  enabled: controller.isLoading.value,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Banner
                        _buildWebWelcomeBanner(),
                        const SizedBox(height: 32),
                        
                        // Top Stats Row
                        Row(
                          children: [
                            Expanded(child: _webStatCard('Total Collection', controller.totalAmount.value, Icons.account_balance_wallet_rounded, AppColors.appTheame)),
                            const SizedBox(width: 24),
                            Expanded(child: _webStatCard('Today\'s Collection', controller.todayAmount.value, Icons.today_rounded, Colors.orange)),
                            const SizedBox(width: 24),
                            Expanded(child: _webStatCard('This Month', controller.monthAmount.value, Icons.calendar_month_rounded, Colors.blue)),
                            const SizedBox(width: 24),
                            Expanded(child: _webStatCard('Total Receipts', controller.totalReceipts.value.toDouble(), Icons.receipt_long_rounded, Colors.green, isCount: true)),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Main Sections Row
                        _buildWebRecentReceipts(),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          const Text("Dashboard Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.grey), onPressed: controller.loadStats, tooltip: "Refresh Data"),
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

  Widget _buildWebWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.appTheame, AppColors.appTheame.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.appTheame.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome Back to Noor Receipt!", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Manage your trust collections and generate professional reports effortlessly.", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _navigateToNewReceipt,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text("Create New Receipt"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.appTheame, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _webStatCard(String title, double value, IconData icon, Color color, {bool isCount = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  isCount ? value.toInt().toString() : '₹${NumberFormat('#,##,###.##').format(value)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebRecentReceipts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => Get.toNamed(HistoryScreen.pageId), child: const Text("View History")),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.isLoading.value ? 5 : controller.recentReceipts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = controller.isLoading.value ? ReceiptModel.dummy() : controller.recentReceipts[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading: CircleAvatar(backgroundColor: AppColors.appTheame.withValues(alpha: 0.05), child: Text("#${r.recNo}", style: TextStyle(fontSize: 10, color: AppColors.appTheame, fontWeight: FontWeight.bold))),
                title: Text(r.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("${r.date} • ${r.paymentType}"),
                trailing: Text('₹${NumberFormat('#,##,###').format(r.amount)}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appTheame, fontSize: 16)),
              );
            },
          ),
        ],
      ),
    );
  }


  // 📱 ── MOBILE VIEW ──
  Widget _buildMobileBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadStats,
      color: AppColors.appTheame,
      child: Obx(() => Skeletonizer(
        enabled: controller.isLoading.value,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                decoration: BoxDecoration(color: AppColors.appTheame, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: [
                  _statCard('Today', controller.todayAmount.value, Icons.today_rounded, Colors.orange),
                  _statCard('This Month', controller.monthAmount.value, Icons.calendar_month_rounded, Colors.blue),
                  _statCard('Total Receipts', controller.totalReceipts.value.toDouble(), Icons.receipt_long_rounded, Colors.green, isCount: true),
                  _statCard('PDF Reports', 0, Icons.picture_as_pdf_rounded, Colors.deepPurple, isAction: true, onTap: () => controller.showExportDialog(context)),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Receipts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.appTheame)),
                    TextButton(onPressed: () => Get.toNamed(HistoryScreen.pageId), child: Text('View All', style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final receipt = controller.isLoading.value ? ReceiptModel.dummy() : controller.recentReceipts[index];
                    return _receiptTile(receipt);
                  },
                  childCount: controller.isLoading.value ? 5 : controller.recentReceipts.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      )),
    );
  }

  // 🚪 Drawer (Mobile Only)
  Widget _buildResponsiveDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              padding: const EdgeInsets.all(8),
              child: Image.asset(ImagePath.appLogo, filterQuality: FilterQuality.high),
            ),
            accountName: Text(AppStrings.appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            accountEmail: Text(controller.userEmail, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
            decoration: BoxDecoration(color: AppColors.appTheame, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _drawerTile(icon: Icons.dashboard_rounded, title: 'Dashboard', onTap: () => Get.back(), selected: true),
                _drawerTile(icon: Icons.add_box_rounded, title: 'New Receipt', onTap: () { Get.back(); _navigateToNewReceipt(); }),
                _drawerTile(icon: Icons.history_rounded, title: 'Receipts History', onTap: () { Get.back(); Get.toNamed(HistoryScreen.pageId); }),
                _drawerTile(icon: Icons.insert_chart_outlined_rounded, title: 'Reports', onTap: () { Get.back(); controller.showExportDialog(context); }),
                const Divider(thickness: 0.8, height: 16),
                _drawerTile(icon: Icons.settings_suggest_rounded, title: 'Settings', onTap: () { Get.back(); Get.toNamed(SettingsScreen.pageId); }),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: _performLogout,
                icon: Icon(Icons.logout_rounded, color: AppColors.errorColor),
                label: Text('Logout', style: TextStyle(color: AppColors.errorColor, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNewReceipt() {
    final receiptCtrl = Get.isRegistered<ReceiptController>() ? Get.find<ReceiptController>() : Get.put(ReceiptController());
    receiptCtrl.setupForNewReceipt();
    Get.toNamed(NewReceiptScreen.pageId);
  }

  void _performLogout() {
    final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController());
    auth.confirmLogout();
  }

  Widget _drawerTile({required IconData icon, required String title, required VoidCallback onTap, bool selected = false}) {
    return ListTile(
      selected: selected,
      selectedTileColor: AppColors.appTheame.withValues(alpha: 0.08),
      selectedColor: AppColors.appTheame,
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
      onTap: onTap,
    );
  }

  Widget _mainStatCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(
        children: [
          Text('Total Collection', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('₹${NumberFormat('#,##,###.##').format(controller.totalAmount.value)}', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.appTheame, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Text('Active FY: ${AppConstants.activeFy}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, double value, IconData icon, Color color, {bool isCount = false, bool isAction = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
            const Spacer(),
            Text(isAction ? 'Reports' : (isCount ? value.toInt().toString() : '₹${NumberFormat('#,##,###').format(value.toInt())}'), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isAction ? Colors.grey.shade700 : color)),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _receiptTile(ReceiptModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.015), blurRadius: 10, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.appTheame.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)), child: Center(child: Text('#${r.recNo}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.appTheame)))),
        title: Text(r.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('${r.date} • ${r.paymentType}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: Text('₹${NumberFormat('#,##,###').format(r.amount.toInt())}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appTheame, fontSize: 15)),
      ),
    );
  }
}
