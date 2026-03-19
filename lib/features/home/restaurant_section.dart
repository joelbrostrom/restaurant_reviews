import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final accent = accentColor ?? NordBiteTheme.coral;

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: NordBiteTheme.charcoal,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: GoogleFonts.karla(
                              fontSize: 13,
                              color: NordBiteTheme.charcoal.withValues(
                                alpha: 0.5,
                              ),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (onSeeAll != null)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onSeeAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'See all',
                          style: GoogleFonts.karla(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              itemCount: restaurants.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (_, i) {
                return RestaurantCard(restaurant: restaurants[i])
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 60 * i),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(
                      begin: 0.08,
                      delay: Duration(milliseconds: 60 * i),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
