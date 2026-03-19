class Restaurant {
  final String id;
  final String sourceProvider;
  final String name;
  final double latitude;
  final double longitude;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? postalCode;
  final int? distanceMeters;
  final List<String> categories;
  final double? rating;
  final int? reviewCount;
  final String? phone;
  final String? websiteUrl;
  final List<String> imageUrls;
  final String? openingHours;
  final bool? isOpenNow;
  final String? description;
  final int? priceLevel;
  final double displayScore;

  Restaurant({
    required this.id,
    required this.sourceProvider,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postalCode,
    this.distanceMeters,
    this.categories = const [],
    this.rating,
    this.reviewCount,
    this.phone,
    this.websiteUrl,
    this.imageUrls = const [],
    this.openingHours,
    this.isOpenNow,
    this.description,
    this.priceLevel,
    this.displayScore = 0,
  });

  Restaurant copyWith({
    String? id,
    String? sourceProvider,
    String? name,
    double? latitude,
    double? longitude,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? postalCode,
    int? distanceMeters,
    List<String>? categories,
    double? rating,
    int? reviewCount,
    String? phone,
    String? websiteUrl,
    List<String>? imageUrls,
    String? openingHours,
    bool? isOpenNow,
    String? description,
    int? priceLevel,
    double? displayScore,
  }) {
    return Restaurant(
      id: id ?? this.id,
      sourceProvider: sourceProvider ?? this.sourceProvider,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      phone: phone ?? this.phone,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      openingHours: openingHours ?? this.openingHours,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      description: description ?? this.description,
      priceLevel: priceLevel ?? this.priceLevel,
      displayScore: displayScore ?? this.displayScore,
    );
  }

  bool get hasPhotos => imageUrls.isNotEmpty;
  bool get hasRating => rating != null && rating! > 0;
  bool get hasWebsite => websiteUrl != null && websiteUrl!.isNotEmpty;
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  String get distanceLabel {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) return '${distanceMeters}m';
    return '${(distanceMeters! / 1000).toStringAsFixed(1)}km';
  }

  String get categoryLabel =>
      categories.isNotEmpty ? categories.first : 'Restaurant';

  String get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  /// Deterministic placeholder photo URL via LoremFlickr.
  /// The lock param ensures the same restaurant always gets the same image.
  String unsplashImageUrl({int width = 600, int height = 400}) {
    final keywords = _flickrKeywords;
    final lock = id.hashCode.abs() % 10000;
    return 'https://loremflickr.com/$width/$height/$keywords?lock=$lock';
  }

  String get _flickrKeywords {
    final lowerCats = categories.map((c) => c.toLowerCase()).toList();
    const foodKeywords = [
      'pizza',
      'burger',
      'sushi',
      'taco',
      'pasta',
      'ramen',
      'thai',
      'indian',
      'chinese',
      'mexican',
      'korean',
      'japanese',
      'vietnamese',
      'mediterranean',
      'seafood',
      'steak',
      'bbq',
      'vegan',
      'vegetarian',
      'bakery',
      'café',
      'cafe',
      'coffee',
      'dessert',
      'ice cream',
    ];
    for (final keyword in foodKeywords) {
      for (final cat in lowerCats) {
        if (cat.contains(keyword)) return '$keyword,food';
      }
    }
    return 'restaurant,food';
  }
}
