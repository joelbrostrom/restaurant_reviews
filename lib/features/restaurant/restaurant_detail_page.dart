import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
          if (restaurant == null) {
            return _error(context, 'Restaurant not found');
          }
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
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _BackButton(onTap: () => Navigator.pop(context)),
                  const Spacer(),
                  Text(
                    'NordBite',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: NordBiteTheme.coral,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child:
              r.hasPhotos
                  ? ImageCarousel(
                    imageUrls: r.imageUrls,
                    fallbackUrl: r.unsplashImageUrl(width: 800, height: 500),
                  )
                  : _fallbackHero(r),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children:
                          r.categories.map((c) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: NordBiteTheme.charcoal.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                c,
                                style: GoogleFonts.karla(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Rating + distance + open status
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (r.hasRating)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: NordBiteTheme.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: NordBiteTheme.gold,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  r.displayRating.toStringAsFixed(1),
                                  style: GoogleFonts.karla(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: NordBiteTheme.charcoal,
                                  ),
                                ),
                                if (r.reviewCount != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${r.reviewCount})',
                                    style: GoogleFonts.karla(
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
                        if (r.distanceLabel.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.near_me_rounded,
                                size: 16,
                                color: NordBiteTheme.charcoal.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                r.distanceLabel,
                                style: GoogleFonts.karla(
                                  fontSize: 14,
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (r.isOpenNow != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  r.isOpenNow!
                                      ? NordBiteTheme.basilGreen.withValues(
                                        alpha: 0.1,
                                      )
                                      : Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        r.isOpenNow!
                                            ? NordBiteTheme.basilGreen
                                            : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  r.isOpenNow! ? 'Open now' : 'Closed',
                                  style: GoogleFonts.karla(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        r.isOpenNow!
                                            ? NordBiteTheme.basilGreen
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
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
                    const SizedBox(height: 32),
                    // Description
                    if (r.description != null && r.description!.isNotEmpty) ...[
                      _SectionTitle(title: 'About'),
                      const SizedBox(height: 10),
                      Text(
                        r.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
                    ],
                    // Opening hours
                    if (r.openingHours != null &&
                        r.openingHours!.isNotEmpty) ...[
                      _SectionTitle(title: 'Opening Hours'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: NordBiteTheme.charcoal.withValues(
                              alpha: 0.06,
                            ),
                          ),
                        ),
                        child: Text(
                          r.openingHours!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    // Address
                    if (r.addressLine1 != null || r.addressLine2 != null) ...[
                      _SectionTitle(title: 'Location'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: NordBiteTheme.charcoal.withValues(
                              alpha: 0.06,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: NordBiteTheme.coral.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: NordBiteTheme.coral,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                r.addressLine2 ?? r.addressLine1 ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    // User rating
                    if (isSignedIn) ...[
                      _SectionTitle(title: 'Your Rating'),
                      const SizedBox(height: 10),
                      RatingWidget(
                        restaurantId: restaurantId,
                        provider: provider,
                      ),
                      const SizedBox(height: 28),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: NordBiteTheme.coral.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: NordBiteTheme.coral.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Sign in to rate this restaurant',
                              style: GoogleFonts.karla(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: NordBiteTheme.charcoal,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pushNamed(context, '/auth'),
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    // Attribution
                    Text(
                      r.sourceProvider == 'foursquare'
                          ? 'Powered by Foursquare'
                          : 'Data by Geoapify • © OpenStreetMap contributors',
                      style: GoogleFonts.karla(
                        fontSize: 11,
                        color: NordBiteTheme.charcoal.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 48),
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
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
      child: CachedNetworkImage(
        imageUrl: r.unsplashImageUrl(width: 800, height: 500),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
        placeholder:
            (_, _) => Shimmer.fromColors(
              baseColor: const Color(0xFFF3F0ED),
              highlightColor: Colors.white,
              child: Container(color: const Color(0xFFF3F0ED)),
            ),
        errorWidget:
            (_, _, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    NordBiteTheme.coral.withValues(alpha: 0.15),
                    NordBiteTheme.basilGreen.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 56,
                  color: NordBiteTheme.coral.withValues(alpha: 0.3),
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
            baseColor: const Color(0xFFF3F0ED),
            highlightColor: Colors.white,
            child: Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0ED),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: const Color(0xFFF3F0ED),
                  highlightColor: Colors.white,
                  child: Container(
                    width: 220,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: const Color(0xFFF3F0ED),
                  highlightColor: Colors.white,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0ED),
                      borderRadius: BorderRadius.circular(10),
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
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: NordBiteTheme.coral.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: NordBiteTheme.charcoal.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 24),
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

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: NordBiteTheme.charcoal.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: NordBiteTheme.charcoal,
      ),
    );
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
    if (mounted) {
      setState(() {
        _isFav = fav;
        _loaded = true;
      });
    }
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
