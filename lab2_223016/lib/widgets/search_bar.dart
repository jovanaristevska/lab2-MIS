import 'package:flutter/material.dart';

class SimpleSearchBar extends StatelessWidget {
  final ValueChanged<String> onSubmitted;
  final String hint;

  const SimpleSearchBar({super.key, required this.onSubmitted, this.hint = 'Search'});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
