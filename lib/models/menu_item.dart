class CustomizationOption {
  final int id;
  final String name;
  final double priceModifier;
  bool isSelected;

  CustomizationOption({
    required this.id,
    required this.name,
    required this.priceModifier,
    this.isSelected = false,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) =>
      CustomizationOption(
        id: json['id'],
        name: json['name'],
        priceModifier: (json['price_modifier'] as num).toDouble(),
      );

  CustomizationOption copyWith({bool? isSelected}) => CustomizationOption(
        id: id,
        name: name,
        priceModifier: priceModifier,
        isSelected: isSelected ?? this.isSelected,
      );
}

class CustomizationGroup {
  final int id;
  final String name;
  final bool required;
  final int maxSelections;
  final List<CustomizationOption> options;

  CustomizationGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.maxSelections,
    required this.options,
  });

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) =>
      CustomizationGroup(
        id: json['id'],
        name: json['name'],
        required: json['required'],
        maxSelections: json['max_selections'],
        options: (json['options'] as List)
            .map((o) => CustomizationOption.fromJson(o))
            .toList(),
      );

  List<CustomizationOption> get selectedOptions =>
      options.where((o) => o.isSelected).toList();
}

class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String? imageUrl;
  final List<CustomizationGroup> customizationGroups;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    required this.customizationGroups,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        categoryId: json['category_id'],
        imageUrl: json['image_url'],
        customizationGroups: (json['customization_groups'] as List)
            .map((g) => CustomizationGroup.fromJson(g))
            .toList(),
      );
}