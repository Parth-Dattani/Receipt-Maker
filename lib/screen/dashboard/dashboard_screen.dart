import 'package:GetYourInvoice/constant/app_constant.dart' show AppConstants;
import 'package:GetYourInvoice/screen/dashboard/widgets/widgets.dart';
import 'package:GetYourInvoice/widgets/web_app_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../utils/calculations.dart';
import '../../widgets/account_status_wrapper.dart';
import '../screen.dart';
import '../setting/setting_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../common/in_app_webview_screen.dart';


class DashboardScreen extends GetView<DashboardController> {
  static const String pageId = '/dashboard';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountStatusWrapper(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On website (kIsWeb): always use web layout so left drawer/sidebar is always visible
          // On mobile app: use web layout only when width > 900
          if (kIsWeb || constraints.maxWidth > 900) {
            return _buildWebLayout(context);
          }
          return _buildMobileLayout(context);
        },
      ),
    );
  }

  Widget _buildBackgroundWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppColors.customeBackground,
      child: SafeArea(child: child), // SafeArea aahi muki devu vadhare saru
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
          icon: const Icon(Icons.menu),
        ),
        title: Text('invoice_sathi'.tr),
        backgroundColor: AppColors.appTheame,
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
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshDashboard,
          )),
        ],
      ),
      body: _buildBackgroundWrapper(
        child: SafeArea(
          child: Obx(() {
            if (controller.showInitialShimmer) {
              return const DashboardShimmer();
            }
            return RefreshIndicator(
              onRefresh: () async => await controller.refreshDashboard(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeBanner(),
                    const SizedBox(height: 16),

                    _buildCashBoxCard(),
                    const SizedBox(height: 20),

                    // Statistics Cards
                    DashboardStatsCard(),
                    const SizedBox(height: 20),

                    // Quick Actions
                    QuickActionsGrid(),
                    const SizedBox(height: 20),

                    // ✅ ROW 1: Invoice Status & Purchase Status
                    IntrinsicHeight( // આનાથી બંને કાર્ડની હાઈટ સરખી થશે
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Invoice Status
                          Expanded(
                            child: _buildInvoiceStatusCard(),
                          ),
                          AppConstants.businessType == "Trading"
                          ? const SizedBox(width: 12) : Container(),
                          // Purchase Status
                          AppConstants.businessType == "Trading"
                          ? Expanded(
                            child: _buildPurchaseStatusCard(),
                          ) : Container(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ ROW 2: Summary Report & Export Data
                    Row(
                      children: [
                        // Summary Report
                        Expanded(
                          child: _buildMobileReportCard(
                            icon: Icons.summarize,
                            title: "Summary Report",
                            subtitle: "Monthly stats",
                            color: Colors.teal,
                            onTap: () => showReportDialog(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Export Data
                        Expanded(
                          child: _buildMobileReportCard(
                            icon: Icons.file_download,
                            title: "Export Data",
                            subtitle: "Excel format",
                            color: Colors.green,
                            onTap: () => showExportDialog(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Recent Invoices
                    RecentInvoicesCard(),
                    const SizedBox(height: 80), // Bottom padding
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      drawer: buildDrawer(),
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Vertical Cards) - COMPACT VERSION
  // ===========================================================================
// Updated _buildWebLayout method - Replace in DashboardScreen
// Updated _buildWebLayout method - Replace in DashboardScreen


  // Updated _buildWebLayout method - Complete restructure

// Updated _buildWebLayout method - Complete restructure

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildBackgroundWrapper(
        child: Row(
          children: [
            // 1. Shared sidebar (same on every web screen)
            WebAppSidebar(currentRoute: DashboardScreen.pageId),

            // 2. Main Content
            Expanded(
              child: Column(
                children: [
                  // Header
                  _buildWebHeaderWithWelcome(),

                  // Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 0),
                      child: Obx(() {
                        if (controller.showInitialShimmer) {
                          return const DashboardShimmer(isWeb: true);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ------------------------------------------------
                                // LEFT COLUMN - Main Content (Flex 3)
                                // ------------------------------------------------
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      // 1. Financial Metrics
                                      _buildFinancialMetricsWithStatus(),

                                      const SizedBox(height: 16),

                                      // 2. Recent Invoices (Removed Status Cards from here)
                                      RecentInvoicesCard(),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // ------------------------------------------------
                                // RIGHT COLUMN - Sidebar Widgets (Flex 1)
                                // ------------------------------------------------
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      // 1. Quick Actions
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: QuickActionsGrid(),
                                      ),

                                      const SizedBox(height: 16),

                                      // 2. Invoice Status Card (Text Based)
                                      _buildInvoiceStatusCard(),

                                      const SizedBox(height: 16),

                                      // ✅ 3. NEW: Purchase Status Card (Added Below Invoice Status)
                                      _buildPurchaseStatusCard(),

                                      const SizedBox(height: 16),

                                      // 4. Reports
                                      _buildWebReportCard(
                                        icon: Icons.summarize,
                                        title: "Summary Report",
                                        subtitle: "Get monthly summary",
                                        onTap: () => showReportDialog(context),
                                      ),

                                      const SizedBox(height: 12),

                                      // 5. Export Data
                                      _buildWebReportCard(
                                        icon: Icons.file_download,
                                        title: "Export Data",
                                        subtitle: "Excel format",
                                        onTap: () => showExportDialog(context),
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
      ),
    );
  }

// NEW: Financial Metrics WITH Invoice Status in 2-column layout
  // that you're already using for Sales, Purchase, etc.

  Widget _buildFinancialMetricsWithStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Web: Today's Collection above Financial Metrics
        _buildCashBoxCard(isWeb: true),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Financial Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        // Row 1: Sales, To Receive, Invoices
        Row(
          children: [
            Expanded(child: Obx(() => _buildCompactMetricCard(title: 'Sales', value: '₹${AppUtil.formatCurrency(controller.totalRevenue.value)}', icon: Icons.trending_up, iconColor: Colors.green, bgColor: Colors.green.shade50))),
            const SizedBox(width: 10),
            Expanded(child: Obx(() => _buildCompactMetricCard(title: 'To Receive', value: '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}', icon: Icons.download_rounded, iconColor: Colors.orange, bgColor: Colors.orange.shade50))),
            const SizedBox(width: 10),
            Expanded(child: Obx(() => _buildCompactMetricCard(title: 'Invoices', value: '${controller.invoiceList.length}', icon: Icons.receipt_rounded, iconColor: Colors.blue, bgColor: Colors.blue.shade50, badge: controller.overdueCount.value > 0 ? controller.overdueCount.value.toString() : null))),
          ],
        ),

        const SizedBox(height: 10),

        // Row 2: Purchase, To Pay, Orders
        Row(
          children: [
            Expanded(child: Obx(() => _buildCompactMetricCard(title: 'Purchase', value: '₹${AppUtil.formatCurrency(controller.totalPurchaseAmount.value)}', icon: Icons.shopping_cart, iconColor: Colors.red, bgColor: Colors.red.shade50))),
            const SizedBox(width: 10),
            Expanded(child: Obx(() => _buildCompactMetricCard(title: 'To Pay', value: '₹${AppUtil.formatCurrency(controller.pendingPurchaseAmount.value)}', icon: Icons.upload_rounded, iconColor: Colors.deepOrange, bgColor: Colors.deepOrange.shade50))),
            const SizedBox(width: 10),
            Expanded(child: Obx(() => _buildCompactMetricCard(title: 'Orders', value: '${controller.totalPurchases.value}', icon: Icons.shopping_bag_rounded, iconColor: Colors.indigo, bgColor: Colors.indigo.shade50, badge: controller.overduePurchases.value > 0 ? controller.overduePurchases.value.toString() : null))),
          ],
        ),
      ],
    );
  }



// Compact Metric Card
  Widget _buildCompactMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    String? badge,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badge != null ? Colors.red.shade200 : Colors.grey.shade200,
          width: badge != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

// Action Card for Summary/Export
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

// NEW: Financial Metrics in 3-column grid format
  Widget _buildFinancialMetricsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Financial Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        // Row 1: Sales, To Receive, Invoices
        Row(
          children: [
            Obx(() => _buildCompactMetricCard(
              title: 'Sales',
              value: '₹${AppUtil.formatCurrency(controller.totalRevenue.value)}',
              icon: Icons.trending_up,
              iconColor: Colors.green,
              bgColor: Colors.green.shade50,
            )),
            SizedBox(width: 14),
            Obx(() => _buildCompactMetricCard(
              title: 'To Receive',
              value: '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}',
              icon: Icons.download_rounded,
              iconColor: Colors.orange,
              bgColor: Colors.orange.shade50,
            )),
            SizedBox(width: 14),
            Obx(() => _buildCompactMetricCard(
              title: 'Invoices',
              value: '${controller.invoiceList.length}',
              icon: Icons.receipt_rounded,
              iconColor: Colors.blue,
              bgColor: Colors.blue.shade50,
              badge: controller.overdueCount.value > 0
                  ? controller.overdueCount.value.toString()
                  : null,
            )),
            Spacer(), // Push cards to the left
          ],
        ),

        SizedBox(height: 14),

        // Row 2: Purchase, To Pay, Orders
        Row(
          children: [
            Obx(() => _buildCompactMetricCard(
              title: 'Purchase',
              value: '₹${AppUtil.formatCurrency(controller.totalPurchaseAmount.value)}',
              icon: Icons.shopping_cart,
              iconColor: Colors.red,
              bgColor: Colors.red.shade50,
            )),
            SizedBox(width: 14),
            Obx(() => _buildCompactMetricCard(
              title: 'To Pay',
              value: '₹${AppUtil.formatCurrency(controller.pendingPurchaseAmount.value)}',
              icon: Icons.upload_rounded,
              iconColor: Colors.deepOrange,
              bgColor: Colors.deepOrange.shade50,
            )),
            SizedBox(width: 14),
            Obx(() => _buildCompactMetricCard(
              title: 'Orders',
              value: '${controller.totalPurchases.value}',
              icon: Icons.shopping_bag_rounded,
              iconColor: Colors.indigo,
              bgColor: Colors.indigo.shade50,
              badge: controller.overduePurchases.value > 0
                  ? controller.overduePurchases.value.toString()
                  : null,
            )),
            Spacer(), // Push cards to the left
          ],
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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


  // ===========================================================================
  // 🎨 WEB COMPONENTS
  // ==========================================================================

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

                if (AppConstants.businessType == "Trading")
                  _buildWebExpansionTile(
                    icon: Icons.shopping_cart,
                    title: "Purchase",
                    children: [
                      _buildWebSubMenuItem(Icons.shopping_cart, "Purchase", () => controller.navigateToInventory()),
                      _buildWebSubMenuItem(Icons.list_alt, "Purchase List", () => controller.navigateToPurchaseList()),
                    ],
                  ),

                // SALES SECTION (Expandable)
                _buildWebExpansionTile(
                  icon: Icons.receipt_long,
                  title: "Sales",
                  children: [
                    if (AppConstants.businessType == "Trading")
                      _buildWebSubMenuItem(Icons.request_quote, "Quotations", () => controller.navigateToQuotList()),
                      _buildWebSubMenuItem(Icons.note_alt, "Challans", () => controller.navigateToChallanList()),
                    _buildWebSubMenuItem(Icons.receipt, "Invoice", () => controller.navigateToInvoiceList()),

                  ],
                ),

                if (AppConstants.businessType == "Trading")
                  _buildWebMenuItem(Icons.assessment, "Stock Report", false, () => controller.navigateToStockReport()),

                _buildWebMenuItem(Icons.people, "customers".tr, false, () => controller.navigateToCustomerList()),
                _buildWebMenuItem(Icons.payment, "payment".tr, false, () => controller.navigateToPaymentDetails()),
                Obx(() => AppConstants.enableCustomerOrderFeature.value
                    ?_buildWebMenuItem(
                  Icons.receipt_long,
                  'Customer Orders',
                  false,
                      () => Get.toNamed(AdminOrdersScreen.pageId),
                )
                     : const SizedBox.shrink()
                ),

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

                const Divider(color: Colors.white24, height: 12),
                // Privacy Policy + Version (same as mobile drawer)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () async {
                          const url = 'https://drive.google.com/file/d/1hRCygh-bIP1rAJTgTI5cdmnt9eeZLtif/view?usp=drive_link';
                          if (kIsWeb) {
                            final uri = Uri.parse(url);
                            try {
                              await launchUrl(uri, mode: LaunchMode.platformDefault);
                            } catch (_) {
                              Get.snackbar('Error', 'Could not open Privacy Policy');
                            }
                          } else {
                            Get.to(() => InAppWebViewScreen(url: url, title: 'Privacy Policy'));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('Privacy Policy', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ),
                      ),
                      Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('invoice_sathi'.tr, style: TextStyle(color: Colors.white54, fontSize: 11)),
                          Text('v${controller.appVersion.value}', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      )),
                    ],
                  ),
                ),
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


  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.appTheame,
            AppColors.appTheame.withOpacity(0.7)
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

  Widget _buildWebHeaderWithWelcome() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right:16, top:10, bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tealColor,
            AppColors.tealColor.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // LEFT SIDE: Company Name + Tagline
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    controller.companyName.isNotEmpty
                        ? controller.companyName
                        : "No Company Selected",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(height: 6),
                  const Text(
                    "Here is what's happening with your business today.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT SIDE: Column with Name on top, Buttons below
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Row 1: User Name
                Obx(() => Text(
                  controller.userName.value.isNotEmpty
                      ? controller.userName.value
                      : 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                )),

                const SizedBox(height: 8),

                // Row 2: Refresh + Avatar (Horizontal)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                      onPressed: controller.refreshDashboard,
                      splashRadius: 20,
                      tooltip: 'Refresh Dashboard',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),

                    const SizedBox(width: 12),

                    PopupMenuButton<String>(
                      offset: Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      onSelected: (String value) {
                        if (value == 'logout') {
                          Get.dialog(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red.shade600),
                                  SizedBox(width: 12),
                                  Text("confirm_logout".tr),
                                ],
                              ),
                              content: Text("logout_message".tr),
                              actions: [
                                TextButton(
                                  child: Text("cancel".tr),
                                  onPressed: () => Get.back(),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                  ),
                                  onPressed: () async {
                                    Get.back();
                                    await controller.logout();
                                  },
                                  child: Text("logout".tr),
                                ),
                              ],
                            ),
                          );
                        } else if (value == 'edit_company') {
                          final data = controller.currentCompany.value;
                          if (data != null) {
                            controller.navigateToEditCompany(
                                data, controller.companyId.value);
                          }
                        } else if (value == 'switch_company') {
                          controller.showCompanySwitcher();
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        // User Info Header
                        PopupMenuItem<String>(
                          enabled: false,
                          child: Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.userName.value.isNotEmpty
                                    ? controller.userName.value
                                    : 'User',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                controller.userEmail.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.tealColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  controller.companyName.isNotEmpty
                                      ? controller.companyName
                                      : "No Company",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.tealColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ),
                        PopupMenuDivider(),

                        // Edit Company
                        PopupMenuItem<String>(
                          value: 'edit_company',
                          child: Row(
                            children: [
                              Icon(Icons.business, size: 20,
                                  color: Colors.grey.shade700),
                              SizedBox(width: 12),
                              Text("edit_company".tr),
                            ],
                          ),
                        ),

                        // Switch Company (if multiple companies)
                        if (controller.hasMultipleCompanies.value)
                          PopupMenuItem<String>(
                            value: 'switch_company',
                            child: Row(
                              children: [
                                Icon(Icons.swap_horiz, size: 20,
                                    color: Colors.grey.shade700),
                                SizedBox(width: 12),
                                Text("Switch Company"),
                              ],
                            ),
                          ),

                        PopupMenuDivider(),

                        // Logout
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20,
                                  color: Colors.red.shade600),
                              SizedBox(width: 12),
                              Text(
                                "logout".tr,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCashBoxCard({bool isWeb = false}) {
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    return Obx(() {
      final total = controller.todayCashAmount.value +
          controller.todayUpiAmount.value +
          controller.todayCardAmount.value;

      if (isWeb) {
        // Web: clean white card with teal accent to match dashboard
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.appTheame,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Collection",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.appTheame.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Profit: ₹${AppUtil.formatCurrency(controller.todayProfit.value)}",
                      style: TextStyle(
                        color: AppColors.tealColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "₹${AppUtil.formatCurrency(total)}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tealColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildBalancedBox("Cash", controller.todayCashAmount.value, Colors.green, isWeb: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBalancedBox("UPI", controller.todayUpiAmount.value, Colors.blue, isWeb: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBalancedBox("Card", controller.todayCardAmount.value, Colors.orange, isWeb: true)),
                ],
              ),
            ],
          ),
        );
      }

      // Mobile: original teal card
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.appTheame,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Collection",
                      style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8E6C9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Profit: ₹${AppUtil.formatCurrency(controller.todayProfit.value)}",
                    style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "₹${AppUtil.formatCurrency(total)}",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _buildBalancedBox("Cash", controller.todayCashAmount.value, Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildBalancedBox("UPI", controller.todayUpiAmount.value, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildBalancedBox("Card", controller.todayCardAmount.value, Colors.orange)),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBalancedBox(String label, double amount, Color iconColor, {bool isWeb = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 5, horizontal: isWeb ? 6 : 0),
      decoration: BoxDecoration(
        color: isWeb ? iconColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isWeb ? Border.all(color: iconColor.withOpacity(0.2)) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isWeb ? 8 : 6,
                height: isWeb ? 8 : 6,
                decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
              ),
              SizedBox(width: isWeb ? 6 : 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: isWeb ? 11 : 9,
                  fontWeight: FontWeight.w600,
                  color: isWeb ? Colors.grey.shade800 : Colors.black54,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 4 : 0),
          Text(
            "₹${AppUtil.formatCurrency(amount)}",
            style: TextStyle(
              fontSize: isWeb ? 12 : 11,
              fontWeight: FontWeight.bold,
              color: isWeb ? Colors.grey.shade900 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ New Widget: Invoice Status Card (Text Based)
  Widget _buildInvoiceStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Invoice Status",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Obx(() => _buildStatusRow(
            label: "Paid",
            count: controller.paidInvoices.value, // Using paidInvoices from controller
            color: Colors.green,
          )),
          const SizedBox(height: 8),

          Obx(() => _buildStatusRow(
            label: "Pending",
            count: controller.unpaidInvoices.value, // Using unpaidInvoices
            color: Colors.orange,
          )),
          const SizedBox(height: 8),

          Obx(() => _buildStatusRow(
            label: "Overdue",
            count: controller.overdueInvoices.value, // Using overdueInvoices
            color: Colors.red,
          )),
        ],
      ),
    );
  }

  // ✅ NEW WIDGET: Purchase Status Card (Same Design as Invoice Status)
  // ✅ Reused: Purchase Status Card
  Widget _buildPurchaseStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Purchase Status",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Obx(() => _buildStatusRow(
            label: "Paid",
            count: controller.paidPurchases.value,
            color: Colors.green,
          )),
          const SizedBox(height: 8),

          Obx(() => _buildStatusRow(
            label: "Pending",
            count: controller.pendingPurchases.value,
            color: Colors.orange,
          )),
          const SizedBox(height: 8),

          Obx(() => _buildStatusRow(
            label: "Overdue",
            count: controller.overduePurchases.value,
            color: Colors.red,
          )),
        ],
      ),
    );
  }

  // ✅ Helper: Mobile Report Card (Summary/Export)
  Widget _buildMobileReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
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

  // Helper Row Widget (જો તમારી પાસે પહેલેથી ન હોય તો આ પણ મૂકી દેજો)
  Widget _buildStatusRow({required String label, required int count, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Helper for Web Rows (No SizedBox needed, handled by spaceEvenly)
  List<Widget> _buildBreakdownRows() {
    return [
      Obx(() => _buildCollectionRow(color: Colors.green, label: "Cash", amount: controller.todayCashAmount.value, count: controller.todayCashInvoices.value)),
      Obx(() => _buildCollectionRow(color: Colors.blueAccent, label: "UPI", amount: controller.todayUpiAmount.value, count: controller.todayUpiInvoices.value)),
      Obx(() => _buildCollectionRow(color: Colors.orange, label: "Card", amount: controller.todayCardAmount.value, count: controller.todayCardInvoices.value)),
    ];
  }

  // Helper for Mobile Rows (Needs SizedBox)
  List<Widget> _buildBreakdownRows_MobileSpaced() {
    return [
      Obx(() => _buildCollectionRow(color: Colors.green, label: "Cash", amount: controller.todayCashAmount.value, count: controller.todayCashInvoices.value)),
      const SizedBox(height: 12),
      Obx(() => _buildCollectionRow(color: Colors.blueAccent, label: "UPI", amount: controller.todayUpiAmount.value, count: controller.todayUpiInvoices.value)),
      const SizedBox(height: 12),
      Obx(() => _buildCollectionRow(color: Colors.orange, label: "Card", amount: controller.todayCardAmount.value, count: controller.todayCardInvoices.value)),
    ];
  }

  // Helper widget for the rows (Square Icon + Text + Amount)
  Widget _buildCollectionRow({
    required Color color,
    required String label,
    required double amount,
    required int count,
  }) {
    return Row(
      children: [
        // Colored Square Indicator
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),

        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),

        const Spacer(),

        // Amount & Invoice Count
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "₹${AppUtil.formatCurrency(amount)}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // if (count > 0)
            //   Text(
            //     "$count invoices",
            //     style: TextStyle(
            //       fontSize: 10,
            //       color: Colors.grey.shade500,
            //     ),
            //   ),
          ],
        ),
      ],
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
                  colors: [AppColors.appTheame, AppColors.appTheame.withOpacity(0.7)],
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
                  _buildMenuItem(icon: Icons.people, iconColor: Colors.orange.shade600,
                      title:
                      AppConstants.businessType == "Trading" ?
                      "customers".tr :  "clients".tr, onTap: () { Get.back(); controller.navigateToCustomerList(); }),
                  _buildMenuItem(icon: Icons.account_balance_wallet, iconColor: Colors.indigo.shade600, title: "payment".tr, onTap: () { Get.back(); controller.navigateToPaymentDetails(); }),
                  Obx(() => AppConstants.enableCustomerOrderFeature.value
                      ?   _buildMenuItem(
                      icon: Icons.receipt_long,
                      iconColor: const Color(0xFF00897B),
                      title: 'Customer Orders',
                      onTap: () {
                        Get.back();
                        Get.toNamed(AdminOrdersScreen.pageId);
                      },
                    ) : const SizedBox.shrink()
                  ),
                  Divider(height: 32, thickness: 1),
                  _buildSectionHeader("settings".tr),
                  _buildMenuItem(icon: Icons.settings, iconColor: Colors.grey.shade700, title: "Settings", onTap: () { Get.back(); Get.toNamed(SettingsScreen.pageId); }),
                  _buildAdminPanelDrawerTile(),
                  if (AppConstants.businessType == "Trading")
                    Obx(() => _buildSwitchTile(icon: Icons.list_alt, iconColor: Colors.green.shade600, title: "enable_challan".tr, value: AppConstants.isChallan.value, activeColor: Colors.green.shade600, onChanged: (value) async { await controller.updateCompanyPreference('isChallanEnabled', value); })),
                  Obx(() => _buildSwitchTile(icon: Icons.language, iconColor: Colors.deepPurple.shade600, title: 'enable_gujarati'.tr, value: AppConstants.isGujarati.value, activeColor: Colors.deepPurple.shade600, onChanged: (value) async { await controller.updateLanguagePreference(value); })),
                  Divider(height: 32, thickness: 1),
                  _buildSectionHeader("company_management".tr),
                  if (controller.hasMultipleCompanies.value)
                    _buildMenuItem(icon: Icons.swap_horiz, iconColor: Colors.indigo.shade600, title: "Switch Company", onTap: () { Get.back(); controller.showCompanySwitcher(); }),
                  _buildMenuItem(icon: Icons.business, iconColor: Colors.teal.shade600, title: "edit_company".tr, onTap: () { final data = controller.currentCompany.value; if (data != null && controller.companyId.value.isNotEmpty) { Get.back(); controller.navigateToEditCompany(data, controller.companyId.value); } else { Get.snackbar("Error", "No active company found to edit."); } }),
                  Divider(height: 32, thickness: 1),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade600.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.privacy_tip_outlined, color: Colors.blue.shade600, size: 22)),
                    title: Text('Privacy Policy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onTap: () async {
                      Get.back();
                      const url = 'https://drive.google.com/file/d/1hRCygh-bIP1rAJTgTI5cdmnt9eeZLtif/view?usp=drive_link';
                      if (kIsWeb) {
                        try {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
                        } catch (_) {
                          Get.snackbar('Error', 'Could not open Privacy Policy');
                        }
                      } else {
                        Get.to(() => InAppWebViewScreen(url: url, title: 'Privacy Policy'));
                      }
                    },
                  ),
                  _buildMenuItem(icon: Icons.logout, iconColor: Colors.red.shade600, title: "logout".tr, titleStyle: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600), onTap: () { Get.dialog(AlertDialog(title: Row(children: [Icon(Icons.logout, color: Colors.red.shade600), SizedBox(width: 12), Text("confirm_logout".tr)]), content: Text("logout_message".tr), actions: [TextButton(child: Text("cancel".tr), onPressed: () => Get.back()), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600), onPressed: () async { Get.back(); await controller.logout(); }, child: Text("logout".tr))])); }),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1))),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('invoice_sathi'.tr, style: TextStyle(fontSize: 12)), Text('v${controller.appVersion.value}', style: TextStyle(fontSize: 12))])),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Web Expansion Tile for collapsible sections
  Widget _buildWebExpansionTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              fontWeight: FontWeight.w500
          ),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        children: children,
      ),
    );
  }

// Web Sub-menu item (indented under expansion tile)
  Widget _buildWebSubMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 52, right: 20, top: 8, bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white60, size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
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

  /// Shows "Admin Panel" tile only when current user's Firestore document has isAdmin == true.
  Widget _buildAdminPanelDrawerTile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
        final isAdmin = snapshot.data!.data()?['isAdmin'] == true;
        if (!isAdmin) return const SizedBox.shrink();
        return _buildMenuItem(
          icon: Icons.security,
          iconColor: Colors.amber.shade700,
          title: 'Admin Panel',
          onTap: () {
            Get.back();
            Get.to(() => AdminPanelScreen());
          },
        );
      },
    );
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