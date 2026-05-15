import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipot_pos/state/cart_controller.dart';
import 'package:ipot_pos/models/menu_item.dart';
import 'package:get/get.dart';

void main() {
  late CartController cartController;

  setUp(() {
    Get.testMode = true;
    cartController = CartController();
  });

  tearDown(() {
    Get.reset();
  });

  group('CartController Tests', () {
    final mockMenuItem = MenuItem(
      id: 1,
      name: 'Test Burger',
      description: 'Delicious test burger',
      price: 10.0,
      categoryId: 1,
      customizationGroups: [],
    );

    // Helper to setup GetX context with enough routes for Get.close(2)
    Future<void> setupGetContext(WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(name: '/detail', page: () => const Scaffold()),
          GetPage(name: '/options', page: () => const Scaffold()),
        ],
      ));
      Get.toNamed('/detail');
      Get.toNamed('/options');
      await tester.pumpAndSettle();
    }

    test('Initial cart should be empty', () {
      expect(cartController.items.length, 0);
      expect(cartController.itemCount, 0);
      expect(cartController.subtotal, 0.0);
    });

    testWidgets('Adding an item should update cart count and subtotal', (tester) async {
      await setupGetContext(tester);
      
      cartController.addItem(mockMenuItem, []);
      // Use a long enough pump to handle GetX snackbar duration and animations
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(cartController.items.length, 1);
      expect(cartController.itemCount, 1);
      expect(cartController.subtotal, 10.0);
    });

    testWidgets('Incrementing quantity should update subtotal', (tester) async {
      await setupGetContext(tester);
      
      cartController.addItem(mockMenuItem, []);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      final cartItemId = cartController.items.first.id;
      cartController.increment(cartItemId);
      
      expect(cartController.items.first.quantity, 2);
      expect(cartController.subtotal, 20.0);
    });

    testWidgets('Decrementing quantity should update subtotal and remove item if quantity < 1', (tester) async {
      await setupGetContext(tester);
      
      cartController.addItem(mockMenuItem, []);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      final cartItemId = cartController.items.first.id;
      cartController.increment(cartItemId); // 2 items
      cartController.decrement(cartItemId); // 1 item
      expect(cartController.items.length, 1);
      
      cartController.decrement(cartItemId); // 0 items, should remove
      expect(cartController.items.length, 0);
    });

    testWidgets('Clearing cart should reset all values', (tester) async {
      await setupGetContext(tester);
      
      cartController.addItem(mockMenuItem, []);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      cartController.clear();
      
      expect(cartController.items.length, 0);
      expect(cartController.subtotal, 0.0);
    });
  });
}
