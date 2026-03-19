import 'dart:convert';
import 'dart:io';

/// Lightweight CORS proxy for Foursquare Places API during development.
/// Run with: dart run proxy/server.dart
///
/// Proxies requests from http://localhost:8090/places/...
/// to https://places-api.foursquare.com/places/... adding CORS headers.
void main() async {
  final port = 8090;
  final target = 'places-api.foursquare.com';
  final client = HttpClient();

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('Foursquare CORS proxy running on http://localhost:$port');
  print('Proxying to https://$target');

  await for (final request in server) {
    final response = request.response;

    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('Access-Control-Allow-Headers',
        'Authorization, Accept, Content-Type, X-Places-Api-Version');
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');

    if (request.method == 'OPTIONS') {
      response.statusCode = 204;
      await response.close();
      continue;
    }

    try {
      final proxyUri = Uri.https(target, request.uri.path, request.uri.queryParameters);
      final proxyRequest = await client.getUrl(proxyUri);

      request.headers.forEach((name, values) {
        if (name.toLowerCase() == 'host') return;
        for (final v in values) {
          proxyRequest.headers.add(name, v);
        }
      });

      final proxyResponse = await proxyRequest.close();
      response.statusCode = proxyResponse.statusCode;

      proxyResponse.headers.forEach((name, values) {
        if (name.toLowerCase() == 'transfer-encoding') return;
        for (final v in values) {
          response.headers.add(name, v);
        }
      });

      response.headers.set('Access-Control-Allow-Origin', '*');

      final body = await proxyResponse.transform(utf8.decoder).join();
      response.write(body);
    } catch (e) {
      response.statusCode = 502;
      response.write(jsonEncode({'error': 'Proxy error', 'detail': e.toString()}));
    }

    await response.close();
  }
}
