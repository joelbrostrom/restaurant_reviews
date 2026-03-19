import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    ref.read(searchProvider.notifier).search(
          query: _searchController.text.trim().isNotEmpty
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
                // Filter sidebar on desktop
                if (isWide)
                  SizedBox(
                    width: 260,
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
                      // Search bar + filters for mobile
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search restaurants...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                                          onPressed: () {
                                            _searchController.clear();
                                            _doSearch();
                                          },
                                        )
                                      : null,
                                ),
                                onSubmitted: (_) => _doSearch(),
                              ),
                            ),
                            if (!isWide) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.tune_rounded),
                                onPressed: () => _showFilterSheet(context),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      NordBiteTheme.coral.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Category chips
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
                      const SizedBox(height: 8),
                      // Sort row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              '${search.results.length} results',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            DropdownButton<String>(
                              value: _sortBy,
                              underline: const SizedBox.shrink(),
                              style: Theme.of(context).textTheme.bodySmall,
                              items: const [
                                DropdownMenuItem(
                                    value: 'RELEVANCE', child: Text('Relevant')),
                                DropdownMenuItem(
                                    value: 'DISTANCE', child: Text('Closest')),
                                DropdownMenuItem(
                                    value: 'RATING',
                                    child: Text('Highest rated')),
                                DropdownMenuItem(
                                    value: 'AZ', child: Text('A–Z')),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _sortBy = v);
                                  _doSearch();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Results
                      Expanded(
                        child: search.isLoading
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
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.05,
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
              delay: Duration(milliseconds: 50 * (i % 6)),
              duration: const Duration(milliseconds: 350),
            )
            .slideY(
              begin: 0.05,
              delay: Duration(milliseconds: 50 * (i % 6)),
              duration: const Duration(milliseconds: 350),
            );
      },
    );
  }

  Widget _loadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.05,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (_, _) =>
          const ShimmerCard(width: double.infinity, height: double.infinity),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: NordBiteTheme.charcoal.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text('No restaurants found',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Try a different search or expand your radius.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
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
        Text('Categories', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
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
        const SizedBox(height: 20),
        Text('Sort by', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...['RELEVANCE', 'DISTANCE', 'RATING', 'AZ'].map((s) {
          final labels = {
            'RELEVANCE': 'Most relevant',
            'DISTANCE': 'Closest first',
            'RATING': 'Highest rated',
            'AZ': 'A–Z',
          };
          final isSelected = sortBy == s;
          return ListTile(
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? NordBiteTheme.coral : null,
              size: 20,
            ),
            title: Text(labels[s]!, style: const TextStyle(fontSize: 14)),
            dense: true,
            onTap: () => onSortChanged(s),
          );
        }),
      ],
    );
  }

  Widget _filterChip(String label, String key) {
    return FilterChip(
      label: Text(label),
      selected: selectedCategory == key,
      onSelected: (_) =>
          onCategoryChanged(selectedCategory == key ? null : key),
      selectedColor: NordBiteTheme.coral.withValues(alpha: 0.15),
      checkmarkColor: NordBiteTheme.coral,
    );
  }
}
