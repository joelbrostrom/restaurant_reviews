import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/restaurant.dart';
import '../utils/logger.dart';

const _tag = 'Foursquare';

class FoursquareService {
  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${AppConfig.foursquareApiKey}',
    'Accept': 'application/json',
    'X-Places-Api-Version': '2025-06-17',
  };

  Future<List<Restaurant>> searchPlaces({
    required double lat,
    required double lng,
    String? query,
    String? categoryKey,
    int radius = AppConfig.defaultSearchRadius,
    int limit = AppConfig.defaultResultLimit,
    String sort = 'RELEVANCE',
  }) async {
    final searchQuery = query ?? categoryKey;

    final params = <String, String>{
      'll': '$lat,$lng',
      'radius': '$radius',
      'limit': '$limit',
      'sort': sort,
    };
    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['query'] = searchQuery;
    }

    final uri = Uri.parse(
      '${AppConfig.foursquareBaseUrl}/places/search',
    ).replace(queryParameters: params);
    Log.d(_tag, 'Search: $uri');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      Log.e(_tag, 'Search failed [${response.statusCode}]: ${response.body}');
      throw FoursquareException(
        'Search failed: ${response.statusCode}',
        response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List? ?? [];
    Log.d(_tag, 'Search returned ${results.length} results');
    return results.map((r) => _parseResult(r as Map<String, dynamic>)).toList();
  }

  Future<Restaurant> getPlaceDetails(String placeId) async {
    final uri = Uri.parse('${AppConfig.foursquareBaseUrl}/places/$placeId');
    Log.d(_tag, 'Detail: $uri');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      Log.e(
        _tag,
        'Detail fetch failed [${response.statusCode}]: ${response.body}',
      );
      throw FoursquareException(
        'Detail fetch failed: ${response.statusCode}',
        response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    Log.d(_tag, 'Detail loaded for "$placeId"');
    return _parseResult(data);
  }

  Restaurant _parseResult(Map<String, dynamic> r) {
    final location = r['location'] as Map<String, dynamic>? ?? {};
    final cats =
        (r['categories'] as List?)
            ?.map(
              (c) => c['short_name'] as String? ?? c['name'] as String? ?? '',
            )
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    final photos =
        (r['photos'] as List?)?.map((p) {
          final prefix = p['prefix'] as String? ?? '';
          final suffix = p['suffix'] as String? ?? '';
          return '${prefix}600x400$suffix';
        }).toList() ??
        [];

    final tips =
        (r['tips'] as List?)
            ?.map((t) => t['text'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

    final hours = r['hours'] as Map<String, dynamic>?;
    final stats = r['stats'] as Map<String, dynamic>?;

    return Restaurant(
      id: r['fsq_place_id'] as String? ?? '',
      sourceProvider: 'foursquare',
      name: r['name'] as String? ?? 'Unknown',
      latitude: (r['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (r['longitude'] as num?)?.toDouble() ?? 0,
      addressLine1: location['address'] as String?,
      addressLine2: location['formatted_address'] as String?,
      city: location['locality'] as String?,
      postalCode: location['postcode'] as String?,
      distanceMeters: r['distance'] as int?,
      categories: cats,
      rating: (r['rating'] as num?)?.toDouble(),
      reviewCount: (stats?['total_ratings'] as num?)?.toInt(),
      phone: r['tel'] as String?,
      websiteUrl: r['website'] as String?,
      imageUrls: photos,
      openingHours: hours?['display'] as String?,
      isOpenNow: hours?['open_now'] as bool?,
      description:
          tips != null && tips.isNotEmpty
              ? tips.first
              : r['description'] as String?,
      priceLevel: r['price'] as int?,
      displayScore: _computeScore(
        rating: (r['rating'] as num?)?.toDouble(),
        distance: r['distance'] as int?,
        hasPhotos: photos.isNotEmpty,
      ),
    );
  }

  double _computeScore({
    double? rating,
    int? distance,
    bool hasPhotos = false,
  }) {
    double score = 0;
    if (rating != null) score += (rating / 10) * 50;
    if (distance != null) {
      score += ((10000 - distance.clamp(0, 10000)) / 10000) * 30;
    }
    if (hasPhotos) score += 20;
    return score;
  }
}

class FoursquareException implements Exception {
  final String message;
  final int statusCode;
  FoursquareException(this.message, this.statusCode);
  @override
  String toString() => 'FoursquareException($statusCode): $message';
}
