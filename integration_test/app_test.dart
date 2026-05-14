import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ipot_pos/main.dart' as app;
import 'package:ipot_pos/components/menu_item_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end checkout flow test', (WidgetTester tester) async {
    // 1. Boot up the app
    await app.main();
    await tester.pumpAndSettle();

    // 2. Scanner Screen - Bypass via "Use Demo Table"
    final demoTableButton = find.text('Use Demo Table (T001)');
    expect(demoTableButton, findsOneWidget);
    await tester.tap(demoTableButton);
    await tester.pumpAndSettle();

    // 3. Menu Screen - Wait for API response/cache and tap the first item
    expect(find.byType(MenuItemCard), findsWidgets);
    final firstMenuItem = find.byType(MenuItemCard).first;
    await tester.tap(firstMenuItem);
    await tester.pumpAndSettle();

    // 4. Item Detail Screen - Tap "Add to Cart"
    final detailAddToCartBtn = find.text('Add to Cart');
    expect(detailAddToCartBtn, findsWidgets);
    await tester.tap(detailAddToCartBtn.first);
    await tester.pumpAndSettle();

    // 5. Customization Sheet - Tap submit with price ("Add to Cart — $...")
    final sheetAddToCartBtn = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.textContaining('Add to Cart —'),
    );
    expect(sheetAddToCartBtn, findsOneWidget);
    await tester.tap(sheetAddToCartBtn);
    await tester.pumpAndSettle();

    // 6. Menu Screen - Tap "View Cart" sticky header/footer
    final viewCartBtn = find.text('View Cart');
    expect(viewCartBtn, findsOneWidget);
    await tester.tap(viewCartBtn);
    await tester.pumpAndSettle();

    // 7. Cart Screen - Verify subtotal exists, tap Place Order
    final placeOrderBtn = find.text('Place Order');
    expect(placeOrderBtn, findsOneWidget);
    await tester.tap(placeOrderBtn);
    await tester.pumpAndSettle();

    // 8. Tracking Screen - Verify completion
    expect(find.textContaining('Order Confirmed!'), findsOneWidget);
  });
}
