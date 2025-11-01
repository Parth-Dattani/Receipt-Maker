import 'package:demo_prac_getx/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';

class QuickActionsGrid extends GetView<DashboardController> {
  static const pageId = "/QuickActionsGrid";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildActionCard(
              icon: Icons.add_circle,
              label: 'new_invoice'.tr,
              color: Colors.blue,
              onTap: controller.navigateToCreateInvoice,
            ),

            if (AppConstants.isChallan.value && AppConstants.businessType == "Trading")
              _buildActionCard(
                icon: Icons.list_alt,
                label: 'new_challan'.tr,
                color: Colors.green,
                onTap: controller.navigateToNewChallan,
              ),
            _buildActionCard(
              icon: Icons.people,
              label: 'customers'.tr,
              color: Colors.purple,
              onTap: controller.navigateToCustomers,
            ),
            _buildActionCard(
              icon: Icons.production_quantity_limits,
              label: 'items'.tr,
              color: Colors.orange,
              onTap: controller.navigateToItems,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
