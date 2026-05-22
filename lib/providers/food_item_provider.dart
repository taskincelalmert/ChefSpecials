import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/food_item_service.dart';

class FoodItemProvider extends ChangeNotifier {
  final FoodItemService _foodItemService;

  FoodItemProvider({
    FoodItemService? foodItemService,
  }) : _foodItemService = foodItemService ?? FoodItemService();

  List<FoodItem> _foodItems = [];
  List<FoodItem> _searchResults = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String _searchQuery = '';
  StreamSubscription? _subscription;

  bool _initialized = false;

  // Filters
  bool _filterVegan = false;
  bool _filterVegetarian = false;
  bool _filterGlutenFree = false;
  String? _filterNutriScore;
  String _sortBy = 'name'; // name, calories, protein

  // Cached filter results — recomputed only when source data or filters change
  bool _filtersDirty = true;
  List<FoodItem> _cachedFoodItems = [];
  List<FoodItem> _cachedSearchResults = [];

  List<FoodItem> get foodItems {
    if (_filtersDirty) _rebuildCache();
    return _cachedFoodItems;
  }

  List<FoodItem> get searchResults {
    if (_filtersDirty) _rebuildCache();
    return _cachedSearchResults;
  }

  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get filterVegan => _filterVegan;
  bool get filterVegetarian => _filterVegetarian;
  bool get filterGlutenFree => _filterGlutenFree;
  String? get filterNutriScore => _filterNutriScore;
  String get sortBy => _sortBy;
  int get activeFilterCount =>
      (_filterVegan ? 1 : 0) +
      (_filterVegetarian ? 1 : 0) +
      (_filterGlutenFree ? 1 : 0) +
      (_filterNutriScore != null ? 1 : 0);

  void _rebuildCache() {
    _cachedFoodItems = _applyFilters(_foodItems);
    _cachedSearchResults = _applyFilters(_searchResults);
    _filtersDirty = false;
  }

  void _invalidate() {
    _filtersDirty = true;
  }

  List<FoodItem> _applyFilters(List<FoodItem> items) {
    var result = items.where((item) {
      if (_filterVegan && !item.isVegan) return false;
      if (_filterVegetarian && !item.isVegetarian) return false;
      if (_filterGlutenFree && !item.isGlutenFree) return false;
      if (_filterNutriScore != null && item.nutriScore != _filterNutriScore) {
        return false;
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case 'calories':
        result.sort((a, b) => a.calories.compareTo(b.calories));
      case 'protein':
        result.sort((a, b) => b.protein.compareTo(a.protein));
      default:
        result.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return result;
  }

  void setFilterVegan(bool value) {
    _filterVegan = value;
    _invalidate();
    notifyListeners();
  }

  void setFilterVegetarian(bool value) {
    _filterVegetarian = value;
    _invalidate();
    notifyListeners();
  }

  void setFilterGlutenFree(bool value) {
    _filterGlutenFree = value;
    _invalidate();
    notifyListeners();
  }

  void setFilterNutriScore(String? value) {
    _filterNutriScore = value;
    _invalidate();
    notifyListeners();
  }

  void setSortBy(String value) {
    _sortBy = value;
    _invalidate();
    notifyListeners();
  }

  void clearFilters() {
    _filterVegan = false;
    _filterVegetarian = false;
    _filterGlutenFree = false;
    _filterNutriScore = null;
    _sortBy = 'name';
    _invalidate();
    notifyListeners();
  }

  void ensureInitialized() {
    if (!_initialized) {
      _initialized = true;
      listenToFoodItems();
    }
  }

  void listenToFoodItems() {
    _isLoading = true;

    _subscription?.cancel();

    final stream = _selectedCategory == 'All'
        ? _foodItemService.getFoodItems()
        : _foodItemService.getFoodItemsByCategory(_selectedCategory);

    _subscription = stream.listen(
      (items) {
        _foodItems = items;
        _invalidate();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setCategory(String category) {
    _selectedCategory = category;
    listenToFoodItems();
  }

  Future<void> searchFoodItems(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      _invalidate();
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _searchResults = await _foodItemService.searchFoodItems(query);
    } catch (_) {
      final lower = query.toLowerCase();
      _searchResults = _foodItems
          .where((f) => f.name.toLowerCase().contains(lower))
          .toList();
    }
    _invalidate();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFoodItem(FoodItem item) async {
    await _foodItemService.addFoodItem(item);
  }

  Future<void> deleteFoodItem(String id) async {
    await _foodItemService.deleteFoodItem(id);
  }

  Future<void> updateFoodItem(FoodItem item) async {
    await _foodItemService.updateFoodItem(item);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
