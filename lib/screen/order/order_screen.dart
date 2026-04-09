import 'package:GetYourInvoice/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../model/item_model.dart';



// ─────────────────────────────────────────────
// Helper — unit check (top level)
// ─────────────────────────────────────────────
bool _isWholeUnit(String? unit) {
  const decimalUnits = {
    // Weight
    'kg', 'kgs', 'kilogram', 'kilograms',
    'g', 'gm', 'gms', 'gram', 'grams',
    'mg', 'milligram', 'milligrams',
    'quintal', 'ton', 'tonne', 'tons', 'tonnes',
    // Volume
    'l', 'lt', 'ltr', 'ltrs', 'liter', 'litre', 'liters', 'litres',
    'ml', 'milliliter', 'millilitre', 'milliliters', 'millilitres',
    // Length
    'm', 'mtr', 'meter', 'metre', 'meters', 'metres',
    'cm', 'centimeter', 'centimetre',
    'mm', 'millimeter', 'millimetre',
    'ft', 'feet', 'foot',
    'inch', 'inches', 'in',
    'yard', 'yd',
  };
  final u = (unit ?? '').toLowerCase().trim();
  if (u.isEmpty) return true; // no unit = pcs style = whole number
  return !decimalUnits.contains(u);
}

// ─────────────────────────────────────────────
// OrderScreen
// ─────────────────────────────────────────────
class OrderScreen extends StatelessWidget {
  static const pageId = '/order';
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00897B),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'My Orders',
            onPressed: () => Get.toNamed(
              '/order-history',
              parameters: {
                'cid': controller.companyId.value,
                'uid': controller.customerId.value,
              },
            ),
          ),
        ],
        title: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.customerName.value.isEmpty
                  ? 'Loading...'
                  : 'Welcome, ${controller.customerName.value} 👋',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            if (controller.companyName.value.isNotEmpty)
              Text(controller.companyName.value,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
          ],
        )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00897B)));
        }

        // ✅ Web-Responsive Container — list row count isolated so qty changes don't rebuild ListView
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800), // વેબ માટે લિમિટ
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF00897B),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: const Text(
                    'Select items and place your order below',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    children: [
                      Obx(() {
                        final n = controller.orderRows.length;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(n, (index) {
                            return _OrderItemRow(
                              index: index,
                              controller: controller,
                            );
                          }),
                        );
                      }),

                      const SizedBox(height: 12),

                      // Add Item Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.addNewRow,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: const Text('Add Another Item',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Total Summary Card
                      _buildTotalItemsSummary(controller),

                      const SizedBox(height: 30),

                      // ✅ Professional One-Line Footer
                      _buildFooter(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      // Bottom Bar (Centering for Web) — orderQtyTick so qty updates don't rebuild main body list
      bottomNavigationBar: Obx(() {
        controller.orderQtyTick.value;
        final hasItems = controller.orderRows.any((r) => r.selectedItem != null && r.qty > 0);
        if (!hasItems || controller.isLoading.value) return const SizedBox.shrink();

        return Center(
          heightFactor: 1,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _CartBar(controller: controller),
          ),
        );
      }),
    );
  }

  // --- Footer Widget ---
  Widget _buildFooter() {
    return Opacity(
      opacity: 0.6,
      child: Column(
        children: [
          Container(height: 1, width: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),

          const Text(
            'Application By: Intelligent Tech',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00897B)
            ),
          ),

          const SizedBox(height: 6),

          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: [
              const Text(
                  '252, NEO Square, Jamnagar',
                  style: TextStyle(fontSize: 10, color: Colors.black54)
              ),
              _dot(),
              const Text(
                  'Mo: 7383915985',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle));

  // --- Total Items Summary Widget ---
  Widget _buildTotalItemsSummary(OrderController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Obx(() {
        controller.orderQtyTick.value;
        final total = controller.orderRows.where((r) => r.selectedItem != null && r.qty > 0).length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Items:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF2E7D32))),
            Text('$total', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF2E7D32))),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Order Item Row Card
// ─────────────────────────────────────────────
class _OrderItemRow extends StatelessWidget {
  final int index;
  final OrderController controller;

  const _OrderItemRow({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final row  = controller.orderRows[index];
      final item = row.selectedItem;

      // ✅ unit read with trim
      final unit    = (item?.unitOfMeasurement ?? '').trim();
      final isWhole = _isWholeUnit(unit);



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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: #N + delete
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('#${index + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Item',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  if (controller.orderRows.length > 1)
                    GestureDetector(
                      onTap: () => controller.removeRow(index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline,
                            color: Colors.red.shade400, size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Item selector
              GestureDetector(
                onTap: () => _showItemPicker(context, index, controller),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: item == null
                        ? const Color(0xFFF8F9FA)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: item == null
                          ? Colors.grey.shade300
                          : const Color(0xFF00897B),
                      width: item == null ? 1 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item?.itemName ?? 'Select Item...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: item != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: item != null
                                ? const Color(0xFF1A1A2E)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              ),

              if (item != null) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price (conditional)
                    if (controller.showPriceToCustomer.value) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Price',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border:
                                Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '₹${item.sellPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Qty
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.isNotEmpty ? 'Qty ($unit)' : 'Qty',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          // ✅ ValueKey — fresh widget on item/unit change
                          _QtyField(
                            key: ValueKey(
                              '${index}_${item.itemId}_$unit',
                            ),
                            row: row,
                            index: index,
                            isWhole: isWhole,
                            controller: controller,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  void _showItemPicker(
      BuildContext context, int index, OrderController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemPickerSheet(
        controller: controller,
        onSelect: (Item item) {
          controller.selectItem(index, item);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ✅ FIXED: Qty Field — super.key + clean logic
// ─────────────────────────────────────────────
class _QtyField extends StatefulWidget {
  final OrderRow row;
  final int index;
  final bool isWhole;
  final OrderController controller;

  const _QtyField({
    super.key, // ✅ CRITICAL — allows ValueKey to work
    required this.row,
    required this.index,
    required this.isWhole,
    required this.controller,
  });

  @override
  State<_QtyField> createState() => _QtyFieldState();
}

class _QtyFieldState extends State<_QtyField> {
  late TextEditingController _tc;

  @override
  void initState() {
    super.initState();
    // Fresh state every time key changes
    _tc = TextEditingController(
      text: widget.row.qty > 0
          ? (widget.isWhole
          ? widget.row.qty.toInt().toString()
          : widget.row.qty.toString())
          : '',
    );
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00897B), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _tc,
        // ✅ pcs/box = whole number keyboard, kg/lt = decimal keyboard
        keyboardType: widget.isWhole
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        // ✅ pcs/box = digits only, kg/lt = digits + one dot
        inputFormatters: widget.isWhole
            ? [FilteringTextInputFormatter.digitsOnly]
            : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF00897B),
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: widget.isWhole ? 'e.g. 5' : 'e.g. 2.5',
          hintStyle:
          TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
        onChanged: (v) {
          if (v.isEmpty) {
            widget.controller.setQty(widget.index, 0);
            return;
          }
          // pcs guard: block dot
          if (widget.isWhole && v.contains('.')) {
            final clean = v.replaceAll('.', '');
            _tc.value = TextEditingValue(
              text: clean,
              selection:
              TextSelection.collapsed(offset: clean.length),
            );
            widget.controller.setQty(
                widget.index, double.tryParse(clean) ?? 0);
            return;
          }
          // decimal: only one dot allowed
          if (!widget.isWhole) {
            final parts = v.split('.');
            if (parts.length > 2) {
              final clean =
                  '${parts[0]}.${parts.sublist(1).join('')}';
              _tc.value = TextEditingValue(
                text: clean,
                selection:
                TextSelection.collapsed(offset: clean.length),
              );
              widget.controller.setQty(
                  widget.index, double.tryParse(clean) ?? 0);
              return;
            }
          }
          widget.controller.setQty(
              widget.index, double.tryParse(v) ?? 0);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Item Picker Bottom Sheet
// ─────────────────────────────────────────────
class _ItemPickerSheet extends StatefulWidget {
  final OrderController controller;
  final Function(Item) onSelect;

  const _ItemPickerSheet(
      {required this.controller, required this.onSelect});

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.itemList
        .where((i) =>
        i.itemName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Select Item',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search items by name...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return InkWell(
                  onTap: () => widget.onSelect(item),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.itemName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),

                              if (widget.controller.showPriceToCustomer.value)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                      '₹ ${item.sellPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Color(0xFF00897B),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Cart Bottom Bar
// ─────────────────────────────────────────────
class _CartBar extends StatelessWidget {
  final OrderController controller;
  const _CartBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                controller.orderQtyTick.value;
                final count = controller.orderRows
                    .where((r) => r.selectedItem != null && r.qty > 0)
                    .length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total Items: $count',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600)),
                    if (controller.showPriceToCustomer.value)
                      Obx(() => Text(
                        '₹${controller.orderTotalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00897B)),
                      )),
                  ],
                );
              }),
            ),
            Obx(() => ElevatedButton(
              onPressed: controller.isPlacingOrder.value
                  ? null
                  : controller.placeOrderNew,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: controller.isPlacingOrder.value
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Text('Place Order',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Order Success Screen
// ─────────────────────────────────────────────
class OrderSuccessScreen extends StatelessWidget {
  static const pageId = '/order-success';
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.green.shade500, size: 80),
              ),
              const SizedBox(height: 32),
              const Text('Order Placed! 🎉',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 12),
              Text(
                'Your order has been placed successfully.\nThe store owner will contact you soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.6),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final cid = Get.parameters['cid'] ?? '';
                      final uid = Get.parameters['uid'] ?? '';
                      if (Get.isRegistered<OrderController>()) {
                        Get.delete<OrderController>(force: true);
                      }
                      Get.offNamed(
                        OrderScreen.pageId,
                        parameters: {'cid': cid, 'uid': uid},
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Order More'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      final cid = Get.parameters['cid'] ?? '';
                      final uid = Get.parameters['uid'] ?? '';
                      Get.offNamed(
                        '/order-history',
                        parameters: {'cid': cid, 'uid': uid},
                      );
                    },
                    icon: const Icon(Icons.receipt_long,
                        size: 18, color: Color(0xFF00897B)),
                    label: const Text('My Orders',
                        style: TextStyle(color: Color(0xFF00897B))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00897B)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}