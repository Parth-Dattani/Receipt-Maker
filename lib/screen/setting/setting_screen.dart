import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/app_colors.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../utils/financial_year_helper.dart';

class SettingsScreen extends GetView<SettingsController> {
  static const String pageId = '/SettingsScreen';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: _buildFinancialYearSettings(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                  'Financial Year',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Each year has a separate Google Sheet',
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
