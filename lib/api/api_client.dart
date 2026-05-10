import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ipot_pos/config/app_config.dart';
import 'package:ipot_pos/local/menu_cache_service.dart';
import 'package:ipot_pos/local/order_queue_service.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class ApiClient {
  // ─── Mock data (used when API unavailable) ───────────────────────
  static final _mockData = {
    "restaurant": {"id": "R001", "name": "Sushi Zen", "table_id": "T001"},
    "categories": [
      {"id": 1, "name": "Appetizers", "sort_order": 1},
      {"id": 2, "name": "Main Course", "sort_order": 2},
      {"id": 3, "name": "Drinks", "sort_order": 3},
    ],
    "items": [
      {
        "id": 1,
        "name": "Edamame",
        "description": "Steamed soybeans with sea salt",
        "price": 5.99,
        "category_id": 1,
        "image_url": null,
        "customization_groups": [
          {
            "id": 1,
            "name": "Seasoning",
            "required": false,
            "max_selections": 2,
            "options": [
              {"id": 1, "name": "Sea Salt", "price_modifier": 0},
              {"id": 2, "name": "Truffle Salt", "price_modifier": 1.50},
              {"id": 3, "name": "Chili Flakes", "price_modifier": 0.50}
            ]
          }
        ]
      },
      {
        "id": 2,
        "name": "Salmon Sashimi",
        "description": "Fresh Norwegian salmon, 8 pieces",
        "price": 16.99,
        "category_id": 2,
        "image_url": null,
        "customization_groups": [
          {
            "id": 2,
            "name": "Size",
            "required": true,
            "max_selections": 1,
            "options": [
              {"id": 4, "name": "Regular (8pc)", "price_modifier": 0},
              {"id": 5, "name": "Large (12pc)", "price_modifier": 8.00}
            ]
          }
        ]
      },
      {
        "id": 3,
        "name": "Green Tea",
        "description": "Hot Japanese green tea",
        "price": 3.50,
        "category_id": 3,
        "image_url": null,
        "customization_groups": []
      },
      {
        "id": 4,
        "name": "Chicken Ramen",
        "description": "Rich chicken broth with chashu, egg, and noodles",
        "price": 14.99,
        "category_id": 2,
        "image_url": null,
        "customization_groups": [
          {
            "id": 3,
            "name": "Spice Level",
            "required": true,
            "max_selections": 1,
            "options": [
              {"id": 6, "name": "Mild", "price_modifier": 0},
              {"id": 7, "name": "Medium", "price_modifier": 0},
              {"id": 8, "name": "Spicy", "price_modifier": 0},
              {"id": 9, "name": "Extra Spicy", "price_modifier": 1.00}
            ]
          },
          {
            "id": 4,
            "name": "Add-ons",
            "required": false,
            "max_selections": 3,
            "options": [
              {"id": 10, "name": "Extra Egg", "price_modifier": 2.00},
              {"id": 11, "name": "Extra Chashu", "price_modifier": 4.00},
              {"id": 12, "name": "Corn", "price_modifier": 1.00}
            ]
          }
        ]
      }
    ]
  };

  // ─── Menu ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> fetchMenu(String tableId) async {
    final menuCacheService = MenuCacheService();
    try {
      final uri =
          Uri.parse('${AppConfig.baseUrl}/api/v1/menu?table_id=$tableId');
      final res = await http.get(uri).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        menuCacheService
            .cacheMenus(jsonDecode(res.body)); // Cache menu data to local storage
        return jsonDecode(res.body);
      }
    } catch (_) {
      return menuCacheService.getMenus(); // If request fails because of network/internet issue use cache data
    }
    // Fallback to mock data
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockData;
  }

  static Restaurant parseRestaurant(Map<String, dynamic> data) =>
      Restaurant.fromJson(data['restaurant']);

  static List<MenuCategory> parseCategories(Map<String, dynamic> data) =>
      (data['categories'] as List).map((c) => MenuCategory.fromJson(c)).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  static List<MenuItem> parseItems(Map<String, dynamic> data) =>
      (data['items'] as List).map((i) => MenuItem.fromJson(i)).toList();

  // ─── Orders ───────────────────────────────────────────────────────
  static Future<Order> submitOrder(Map<String, dynamic> payload) async {
    final orderQueueService = OrderQueueService();
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/orders');
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 201) return Order.fromJson(jsonDecode(res.body));
    } catch (_) {
      orderQueueService.addOrder(payload);
    }
    // Mock response
    await Future.delayed(const Duration(seconds: 1));
    return Order.fromJson({
      'id':
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'table_id': payload['table_id'],
      'status': OrderStatus.pending,
      'total': payload['total'],
      'estimated_minutes': 20,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<Order> fetchOrderStatus(
      String orderId, int currentStatusIdx) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/orders/$orderId');
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return Order.fromJson(jsonDecode(res.body));
    } catch (_) {}
    // Mock: cycle through statuses
    await Future.delayed(const Duration(milliseconds: 500));
    const statuses = OrderStatus.steps;
    final idx = currentStatusIdx;
    return Order.fromJson({
      'id': orderId,
      'table_id': 'T001',
      'status': statuses[currentStatusIdx],
      'total': 0.0,
      'estimated_minutes': (20 - idx * 4).clamp(0, 20),
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
