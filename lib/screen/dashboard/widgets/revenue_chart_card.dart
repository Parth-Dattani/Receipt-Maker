import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../controller/controller.dart';
import '../../../model/model.dart';

class RevenueChartCard extends GetView<DashboardController> {
  static const pageId = "/RevenueChartCard";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  majorGridLines: MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  numberFormat: NumberFormat.compact(),
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey.shade100,
                  ),
                ),
                /// CORRECTED: Use CartesianSeries instead of ChartSeries
                // series: <CartesianSeries<RevenueData, String>>[
                //   LineSeries<RevenueData, String>(
                //     dataSource: controller.revenueData,
                //     xValueMapper: (RevenueData data, _) => data.month,
                //     yValueMapper: (RevenueData data, _) => data.revenue,
                //     color: Colors.blue,
                //     width: 3,
                //     markerSettings: MarkerSettings(isVisible: true),
                //   )
                // ],
                // Replace the series section with this:
                series: <CartesianSeries<RevenueData, String>>[
                  ColumnSeries<RevenueData, String>(
                    dataSource: controller.revenueData,
                    xValueMapper: (RevenueData data, _) => data.month,
                    yValueMapper: (RevenueData data, _) => data.revenue,
                    color: Colors.blue,
                    width: 0.6,
                    borderRadius: BorderRadius.circular(4),
                  )
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueData {
  final String month;
  final double revenue;
  final int year;

  RevenueData({
    required this.month,
    required this.revenue,
    required this.year,
  });
}

