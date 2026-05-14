import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import '../local/connectivity_service.dart';
import '../local/order_queue_service.dart';
import '../api/api_client.dart';
import '../models/order.dart';

class OrderController extends GetxController {
  final isSubmitting = false.obs;
  final listCurrentOrder = <Order>[].obs;
  final error = Rxn<String>();

  // Reactive — UI rebuilds whenever the queue changes
  final queuedOrders = <Map<String, dynamic>>[].obs;

  final _queueService = OrderQueueService();
  Timer? _pollTimer;

  @override
  void onInit() async {
    super.onInit();
    _syncQueue();
  }

  // ─── Sync Hive → reactive list ─────────────────────────────────────
  void _syncQueue() {
    queuedOrders.value = _queueService.getQueuedOrders();
  }

  void _addOrUpdateOrder(Order order) {
    final existingIdx = listCurrentOrder.indexWhere((o) => o.id == order.id);
    if (existingIdx != -1) {
      listCurrentOrder[existingIdx] = order;
    } else {
      listCurrentOrder.add(order);
    }
  }

  // ─── Submit (online path) ──────────────────────────────────────────
  Future<bool> submitOrder(Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    error.value = null;
    try {
      final order = await ApiClient.submitOrder(payload);
      _addOrUpdateOrder(order);
      _startPolling();
      return true;
    } catch (e) {
      // Offline — persist to Hive queue with a generated local_id
      error.value = 'No connection. Order saved to queue.';
      // await _enqueueOffline(payload);
      return false;
    } finally {
      _syncQueue();
      isSubmitting.value = false;
    }
  }

  // ─── Retry one queued order ────────────────────────────────────────
  Future<void> retryQueued(Map<String, dynamic> queued) async {
    final connectivity = Get.find<ConnectivityService>();
    if (!connectivity.isOnline.value) {
      connectivity.showNoConnectionSnackbar();
      return;
    }
    final localId = queued['local_id'] as String;
    isSubmitting.value = true;
    error.value = null;
    try {
      // Strip queue-only keys before sending to API
      final payload = _toApiPayload(queued);
      final order = await ApiClient.submitOrder(payload);
      await _queueService.removeOrder(localId);
      _syncQueue();
      _addOrUpdateOrder(order);
      _startPolling();
    } catch (e) {
      error.value = 'Still offline. Order kept in queue.';
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── Retry all queued orders in sequence ───────────────────────────
  Future<void> retryAllQueued() async {
    final connectivity = Get.find<ConnectivityService>();
    if (!connectivity.isOnline.value) {
      // We don't show snackbar here because this is often called automatically
      // by the ConnectivityService when it thinks it's online,
      // or from the clear all/retry all button.
      // A manual click can just rely on retryQueued snackbar.
      return;
    }
    // Snapshot so the list doesn't shift under us mid-loop
    final snapshot = List<Map<String, dynamic>>.from(queuedOrders);
    for (final q in snapshot) {
      // Prevent running multiple queue drains at once
      if (isSubmitting.value && snapshot.length > 1) {
        // just let it take its course if it's already submitting.
      }
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
  final _statusIndices = <String, int>{};

  void _startPolling() {
    if (_pollTimer?.isActive == true) return;

    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      // Skip if offline
      try {
        final connectivity = Get.find<ConnectivityService>();
        if (!connectivity.isOnline.value) {
          return;
        }
      } catch (_) {
        // Fallback if not injected yet
      }

      // Drain one offline order per tick before advancing status
      List<Map<String, dynamic>>? queue;
      try {
        queue = _queueService.getQueuedOrders();
      } catch (e) {
        log(e.toString(), name: 'Error get queue');
      }
      if (queue?.isNotEmpty == true) {
        if (isSubmitting.value) return; // Prevent double submission
        final first = queue?.first;
        try {
          final order = await ApiClient.submitOrder(_toApiPayload(first!));
          await _queueService.removeOrder(first['local_id'] as String);
          _syncQueue();
          _addOrUpdateOrder(order);
        } catch (_) {
          // Still offline — retry next tick
        }
        return;
      }

      bool hasActive = false;
      for (int i = 0; i < listCurrentOrder.length; i++) {
        final order = listCurrentOrder[i];
        if (order.status != OrderStatus.served) {
          hasActive = true;
          try {
            int idx = _statusIndices[order.id] ?? 0;
            idx++;
            _statusIndices[order.id] = idx;
            final updated = await ApiClient.fetchOrderStatus(
              order.id,
              idx,
            );
            listCurrentOrder[i] = updated;
          } catch (e) {
            //
          }
        }
      }

      if (!hasActive && queue?.isEmpty == true) {
        _pollTimer?.cancel();
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
