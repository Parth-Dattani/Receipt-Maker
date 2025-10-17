import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';

class InvoiceStatusChart extends GetView<DashboardController> {
  static const pageId = "/InvoiceStatusChart";

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 🔹 Ensure we always have data to display
      final chartData = controller.invoiceStatusData.isEmpty
          ? [
        ChartData("Paid", 0.0, Colors.green),
        ChartData("Pending", 0.0, Colors.orange),
        ChartData("Overdue", 0.0, Colors.red),
      ]
          : controller.invoiceStatusData;

      return Container(
        height: 220,
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
                'invoice_status'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: chartData.isEmpty
                    ? Center(
                  child: Text(
                    'no_data_available'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                )
                    : Column(
                  children: chartData.map((data) {
                    String extraText = "";

                    // 🔹 Use translated labels for comparison
                    if (data.label == "Pending") {
                      extraText = "₹${controller.pendingAmount.value.toStringAsFixed(2)}";
                    } else if (data.label == "Overdue") {
                      extraText = "₹${controller.overdueAmount.value.toStringAsFixed(2)}";
                    } else if (data.label == "Paid") {
                      extraText = "₹${controller.calculatePaidAmount().toStringAsFixed(2)}";
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: data.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data.label.tr, // 🔹 Apply translation
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                data.value.toInt().toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: data.value == 0
                                      ? Colors.grey.shade400
                                      : Colors.black87,
                                ),
                              ),
                              /// Optional: Show amount
                              // if (extraText.isNotEmpty && data.value > 0)
                              //   Text(
                              //     extraText,
                              //     style: TextStyle(
                              //       fontSize: 11,
                              //       color: Colors.grey.shade600,
                              //     ),
                              //   ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
