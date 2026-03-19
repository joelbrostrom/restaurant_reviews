import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../utils/logger.dart';

const _tag = 'Location';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? cityName;

  LocationResult({
    required this.latitude,
    required this.longitude,
    this.cityName,
  });
}

class SwedishCity {
  final String name;
  final double latitude;
  final double longitude;

  const SwedishCity(this.name, this.latitude, this.longitude);
}

const swedishCities = [
  SwedishCity('Stockholm', 59.3293, 18.0686),
  SwedishCity('Gothenburg', 57.7089, 11.9746),
  SwedishCity('Malmö', 55.6050, 13.0038),
  SwedishCity('Uppsala', 59.8586, 17.6389),
  SwedishCity('Västerås', 59.6099, 16.5448),
  SwedishCity('Örebro', 59.2753, 15.2134),
  SwedishCity('Linköping', 58.4108, 15.6214),
  SwedishCity('Helsingborg', 56.0465, 12.6945),
  SwedishCity('Jönköping', 57.7826, 14.1618),
  SwedishCity('Norrköping', 58.5877, 16.1924),
  SwedishCity('Lund', 55.7047, 13.1910),
  SwedishCity('Umeå', 63.8258, 20.2630),
  SwedishCity('Gävle', 60.6749, 17.1413),
  SwedishCity('Borås', 57.7210, 12.9401),
  SwedishCity('Södertälje', 59.1955, 17.6253),
];

class LocationService {
  Future<LocationResult?> getCurrentPosition() async {
    Log.d(_tag, 'Requesting browser geolocation...');
    try {
      final completer = Completer<LocationResult?>();

      web.window.navigator.geolocation.getCurrentPosition(
        ((web.GeolocationPosition position) {
          Log.d(
            _tag,
            'Geolocation granted: ${position.coords.latitude}, ${position.coords.longitude}',
          );
          completer.complete(
            LocationResult(
              latitude: position.coords.latitude.toDouble(),
              longitude: position.coords.longitude.toDouble(),
            ),
          );
        }).toJS,
        ((web.GeolocationPositionError error) {
          Log.w(
            _tag,
            'Geolocation denied/error: code=${error.code}, message=${error.message}',
          );
          completer.complete(null);
        }).toJS,
        web.PositionOptions(
          enableHighAccuracy: false,
          timeout: 10000,
          maximumAge: 300000,
        ),
      );

      return await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          Log.w(_tag, 'Geolocation timed out after 12s');
          return null;
        },
      );
    } catch (e, stack) {
      Log.e(_tag, 'Geolocation exception', e, stack);
      return null;
    }
  }

  LocationResult cityToLocation(SwedishCity city) {
    return LocationResult(
      latitude: city.latitude,
      longitude: city.longitude,
      cityName: city.name,
    );
  }
}
