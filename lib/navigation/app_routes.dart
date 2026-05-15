import 'package:get/get.dart';
import 'package:ipot_pos/screens/cart/cart_screen.dart';
import 'package:ipot_pos/screens/menu/item_detail_screen.dart';
import 'package:ipot_pos/screens/menu/menu_screen.dart';
import 'package:ipot_pos/screens/order_tracking/order_tracking_screen.dart';
import '../screens/scanner/scanner_screen.dart';

class AppRoutes {
  static const scanner = '/';
  static const menu = '/menu';
  static const itemDetail = '/item-detail';
  static const cart = '/cart';
  static const orderTracking = '/order-tracking';

  static final pages = [
    GetPage(name: scanner, page: () => const ScannerScreen()),
    GetPage(
      name: menu,
      page: () => const MenuScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: itemDetail,
      page: () => const ItemDetailScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: cart,
      page: () => const CartScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: orderTracking,
      page: () => const OrderTrackingScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
