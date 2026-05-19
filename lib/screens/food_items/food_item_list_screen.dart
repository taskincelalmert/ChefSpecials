import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/food_item_provider.dart';
import '../../utils/category_helpers.dart';
import '../../widgets/empty_state.dart';
import 'widgets/food_item_card.dart';

class FoodItemListScreen extends StatefulWidget {
  const FoodItemListScreen({super.key});

  @override
  State<FoodItemListScreen> createState() => _FoodItemListScreenState();
}

class _FoodItemListScreenState extends State<FoodItemListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<FoodItemProvider>().ensureInitialized();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _isSearching) {
        setState(() {
          _isSearching = false;
          _searchController.clear();
        });
        context.read<FoodItemProvider>().searchFoodItems('');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<FoodItemProvider>();
    final view = View.of(context);
    final systemBottomInset = view.viewPadding.bottom / view.devicePixelRatio;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, provider),
          Expanded(child: _buildBody(l10n, provider)),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80 + systemBottomInset),
        child: FloatingActionButton(
          heroTag: 'materials_fab',
          onPressed: () => context.push('/add-food-item'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    FoodItemProvider provider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.materials,
                        style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                      ),
                      Text(
                        l10n.itemCount(provider.foodItems.length),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Filter button
                  GestureDetector(
                    onTap: () => _showFilterSheet(context, provider),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: provider.activeFilterCount > 0
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : AppTheme.neutralLightOf(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Badge(
                        isLabelVisible: provider.activeFilterCount > 0,
                        label: Text('${provider.activeFilterCount}'),
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.tune_rounded,
                          color: provider.activeFilterCount > 0
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryOf(context),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar
              GestureDetector(
                onTap: () {
                  if (!_isSearching) {
                    setState(() => _isSearching = true);
                  }
                },
                child: Container(
                  key: _searchBarKey,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.neutralLightOf(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _isSearching
                      ? Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search_outlined,
                              color: AppTheme.textTertiaryOf(context),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: l10n.searchFoodItems,
                                  hintStyle: TextStyle(
                                    color: AppTheme.textTertiaryOf(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                onChanged: (value) {
                                  provider.searchFoodItems(value);
                                  setState(() {});
                                },
                                onTapOutside: (event) {
                                  final box = _searchBarKey.currentContext
                                      ?.findRenderObject() as RenderBox?;
                                  if (box != null) {
                                    final localPos =
                                        box.globalToLocal(event.position);
                                    if (box.paintBounds.contains(localPos)) {
                                      return;
                                    }
                                  }
                                  // Delay so list item taps are processed first
                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () { if (mounted) _closeSearch(); },
                                  );
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_searchController.text.isEmpty) {
                                  _closeSearch();
                                } else {
                                  _searchController.clear();
                                  provider.searchFoodItems('');
                                  setState(() {});
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppTheme.textTertiaryOf(context),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search_outlined,
                              color: AppTheme.textTertiaryOf(context),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.searchFoodItems,
                              style: TextStyle(
                                color: AppTheme.textTertiaryOf(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, FoodItemProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _isSearching && provider.searchQuery.isNotEmpty
        ? provider.searchResults
        : provider.foodItems;

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: _isSearching ? l10n.noResults : l10n.noFoodItems,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FoodItemCard(foodItem: items[index]),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, FoodItemProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: _FilterSheetBody(l10n: l10n),
      ),
    );
  }
}

class _FilterSheetBody extends StatelessWidget {
  final AppLocalizations l10n;
  const _FilterSheetBody({required this.l10n});

  @override
  Widget build(BuildContext context) {
    const categories = [
      'All', 'Protein', 'Dairy', 'Grains', 'Vegetables',
      'Fruits', 'Oils & Fats', 'Beverages', 'Other',
    ];
    final provider = context.watch<FoodItemProvider>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.neutralLightOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.filters,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (provider.activeFilterCount > 0)
                  TextButton(
                    onPressed: () => provider.clearFilters(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(l10n.clearAll,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: AppTheme.neutralLightOf(context), height: 1),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          const SizedBox(height: 20),
          // Category section
          _buildLabel(l10n.category.toUpperCase(), context),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = provider.selectedCategory == category;
              return GestureDetector(
                onTap: () => provider.setCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.neutralLightOf(context),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    category == 'All' ? l10n.all : localizeFoodCategory(category, l10n),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textSecondaryOf(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Dietary section
          _buildLabel(l10n.dietary.toUpperCase(), context),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildToggleChip(
                context: context,
                label: l10n.vegan,
                icon: Icons.eco_outlined,
                selected: provider.filterVegan,
                onTap: () => provider.setFilterVegan(!provider.filterVegan),
              ),
              const SizedBox(width: 8),
              _buildToggleChip(
                context: context,
                label: l10n.vegetarian,
                icon: Icons.spa_outlined,
                selected: provider.filterVegetarian,
                onTap: () => provider.setFilterVegetarian(!provider.filterVegetarian),
              ),
              const SizedBox(width: 8),
              _buildToggleChip(
                context: context,
                label: l10n.glutenFree,
                icon: Icons.no_food_outlined,
                selected: provider.filterGlutenFree,
                onTap: () => provider.setFilterGlutenFree(!provider.filterGlutenFree),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Nutri-Score section
          _buildLabel(l10n.nutriScore.toUpperCase(), context),
          const SizedBox(height: 10),
          Row(
            children: ['A', 'B', 'C', 'D', 'E'].map((score) {
              final selected = provider.filterNutriScore == score;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => provider.setFilterNutriScore(selected ? null : score),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? _nutriScoreColor(score)
                          : AppTheme.neutralLightOf(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      score,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Sort section
          _buildLabel(l10n.sortBy.toUpperCase(), context),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSortChip(context, provider, 'name', l10n.name),
              const SizedBox(width: 8),
              _buildSortChip(context, provider, 'calories', l10n.calories),
              const SizedBox(width: 8),
              _buildSortChip(context, provider, 'protein', l10n.protein),
            ],
          ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Apply button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  provider.activeFilterCount > 0
                      ? l10n.applyFiltersCount(provider.activeFilterCount)
                      : l10n.applyFilters,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiaryOf(context),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildToggleChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.neutralLightOf(context),
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3))
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppTheme.primaryColor : AppTheme.textTertiaryOf(context),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppTheme.primaryColor : AppTheme.textSecondaryOf(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, FoodItemProvider provider, String value, String label) {
    final selected = provider.sortBy == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSortBy(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : AppTheme.neutralLightOf(context),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppTheme.textSecondaryOf(context),
            ),
          ),
        ),
      ),
    );
  }

  Color _nutriScoreColor(String score) {
    switch (score) {
      case 'A': return const Color(0xFF22C55E);
      case 'B': return const Color(0xFF84CC16);
      case 'C': return const Color(0xFFF59E0B);
      case 'D': return const Color(0xFFF97316);
      case 'E': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }
}
