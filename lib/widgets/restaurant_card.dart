import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordbite/models/restaurant.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';
import 'package:nordbite/utils/logger.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantCard extends ConsumerStatefulWidget {
  final Restaurant restaurant;
  final double width;
  final double height;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.width = 280,
    this.height = 260,
  });

  @override
  ConsumerState<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends ConsumerState<RestaurantCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final auth = ref.watch(authStateProvider);
    final isSignedIn = auth.value != null;

    final useConstraints =
        widget.width == double.infinity || widget.height == double.infinity;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap:
            () => Navigator.pushNamed(
              context,
              '/restaurant',
              arguments: {
                'id': r.id,
                'provider': r.sourceProvider,
                'name': r.name,
              },
            ),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: _hovering ? const Offset(0, -0.02) : Offset.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: useConstraints ? null : widget.width,
            height: useConstraints ? null : widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: NordBiteTheme.charcoal.withValues(
                    alpha: _hovering ? 0.12 : 0.06,
                  ),
                  blurRadius: _hovering ? 16 : 8,
                  offset: Offset(0, _hovering ? 8 : 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 55,
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              r.hasPhotos
                                  ? r.firstImageUrl
                                  : r.unsplashImageUrl(),
                          fit: BoxFit.cover,
                          placeholder: (_, _) => _shimmerPlaceholder(),
                          errorWidget:
                              (_, _, _) => CachedNetworkImage(
                                imageUrl: r.unsplashImageUrl(),
                                fit: BoxFit.cover,
                                placeholder: (_, _) => _shimmerPlaceholder(),
                                errorWidget: (_, _, _) => _fallbackImage(r),
                              ),
                        ),
                        // Gradient overlay
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
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Favorite button
                        if (isSignedIn)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _FavoriteButton(restaurant: r),
                          ),
                        // Distance badge
                        if (r.distanceLabel.isNotEmpty)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                r.distanceLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.categoryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: NordBiteTheme.charcoal.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            if (r.hasRating) ...[
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: NordBiteTheme.gold,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                r.displayRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            if (r.distanceLabel.isNotEmpty) ...[
                              Icon(
                                Icons.near_me_rounded,
                                size: 13,
                                color: NordBiteTheme.charcoal.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                r.distanceLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            if (r.city != null)
                              Expanded(
                                child: Text(
                                  r.city!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: NordBiteTheme.charcoal.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: NordBiteTheme.softGray,
      highlightColor: Colors.white,
      child: Container(color: NordBiteTheme.softGray),
    );
  }

  Widget _fallbackImage(Restaurant r) {
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
          size: 40,
          color: NordBiteTheme.coral.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _FavoriteButton extends ConsumerStatefulWidget {
  final Restaurant restaurant;
  const _FavoriteButton({required this.restaurant});

  @override
  ConsumerState<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isFav = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _checkFav();
  }

  Future<void> _checkFav() async {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox(width: 32, height: 32);
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: NordBiteTheme.coral,
          ),
        ),
      ),
    );
  }

  Future<void> _toggle() async {
    final firebase = ref.read(firebaseServiceProvider);
    final r = widget.restaurant;
    setState(() => _isFav = !_isFav);
    _controller.forward(from: 0);
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
      Log.e('RestaurantCard', 'Favorite toggle failed for ${r.id}', e, stack);
      if (mounted) setState(() => _isFav = !_isFav);
    }
  }
}
