import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:GetYourInvoice/constant/app_constant.dart';
import 'package:GetYourInvoice/constant/constant.dart';
import 'package:GetYourInvoice/controller/controller.dart';
import 'package:GetYourInvoice/screen/screen.dart';
import 'package:GetYourInvoice/screen/setting/setting_screen.dart';
import 'package:GetYourInvoice/screen/payment/payment_details_screen.dart';
import 'package:GetYourInvoice/utils/financial_year_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/common/in_app_webview_screen.dart';
import 'logout_confirm_dialog.dart';

/// Shared left sidebar for web. Shows on every screen when kIsWeb.
/// [currentRoute] is used to highlight the active menu item (e.g. CustomerListScreen.pageId).
class WebAppSidebar extends GetView<DashboardController> {
  final String? currentRoute;

  const WebAppSidebar({super.key, this.currentRoute});

  bool _isActive(String route) =>
      currentRoute != null && currentRoute == route;

  bool _isSalesActive() =>
      currentRoute != null &&
      (currentRoute == InvoiceListScreen.pageId ||
          currentRoute == ChallanListScreen.pageId ||
          currentRoute == QuotationListScreen.pageId);

  bool _isPurchaseActive() =>
      currentRoute != null &&
      (currentRoute == PurchaseEntryScreen.pageId ||
          currentRoute == PurchaseListScreen.pageId);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tealColor,
      child: Container(
        width: 250,
        color: AppColors.tealColor,
        child: Column(
        children: [
          Container(
            height: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.dashboard_customize, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Text('Invoice Sathi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Obx(() {
                  final auth = Get.find<AuthController>();
                  final fy = auth.activeFyValue.value.isNotEmpty
                      ? auth.activeFyValue.value
                      : (AppConstants.activeFy.isNotEmpty ? AppConstants.activeFy : FinancialYearHelper.currentFy());
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      fy,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: false,
              children: [
                _buildMenuItem(Icons.dashboard, "Dashboard", _isActive(DashboardScreen.pageId), () => Get.offAllNamed(DashboardScreen.pageId)),
                if (AppConstants.businessType == "Trading")
                  Obx(() => AppConstants.enablePurchaseFeature.value
                      ? _buildExpansionTile(
                          icon: Icons.shopping_cart,
                          title: "Purchase",
                          isExpanded: _isPurchaseActive(),
                          children: [
                            _buildSubMenuItem(Icons.shopping_cart, "Purchase", () => controller.navigateToInventory()),
                            _buildSubMenuItem(Icons.list_alt, "Purchase List", () => controller.navigateToPurchaseList()),
                          ],
                        )
                      : const SizedBox.shrink()),
                _buildExpansionTile(
                  icon: Icons.receipt_long,
                  title: "Sales",
                  isExpanded: _isSalesActive(),
                  children: [
                    if (AppConstants.businessType == "Trading")
                      _buildSubMenuItem(Icons.request_quote, "Quotations", () => controller.navigateToQuotList()),
                    if (AppConstants.businessType == "Trading")
                      _buildSubMenuItem(Icons.note_alt, "Challans", () => controller.navigateToChallanList()),
                    _buildSubMenuItem(Icons.receipt, "Invoice", () => controller.navigateToInvoiceList()),
                  ],
                ),
                if (AppConstants.businessType == "Trading")
                  _buildMenuItem(Icons.assessment, "Stock Report", _isActive(StockReportScreen.pageId), () => controller.navigateToStockReport()),
                _buildMenuItem(Icons.people, "customers".tr, _isActive(CustomerListScreen.pageId), () => controller.navigateToCustomerList()),
                Obx(() => AppConstants.enablePaymentReceiptFeature.value
                    ? _buildMenuItem(Icons.payment, "payment".tr, _isActive(PaymentDetailsScreen.pageId), () => controller.navigateToPaymentDetails())
                    : const SizedBox.shrink()),
                // ✅ NEW — payment item ની નીચે
                Obx(() => AppConstants.enableCustomerOrderFeature.value
                    ? _buildMenuItem(
                  Icons.receipt_long,
                  'Customer Orders',
                  _isActive(AdminOrdersScreen.pageId), // active highlight ✅
                      () => Get.toNamed(AdminOrdersScreen.pageId),
                )
                    : const SizedBox.shrink()
                ),
                const Divider(color: Colors.white24, height: 12),
                _buildSectionHeader("SETTINGS"),
                _buildAdminPanelTile(),
                _buildMenuItem(Icons.settings, "Settings", _isActive(SettingsScreen.pageId), () => Get.toNamed(SettingsScreen.pageId)),
                if (AppConstants.businessType == "Trading")
                  Obx(() => _buildSwitchTile(
                    icon: Icons.list_alt,
                    title: "enable_challan".tr,
                    value: AppConstants.isChallan.value,
                    activeColor: Colors.greenAccent,
                    onChanged: (value) async => await controller.updateCompanyPreference('isChallanEnabled', value),
                  )),
                Obx(() => _buildSwitchTile(
                  icon: Icons.language,
                  title: 'enable_gujarati'.tr,
                  value: AppConstants.isGujarati.value,
                  activeColor: Colors.deepPurpleAccent,
                  onChanged: (value) async => await controller.updateLanguagePreference(value),
                )),
                const Divider(color: Colors.white24, height: 12),
                _buildSectionHeader("COMPANY"),
                if (controller.hasMultipleCompanies.value)
                  _buildMenuItem(Icons.swap_horiz, "Switch Company", false, () => controller.showCompanySwitcher()),
                _buildMenuItem(Icons.business, "edit_company".tr, _isActive(CompanyRegistrationScreen.pageId), () {
                  final data = controller.currentCompany.value;
                  if (data != null) controller.navigateToEditCompany(data, controller.companyId.value);
                }),
                const Divider(color: Colors.white24, height: 12),
                _buildPrivacyPolicyTile(),
                _buildMenuItem(Icons.logout, "logout".tr, false, () {
                  Get.dialog(
                    LogoutConfirmDialog(
                      onConfirm: () => controller.logout(),
                    ),
                  );
                }),
                const Divider(color: Colors.white24, height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppConstants.appName, style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text('v${controller.appVersion.value}', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }

  /// Shows "Admin Panel" in web sidebar only when current user has isAdmin == true.
  Widget _buildAdminPanelTile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
        final isAdmin = snapshot.data!.data()?['isAdmin'] == true;
        if (!isAdmin) return const SizedBox.shrink();
        return _buildMenuItem(
          Icons.security,
          'Admin Panel',
          false,
          () => Get.to(() => AdminPanelScreen()),
        );
      },
    );
  }

  Widget _buildPrivacyPolicyTile() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.privacy_tip_outlined, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Text('Privacy Policy', style: TextStyle(color: Colors.white70, fontSize: 13.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required List<Widget> children,
  }) {
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          leading: Icon(icon, color: Colors.white70, size: 20),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13.5, fontWeight: FontWeight.w500),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(left: 52, right: 20, top: 8, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white60, size: 18),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color activeColor,
    required Function(bool) onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13.5))),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: activeColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
