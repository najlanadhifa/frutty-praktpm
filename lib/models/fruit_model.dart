class Fruit {
  final String name;
  final int id;
  final String family;
  final String order;
  final String genus;
  final Nutritions nutritions;
  final int harga; // Field baru untuk harga
  final String gambar; // Field baru untuk URL gambar

  Fruit({
    required this.name,
    required this.id,
    required this.family,
    required this.order,
    required this.genus,
    required this.nutritions,
    required this.harga,
    required this.gambar,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      name: json['name'],
      id: json['id'],
      family: json['family'],
      order: json['order'],
      genus: json['genus'],
      nutritions: Nutritions.fromJson(json['nutritions']),
      harga: (json['harga'] as num?)?.toInt() ?? 0,
      gambar: json['gambar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'family': family,
      'order': order,
      'genus': genus,
      'nutritions': nutritions.toJson(),
      'harga': harga,
      'gambar': gambar,
    };
  }
}

class Nutritions {
  final int calories;
  final double fat;
  final double sugar;
  final double carbohydrates;
  final double protein;

  Nutritions({
    required this.calories,
    required this.fat,
    required this.sugar,
    required this.carbohydrates,
    required this.protein,
  });

  factory Nutritions.fromJson(Map<String, dynamic> json) {
    return Nutritions(
      calories: json['calories'],
      fat: (json['fat'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
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
}