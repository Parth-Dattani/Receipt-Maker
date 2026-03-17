import 'package:GetYourInvoice/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Obx(() => Text(
          controller.customerName.value.isEmpty
              ? 'Loading...'
              : 'Welcome, ${controller.customerName.value} 👋',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        )),
      ),
      body: Obx(() {
        // ── Loading ──
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 16),
                Text('Loading items...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // ── Empty ──
        if (controller.itemList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No items available', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        // ── Content ──
        return Column(
          children: [
            // ── Header banner ──
            Container(
              width: double.infinity,
              color: Colors.teal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: const Text(
                'Select items and place your order below',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),

            // ── Item list ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: controller.itemList.length,
                itemBuilder: (context, index) {
                  final item = controller.itemList[index];
                  return _ItemCard(item: item, controller: controller);
                },
              ),
            ),
          ],
        );
      }),

      // ── Sticky bottom cart bar ──
      bottomNavigationBar: Obx(() {
        if (controller.cart.isEmpty || controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return _CartBottomBar(controller: controller);
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Item Card Widget
// ─────────────────────────────────────────────
class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final OrderController controller;

  const _ItemCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Item Icon ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: Colors.teal, size: 22),
            ),
            const SizedBox(width: 14),

            // ── Item Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => controller.showPriceToCustomer.value
                      ? Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                      : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ── Quantity Control ──
            Obx(() {
              final qty = controller.getQuantity(item.itemId);
              if (qty == 0) {
                // Show ADD button
                return TextButton(
                  onPressed: () => controller.incrementQuantity(item.itemId),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              }
              // Show quantity stepper
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => controller.decrementQuantity(item.itemId),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => controller.incrementQuantity(item.itemId),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quantity Button
// ─────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: Colors.teal),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Cart Bottom Bar
// ─────────────────────────────────────────────
class _CartBottomBar extends StatelessWidget {
  final OrderController controller;

  const _CartBottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4)),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ── Total info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final itemCount = controller.cart.values.fold(0, (sum, qty) => sum + qty);
                    return Text(
                      '$itemCount item${itemCount == 1 ? '' : 's'} selected',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    );
                  }),
                  const SizedBox(height: 2),
                  Obx(() => controller.showPriceToCustomer.value
                      ? Text(
                    '₹${controller.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  )
                      : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ── Place Order button ──
            Obx(() => ElevatedButton(
              onPressed: controller.isPlacingOrder.value ? null : controller.placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: controller.isPlacingOrder.value
                  ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                'Place Order',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// OrderSuccessScreen
// ─────────────────────────────────────────────
class OrderSuccessScreen extends StatelessWidget {
  static const pageId = '/order-success';

  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 80),
              ),
              const SizedBox(height: 28),
              const Text(
                'Order Placed! 🎉',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Text(
                'Your order has been placed successfully.\nThe store owner will contact you soon.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () => Get.offNamed(OrderScreen.pageId +
                    '?cid=${Get.parameters['cid'] ?? ''}&uid=${Get.parameters['uid'] ?? ''}'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Order More Items'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}