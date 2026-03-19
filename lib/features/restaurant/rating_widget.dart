import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';

class RatingWidget extends ConsumerWidget {
  final String restaurantId;
  final String provider;

  const RatingWidget({
    super.key,
    required this.restaurantId,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingAsync = ref.watch(userRatingProvider((restaurantId, provider)));

    return ratingAsync.when(
      loading: () => const SizedBox(height: 44),
      error: (_, _) => const Text('Could not load rating'),
      data: (currentRating) {
        return _StarRow(
          currentRating: currentRating ?? 0,
          onRate: (rating) async {
            final firebase = ref.read(firebaseServiceProvider);
            await firebase.setRating(
              restaurantId: restaurantId,
              provider: provider,
              rating: rating,
            );
          },
        );
      },
    );
  }
}

class _StarRow extends StatefulWidget {
  final int currentRating;
  final Future<void> Function(int) onRate;

  const _StarRow({required this.currentRating, required this.onRate});

  @override
  State<_StarRow> createState() => _StarRowState();
}

class _StarRowState extends State<_StarRow> {
  int _hoverRating = 0;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.currentRating;
  }

  @override
  void didUpdateWidget(covariant _StarRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRating != widget.currentRating) {
      _selectedRating = widget.currentRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayRating = _hoverRating > 0 ? _hoverRating : _selectedRating;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: NordBiteTheme.gold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NordBiteTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final starValue = i + 1;
          final isActive = displayRating >= starValue;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoverRating = starValue),
            onExit: (_) => setState(() => _hoverRating = 0),
            child: GestureDetector(
              onTap: () async {
                setState(() => _selectedRating = starValue);
                await widget.onRate(starValue);
              },
              child: AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    isActive ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 38,
                    color:
                        isActive
                            ? NordBiteTheme.gold
                            : NordBiteTheme.charcoal.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
