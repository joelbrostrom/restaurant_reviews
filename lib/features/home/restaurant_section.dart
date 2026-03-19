import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nordbite/models/restaurant.dart';
import 'package:nordbite/theme.dart';
import 'package:nordbite/widgets/restaurant_card.dart';

class RestaurantSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Restaurant> restaurants;
  final VoidCallback? onSeeAll;
  final IconData? icon;
  final Color? accentColor;

  const RestaurantSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.restaurants,
    this.onSeeAll,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 22,
                    color: accentColor ?? NordBiteTheme.coral,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                if (onSeeAll != null)
                  TextButton(onPressed: onSeeAll, child: const Text('See all')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: restaurants.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (_, i) {
                return RestaurantCard(restaurant: restaurants[i])
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 80 * i),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(
                      begin: 0.1,
                      delay: Duration(milliseconds: 80 * i),
                      duration: const Duration(milliseconds: 400),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
