import 'dart:convert';

List<Category> categoryFromJson(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
  int categoryId;
  String name;

  Category({
    required this.categoryId,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json["category_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "name": name,
      };
}
