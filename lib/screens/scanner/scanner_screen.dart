import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipot_pos/state/cart_controller.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ipot_pos/l10n/app_localizations.dart';
import '../../navigation/app_routes.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final raw = barcode.rawValue!;
    final tableId = _parseTableId(raw);

    if (tableId == null) {
      setState(() => _scanned = true);
      _controller.stop();
      Get.defaultDialog(
        title: AppLocalizations.of(context)!.invalidQrTitle,
        middleText: AppLocalizations.of(context)!.invalidQrDesc,
        barrierDismissible: false,
        textConfirm: AppLocalizations.of(context)!.retry,
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary,
        onConfirm: () {
          Get.back(); // close dialog
          setState(() => _scanned = false);
          _controller.start();
        },
      );
      return;
    }

    setState(() => _scanned = true);
    Get.find<CartController>().tableId = tableId;
    Get.toNamed(AppRoutes.menu, arguments: tableId);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _scanned = false);
    });
  }

  String? _parseTableId(String raw) {
    // Expects: ipot://table/{tableId}
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    if (uri.scheme != 'ipot') return null;
    if (uri.host != 'table') return null;
    final segments = uri.pathSegments;
    if (segments.isEmpty) {
      // Also handle ipot://table/T001 where T001 is the host
      return uri.host == 'table' ? uri.path.replaceAll('/', '') : null;
    }
    return segments.first.isNotEmpty ? segments.first : null;
  }

  void _useDemoTable() {
    const tableId = 'T001';
    Get.find<CartController>().tableId = tableId;
    Get.toNamed(AppRoutes.menu, arguments: tableId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay
          _ScannerOverlay(),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.scanQrTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.scanQrSubtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.flash_on,
                          label: 'Torch',
                          onTap: () => _controller.toggleTorch(),
                        ),
                        const SizedBox(width: 24),
                        _ActionButton(
                          icon: Icons.flip_camera_ios,
                          label: 'Flip',
                          onTap: () => _controller.switchCamera(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _useDemoTable,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white38, width: 1),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.useDemoTable,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const boxSize = 260.0;

    return Stack(
      children: [
        // Dimmed areas
        Positioned.fill(
          child: CustomPaint(
            painter: _OverlayPainter(
              center: Offset(size.width / 2, size.height / 2),
              boxSize: boxSize,
            ),
          ),
        ),
        // Corner brackets
        Center(
          child: SizedBox(
            width: boxSize,
            height: boxSize,
            child: Stack(
              children: const [
                _Corner(corner: Alignment.topLeft),
                _Corner(corner: Alignment.topRight),
                _Corner(corner: Alignment.bottomLeft),
                _Corner(corner: Alignment.bottomRight),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Offset center;
  final double boxSize;

  _OverlayPainter({required this.center, required this.boxSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final half = boxSize / 2;
    final rect =
        Rect.fromCenter(center: center, width: boxSize, height: boxSize);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12))),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Corner extends StatelessWidget {
  final Alignment corner;
  const _Corner({required this.corner});

  @override
  Widget build(BuildContext context) {
    final isTop = corner == Alignment.topLeft || corner == Alignment.topRight;
    final isLeft =
        corner == Alignment.topLeft || corner == Alignment.bottomLeft;
    const len = 28.0;
    const thick = 4.0;

    return Align(
      alignment: corner,
      child: SizedBox(
        width: len + thick,
        height: len + thick,
        child: CustomPaint(
          painter: _CornerPainter(
            isTop: isTop,
            isLeft: isLeft,
            color: AppColors.accent,
            length: len,
            thickness: thick,
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop, isLeft;
  final Color color;
  final double length, thickness;

  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
    required this.length,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = isLeft ? thickness / 2 : size.width - thickness / 2;
    final y = isTop ? thickness / 2 : size.height - thickness / 2;

    canvas.drawLine(
      Offset(x, y),
      Offset(isLeft ? x + length : x - length, y),
      paint,
    );
    canvas.drawLine(
      Offset(x, y),
      Offset(x, isTop ? y + length : y - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
