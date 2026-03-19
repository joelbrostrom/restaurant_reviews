import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 40,
                color: NordBiteTheme.coral,
              ),
              const SizedBox(height: 12),
              Text(
                'Choose your city',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'We couldn\'t detect your location.\nPick a Swedish city to discover nearby restaurants.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search cities...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (v) => setState(() => _filter = v),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final city = filtered[i];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_city_rounded,
                        size: 20,
                      ),
                      title: Text(city.name),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () {
                        ref.read(locationProvider.notifier).selectCity(city);
                        Navigator.pop(context);
                      },
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
