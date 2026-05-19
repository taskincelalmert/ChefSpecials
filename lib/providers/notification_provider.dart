import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationProvider({
    NotificationService? service,
    Stream<User?>? authStream,
  }) : _service = service ?? NotificationService() {
    _authSub = (authStream ?? FirebaseAuth.instance.authStateChanges())
        .listen(_onAuthChanged);
  }

  // Meal reminder notification IDs
  static const _breakfastId = 1001;
  static const _lunchId = 1002;
  static const _dinnerId = 1003;

  // SharedPreferences keys
  static const _keyPushEnabled = 'notif_push_enabled';
  static const _keyBreakfastEnabled = 'notif_breakfast_enabled';
  static const _keyBreakfastHour = 'notif_breakfast_hour';
  static const _keyBreakfastMinute = 'notif_breakfast_minute';
  static const _keyLunchEnabled = 'notif_lunch_enabled';
  static const _keyLunchHour = 'notif_lunch_hour';
  static const _keyLunchMinute = 'notif_lunch_minute';
  static const _keyDinnerEnabled = 'notif_dinner_enabled';
  static const _keyDinnerHour = 'notif_dinner_hour';
  static const _keyDinnerMinute = 'notif_dinner_minute';
  static const _keyNewRecipeAlerts = 'notif_new_recipe_alerts';
  static const _keyCommentAlerts = 'notif_comment_alerts';
  static const _keyFollowerAlerts = 'notif_follower_alerts';

  // State
  bool _pushEnabled = false;
  bool _breakfastEnabled = false;
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 8, minute: 0);
  bool _lunchEnabled = false;
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 0);
  bool _dinnerEnabled = false;
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 0);
  bool _newRecipeAlerts = false;
  bool _commentAlerts = false;
  bool _followerAlerts = false;
  bool _permissionDenied = false;

  String? _currentUserId;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<String>? _tokenRefreshSub;

  // Getters
  bool get pushEnabled => _pushEnabled;
  bool get breakfastEnabled => _breakfastEnabled;
  TimeOfDay get breakfastTime => _breakfastTime;
  bool get lunchEnabled => _lunchEnabled;
  TimeOfDay get lunchTime => _lunchTime;
  bool get dinnerEnabled => _dinnerEnabled;
  TimeOfDay get dinnerTime => _dinnerTime;
  bool get newRecipeAlerts => _newRecipeAlerts;
  bool get commentAlerts => _commentAlerts;
  bool get followerAlerts => _followerAlerts;
  bool get permissionDenied => _permissionDenied;

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
      _currentUserId = null;
      return;
    }
    await _bootstrap(user.uid);
  }

  /// Non-prompting bootstrap that runs on every login.
  /// Loads stored toggle state only. FCM is fully dormant — no OS permission
  /// check, no token fetch, no Firestore write — until the user explicitly
  /// flips the master toggle via [setPushEnabled].
  Future<void> _bootstrap(String userId) async {
    _currentUserId = userId;
    await _loadFromPrefs();

    if (_pushEnabled) {
      await _activatePush(userId, requestIfNeeded: false);
    }

    notifyListeners();
  }

  /// Master toggle: turn push notifications on or off.
  /// Enabling prompts for OS permission, fetches the FCM token, and starts
  /// listening for token rotations. Disabling clears the token from Firestore,
  /// cancels every scheduled reminder, unsubscribes from topics, and resets
  /// all sub-toggles to off.
  Future<void> setPushEnabled(bool enabled) async {
    final userId = _currentUserId;
    if (userId == null) return;

    if (enabled) {
      final granted = await _activatePush(userId, requestIfNeeded: true);
      _pushEnabled = granted;
      await _persistPushEnabled(_pushEnabled);
      notifyListeners();
    } else {
      _pushEnabled = false;
      await _persistPushEnabled(false);

      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
      await _service.clearFcmToken(userId);
      await _service.cancelAllReminders();

      if (_newRecipeAlerts) {
        await _service.unsubscribeFromTopic('new_recipes');
      }

      _breakfastEnabled = false;
      _lunchEnabled = false;
      _dinnerEnabled = false;
      _newRecipeAlerts = false;
      _commentAlerts = false;
      _followerAlerts = false;
      await _saveToPrefs();
      await _mirrorToFirestore({
        'notifyOnComment': false,
        'notifyOnFollow': false,
      });

      notifyListeners();
    }
  }

  /// Initializes FCM for a user that has opted into push.
  /// Returns true if permission is granted and the token was registered.
  Future<bool> _activatePush(
    String userId, {
    required bool requestIfNeeded,
  }) async {
    await _service.initialize();

    final settings = requestIfNeeded
        ? await _service.requestPermission()
        : await _service.currentSettings();
    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!authorized) {
      _permissionDenied = true;
      return false;
    }

    _permissionDenied = false;

    final token = await _service.getFcmToken();
    if (token != null) {
      await _service.saveFcmToken(userId, token);
    }
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _service.tokenRefreshStream.listen((rotated) async {
      final uid = _currentUserId;
      if (uid != null) await _service.saveFcmToken(uid, rotated);
    });

    return true;
  }

  Future<void> recheckPermission(String userId) async {
    if (!_pushEnabled) return;
    _permissionDenied = false;
    notifyListeners();
    final granted = await _activatePush(userId, requestIfNeeded: true);
    if (!granted) {
      _pushEnabled = false;
      await _persistPushEnabled(false);
    }
    notifyListeners();
  }

  Future<void> openSystemSettings() => _service.openSystemSettings();

  Future<NotificationSettings> currentSettings() => _service.currentSettings();

  Future<void> _persistPushEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushEnabled, value);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _pushEnabled = prefs.getBool(_keyPushEnabled) ?? false;
    _breakfastEnabled = prefs.getBool(_keyBreakfastEnabled) ?? false;
    _breakfastTime = TimeOfDay(
      hour: prefs.getInt(_keyBreakfastHour) ?? 8,
      minute: prefs.getInt(_keyBreakfastMinute) ?? 0,
    );
    _lunchEnabled = prefs.getBool(_keyLunchEnabled) ?? false;
    _lunchTime = TimeOfDay(
      hour: prefs.getInt(_keyLunchHour) ?? 12,
      minute: prefs.getInt(_keyLunchMinute) ?? 0,
    );
    _dinnerEnabled = prefs.getBool(_keyDinnerEnabled) ?? false;
    _dinnerTime = TimeOfDay(
      hour: prefs.getInt(_keyDinnerHour) ?? 19,
      minute: prefs.getInt(_keyDinnerMinute) ?? 0,
    );
    _newRecipeAlerts = prefs.getBool(_keyNewRecipeAlerts) ?? false;
    _commentAlerts = prefs.getBool(_keyCommentAlerts) ?? false;
    _followerAlerts = prefs.getBool(_keyFollowerAlerts) ?? false;

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyBreakfastEnabled, _breakfastEnabled);
    await prefs.setInt(_keyBreakfastHour, _breakfastTime.hour);
    await prefs.setInt(_keyBreakfastMinute, _breakfastTime.minute);
    await prefs.setBool(_keyLunchEnabled, _lunchEnabled);
    await prefs.setInt(_keyLunchHour, _lunchTime.hour);
    await prefs.setInt(_keyLunchMinute, _lunchTime.minute);
    await prefs.setBool(_keyDinnerEnabled, _dinnerEnabled);
    await prefs.setInt(_keyDinnerHour, _dinnerTime.hour);
    await prefs.setInt(_keyDinnerMinute, _dinnerTime.minute);
    await prefs.setBool(_keyNewRecipeAlerts, _newRecipeAlerts);
    await prefs.setBool(_keyCommentAlerts, _commentAlerts);
    await prefs.setBool(_keyFollowerAlerts, _followerAlerts);
  }

  Future<void> _mirrorToFirestore(Map<String, dynamic> prefs) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      await _service.savePreferences(uid, prefs);
    } catch (_) {
      // Non-fatal — the local SharedPreferences value is already saved.
    }
  }

  Future<void> toggleBreakfastReminder(bool enabled) async {
    if (enabled && !_pushEnabled) return;
    _breakfastEnabled = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.scheduleMealReminder(
        id: _breakfastId,
        mealType: 'breakfast',
        title: 'Breakfast Reminder',
        body: 'Time for Breakfast!',
        hour: _breakfastTime.hour,
        minute: _breakfastTime.minute,
      );
    } else {
      await _service.cancelMealReminder(_breakfastId);
    }
  }

  Future<void> setBreakfastTime(TimeOfDay time) async {
    _breakfastTime = time;
    notifyListeners();
    await _saveToPrefs();

    if (_breakfastEnabled) {
      await _service.scheduleMealReminder(
        id: _breakfastId,
        mealType: 'breakfast',
        title: 'Breakfast Reminder',
        body: 'Time for Breakfast!',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> toggleLunchReminder(bool enabled) async {
    if (enabled && !_pushEnabled) return;
    _lunchEnabled = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.scheduleMealReminder(
        id: _lunchId,
        mealType: 'lunch',
        title: 'Lunch Reminder',
        body: 'Time for Lunch!',
        hour: _lunchTime.hour,
        minute: _lunchTime.minute,
      );
    } else {
      await _service.cancelMealReminder(_lunchId);
    }
  }

  Future<void> setLunchTime(TimeOfDay time) async {
    _lunchTime = time;
    notifyListeners();
    await _saveToPrefs();

    if (_lunchEnabled) {
      await _service.scheduleMealReminder(
        id: _lunchId,
        mealType: 'lunch',
        title: 'Lunch Reminder',
        body: 'Time for Lunch!',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> toggleDinnerReminder(bool enabled) async {
    if (enabled && !_pushEnabled) return;
    _dinnerEnabled = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.scheduleMealReminder(
        id: _dinnerId,
        mealType: 'dinner',
        title: 'Dinner Reminder',
        body: 'Time for Dinner!',
        hour: _dinnerTime.hour,
        minute: _dinnerTime.minute,
      );
    } else {
      await _service.cancelMealReminder(_dinnerId);
    }
  }

  Future<void> setDinnerTime(TimeOfDay time) async {
    _dinnerTime = time;
    notifyListeners();
    await _saveToPrefs();

    if (_dinnerEnabled) {
      await _service.scheduleMealReminder(
        id: _dinnerId,
        mealType: 'dinner',
        title: 'Dinner Reminder',
        body: 'Time for Dinner!',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> toggleNewRecipeAlerts(bool enabled) async {
    if (enabled && !_pushEnabled) return;
    _newRecipeAlerts = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.subscribeToTopic('new_recipes');
    } else {
      await _service.unsubscribeFromTopic('new_recipes');
    }
  }

  Future<void> toggleCommentAlerts(bool enabled) async {
    if (enabled && !_pushEnabled) return;
    _commentAlerts = enabled;
    notifyListeners();
    await _saveToPrefs();
    await _mirrorToFirestore({'notifyOnComment': enabled});
  }

  Future<void> toggleFollowerAlerts(bool enabled) async {
    if (enabled && !_pushEnabled) return;
    _followerAlerts = enabled;
    notifyListeners();
    await _saveToPrefs();
    await _mirrorToFirestore({'notifyOnFollow': enabled});
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _tokenRefreshSub?.cancel();
    super.dispose();
  }
}
