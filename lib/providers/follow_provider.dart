import 'dart:async';
import 'package:flutter/material.dart';
import '../services/follow_service.dart';
import '../services/activity_service.dart';

class FollowProvider extends ChangeNotifier {
  final FollowService _service;
  final ActivityService _activityService;

  FollowProvider({FollowService? followService, ActivityService? activityService})
      : _service = followService ?? FollowService(),
        _activityService = activityService ?? ActivityService();

  Set<String> _followingIds = {};
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserAvatar;
  StreamSubscription<List<String>>? _sub;

  Set<String> get followingIds => _followingIds;
  List<String> get followingList => _followingIds.toList();
  bool isFollowing(String uid) => _followingIds.contains(uid);

  void initialize(String currentUserId, {String? userName, String? userAvatar}) {
    if (_currentUserId == currentUserId) return;
    _currentUserId = currentUserId;
    _currentUserName = userName;
    _currentUserAvatar = userAvatar;
    _sub?.cancel();
    _sub = _service.watchFollowingIds(currentUserId).listen(
      (ids) {
        _followingIds = ids.toSet();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('FollowProvider stream error: $e');
        // Stream is dead; allow the next initialize() to re-subscribe.
        _currentUserId = null;
      },
    );
  }

  Future<void> follow(String targetId) async {
    if (_currentUserId == null) return;
    if (targetId == _currentUserId) return;
    // Optimistic update — create a new set so reference changes
    _followingIds = {..._followingIds, targetId};
    notifyListeners();
    try {
      await _service.follow(_currentUserId!, targetId);
      _activityService.createFollowActivity(
        targetUserId: targetId,
        actorId: _currentUserId!,
        actorName: _currentUserName ?? '',
        actorAvatar: _currentUserAvatar,
      );
    } catch (_) {
      _followingIds = _followingIds.difference({targetId});
      notifyListeners();
    }
  }

  Future<List<String>> getFollowerIds(String userId) {
    return _service.getFollowerIds(userId);
  }

  Future<void> unfollow(String targetId) async {
    if (_currentUserId == null) return;
    // Optimistic update — create a new set so reference changes
    _followingIds = _followingIds.difference({targetId});
    notifyListeners();
    try {
      await _service.unfollow(_currentUserId!, targetId);
    } catch (_) {
      _followingIds = {..._followingIds, targetId};
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
