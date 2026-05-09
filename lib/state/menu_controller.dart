import 'package:get/get.dart';
import '../api/api_client.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';

class MenuController extends GetxController {
  final isLoading = true.obs;
  final error = Rxn<String>();
  final restaurant = Rxn<Restaurant>();
  final categories = <MenuCategory>[].obs;
  final allItems = <MenuItem>[].obs;
  final selectedCategoryId = Rxn<int>();
  final searchQuery = ''.obs;

  List<MenuItem> get filteredItems {
    var items = allItems.toList();
    if (selectedCategoryId.value != null) {
      items = items.where((i) => i.categoryId == selectedCategoryId.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      items = items
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q))
          .toList();
    }
    return items;
  }

  Future<void> loadMenu(String tableId) async {
    isLoading.value = true;
    error.value = null;
    try {
      final data = await ApiClient.fetchMenu(tableId);
      restaurant.value = ApiClient.parseRestaurant(data);
      categories.value = ApiClient.parseCategories(data);
      allItems.value = ApiClient.parseItems(data);
      if (categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
    } catch (e) {
      error.value = 'Failed to load menu. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(int id) {
    selectedCategoryId.value = id;
    searchQuery.value = '';
  }

  void setSearch(String q) => searchQuery.value = q;

  MenuItem? getById(int id) {
    try {
      return allItems.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}