import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipot_pos/components/menu_item_card.dart';
import 'package:ipot_pos/models/menu_item.dart';

void main() {
  final mockMenuItem = MenuItem(
    id: 1,
    name: 'Sushi Roll',
    description: 'Fresh salmon and avocado',
    price: 12.50,
    categoryId: 2,
    customizationGroups: [],
    imageUrl: null, // Using null to avoid network image issues in tests
  );

  testWidgets('MenuItemCard renders item details correctly', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuItemCard(
            item: mockMenuItem,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // Verify name and description are displayed
    expect(find.text('Sushi Roll'), findsOneWidget);
    expect(find.text('Fresh salmon and avocado'), findsOneWidget);
    
    // Verify price is displayed (depending on Formatter.price implementation)
    // Assuming it formats 12.5 to something like "$12.50" or "12.50"
    expect(find.textContaining('12.50'), findsOneWidget);

    // Verify tap interaction
    await tester.tap(find.byType(MenuItemCard));
    expect(tapped, isTrue);
  });
}
