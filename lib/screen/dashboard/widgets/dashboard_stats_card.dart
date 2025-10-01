import 'package:demo_prac_getx/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';

class DashboardStatsCard extends GetView<DashboardController> {
 static const pageId = "/DashboardStatsCard";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Revenue Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Revenue',
                value: '₹${AppUtil.formatCurrency(controller.totalRevenue.value)}',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: 'Pending Amount',
                value: '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}',
                icon: Icons.pending,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Invoice Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Invoices',
                value: '${controller.invoiceList.length}',
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: 'Overdue',
                value: '${controller.overdueAmount.value}',
                icon: Icons.warning,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
