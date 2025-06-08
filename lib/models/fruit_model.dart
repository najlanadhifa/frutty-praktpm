import 'package:hive/hive.dart';

part 'fruit_model.g.dart';

@HiveType(typeId: 1)
class FruitModel extends HiveObject {
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int id;
  
  @HiveField(3)
  final String family;
  
  @HiveField(4)
  final String order;
  
  @HiveField(5)
  final String genus;
  
  @HiveField(6)
  final Nutritions nutritions;

  FruitModel({
    required this.name,
    required this.id,
    required this.family,
    required this.order,
    required this.genus,
    required this.nutritions,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory FruitModel.fromJson(Map<String, dynamic> json) {
    return FruitModel(
      name: json['name'] as String,
      id: json['id'] as int,
      family: json['family'] as String,
      order: json['order'] as String,
      genus: json['genus'] as String,
      nutritions: Nutritions.fromJson(json['nutritions'] as Map<String, dynamic>),
    );
  }

  // Method untuk convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'family': family,
      'order': order,
      'genus': genus,
      'nutritions': nutritions.toJson(),
    };
  }

  // Method untuk membuat list dari JSON array
  static List<FruitModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FruitModel.fromJson(json)).toList();
  }

  @override
  String toString() {
    return 'FruitModel(name: $name, id: $id, family: $family, order: $order, genus: $genus, nutritions: $nutritions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FruitModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 2)
class Nutritions extends HiveObject {
  @HiveField(1)
  final int calories;
  
  @HiveField(2)
  final double fat;
  
  @HiveField(3)
  final double sugar;
  
  @HiveField(4)
  final double carbohydrates;
  
  @HiveField(5)
  final double protein;

  Nutritions({
    required this.calories,
    required this.fat,
    required this.sugar,
    required this.carbohydrates,
    required this.protein,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory Nutritions.fromJson(Map<String, dynamic> json) {
    return Nutritions(
      calories: (json['calories'] as num).toInt(),
      fat: (json['fat'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
    );
  }

  // Method untuk convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'fat': fat,
      'sugar': sugar,
      'carbohydrates': carbohydrates,
      'protein': protein,
    };
  }

  @override
  String toString() {
    return 'Nutritions(calories: $calories, fat: $fat, sugar: $sugar, carbohydrates: $carbohydrates, protein: $protein)';
  }
}
