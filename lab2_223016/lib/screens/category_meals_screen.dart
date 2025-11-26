import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal_summary.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class CategoryMealsScreen extends StatefulWidget {
  static const routeName = '/category-meals';
  const CategoryMealsScreen({super.key});

  @override
  State<CategoryMealsScreen> createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  final ApiService _api = ApiService();
  late Future<List<MealSummary>> _mealsFuture;
  String category = '';
  String _search = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    category = (arg as String?) ?? '';
    _mealsFuture = _api.getMealsByCategory(category);
  }

  void _openMeal(String id) async {
    try {
      final mealDetail = await _api.getMealDetail(id);
      Navigator.pushNamed(context, MealDetailScreen.routeName, arguments: mealDetail);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Грешка при отворање рецепт: $e')));
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _search = query.trim();
      // We'll not change _mealsFuture here; we'll use search results separately
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Јадења: $category'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Пребарај јадења (во оваа категорија)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (q) => _performSearch(q),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MealSummary>>(
              future: _mealsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Грешка: ${snapshot.error}'));
                }
                final meals = snapshot.data ?? [];

                if (_search.isNotEmpty) {
                  // call search endpoint and filter by category
                  return FutureBuilder<List<MealSummary>>(
                    future: _api.searchMeals(_search, category: category),
                    builder: (c2, sn2) {
                      if (sn2.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (sn2.hasError) {
                        return Center(child: Text('Грешка: ${sn2.error}'));
                      }
                      final results = sn2.data ?? [];
                      if (results.isEmpty) {
                        return const Center(child: Text('Нема резултати'));
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final m = results[index];
                          return GestureDetector(
                            onTap: () => _openMeal(m.id),
                            child: MealCard(meal: m),
                          );
                        },
                      );
                    },
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final m = meals[index];
                    return GestureDetector(
                      onTap: () => _openMeal(m.id),
                      child: MealCard(meal: m),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
