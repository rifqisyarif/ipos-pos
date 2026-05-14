import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipot_pos/components/connectivity_banner.dart';
import 'package:ipot_pos/components/quality_control.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:ipot_pos/utils/formatter.dart';
import '../../navigation/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../state/order_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final orderCtrl = Get.put(OrderController(), permanent: true);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Obx(() => cart.items.isNotEmpty
              ? TextButton(
                  onPressed: () => _confirmClear(cart),
                  child: const Text('Clear',
                      style: TextStyle(color: Colors.white70)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: ConnectivityBanner(
        child: Obx(() {
          if (cart.items.isEmpty) return const _EmptyCart();
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: cart.items.length,
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    return _CartItemTile(
                      key: ValueKey(item.id),
                      cartItemId: item.id,
                      name: item.menuItem.name,
                      customizations: item.customizationSummary,
                      quantity: item.quantity,
                      unitPrice: item.unitPrice,
                      totalPrice: item.totalPrice,
                      onIncrement: () => cart.increment(item.id),
                      onDecrement: () => cart.decrement(item.id),
                      onRemove: () => cart.remove(item.id),
                    );
                  },
                ),
              ),
              _OrderSummary(cart: cart, orderCtrl: orderCtrl),
            ],
          );
        }),
      ),
    );
  }

  void _confirmClear(CartController cart) {
    Get.defaultDialog(
      title: 'Clear Cart',
      middleText: 'Remove all items from cart?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.accent,
      onConfirm: () {
        cart.clear();
        Get.back();
      },
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final String cartItemId;
  final String name;
  final String customizations;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemTile({
    super.key,
    required this.cartItemId,
    required this.name,
    required this.customizations,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.grey[400],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Remove item',
                ),
              ],
            ),
            if (customizations.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                customizations,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuantityControl(
                  quantity: quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.price(totalPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (quantity > 1)
                        Text(
                          '${Formatters.price(unitPrice)} each',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartController cart;
  final OrderController orderCtrl;

  const _OrderSummary({required this.cart, required this.orderCtrl});

  Future<void> _placeOrder(BuildContext context) async {
    final payload = cart.toOrderPayload();
    final success = await orderCtrl.submitOrder(payload);
    if (success) {
      cart.clear();
      Get.offAllNamed(AppRoutes.orderTracking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal',
                    style: TextStyle(color: AppColors.textSecondary)),
                Obx(() => Text(Formatters.price(cart.subtotal),
                    style: const TextStyle(fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax (10%)',
                    style: TextStyle(color: AppColors.textSecondary)),
                Text('Calculated at checkout'),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Obx(() => Text(
                      Formatters.price(cart.subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.accent,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: orderCtrl.isSubmitting.value
                        ? null
                        : () => _placeOrder(context),
                    child: orderCtrl.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Place Order',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Browse the menu and add some items!',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }
}
