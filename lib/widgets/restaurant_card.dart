import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    this.height = 280,
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
      cursor: SystemMouseCursors.click,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: useConstraints ? null : widget.width,
          height: useConstraints ? null : widget.height,
          transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: NordBiteTheme.charcoal.withValues(
                  alpha: _hovering ? 0.14 : 0.06,
                ),
                blurRadius: _hovering ? 24 : 12,
                offset: Offset(0, _hovering ? 10 : 4),
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
                      AnimatedScale(
                        scale: _hovering ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        child: CachedNetworkImage(
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
                      ),
                      // Subtle bottom gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.25),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isSignedIn)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _FavoriteButton(restaurant: r),
                        ),
                      if (r.distanceLabel.isNotEmpty)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              r.distanceLabel,
                              style: GoogleFonts.karla(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
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
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: NordBiteTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        r.categoryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.karla(
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (r.hasRating) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: NordBiteTheme.gold.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: NordBiteTheme.gold,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    r.displayRating.toStringAsFixed(1),
                                    style: GoogleFonts.karla(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: NordBiteTheme.charcoal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (r.city != null)
                            Expanded(
                              child: Text(
                                r.city!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.karla(
                                  fontSize: 11,
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.45,
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
    );
  }

  Widget _shimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF3F0ED),
      highlightColor: Colors.white,
      child: Container(color: const Color(0xFFF3F0ED)),
    );
  }

  Widget _fallbackImage(Restaurant r) {
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
          size: 40,
          color: NordBiteTheme.coral.withValues(alpha: 0.3),
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
    if (mounted) {
      setState(() {
        _isFav = fav;
        _loaded = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox(width: 34, height: 34);
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
