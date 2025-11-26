import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';

class MealDetailScreen extends StatelessWidget {
  static const routeName = '/meal-detail';
  const MealDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments;
    final MealDetail meal = (arg as MealDetail);

    return Scaffold(
      appBar: AppBar(title: Text(meal.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                meal.thumbnail,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              meal.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (meal.category.isNotEmpty)
              Text('Категорија: ${meal.category} • Кујна: ${meal.area}'),
            const SizedBox(height: 12),
            const Text('Инструкции:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(meal.instructions),
            const SizedBox(height: 12),
            const Text('Состојки:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...meal.ingredients.entries.map((e) {
              final ing = e.key;
              final measure = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('- $ing ${measure.isNotEmpty ? '• $measure' : ''}'),
              );
            }),
            const SizedBox(height: 12),
            if (meal.youtube.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(meal.youtube);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не може да се отвори YouTube линкот')));
                  }
                },
                icon: const Icon(Icons.video_library),
                label: const Text('Отвори YouTube'),
              ),
          ],
        ),
      ),
    );
  }
}
