import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../widgets/category_card.dart';
import 'category_meals_screen.dart';
import 'meal_detail_screen.dart';
import '../models/meal_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  late Future<List<Category>> _categoriesFuture;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _api.getCategories();
  }

  void _openCategory(Category cat) {
    Navigator.pushNamed(
      context,
      CategoryMealsScreen.routeName,
      arguments: cat.name,
    );
  }

  void _openRandom() async {
    try {
      final MealDetail meal = await _api.getRandomMeal();
      Navigator.pushNamed(
        context,
        MealDetailScreen.routeName,
        arguments: meal,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не може да се преземе рандом рецепт: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории јадења'),
        actions: [
          IconButton(
            tooltip: 'Random meal',
            onPressed: _openRandom,
            icon: const Icon(Icons.casino),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Пребарај категории',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() {
                  _search = v.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Грешка: ${snapshot.error}'));
                }
                final cats = snapshot.data ?? [];
                final filtered = _search.isEmpty
                    ? cats
                    : cats
                    .where((c) =>
                c.name.toLowerCase().contains(_search) ||
                    c.description.toLowerCase().contains(_search))
                    .toList();
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final cat = filtered[index];
                    return GestureDetector(
                      onTap: () => _openCategory(cat),
                      child: CategoryCard(category: cat),
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
