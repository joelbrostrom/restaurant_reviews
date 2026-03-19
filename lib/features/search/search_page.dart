import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';
import 'package:nordbite/widgets/app_drawer.dart';
import 'package:nordbite/widgets/app_header.dart';
import 'package:nordbite/widgets/category_chips.dart';
import 'package:nordbite/widgets/restaurant_card.dart';
import 'package:nordbite/widgets/shimmer_placeholder.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const SearchPage({super.key, this.initialQuery, this.initialCategory});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String _sortBy = 'RELEVANCE';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _doSearch());
    }
  }

  void _doSearch() {
    ref
        .read(searchProvider.notifier)
        .search(
          query:
              _searchController.text.trim().isNotEmpty
                  ? _searchController.text.trim()
                  : null,
          categoryKey: _selectedCategory,
          sortBy: _sortBy,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchProvider);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          AppHeader(
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            searchHint: 'Search restaurants...',
          ),
          Expanded(
            child: Row(
              children: [
                if (isWide)
                  Container(
                    width: 270,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    child: _FilterPanel(
                      selectedCategory: _selectedCategory,
                      sortBy: _sortBy,
                      onCategoryChanged: (cat) {
                        setState(() => _selectedCategory = cat);
                        _doSearch();
                      },
                      onSortChanged: (sort) {
                        setState(() => _sortBy = sort);
                        _doSearch();
                      },
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search restaurants...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon:
                                      _searchController.text.isNotEmpty
                                          ? IconButton(
                                            icon: const Icon(
                                              Icons.clear_rounded,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              _doSearch();
                                            },
                                          )
                                          : null,
                                ),
                                style: GoogleFonts.karla(fontSize: 14),
                                onSubmitted: (_) => _doSearch(),
                              ),
                            ),
                            if (!isWide) ...[
                              const SizedBox(width: 10),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showFilterSheet(context),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: NordBiteTheme.coral.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      color: NordBiteTheme.coral,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      CategoryChips(
                        selected: _selectedCategory,
                        onSelected: (cat) {
                          setState(() {
                            _selectedCategory =
                                _selectedCategory == cat ? null : cat;
                          });
                          _doSearch();
                        },
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              '${search.results.length} results',
                              style: GoogleFonts.karla(
                                fontSize: 13,
                                color: NordBiteTheme.charcoal.withValues(
                                  alpha: 0.5,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: NordBiteTheme.charcoal.withValues(
                                  alpha: 0.04,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: _sortBy,
                                underline: const SizedBox.shrink(),
                                style: GoogleFonts.karla(
                                  fontSize: 13,
                                  color: NordBiteTheme.charcoal,
                                  fontWeight: FontWeight.w600,
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'RELEVANCE',
                                    child: Text('Relevant'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'DISTANCE',
                                    child: Text('Closest'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'RATING',
                                    child: Text('Highest rated'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'AZ',
                                    child: Text('A–Z'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _sortBy = v);
                                    _doSearch();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            search.isLoading
                                ? _loadingGrid()
                                : search.results.isEmpty
                                ? _emptyState()
                                : _resultsGrid(search, isWide),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsGrid(SearchState search, bool isWide) {
    final crossAxisCount = isWide ? 3 : 2;
    return GridView.builder(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.95,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: search.results.length,
      itemBuilder: (_, i) {
        return RestaurantCard(
              restaurant: search.results[i],
              width: double.infinity,
              height: double.infinity,
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 40 * (i % 6)),
              duration: const Duration(milliseconds: 350),
            )
            .slideY(
              begin: 0.04,
              delay: Duration(milliseconds: 40 * (i % 6)),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _loadingGrid() {
    return GridView.builder(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder:
          (_, _) => const ShimmerCard(
            width: double.infinity,
            height: double.infinity,
          ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: NordBiteTheme.charcoal.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: NordBiteTheme.charcoal.withValues(alpha: 0.25),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No restaurants found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or expand your radius.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NordBiteTheme.warmWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(28),
            child: _FilterPanel(
              selectedCategory: _selectedCategory,
              sortBy: _sortBy,
              onCategoryChanged: (cat) {
                setState(() => _selectedCategory = cat);
                _doSearch();
                Navigator.pop(context);
              },
              onSortChanged: (sort) {
                setState(() => _sortBy = sort);
                _doSearch();
                Navigator.pop(context);
              },
            ),
          ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final String? selectedCategory;
  final String sortBy;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onSortChanged;

  const _FilterPanel({
    required this.selectedCategory,
    required this.sortBy,
    required this.onCategoryChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Categories',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: NordBiteTheme.charcoal,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChip('Burgers', 'burgers'),
            _filterChip('Pizza', 'pizza'),
            _filterChip('Tacos', 'tacos'),
            _filterChip('Vegetarian', 'vegetarian'),
            _filterChip('Sushi', 'sushi'),
            _filterChip('Coffee', 'coffee'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Sort by',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: NordBiteTheme.charcoal,
          ),
        ),
        const SizedBox(height: 12),
        ...['RELEVANCE', 'DISTANCE', 'RATING', 'AZ'].map((s) {
          final labels = {
            'RELEVANCE': 'Most relevant',
            'DISTANCE': 'Closest first',
            'RATING': 'Highest rated',
            'AZ': 'A–Z',
          };
          final icons = {
            'RELEVANCE': Icons.auto_awesome_rounded,
            'DISTANCE': Icons.near_me_rounded,
            'RATING': Icons.star_rounded,
            'AZ': Icons.sort_by_alpha_rounded,
          };
          final isSelected = sortBy == s;
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSortChanged(s),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icons[s],
                        size: 18,
                        color:
                            isSelected
                                ? NordBiteTheme.coral
                                : NordBiteTheme.charcoal.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        labels[s]!,
                        style: GoogleFonts.karla(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isSelected
                                  ? NordBiteTheme.coral
                                  : NordBiteTheme.charcoal,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: NordBiteTheme.coral,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _filterChip(String label, String key) {
    final isActive = selectedCategory == key;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onCategoryChanged(selectedCategory == key ? null : key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? NordBiteTheme.coral : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isActive
                      ? NordBiteTheme.coral
                      : NordBiteTheme.charcoal.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.karla(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : NordBiteTheme.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
