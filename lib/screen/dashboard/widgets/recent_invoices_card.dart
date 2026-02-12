import 'package:demo_prac_getx/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';

class RecentInvoicesCard extends GetView<DashboardController> {
  static const pageId = "/RecentInvoicesCard";

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 12, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'recent_invoices'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                TextButton(
                  onPressed: controller.navigateToInvoiceList,
                  child: Text('view_all'.tr),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.invoiceList.take(6).length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final invoice = controller.invoiceList.reversed.take(6).toList()[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor('paid').withOpacity(0.1),
                  child: Text( invoice.customerName.isNotEmpty ?
                    invoice.customerName.substring(0,1) : invoice.customerName,
                    style: TextStyle(
                      color: _getStatusColor('paid'),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  '${invoice.invoiceId} - ${invoice.customerName}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${AppUtil.formatCurrency(invoice.totalAmount!)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(invoice.status.toString()).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        invoice.status.toString(),
                        style: TextStyle(
                          color: _getStatusColor(invoice.status.toString()),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  controller.viewInvoiceDetails(invoice);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
