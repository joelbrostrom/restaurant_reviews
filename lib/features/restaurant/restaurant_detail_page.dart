import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordbite/features/restaurant/image_carousel.dart';
import 'package:nordbite/features/restaurant/rating_widget.dart';
import 'package:nordbite/models/restaurant.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';
import 'package:nordbite/utils/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailPage extends ConsumerWidget {
  final String restaurantId;
  final String provider;
  final String restaurantName;

  const RestaurantDetailPage({
    super.key,
    required this.restaurantId,
    required this.provider,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(
      restaurantDetailProvider((restaurantId, provider)),
    );

    return Scaffold(
      body: detail.when(
        loading: () => _loading(context),
        error: (e, _) => _error(context, e.toString()),
        data: (restaurant) {
          if (restaurant == null)
            return _error(context, 'Restaurant not found');
          return _content(context, ref, restaurant);
        },
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, Restaurant r) {
    final auth = ref.watch(authStateProvider);
    final isSignedIn = auth.value != null;
    return CustomScrollView(
      slivers: [
        // Back button
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'NordBite',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: NordBiteTheme.coral,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
        // Image carousel
        SliverToBoxAdapter(
          child:
              r.hasPhotos
                  ? ImageCarousel(
                    imageUrls: r.imageUrls,
                    fallbackUrl: r.unsplashImageUrl(width: 800, height: 500),
                  )
                  : _fallbackHero(r),
        ),
        // Content
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + category
                    Text(
                      r.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          r.categories.map((c) {
                            return Chip(
                              label: Text(
                                c,
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Rating + distance row
                    Row(
                      children: [
                        if (r.hasRating) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: NordBiteTheme.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: NordBiteTheme.gold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  r.displayRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                if (r.reviewCount != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${r.reviewCount})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: NordBiteTheme.charcoal.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (r.distanceLabel.isNotEmpty) ...[
                          Icon(
                            Icons.near_me_rounded,
                            size: 16,
                            color: NordBiteTheme.charcoal.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            r.distanceLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (r.isOpenNow != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  r.isOpenNow!
                                      ? NordBiteTheme.basilGreen.withValues(
                                        alpha: 0.15,
                                      )
                                      : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r.isOpenNow! ? 'Open now' : 'Closed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    r.isOpenNow!
                                        ? NordBiteTheme.basilGreen
                                        : Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (r.hasWebsite)
                          ElevatedButton.icon(
                            onPressed: () => _launchUrl(r.websiteUrl!),
                            icon: const Icon(Icons.language_rounded, size: 18),
                            label: const Text('Visit Website'),
                          ),
                        if (r.hasPhone)
                          OutlinedButton.icon(
                            onPressed: () => _launchUrl('tel:${r.phone}'),
                            icon: const Icon(Icons.phone_rounded, size: 18),
                            label: const Text('Call'),
                          ),
                        if (isSignedIn) _FavoriteActionButton(restaurant: r),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Description
                    if (r.description != null && r.description!.isNotEmpty) ...[
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Opening hours
                    if (r.openingHours != null &&
                        r.openingHours!.isNotEmpty) ...[
                      Text(
                        'Opening Hours',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: NordBiteTheme.softGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          r.openingHours!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Address
                    if (r.addressLine1 != null || r.addressLine2 != null) ...[
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: NordBiteTheme.softGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: NordBiteTheme.coral,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r.addressLine2 ?? r.addressLine1 ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // User rating
                    if (isSignedIn) ...[
                      Text(
                        'Your Rating',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      RatingWidget(
                        restaurantId: restaurantId,
                        provider: provider,
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: NordBiteTheme.coral.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Sign in to rate this restaurant',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pushNamed(context, '/auth'),
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Attribution
                    Text(
                      r.sourceProvider == 'foursquare'
                          ? 'Powered by Foursquare'
                          : 'Data by Geoapify • © OpenStreetMap contributors',
                      style: TextStyle(
                        fontSize: 11,
                        color: NordBiteTheme.charcoal.withValues(alpha: 0.35),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackHero(Restaurant r) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: CachedNetworkImage(
        imageUrl: r.unsplashImageUrl(width: 800, height: 500),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 280,
        placeholder:
            (_, _) => Shimmer.fromColors(
              baseColor: NordBiteTheme.softGray,
              highlightColor: Colors.white,
              child: Container(color: NordBiteTheme.softGray),
            ),
        errorWidget:
            (_, _, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    NordBiteTheme.coral.withValues(alpha: 0.2),
                    NordBiteTheme.basilGreen.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 56,
                  color: NordBiteTheme.coral.withValues(alpha: 0.4),
                ),
              ),
            ),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Shimmer.fromColors(
            baseColor: NordBiteTheme.softGray,
            highlightColor: Colors.white,
            child: Container(
              height: 280,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NordBiteTheme.softGray,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: NordBiteTheme.softGray,
                  highlightColor: Colors.white,
                  child: Container(
                    width: 200,
                    height: 32,
                    decoration: BoxDecoration(
                      color: NordBiteTheme.softGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: NordBiteTheme.softGray,
                  highlightColor: Colors.white,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: NordBiteTheme.softGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _error(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: NordBiteTheme.charcoal.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Couldn\'t load restaurant',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FavoriteActionButton extends ConsumerStatefulWidget {
  final Restaurant restaurant;
  const _FavoriteActionButton({required this.restaurant});

  @override
  ConsumerState<_FavoriteActionButton> createState() =>
      _FavoriteActionButtonState();
}

class _FavoriteActionButtonState extends ConsumerState<_FavoriteActionButton> {
  bool _isFav = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final firebase = ref.read(firebaseServiceProvider);
    final fav = await firebase.isFavorite(
      widget.restaurant.id,
      widget.restaurant.sourceProvider,
    );
    if (mounted)
      setState(() {
        _isFav = fav;
        _loaded = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return _isFav
        ? OutlinedButton.icon(
          onPressed: _toggle,
          icon: const Icon(Icons.favorite_rounded, size: 18),
          label: const Text('Saved'),
          style: OutlinedButton.styleFrom(
            foregroundColor: NordBiteTheme.coral,
            side: const BorderSide(color: NordBiteTheme.coral),
          ),
        )
        : OutlinedButton.icon(
          onPressed: _toggle,
          icon: const Icon(Icons.favorite_border_rounded, size: 18),
          label: const Text('Save'),
        );
  }

  Future<void> _toggle() async {
    final firebase = ref.read(firebaseServiceProvider);
    final r = widget.restaurant;
    setState(() => _isFav = !_isFav);
    try {
      if (_isFav) {
        await firebase.addFavorite(
          restaurantId: r.id,
          provider: r.sourceProvider,
          restaurantName: r.name,
          cachedCity: r.city,
          cachedImageUrl: r.firstImageUrl,
        );
      } else {
        await firebase.removeFavorite(r.id, r.sourceProvider);
      }
    } catch (e, stack) {
      Log.e('DetailPage', 'Favorite toggle failed for ${r.id}', e, stack);
      if (mounted) setState(() => _isFav = !_isFav);
    }
  }
}
