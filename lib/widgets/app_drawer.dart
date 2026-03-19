import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'NordBite',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        color: NordBiteTheme.coral,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              if (location.cityName != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: NordBiteTheme.charcoal.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.cityName!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _DrawerItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () => _navigate(context, '/'),
                    ),
                    _DrawerItem(
                      icon: Icons.favorite_rounded,
                      label: 'Favorites',
                      onTap: () => _navigate(context, '/favorites'),
                    ),
                    const Divider(height: 24, indent: 20, endIndent: 20),
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
                    const Divider(height: 24, indent: 20, endIndent: 20),
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
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
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
    return ListTile(
      leading: Icon(icon, size: 22, color: color ?? NordBiteTheme.charcoal),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }
}
