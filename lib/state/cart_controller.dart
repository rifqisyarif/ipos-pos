import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartController extends GetxController {
  final items = <CartItem>[].obs;
  String tableId = '';

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);

  void addItem(MenuItem menuItem, List<CustomizationOption> options, {String? notes}) {
    final newId = '${menuItem.id}_${DateTime.now().millisecondsSinceEpoch}';
    items.add(CartItem(
      id: newId,
      menuItem: menuItem,
      quantity: 1,
      selectedOptions: options,
      notes: notes,
    ));
    Get.close(2);
    Get.snackbar(
      'Added to cart',
      '${menuItem.name} added!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
    );
  }

  void increment(String cartItemId) {
    final idx = items.indexWhere((i) => i.id == cartItemId);
    if (idx >= 0) {
      items[idx].quantity++;
      items.refresh();
    }
  }

  void decrement(String cartItemId) {
    final idx = items.indexWhere((i) => i.id == cartItemId);
    if (idx >= 0) {
      if (items[idx].quantity <= 1) {
        items.removeAt(idx);
      } else {
        items[idx].quantity--;
        items.refresh();
      }
    }
  }

  void remove(String cartItemId) {
    items.removeWhere((i) => i.id == cartItemId);
  }

  void clear() => items.clear();

  Map<String, dynamic> toOrderPayload() => {
        'table_id': tableId,
        'total': subtotal,
        'items': items.map((i) => i.toOrderJson()).toList(),
      };
}