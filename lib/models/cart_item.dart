import 'menu_item.dart';

class CartItem {
  final String id; // unique per cart entry
  final MenuItem menuItem;
  int quantity;
  final List<CustomizationOption> selectedOptions;
  final String? notes;

  CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.selectedOptions,
    this.notes,
  });

  double get unitPrice =>
      menuItem.price +
      selectedOptions.fold(0.0, (sum, o) => sum + o.priceModifier);

  double get totalPrice => unitPrice * quantity;

  String get customizationSummary =>
      selectedOptions.map((o) => o.name).join(', ');

  Map<String, dynamic> toOrderJson() => {
        'item_id': menuItem.id,
        'quantity': quantity,
        'selected_options': selectedOptions.map((o) => o.id).toList(),
        'notes': notes,
      };
}
