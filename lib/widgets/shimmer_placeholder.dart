import 'package:flutter/material.dart';
import 'package:nordbite/theme.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerCard({super.key, this.width = 280, this.height = 260});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NordBiteTheme.softGray,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: NordBiteTheme.softGray,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class ShimmerHero extends StatelessWidget {
  const ShimmerHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NordBiteTheme.softGray,
      highlightColor: Colors.white,
      child: Container(
        height: 400,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NordBiteTheme.softGray,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class ShimmerSection extends StatelessWidget {
  const ShimmerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Shimmer.fromColors(
            baseColor: NordBiteTheme.softGray,
            highlightColor: Colors.white,
            child: Container(
              width: 180,
              height: 24,
              decoration: BoxDecoration(
                color: NordBiteTheme.softGray,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (_, _) => const ShimmerCard(),
          ),
        ),
      ],
    );
  }
}
