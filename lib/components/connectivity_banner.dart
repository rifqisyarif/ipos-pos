import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipot_pos/utils/constant.dart';
import '../local/connectivity_service.dart';

/// Wrap any Scaffold body with this to get the sliding banner.
/// Usage:
///   body: ConnectivityBanner(child: YourWidget()),
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _slide;

  bool _showingRestored = false;
  late final Worker _worker;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slide = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

    final connectivity = Get.find<ConnectivityService>();

    // React to changes
    _worker = ever(connectivity.isOnline, (bool online) {
      if (!mounted) return;
      
      _timer?.cancel();
      
      if (!online) {
        setState(() => _showingRestored = false);
        _anim.forward();
      } else {
        // Show "back online" briefly, then collapse
        setState(() => _showingRestored = true);
        _anim.forward();
        _timer = Timer(const Duration(seconds: 2), () {
          if (mounted && connectivity.isOnline.value) {
             _anim.reverse();
          }
        });
      }
    });

    // Reflect initial state without animation
    if (!connectivity.isOnline.value) _anim.value = 1.0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _worker.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _slide,
          axisAlignment: -1,
          child: _showingRestored
              ? const _BannerContent(
                  color: AppColors.success,
                  icon: Icons.wifi,
                  message: 'Back online',
                  sub: 'Retrying queued orders...',
                )
              : const _BannerContent(
                  color: AppColors.warning,
                  icon: Icons.wifi_off,
                  message: "You're offline",
                  sub: 'Orders will be saved and retried automatically',
                ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _BannerContent extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;
  final String sub;

  const _BannerContent({
    required this.color,
    required this.icon,
    required this.message,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text(sub,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}