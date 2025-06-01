class Fruit {
    final String name;
    final int id;
    final String family;
    final String order;
    final String genus;
    final Nutritions nutritions;

    Fruit({
        required this.name,
        required this.id,
        required this.family,
        required this.order,
        required this.genus,
        required this.nutritions,
    });

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

}
