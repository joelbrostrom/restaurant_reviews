import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurant.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/restaurant_repository.dart';
import '../utils/logger.dart';

const _tag = 'Providers';

// --- Core services ---

final firebaseServiceProvider = Provider((_) => FirebaseService());
final locationServiceProvider = Provider((_) => LocationService());
final restaurantRepoProvider = Provider((_) => RestaurantRepository());

// --- Auth ---

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(firebaseServiceProvider).authStateChanges;
});

// --- Location ---

class LocationState {
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final bool isLoading;
  final bool needsCitySelector;

  LocationState({
    this.latitude,
    this.longitude,
    this.cityName,
    this.isLoading = false,
    this.needsCitySelector = false,
  });

  bool get hasLocation => latitude != null && longitude != null;

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    bool? isLoading,
    bool? needsCitySelector,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      isLoading: isLoading ?? this.isLoading,
      needsCitySelector: needsCitySelector ?? this.needsCitySelector,
    );
  }
}

class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() {
    _init();
    return LocationState(isLoading: true);
  }

  Future<void> _init() async {
    final locationService = ref.read(locationServiceProvider);
    final firebaseService = ref.read(firebaseServiceProvider);

    if (firebaseService.isSignedIn) {
      Log.d(_tag, 'Loading location from profile...');
      final profile = await firebaseService.getProfile();
      if (profile != null &&
          profile['latitude'] != null &&
          profile['longitude'] != null) {
        Log.d(
          _tag,
          'Using saved location: ${profile['latitude']}, ${profile['longitude']}',
        );
        state = LocationState(
          latitude: (profile['latitude'] as num).toDouble(),
          longitude: (profile['longitude'] as num).toDouble(),
          cityName: profile['selectedCity'] as String?,
        );
        return;
      }
    }

    final result = await locationService.getCurrentPosition();
    if (result != null) {
      Log.d(
        _tag,
        'Using browser location: ${result.latitude}, ${result.longitude}',
      );
      state = LocationState(
        latitude: result.latitude,
        longitude: result.longitude,
      );
      _persistLocation();
    } else {
      Log.w(_tag, 'No location available, showing city selector');
      state = LocationState(needsCitySelector: true);
    }
  }

  void selectCity(SwedishCity city) {
    final locationService = ref.read(locationServiceProvider);
    final loc = locationService.cityToLocation(city);
    state = LocationState(
      latitude: loc.latitude,
      longitude: loc.longitude,
      cityName: loc.cityName,
    );
    _persistLocation();
  }

  void _persistLocation() {
    final firebaseService = ref.read(firebaseServiceProvider);
    if (firebaseService.isSignedIn && state.hasLocation) {
      firebaseService.updateProfile(
        selectedCity: state.cityName,
        latitude: state.latitude,
        longitude: state.longitude,
      );
    }
  }

  Future<void> retryGeolocation() async {
    final locationService = ref.read(locationServiceProvider);
    state = state.copyWith(isLoading: true, needsCitySelector: false);
    final result = await locationService.getCurrentPosition();
    if (result != null) {
      state = LocationState(
        latitude: result.latitude,
        longitude: result.longitude,
      );
      _persistLocation();
    } else {
      state = LocationState(needsCitySelector: true);
    }
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);

// --- Home data ---

class HomeData {
  final List<Restaurant> hero;
  final Map<String, List<Restaurant>> sections;
  final bool isLoading;
  final String? error;

  HomeData({
    this.hero = const [],
    this.sections = const {},
    this.isLoading = true,
    this.error,
  });
}

class HomeDataNotifier extends Notifier<HomeData> {
  double? _lastLat;
  double? _lastLng;

  @override
  HomeData build() {
    final location = ref.watch(locationProvider);
    if (location.hasLocation && !location.isLoading) {
      final lat = location.latitude!;
      final lng = location.longitude!;
      if (_lastLat != lat || _lastLng != lng) {
        _lastLat = lat;
        _lastLng = lng;
        Future.microtask(() => _loadData(lat, lng));
      }
    }
    return HomeData();
  }

  Future<void> _loadData(double lat, double lng) async {
    final repo = ref.read(restaurantRepoProvider);
    state = HomeData(isLoading: true);
    Log.d(_tag, 'Loading home data for $lat, $lng');
    try {
      final sections = await repo.fetchHomeSections(lat: lat, lng: lng);
      final hero = await repo.searchNearby(
        lat: lat,
        lng: lng,
        limit: 8,
        sort: 'RATING',
      );
      Log.d(
        _tag,
        'Home data loaded: ${hero.length} hero, ${sections.length} sections',
      );
      state = HomeData(hero: hero, sections: sections, isLoading: false);
    } catch (e, stack) {
      Log.e(_tag, 'Home data load failed', e, stack);
      state = HomeData(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refresh() async {
    _lastLat = null;
    _lastLng = null;
    final loc = ref.read(locationProvider);
    if (loc.hasLocation) {
      _lastLat = loc.latitude;
      _lastLng = loc.longitude;
      await _loadData(loc.latitude!, loc.longitude!);
    }
  }
}

final homeDataProvider = NotifierProvider<HomeDataNotifier, HomeData>(
  HomeDataNotifier.new,
);

// --- Search ---

class SearchState {
  final String query;
  final String? categoryKey;
  final String sortBy;
  final List<Restaurant> results;
  final bool isLoading;
  final String? error;

  SearchState({
    this.query = '',
    this.categoryKey,
    this.sortBy = 'RELEVANCE',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    String? categoryKey,
    String? sortBy,
    List<Restaurant>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      categoryKey: categoryKey ?? this.categoryKey,
      sortBy: sortBy ?? this.sortBy,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => SearchState();

  Future<void> search({
    String? query,
    String? categoryKey,
    String? sortBy,
  }) async {
    final loc = ref.read(locationProvider);
    if (!loc.hasLocation) return;

    final repo = ref.read(restaurantRepoProvider);

    state = state.copyWith(
      query: query ?? state.query,
      categoryKey: categoryKey,
      sortBy: sortBy ?? state.sortBy,
      isLoading: true,
      error: null,
    );

    Log.d(
      _tag,
      'Search: query="${state.query}", category=${state.categoryKey}, sort=${state.sortBy}',
    );
    try {
      final results = await repo.searchNearby(
        lat: loc.latitude!,
        lng: loc.longitude!,
        query: state.query.isNotEmpty ? state.query : null,
        categoryKey: state.categoryKey,
        sort: state.sortBy,
        limit: 30,
      );

      var sorted = results;
      if (state.sortBy == 'DISTANCE') {
        sorted = List.from(results)..sort(
          (a, b) =>
              (a.distanceMeters ?? 99999).compareTo(b.distanceMeters ?? 99999),
        );
      } else if (state.sortBy == 'RATING') {
        sorted = List.from(results)
          ..sort((a, b) => b.displayRating.compareTo(a.displayRating));
      } else if (state.sortBy == 'AZ') {
        sorted = List.from(results)..sort((a, b) => a.name.compareTo(b.name));
      }

      Log.d(_tag, 'Search returned ${sorted.length} results');
      state = state.copyWith(results: sorted, isLoading: false);
    } catch (e, stack) {
      Log.e(_tag, 'Search failed', e, stack);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearCategory() {
    state = state.copyWith(categoryKey: null);
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

// --- Restaurant detail ---

final restaurantDetailProvider =
    FutureProvider.family<Restaurant?, (String, String)>((ref, params) async {
      final (id, provider) = params;
      final repo = ref.read(restaurantRepoProvider);
      return await repo.getDetails(id, provider);
    });

// --- Favorites ---

final favoritesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final firebase = ref.read(firebaseServiceProvider);

  // Invalidate when the signed-in user actually changes (sign-in / sign-out),
  // but don't rebuild on every auth stream tick (which causes load-flicker).
  String? lastUid = firebase.currentUser?.uid;
  ref.listen(authStateProvider, (prev, next) {
    final newUid = next.value?.uid;
    if (newUid != lastUid) {
      lastUid = newUid;
      ref.invalidateSelf();
    }
  });

  if (!firebase.isSignedIn) return Stream.value([]);
  return firebase.watchFavorites();
});

final isFavoriteProvider = FutureProvider.family<bool, (String, String)>((
  ref,
  params,
) async {
  final (restaurantId, provider) = params;
  final firebase = ref.read(firebaseServiceProvider);

  String? lastUid = firebase.currentUser?.uid;
  ref.listen(authStateProvider, (prev, next) {
    if (next.value?.uid != lastUid) {
      lastUid = next.value?.uid;
      ref.invalidateSelf();
    }
  });

  if (!firebase.isSignedIn) return false;
  return await firebase.isFavorite(restaurantId, provider);
});

// --- User rating ---

final userRatingProvider = StreamProvider.family<int?, (String, String)>((
  ref,
  params,
) {
  final (restaurantId, provider) = params;
  final firebase = ref.read(firebaseServiceProvider);

  String? lastUid = firebase.currentUser?.uid;
  ref.listen(authStateProvider, (prev, next) {
    if (next.value?.uid != lastUid) {
      lastUid = next.value?.uid;
      ref.invalidateSelf();
    }
  });

  if (!firebase.isSignedIn) return Stream.value(null);
  return firebase.watchUserRating(restaurantId, provider);
});
