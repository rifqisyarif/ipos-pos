import 'package:flutter/material.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:ipot_pos/l10n/app_localizations.dart';
import '../models/order.dart';

class OrderStatusStepper extends StatelessWidget {
  final String currentStatus;

  const OrderStatusStepper({super.key, required this.currentStatus});

  Map<String, String> _getLabels(BuildContext context) {
    return {
      OrderStatus.pending: AppLocalizations.of(context)!.orderReceivedState,
      OrderStatus.confirmed: AppLocalizations.of(context)!.orderConfirmedState,
      OrderStatus.preparing: AppLocalizations.of(context)!.beingPreparedState,
      OrderStatus.ready: AppLocalizations.of(context)!.readyToServeState,
      OrderStatus.served: AppLocalizations.of(context)!.servedState,
    };
  }

  static const _icons = {
    OrderStatus.pending: Icons.receipt_long,
    OrderStatus.confirmed: Icons.check_circle_outline,
    OrderStatus.preparing: Icons.restaurant,
    OrderStatus.ready: Icons.room_service,
    OrderStatus.served: Icons.celebration,
  };

  @override
  Widget build(BuildContext context) {
    final currentIdx = OrderStatus.stepIndex(currentStatus);
    final labels = _getLabels(context);

    return Row(
      children: List.generate(OrderStatus.steps.length, (i) {
        final step = OrderStatus.steps[i];
        final isDone = i < currentIdx;
        final isCurrent = i == currentIdx;
        final isLast = i == OrderStatus.steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success
                            : isCurrent
                                ? AppColors.accent
                                : Colors.grey[200],
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        _icons[step],
                        color: isDone || isCurrent
                            ? Colors.white
                            : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[step] ?? step,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.normal,
                        color: isCurrent
                            ? AppColors.accent
                            : isDone
                                ? AppColors.success
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 28),
                    color:
                        i < currentIdx ? AppColors.success : Colors.grey[200],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
