import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
// OrderHistoryScreen
// URL: /order-history?cid=...&uid=...
// ─────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
// OrderHistoryScreen
// URL: /order-history?cid=...&uid=...
// ─────────────────────────────────────────────
class OrderHistoryScreen extends StatelessWidget {
  static const pageId = '/order-history';
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cid = Get.parameters['cid'] ?? '';
    final uid = Get.parameters['uid'] ?? '';

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
            parameters: {'cid': cid, 'uid': uid},
          ),
        ),
      ),
      body: cid.isEmpty || uid.isEmpty
          ? const Center(
          child: Text('Invalid link',
              style: TextStyle(color: Colors.grey)))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('public_orders')
            .where('companyId', isEqualTo: cid)
            .where('customerId', isEqualTo: uid)
            .snapshots(),
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
                ],
              ),
            );
          }

          // Sort by timestamp descending in Dart (no index needed)
          final docs = (snapshot.data?.docs ?? [])
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTs = aData['timestamp'] as Timestamp?;
              final bTs = bData['timestamp'] as Timestamp?;
              if (aTs == null && bTs == null) return 0;
              if (aTs == null) return 1;
              if (bTs == null) return -1;
              return bTs.compareTo(aTs); // newest first
            });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No orders yet',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Your orders will appear here',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
              docs[index].data() as Map<String, dynamic>;
              return _OrderCard(data: data);
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Order Card
// ─────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _OrderCard({required this.data});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

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
      final dt = (ts as Timestamp).toDate();
      return '${dt.day.toString().padLeft(2,'0')}/'
          '${dt.month.toString().padLeft(2,'0')}/${dt.year}  '
          '${dt.hour.toString().padLeft(2,'0')}:'
          '${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status      = widget.data['status']?.toString() ?? 'pending';
    final totalAmount = widget.data['totalAmount'];
    final timestamp   = widget.data['timestamp'];
    final items       = (widget.data['items'] as List<dynamic>?) ?? [];
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
                    final price = i['price'];
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