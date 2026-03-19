import 'package:flutter/material.dart';
import 'package:nordbite/theme.dart';

class CategoryChips extends StatelessWidget {
  final String? selected;
  final void Function(String category) onSelected;

  const CategoryChips({super.key, this.selected, required this.onSelected});

  static const categories = [
    ('Pizza', Icons.local_pizza_rounded),
    ('Burgers', Icons.lunch_dining_rounded),
    ('Tacos', Icons.set_meal_rounded),
    ('Vegetarian', Icons.eco_rounded),
    ('Sushi', Icons.rice_bowl_rounded),
    ('Coffee', Icons.coffee_rounded),
    ('Seafood', Icons.water_rounded),
    ('Italian', Icons.dinner_dining_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, icon) = categories[i];
          final isActive = selected?.toLowerCase() == label.toLowerCase();
          return FilterChip(
            avatar: Icon(
              icon,
              size: 16,
              color: isActive ? NordBiteTheme.coral : NordBiteTheme.charcoal,
            ),
            label: Text(label),
            selected: isActive,
            onSelected: (_) => onSelected(label.toLowerCase()),
            selectedColor: NordBiteTheme.coral.withValues(alpha: 0.15),
            checkmarkColor: NordBiteTheme.coral,
          );
        },
      ),
    );
  }
}
