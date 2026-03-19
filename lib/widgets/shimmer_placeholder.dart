import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerCard({super.key, this.width = 280, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF3F0ED),
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0ED),
          borderRadius: BorderRadius.circular(20),
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
      baseColor: const Color(0xFFF3F0ED),
      highlightColor: Colors.white,
      child: Container(
        height: 420,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0ED),
          borderRadius: BorderRadius.circular(28),
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
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: const Color(0xFFF3F0ED),
                highlightColor: Colors.white,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Shimmer.fromColors(
                baseColor: const Color(0xFFF3F0ED),
                highlightColor: Colors.white,
                child: Container(
                  width: 160,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
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
