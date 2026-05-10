import 'dart:async';
import 'package:get/get.dart';
import '../api/api_client.dart';
import '../models/order.dart';

class OrderController extends GetxController {
  final isSubmitting = false.obs;
  final currentOrder = Rxn<Order>();
  final error = Rxn<String>();

  Timer? _pollTimer;

  Future<bool> submitOrder(Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    error.value = null;
    try {
      final order = await ApiClient.submitOrder(payload);
      currentOrder.value = order;
      _startPolling(order.id);
      return true;
    } catch (e) {
      error.value = 'Failed to submit order. Please try again.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _startPolling(String orderId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      try {
        final updated = await ApiClient.fetchOrderStatus(orderId);
        currentOrder.value = updated;
        if (updated.status == OrderStatus.served) {
          _pollTimer?.cancel();
        }
      } catch (_) {}
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}