import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nordbite/theme.dart';
import 'package:shimmer/shimmer.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String? fallbackUrl;

  const ImageCarousel({super.key, required this.imageUrls, this.fallbackUrl});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder:
                        (_, _) => Shimmer.fromColors(
                          baseColor: const Color(0xFFF3F0ED),
                          highlightColor: Colors.white,
                          child: Container(color: const Color(0xFFF3F0ED)),
                        ),
                    errorWidget: (_, _, _) {
                      if (widget.fallbackUrl != null) {
                        return CachedNetworkImage(
                          imageUrl: widget.fallbackUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (_, _, _) => _brokenImage(),
                        );
                      }
                      return _brokenImage();
                    },
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (i) {
              final isActive = _current == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 24 : 8,
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
          ),
        ],
      ],
    );
  }

  Widget _brokenImage() {
    return Container(
      color: const Color(0xFFF3F0ED),
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          size: 40,
          color: NordBiteTheme.charcoal.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
