import 'dart:async';
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService;

  FavoriteProvider({FavoriteService? favoriteService})
      : _favoriteService = favoriteService ?? FavoriteService();

  Set<String> _favoriteRecipeIds = {};
  StreamSubscription? _subscription;
  String? _userId;

  Set<String> get favoriteRecipeIds => _favoriteRecipeIds;

  bool isFavorite(String recipeId) => _favoriteRecipeIds.contains(recipeId);

  void listenToFavorites(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _subscription = _favoriteService.getUserFavoriteIds(userId).listen(
      (ids) {
        _favoriteRecipeIds = ids.toSet();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('FavoriteProvider stream error: $e');
        // Stream is dead; allow the next listenToFavorites() to re-subscribe.
        _userId = null;
      },
    );
  }

  Future<void> toggleFavorite(String recipeId) async {
    if (_userId == null) return;
    await _favoriteService.toggleFavorite(_userId!, recipeId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
