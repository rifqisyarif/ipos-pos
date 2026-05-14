import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipot_pos/local/connectivity_service.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:ipot_pos/utils/formatter.dart';
import '../../models/order.dart';
import '../../navigation/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../state/order_controller.dart';
import '../../components/order_status_stepper.dart';

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
      ),
      body: Obx(() {
        final queue = orderCtrl.queuedOrders;
        final queuedIds = queue.map((q) => q['id']).toSet();
        final orders = orderCtrl.listCurrentOrder
            .where((o) => !queuedIds.contains(o.id))
            .toList();

        return CustomScrollView(
          slivers: [
            // ── Active orders ──────────────────────────────────────
            if (orders.isEmpty)
              SliverToBoxAdapter(
                child: _NoActiveOrder(hasQueue: queue.isNotEmpty),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ActiveOrderSection(order: orders[i]),
                  childCount: orders.length,
                ),
              ),

            // ── Queue section ─────────────────────────────────────
            if (queue.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _QueueHeader(
                  count: queue.length,
                  onRetryAll: orderCtrl.retryAllQueued,
                  onClearAll: () => _confirmClearAll(orderCtrl),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final q = queue[i];
                    return _QueuedOrderTile(
                      key: ValueKey(q['local_id']),
                      queued: q,
                      index: i,
                      isSubmitting: orderCtrl.isSubmitting.value,
                      onRetry: () => orderCtrl.retryQueued(q),
                      onRemove: () =>
                          orderCtrl.removeQueued(q['local_id'] as String),
                    );
                  },
                  childCount: queue.length,
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(
          AppRoutes.menu,
          arguments: Get.find<CartController>().tableId,
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Order More',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _confirmClearAll(OrderController ctrl) {
    Get.defaultDialog(
      title: 'Clear Queue',
      middleText: 'Remove all queued offline orders?',
      textConfirm: 'Clear All',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.accent,
      onConfirm: () {
        ctrl.clearAllQueued();
        Get.back();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active order
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveOrderSection extends StatelessWidget {
  final Order order;
  const _ActiveOrderSection({required this.order});

  String get _statusMessage => switch (order.status) {
        OrderStatus.pending => 'Your order has been received!',
        OrderStatus.confirmed => 'Great! Your order is confirmed.',
        OrderStatus.preparing => 'Our chefs are preparing your food 🍳',
        OrderStatus.ready => 'Your order is ready! 🎉',
        OrderStatus.served => 'Enjoy your meal! 😋',
        _ => 'Tracking your order...',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
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
                const Text('Order Confirmed!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                _Chip(label: 'Order #${order.id}'),
                const SizedBox(height: 10),
                Text(
                  'Table: ${order.tableId}  •  Total: ${Formatters.price(order.total)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Status text
          Center(
            child: Text(_statusMessage,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
          ),

          if (order.estimatedMinutes != null &&
              order.estimatedMinutes! > 0 &&
              order.status != OrderStatus.served) ...[
            const SizedBox(height: 6),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Est. ${order.estimatedMinutes} min',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Stepper
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: OrderStatusStepper(currentStatus: order.status),
          ),

          // Poll indicator
          if (order.status != OrderStatus.served) ...[
            const SizedBox(height: 14),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 11,
                    height: 11,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Auto-updating every 8 s',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No active order
// ─────────────────────────────────────────────────────────────────────────────

class _NoActiveOrder extends StatelessWidget {
  final bool hasQueue;
  const _NoActiveOrder({required this.hasQueue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            hasQueue
                ? 'No active order — see queued orders below'
                : 'No active order yet',
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue section header
// ─────────────────────────────────────────────────────────────────────────────

class _QueueHeader extends StatelessWidget {
  final int count;
  final VoidCallback onRetryAll;
  final VoidCallback onClearAll;

  const _QueueHeader({
    required this.count,
    required this.onRetryAll,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();

    return Obx(() {
      final online = connectivity.isOnline.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Context pill ──────────────────────────────────────
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (online ? AppColors.warning : Colors.grey)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        online ? Icons.schedule : Icons.wifi_off,
                        size: 13,
                        color: online
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$count order${count > 1 ? 's' : ''} in queue',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: online
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (online)
                  Semantics(
                    button: true,
                    label: 'Retry all queued orders',
                    child: GestureDetector(
                      onTap: onRetryAll,
                      child: const Text('Retry All',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  )
                else
                  const Text('Will retry when online',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 14),
                Semantics(
                  button: true,
                  label: 'Clear all queued orders',
                  child: GestureDetector(
                    onTap: onClearAll,
                    child: const Text('Clear',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),

            // ── Subtext: tells user exactly what will happen ──────
            const SizedBox(height: 6),
            Text(
              online
                  ? 'Tap "Retry All" to submit now, or they\'ll send automatically on the next poll.'
                  : 'These orders are saved locally. They\'ll be submitted automatically once you reconnect.',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single queued order tile
// ─────────────────────────────────────────────────────────────────────────────

class _QueuedOrderTile extends StatelessWidget {
  final Map<String, dynamic> queued;
  final int index;
  final bool isSubmitting;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  const _QueuedOrderTile(
      {super.key,
      required this.queued,
      required this.index,
      required this.isSubmitting,
      required this.onRetry,
      required this.onRemove});

  // ── Read directly from the raw map ──────────────────────────────────
  String get _localId => queued['local_id'] as String? ?? '—';
  String get orderId => queued['id'] as String? ?? '—';
  String get _tableId => queued['table_id'] as String? ?? '—';
  double get _total => (queued['total'] as num?)?.toDouble() ?? 0.0;

  int get _itemCount {
    final items = queued['items'] as List?;
    if (items == null) return 0;
    return items.fold<int>(0, (sum, i) => sum + ((i['quantity'] as int?) ?? 1));
  }

  String get _timeAgo {
    final raw = queued['queued_at'] as String?;
    if (raw == null) return '';
    final diff = DateTime.now().difference(DateTime.parse(raw));
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours} hr ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.warning.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: Row(
          children: [
            // Index bubble
            Container(
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          orderId,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _OfflineBadge(),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Table $_tableId  •  $_itemCount item${_itemCount != 1 ? 's' : ''}  •  ${Formatters.price(_total)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (_timeAgo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(_timeAgo,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Semantics(
                  button: true,
                  label: 'Retry order',
                  child: GestureDetector(
                    onTap: isSubmitting ? null : onRetry,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color:
                            isSubmitting ? Colors.grey[200] : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.grey),
                            )
                          : const Text('Retry',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Semantics(
                  button: true,
                  label: 'Remove order',
                  child: GestureDetector(
                    onTap: onRemove,
                    child: const Text('Remove',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600)),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared micro-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text('OFFLINE',
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.warning,
              letterSpacing: 0.5)),
    );
  }
}
