import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/order_controller.dart';
import '../../services/orders_sheet_service.dart';
import 'order_screen.dart';

// ─────────────────────────────────────────────
// OrderHistoryScreen
// URL: /order-history?cid=...&uid=...
// ─────────────────────────────────────────────
class OrderHistoryScreen extends StatefulWidget {
  static const pageId = '/order-history';
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  late final String _cid;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _cid = Get.parameters['cid'] ?? '';
    _uid = Get.parameters['uid'] ?? '';
    _ordersFuture = OrdersSheetService.getCustomerOrders(
      companyId: _cid,
      customerId: _uid,
    );
  }

  Future<void> _reload() async {
    final f = OrdersSheetService.getCustomerOrders(
      companyId: _cid,
      customerId: _uid,
    );
    setState(() => _ordersFuture = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00897B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offNamed(
            '/order',
            parameters: {'cid': _cid, 'uid': _uid},
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _reload,
          ),
        ],
      ),
      body: _cid.isEmpty || _uid.isEmpty
          ? const Center(
              child: Text('Invalid link',
                  style: TextStyle(color: Colors.grey)))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF00897B)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text('Error loading orders',
                            style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => _reload(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFF00897B),
                    onRefresh: _reload,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                        ),
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Center(
                          child: Text('No orders yet',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text('Your orders will appear here',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400)),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF00897B),
                  onRefresh: _reload,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _OrderCard(
                        data: orders[index],
                        companyId: _cid,
                        customerId: _uid,
                        onOrdersChanged: _reload,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

List<dynamic> _orderItemsFromData(dynamic v) {
  if (v is List) return v;
  return const [];
}

/// True if sheet/backend sent a cancelled-like label (spacing, punctuation, unicode noise).
bool _statusMeansCancelledLike(String raw) {
  var s = raw.toLowerCase().trim();
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  if (s.isEmpty) return false;
  if (s == 'cancelled' || s == 'canceled' || s == 'cancel') return true;
  final letters = s.replaceAll(RegExp(r'[^a-z]'), '');
  return letters == 'cancelled' ||
      letters == 'canceled' ||
      letters == 'cancel';
}

/// Order header: if any line item is still shown, never show full "cancelled" (partial line cancels).
String _displayOrderStatus(Map<String, dynamic> data) {
  final raw = (data['status']?.toString() ?? '').trim();
  final items = _orderItemsFromData(data['items']);
  if (items.isNotEmpty && _statusMeansCancelledLike(raw)) {
    return 'confirmed';
  }
  return raw.isEmpty ? 'pending' : raw;
}

bool _customerMayEditOrDelete(Map<String, dynamic> data) {
  return _displayOrderStatus(data).toLowerCase() == 'pending';
}

// ─────────────────────────────────────────────
// Order Card
// ─────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String companyId;
  final String customerId;
  final Future<void> Function() onOrdersChanged;

  const _OrderCard({
    required this.data,
    required this.companyId,
    required this.customerId,
    required this.onOrdersChanged,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;
  bool _deleting = false;

  Future<void> _confirmAndDeleteOrder() async {
    final oid = widget.data['orderId']?.toString() ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await OrdersSheetService.deletePendingOrderFromSheet(
        companyId: widget.companyId,
        customerId: widget.customerId,
        orderId: oid,
      );
      if (!mounted) return;
      Get.snackbar(
        'ડિલીટ થયું',
        'ઓર્ડર કાઢી નાખ્યો.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00897B),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      await widget.onOrdersChanged();
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'ભૂલ',
          e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':   return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':   return Icons.hourglass_empty;
      case 'confirmed': return Icons.check_circle_outline;
      case 'delivered': return Icons.local_shipping_outlined;
      case 'cancelled': return Icons.cancel_outlined;
      default:          return Icons.info_outline;
    }
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return '';
    try {
      // Sheet stores timestamp as string; keep as-is.
      return ts.toString();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status      = _displayOrderStatus(widget.data);
    final totalAmount = widget.data['totalAmount'];
    final timestamp   = widget.data['timestamp'];
    final items       = _orderItemsFromData(widget.data['items']);
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(status),
                                size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              status[0].toUpperCase() +
                                  status.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Total — hide if pending (showPriceToCustomer unknown)
                      if (totalAmount != null && status != 'pending')
                        Text(
                          '₹${double.tryParse(totalAmount.toString())?.toStringAsFixed(2) ?? totalAmount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00897B),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500),
                      ),
                      const Spacer(),
                      Text(
                        '${items.length} item${items.length == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  if (_customerMayEditOrDelete(widget.data)) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _deleting
                                ? null
                                : () {
                                    final oid = widget.data['orderId']
                                            ?.toString() ??
                                        '';
                                    Get.delete<OrderController>(
                                        force: true);
                                    Get.toNamed(
                                      OrderScreen.pageId,
                                      parameters: {
                                        'cid': widget.companyId,
                                        'uid': widget.customerId,
                                        'editOrderId': oid,
                                      },
                                    );
                                  },
                            icon: const Icon(Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF00897B)),
                            label: const Text('Edit',
                                style: TextStyle(
                                    color: Color(0xFF00897B),
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF00897B)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                _deleting ? null : _confirmAndDeleteOrder,
                            icon: _deleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red),
                                  )
                                : const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                            label: Text(
                                _deleting ? '…' : 'Delete',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Expanded Items ──
          if (_expanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Details',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 10),
                  ...items.map((item) {
                    final i = item as Map<String, dynamic>;
                    final qty = i['quantity'];
                    final subtotal = i['subtotal'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00897B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              i['itemName']?.toString() ?? '',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            'x$qty',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600),
                          ),
                          if (subtotal != null && status != 'pending') ...[
                            const SizedBox(width: 12),
                            Text(
                              '₹${double.tryParse(subtotal.toString())?.toStringAsFixed(2) ?? subtotal}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00897B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),

                  // Total row
                  if (totalAmount != null) ...[
                    Divider(color: Colors.grey.shade100, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700)),
                        if (status != 'pending')
                          Text(
                            '₹${double.tryParse(totalAmount.toString())?.toStringAsFixed(2) ?? totalAmount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF00897B),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}