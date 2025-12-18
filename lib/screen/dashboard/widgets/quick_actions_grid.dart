import 'package:demo_prac_getx/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ensure imports match your project
// import 'package:invoice_sathi/controllers/dashboard_controller.dart';
// import 'package:invoice_sathi/utils/app_constants.dart';

class QuickActionsGrid extends GetView<DashboardController> {
  static const pageId = "/QuickActionsGrid";

  @override
  Widget build(BuildContext context) {
    // 1. Detect if we are on Web (Screen > 900)
    bool isWeb = MediaQuery.of(context).size.width > 900;

    // 2. Configure Columns based on your request:
    // Mobile = 4 Columns | Web = 2 Columns
    int crossAxisCount = isWeb ? 2 : 4;

    // 3. Adjust Aspect Ratio to prevent Overflow
    // Mobile (4 cols): Items are narrow, so we make them taller (0.75)
    // Web (2 cols): Standard ratio (0.9) to ensure text fits without overflow
    double aspectRatio = isWeb ? 0.9 : 0.70;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Only show the header title on Mobile.
        // On Web, the parent container already has a title, so we hide this to save space.
        if (!isWeb) ...[
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
        ],

        GridView.count(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: EdgeInsets.zero, // Remove default padding to fit better
          children: [
            _buildActionCard(
              icon: Icons.add_circle,
              label: 'new_invoice'.tr,
              color: Colors.blue,
              onTap: controller.navigateToCreateInvoice,
              isWeb: isWeb,
            ),

            if (AppConstants.isChallan.value && AppConstants.businessType == "Trading")
              _buildActionCard(
                icon: Icons.list_alt,
                label: 'new_challan'.tr,
                color: Colors.green,
                onTap: controller.navigateToNewChallan,
                isWeb: isWeb,
              ),
            _buildActionCard(
              icon: Icons.people,
              label: 'customers'.tr,
              color: Colors.purple,
              onTap: controller.navigateToCustomers,
              isWeb: isWeb,
            ),
            _buildActionCard(
              icon: Icons.production_quantity_limits,
              label: 'items'.tr,
              color: Colors.orange,
              onTap: controller.navigateToItems,
              isWeb: isWeb,
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
    required bool isWeb,
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
          mainAxisSize: MainAxisSize.min, // Fixes vertical overflow
          children: [
            Container(
              padding: EdgeInsets.all(isWeb ? 10 : 8), // Smaller padding on mobile
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isWeb ? 24 : 20), // Smaller icon on mobile
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2, // Allow text to wrap to 2 lines
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isWeb ? 12 : 10, // Smaller text on mobile to fit 4 cols
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}