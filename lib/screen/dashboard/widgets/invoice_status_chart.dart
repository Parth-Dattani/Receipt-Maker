import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';
//
// class InvoiceStatusChart extends GetView<DashboardController> {
//   static const pageId = "/InvoiceStatusChart";
//
//   // ✅ 1. Add isWeb flag
//   final bool isWeb;
//
//   // ✅ 2. Initialize in constructor (Default is false for Mobile)
//   const InvoiceStatusChart({super.key, this.isWeb = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final chartData = controller.invoiceStatusData.isEmpty
//           ? [
//         ChartData("Paid", 0.0, Colors.green),
//         ChartData("Pending", 0.0, Colors.orange),
//         ChartData("Overdue", 0.0, Colors.red),
//       ]
//           : controller.invoiceStatusData;
//
//       return Container(
//         // ✅ 3. Only apply full width on Web. Mobile stays untouched (null).
//         width: isWeb ? double.infinity : null,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 2,
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min, // ✅ Only take needed space
//             children: [
//               Text(
//                 'invoice_status'.tr,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//               SizedBox(height: 16),
//
//               chartData.isEmpty
//                   ? Padding(
//                 padding: EdgeInsets.symmetric(vertical: 24),
//                 child: Center(
//                   child: Text(
//                     'no_data_available'.tr,
//                     style: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               )
//                   : Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: chartData.map((data) {
//                   return Padding(
//                     padding: EdgeInsets.symmetric(vertical: 6),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 12,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: data.color,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             data.label.tr,
//                             style: TextStyle(fontSize: 12),
//                           ),
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               data.value.toInt().toString(),
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                                 color: data.value == 0
//                                     ? Colors.grey.shade400
//                                     : Colors.black87,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';


class InvoiceStatusChart extends GetView<DashboardController> {
  static const pageId = "/InvoiceStatusChart";

  final bool isWeb;

  const InvoiceStatusChart({super.key, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chartData = controller.invoiceStatusData.isEmpty
          ? [
        ChartData("Paid", 0.0, Colors.green),
        ChartData("Pending", 0.0, Colors.orange),
        ChartData("Overdue", 0.0, Colors.red),
      ]
          : controller.invoiceStatusData;

      return Container(
        //height: isWeb ? double.infinity : null,
       // width: isWeb ? double.infinity : null,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:  MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'invoice_status'.tr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),

              if(!isWeb) const SizedBox(height: 12),

              // Data List
              Column(
                mainAxisSize: MainAxisSize.min,
                children: chartData.map((data) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6), // ઓછી પેડિંગ
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: data.color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            data.label.tr,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ),
                        Text(
                          data.value.toInt().toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: data.value == 0 ? Colors.grey.shade400 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}