import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final String? searchHint;

  const AppHeader({super.key, required this.onMenuTap, this.searchHint});

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: NordBiteTheme.warmWhite.withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: NordBiteTheme.charcoal.withValues(alpha: 0.04),
              ),
            ),
          ),
          child: Row(
            children: [
              _IconBtn(
                icon: Icons.menu_rounded,
                onTap: onMenuTap,
                tooltip: 'Menu',
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap:
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'NordBite',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: NordBiteTheme.coral,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              if (isWide) ...[
                const SizedBox(width: 28),
                Expanded(child: _SearchField(hint: searchHint)),
              ],
              if (!isWide) const Spacer(),
              if (!isWide)
                _IconBtn(
                  icon: Icons.search_rounded,
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  tooltip: 'Search',
                ),
              const SizedBox(width: 4),
              auth.when(
                data: (user) {
                  if (user != null) {
                    return PopupMenuButton<String>(
                      offset: const Offset(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                NordBiteTheme.coral,
                                NordBiteTheme.coralLight,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: NordBiteTheme.coral.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (user.email ?? 'U')[0].toUpperCase(),
                              style: GoogleFonts.karla(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
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
                                style: GoogleFonts.karla(fontSize: 13),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'favorites',
                              child: Row(
                                children: [
                                  Icon(Icons.favorite_rounded, size: 18),
                                  SizedBox(width: 10),
                                  Text('My Favorites'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'signout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout_rounded, size: 18),
                                  SizedBox(width: 10),
                                  Text('Sign Out'),
                                ],
                              ),
                            ),
                          ],
                    );
                  }
                  return _IconBtn(
                    icon: Icons.person_outline_rounded,
                    onTap: () => Navigator.pushNamed(context, '/auth'),
                    tooltip: 'Sign In',
                  );
                },
                loading: () => const SizedBox(width: 40),
                error: (_, _) => const SizedBox(width: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBtn({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 22, color: NordBiteTheme.charcoal),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String? hint;
  const _SearchField({this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      constraints: const BoxConstraints(maxWidth: 520),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint ?? 'Search restaurants, cuisines, cities...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: NordBiteTheme.charcoal.withValues(alpha: 0.35),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          filled: true,
          fillColor: NordBiteTheme.charcoal.withValues(alpha: 0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: NordBiteTheme.coral, width: 2),
          ),
        ),
        style: GoogleFonts.karla(fontSize: 14),
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
