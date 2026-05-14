import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get/get.dart';
import 'package:ipot_pos/utils/constant.dart';
import '../state/cart_controller.dart';
import '../navigation/app_routes.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Obx(() {
      final count = cart.itemCount;
      return badges.Badge(
        showBadge: count > 0,
        badgeContent: Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.accent),
        child: IconButton(
          icon: const Icon(Icons.shopping_bag_outlined),
          onPressed: () => Get.toNamed(AppRoutes.cart),
        ),
      );
    });
  }
}