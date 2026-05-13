import 'dart:async';
import 'package:get/get.dart';
import '../local/order_queue_service.dart';
import '../api/api_client.dart';
import '../models/order.dart';

class OrderController extends GetxController {
  final isSubmitting = false.obs;
  final currentOrder = Rxn<Order>();
  final currentStatusIdx = 0.obs;
  final error = Rxn<String>();

  // Reactive — UI rebuilds whenever the queue changes
  final queuedOrders = <Map<String, dynamic>>[].obs;

  final _queueService = OrderQueueService();
  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    _syncQueue();
  }

  // ─── Sync Hive → reactive list ─────────────────────────────────────
  void _syncQueue() {
    queuedOrders.value = _queueService.getQueuedOrders();
  }

  // ─── Submit (online path) ──────────────────────────────────────────
  Future<bool> submitOrder(Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    error.value = null;
    try {
      final order = await ApiClient.submitOrder(payload);
      currentOrder.value = order;
      _startPolling(order.id);
      return true;
    } catch (e) {
      // Offline — persist to Hive queue with a generated local_id
      error.value = 'No connection. Order saved to queue.';
      await _enqueueOffline(payload);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _enqueueOffline(Map<String, dynamic> payload) async {
    final queued = {
      ...payload,
      'local_id': 'LOCAL-${DateTime.now().millisecondsSinceEpoch}',
      'queued_at': DateTime.now().toIso8601String(),
    };
    await _queueService.addOrder(queued);
    _syncQueue();
  }

  // ─── Retry one queued order ────────────────────────────────────────
  Future<void> retryQueued(Map<String, dynamic> queued) async {
    final localId = queued['local_id'] as String;
    isSubmitting.value = true;
    error.value = null;
    try {
      // Strip queue-only keys before sending to API
      final payload = _toApiPayload(queued);
      final order = await ApiClient.submitOrder(payload);
      await _queueService.removeOrder(localId);
      _syncQueue();
      currentOrder.value = order;
      _startPolling(order.id);
    } catch (e) {
      error.value = 'Still offline. Order kept in queue.';
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── Retry all queued orders in sequence ───────────────────────────
  Future<void> retryAllQueued() async {
    // Snapshot so the list doesn't shift under us mid-loop
    final snapshot = List<Map<String, dynamic>>.from(queuedOrders);
    for (final q in snapshot) {
      await retryQueued(q);
    }
  }

  // ─── Remove one without retrying ──────────────────────────────────
  Future<void> removeQueued(String localId) async {
    await _queueService.removeOrder(localId);
    _syncQueue();
  }

  // ─── Clear the whole queue (no removeAll in service → loop) ───────
  Future<void> clearAllQueued() async {
    final snapshot = List<Map<String, dynamic>>.from(queuedOrders);
    for (final q in snapshot) {
      await _queueService.removeOrder(q['local_id'] as String);
    }
    _syncQueue();
  }

  // ─── Polling ───────────────────────────────────────────────────────
  void _startPolling(String orderId) {
    if (_pollTimer?.isActive == true) _pollTimer?.cancel();

    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      // Drain one offline order per tick before advancing status
      final queue = _queueService.getQueuedOrders();
      if (queue.isNotEmpty) {
        final first = queue.first;
        try {
          await ApiClient.submitOrder(_toApiPayload(first));
          await _queueService.removeOrder(first['local_id'] as String);
          _syncQueue();
        } catch (_) {
          // Still offline — retry next tick
        }
        return;
      }

      try {
        currentStatusIdx.value++;
        final updated = await ApiClient.fetchOrderStatus(
          orderId,
          currentStatusIdx.value,
        );
        currentOrder.value = updated;
        if (updated.status == OrderStatus.served) {
          _pollTimer?.cancel();
        }
      } catch (e) {
        print('polling error: $e');
      }
    });
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  /// Strips queue-only metadata keys so the API never sees them
  Map<String, dynamic> _toApiPayload(Map<String, dynamic> queued) {
    return Map<String, dynamic>.from(queued)
      ..remove('local_id')
      ..remove('queued_at');
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}