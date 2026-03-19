import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/restaurant.dart';
import '../utils/logger.dart';

const _tag = 'Geoapify';

class GeoapifyService {
  static const _categoryMap = {
    'pizza': 'catering.restaurant',
    'burgers': 'catering.fast_food',
    'tacos': 'catering.restaurant',
    'vegetarian': 'catering.restaurant',
    'sushi': 'catering.restaurant',
    'coffee': 'catering.cafe',
    'restaurant': 'catering.restaurant',
    'fast_food': 'catering.fast_food',
  };

  static const _conditionsMap = {'vegetarian': 'vegetarian', 'vegan': 'vegan'};

  /// Note: Geoapify uses lon,lat order (not lat,lng)
  Future<List<Restaurant>> searchPlaces({
    required double lat,
    required double lng,
    String? query,
    String? categoryKey,
    int radius = AppConfig.defaultSearchRadius,
    int limit = AppConfig.defaultResultLimit,
  }) async {
    final categories =
        _categoryMap[categoryKey?.toLowerCase()] ?? 'catering.restaurant';
    final condition = _conditionsMap[categoryKey?.toLowerCase()];

    var url =
        '${AppConfig.geoapifyBaseUrl}/places'
        '?categories=$categories'
        '&filter=circle:$lng,$lat,$radius'
        '&bias=proximity:$lng,$lat'
        '&limit=$limit'
        '&apiKey=${AppConfig.geoapifyApiKey}';

    if (condition != null) url += '&conditions=$condition';
    if (query != null && query.isNotEmpty) url += '&name=$query';

    Log.d(_tag, 'Search: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      Log.e(_tag, 'Search failed [${response.statusCode}]: ${response.body}');
      throw GeoapifyException(
        'Search failed: ${response.statusCode}',
        response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List? ?? [];
    Log.d(_tag, 'Search returned ${features.length} results');
    return features
        .map((f) => _parseFeature(f as Map<String, dynamic>))
        .toList();
  }

  Future<Restaurant?> getPlaceDetails(String placeId) async {
    final url =
        '${AppConfig.geoapifyBaseUrl}/place-details'
        '?id=$placeId'
        '&features=details'
        '&apiKey=${AppConfig.geoapifyApiKey}';

    Log.d(_tag, 'Detail: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      Log.w(
        _tag,
        'Detail fetch failed [${response.statusCode}] for "$placeId"',
      );
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List? ?? [];
    if (features.isEmpty) return null;

    return _parseDetailFeature(features.first as Map<String, dynamic>);
  }

  Restaurant _parseFeature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final cats =
        (props['categories'] as List?)
            ?.map((c) => _prettifyCategory(c.toString()))
            .toList() ??
        [];

    return Restaurant(
      id: props['place_id'] as String? ?? '',
      sourceProvider: 'geoapify',
      name: props['name'] as String? ?? 'Unknown',
      latitude: (props['lat'] as num?)?.toDouble() ?? 0,
      longitude: (props['lon'] as num?)?.toDouble() ?? 0,
      addressLine1: props['address_line1'] as String?,
      addressLine2: props['address_line2'] as String?,
      city: props['city'] as String?,
      postalCode: props['postcode'] as String?,
      distanceMeters: (props['distance'] as num?)?.toInt(),
      categories: cats,
      phone: _extractContact(props, 'phone'),
      websiteUrl: props['website'] as String?,
      displayScore: _computeScore(
        distance: (props['distance'] as num?)?.toInt(),
      ),
    );
  }

  Restaurant? _parseDetailFeature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final cats =
        (props['categories'] as List?)
            ?.map((c) => _prettifyCategory(c.toString()))
            .toList() ??
        [];

    final wikiMedia = props['wiki_and_media'] as Map<String, dynamic>?;
    final imageUrl = wikiMedia?['image'] as String?;

    return Restaurant(
      id: props['place_id'] as String? ?? '',
      sourceProvider: 'geoapify',
      name: props['name'] as String? ?? 'Unknown',
      latitude: (props['lat'] as num?)?.toDouble() ?? 0,
      longitude: (props['lon'] as num?)?.toDouble() ?? 0,
      addressLine1: props['address_line1'] as String?,
      addressLine2: props['address_line2'] as String?,
      city: props['city'] as String?,
      postalCode: props['postcode'] as String?,
      categories: cats,
      phone: _extractContact(props, 'phone'),
      websiteUrl: props['website'] as String?,
      imageUrls: imageUrl != null ? [imageUrl] : [],
      openingHours: props['opening_hours'] as String?,
      description: _extractCuisine(props),
      displayScore: _computeScore(
        distance: (props['distance'] as num?)?.toInt(),
        hasPhotos: imageUrl != null,
      ),
    );
  }

  String? _extractContact(Map<String, dynamic> props, String key) {
    final contact = props['datasource'] as Map<String, dynamic>?;
    final raw = contact?['raw'] as Map<String, dynamic>?;
    return raw?[key] as String? ?? props[key] as String?;
  }

  String? _extractCuisine(Map<String, dynamic> props) {
    final raw =
        (props['datasource'] as Map<String, dynamic>?)?['raw']
            as Map<String, dynamic>?;
    return raw?['cuisine'] as String?;
  }

  String _prettifyCategory(String cat) {
    return cat
        .replaceAll('catering.', '')
        .replaceAll('_', ' ')
        .split('.')
        .last
        .replaceFirstMapped(
          RegExp(r'^[a-z]'),
          (m) => m.group(0)!.toUpperCase(),
        );
  }

  double _computeScore({int? distance, bool hasPhotos = false}) {
    double score = 0;
    if (distance != null) {
      score += ((10000 - distance.clamp(0, 10000)) / 10000) * 50;
    }
    if (hasPhotos) score += 20;
    return score;
  }
}

class GeoapifyException implements Exception {
  final String message;
  final int statusCode;
  GeoapifyException(this.message, this.statusCode);
  @override
  String toString() => 'GeoapifyException($statusCode): $message';
}
