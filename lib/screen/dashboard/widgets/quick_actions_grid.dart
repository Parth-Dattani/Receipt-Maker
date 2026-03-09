import 'package:GetYourInvoice/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';

class QuickActionsGrid extends GetView<DashboardController> {
  static const pageId = "/QuickActionsGrid";

  @override
  Widget build(BuildContext context) {
    // 1. Detect if we are on Web (Screen > 900)
    bool isWeb = MediaQuery.of(context).size.width > 900;

    // 2. Configure Columns: Mobile = 4 Columns | Web = 2 Columns
    int crossAxisCount = isWeb ? 2 : 4;

    // 3. Adjust Aspect Ratio - More compact on web to reduce vertical space
    double aspectRatio = isWeb ? 1.6 : 0.9;

    // 4. Reduce spacing on web to minimize padding
    double mainAxisSpacing = isWeb ? 8 : 10;
    double crossAxisSpacing = isWeb ? 8 : 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // Only show the header title on Mobile.
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
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          padding: EdgeInsets.zero,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isWeb ? 10 : 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isWeb ? 24 : 20),
            ),
            SizedBox(height: isWeb ? 10 : 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 8.0 : 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isWeb ? 13 : 10,
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