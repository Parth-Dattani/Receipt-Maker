import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/constant.dart';
import '../controller/auth_controller.dart';
import '../controller/dashboard_controller.dart';
import '../controller/receipt_controller.dart';
import '../screen/dashboard/dashboard_screen.dart';
import '../screen/history/history_screen.dart';
import '../screen/receipt/new_receipt_screen.dart';
import '../screen/setting/settings_screen.dart';

enum SidebarItem { dashboard, newReceipt, history, reports, settings }

class WebAppSidebar extends StatelessWidget {
  final SidebarItem selectedItem;
  const WebAppSidebar({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      color: AppColors.appTheame,
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo & Name
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Image.asset(
              ImagePath.appLogo, 
              height: 85,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,

            ),
          ),
          const SizedBox(height: 16),
           Text(AppStrings.appName.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
          
          // 🚀 Display Active Financial Year in Sidebar
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(() => Text(
              "FY: ${AppConstants.activeFy.value}",
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
            )),
          ),
          
          const SizedBox(height: 30),
          
          // Menu Items
          _sidebarItem(Icons.dashboard_rounded, "Dashboard", isSelected: selectedItem == SidebarItem.dashboard, onTap: () => Get.offAllNamed(DashboardScreen.pageId)),
          _sidebarItem(Icons.add_box_rounded, "New Receipt", isSelected: selectedItem == SidebarItem.newReceipt, onTap: _navigateToNewReceipt),
          _sidebarItem(Icons.history_rounded, "History", isSelected: selectedItem == SidebarItem.history, onTap: () => Get.toNamed(HistoryScreen.pageId)),
          _sidebarItem(Icons.analytics_rounded, "Reports", isSelected: selectedItem == SidebarItem.reports, onTap: () {
             if (Get.isRegistered<DashboardController>()) {
              Get.find<DashboardController>().showExportDialog(context);
            }
          }),
          _sidebarItem(Icons.settings_suggest_rounded, "Settings", isSelected: selectedItem == SidebarItem.settings, onTap: () => Get.toNamed(SettingsScreen.pageId)),
          
          const Spacer(),
          
          // Logout
          _sidebarItem(Icons.logout_rounded, "Logout", onTap: () => Get.find<AuthController>().confirmLogout(), isDanger: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {bool isSelected = false, bool isDanger = false, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
        leading: Icon(icon, color: isDanger ? Colors.redAccent.shade100 : (isSelected ? Colors.white : Colors.white60), size: 20),
        title: Text(title, style: TextStyle(color: isDanger ? Colors.redAccent.shade100 : (isSelected ? Colors.white : Colors.white60), fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  void _navigateToNewReceipt() {
    final receiptCtrl = Get.isRegistered<ReceiptController>() ? Get.find<ReceiptController>() : Get.put(ReceiptController());
    receiptCtrl.setupForNewReceipt();
    Get.toNamed(NewReceiptScreen.pageId);
  }
}
