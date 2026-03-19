import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';
import 'package:nordbite/widgets/app_drawer.dart';
import 'package:nordbite/widgets/app_header.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final favoritesAsync = ref.watch(favoritesStreamProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          AppHeader(onMenuTap: () => _scaffoldKey.currentState?.openDrawer()),
          Expanded(
            child: auth.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _signInPrompt(context),
              data: (user) {
                if (user == null) return _signInPrompt(context);
                return favoritesAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (favorites) {
                    if (favorites.isEmpty) return _emptyState(context);
                    return _favoritesList(context, favorites);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoritesList(
    BuildContext context,
    List<Map<String, dynamic>> favorites,
  ) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: favorites.length,
      itemBuilder: (_, i) {
        final fav = favorites[i];
        return _FavoriteCard(favorite: fav)
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 60 * i),
              duration: const Duration(milliseconds: 350),
            )
            .slideY(
              begin: 0.05,
              delay: Duration(milliseconds: 60 * i),
              duration: const Duration(milliseconds: 350),
            );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: NordBiteTheme.coral.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Discover restaurants and save your favorites here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:
                  () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (r) => false,
                  ),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Explore Restaurants'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signInPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 56,
              color: NordBiteTheme.charcoal.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to see favorites',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account to save and manage your favorite restaurants.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  final Map<String, dynamic> favorite;

  const _FavoriteCard({required this.favorite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = favorite['restaurantName'] as String? ?? 'Restaurant';
    final city = favorite['cachedCity'] as String?;
    final imageUrl = favorite['cachedImageUrl'] as String?;
    final restaurantId = favorite['restaurantId'] as String? ?? '';
    final provider = favorite['provider'] as String? ?? 'foursquare';

    return GestureDetector(
      onTap:
          () => Navigator.pushNamed(
            context,
            '/restaurant',
            arguments: {'id': restaurantId, 'provider': provider, 'name': name},
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: NordBiteTheme.charcoal.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child:
                  imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, _, _) => _placeholder(),
                      )
                      : _placeholder(),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (city != null)
                      Text(
                        city,
                        style: TextStyle(
                          fontSize: 12,
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.5),
                        ),
                      ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final firebase = ref.read(firebaseServiceProvider);
                        await firebase.removeFavorite(restaurantId, provider);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            size: 14,
                            color: NordBiteTheme.coral,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Remove',
                            style: TextStyle(
                              fontSize: 11,
                              color: NordBiteTheme.coral,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NordBiteTheme.coral.withValues(alpha: 0.15),
            NordBiteTheme.basilGreen.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 32,
          color: NordBiteTheme.coral.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
