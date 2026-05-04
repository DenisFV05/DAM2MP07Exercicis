class Category {
  final int id;
  final String name;
  final String description;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }
}

class FoodItem {
  final int id;
  final int categoryId;
  final String name;
  final String country;
  final String description;
  final List<String> ingredients;
  final String image;

  FoodItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.country,
    required this.description,
    required this.ingredients,
    required this.image,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      categoryId: json['categoryId'],
      name: json['name'],
      country: json['country'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      image: json['image'],
    );
  }
}
