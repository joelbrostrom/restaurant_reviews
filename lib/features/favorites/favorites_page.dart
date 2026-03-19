import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Text(
            'My Favorites',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: NordBiteTheme.charcoal,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (_, i) {
              final fav = favorites[i];
              return _FavoriteCard(favorite: fav)
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 50 * i),
                    duration: const Duration(milliseconds: 350),
                  )
                  .slideY(
                    begin: 0.04,
                    delay: Duration(milliseconds: 50 * i),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: NordBiteTheme.coral.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 40,
                color: NordBiteTheme.coral.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
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
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: NordBiteTheme.charcoal.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: NordBiteTheme.charcoal.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in to see favorites',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account to save and manage\nyour favorite restaurants.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
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

class _FavoriteCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> favorite;

  const _FavoriteCard({required this.favorite});

  @override
  ConsumerState<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends ConsumerState<_FavoriteCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.favorite['restaurantName'] as String? ?? 'Restaurant';
    final city = widget.favorite['cachedCity'] as String?;
    final imageUrl = widget.favorite['cachedImageUrl'] as String?;
    final restaurantId = widget.favorite['restaurantId'] as String? ?? '';
    final provider = widget.favorite['provider'] as String? ?? 'foursquare';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap:
            () => Navigator.pushNamed(
              context,
              '/restaurant',
              arguments: {
                'id': restaurantId,
                'provider': provider,
                'name': name,
              },
            ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: NordBiteTheme.charcoal.withValues(
                  alpha: _hovering ? 0.12 : 0.06,
                ),
                blurRadius: _hovering ? 20 : 10,
                offset: Offset(0, _hovering ? 8 : 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (_, _, _) => _placeholder(),
                        )
                        : _placeholder(),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: NordBiteTheme.charcoal,
                        ),
                      ),
                      const Spacer(),
                      if (city != null)
                        Text(
                          city,
                          style: GoogleFonts.karla(
                            fontSize: 12,
                            color: NordBiteTheme.charcoal.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            final firebase = ref.read(firebaseServiceProvider);
                            await firebase.removeFavorite(
                              restaurantId,
                              provider,
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: NordBiteTheme.coral,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Remove',
                                style: GoogleFonts.karla(
                                  fontSize: 12,
                                  color: NordBiteTheme.coral,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            NordBiteTheme.coral.withValues(alpha: 0.12),
            NordBiteTheme.basilGreen.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 32,
          color: NordBiteTheme.coral.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
