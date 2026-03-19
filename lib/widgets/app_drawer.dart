import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';
import 'package:nordbite/widgets/city_selector.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final isSignedIn = auth.value != null;
    final location = ref.watch(locationProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Drawer(
        backgroundColor: NordBiteTheme.warmWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'NordBite',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: NordBiteTheme.coral,
                      ),
                    ),
                    const Spacer(),
                    _CloseBtn(onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),
              if (location.cityName != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: NordBiteTheme.charcoal.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.cityName!,
                        style: GoogleFonts.karla(
                          fontSize: 13,
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Divider(
                height: 1,
                color: NordBiteTheme.charcoal.withValues(alpha: 0.06),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _DrawerItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () => _navigate(context, '/'),
                    ),
                    _DrawerItem(
                      icon: Icons.favorite_rounded,
                      label: 'Favorites',
                      color: NordBiteTheme.coral,
                      onTap: () => _navigate(context, '/favorites'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Divider(
                        height: 1,
                        color: NordBiteTheme.charcoal.withValues(alpha: 0.06),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        bottom: 8,
                        top: 4,
                      ),
                      child: Text(
                        'EXPLORE',
                        style: GoogleFonts.karla(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.3),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    _DrawerItem(
                      icon: Icons.explore_rounded,
                      label: 'Nearby',
                      onTap: () => _navigateSearch(context, null),
                    ),
                    _DrawerItem(
                      icon: Icons.eco_rounded,
                      label: 'Vegetarian',
                      color: NordBiteTheme.basilGreen,
                      onTap: () => _navigateSearch(context, 'vegetarian'),
                    ),
                    _DrawerItem(
                      icon: Icons.local_pizza_rounded,
                      label: 'Pizza',
                      onTap: () => _navigateSearch(context, 'pizza'),
                    ),
                    _DrawerItem(
                      icon: Icons.lunch_dining_rounded,
                      label: 'Burgers',
                      onTap: () => _navigateSearch(context, 'burgers'),
                    ),
                    _DrawerItem(
                      icon: Icons.set_meal_rounded,
                      label: 'Tacos',
                      onTap: () => _navigateSearch(context, 'tacos'),
                    ),
                    _DrawerItem(
                      icon: Icons.star_rounded,
                      label: 'Top Rated',
                      color: NordBiteTheme.gold,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/search',
                          arguments: {'query': null, 'category': 'top_rated'},
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Divider(
                        height: 1,
                        color: NordBiteTheme.charcoal.withValues(alpha: 0.06),
                      ),
                    ),
                    _DrawerItem(
                      icon: Icons.location_city_rounded,
                      label: 'Change City',
                      onTap: () {
                        Navigator.pop(context);
                        showCitySelector(context);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: NordBiteTheme.charcoal.withValues(alpha: 0.06),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child:
                      isSignedIn
                          ? OutlinedButton.icon(
                            onPressed: () {
                              ref.read(firebaseServiceProvider).signOut();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Sign Out'),
                          )
                          : ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/auth');
                            },
                            icon: const Icon(Icons.person_rounded, size: 18),
                            label: const Text('Sign In'),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  void _navigateSearch(BuildContext context, String? category) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/search',
      arguments: {'query': null, 'category': category},
    );
  }
}

class _CloseBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: NordBiteTheme.charcoal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.close_rounded, size: 20),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (color ?? NordBiteTheme.charcoal).withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color:
                        color ?? NordBiteTheme.charcoal.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: GoogleFonts.karla(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: NordBiteTheme.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
