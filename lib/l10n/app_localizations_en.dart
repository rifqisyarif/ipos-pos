// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IPOT POS';

  @override
  String get scanQrTitle => 'Scan QR Code';

  @override
  String get scanQrSubtitle => 'Point camera at the table QR code';

  @override
  String get torch => 'Torch';

  @override
  String get flip => 'Flip';

  @override
  String get useDemoTable => 'Use Demo Table (T001)';

  @override
  String get invalidQrTitle => 'Invalid QR Code';

  @override
  String get invalidQrDesc => 'Please scan a valid restaurant table QR code.';

  @override
  String get retry => 'Retry';

  @override
  String get menu => 'Menu';

  @override
  String get searchMenu => 'Search menu...';

  @override
  String get noItems => 'No items found';

  @override
  String get loadingMenu => 'Loading menu...';

  @override
  String get viewCart => 'View Cart';

  @override
  String get itemNotFound => 'Item Not Found';

  @override
  String get customizationsAvailable => 'Customizations available';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get myCart => 'My Cart';

  @override
  String get clear => 'Clear';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get clearCartConfirm => 'Remove all items from cart?';

  @override
  String get cancel => 'Cancel';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tax => 'Tax (10%)';

  @override
  String get taxDesc => 'Calculated at checkout';

  @override
  String get total => 'Total';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get browseMenuAdd => 'Browse the menu and add some items!';

  @override
  String get browseMenu => 'Browse Menu';

  @override
  String get orderStatusTitle => 'Order Status';

  @override
  String get orderMore => 'Order More';

  @override
  String get orderReceivedDesc => 'Your order has been received!';

  @override
  String get orderConfirmedDesc => 'Great! Your order is confirmed.';

  @override
  String get orderPreparingDesc => 'Our chefs are preparing your food 🍳';

  @override
  String get orderReadyDesc => 'Your order is ready! 🎉';

  @override
  String get orderServedDesc => 'Enjoy your meal! 😋';

  @override
  String get trackingOrder => 'Tracking your order...';

  @override
  String get orderConfirmedMsg => 'Order Confirmed!';

  @override
  String get autoUpdating => 'Auto-updating every 8 s';

  @override
  String get noActiveOrderQueued => 'No active order — see queued orders below';

  @override
  String get noActiveOrder => 'No active order yet';

  @override
  String ordersInQueue(int count) {
    return '$count order(s) in queue';
  }

  @override
  String get retryAll => 'Retry All';

  @override
  String get willRetryWhenOnline => 'Will retry when online';

  @override
  String get remove => 'Remove';

  @override
  String get offline => 'OFFLINE';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get backOnline => 'Back online';

  @override
  String get requiredLabel => 'Required';

  @override
  String get optionalLabel => 'Optional';

  @override
  String upToN(int max) {
    return 'Up to $max';
  }

  @override
  String get specialInstructions => 'Special instructions (optional)';

  @override
  String addToCartPrice(String price) {
    return 'Add to Cart — $price';
  }

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get orderReceivedState => 'Order\nReceived';

  @override
  String get orderConfirmedState => 'Order\nConfirmed';

  @override
  String get beingPreparedState => 'Being\nPrepared';

  @override
  String get readyToServeState => 'Ready\nto Serve';

  @override
  String get servedState => 'Served!';
}
