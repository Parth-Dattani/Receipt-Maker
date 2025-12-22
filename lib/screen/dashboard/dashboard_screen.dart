import 'package:demo_prac_getx/constant/app_constant.dart' show AppConstants;
import 'package:demo_prac_getx/screen/dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../utils/calculations.dart';
import '../screen.dart';
import 'package:shimmer/shimmer.dart';



import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DashboardScreen extends GetView<DashboardController> {
  static const String pageId = '/DashboardScreen';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is greater than 900, use Web/Desktop Layout
        if (constraints.maxWidth > 900) {
          return _buildWebLayout(context);
        }
        // Otherwise use Mobile Layout
        return _buildMobileLayout(context);
      },
    );
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT (Horizontal Cards)
  // ===========================================================================
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            controller.scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(Icons.menu),
        ),
        title: Text('invoice_sathi'.tr),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => controller.isLoading.value
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
              : IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshDashboard,
          )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.invoiceList.isEmpty) {
            return const DashboardShimmer();
          }
          return RefreshIndicator(
            onRefresh: () async => await controller.refreshDashboard(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeBanner(),

                  SizedBox(height: 20),

                  // Statistics Cards
                  DashboardStatsCard(),

                  SizedBox(height: 20),
                  // Quick Actions
                  QuickActionsGrid(),

                  SizedBox(height: 20),

                  // Charts Section & Export (Mobile Flow)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart on the left
                      Expanded(
                        flex: 1,
                        child: InvoiceStatusChart(),
                      ),

                      const SizedBox(width: 16),

                      // Export + Summary cards on the right
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildExportCard(
                              context: context,
                              icon: Icons.summarize,
                              title: "summary_report".tr,
                              subtitle: "get_summary_report".tr,
                              onTap: () => showReportDialog(context),
                            ),
                            SizedBox(height: 16),
                            _buildExportCard(
                              context: context,
                              icon: Icons.file_download,
                              title: "Export Data",
                              subtitle: "for_auditing_report".tr,
                              onTap: () => showExportDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  SizedBox(height: 20),

                  // Recent Invoices
                  RecentInvoicesCard(),
                ],
              ),
            ),
          );
        }),
      ),
      drawer: buildDrawer(),
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Vertical Cards) - COMPACT VERSION
  // ===========================================================================
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // 1. Fixed Sidebar (Made slightly narrower: 250px)
          SizedBox(
            width: 250,
            child: _buildWebSidebar(context),
          ),

          // 2. Main Content
          Expanded(
            child: Column(
              children: [
                // Web Header (Compacted)
                _buildWebHeader(),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    // Reduced padding from 24 to 16
                    padding: const EdgeInsets.all(16),
                    child: Obx(() {
                      if (controller.isLoading.value && controller.invoiceList.isEmpty) {
                        return const DashboardShimmer(isWeb: true);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeBanner(), // Compacted inside

                          // Reduced vertical gap from 24 to 16
                          const SizedBox(height: 16),

                          // 2-Column Layout for Web
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT COLUMN (Main Stats & Charts) - Flex 3
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    DashboardStatsCard(),
                                    const SizedBox(height: 16), // Reduced gap
                                    InvoiceStatusChart(),
                                    const SizedBox(height: 16), // Reduced gap
                                    RecentInvoicesCard(),
                                  ],
                                ),
                              ),

                              // Reduced horizontal gap from 24 to 16
                              const SizedBox(width: 16),

                              // RIGHT COLUMN (Quick Actions & Reports) - Flex 1
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    // Quick Actions Container
                                    Container(
                                      // Reduced padding from 20 to 16
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                        ],
                                      ),
                                      child: QuickActionsGrid(),
                                    ),

                                    const SizedBox(height: 16),

                                    // Reports & Export Section
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Reports & Export",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15, // Slightly smaller font
                                                color: Colors.grey[700]
                                            )
                                        ),
                                        const SizedBox(height: 12),

                                        // Vertical Card 1: Summary
                                        _buildWebReportCard(
                                            icon: Icons.summarize,
                                            title: "Summary Report",
                                            subtitle: "Get monthly summary",
                                            onTap: () => showReportDialog(context)
                                        ),

                                        const SizedBox(height: 12), // Reduced gap

                                        // Vertical Card 2: Export Data
                                        _buildWebReportCard(
                                            icon: Icons.file_download,
                                            title: "Export Data",
                                            subtitle: "Excel format",
                                            onTap: () => showExportDialog(context)
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 🎨 CARD HELPERS
  // ===========================================================================

  // 1. Vertical Card (For Web)
  Widget _buildWebReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        // Drastically reduced vertical padding from 24 to 16
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10), // Reduced from 12
              decoration: BoxDecoration(
                color: AppColors.tealColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: AppColors.tealColor), // Reduced size from 32
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.tealColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Horizontal Card (For Mobile)
  Widget _buildExportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.tealColor),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.tealColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 🎨 WEB COMPONENTS
  // ===========================================================================

  Widget _buildWebSidebar(BuildContext context) {
    return Container(
      color: AppColors.tealColor,
      child: Column(
        children: [
          // 1. Ultra Compact Header (Height 50)
          Container(
            height: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16), // Tighter edges
            child: Row(
              children: [
                const Icon(Icons.dashboard_customize, color: Colors.white, size: 20), // Smaller Icon
                const SizedBox(width: 10),
                const Text('Invoice Sathi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), // Smaller Text
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8), // Very tight top/bottom
              children: [
                _buildWebMenuItem(Icons.dashboard, "Dashboard", true, () {}),

                if (AppConstants.businessType == "Trading") ...[
                  _buildWebSectionHeader("PURCHASE"),
                  _buildWebMenuItem(Icons.shopping_cart, "Purchase", false, () => controller.navigateToInventory()),
                  _buildWebMenuItem(Icons.list_alt, "Purchase List", false, () => controller.navigateToPurchaseList()),
                ],

                _buildWebSectionHeader("SALES"),
                if (AppConstants.businessType == "Trading")
                  _buildWebMenuItem(Icons.note_alt, "Challans", false, () => controller.navigateToChallanList()),

                _buildWebMenuItem(Icons.receipt, "Invoice", false, () => controller.navigateToInvoiceList()),
                _buildWebMenuItem(Icons.request_quote, "Quotations", false, () => controller.navigateToQuotList()),

                if (AppConstants.businessType == "Trading")
                  _buildWebMenuItem(Icons.assessment, "Stock Report", false, () => controller.navigateToStockReport()),

                _buildWebMenuItem(Icons.people, "customers".tr, false, () => controller.navigateToCustomerList()),
                _buildWebMenuItem(Icons.payment, "payment".tr, false, () => controller.navigateToPaymentDetails()),

                // Tighter Divider (Height 12 instead of 24)
                const Divider(color: Colors.white24, height: 12),

                _buildWebSectionHeader("SETTINGS"),
                if (AppConstants.businessType == "Trading")
                  Obx(() => _buildWebSwitchTile(
                    icon: Icons.list_alt,
                    title: "enable_challan".tr,
                    value: AppConstants.isChallan.value,
                    activeColor: Colors.greenAccent,
                    onChanged: (value) async {
                      await controller.updateCompanyPreference('isChallanEnabled', value);
                    },
                  )),

                Obx(() => _buildWebSwitchTile(
                  icon: Icons.language,
                  title: 'enable_gujarati'.tr,
                  value: AppConstants.isGujarati.value,
                  activeColor: Colors.deepPurpleAccent,
                  onChanged: (value) async {
                    await controller.updateLanguagePreference(value);
                  },
                )),

                const Divider(color: Colors.white24, height: 12),

                _buildWebSectionHeader("COMPANY"),
                if (controller.hasMultipleCompanies.value)
                  _buildWebMenuItem(Icons.swap_horiz, "Switch Company", false, () => controller.showCompanySwitcher()),

                _buildWebMenuItem(Icons.business, "edit_company".tr, false, () {
                  final data = controller.currentCompany.value;
                  if (data != null) controller.navigateToEditCompany(data, controller.companyId.value);
                }),

                const Divider(color: Colors.white24, height: 12),

                _buildWebMenuItem(Icons.logout, "logout".tr, false, () => controller.logout()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color activeColor,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value), // Tapping the text/row also toggles the switch
      child: Padding(
        // Matches the padding of _buildWebMenuItem (Horizontal 20, Vertical reduced to 8)
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 13.5),
              ),
            ),
            Transform.scale(
              scale: 0.7, // Makes the switch smaller to fit the compact design
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: activeColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Removes extra hit-test padding
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebMenuItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2), // Reduced margin
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced vertical padding (12 -> 10)
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
          border: isActive ? const Border(left: BorderSide(color: Colors.white, width: 4)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSectionHeader(String title) {
    return Padding(
      // Tighter section headers
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildWebHeader() {
    return Container(
      height: 60, // Reduced from 70
      padding: const EdgeInsets.symmetric(horizontal: 20), // Reduced horizontal padding
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: controller.refreshDashboard,
                splashRadius: 20, // Tighter splash
              ),
              const SizedBox(width: 16),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.userName.value.isNotEmpty ? controller.userName.value : 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(controller.companyName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              )),
              const SizedBox(width: 12),
              CircleAvatar(
                  radius: 18, // Slightly smaller avatar
                  backgroundColor: AppColors.tealColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: AppColors.tealColor, size: 20)
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tealColor,
            AppColors.tealColor.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.companyName.isNotEmpty
                ? controller.companyName
                : "No Company Selected",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22, // Slightly smaller font
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Here is what's happening with your business today.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          )
        ],
      ),
    );
  }

  // ===========================================================================
  // 🗓️ DIALOGS
  // ===========================================================================
  Future<void> showExportDialog(BuildContext context) async {
    DateTime? fromDate;
    DateTime? toDate;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.tealColor, AppColors.tealColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.file_download_outlined, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("export_invoices".tr, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("select_date_range_to_export".tr, style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildDateCard(
                            context: context,
                            icon: Icons.calendar_today,
                            label: "from_date".tr,
                            date: fromDate,
                            color: AppColors.tealColor,
                            onTap: () async {
                              final isDemo = AppConstants.isDemo.value;
                              final startLimit = isDemo ? DateTime(1990) : DateTime(2000);
                              final endLimit = isDemo ? DateTime(1992) : DateTime.now();

                              DateTime initDate = fromDate ?? (isDemo ? DateTime(1992) : DateTime.now());
                              if (initDate.isAfter(endLimit)) initDate = endLimit;
                              if (initDate.isBefore(startLimit)) initDate = startLimit;

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: initDate,
                                firstDate: startLimit,
                                lastDate: endLimit,
                              );
                              if (picked != null) setState(() => fromDate = picked);
                            },
                          ),
                          const SizedBox(height: 16),
                          Icon(Icons.arrow_downward_rounded, color: Colors.grey.shade400, size: 24),
                          const SizedBox(height: 16),
                          _buildDateCard(
                            context: context,
                            icon: Icons.event,
                            label: "to_date".tr,
                            date: toDate,
                            color: AppColors.tealColor,
                            onTap: () async {
                              final isDemo = AppConstants.isDemo.value;
                              final startLimit = isDemo ? DateTime(1990) : DateTime(2000);
                              final endLimit = isDemo ? DateTime(1992) : DateTime.now();

                              // Logic: Start from 'fromDate', but clamp to limits
                              DateTime effectiveFirst = fromDate ?? startLimit;
                              if (effectiveFirst.isAfter(endLimit)) effectiveFirst = endLimit;
                              if (effectiveFirst.isBefore(startLimit)) effectiveFirst = startLimit;

                              DateTime initDate = toDate ?? endLimit;
                              if (initDate.isBefore(effectiveFirst)) initDate = effectiveFirst;
                              if (initDate.isAfter(endLimit)) initDate = endLimit;

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: initDate,
                                firstDate: effectiveFirst,
                                lastDate: endLimit,
                              );
                              if (picked != null) setState(() => toDate = picked);
                            },
                          ),
                          const SizedBox(height: 24),
                          if (fromDate != null && toDate != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.tealColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: AppColors.tealColor, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text("Exporting ${_calculateDays(fromDate!, toDate!)} days of data", style: TextStyle(color: AppColors.tealColor, fontSize: 14))),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                if (fromDate == null || toDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Please select both dates"), backgroundColor: Colors.red.shade600));
                                  return;
                                }
                                Navigator.pop(context);
                                await controller.exportInvoiceDataWithDateFilter(fromDate!, toDate!);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.download_rounded, size: 24),
                                  SizedBox(width: 12),
                                  Text("export_to_excel".tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showReportDialog(BuildContext context) async {
    DateTime? fromDate;
    DateTime? toDate;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.tealColor, AppColors.tealColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.file_download_outlined, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("export_invoices".tr, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("Select date range to export", style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildDateCard(
                            context: context,
                            icon: Icons.calendar_today,
                            label: "from_date".tr,
                            date: fromDate,
                            color: AppColors.tealColor,
                            onTap: () async {
                              final isDemo = AppConstants.isDemo.value;
                              final startLimit = isDemo ? DateTime(1990) : DateTime(2000);
                              final endLimit = isDemo ? DateTime(1992) : DateTime.now();

                              DateTime initDate = fromDate ?? (isDemo ? DateTime(1992) : DateTime.now());
                              if (initDate.isAfter(endLimit)) initDate = endLimit;
                              if (initDate.isBefore(startLimit)) initDate = startLimit;

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: initDate,
                                firstDate: startLimit,
                                lastDate: endLimit,
                              );
                              if (picked != null) setState(() => fromDate = picked);
                            },
                          ),
                          const SizedBox(height: 16),
                          Icon(Icons.arrow_downward_rounded, color: Colors.grey.shade400, size: 24),
                          const SizedBox(height: 16),
                          _buildDateCard(
                            context: context,
                            icon: Icons.event,
                            label: "to_date",
                            date: toDate,
                            color: AppColors.tealColor,
                            onTap: () async {
                              final isDemo = AppConstants.isDemo.value;
                              final startLimit = isDemo ? DateTime(1990) : DateTime(2000);
                              final endLimit = isDemo ? DateTime(1992) : DateTime.now();

                              DateTime effectiveFirst = fromDate ?? startLimit;
                              if (effectiveFirst.isAfter(endLimit)) effectiveFirst = endLimit;
                              if (effectiveFirst.isBefore(startLimit)) effectiveFirst = startLimit;

                              DateTime initDate = toDate ?? endLimit;
                              if (initDate.isBefore(effectiveFirst)) initDate = effectiveFirst;
                              if (initDate.isAfter(endLimit)) initDate = endLimit;

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: initDate,
                                firstDate: effectiveFirst,
                                lastDate: endLimit,
                              );
                              if (picked != null) setState(() => toDate = picked);
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                if (fromDate == null || toDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Please select both dates"), backgroundColor: Colors.red.shade600));
                                  return;
                                }
                                Navigator.pop(context);
                                await controller.exportGSTReportWithDateFilter(fromDate!, toDate!);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.download_rounded, size: 24),
                                  SizedBox(width: 12),
                                  Text("export".tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required DateTime? date,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: date != null ? color.withOpacity(0.5) : Colors.grey.shade300, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(date == null ? "select_date".tr : "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}", style: TextStyle(color: date != null ? Colors.black87 : Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  int _calculateDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }

  Widget buildDrawer() {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.tealColor, AppColors.tealColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Obx(() => Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 25, backgroundColor: Colors.white.withOpacity(0.3), child: Icon(Icons.person, size: 28, color: Colors.white)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(controller.userName.value.isNotEmpty ? controller.userName.value : 'User', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text(controller.userEmail.value, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.business, size: 20, color: Colors.white)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(controller.companyName.isNotEmpty ? controller.companyName : "No Company Selected", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                if (controller.hasMultipleCompanies.value)
                                  GestureDetector(
                                    onTap: controller.showCompanySwitcher,
                                    child: Container(margin: EdgeInsets.only(top: 2), child: Row(mainAxisSize: MainAxisSize.min, children: [Text("Switch Company", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)), SizedBox(width: 4), Icon(Icons.swap_horiz, color: Colors.white.withOpacity(0.8), size: 12)])),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 8, bottom: 20),
                children: [
                  if (AppConstants.businessType == "Trading")
                    _buildExpansionTile(
                      icon: Icons.inventory_2, iconColor: Colors.blue.shade600, title: "purchase".tr,
                      children: [
                        _buildSubMenuItem(icon: Icons.shopping_cart, iconColor: Colors.blue.shade700, title: "purchase".tr, onTap: () {
                          //Get.back();
                          controller.navigateToInventory(); }),
                        _buildSubMenuItem(icon: Icons.list_alt, iconColor: Colors.blue.shade700, title: "Purchase List", onTap: () { Get.back(); controller.navigateToPurchaseList(); }),
                      ],
                    ),
                  _buildExpansionTile(
                    icon: Icons.receipt_long, iconColor: Colors.purple.shade600, title: "sales".tr,
                    children: [
                      if (AppConstants.businessType == "Trading")
                        _buildSubMenuItem(icon: Icons.note_alt, iconColor: Colors.purple.shade700, title: "challans".tr, onTap: () { Get.back(); controller.navigateToChallanList(); }),
                      _buildSubMenuItem(icon: Icons.receipt, iconColor: Colors.purple.shade700, title: "invoice".tr, onTap: () { Get.back(); controller.navigateToInvoiceList(); }),
                      _buildSubMenuItem(icon: Icons.request_quote, iconColor: Colors.purple.shade700, title: "quotations".tr, onTap: () { Get.back(); controller.navigateToQuotList(); }),
                    ],
                  ),
                  if (AppConstants.businessType == "Trading")
                    _buildMenuItem(icon: Icons.assessment, iconColor: Colors.purple.shade600, title: "Stock Report", onTap: () { Get.back(); controller.navigateToStockReport(); }),
                  _buildMenuItem(icon: Icons.people, iconColor: Colors.orange.shade600, title: "customers".tr, onTap: () { Get.back(); controller.navigateToCustomerList(); }),
                  _buildMenuItem(icon: Icons.account_balance_wallet, iconColor: Colors.indigo.shade600, title: "payment".tr, onTap: () { Get.back(); controller.navigateToPaymentDetails(); }),
                  Divider(height: 32, thickness: 1),
                  _buildSectionHeader("settings".tr),
                  if (AppConstants.businessType == "Trading")
                    Obx(() => _buildSwitchTile(icon: Icons.list_alt, iconColor: Colors.green.shade600, title: "enable_challan".tr, value: AppConstants.isChallan.value, activeColor: Colors.green.shade600, onChanged: (value) async { await controller.updateCompanyPreference('isChallanEnabled', value); })),
                  Obx(() => _buildSwitchTile(icon: Icons.language, iconColor: Colors.deepPurple.shade600, title: 'enable_gujarati'.tr, value: AppConstants.isGujarati.value, activeColor: Colors.deepPurple.shade600, onChanged: (value) async { await controller.updateLanguagePreference(value); })),
                  Divider(height: 32, thickness: 1),
                  _buildSectionHeader("company_management".tr),
                  if (controller.hasMultipleCompanies.value)
                    _buildMenuItem(icon: Icons.swap_horiz, iconColor: Colors.indigo.shade600, title: "Switch Company", onTap: () { Get.back(); controller.showCompanySwitcher(); }),
                  _buildMenuItem(icon: Icons.business, iconColor: Colors.teal.shade600, title: "edit_company".tr, onTap: () { final data = controller.currentCompany.value; if (data != null && controller.companyId.value.isNotEmpty) { Get.back(); controller.navigateToEditCompany(data, controller.companyId.value); } else { Get.snackbar("Error", "No active company found to edit."); } }),
                  Divider(height: 32, thickness: 1),
                  _buildMenuItem(icon: Icons.logout, iconColor: Colors.red.shade600, title: "logout".tr, titleStyle: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600), onTap: () { Get.dialog(AlertDialog(title: Row(children: [Icon(Icons.logout, color: Colors.red.shade600), SizedBox(width: 12), Text("confirm_logout".tr)]), content: Text("logout_message".tr), actions: [TextButton(child: Text("cancel".tr), onPressed: () => Get.back()), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600), onPressed: () async { Get.back(); await controller.logout(); }, child: Text("logout".tr))])); }),
                  SizedBox(height: 20),
                  Container(padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20), decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('invoice_sathi'.tr), Obx(() => Text('v${controller.appVersion.value}'))])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, 8), child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.2)));
  }

  Widget _buildExpansionTile({required IconData icon, required Color iconColor, required String title, required List<Widget> children}) {
    return Theme(data: ThemeData(dividerColor: Colors.transparent), child: ExpansionTile(leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 22)), title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800)), iconColor: AppColors.tealColor, children: children));
  }

  Widget _buildSubMenuItem({required IconData icon, required Color iconColor, required String title, required VoidCallback onTap}) {
    return ListTile(contentPadding: EdgeInsets.only(left: 60, right: 16), leading: Icon(icon, color: iconColor, size: 20), title: Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)), dense: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), onTap: onTap);
  }

  Widget _buildMenuItem({required IconData icon, required Color iconColor, required String title, required VoidCallback onTap, TextStyle? titleStyle}) {
    return ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 22)), title: Text(title, style: titleStyle ?? TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), onTap: onTap);
  }

  Widget _buildSwitchTile({required IconData icon, required Color iconColor, required String title, required bool value, required Color activeColor, required Function(bool) onChanged}) {
    return ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 22)), title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800)), trailing: Switch(value: value, onChanged: onChanged, activeColor: Colors.white, activeTrackColor: activeColor));
  }
}

class DashboardShimmer extends StatelessWidget {
  final bool isWeb;

  const DashboardShimmer({super.key, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    if (isWeb) {
      return _buildWebShimmer();
    }
    return _buildMobileShimmer();
  }

  // 📱 Mobile Shimmer (Your existing layout)
  Widget _buildMobileShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _shimmerBox(height: 100, width: double.infinity, borderRadius: 15),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 100, borderRadius: 12)),
              const SizedBox(width: 10),
              Expanded(child: _shimmerBox(height: 100, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => _shimmerBox(borderRadius: 12),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 200, borderRadius: 12)),
              const SizedBox(width: 10),
              Expanded(child: _shimmerBox(height: 200, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecentListShimmer(),
        ],
      ),
    );
  }

  // 💻 Web Shimmer (Matches your Dashboard Web Layout)
  Widget _buildWebShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner
        _shimmerBox(height: 100, width: double.infinity, borderRadius: 15),
        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT COLUMN (Flex 3)
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Stats Cards Row
                  Row(
                    children: [
                      Expanded(child: _shimmerBox(height: 120, borderRadius: 12)),
                      const SizedBox(width: 20),
                      Expanded(child: _shimmerBox(height: 120, borderRadius: 12)),
                      const SizedBox(width: 20),
                      Expanded(child: _shimmerBox(height: 120, borderRadius: 12)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Chart
                  _shimmerBox(height: 300, borderRadius: 12),
                  const SizedBox(height: 24),
                  // Recent Invoices
                  _buildRecentListShimmer(),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // RIGHT COLUMN (Flex 1)
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Quick Actions Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _shimmerBox(height: 20, width: 100), // Title
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.5,
                          ),
                          itemBuilder: (_, __) => _shimmerBox(borderRadius: 8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Report Cards
                  _shimmerBox(height: 150, borderRadius: 20),
                  const SizedBox(height: 16),
                  _shimmerBox(height: 150, borderRadius: 20),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentListShimmer() {
    return Column(
      children: List.generate(
        3,
            (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _shimmerBox(height: 60, borderRadius: 12),
        ),
      ),
    );
  }

  Widget _shimmerBox({double height = 80, double? width, double borderRadius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}


///mobile Working
// class DashboardScreen extends GetView<DashboardController> {
//   static const String pageId = '/DashboardScreen';
//
//   const DashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.checkSubscriptionStatus();
//     });
//     return Scaffold(
//       key: controller.scaffoldKey,
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             controller.scaffoldKey.currentState?.openDrawer();
//           },
//           icon: Icon(Icons.menu),
//         ),
//         title: Text('invoice_sathi'.tr),
//         backgroundColor: AppColors.tealColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           // 🆕 Show loading indicator in AppBar when refreshing
//           Obx(() => controller.isLoading.value
//               ? Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ),
//           )
//               : IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: controller.refreshDashboard,
//           )),
//         ],
//       ),
//       body: SafeArea(
//         child: Obx(() {
//           if (controller.isLoading.value && controller.invoiceList.isEmpty) {
//             return const DashboardShimmer();
//           }
//           // 🆕 Show content even if loading (for refresh)
//           return RefreshIndicator(
//             onRefresh: () async => await controller.refreshDashboard(),
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(16),
//               physics: AlwaysScrollableScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Welcome Section
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           AppColors.tealColor,
//                           AppColors.tealColor.withOpacity(0.7)
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           controller.companyName.isNotEmpty
//                               ? controller.companyName
//                               : "No Company Selected",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: 20),
//
//                   // Statistics Cards
//                   DashboardStatsCard(),
//
//                   SizedBox(height: 20),
//                   // Quick Actions
//                   QuickActionsGrid(),
//
//                   SizedBox(height: 20),
//
//                   // Charts Section
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Chart on the left
//                       Expanded(
//                         flex: 1,
//                         child: InvoiceStatusChart(),
//                       ),
//
//                       const SizedBox(width: 16),
//
//                       // Export + Summary cards on the right
//                       Expanded(
//                         flex: 1,
//                         child: Column(
//                           children: [
//                             InkWell(
//                               onTap: () => showReportDialog(context),
//                               borderRadius: BorderRadius.circular(12),
//                               child: Container(
//                                 margin: const EdgeInsets.only(bottom: 16),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   border: Border.all(
//                                       color: Colors.grey.shade300, width: 1),
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.15),
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.summarize,
//                                         size: 32, color: AppColors.tealColor),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       "summary_report".tr,
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColors.tealColor,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 3),
//                                     Text(
//                                       "get_summary_report".tr,
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           fontSize: 11,
//                                           color: Colors.grey.shade600),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//
//                             InkWell(
//                               onTap: () => showExportDialog(context),
//                               borderRadius: BorderRadius.circular(12),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   border: Border.all(
//                                       color: Colors.grey.shade300, width: 1),
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.15),
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.file_download,
//                                         size: 32, color: AppColors.tealColor),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       "Export Invoice Data",
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColors.tealColor,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 3),
//                                     Text(
//                                       "for_auditing_report".tr,
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           fontSize: 11,
//                                           color: Colors.grey.shade600),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 14),
//                   SizedBox(height: 20),
//
//                   // Recent Invoices
//                   RecentInvoicesCard(),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//       drawer: buildDrawer(),
//     );
//   }
//
//   Future<void> showExportDialog(BuildContext context) async {
//     DateTime? fromDate;
//     DateTime? toDate;
//
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 constraints: const BoxConstraints(maxWidth: 500),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header with gradient
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             AppColors.tealColor,
//                             AppColors.tealColor.withOpacity(0.7)
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.file_download_outlined,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "export_invoices".tr,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   "select_date_range_to_export".tr,
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close, color: Colors.white),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Body
//                     Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         children: [
//                           // From Date Card
//                           _buildDateCard(
//                             context: context,
//                             icon: Icons.calendar_today,
//                             label: "from_date".tr,
//                             date: fromDate,
//                             color: AppColors.tealColor,
//                             onTap: () async {
//                               final picked = await showDatePicker(
//                                 context: context,
//                                 initialDate: fromDate ?? DateTime.now(),
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (picked != null) {
//                                 setState(() => fromDate = picked);
//                               }
//                             },
//                           ),
//
//                           const SizedBox(height: 16),
//
//                           // Arrow indicator
//                           Icon(
//                             Icons.arrow_downward_rounded,
//                             color: Colors.grey.shade400,
//                             size: 24,
//                           ),
//
//                           const SizedBox(height: 16),
//
//                           // To Date Card
//                           _buildDateCard(
//                             context: context,
//                             icon: Icons.event,
//                             label: "to_date".tr,
//                             date: toDate,
//                             color: AppColors.tealColor,
//                             onTap: () async {
//                               final picked = await showDatePicker(
//                                 context: context,
//                                 initialDate: toDate ?? DateTime.now(),
//                                 firstDate: fromDate ?? DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (picked != null) {
//                                 setState(() => toDate = picked);
//                               }
//                             },
//                           ),
//
//                           const SizedBox(height: 24),
//
//                           // Info box
//                           if (fromDate != null && toDate != null)
//                             Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: AppColors.tealColor.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                     color: AppColors.tealColor.withOpacity(0.3)),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.info_outline,
//                                       color: AppColors.tealColor, size: 20),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Text(
//                                       "Exporting ${_calculateDays(fromDate!, toDate!)} days of data",
//                                       style: TextStyle(
//                                         color: AppColors.tealColor,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                           const SizedBox(height: 24),
//
//                           // Export Button
//                           SizedBox(
//                             width: double.infinity,
//                             height: 56,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.tealColor,
//                                 foregroundColor: Colors.white,
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               onPressed: () async {
//                                 if (fromDate == null || toDate == null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content:
//                                       const Text("Please select both dates"),
//                                       backgroundColor: Colors.red.shade600,
//                                       behavior: SnackBarBehavior.floating,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                     ),
//                                   );
//                                   return;
//                                 }
//
//                                 Navigator.pop(context);
//                                 await controller.exportInvoiceDataWithDateFilter(
//                                   fromDate!,
//                                   toDate!,
//                                 );
//                               },
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.download_rounded, size: 24),
//                                   SizedBox(width: 12),
//                                   Text(
//                                     "export_to_excel".tr,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> showReportDialog(BuildContext context) async {
//     DateTime? fromDate;
//     DateTime? toDate;
//
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 constraints: const BoxConstraints(maxWidth: 500),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header with gradient
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             AppColors.tealColor,
//                             AppColors.tealColor.withOpacity(0.7)
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.file_download_outlined,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "export_invoices".tr,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   "Select date range to export",
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close, color: Colors.white),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Body
//                     Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         children: [
//                           // From Date Card
//                           _buildDateCard(
//                             context: context,
//                             icon: Icons.calendar_today,
//                             label: "from_date".tr,
//                             date: fromDate,
//                             color: AppColors.tealColor,
//                             onTap: () async {
//                               final picked = await showDatePicker(
//                                 context: context,
//                                 initialDate: fromDate ?? DateTime.now(),
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (picked != null) {
//                                 setState(() => fromDate = picked);
//                               }
//                             },
//                           ),
//
//                           const SizedBox(height: 16),
//
//                           // Arrow indicator
//                           Icon(
//                             Icons.arrow_downward_rounded,
//                             color: Colors.grey.shade400,
//                             size: 24,
//                           ),
//
//                           const SizedBox(height: 16),
//
//                           // To Date Card
//                           _buildDateCard(
//                             context: context,
//                             icon: Icons.event,
//                             label: "to_date",
//                             date: toDate,
//                             color: AppColors.tealColor,
//                             onTap: () async {
//                               final picked = await showDatePicker(
//                                 context: context,
//                                 initialDate: toDate ?? DateTime.now(),
//                                 firstDate: fromDate ?? DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (picked != null) {
//                                 setState(() => toDate = picked);
//                               }
//                             },
//                           ),
//
//                           const SizedBox(height: 24),
//
//                           // Info box
//                           if (fromDate != null && toDate != null)
//                             Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: AppColors.tealColor.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                     color: AppColors.tealColor.withOpacity(0.3)),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.info_outline,
//                                       color: AppColors.tealColor, size: 20),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Text(
//                                       "Exporting ${_calculateDays(fromDate!, toDate!)} days of data",
//                                       style: TextStyle(
//                                         color: AppColors.tealColor,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                           const SizedBox(height: 24),
//
//                           // Export Button
//                           SizedBox(
//                             width: double.infinity,
//                             height: 56,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.tealColor,
//                                 foregroundColor: Colors.white,
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               onPressed: () async {
//                                 if (fromDate == null || toDate == null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content:
//                                       const Text("Please select both dates"),
//                                       backgroundColor: Colors.red.shade600,
//                                       behavior: SnackBarBehavior.floating,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                     ),
//                                   );
//                                   return;
//                                 }
//
//                                 Navigator.pop(context);
//                                 await controller.exportGSTReportWithDateFilter(
//                                   fromDate!,
//                                   toDate!,
//                                 );
//                               },
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.download_rounded, size: 24),
//                                   SizedBox(width: 12),
//                                   Text(
//                                     "export".tr,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildDateCard({
//     required BuildContext context,
//     required IconData icon,
//     required String label,
//     required DateTime? date,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color:
//             date != null ? color.withOpacity(0.5) : Colors.grey.shade300,
//             width: 2,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     date == null
//                         ? "select_date".tr
//                         : "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
//                     style: TextStyle(
//                       color:
//                       date != null ? Colors.black87 : Colors.grey.shade400,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: Colors.grey.shade400,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   int _calculateDays(DateTime from, DateTime to) {
//     return to.difference(from).inDays + 1;
//   }
//
//   // Add this to your floating action button or main action area
//   Widget _buildFloatingActionButton() {
//     return FloatingActionButton.extended(
//       onPressed: () => controller.navigateToAddNewCustomer(),
//       backgroundColor: AppColors.tealColor,
//       icon: Icon(Icons.person_add),
//       label: Text('Add Customer'),
//     );
//   }
//
//
//   Widget buildDrawer() {
//     return SafeArea(
//       child: Drawer(
//         child: Column(
//           children: [
//             // Drawer Header with User & Company Info
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.tealColor,
//                     AppColors.tealColor.withOpacity(0.7)
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Obx(() => Container(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // User Info Row
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CircleAvatar(
//                           radius: 25,
//                           backgroundColor: Colors.white.withOpacity(0.3),
//                           child: Icon(
//                             Icons.person,
//                             size: 28,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 controller.userName.value.isNotEmpty
//                                     ? controller.userName.value
//                                     : 'User',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(height: 2),
//                               Text(
//                                 controller.userEmail.value,
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.9),
//                                   fontSize: 12,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 12),
//
//                     // Company Info Section
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(6),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.3),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.business,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   controller.companyName.isNotEmpty
//                                       ? controller.companyName
//                                       : "No Company Selected",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 if (controller.hasMultipleCompanies.value)
//                                   GestureDetector(
//                                     onTap: controller.showCompanySwitcher,
//                                     child: Container(
//                                       margin: EdgeInsets.only(top: 2),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Text(
//                                             "Switch Company",
//                                             style: TextStyle(
//                                               color: Colors.white.withOpacity(0.8),
//                                               fontSize: 10,
//                                             ),
//                                           ),
//                                           SizedBox(width: 4),
//                                           Icon(
//                                             Icons.swap_horiz,
//                                             color: Colors.white.withOpacity(0.8),
//                                             size: 12,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//             ),
//
//             // 📋 Drawer Menu Items
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.only(top: 8, bottom: 20),
//                 children: [
//                   // 📦 Inventory Management Submenu (Only for Trading)
//                   if (AppConstants.businessType == "Trading")
//                     _buildExpansionTile(
//                       icon: Icons.inventory_2,
//                       iconColor: Colors.blue.shade600,
//                       title: "purchase".tr,
//                       children: [
//                         _buildSubMenuItem(
//                           icon: Icons.shopping_cart,
//                           iconColor: Colors.blue.shade700,
//                           title: "purchase".tr,
//                           onTap: () {
//                             Get.back();
//                             controller.navigateToInventory();
//                           },
//                         ),
//                         _buildSubMenuItem(
//                           icon: Icons.list_alt,
//                           iconColor: Colors.blue.shade700,
//                           title: "Purchase List",
//                           onTap: () {
//                             Get.back();
//                             controller.navigateToPurchaseList();
//                           },
//                         ),
//                       ],
//                     ),
//
//                   // 📋 Sales & Orders Submenu
//                   _buildExpansionTile(
//                     icon: Icons.receipt_long,
//                     iconColor: Colors.purple.shade600,
//                     title: "sales".tr,
//                     children: [
//                       // ✅ Challans - Only for Trading
//                       if (AppConstants.businessType == "Trading")
//                         _buildSubMenuItem(
//                           icon: Icons.note_alt,
//                           iconColor: Colors.purple.shade700,
//                           title: "challans".tr,
//                           onTap: () {
//                             Get.back();
//                             controller.navigateToChallanList();
//                           },
//                         ),
//                       // ✅ Invoice - Always visible
//                       _buildSubMenuItem(
//                         icon: Icons.receipt,
//                         iconColor: Colors.purple.shade700,
//                         title: "invoice".tr,
//                         onTap: () {
//                           Get.back();
//                           controller.navigateToInvoiceList();
//                         },
//                       ),
//                       // ✅ Quotations - Always visible
//                       _buildSubMenuItem(
//                         icon: Icons.request_quote,
//                         iconColor: Colors.purple.shade700,
//                         title: "quotations".tr,
//                         onTap: () {
//                           Get.back();
//                           controller.navigateToQuotList();
//                         },
//                       ),
//                     ],
//                   ),
//
//                   // 📊 Stock Report (Only for Trading)
//                   if (AppConstants.businessType == "Trading")
//                     _buildMenuItem(
//                       icon: Icons.assessment,
//                       iconColor: Colors.purple.shade600,
//                       title: "Stock Report",
//                       onTap: () {
//                         Get.back();
//                         controller.navigateToStockReport();
//                       },
//                     ),
//
//                   // 👥 Customers (Direct Item - Always visible)
//                   _buildMenuItem(
//                     icon: Icons.people,
//                     iconColor: Colors.orange.shade600,
//                     title: "customers".tr,
//                     onTap: () {
//                       Get.back();
//                       controller.navigateToCustomerList();
//                     },
//                   ),
//
//                   // 💰 Payment (Direct Item - Always visible)
//                   _buildMenuItem(
//                     icon: Icons.account_balance_wallet,
//                     iconColor: Colors.indigo.shade600,
//                     title: "payment".tr,
//                     onTap: () {
//                       Get.back();
//                       controller.navigateToPaymentDetails();
//                     },
//                   ),
//
//                   // ━━━━━━━━━━━━━━━━━━━━━
//                   Divider(height: 32, thickness: 1),
//
//                   // ⚙️ Settings Section Header
//                   _buildSectionHeader("settings".tr),
//
//                   // 🔹 Challan Toggle (Only for Trading)
//                   if (AppConstants.businessType == "Trading")
//                     Obx(() => _buildSwitchTile(
//                       icon: Icons.list_alt,
//                       iconColor: Colors.green.shade600,
//                       title: "enable_challan".tr,
//                       value: AppConstants.isChallan.value,
//                       activeColor: Colors.green.shade600,
//                       onChanged: (value) async {
//                         await controller.updateCompanyPreference(
//                             'isChallanEnabled', value);
//                       },
//                     )),
//
//
//                   // 🌐 Language Toggle (Always visible)
//                   Obx(() => _buildSwitchTile(
//                     icon: Icons.language,
//                     iconColor: Colors.deepPurple.shade600,
//                     title: 'enable_gujarati'.tr,
//                     value: AppConstants.isGujarati.value,
//                     activeColor: Colors.deepPurple.shade600,
//                     onChanged: (value) async {
//                       await controller.updateLanguagePreference(value);
//                     },
//                   )),
//
//                   // ━━━━━━━━━━━━━━━━━━━━━
//                   Divider(height: 32, thickness: 1),
//
//                   // 🏢 Company Management Section Header
//                   _buildSectionHeader("company_management".tr),
//
//                   // Switch Company (Conditional)
//                   if (controller.hasMultipleCompanies.value)
//                     _buildMenuItem(
//                       icon: Icons.swap_horiz,
//                       iconColor: Colors.indigo.shade600,
//                       title: "Switch Company",
//                       onTap: () {
//                         Get.back();
//                         controller.showCompanySwitcher();
//                       },
//                     ),
//
//                   // Edit Company
//                   _buildMenuItem(
//                     icon: Icons.business,
//                     iconColor: Colors.teal.shade600,
//                     title: "edit_company".tr,
//                     onTap: () {
//                       final data = controller.currentCompany.value;
//                       if (data != null && controller.companyId.value.isNotEmpty) {
//                         Get.back();
//                         controller.navigateToEditCompany(
//                             data, controller.companyId.value);
//                       } else {
//                         Get.snackbar(
//                           "Error",
//                           "No active company found to edit.",
//                           snackPosition: SnackPosition.BOTTOM,
//                           backgroundColor: Colors.red.shade100,
//                           colorText: Colors.red.shade800,
//                         );
//                       }
//                     },
//                   ),
//
//                   // ━━━━━━━━━━━━━━━━━━━━━
//                   Divider(height: 32, thickness: 1),
//
//                   // 🚪 Logout
//                   _buildMenuItem(
//                     icon: Icons.logout,
//                     iconColor: Colors.red.shade600,
//                     title: "logout".tr,
//                     titleStyle: TextStyle(
//                       color: Colors.red.shade700,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     onTap: () {
//                       Get.dialog(
//                         AlertDialog(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           title: Row(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.shade50,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Icon(Icons.logout,
//                                     color: Colors.red.shade600, size: 24),
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 "confirm_logout".tr,
//                                 style: TextStyle(fontSize: 18),
//                               ),
//                             ],
//                           ),
//                           content: Text(
//                             "logout_message".tr,
//                             style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
//                           ),
//                           actions: [
//                             TextButton(
//                               child: Text(
//                                 "cancel".tr,
//                                 style: TextStyle(
//                                   color: Colors.grey.shade600,
//                                   fontSize: 15,
//                                 ),
//                               ),
//                               onPressed: () => Get.back(),
//                             ),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red.shade600,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 24, vertical: 12),
//                               ),
//                               child: Text("logout".tr,
//                                   style: TextStyle(fontSize: 15)),
//                               onPressed: () async {
//                                 Get.back();
//                                 await controller.logout();
//                               },
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//
//                   SizedBox(height: 20),
//
//                   // Replace the version section with this minimal version:
//                   Container(
//                     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         top: BorderSide(color: Colors.grey.shade300, width: 1),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'invoice_sathi'.tr,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade700,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         Obx(() => Text(
//                           'v${controller.appVersion.value}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         )),
//                       ],
//                     ),
//                   ),
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// // 🎨 HELPER WIDGETS (Keep all the existing helper methods)
// // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//   /// Section Header
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
//       child: Text(
//         title.toUpperCase(),
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey.shade600,
//           letterSpacing: 1.2,
//         ),
//       ),
//     );
//   }
//
//   /// Expansion Tile (Submenu)
//   Widget _buildExpansionTile({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Theme(
//       data: ThemeData(
//         dividerColor: Colors.transparent,
//       ),
//       child: ExpansionTile(
//         leading: Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: iconColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: iconColor, size: 22),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade800,
//           ),
//         ),
//         iconColor: AppColors.tealColor,
//         collapsedIconColor: Colors.grey.shade500,
//         tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         childrenPadding: EdgeInsets.only(left: 16, bottom: 8),
//         children: children,
//       ),
//     );
//   }
//
//   /// Sub Menu Item (Inside Expansion Tile)
//   Widget _buildSubMenuItem({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       contentPadding: EdgeInsets.only(left: 60, right: 16),
//       leading: Icon(icon, color: iconColor, size: 20),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: 14,
//           color: Colors.grey.shade700,
//         ),
//       ),
//       dense: true,
//       visualDensity: VisualDensity.compact,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       onTap: onTap,
//     );
//   }
//
//   /// Direct Menu Item
//   Widget _buildMenuItem({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required VoidCallback onTap,
//     TextStyle? titleStyle,
//   }) {
//     return ListTile(
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       leading: Container(
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: iconColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, color: iconColor, size: 22),
//       ),
//       title: Text(
//         title,
//         style: titleStyle ??
//             TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade800,
//             ),
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       onTap: onTap,
//     );
//   }
//
//   /// Switch Toggle Item
//   Widget _buildSwitchTile({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required bool value,
//     required Color activeColor,
//     required Function(bool) onChanged,
//   }) {
//     return ListTile(
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       leading: Container(
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: iconColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, color: iconColor, size: 22),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//           color: Colors.grey.shade800,
//         ),
//       ),
//       trailing: Switch(
//         value: value,
//         onChanged: onChanged,
//         activeColor: Colors.white,
//         activeTrackColor: activeColor,
//         inactiveThumbColor: Colors.white,
//         inactiveTrackColor: Colors.grey.shade400,
//         thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
//           if (states.contains(WidgetState.selected)) {
//             return Icon(Icons.check, color: activeColor, size: 16);
//           }
//           return Icon(Icons.close, color: Colors.grey, size: 16);
//         }),
//       ),
//     );
//   }
// }



// class DashboardShimmer extends StatelessWidget {
//   const DashboardShimmer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Top banner
//           _shimmerBox(height: 100, width: double.infinity, borderRadius: 15),
//
//           const SizedBox(height: 20),
//
//           // Statistics cards row
//           Row(
//             children: [
//               Expanded(child: _shimmerBox(height: 100, borderRadius: 12)),
//               const SizedBox(width: 10),
//               Expanded(child: _shimmerBox(height: 100, borderRadius: 12)),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           // Quick actions
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 2.2,
//             ),
//             itemCount: 4,
//             itemBuilder: (_, __) => _shimmerBox(borderRadius: 12),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Chart placeholders
//           Row(
//             children: [
//               Expanded(child: _shimmerBox(height: 200, borderRadius: 12)),
//               const SizedBox(width: 10),
//               Expanded(child: _shimmerBox(height: 200, borderRadius: 12)),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           // Recent invoices list
//           Column(
//             children: List.generate(
//               3,
//                   (_) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: _shimmerBox(height: 60, borderRadius: 12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _shimmerBox({double height = 80, double? width, double borderRadius = 8}) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(borderRadius),
//         ),
//       ),
//     );
//   }
// }


class SubscriptionDialog extends StatelessWidget {
  const SubscriptionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium,
                  size: 50,
                  color: Colors.amber.shade300,
                ),
              ),

              SizedBox(height: 20),

              // Title with gradient text
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.amber.shade300, Colors.amber.shade100],
                ).createShader(bounds),
                child: Text(
                  'Premium Access Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 15),

              // Message
              Text(
                'Your trial period has ended. To continue enjoying all premium features, please contact your authorized representative.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),

              SizedBox(height: 25),

              // Contact card
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildContactInfo(Icons.person, 'Authorized Representative', 'Inteligent Tech'),
                    SizedBox(height: 12),
                    _buildContactInfo(Icons.phone, 'Phone No.', '+91 9512359792'),
                    SizedBox(height: 12),
                    _buildContactInfo(Icons.email, 'Email', 'info@intelligenttech.in'),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Action button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // // Copy phone number to clipboard
                    // Clipboard.setData(ClipboardData(text: '+1 (555) 123-4567'));
                    //
                    // // Show confirmation with GetX
                    // Get.snackbar(
                    //   'Copied!',
                    //   'Phone number copied to clipboard',
                    //   snackPosition: SnackPosition.BOTTOM,
                    //   backgroundColor: Colors.green.shade600,
                    //   colorText: Colors.white,
                    //   borderRadius: 10,
                    //   margin: EdgeInsets.all(15),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade500,
                    foregroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contact_phone, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Contact Representative',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.amber.shade300,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}