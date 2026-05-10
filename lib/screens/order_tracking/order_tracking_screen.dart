import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:ipot_pos/utils/formatter.dart';
import '../../components/order_status_stepper.dart';
import '../../models/order.dart';
import '../../navigation/app_routes.dart';
import '../../state/order_controller.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Status',
            style: TextStyle(fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.scanner),
            child: const Text('New Order',
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: Obx(() {
        final order = orderCtrl.currentOrder.value;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _TrackingContent(order: order);
      }),
    );
  }
}

class _TrackingContent extends StatelessWidget {
  final Order order;

  const _TrackingContent({required this.order});

  String get _statusMessage {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Your order has been received!';
      case OrderStatus.confirmed:
        return 'Great! Your order is confirmed.';
      case OrderStatus.preparing:
        return 'Our chefs are preparing your food 🍳';
      case OrderStatus.ready:
        return 'Your order is ready! 🎉';
      case OrderStatus.served:
        return 'Enjoy your meal! 😋';
      default:
        return 'Tracking your order...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Confirmation card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Table: ${order.tableId}  •  Total: ${Formatters.price(order.total)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Status message
          Text(
            _statusMessage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (order.estimatedMinutes != null &&
              order.estimatedMinutes! > 0 &&
              order.status != OrderStatus.served) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Est. ${order.estimatedMinutes} min',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          // Status stepper
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: OrderStatusStepper(currentStatus: order.status),
          ),
          const SizedBox(height: 24),
          // Polling indicator
          if (order.status != OrderStatus.served)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Auto-updating every 8 seconds',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          if (order.status == OrderStatus.served) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.offAllNamed(AppRoutes.scanner),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan for New Order'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}