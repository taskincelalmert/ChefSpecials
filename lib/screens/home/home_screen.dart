import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../models/user_model.dart';
import '../../utils/category_helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/block_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/trending_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _selectedDietaryTags = {};
  String? _selectedCategory;
  String _sortBy = 'newest';
  String? _lastSyncedUid;
  late ScrollController _scrollController;

  int get _activeFilterCount =>
      (_selectedCategory != null ? 1 : 0) +
      _selectedDietaryTags.length +
      (_sortBy != 'newest' ? 1 : 0);

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecipeProvider>().ensureInitialized();
      context.read<TrendingProvider>().loadTrending();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<RecipeProvider>().loadMore();
    }
  }

  void _syncUserBoundProviders(String uid) {
    context.read<FavoriteProvider>().listenToFavorites(uid);
    context.read<ActivityProvider>().init(uid);
    context.read<TrendingProvider>().loadTrending(force: true);
    context.read<BlockProvider>().initialize(uid);
  }

  List<Recipe> _applyLocalFilters(List<Recipe> recipes) {
    var result = recipes.toList();

    if (_selectedCategory != null) {
      result = result.where((r) => r.category == _selectedCategory).toList();
    }

    if (_selectedDietaryTags.isNotEmpty) {
      result = result
          .where((r) => _selectedDietaryTags.every((tag) => r.dietaryTags.contains(tag)))
          .toList();
    }

    switch (_sortBy) {
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case 'popular':
        result.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipeProvider = context.watch<RecipeProvider>();
    final trendingProvider = context.watch<TrendingProvider>();
    final authUser = context.select<AuthProvider, UserModel?>((a) => a.userModel);
    final authUid = authUser?.uid;
    if (authUid != null && authUid != _lastSyncedUid) {
      _lastSyncedUid = authUid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncUserBoundProviders(authUid);
      });
    }
    final blockedIds = context.watch<BlockProvider>().blockedUserIds;
    final allPublic = recipeProvider.allRecipes
        .where((r) => !r.isPrivate && !blockedIds.contains(r.authorId))
        .toList();
    final filteredRecipes = _applyLocalFilters(allPublic);
    final hasActiveFilter = _activeFilterCount > 0;
    final trendingIds = trendingProvider.trendingIds;

    final view = View.of(context);
    final systemBottomInset = view.viewPadding.bottom / view.devicePixelRatio;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, authUser),
          Expanded(
            child: recipeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRecipes.isEmpty
                    ? EmptyState(
                        icon: Icons.restaurant_menu,
                        title: l10n.noRecipes,
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: filteredRecipes.length +
                            (hasActiveFilter ? 0 : 1) +
                            (recipeProvider.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (recipeProvider.isLoadingMore &&
                              index ==
                                  filteredRecipes.length +
                                      (hasActiveFilter ? 0 : 1)) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (!hasActiveFilter && index == 0) {
                            return _buildDiscoverySections(context, l10n, trendingProvider);
                          }
                          final recipeIndex = hasActiveFilter ? index : index - 1;
                          final recipe = filteredRecipes[recipeIndex];
                          final isTrending =
                              recipe.id != null && trendingIds.contains(recipe.id);
                          return RepaintBoundary(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: RecipeCard(
                                recipe: recipe,
                                showTrendingBadge: isTrending,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80 + systemBottomInset),
        child: FloatingActionButton(
          heroTag: 'home_fab',
          onPressed: () => context.push('/add-recipe'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, UserModel? user) {
    final firstName = user?.firstName ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (firstName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${_getGreeting(l10n)}, $firstName!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryOf(context),
                        ),
                  ),
                ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'ChefSpecials',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Notifications',
                    child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppTheme.textSecondaryOf(context),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(6),
                        ),
                        onPressed: () => context.push('/announcements'),
                      ),
                      Consumer<ActivityProvider>(
                        builder: (context, provider, _) {
                          if (provider.unreadCount == 0) {
                            return const SizedBox.shrink();
                          }
                          return Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.errorColor,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                provider.unreadCount > 99
                                    ? '99+'
                                    : '${provider.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ),
                  Tooltip(
                    message: 'Collections',
                    child: IconButton(
                    icon: const Icon(Icons.folder_outlined),
                    color: AppTheme.textSecondaryOf(context),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(6),
                    ),
                    onPressed: () => context.push('/collections'),
                  ),
                  ),
                  Tooltip(
                    message: 'Shopping List',
                    child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    color: AppTheme.textSecondaryOf(context),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(6),
                    ),
                    onPressed: () => context.push('/shopping-lists'),
                  ),
                  ),
                  Tooltip(
                    message: 'Favorites',
                    child: IconButton(
                    icon: const Icon(Icons.favorite_outline),
                    color: AppTheme.textSecondaryOf(context),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(6),
                    ),
                    onPressed: () => context.push('/favorites'),
                  ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar with filter icon
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.neutralLightOf(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search,
                              color: AppTheme.textTertiaryOf(context),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.searchRecipeOrIngredient,
                                style: TextStyle(
                                  color: AppTheme.textTertiaryOf(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter button
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _activeFilterCount > 0
                            ? AppTheme.primaryColor
                            : AppTheme.neutralLightOf(context),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Badge(
                        isLabelVisible: _activeFilterCount > 0,
                        label: Text(
                          '$_activeFilterCount',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: Colors.white,
                        textColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.tune_rounded,
                          size: 22,
                          color: _activeFilterCount > 0
                              ? Colors.white
                              : AppTheme.textTertiaryOf(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
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
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.filters,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_activeFilterCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _selectedDietaryTags.clear();
                              _sortBy = 'newest';
                            });
                            setSheetState(() {});
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(
                            l10n.clearAll,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: AppTheme.neutralLightOf(context), height: 1),
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CATEGORY SECTION
                        _buildSectionHeader(
                          context,
                          icon: Icons.category_rounded,
                          title: l10n.category,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.defaultCategories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return _buildChip(
                              context: context,
                              label: _localizeCategory(cat, l10n),
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = isSelected ? null : cat;
                                });
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        // DIETARY TAGS SECTION
                        _buildSectionHeader(
                          context,
                          icon: Icons.eco_rounded,
                          title: l10n.dietaryTags,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.defaultDietaryTags.map((tag) {
                            final isSelected = _selectedDietaryTags.contains(tag);
                            return _buildChip(
                              context: context,
                              label: localizeDietaryTag(tag, l10n),
                              selected: isSelected,
                              outlined: true,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedDietaryTags.remove(tag);
                                  } else {
                                    _selectedDietaryTags.add(tag);
                                  }
                                });
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        // SORT SECTION
                        _buildSectionHeader(
                          context,
                          icon: Icons.sort_rounded,
                          title: l10n.sortBy,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSortOption(context, setSheetState, 'newest', l10n.newest),
                            _buildSortOption(context, setSheetState, 'oldest', l10n.oldest),
                            _buildSortOption(context, setSheetState, 'popular', l10n.popular),
                          ],
                        ),
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
                        _activeFilterCount > 0
                            ? l10n.applyFiltersCount(_activeFilterCount)
                            : l10n.applyFilters,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (outlined
                  ? AppTheme.primaryColor.withValues(alpha: 0.12)
                  : AppTheme.primaryColor)
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(50),
          border: selected && outlined
              ? Border.all(color: AppTheme.primaryColor, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? (outlined ? AppTheme.primaryColor : Colors.white)
                : AppTheme.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    StateSetter setSheetState,
    String value,
    String label,
  ) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        setSheetState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverySections(
    BuildContext context,
    AppLocalizations l10n,
    TrendingProvider provider,
  ) {
    final blockedIds = context.read<BlockProvider>().blockedUserIds;
    final trending = provider.trendingRecipes
        .where((r) => !blockedIds.contains(r.authorId))
        .toList();
    if (trending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.deepOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.popularThisWeek,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/trending'),
                child: Text(
                  l10n.seeAll,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trending.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final recipe = trending[index];
              return SizedBox(
                width: 200,
                child: _CompactTrendingCard(
                  recipe: recipe,
                  rank: index + 1,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
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
}

class _CompactTrendingCard extends StatelessWidget {
  final Recipe recipe;
  final int rank;

  const _CompactTrendingCard({required this.recipe, required this.rank});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}', extra: recipe),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            color: AppTheme.neutralLightOf(context),
                            child: Icon(
                              Icons.restaurant,
                              size: 40,
                              color: AppTheme.textTertiaryOf(context),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.neutralLightOf(context),
                          child: Icon(
                            Icons.restaurant,
                            size: 40,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '#$rank',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: AppTheme.starColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        recipe.averageRating > 0
                            ? recipe.averageRating.toStringAsFixed(1)
                            : '-',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppTheme.textTertiaryOf(context),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.prepTimeMinutes + recipe.cookTimeMinutes}m',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
