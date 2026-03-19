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
          height: 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder:
                        (_, _) => Shimmer.fromColors(
                          baseColor: NordBiteTheme.softGray,
                          highlightColor: Colors.white,
                          child: Container(color: NordBiteTheme.softGray),
                        ),
                    errorWidget: (_, _, _) {
                      if (widget.fallbackUrl != null) {
                        return CachedNetworkImage(
                          imageUrl: widget.fallbackUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (_, _, _) => Container(
                            color: NordBiteTheme.softGray,
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 40,
                              color: NordBiteTheme.charcoal.withValues(alpha: 0.2),
                            ),
                          ),
                        );
                      }
                      return Container(
                        color: NordBiteTheme.softGray,
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 40,
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.2),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 20 : 8,
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
      ],
    );
  }
}
