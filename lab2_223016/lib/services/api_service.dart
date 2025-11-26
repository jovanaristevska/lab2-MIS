import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class ApiService {
  static const String _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    final uri = Uri.parse('$_base/categories.php');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = data['categories'] as List<dynamic>;
      return list.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<MealSummary>> getMealsByCategory(String category) async {
    final uri = Uri.parse('$_base/filter.php?c=$category');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = data['meals'] as List<dynamic>;
      return list.map((e) => MealSummary.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load meals for $category');
    }
  }

  /// Search meals by query (global). If category is provided, filter results by category.
  Future<List<MealSummary>> searchMeals(String query, {String? category}) async {
    final uri = Uri.parse('$_base/search.php?s=${Uri.encodeComponent(query)}');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = data['meals'] as List<dynamic>?;
      if (list == null) return [];
      final meals = list.map((e) {
        // search.php returns full meal objects; use summary fields
        return MealSummary(
          id: e['idMeal'] as String,
          name: e['strMeal'] as String,
          thumbnail: e['strMealThumb'] as String,
        );
      }).toList();
      if (category != null && category.isNotEmpty) {
        // Need to filter by category; but search.php returns strCategory field - get raw list again
        final filtered = <MealSummary>[];
        for (final e in list) {
          if (e['strCategory'] != null && e['strCategory'] == category) {
            filtered.add(MealSummary(
              id: e['idMeal'] as String,
              name: e['strMeal'] as String,
              thumbnail: e['strMealThumb'] as String,
            ));
          }
        }
        return filtered;
      }
      return meals;
    } else {
      throw Exception('Search failed');
    }
  }

  Future<MealDetail> getMealDetail(String id) async {
    final uri = Uri.parse('$_base/lookup.php?i=$id');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = data['meals'] as List<dynamic>;
      return MealDetail.fromJson(list.first as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load meal detail');
    }
  }

  Future<MealDetail> getRandomMeal() async {
    final uri = Uri.parse('$_base/random.php');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = data['meals'] as List<dynamic>;
      return MealDetail.fromJson(list.first as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}
