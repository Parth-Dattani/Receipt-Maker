import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../widgets/web_screen_wrapper.dart';
import '../screen.dart';


// ── Import your screen paths ──
// import '../new_invoice/new_invoice_screen.dart';
// import '../new_challan/new_challan_screen.dart';

// ─────────────────────────────────────────────
// AdminOrdersScreen
// ─────────────────────────────────────────────
class AdminOrdersScreen extends GetView<AdminOrdersController> {
  static const pageId = '/AdminOrdersScreen';
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Customer Orders',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Summary bar ──
          Obx(() => Container(
            color: const Color(0xFF00897B),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _SummaryCard(label: 'Total',     count: controller.orders.length,    color: Colors.white,          textColor: const Color(0xFF00897B)),
                const SizedBox(width: 8),
                _SummaryCard(label: 'Pending',   count: controller.pendingCount,     color: Colors.orange.shade50,  textColor: Colors.orange.shade700),
                const SizedBox(width: 8),
                _SummaryCard(label: 'Confirmed', count: controller.confirmedCount,   color: Colors.blue.shade50,    textColor: Colors.blue.shade700),
                const SizedBox(width: 8),
                _SummaryCard(label: 'Delivered', count: controller.deliveredCount,   color: Colors.green.shade50,   textColor: Colors.green.shade700),
              ],
            ),
          )),

          // ── Filter chips ──
          Container(
            height: 48,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FilterChip(label: 'All',       value: 'all',       controller: controller),
                _FilterChip(label: 'Pending',   value: 'pending',   controller: controller),
                _FilterChip(label: 'Confirmed', value: 'confirmed', controller: controller),
                _FilterChip(label: 'Delivered', value: 'delivered', controller: controller),
                _FilterChip(label: 'Cancelled', value: 'cancelled', controller: controller),
              ],
            ),
          ),

          // ── Orders list ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00897B)));
              }
              if (controller.filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No orders',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 16)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadOrders,
                color: const Color(0xFF00897B),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredOrders.length,
                  itemBuilder: (context, index) {
                    return _AdminOrderCard(
                      order: controller.filteredOrders[index],
                      controller: controller,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );

    if (kIsWeb) {
      return webScreenWrapper(
        currentRoute: AdminOrdersScreen.pageId,
        child: content,
      );
    }
    return content;
  }
}

// ─────────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color textColor;
  const _SummaryCard({required this.label, required this.count, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
            Text(label, style: TextStyle(fontSize: 10, color: textColor)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Filter Chip
// ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final AdminOrdersController controller;
  const _FilterChip({required this.label, required this.value, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.filterStatus.value == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => controller.filterStatus.value = value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00897B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                )),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// Admin Order Card
// ─────────────────────────────────────────────
class _AdminOrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final AdminOrdersController controller;
  const _AdminOrderCard({required this.order, required this.controller});

  @override
  State<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<_AdminOrderCard> {
  bool _expanded = false;

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':   return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  String _formatTs(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as Timestamp).toDate();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return ''; }
  }

  void _createInvoice(Map<String, dynamic> order) async {
    final customerData = {
      'name':       order['customerName']    ?? '',
      'customerId': order['customerId']      ?? '',
      'mobile1':    order['customerMobile']  ?? order['customerPhone'] ?? order['mobile'] ?? '',
      'address':    order['customerAddress'] ?? order['address'] ?? '',
      'email':      order['customerEmail']   ?? order['email']   ?? '',
      'pan':        order['customerPan']     ?? '',
      'gst':        order['customerGst']     ?? '',
      'isActive':   'true',
    };
    final orderItems = (order['items'] as List<dynamic>? ?? [])
        .map((i) => i as Map<String, dynamic>).toList();
    final orderId = order['id']?.toString() ?? '';

    if (Get.isRegistered<NewInvoiceController>()) {
      Get.delete<NewInvoiceController>(force: true);
    }

    final result = await Get.toNamed(NewInvoiceScreen.pageId, arguments: {
      'customerData': customerData,
      'customerId':   order['customerId'] ?? '',
      'prefillItems': orderItems,
      'fromOrderId':  orderId,
    });

    if (result == true && orderId.isNotEmpty) {
      widget.controller.markInvoiceCreated(orderId);
    }
  }

  void _createChallan(Map<String, dynamic> order) async {
    final orderId = order['id']?.toString() ?? '';
    final customerData = {
      'name':       order['customerName']    ?? '',
      'customerId': order['customerId']      ?? '',
      'mobile1':    order['customerMobile']  ?? order['customerPhone'] ?? order['mobile'] ?? '',
      'address':    order['customerAddress'] ?? order['address'] ?? '',
      'email':      order['customerEmail']   ?? order['email']   ?? '',
      'pan':        order['customerPan']     ?? '',
      'gst':        order['customerGst']     ?? '',
      'isActive':   'true',
    };
    final orderItems = (order['items'] as List<dynamic>? ?? [])
        .map((i) => i as Map<String, dynamic>).toList();

    if (Get.isRegistered<NewChallanController>()) {
      Get.delete<NewChallanController>(force: true);
    }
    Get.put(NewChallanController());

    final result = await Get.toNamed(NewChallanScreen.pageId, arguments: {
      'customerData': customerData,
      'customerId':   order['customerId'] ?? '',
      'prefillItems': orderItems,
      'fromOrderId':  orderId,
    });

    if (result == true && orderId.isNotEmpty) {
      widget.controller.markChallanCreated(orderId);
    }
  }

  // ✅ NEW: Reset confirm dialog
  void _showResetConfirmDialog(BuildContext context, String orderId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_outlined, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Re-enable Order?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'This will reset Invoice/Challan status and allow you to create them again.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              widget.controller.resetOrderCreated(orderId);
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Re-enable'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order        = widget.order;
    final status       = order['status']?.toString() ?? 'pending';
    final customerName = order['customerName']?.toString() ?? 'Customer';
    final totalAmount  = order['totalAmount'];
    final items        = (order['items'] as List<dynamic>?) ?? [];
    final orderId      = order['id']?.toString() ?? '';
    final statusColor  = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF00897B).withOpacity(0.1),
                        child: Text(
                          customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                          style: const TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(
                              '${items.length} item${items.length == 1 ? '' : 's'}  •  ${_formatTs(order['timestamp'])}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      if (totalAmount != null)
                        Text(
                          '₹${double.tryParse(totalAmount.toString())?.toStringAsFixed(0) ?? totalAmount}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF00897B)),
                        ),
                      const SizedBox(width: 6),
                      Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded ──
          if (_expanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  ...items.map((item) {
                    final i = item as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Color(0xFF00897B)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(i['itemName']?.toString() ?? '', style: const TextStyle(fontSize: 13))),
                          Text('x${i['quantity']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(width: 12),
                          Text(
                            '₹${double.tryParse(i['subtotal']?.toString() ?? '0')?.toStringAsFixed(0) ?? 0}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00897B)),
                          ),
                        ],
                      ),
                    );
                  }),
                  Divider(color: Colors.grey.shade100, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                      Text(
                        '₹${double.tryParse(totalAmount?.toString() ?? '0')?.toStringAsFixed(0) ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF00897B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 12),

                  // ── Action Buttons ──
                  Builder(builder: (context) {
                    final invoiceDone = order['invoiceCreated'] == true;
                    final challanDone = order['challanCreated'] == true;
                    final anyDone = invoiceDone || challanDone;

                    return Column(
                      children: [
                        Row(
                          children: [
                            // ── Invoice Button ──
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: anyDone ? null : () => _createInvoice(order),
                                icon: Icon(
                                  invoiceDone ? Icons.check_circle : Icons.receipt,
                                  size: 16,
                                ),
                                label: Text(
                                  invoiceDone ? 'Invoice ✓' : 'Invoice',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: invoiceDone
                                      ? Colors.green.shade100
                                      : const Color(0xFF00897B),
                                  foregroundColor: invoiceDone
                                      ? Colors.green.shade700
                                      : Colors.white,
                                  disabledBackgroundColor: Colors.green.shade100,
                                  disabledForegroundColor: Colors.green.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // ── Challan Button ──
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: anyDone ? null : () => _createChallan(order),
                                icon: Icon(
                                  challanDone ? Icons.check_circle : Icons.note_alt,
                                  size: 16,
                                  color: challanDone
                                      ? Colors.green.shade600
                                      : Colors.grey.shade700,
                                ),
                                label: Text(
                                  challanDone ? 'Challan ✓' : 'Challan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: challanDone
                                        ? Colors.green.shade600
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: BorderSide(
                                    color: challanDone
                                        ? Colors.green.shade300
                                        : Colors.grey.shade300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ✅ NEW: Edit/Re-enable button — only when anyDone
                        if (anyDone) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showResetConfirmDialog(context, orderId),
                              icon: Icon(Icons.edit_outlined,
                                  size: 15, color: Colors.orange.shade700),
                              label: Text(
                                'Edit / Re-enable',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                side: BorderSide(color: Colors.orange.shade300),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}