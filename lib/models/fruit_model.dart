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

  // Factory constructor dengan error handling yang lebih baik
  factory FruitModel.fromJson(Map<String, dynamic> json) {
    try {
      // Validasi field yang required
      if (json['name'] == null || json['name'].toString().isEmpty) {
        throw FormatException('Fruit name is required');
      }
      
      if (json['id'] == null) {
        throw FormatException('Fruit id is required');
      }

      return FruitModel(
        name: json['name'].toString(),
        id: _parseToInt(json['id']),
        family: json['family']?.toString() ?? 'Unknown',
        order: json['order']?.toString() ?? 'Unknown',
        genus: json['genus']?.toString() ?? 'Unknown',
        nutritions: json['nutritions'] != null 
            ? Nutritions.fromJson(json['nutritions'] as Map<String, dynamic>)
            : Nutritions.empty(),
      );
    } catch (e) {
      throw FormatException('Error parsing fruit data: $e. Data: $json');
    }
  }

  // Helper method untuk parsing int yang aman
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is double) return value.toInt();
    throw FormatException('Cannot parse $value to int');
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

  // Method untuk membuat list dari JSON array dengan error handling
  static List<FruitModel> fromJsonList(List<dynamic> jsonList) {
    final List<FruitModel> fruits = [];
    final List<String> errors = [];

    for (int i = 0; i < jsonList.length; i++) {
      try {
        final fruit = FruitModel.fromJson(jsonList[i] as Map<String, dynamic>);
        fruits.add(fruit);
      } catch (e) {
        errors.add('Index $i: $e');
        print('Error parsing fruit at index $i: $e');
      }
    }

    if (fruits.isEmpty && errors.isNotEmpty) {
      throw FormatException('Failed to parse any fruits. Errors: ${errors.join(', ')}');
    }

    if (errors.isNotEmpty) {
      print('Warning: ${errors.length} fruits failed to parse out of ${jsonList.length}');
    }

    return fruits;
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
  final double calories;
  
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

  // Factory constructor dengan parsing yang lebih robust
  factory Nutritions.fromJson(Map<String, dynamic> json) {
    try {
      return Nutritions(
        calories: _parseToDouble(json['calories']),
        fat: _parseToDouble(json['fat']),
        sugar: _parseToDouble(json['sugar']),
        carbohydrates: _parseToDouble(json['carbohydrates']),
        protein: _parseToDouble(json['protein']),
      );
    } catch (e) {
      throw FormatException('Error parsing nutrition data: $e. Data: $json');
    }
  }

  // Helper method untuk parsing double yang aman
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0; // Default value instead of throwing error
  }

  // Factory untuk nutritions kosong
  factory Nutritions.empty() {
    return Nutritions(
      calories: 0.0,
      fat: 0.0,
      sugar: 0.0,
      carbohydrates: 0.0,
      protein: 0.0,
    );
  }

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