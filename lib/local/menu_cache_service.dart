import 'package:hive/hive.dart';

class MenuCacheService {
  static const _boxName = 'menu_cache';
  static const _menuKey = 'menus';

  Future<void> cacheMenus(Map<String, dynamic> menus) async {
    final box = Hive.box(_boxName);

    await box.put(_menuKey, menus);
  }

  Map<String, dynamic> getMenus() {
    final box = Hive.box(_boxName);

    final data = box.get(_menuKey);

    if (data == null) return {};

    return Map<String, dynamic>.from(data);
  }
}
