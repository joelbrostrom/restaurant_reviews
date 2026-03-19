import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final String? searchHint;

  const AppHeader({super.key, required this.onMenuTap, this.searchHint});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: NordBiteTheme.cream,
        boxShadow: [
          BoxShadow(
            color: NordBiteTheme.charcoal.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: onMenuTap,
            tooltip: 'Menu',
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap:
                () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                ),
            child: Text(
              'NordBite',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: NordBiteTheme.coral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 24),
            Expanded(child: _SearchField(hint: searchHint)),
          ],
          if (!isWide) const Spacer(),
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => Navigator.pushNamed(context, '/search'),
            ),
          auth.when(
            data: (user) {
              if (user != null) {
                return PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: NordBiteTheme.coral.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      (user.email ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: NordBiteTheme.coral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'favorites') {
                      Navigator.pushNamed(context, '/favorites');
                    } else if (value == 'signout') {
                      ref.read(firebaseServiceProvider).signOut();
                    }
                  },
                  itemBuilder:
                      (_) => [
                        PopupMenuItem(
                          value: 'email',
                          enabled: false,
                          child: Text(
                            user.email ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'favorites',
                          child: Row(
                            children: [
                              Icon(Icons.favorite_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('My Favorites'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'signout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Sign Out'),
                            ],
                          ),
                        ),
                      ],
                );
              }
              return TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/auth'),
                icon: const Icon(Icons.person_outline_rounded, size: 20),
                label: isWide ? const Text('Sign In') : const SizedBox.shrink(),
              );
            },
            loading: () => const SizedBox(width: 36),
            error: (_, _) => const SizedBox(width: 36),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String? hint;
  const _SearchField({this.hint});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint ?? 'Search restaurants, cuisines, cities...',
          hintStyle: TextStyle(
            color: NordBiteTheme.charcoal.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: NordBiteTheme.charcoal.withValues(alpha: 0.4),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            Navigator.pushNamed(
              context,
              '/search',
              arguments: {'query': query.trim(), 'category': null},
            );
          }
        },
      ),
    );
  }
}
