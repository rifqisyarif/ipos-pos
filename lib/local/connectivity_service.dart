import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipot_pos/state/order_controller.dart';

class ConnectivityService extends GetxService {
  final isOnline = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _check(); // immediate check on startup
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _check());
  }

  Future<void> _check() async {
    bool isConnected = false;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      isConnected = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      isConnected = false;
    }

    final wasOffline = !isOnline.value;
    isOnline.value = isConnected;

    // If just came back online, trigger queue drain
    if (wasOffline && isConnected) {
      try {
        Get.find<OrderController>().retryAllQueued();
      } catch (e) {
        //
      }
    }
  }

  void showNoConnectionSnackbar() {
    Get.snackbar(
      'No Connection',
      'Please check your internet connection.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),

      // Fade animation
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,

      // Makes it fade instead of slide
      snackStyle: SnackStyle.FLOATING,
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
