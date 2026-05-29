import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../models/user_achievement.dart';
import '../services/achievement_service.dart';
import '../services/follow_service.dart';
import 'auth_provider.dart';
import 'collection_provider.dart';
import 'cooking_log_provider.dart';
import 'recipe_provider.dart';
import 'shopping_list_provider.dart';

class AchievementProvider extends ChangeNotifier {
  final AchievementService _service;

  AchievementProvider({AchievementService? service, FollowService? followService})
      : _service = service ?? AchievementService(),
        _followServiceOverride = followService;

  final FollowService? _followServiceOverride;
  FollowService? _cachedFollowService;
  FollowService get _followService =>
      _followServiceOverride ??
      (_cachedFollowService ??= FollowService());

  StreamSubscription? _subscription;
  String? _userId;
  bool _isLoading = false;

  List<UserAchievement> _unlockedAchievements = [];
  Map<String, double> _progressMap = {};
  List<Achievement> _newlyUnlocked = [];
  Map<String, dynamic> _lastContext = {};

  List<UserAchievement> get unlockedAchievements => _unlockedAchievements;
  Map<String, double> get progressMap => _progressMap;
  List<Achievement> get newlyUnlocked => _newlyUnlocked;
  bool get isLoading => _isLoading;

  Set<String> get unlockedIds =>
      _unlockedAchievements.map((u) => u.achievementId).toSet();

  int get unlockedCount => _unlockedAchievements.length;
  int get totalCount => Achievement.allAchievements.length;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    _subscription = _service.streamUserAchievements(userId).listen(
      (data) {
        _unlockedAchievements = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> checkAchievements(Map<String, dynamic> context) async {
    if (_userId == null) return;
    _lastContext = Map<String, dynamic>.from(context);
    await _recomputeProgress();
    try {
      final newly = await _service.checkAndUnlockAchievements(
        _userId!,
        context: context,
      );
      if (newly.isNotEmpty) {
        _newlyUnlocked = [..._newlyUnlocked, ...newly];
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _recomputeProgress() async {
    final map = <String, double>{};
    for (final achievement in Achievement.allAchievements) {
      map[achievement.id] =
          await _service.getProgress(_userId!, achievement, context: _lastContext);
    }
    _progressMap = map;
    notifyListeners();
  }

  double getProgress(String achievementId) {
    if (unlockedIds.contains(achievementId)) return 1.0;
    return _progressMap[achievementId] ?? 0.0;
  }

  bool isUnlocked(String achievementId) => unlockedIds.contains(achievementId);

  UserAchievement? unlockedFor(String achievementId) {
    for (final ua in _unlockedAchievements) {
      if (ua.achievementId == achievementId) return ua;
    }
    return null;
  }

  Future<void> refreshFromContext(BuildContext context) async {
    if (_userId == null) return;
    final userId = _userId!;
    final recipeProvider = context.read<RecipeProvider>();
    final cookingLogProvider = context.read<CookingLogProvider>();
    final shoppingListProvider = context.read<ShoppingListProvider>();
    final collectionProvider = context.read<CollectionProvider>();

    final myRecipes =
        recipeProvider.allRecipes.where((r) => r.authorId == userId).toList();

    final cookedRecipeIds = cookingLogProvider.cookingHistory
        .map((l) => l.recipeId)
        .toSet();

    final allRecipes = recipeProvider.allRecipes;
    final categoriesCooked = cookedRecipeIds
        .map((id) {
          for (final r in allRecipes) {
            if (r.id == id) return r.category;
          }
          return null;
        })
        .whereType<String>()
        .toSet();

    double maxAverageRating = 0.0;
    for (final r in myRecipes) {
      if (r.ratingCount > 0 && r.averageRating > maxAverageRating) {
        maxAverageRating = r.averageRating;
      }
    }

    int followers = 0;
    try {
      final followerIds = await _followService.getFollowerIds(userId);
      followers = followerIds.length;
    } catch (_) {}

    final stats = <String, dynamic>{
      'recipesPublished': myRecipes.length,
      'uniqueRecipesCooked': cookedRecipeIds.length,
      'categoriesCooked': categoriesCooked.length,
      'shoppingLists': shoppingListProvider.lists.length,
      'collections': collectionProvider.collections.length,
      'averageRating': maxAverageRating,
      'followers': followers,
    };

    await checkAchievements(stats);
  }

  void _maybeTouchAuth(BuildContext context) {
    final userId = context.read<AuthProvider>().userModel?.uid;
    if (userId != null && _userId != userId) {
      init(userId);
    }
  }

  Future<void> triggerCheck(BuildContext context) async {
    _maybeTouchAuth(context);
    await refreshFromContext(context);
  }

  void clearNewlyUnlocked() {
    if (_newlyUnlocked.isEmpty) return;
    _newlyUnlocked = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
