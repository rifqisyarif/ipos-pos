class Restaurant {
  final String id;
  final String name;
  final String tableId;

  Restaurant({required this.id, required this.name, required this.tableId});

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'],
        name: json['name'],
        tableId: json['table_id'],
      );
}

class MenuCategory {
  final int id;
  final String name;
  final int sortOrder;

  MenuCategory({required this.id, required this.name, required this.sortOrder});

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: json['id'],
        name: json['name'],
        sortOrder: json['sort_order'],
      );
}
