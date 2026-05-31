import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/trending_service.dart';

class TrendingProvider extends ChangeNotifier {
  final TrendingService _service;

  TrendingProvider({TrendingService? service})
      : _service = service ?? TrendingService();

  static const Duration _cacheDuration = Duration(hours: 1);

  List<Recipe> _trendingRecipes = [];
  bool _loading = false;
  DateTime? _lastRefreshed;
  String _currentTimeWindow = '7d';

  List<Recipe> get trendingRecipes => _trendingRecipes;
  bool get loading => _loading;
  DateTime? get lastRefreshed => _lastRefreshed;
  String get currentTimeWindow => _currentTimeWindow;

  Set<String> get trendingIds =>
      _trendingRecipes.map((r) => r.id).whereType<String>().toSet();

  int? rankOf(String recipeId) {
    for (var i = 0; i < _trendingRecipes.length; i++) {
      if (_trendingRecipes[i].id == recipeId) return i + 1;
    }
    return null;
  }

  bool _isFresh() {
    final last = _lastRefreshed;
    if (last == null) return false;
    return DateTime.now().difference(last) < _cacheDuration;
  }

  Future<void> loadTrending({
    int limit = 10,
    String timeWindow = '7d',
    bool force = false,
  }) async {
    if (!force &&
        _isFresh() &&
        _currentTimeWindow == timeWindow &&
        _trendingRecipes.isNotEmpty) {
      return;
    }
    _loading = true;
    _currentTimeWindow = timeWindow;
    notifyListeners();
    try {
      _trendingRecipes = await _service.getTrendingRecipes(
        limit: limit,
        timeWindow: timeWindow,
      );
      _lastRefreshed = DateTime.now();
    } catch (e) {
      debugPrint('TrendingProvider.loadTrending error: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh({String timeWindow = '7d', int limit = 10}) async {
    await loadTrending(limit: limit, timeWindow: timeWindow, force: true);
  }

  void removeRecipe(String recipeId) {
    final before = _trendingRecipes.length;
    _trendingRecipes =
        _trendingRecipes.where((r) => r.id != recipeId).toList();
    if (_trendingRecipes.length != before) notifyListeners();
  }
}
