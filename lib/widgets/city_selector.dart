import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/services/location_service.dart';
import 'package:nordbite/theme.dart';

class CitySelectorDialog extends ConsumerStatefulWidget {
  const CitySelectorDialog({super.key});

  @override
  ConsumerState<CitySelectorDialog> createState() => _CitySelectorDialogState();
}

class _CitySelectorDialogState extends ConsumerState<CitySelectorDialog> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
        swedishCities
            .where((c) => c.name.toLowerCase().contains(_filter.toLowerCase()))
            .toList();

    return Dialog(
      backgroundColor: NordBiteTheme.warmWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 580),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: NordBiteTheme.coral.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 28,
                  color: NordBiteTheme.coral,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose your city',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: NordBiteTheme.charcoal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We couldn\'t detect your location.\nPick a Swedish city to discover nearby restaurants.',
                textAlign: TextAlign.center,
                style: GoogleFonts.karla(
                  fontSize: 13,
                  color: NordBiteTheme.charcoal.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search cities...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                style: GoogleFonts.karla(fontSize: 14),
                onChanged: (v) => setState(() => _filter = v),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final city = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(locationProvider.notifier)
                                .selectCity(city);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: NordBiteTheme.charcoal.withValues(
                                      alpha: 0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_city_rounded,
                                    size: 18,
                                    color: NordBiteTheme.charcoal.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  city.name,
                                  style: GoogleFonts.karla(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: NordBiteTheme.charcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showCitySelector(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const CitySelectorDialog(),
  );
}
