import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (label, icon) = categories[i];
          final isActive = selected?.toLowerCase() == label.toLowerCase();
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelected(label.toLowerCase()),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? NordBiteTheme.coral : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isActive
                            ? NordBiteTheme.coral
                            : NordBiteTheme.charcoal.withValues(alpha: 0.08),
                  ),
                  boxShadow:
                      isActive
                          ? [
                            BoxShadow(
                              color: NordBiteTheme.coral.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : [
                            BoxShadow(
                              color: NordBiteTheme.charcoal.withValues(
                                alpha: 0.04,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color:
                          isActive
                              ? Colors.white
                              : NordBiteTheme.charcoal.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: GoogleFonts.karla(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : NordBiteTheme.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
