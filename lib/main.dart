import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordbite/config.dart';
import 'package:nordbite/features/auth/auth_dialog.dart';
import 'package:nordbite/features/favorites/favorites_page.dart';
import 'package:nordbite/features/home/home_page.dart';
import 'package:nordbite/features/restaurant/restaurant_detail_page.dart';
import 'package:nordbite/features/search/search_page.dart';
import 'package:nordbite/firebase_options.dart';
import 'package:nordbite/theme.dart';
import 'package:nordbite/utils/logger.dart';

const _tag = 'App';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Log.d(_tag, 'NordBite starting...');

  _logKey('FOURSQUARE_API_KEY', AppConfig.foursquareApiKey);
  _logKey('GEOAPIFY_API_KEY', AppConfig.geoapifyApiKey);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Log.d(_tag, 'Firebase initialized');
  } catch (e, stack) {
    Log.e(_tag, 'Firebase init failed', e, stack);
  }

  runApp(const ProviderScope(child: NordBiteApp()));
}

void _logKey(String name, String value) {
  if (value.isEmpty) {
    Log.w(_tag, '$name is not set — pass it via --dart-define');
  } else {
    final masked =
        '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
    Log.d(_tag, '$name loaded ($masked)');
  }
}

class NordBiteApp extends StatelessWidget {
  const NordBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NordBite',
      debugShowCheckedModeBanner: false,
      theme: NordBiteTheme.theme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _fade(const HomePage());
          case '/search':
            final args = settings.arguments as Map<String, String?>?;
            return _fade(
              SearchPage(
                initialQuery: args?['query'],
                initialCategory: args?['category'],
              ),
            );
          case '/restaurant':
            final args = settings.arguments as Map<String, String>;
            return _fade(
              RestaurantDetailPage(
                restaurantId: args['id']!,
                provider: args['provider']!,
                restaurantName: args['name'] ?? '',
              ),
            );
          case '/favorites':
            return _fade(const FavoritesPage());
          case '/auth':
            return _fade(const AuthPage());
          default:
            return _fade(const HomePage());
        }
      },
    );
  }

  PageRouteBuilder _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
