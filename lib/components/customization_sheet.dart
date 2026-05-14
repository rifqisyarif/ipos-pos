import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:ipot_pos/utils/formatter.dart';
import 'package:ipot_pos/l10n/app_localizations.dart';
import '../models/menu_item.dart';
import '../state/cart_controller.dart';

class CustomizationSheet extends StatefulWidget {
  final MenuItem item;

  const CustomizationSheet({super.key, required this.item});

  static Future<void> show(MenuItem item) async {
    await Get.bottomSheet(
      CustomizationSheet(item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<CustomizationSheet> createState() => _CustomizationSheetState();
}

class _CustomizationSheetState extends State<CustomizationSheet> {
  late final List<CustomizationGroup> _groups;
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Deep-copy groups to manage local selection state
    _groups = widget.item.customizationGroups
        .map((g) => CustomizationGroup(
              id: g.id,
              name: g.name,
              required: g.required,
              maxSelections: g.maxSelections,
              options: g.options.map((o) => o.copyWith()).toList(),
            ))
        .toList();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    for (final g in _groups) {
      if (g.required && g.selectedOptions.isEmpty) return false;
    }
    return true;
  }

  double get _extraCost => _groups.fold(0.0, (sum, g) {
        return sum + g.selectedOptions.fold(0.0, (s, o) => s + o.priceModifier);
      });

  void _toggle(CustomizationGroup group, CustomizationOption option) {
    setState(() {
      if (option.isSelected) {
        option.isSelected = false;
      } else {
        if (group.maxSelections == 1) {
          for (final o in group.options) {
            o.isSelected = false;
          }
        }
        final currentSelected = group.options.where((o) => o.isSelected).length;
        if (currentSelected < group.maxSelections) {
          option.isSelected = true;
        }
      }
    });
  }

  void _addToCart() {
    if (!_canSubmit) {
      Get.snackbar(
        'Required',
        'Please make all required selections.',
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
      return;
    }
    final allSelected =
        _groups.expand((g) => g.options.where((o) => o.isSelected)).toList();
    Get.find<CartController>().addItem(
      widget.item,
      allSelected,
      notes: _notes.text.isNotEmpty ? _notes.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.item.price + _extraCost;

    return TapRegion(
      onTapOutside: (e) {
        Get.back();
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.65,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.item.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          Text(widget.item.description,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.price(widget.item.price),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Customization groups
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ..._groups.map((g) => _GroupWidget(
                          group: g,
                          onToggle: (o) => _toggle(g, o),
                        )),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notes,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.specialInstructions,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              // Add to cart
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _addToCart : null,
                      child: Text(
                          AppLocalizations.of(context)!.addToCartPrice(Formatters.price(totalPrice)),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupWidget extends StatelessWidget {
  final CustomizationGroup group;
  final ValueChanged<CustomizationOption> onToggle;

  const _GroupWidget({required this.group, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(group.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: group.required
                      ? AppColors.accent.withOpacity(0.12)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  group.required ? AppLocalizations.of(context)!.requiredLabel : AppLocalizations.of(context)!.optionalLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: group.required
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (group.maxSelections > 1) ...[
                const SizedBox(width: 6),
                Text(AppLocalizations.of(context)!.upToN(group.maxSelections),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ]
            ],
          ),
        ),
        ...group.options.map((o) => Semantics(
              button: true,
              toggled: o.isSelected,
              label: '${o.name}, extra ${Formatters.priceModifier(o.priceModifier)}',
              child: GestureDetector(
                onTap: () => onToggle(o),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: o.isSelected
                        ? AppColors.primary.withOpacity(0.06)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          o.isSelected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        group.maxSelections == 1
                            ? (o.isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off)
                            : (o.isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank),
                        color: o.isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(o.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: o.isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            )),
                      ),
                      Text(
                        Formatters.priceModifier(o.priceModifier),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: o.priceModifier > 0
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        const SizedBox(height: 4),
      ],
    );
  }
}
