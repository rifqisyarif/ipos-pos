import 'package:flutter/material.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:ipot_pos/l10n/app_localizations.dart';

class QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double size;

  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Button(
          icon: Icons.remove,
          onTap: onDecrement,
          size: size,
          color: quantity <= 1 ? AppColors.accent : AppColors.primary,
          semanticLabel: AppLocalizations.of(context)!.decreaseQuantity,
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _Button(
          icon: Icons.add,
          onTap: onIncrement,
          size: size,
          color: AppColors.primary,
          semanticLabel: AppLocalizations.of(context)!.increaseQuantity,
        ),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final String semanticLabel;

  const _Button({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.color,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}
