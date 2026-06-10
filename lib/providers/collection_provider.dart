import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe_collection.dart';
import '../services/collection_service.dart';

class CollectionProvider extends ChangeNotifier {
  final CollectionService _service;

  CollectionProvider({CollectionService? collectionService})
      : _service = collectionService ?? CollectionService();

  List<RecipeCollection> _collections = [];
  StreamSubscription? _subscription;
  String? _userId;
  bool _isLoading = false;

  List<RecipeCollection> get collections => _collections;
  bool get isLoading => _isLoading;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _service.getUserCollections(userId).listen(
      (data) {
        _collections = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        // Firestore closes the stream on error; clear _userId so the
        // next init() call re-subscribes instead of being a no-op.
        _userId = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  List<RecipeCollection> collectionsContaining(String recipeId) {
    return _collections
        .where((c) => c.recipeIds.contains(recipeId))
        .toList();
  }

  Future<String> createCollection(String name, {String? description}) async {
    if (_userId == null) return '';
    final now = DateTime.now();
    final collection = RecipeCollection(
      userId: _userId!,
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    final id = await _service.createCollection(collection);
    // Show the new collection right away instead of waiting for the
    // snapshot listener; the next stream emission replaces the list.
    if (id.isNotEmpty && !_collections.any((c) => c.id == id)) {
      _collections = [
        RecipeCollection(
          id: id,
          userId: collection.userId,
          name: collection.name,
          description: collection.description,
          createdAt: collection.createdAt,
          updatedAt: collection.updatedAt,
        ),
        ..._collections,
      ];
      notifyListeners();
    }
    return id;
  }

  Future<void> deleteCollection(String collectionId) async {
    await _service.deleteCollection(collectionId);
  }

  Future<void> addRecipe(String collectionId, String recipeId) async {
    await _service.addRecipe(collectionId, recipeId);
  }

  Future<void> removeRecipe(String collectionId, String recipeId) async {
    await _service.removeRecipe(collectionId, recipeId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
