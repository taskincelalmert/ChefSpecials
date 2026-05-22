import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/cooking_log_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../../widgets/achievement_celebration.dart';

class ShellScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  RecipeProvider? _recipeProvider;
  CookingLogProvider? _cookingLogProvider;
  ShoppingListProvider? _shoppingListProvider;
  CollectionProvider? _collectionProvider;
  VoidCallback? _listener;
  Timer? _debounce;
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _bootstrap() {
    if (!mounted) return;
    final userId = context.read<AuthProvider>().userModel?.uid;
    if (userId == null) return;
    _userId = userId;

    _recipeProvider = context.read<RecipeProvider>();
    _cookingLogProvider = context.read<CookingLogProvider>();
    _shoppingListProvider = context.read<ShoppingListProvider>();
    _collectionProvider = context.read<CollectionProvider>();

    _listener = _scheduleCheck;
    _recipeProvider!.addListener(_listener!);
    _cookingLogProvider!.addListener(_listener!);
    _shoppingListProvider!.addListener(_listener!);
    _collectionProvider!.addListener(_listener!);

    _recipeProvider!.ensureInitialized();
    _cookingLogProvider!.init(userId);
    _shoppingListProvider!.init(userId);
    _collectionProvider!.init(userId);
    context.read<AchievementProvider>().init(userId);

    _runCheckNow();
    for (final ms in const [500, 1500, 3500]) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (mounted) _runCheckNow();
      });
    }
  }

  void _runCheckNow() {
    if (!mounted || _userId == null) return;
    context.read<AchievementProvider>().refreshFromContext(context);
  }

  void _scheduleCheck() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _runCheckNow);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_listener != null) {
      _recipeProvider?.removeListener(_listener!);
      _cookingLogProvider?.removeListener(_listener!);
      _shoppingListProvider?.removeListener(_listener!);
      _collectionProvider?.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = widget.navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: AchievementCelebration(child: widget.navigationShell),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l10n.home,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.dynamic_feed_outlined,
                  activeIcon: Icons.dynamic_feed,
                  label: l10n.feed,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.track_changes_outlined,
                  activeIcon: Icons.track_changes,
                  label: l10n.dailyTracker,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.kitchen_outlined,
                  activeIcon: Icons.kitchen,
                  label: l10n.materials,
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  currentIndex: currentIndex,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l10n.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == currentIndex,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textTertiaryOf(context),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textTertiaryOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : null,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
