import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_goal.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/daily_tracker_service.dart';

class DailyTrackerProvider extends ChangeNotifier {
  final DailyTrackerService _service;
  final CacheService? _cacheService;
  final ConnectivityService? _connectivityService;

  DailyTrackerProvider({
    DailyTrackerService? dailyTrackerService,
    CacheService? cacheService,
    ConnectivityService? connectivityService,
    Stream<User?>? authStream,
  })  : _service = dailyTrackerService ?? DailyTrackerService(),
        _cacheService = cacheService,
        _connectivityService = connectivityService {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _authSub = (authStream ?? FirebaseAuth.instance.authStateChanges())
        .listen(_onAuthChanged);
  }

  DailyLog? _dailyLog;
  NutritionGoal? _nutritionGoal;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _userId;
  Map<String, double> _weeklyCalories = {};
  String? _loadedWeekKey;

  StreamSubscription? _logSubscription;
  StreamSubscription? _goalSubscription;
  StreamSubscription<User?>? _authSub;

  DailyLog? get dailyLog => _dailyLog;
  NutritionGoal? get nutritionGoal => _nutritionGoal;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String get dateString => DateFormat('yyyy-MM-dd').format(_selectedDate);
  Map<String, double> get weeklyCalories => _weeklyCalories;

  void init(String userId) {
    if (_userId == userId && _logSubscription != null) return;
    _bindUser(userId);
  }

  void _onAuthChanged(User? user) {
    final newUid = user?.uid;
    if (newUid == _userId && (newUid == null || _logSubscription != null)) {
      return;
    }
    if (newUid == null) {
      _userId = null;
      _logSubscription?.cancel();
      _goalSubscription?.cancel();
      _logSubscription = null;
      _goalSubscription = null;
      _dailyLog = null;
      _nutritionGoal = null;
      _weeklyCalories = {};
      _loadedWeekKey = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _bindUser(newUid);
  }

  void _bindUser(String userId) {
    _userId = userId;
    _loadedWeekKey = null;
    _listenToGoal();
    _listenToLog();
    loadWeeklyCalories(_selectedDate);
  }

  void setDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _listenToLog();
    loadWeeklyCalories(_selectedDate);
    notifyListeners();
  }

  Future<void> loadWeeklyCalories(DateTime referenceDate) async {
    if (_userId == null) return;
    final weekStart =
        referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
    final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
    if (_loadedWeekKey == weekKey) return;
    _loadedWeekKey = weekKey;

    final dates = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      return DateFormat('yyyy-MM-dd').format(day);
    });
    _weeklyCalories = await _service.getWeeklyCalories(_userId!, dates);
    notifyListeners();
  }

  void refreshWeeklyCalories() {
    _loadedWeekKey = null;
    loadWeeklyCalories(_selectedDate);
  }

  void _listenToLog() {
    _logSubscription?.cancel();
    if (_userId == null) return;
    if (_dailyLog == null && !_isLoading) _isLoading = true;
    _dailyLog = null;

    // Immediately serve cached log so the UI isn't blank — but only if it
    // belongs to the current user. The cache is keyed by date alone, so
    // without this check we can serve another user's log after re-login.
    final cached = _cacheService?.getCachedDailyLog(dateString);
    if (cached != null && cached.userId == _userId) {
      _dailyLog = cached;
      _isLoading = false;
      notifyListeners();
    }

    _logSubscription = _service.getDailyLog(_userId!, dateString).listen(
      (log) {
        _dailyLog = log;
        _isLoading = false;
        _weeklyCalories[dateString] = log?.totalCalories ?? 0;
        notifyListeners();
        if (log != null) _cacheService?.cacheDailyLog(log);
      },
      onError: (_) {
        _isLoading = false;
        if (_dailyLog == null) {
          final cached = _cacheService?.getCachedDailyLog(dateString);
          if (cached != null && cached.userId == _userId) {
            _dailyLog = cached;
          }
        }
        notifyListeners();
      },
    );
  }

  void _listenToGoal() {
    _goalSubscription?.cancel();
    if (_userId == null) return;
    _goalSubscription = _service.getNutritionGoal(_userId!).listen(
      (goal) {
        _nutritionGoal = goal;
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  Future<void> addMealEntry(MealEntry entry) async {
    // Always write as the live Firebase Auth user. The Firestore security
    // rule requires `request.resource.data.userId == request.auth.uid`, so
    // a stale `_userId` (from a previous session) would be rejected with
    // permission-denied. Re-bind eagerly if they drift apart.
    final liveUid = FirebaseAuth.instance.currentUser?.uid;
    if (liveUid == null) return;
    if (_userId != liveUid) {
      _bindUser(liveUid);
    }

    final isOnline = await _connectivityService?.isOnline() ?? true;
    final currentMeals = List<MealEntry>.from(_dailyLog?.meals ?? [])
      ..add(entry);

    if (!isOnline) {
      // Optimistic local update
      _dailyLog = (_dailyLog ??
              DailyLog(userId: _userId!, date: dateString, meals: []))
          .copyWith(meals: currentMeals);
      notifyListeners();
      await _cacheService?.cacheDailyLog(_dailyLog!);
      await _cacheService?.queueOfflineAction({
        'type': 'add_meal_entry',
        'userId': _userId,
        'dateString': dateString,
        'entry': entry.toMap(),
      });
      return;
    }

    final cachedLog = _dailyLog;
    final hasOwnLog = cachedLog != null &&
        (cachedLog.id?.isNotEmpty ?? false) &&
        cachedLog.userId == _userId;

    if (hasOwnLog) {
      final updated = cachedLog.copyWith(meals: currentMeals);
      try {
        await _service.updateDailyLog(cachedLog.id!, updated);
        return;
      } on FirebaseException catch (e) {
        if (e.code != 'not-found' && e.code != 'permission-denied') rethrow;
        // Stale id (doc was deleted, or cache leaked across users) — fall
        // through and create a fresh log below.
        debugPrint('addMealEntry: stale daily_log id, recreating ($e)');
      }
    }

    final newLog =
        DailyLog(userId: _userId!, date: dateString, meals: currentMeals);
    await _service.createDailyLog(newLog);
  }

  Future<void> removeMealEntry(int index) async {
    if (_dailyLog?.id?.isNotEmpty != true) return;
    final currentMeals = List<MealEntry>.from(_dailyLog!.meals);
    if (index < 0 || index >= currentMeals.length) return;
    currentMeals.removeAt(index);
    final updated = _dailyLog!.copyWith(meals: currentMeals);
    await _service.updateDailyLog(_dailyLog!.id!, updated);
  }

  Future<void> addWater(int ml) async {
    if (_userId == null) return;
    final currentWater = _dailyLog?.waterMl ?? 0;
    final newWater = currentWater + ml;

    if (_dailyLog?.id != null) {
      final updated = _dailyLog!.copyWith(waterMl: newWater);
      await _service.updateDailyLog(_dailyLog!.id!, updated);
    } else {
      final newLog = DailyLog(
          userId: _userId!, date: dateString, meals: [], waterMl: newWater);
      await _service.createDailyLog(newLog);
    }
  }

  Future<void> removeWater(int ml) async {
    if (_userId == null || _dailyLog?.id?.isNotEmpty != true) return;
    final currentWater = _dailyLog?.waterMl ?? 0;
    final newWater = (currentWater - ml).clamp(0, double.maxFinite).toInt();
    final updated = _dailyLog!.copyWith(waterMl: newWater);
    await _service.updateDailyLog(_dailyLog!.id!, updated);
  }

  Future<void> saveNutritionGoal(NutritionGoal goal) async {
    await _service.setNutritionGoal(goal);
  }

  List<MealEntry> mealsOfType(MealType type) =>
      _dailyLog?.mealsOfType(type) ?? [];

  double get totalCalories => _dailyLog?.totalCalories ?? 0;
  double get totalProtein => _dailyLog?.totalProtein ?? 0;
  double get totalCarbs => _dailyLog?.totalCarbs ?? 0;
  double get totalFat => _dailyLog?.totalFat ?? 0;

  double calorieProgress() {
    final target = _nutritionGoal?.calorieTarget ?? 2000;
    return (totalCalories / target).clamp(0, 1.5);
  }

  double proteinProgress() {
    final target = _nutritionGoal?.proteinTarget ?? 50;
    return (totalProtein / target).clamp(0, 1.5);
  }

  double carbsProgress() {
    final target = _nutritionGoal?.carbsTarget ?? 250;
    return (totalCarbs / target).clamp(0, 1.5);
  }

  double fatProgress() {
    final target = _nutritionGoal?.fatTarget ?? 65;
    return (totalFat / target).clamp(0, 1.5);
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _goalSubscription?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
