import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    _controller = PageController(viewportFraction: 0.88);
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.restaurants.isEmpty) return;
      final next = (_current + 1) % widget.restaurants.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
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
          height: 440,
          child: PageView.builder(
            clipBehavior: Clip.none,
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
                    scale = (1 - (page - i).abs() * 0.06).clamp(0.92, 1.0);
                  }
                  return Transform.scale(scale: scale, child: child);
                },
                child: _HeroCard(restaurant: r),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _PageIndicator(count: widget.restaurants.length, current: _current),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _PageIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = current == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                isActive
                    ? NordBiteTheme.coral
                    : NordBiteTheme.charcoal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _HeroCard extends StatefulWidget {
  final Restaurant restaurant;

  const _HeroCard({required this.restaurant});

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;

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
          margin: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: _hovering ? 4 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: NordBiteTheme.charcoal.withValues(
                  alpha: _hovering ? 0.18 : 0.10,
                ),
                blurRadius: _hovering ? 32 : 20,
                offset: Offset(0, _hovering ? 12 : 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScale(
                scale: _hovering ? 1.04 : 1.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: CachedNetworkImage(
                  imageUrl:
                      r.hasPhotos
                          ? r.firstImageUrl
                          : r.unsplashImageUrl(width: 800, height: 600),
                  fit: BoxFit.cover,
                  placeholder:
                      (_, _) => Shimmer.fromColors(
                        baseColor: NordBiteTheme.softGray,
                        highlightColor: Colors.white,
                        child: Container(color: NordBiteTheme.softGray),
                      ),
                  errorWidget:
                      (_, _, _) => CachedNetworkImage(
                        imageUrl: r.unsplashImageUrl(width: 800, height: 600),
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _fallbackGradient(),
                      ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.2, 0.55, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 28,
                right: 28,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (r.categories.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: NordBiteTheme.coral,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          r.categoryLabel.toUpperCase(),
                          style: GoogleFonts.karla(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      r.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (r.hasRating) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: NordBiteTheme.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            r.displayRating.toStringAsFixed(1),
                            style: GoogleFonts.karla(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                        if (r.distanceLabel.isNotEmpty) ...[
                          const Icon(
                            Icons.near_me_rounded,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            r.distanceLabel,
                            style: GoogleFonts.karla(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                        if (r.city != null)
                          Expanded(
                            child: Text(
                              r.city!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.karla(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'View Restaurant',
                        style: GoogleFonts.karla(
                          color: NordBiteTheme.coral,
                          fontWeight: FontWeight.w800,
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
      ),
    );
  }

  Widget _fallbackGradient() {
    return Container(
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
        child: Icon(Icons.restaurant_rounded, size: 64, color: Colors.white24),
      ),
    );
  }
}
