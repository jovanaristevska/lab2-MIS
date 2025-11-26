class MealDetail {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String youtube;
  final Map<String, String> ingredients; // ingredient -> measure

  MealDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    required this.youtube,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final ingredients = <String, String>{};
    for (var i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'] as String?;
      final meas = json['strMeasure$i'] as String?;
      if (ing != null && ing.isNotEmpty) {
        final measure = (meas ?? '').trim();
        if (ing.trim().isNotEmpty) {
          ingredients[ing.trim()] = measure;
        }
      }
    }

    return MealDetail(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String? ?? '',
      category: json['strCategory'] as String? ?? '',
      area: json['strArea'] as String? ?? '',
      instructions: json['strInstructions'] as String? ?? '',
      thumbnail: json['strMealThumb'] as String? ?? '',
      youtube: json['strYoutube'] as String? ?? '',
      ingredients: ingredients,
    );
  }
}
