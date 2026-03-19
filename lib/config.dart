class AppConfig {
  static const foursquareApiKey = String.fromEnvironment('FOURSQUARE_API_KEY');
  static const geoapifyApiKey = String.fromEnvironment('GEOAPIFY_API_KEY');

  static const foursquareBaseUrl = 'https://places-api.foursquare.com';
  static const geoapifyBaseUrl = 'https://api.geoapify.com/v2';

  static const defaultSearchRadius = 5000; // meters
  static const defaultResultLimit = 20;
  static const heroResultLimit = 10;
}
