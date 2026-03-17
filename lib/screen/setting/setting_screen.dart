import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import '../../constant/app_colors.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../utils/financial_year_helper.dart';
import '../../widgets/web_screen_wrapper.dart';

class SettingsScreen extends GetView<SettingsController> {
  static const String pageId = '/SettingsScreen';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.tealColor, AppColors.tealColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLogoPosition(),
                        SizedBox(height: 20),
                        _buildInvoiceThemes(),
                        SizedBox(height: 20),
                        _buildFinancialYearSettings(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (kIsWeb) {
      return webScreenWrapper(currentRoute: SettingsScreen.pageId, child: content);
    }
    return content;
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Invoice themes & financial year',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPosition() {
    final settings = Get.find<SettingsController>();
    const positions = [
      {'id': 'Left', 'label': 'Left', 'subtitle': 'Logo on left, details right', 'icon': Icons.format_align_left},
      {'id': 'Center', 'label': 'Center', 'subtitle': 'Logo & details centered', 'icon': Icons.format_align_center},
      {'id': 'Right', 'label': 'Right', 'subtitle': 'Logo on right, details left', 'icon': Icons.format_align_right},
      {'id': 'TopLeft', 'label': 'Top Left', 'subtitle': 'Small logo top-left', 'icon': Icons.crop_square},
      {'id': 'TopCenter', 'label': 'Top Center', 'subtitle': 'Logo centered at top', 'icon': Icons.vertical_align_top},
    ];
    return _buildSettingsCard(
      icon: Icons.image_outlined,
      title: 'Company Logo Position',
      children: [
        Text(
          'Where to show your company logo on the invoice PDF.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        SizedBox(height: 16),
        Obx(() {
          if (settings.isLoadingLogoPosition.value) {
            return Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
          }
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: positions.map((p) {
              final id = p['id'] as String;
              final isSelected = settings.selectedLogoPosition.value == id;
              return InkWell(
                onTap: () => settings.updateLogoPosition(id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tealColor.withOpacity(0.12) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.tealColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(p['icon'] as IconData, size: 32, color: isSelected ? AppColors.tealColor : Colors.grey.shade600),
                          if (isSelected)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(color: AppColors.tealColor, shape: BoxShape.circle),
                                child: Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        p['label'] as String,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade800),
                      ),
                      SizedBox(height: 2),
                      Text(
                        p['subtitle'] as String,
                        style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildInvoiceThemes() {
    final settings = Get.find<SettingsController>();
    const themes = [
      {'id': 'Modern', 'label': 'Modern', 'subtitle': 'Teal, clean lines', 'icon': Icons.dashboard_rounded, 'color': Color(0xFF00897B)},
      {'id': 'Classic', 'label': 'Classic', 'subtitle': 'Maroon & beige', 'icon': Icons.receipt_long, 'color': Color(0xFF8B0000)},
      {'id': 'Minimal', 'label': 'Minimal', 'subtitle': 'Grey, simple', 'icon': Icons.filter_b_and_w, 'color': Color(0xFF424242)},
      {'id': 'Professional', 'label': 'Professional', 'subtitle': 'Blue, corporate', 'icon': Icons.business_center, 'color': Color(0xFF1565C0)},
      {'id': 'Elegant', 'label': 'Elegant', 'subtitle': 'Deep purple', 'icon': Icons.auto_awesome, 'color': Color(0xFF4527A0)},
    ];
    return _buildSettingsCard(
      icon: Icons.palette_outlined,
      title: 'Invoice Themes',
      children: [
        Text(
          'Choose how your invoice PDF looks. This applies when you print or share.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        SizedBox(height: 16),
        Obx(() {
          if (settings.isLoadingPdfTemplate.value) {
            return Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
          }
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: themes.map((t) {
              final id = t['id'] as String;
              final isSelected = settings.selectedPdfTemplate.value == id;
              return InkWell(
                onTap: () => settings.updatePdfTemplate(id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? (t['color'] as Color).withOpacity(0.12) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? (t['color'] as Color) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 48,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: (t['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(t['icon'] as IconData, size: 24, color: t['color'] as Color),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(color: AppColors.tealColor, shape: BoxShape.circle),
                                child: Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        t['label'] as String,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade800),
                      ),
                      SizedBox(height: 2),
                      Text(
                        t['subtitle'] as String,
                        style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildFinancialYearSettings() {
    final auth = Get.find<AuthController>();
    return _buildSettingsCard(
      icon: Icons.calendar_today,
      title: 'Financial Year',
      children: [
        Text(
          'Each financial year has a separate Google Sheet. Switch or add a new FY.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        SizedBox(height: 12),
        Obx(() {
          final activeFy = auth.activeFyValue.value;
          return Text(
            'Current: ${activeFy.isEmpty ? FinancialYearHelper.currentFy() : FinancialYearHelper.displayLabel(activeFy)}',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          );
        }),
        SizedBox(height: 12),
        Obx(() {
          final list = auth.fyList;
          if (list.isEmpty) return SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your financial years:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              SizedBox(height: 8),
              ...list.map((fy) => ListTile(
                title: Text(FinancialYearHelper.displayLabel(fy)),
                trailing: auth.activeFyValue.value == fy
                    ? Chip(label: Text('Active', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.tealColor)
                    : TextButton(
                        onPressed: () => auth.switchFinancialYear(fy),
                        child: Text('Use this year'),
                      ),
              )),
            ],
          );
        }),
        SizedBox(height: 12),
        Obx(() => auth.isLoadingFy.value
            ? Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
            : SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddNewFyDialog(auth),
                  icon: Icon(Icons.add),
                  label: Text('Add new financial year'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.tealColor,
                    side: BorderSide(color: AppColors.tealColor),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )),
      ],
    );
  }

  void _showAddNewFyDialog(AuthController auth) {
    final currentFy = AppConstants.activeFy.isNotEmpty ? AppConstants.activeFy : FinancialYearHelper.currentFy();
    final existingSet = auth.fyList.toSet();

    // Only next 3 years (current FY + next 2) can be created as new sheet
    final nextThreeFys = FinancialYearHelper.upcomingFyList(currentFy, count: 3);
    final availableFys = nextThreeFys.where((fy) => !existingSet.contains(fy)).toList();

    if (availableFys.isEmpty) {
      Get.snackbar('Info', 'You already have sheets for the next 3 years.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.tealColor),
            SizedBox(width: 10),
            Text('Create sheet for year'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a financial year to create a new Google Sheet (next 3 years only):',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              SizedBox(height: 12),
              ...availableFys.map((fy) {
                final isCurrent = fy == currentFy;
                final nextFy = FinancialYearHelper.nextFy(currentFy);
                final isNext = fy == nextFy;
                final subtitle = isCurrent ? 'Current year' : (isNext ? 'Next year' : 'Upcoming');
                return ListTile(
                  leading: Icon(isCurrent ? Icons.today : Icons.arrow_forward, color: AppColors.tealColor, size: 22),
                  title: Text(
                    FinancialYearHelper.displayLabel(fy),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    Get.back();
                    auth.addNewFinancialYearForFy(fy);
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
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
                  color: AppColors.tealColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.tealColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
