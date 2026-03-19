import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordbite/features/home/hero_carousel.dart';
import 'package:nordbite/features/home/restaurant_section.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';
import 'package:nordbite/widgets/app_drawer.dart';
import 'package:nordbite/widgets/app_header.dart';
import 'package:nordbite/widgets/category_chips.dart';
import 'package:nordbite/widgets/city_selector.dart';
import 'package:nordbite/widgets/shimmer_placeholder.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _citySelectorShown = false;

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final homeData = ref.watch(homeDataProvider);

    // Show city selector when needed
    if (location.needsCitySelector && !_citySelectorShown) {
      _citySelectorShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCitySelector(context);
      });
    }
    if (!location.needsCitySelector) _citySelectorShown = false;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          AppHeader(onMenuTap: () => _scaffoldKey.currentState?.openDrawer()),
          Expanded(
            child:
                location.isLoading
                    ? _loadingState()
                    : homeData.isLoading
                    ? _loadingState()
                    : homeData.error != null
                    ? _errorState(homeData.error!)
                    : _content(homeData),
          ),
        ],
      ),
    );
  }

  Widget _content(HomeData data) {
    return RefreshIndicator(
      onRefresh: () => ref.read(homeDataProvider.notifier).refresh(),
      color: NordBiteTheme.coral,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          const SizedBox(height: 8),
          // Hero
          HeroCarousel(restaurants: data.hero),
          const SizedBox(height: 24),
          // Category chips
          CategoryChips(
            onSelected: (cat) {
              Navigator.pushNamed(
                context,
                '/search',
                arguments: {'query': null, 'category': cat},
              );
            },
          ),
          const SizedBox(height: 28),
          // Featured sections
          RestaurantSection(
            title: 'Featured Nearby',
            subtitle: 'Popular spots close to you',
            icon: Icons.explore_rounded,
            restaurants: data.sections['featured'] ?? [],
            onSeeAll: () => _seeAll(null),
          ),
          RestaurantSection(
            title: 'Vegetarian Options',
            subtitle: 'Plant-forward dining',
            icon: Icons.eco_rounded,
            accentColor: NordBiteTheme.basilGreen,
            restaurants: data.sections['vegetarian'] ?? [],
            onSeeAll: () => _seeAll('vegetarian'),
          ),
          RestaurantSection(
            title: 'Pizza',
            subtitle: 'Slices and pies nearby',
            icon: Icons.local_pizza_rounded,
            restaurants: data.sections['pizza'] ?? [],
            onSeeAll: () => _seeAll('pizza'),
          ),
          RestaurantSection(
            title: 'Burgers',
            subtitle: 'Juicy burgers around you',
            icon: Icons.lunch_dining_rounded,
            restaurants: data.sections['burgers'] ?? [],
            onSeeAll: () => _seeAll('burgers'),
          ),
          RestaurantSection(
            title: 'Tacos',
            subtitle: 'Tacos and Mexican flavors',
            icon: Icons.set_meal_rounded,
            restaurants: data.sections['tacos'] ?? [],
            onSeeAll: () => _seeAll('tacos'),
          ),
          RestaurantSection(
            title: 'Top Rated Nearby',
            subtitle: 'Highest rated in your area',
            icon: Icons.star_rounded,
            accentColor: NordBiteTheme.gold,
            restaurants: data.sections['top_rated'] ?? [],
            onSeeAll: () => _seeAll('top_rated'),
          ),
          // Attribution
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Powered by Foursquare & Geoapify  •  Data © OpenStreetMap contributors',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: NordBiteTheme.charcoal.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _seeAll(String? category) {
    Navigator.pushNamed(
      context,
      '/search',
      arguments: {'query': null, 'category': category},
    );
  }

  Widget _loadingState() {
    return ListView(
      children: const [
        SizedBox(height: 16),
        ShimmerHero(),
        SizedBox(height: 32),
        ShimmerSection(),
        SizedBox(height: 24),
        ShimmerSection(),
      ],
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: NordBiteTheme.charcoal.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t load restaurants right now.\nCheck your connection and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.read(homeDataProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
