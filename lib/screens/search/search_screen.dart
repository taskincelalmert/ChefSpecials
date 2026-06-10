import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/search_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/search_result_tile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider()
        ..loadRecipes()
        ..loadHistory(),
      child: const _SearchBody(),
    );
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final _controller = TextEditingController();
  final _ingredientController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient(SearchProvider provider) {
    final text = _ingredientController.text.trim();
    if (text.isEmpty) return;
    provider.addIngredient(text);
    _ingredientController.clear();
  }

  String _localizeCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Breakfast':
        return l10n.breakfast;
      case 'Lunch':
        return l10n.lunch;
      case 'Dinner':
        return l10n.dinner;
      case 'Dessert':
        return l10n.dessert;
      case 'Snack':
        return l10n.snack;
      case 'Drink':
        return l10n.drink;
      case 'Salad':
        return l10n.salad;
      case 'Soup':
        return l10n.soup;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.isIngredientMode
                    ? _buildIngredientMode(context, l10n, provider)
                    : _buildTextMode(context, l10n, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    SearchProvider provider,
  ) {
    final filterCount = provider.activeFilterCount;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [AppTheme.warmShadowLight()],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.neutralLightOf(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppTheme.textSecondaryOf(context),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.neutralLightOf(context),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: provider.isIngredientMode
                          ? Row(
                              children: [
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.blender_outlined,
                                  color: AppTheme.textTertiaryOf(context),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _ingredientController,
                                    autofocus: true,
                                    onSubmitted: (_) =>
                                        _addIngredient(provider),
                                    decoration: InputDecoration(
                                      hintText: l10n.addIngredient,
                                      hintStyle: TextStyle(
                                        color:
                                            AppTheme.textTertiaryOf(context),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 14),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppTheme.primaryColor,
                                    size: 22,
                                  ),
                                  onPressed: () => _addIngredient(provider),
                                ),
                              ],
                            )
                          : TextField(
                              controller: _controller,
                              autofocus: true,
                              onChanged: (v) => provider.search(v),
                              onSubmitted: (v) => provider.commitSearch(v),
                              decoration: InputDecoration(
                                hintText: l10n.searchHint,
                                hintStyle: TextStyle(
                                  color: AppTheme.textTertiaryOf(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.textTertiaryOf(context),
                                  size: 22,
                                ),
                                suffixIcon: provider.query.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color:
                                              AppTheme.textTertiaryOf(context),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _controller.clear();
                                          provider.search('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                    ),
                  ),
                  if (!provider.isIngredientMode) ...[
                    const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _showFilterSheet(context, provider, l10n),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: filterCount > 0
                                  ? AppTheme.primaryColor
                                  : AppTheme.neutralLightOf(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: filterCount > 0
                                  ? Colors.white
                                  : AppTheme.textSecondaryOf(context),
                              size: 22,
                            ),
                          ),
                        ),
                        if (filterCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$filterCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ModeChip(
                    label: l10n.search,
                    selected: !provider.isIngredientMode,
                    onTap: () {
                      provider.setIngredientMode(false);
                      _ingredientController.clear();
                    },
                  ),
                  const SizedBox(width: 8),
                  _ModeChip(
                    label: l10n.searchByIngredients,
                    icon: Icons.blender_outlined,
                    selected: provider.isIngredientMode,
                    onTap: () {
                      provider.setIngredientMode(true);
                      _controller.clear();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextMode(
    BuildContext context,
    AppLocalizations l10n,
    SearchProvider provider,
  ) {
    if (provider.query.isEmpty && provider.activeFilterCount == 0) {
      return _buildInitialState(context, l10n, provider);
    }

    final hasSuggestions = provider.suggestions.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: [
        if (hasSuggestions) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.search,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textTertiaryOf(context),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...provider.suggestions.map((s) => ListTile(
                leading: Icon(
                  Icons.search,
                  color: AppTheme.textTertiaryOf(context),
                  size: 18,
                ),
                title: Text(s, style: const TextStyle(fontSize: 14)),
                dense: true,
                onTap: () {
                  _controller.text = s;
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: s.length));
                  provider.search(s);
                  provider.commitSearch(s);
                },
              )),
          const Divider(height: 1),
        ],
        if (provider.results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: EmptyState(
              icon: Icons.search_off,
              title: l10n.noResults,
            ),
          )
        else
          ...provider.results.map((r) => SearchResultTile(recipe: r)),
      ],
    );
  }

  Widget _buildInitialState(
    BuildContext context,
    AppLocalizations l10n,
    SearchProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentSearches,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () async {
                    for (final h in List.of(provider.searchHistory)) {
                      await provider.removeFromHistory(h);
                    }
                  },
                  child: Text(
                    l10n.clearAll,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.searchHistory
                  .map((h) => _HistoryChip(
                        label: h,
                        onTap: () {
                          _controller.text = h;
                          provider.search(h);
                          provider.commitSearch(h);
                        },
                        onRemove: () => provider.removeFromHistory(h),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            l10n.category,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.defaultCategories.map((category) {
              return GestureDetector(
                onTap: () {
                  _controller.text = _localizeCategory(category, l10n);
                  provider.search(category);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.neutralLightOf(context),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    _localizeCategory(category, l10n),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientMode(
    BuildContext context,
    AppLocalizations l10n,
    SearchProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.ingredientFilters.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: provider.ingredientFilters
                  .map((ing) => Chip(
                        label: Text(ing),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => provider.removeIngredient(ing),
                        visualDensity: VisualDensity.compact,
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                        side: BorderSide(
                          color:
                              AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),
        ],
        if (provider.ingredientFilters.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.blender_outlined,
                      size: 64,
                      color: AppTheme.textTertiaryOf(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.searchByIngredients,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addIngredient,
                      style: TextStyle(
                        color: AppTheme.textTertiaryOf(context),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (provider.results.isEmpty)
          Expanded(
            child: EmptyState(
              icon: Icons.search_off,
              title: l10n.noResults,
            ),
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    l10n.bestMatches,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: provider.results.length,
                    itemBuilder: (_, i) =>
                        SearchResultTile(recipe: provider.results[i]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showFilterSheet(
    BuildContext context,
    SearchProvider provider,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(provider: provider, l10n: l10n),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Mode chip
// ─────────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected
                    ? Colors.white
                    : AppTheme.textSecondaryOf(context),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : AppTheme.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// History chip
// ─────────────────────────────────────────────────────────────

class _HistoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 14,
              color: AppTheme.textTertiaryOf(context),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14,
                color: AppTheme.textTertiaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Filter bottom sheet
// ─────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final SearchProvider provider;
  final AppLocalizations l10n;

  const _FilterSheet({required this.provider, required this.l10n});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _cookTimeRange;
  late bool _cookTimeEnabled;
  late RangeValues _calorieRange;
  late bool _calorieEnabled;
  String? _difficultyLevel;
  late double _maxIngredients;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    _cookTimeRange = p.cookTimeRange ?? const RangeValues(0, 120);
    _cookTimeEnabled = p.cookTimeRange != null;
    _calorieRange = p.calorieRange ?? const RangeValues(0, 1000);
    _calorieEnabled = p.calorieRange != null;
    _difficultyLevel = p.difficultyLevel;
    _maxIngredients = (p.maxIngredientCount ?? 20).toDouble();
    _sortBy = p.sortBy;
  }

  int get _draftActiveCount {
    int n = 0;
    if (_cookTimeEnabled) n++;
    if (_calorieEnabled) n++;
    if (_difficultyLevel != null) n++;
    if (_maxIngredients < 20) n++;
    if (_sortBy != 'newest') n++;
    return n;
  }

  void _resetAll() {
    setState(() {
      _cookTimeEnabled = false;
      _cookTimeRange = const RangeValues(0, 120);
      _calorieEnabled = false;
      _calorieRange = const RangeValues(0, 1000);
      _difficultyLevel = null;
      _maxIngredients = 20;
      _sortBy = 'newest';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.neutralLightOf(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filters,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _resetAll,
                  child: Text(l10n.clearAll),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cook time ──
                  _SectionTitle(l10n.cookingTime),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _PresetChip(
                        label: l10n.quickUnder15,
                        selected: _cookTimeEnabled &&
                            _cookTimeRange ==
                                const RangeValues(0, 15),
                        onTap: () => setState(() {
                          _cookTimeEnabled = true;
                          _cookTimeRange = const RangeValues(0, 15);
                        }),
                      ),
                      _PresetChip(
                        label: l10n.medium15to30,
                        selected: _cookTimeEnabled &&
                            _cookTimeRange ==
                                const RangeValues(15, 30),
                        onTap: () => setState(() {
                          _cookTimeEnabled = true;
                          _cookTimeRange =
                              const RangeValues(15, 30);
                        }),
                      ),
                      _PresetChip(
                        label: l10n.standard30to60,
                        selected: _cookTimeEnabled &&
                            _cookTimeRange ==
                                const RangeValues(30, 60),
                        onTap: () => setState(() {
                          _cookTimeEnabled = true;
                          _cookTimeRange =
                              const RangeValues(30, 60);
                        }),
                      ),
                      _PresetChip(
                        label: l10n.longOver60,
                        selected: _cookTimeEnabled &&
                            _cookTimeRange ==
                                const RangeValues(60, 120),
                        onTap: () => setState(() {
                          _cookTimeEnabled = true;
                          _cookTimeRange =
                              const RangeValues(60, 120);
                        }),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Switch(
                        value: _cookTimeEnabled,
                        onChanged: (v) =>
                            setState(() => _cookTimeEnabled = v),
                      ),
                      Expanded(
                        child: RangeSlider(
                          values: _cookTimeRange,
                          min: 0,
                          max: 120,
                          divisions: 24,
                          labels: RangeLabels(
                            '${_cookTimeRange.start.round()} min',
                            _cookTimeRange.end >= 120
                                ? '120+ min'
                                : '${_cookTimeRange.end.round()} min',
                          ),
                          onChanged: _cookTimeEnabled
                              ? (v) =>
                                  setState(() => _cookTimeRange = v)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // ── Calorie range ──
                  _SectionTitle(l10n.calorieRange),
                  Row(
                    children: [
                      Switch(
                        value: _calorieEnabled,
                        onChanged: (v) =>
                            setState(() => _calorieEnabled = v),
                      ),
                      Expanded(
                        child: RangeSlider(
                          values: _calorieRange,
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          labels: RangeLabels(
                            '${_calorieRange.start.round()} kcal',
                            _calorieRange.end >= 1000
                                ? '1000+ kcal'
                                : '${_calorieRange.end.round()} kcal',
                          ),
                          onChanged: _calorieEnabled
                              ? (v) =>
                                  setState(() => _calorieRange = v)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // ── Difficulty ──
                  _SectionTitle(l10n.difficulty),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _PresetChip(
                        label: l10n.easy,
                        selected: _difficultyLevel == 'Easy',
                        onTap: () => setState(() => _difficultyLevel =
                            _difficultyLevel == 'Easy' ? null : 'Easy'),
                      ),
                      _PresetChip(
                        label: l10n.medium,
                        selected: _difficultyLevel == 'Medium',
                        onTap: () => setState(() => _difficultyLevel =
                            _difficultyLevel == 'Medium'
                                ? null
                                : 'Medium'),
                      ),
                      _PresetChip(
                        label: l10n.hard,
                        selected: _difficultyLevel == 'Hard',
                        onTap: () => setState(() => _difficultyLevel =
                            _difficultyLevel == 'Hard' ? null : 'Hard'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // ── Max ingredients ──
                  Row(
                    children: [
                      _SectionTitle(l10n.maxIngredients),
                      const Spacer(),
                      Text(
                        _maxIngredients >= 20
                            ? '20+'
                            : '${_maxIngredients.round()}',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxIngredients,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: _maxIngredients >= 20
                        ? '20+'
                        : '${_maxIngredients.round()}',
                    onChanged: (v) =>
                        setState(() => _maxIngredients = v),
                  ),
                  const Divider(height: 24),

                  // ── Sort by ──
                  _SectionTitle(l10n.sortBy),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _PresetChip(
                        label: l10n.newest,
                        selected: _sortBy == 'newest',
                        onTap: () =>
                            setState(() => _sortBy = 'newest'),
                      ),
                      _PresetChip(
                        label: l10n.popular,
                        selected: _sortBy == 'popular',
                        onTap: () =>
                            setState(() => _sortBy = 'popular'),
                      ),
                      _PresetChip(
                        label: l10n.rating,
                        selected: _sortBy == 'rating',
                        onTap: () =>
                            setState(() => _sortBy = 'rating'),
                      ),
                      _PresetChip(
                        label: l10n.cookTime,
                        selected: _sortBy == 'cookTime',
                        onTap: () =>
                            setState(() => _sortBy = 'cookTime'),
                      ),
                      _PresetChip(
                        label: l10n.calories,
                        selected: _sortBy == 'calories',
                        onTap: () =>
                            setState(() => _sortBy = 'calories'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.provider.applyFilters(
                      cookTimeRange:
                          _cookTimeEnabled ? _cookTimeRange : null,
                      calorieRange:
                          _calorieEnabled ? _calorieRange : null,
                      difficultyLevel: _difficultyLevel,
                      maxIngredientCount: _maxIngredients < 20
                          ? _maxIngredients.round()
                          : null,
                      sortBy: _sortBy,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _draftActiveCount > 0
                        ? l10n.applyFiltersCount(_draftActiveCount)
                        : l10n.applyFilters,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Filter sheet helpers
// ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected
                ? Colors.white
                : AppTheme.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }
}
