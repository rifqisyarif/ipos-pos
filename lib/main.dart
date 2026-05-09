import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:ipot_pos/navigation/app_routes.dart';
import 'package:ipot_pos/state/cart_controller.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Register global CartController
    Get.put(CartController(), permanent: true);
    
    return GetMaterialApp(
      getPages: AppRoutes.pages,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
    );
  }
}
