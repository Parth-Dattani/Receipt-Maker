import 'package:GetYourInvoice/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';


///new No Duplication
class DashboardStatsCard extends GetView<DashboardController> {
  static const pageId = "/DashboardStatsCard";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ FINANCIAL METRICS
        _buildSectionTitle('Financial Metrics'),
        SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Obx(() => _buildModernCard(
                title: 'Sales',
                value: '₹${AppUtil.formatCurrency(controller.totalRevenue.value)}',
                icon: Icons.add_circle_outline,
                iconColor: Colors.green,
                bgColor: Colors.green.shade50,
              )),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildModernCard(
                title: 'Purchase',
                value: '₹${AppUtil.formatCurrency(controller.totalPurchaseAmount.value)}',
                icon: Icons.remove_circle_outline,
                iconColor: Colors.red,
                bgColor: Colors.red.shade50,
              )),
            ),
          ],
        ),

        SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Obx(() => _buildModernCard(
                title: 'To Receive',
                value: '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}',
                icon: Icons.download_rounded,
                iconColor: Colors.orange,
                bgColor: Colors.orange.shade50,
              )),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildModernCard(
                title: 'To Pay',
                value: '₹${AppUtil.formatCurrency(controller.pendingPurchaseAmount.value)}',
                icon: Icons.upload_rounded,
                iconColor: Colors.deepOrange,
                bgColor: Colors.deepOrange.shade50,
              )),
            ),
          ],
        ),

        SizedBox(height: 20),

        // ✅ TRANSACTIONS COUNT
        _buildSectionTitle('Transactions'),
        SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Obx(() => _buildCountCard(
                title: 'Invoices',
                count: controller.invoiceList.length,
                overdue: controller.overdueCount.value,
                icon: Icons.receipt_rounded,
                color: Colors.blue,
              )),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildCountCard(
                title: 'Orders',
                count: controller.totalPurchases.value,
                overdue: controller.overduePurchases.value,
                icon: Icons.shopping_bag_rounded,
                color: Colors.indigo,
              )),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Modern Financial Card
  Widget _buildModernCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Count Card
  Widget _buildCountCard({
    required String title,
    required int count,
    required int overdue,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: overdue > 0 ? Colors.red.shade200 : Colors.grey.shade200,
          width: overdue > 0 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: overdue > 0
                ? Colors.red.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (overdue > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: Colors.white,
                              size: 9,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '$overdue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
