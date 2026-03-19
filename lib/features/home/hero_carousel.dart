import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nordbite/models/restaurant.dart';
import 'package:nordbite/theme.dart';
import 'package:shimmer/shimmer.dart';

class HeroCarousel extends StatefulWidget {
  final List<Restaurant> restaurants;

  const HeroCarousel({super.key, required this.restaurants});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late PageController _controller;
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.restaurants.isEmpty) return;
      final next = (_current + 1) % widget.restaurants.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.restaurants.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.restaurants.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              final r = widget.restaurants[i];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_controller.position.haveDimensions) {
                    final page = _controller.page ?? _current.toDouble();
                    scale = (1 - (page - i).abs() * 0.08).clamp(0.9, 1.0);
                  }
                  return Transform.scale(scale: scale, child: child);
                },
                child: _HeroCard(restaurant: r),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.restaurants.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    _current == i
                        ? NordBiteTheme.coral
                        : NordBiteTheme.charcoal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Restaurant restaurant;

  const _HeroCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.pushNamed(
            context,
            '/restaurant',
            arguments: {
              'id': restaurant.id,
              'provider': restaurant.sourceProvider,
              'name': restaurant.name,
            },
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: NordBiteTheme.charcoal.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: restaurant.hasPhotos
                  ? restaurant.firstImageUrl
                  : restaurant.unsplashImageUrl(width: 800, height: 600),
              fit: BoxFit.cover,
              placeholder: (_, _) => Shimmer.fromColors(
                baseColor: NordBiteTheme.softGray,
                highlightColor: Colors.white,
                child: Container(color: NordBiteTheme.softGray),
              ),
              errorWidget: (_, _, _) => CachedNetworkImage(
                imageUrl: restaurant.unsplashImageUrl(width: 800, height: 600),
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        NordBiteTheme.coral.withValues(alpha: 0.8),
                        NordBiteTheme.charcoal.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      size: 64,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 0.7, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (restaurant.categories.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: NordBiteTheme.coral,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        restaurant.categoryLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (restaurant.hasRating) ...[
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: NordBiteTheme.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (restaurant.distanceLabel.isNotEmpty) ...[
                        const Icon(
                          Icons.near_me_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.distanceLabel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (restaurant.city != null)
                        Expanded(
                          child: Text(
                            restaurant.city!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'View Restaurant',
                      style: TextStyle(
                        color: NordBiteTheme.coral,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
