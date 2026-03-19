import '../models/restaurant.dart';
import '../utils/logger.dart';
import 'foursquare_service.dart';
import 'geoapify_service.dart';

const _tag = 'RestaurantRepo';

class RestaurantRepository {
  final FoursquareService _foursquare = FoursquareService();
  final GeoapifyService _geoapify = GeoapifyService();

  Future<List<Restaurant>> searchNearby({
    required double lat,
    required double lng,
    String? query,
    String? categoryKey,
    int radius = 5000,
    int limit = 20,
    String sort = 'RELEVANCE',
  }) async {
    try {
      final results = await _foursquare.searchPlaces(
        lat: lat,
        lng: lng,
        query: query,
        categoryKey: categoryKey,
        radius: radius,
        limit: limit,
        sort: sort,
      );
      if (results.isNotEmpty) return _rankResults(results, lat, lng);
      Log.w(_tag, 'Foursquare returned 0 results, trying Geoapify');
    } catch (e, stack) {
      Log.w(
        _tag,
        'Foursquare search failed, falling back to Geoapify',
        e,
        stack,
      );
    }

    try {
      final results = await _geoapify.searchPlaces(
        lat: lat,
        lng: lng,
        query: query,
        categoryKey: categoryKey,
        radius: radius,
        limit: limit,
      );
      return _rankResults(results, lat, lng);
    } catch (e, stack) {
      Log.e(_tag, 'Both providers failed for searchNearby', e, stack);
      return [];
    }
  }

  Future<Restaurant?> getDetails(String id, String provider) async {
    try {
      if (provider == 'foursquare') {
        return await _foursquare.getPlaceDetails(id);
      } else {
        return await _geoapify.getPlaceDetails(id);
      }
    } catch (e, stack) {
      Log.e(_tag, 'getDetails failed for "$id" ($provider)', e, stack);
      return null;
    }
  }

  Future<Map<String, List<Restaurant>>> fetchHomeSections({
    required double lat,
    required double lng,
  }) async {
    final sections = <String, Future<List<Restaurant>>>{
      'featured': searchNearby(
        lat: lat,
        lng: lng,
        limit: 10,
        sort: 'RELEVANCE',
      ),
      'vegetarian': searchNearby(
        lat: lat,
        lng: lng,
        categoryKey: 'vegetarian',
        limit: 10,
      ),
      'pizza': searchNearby(
        lat: lat,
        lng: lng,
        categoryKey: 'pizza',
        limit: 10,
      ),
      'burgers': searchNearby(
        lat: lat,
        lng: lng,
        categoryKey: 'burgers',
        limit: 10,
      ),
      'tacos': searchNearby(
        lat: lat,
        lng: lng,
        categoryKey: 'tacos',
        limit: 10,
      ),
      'top_rated': searchNearby(lat: lat, lng: lng, limit: 10, sort: 'RATING'),
    };

    final results = <String, List<Restaurant>>{};
    for (final entry in sections.entries) {
      try {
        results[entry.key] = await entry.value;
      } catch (e, stack) {
        Log.w(_tag, 'Home section "${entry.key}" failed', e, stack);
        results[entry.key] = [];
      }
    }
    return results;
  }

  List<Restaurant> _rankResults(
    List<Restaurant> restaurants,
    double userLat,
    double userLng,
  ) {
    final scored =
        restaurants.map((r) {
          double score = r.displayScore;
          if (r.distanceMeters != null) {
            score += ((10000 - r.distanceMeters!.clamp(0, 10000)) / 10000) * 30;
          }
          if (r.hasRating) score += 10;
          return r.copyWith(displayScore: score);
        }).toList();

    scored.sort((a, b) => b.displayScore.compareTo(a.displayScore));
    return scored;
  }
}
