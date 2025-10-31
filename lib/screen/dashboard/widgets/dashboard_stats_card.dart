import 'package:demo_prac_getx/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';

// class DashboardStatsCard extends GetView<DashboardController> {
//  static const pageId = "/DashboardStatsCard";
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Revenue Stats Row
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 title: 'Total Revenue',
//                 value: '₹${AppUtil.formatCurrency(controller.totalRevenue.value)}',
//                 icon: Icons.account_balance_wallet,
//                 color: Colors.green,
//               ),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: _buildStatCard(
//                 title: 'Pending Amount',
//                 value: '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}',
//                 icon: Icons.pending,
//                 color: Colors.orange,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 10),
//
//         // Invoice Stats Row
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 title: 'Total Invoices',
//                 value: '${controller.invoiceList.length}',
//                 icon: Icons.receipt_long,
//                 color: Colors.blue,
//               ),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: _buildStatCard(
//                 title: 'Overdue',
//                 value: '${controller.overdueAmount.value}',
//                 icon: Icons.warning,
//                 color: Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(icon, color: color, size: 24),
//               Container(
//                 padding: EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.trending_up, color: color, size: 16),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade800,
//             ),
//           ),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

///change UI 23-10 10;16
// class DashboardStatsCard extends GetView<DashboardController> {
//   static const pageId = "/DashboardStatsCard";
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // ✅ SALES SECTION
//         _buildSectionHeader('Sales Overview', Icons.trending_up, Colors.green),
//         SizedBox(height: 10),
//
//         // Revenue Stats Row
//         Row(
//           children: [
//             Expanded(
//               child: Obx(() => _buildStatCard(
//                 title: 'Total Revenue',
//                 value: '₹${AppUtil.formatCurrency(controller.totalRevenue.value)}',
//                 icon: Icons.account_balance_wallet,
//                 color: Colors.green,
//               )),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Obx(() => _buildStatCard(
//                 title: 'Pending Amount',
//                 value: '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}',
//                 icon: Icons.pending,
//                 color: Colors.orange,
//               )),
//             ),
//           ],
//         ),
//         SizedBox(height: 10),
//
//         // Invoice Stats Row
//         Row(
//           children: [
//             Expanded(
//               child: Obx(() => _buildStatCard(
//                 title: 'Total Invoices',
//                 value: '${controller.invoiceList.length}',
//                 icon: Icons.receipt_long,
//                 color: Colors.blue,
//               )),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Obx(() => _buildStatCard(
//                 title: 'Overdue Invoices',
//                 value: '${controller.overdueCount.value}',
//                 icon: Icons.warning,
//                 color: Colors.red,
//               )),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 20),
//
//         // ✅ PURCHASE SECTION
//         _buildSectionHeader('Purchase Overview', Icons.shopping_cart, Colors.purple),
//         SizedBox(height: 10),
//
//         // Purchase Stats Row - Only Pending Payment
//         Row(
//           children: [
//             Expanded(
//               child: Obx(() => _buildStatCard(
//                 title: 'Total Purchase',
//                 value: '₹${AppUtil.formatCurrency(controller.totalPurchaseAmount.value)}',
//                 icon: Icons.shopping_bag,
//                 color: Colors.purple,
//               )),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Obx(() => _buildStatCard(
//                 title: 'Pending Payment',
//                 value: '₹${AppUtil.formatCurrency(controller.pendingPurchaseAmount.value)}',
//                 icon: Icons.payment,
//                 color: Colors.deepOrange,
//               )),
//             ),
//
//           ],
//         ),
//         SizedBox(height: 10),
//
//         // Purchase Count Row - Only Pending Orders
//         Row(
//           children: [
//             Expanded(
//               child: Obx(() => _buildStatCard(
//                 title: 'Total Orders',
//                 value: '${controller.totalPurchases.value}',
//                 icon: Icons.inventory,
//                 color: Colors.indigo,
//               )),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Obx(() => _buildStatCard(
//                 title: 'Overdue Payment',
//                 value: '${controller.overduePurchases.value}',
//                 icon: Icons.warning,
//                 color: Colors.red,
//               )),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 20),
//
//         // ✅ NET PROFIT/LOSS CARD
//         Obx(() => _buildProfitCard(
//           salesTotal: controller.totalRevenue.value,
//           purchaseTotal: controller.totalPurchaseAmount.value,
//         )),
//       ],
//     );
//   }
//
//   // ✅ Section Header Widget
//   Widget _buildSectionHeader(String title, IconData icon, Color color) {
//     return Row(
//       children: [
//         Icon(icon, color: color, size: 20),
//         SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey.shade800,
//           ),
//         ),
//         Expanded(child: Divider(indent: 12, color: color.withOpacity(0.3))),
//       ],
//     );
//   }
//
//   // ✅ Stat Card Widget
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(icon, color: color, size: 24),
//               Container(
//                 padding: EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.trending_up, color: color, size: 16),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade800,
//             ),
//           ),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ Profit/Loss Summary Card
//   Widget _buildProfitCard({
//     required double salesTotal,
//     required double purchaseTotal,
//   }) {
//     final netProfit = salesTotal - purchaseTotal;
//     final isProfit = netProfit >= 0;
//
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: isProfit
//               ? [Colors.green.shade50, Colors.green.shade100]
//               : [Colors.red.shade50, Colors.red.shade100],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isProfit ? Colors.green.shade300 : Colors.red.shade300,
//           width: 1.5,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 isProfit ? Icons.trending_up : Icons.trending_down,
//                 color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
//                 size: 28,
//               ),
//               SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isProfit ? 'Net Profit' : 'Net Loss',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     '₹${AppUtil.formatCurrency(netProfit.abs())}',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: isProfit ? Colors.green.shade800 : Colors.red.shade800,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '${((netProfit / (purchaseTotal > 0 ? purchaseTotal : 1)) * 100).toStringAsFixed(1)}%',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


/// nw Ui SALEes/ purchas is Ok But why use revnu / purschas Show I sDuplication
// class DashboardStatsCard extends GetView<DashboardController> {
//   static const pageId = "/DashboardStatsCard";
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // ✅ NET PROFIT/LOSS HERO CARD (TOP)
//         Obx(() => _buildHeroProfitCard(
//           salesTotal: controller.totalRevenue.value,
//           purchaseTotal: controller.totalPurchaseAmount.value,
//         )),
//
//         SizedBox(height: 20),
//
//         // ✅ FINANCIAL METRICS
//         _buildSectionTitle('Financial Metrics'),
//         SizedBox(height: 12),
//
//         Row(
//           children: [
//             Expanded(
//               child: Obx(() => _buildModernCard(
//                 title: 'Revenue',
//                 value: '₹${AppUtil.formatCurrency(controller.totalRevenue.value)}',
//                 icon: Icons.arrow_upward_rounded,
//                 iconColor: Colors.green,
//                 bgColor: Colors.green.shade50,
//               )),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Obx(() => _buildModernCard(
//                 title: 'Purchase',
//                 value: '₹${AppUtil.formatCurrency(controller.totalPurchaseAmount.value)}',
//                 icon: Icons.arrow_downward_rounded,
//                 iconColor: Colors.purple,
//                 bgColor: Colors.purple.shade50,
//               )),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 12),
//
//         Row(
//           children: [
//             Expanded(
//               child: Obx(() => _buildModernCard(
//                 title: 'To Receive',
//                 value: '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}',
//                 icon: Icons.download_rounded,
//                 iconColor: Colors.orange,
//                 bgColor: Colors.orange.shade50,
//               )),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Obx(() => _buildModernCard(
//                 title: 'To Pay',
//                 value: '₹${AppUtil.formatCurrency(controller.pendingPurchaseAmount.value)}',
//                 icon: Icons.upload_rounded,
//                 iconColor: Colors.deepOrange,
//                 bgColor: Colors.deepOrange.shade50,
//               )),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 20),
//
//         // ✅ TRANSACTIONS COUNT
//         _buildSectionTitle('Transactions'),
//         SizedBox(height: 12),
//
//         Row(
//           children: [
//             Expanded(
//               child: Obx(() => _buildCountCard(
//                 title: 'Invoices',
//                 count: controller.invoiceList.length,
//                 overdue: controller.overdueCount.value,
//                 icon: Icons.receipt_rounded,
//                 color: Colors.blue,
//               )),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Obx(() => _buildCountCard(
//                 title: 'Orders',
//                 count: controller.totalPurchases.value,
//                 overdue: controller.overduePurchases.value,
//                 icon: Icons.shopping_bag_rounded,
//                 color: Colors.indigo,
//               )),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // ✅ Section Title
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 4,
//             height: 20,
//             decoration: BoxDecoration(
//               color: Colors.blue.shade600,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           SizedBox(width: 10),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w700,
//               color: Colors.grey.shade900,
//               letterSpacing: 0.3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ Hero Profit Card (Large, Prominent)
//   Widget _buildHeroProfitCard({
//     required double salesTotal,
//     required double purchaseTotal,
//   }) {
//     final netProfit = salesTotal - purchaseTotal;
//     final isProfit = netProfit >= 0;
//     final percentage = ((netProfit / (purchaseTotal > 0 ? purchaseTotal : 1)) * 100).toStringAsFixed(1);
//
//     return Container(
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: isProfit
//               ? [Color(0xFF0F766E), Color(0xFF14B8A6)]
//               : [Color(0xFFB91C1C), Color(0xFFEF4444)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: (isProfit ? Colors.teal : Colors.red).withOpacity(0.25),
//             spreadRadius: 0,
//             blurRadius: 20,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       isProfit ? Icons.trending_up : Icons.trending_down,
//                       color: Colors.white,
//                       size: 16,
//                     ),
//                     SizedBox(width: 6),
//                     Text(
//                       isProfit ? 'PROFIT' : 'LOSS',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   '$percentage%',
//                   style: TextStyle(
//                     color: isProfit ? Color(0xFF0F766E) : Color(0xFFB91C1C),
//                     fontWeight: FontWeight.w800,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Net ${isProfit ? 'Profit' : 'Loss'}',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.9),
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             '₹${AppUtil.formatCurrency(netProfit.abs())}',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 36,
//               fontWeight: FontWeight.w800,
//               letterSpacing: 0.5,
//             ),
//           ),
//           SizedBox(height: 20),
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildProfitDetail(
//                     label: 'Sales',
//                     amount: salesTotal,
//                     icon: Icons.add_circle_outline,
//                   ),
//                 ),
//                 Container(
//                   width: 1,
//                   height: 40,
//                   color: Colors.white.withOpacity(0.3),
//                   margin: EdgeInsets.symmetric(horizontal: 12),
//                 ),
//                 Expanded(
//                   child: _buildProfitDetail(
//                     label: 'Purchase',
//                     amount: purchaseTotal,
//                     icon: Icons.remove_circle_outline,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfitDetail({
//     required String label,
//     required double amount,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
//             SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.8),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 4),
//         Text(
//           '₹${AppUtil.formatCurrency(amount)}',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ✅ Modern Financial Card
//   Widget _buildModernCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color iconColor,
//     required Color bgColor,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade200, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: iconColor, size: 26),
//           ),
//           SizedBox(height: 16),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: 6),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//               color: Colors.grey.shade900,
//               letterSpacing: 0.2,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ IMPROVED Count Card with Better Overdue Display
//   Widget _buildCountCard({
//     required String title,
//     required int count,
//     required int overdue,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: overdue > 0 ? Colors.red.shade200 : Colors.grey.shade200,
//           width: overdue > 0 ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: overdue > 0
//                 ? Colors.red.withOpacity(0.08)
//                 : Colors.black.withOpacity(0.03),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Top Row: Icon and Overdue Badge
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, color: color, size: 22),
//               ),
//               if (overdue > 0)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade600,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.red.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.access_time_rounded,
//                         color: Colors.white,
//                         size: 14,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         '$overdue',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//
//           SizedBox(height: 16),
//
//           // Count and Title
//           Text(
//             '$count',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w800,
//               color: Colors.grey.shade900,
//             ),
//           ),
//           SizedBox(height: 2),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//
//           // Overdue Section at Bottom
//           if (overdue > 0) ...[
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: Colors.red.shade200,
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.warning_amber_rounded,
//                     color: Colors.red.shade700,
//                     size: 16,
//                   ),
//                   SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       '$overdue Overdue',
//                       style: TextStyle(
//                         color: Colors.red.shade700,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }


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
