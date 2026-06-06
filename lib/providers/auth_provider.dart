import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Result of a Google sign-in attempt.
/// [needsPasswordLink] means the email already belongs to a password account
/// and the user must enter that password so we can link Google onto it.
enum GoogleSignInOutcome { success, cancelled, needsPasswordLink, failed }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserModel?>? _userSub;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isBanned => _userModel?.isBanned ?? false;

  AuthProvider({AuthService? authService, UserService? userService})
      : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService() {
    _authSub = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _firebaseUser = user;
    _userSub?.cancel();
    _userSub = null;
    if (user != null) {
      _userSub = _userService.watchUser(user.uid).listen(
        (model) {
          _userModel = model;
          if (model != null && model.username == null) {
            _generateMissingUsername(model);
          } else if (model != null && !_migrationRan) {
            _migrationRan = true;
            _userService.migrateUsersWithoutUsernames();
          }
          notifyListeners();
        },
        onError: (_) async {
          // Fallback to one-time fetch if stream fails
          _userModel = await _userService.getUser(user.uid);
          notifyListeners();
        },
      );
    } else {
      _userModel = null;
      notifyListeners();
    }
  }

  bool _generatingUsername = false;
  bool _migrationRan = false;

  Future<void> _generateMissingUsername(UserModel model) async {
    if (_generatingUsername) return;
    _generatingUsername = true;
    try {
      await _userService.generateAndClaimUsername(
        model.uid,
        model.firstName,
        model.lastName,
      );
      // After own username is set, migrate other users once
      if (!_migrationRan) {
        _migrationRan = true;
        _userService.migrateUsersWithoutUsernames();
      }
    } catch (_) {
      // Silently fail — will retry on next auth state change
    } finally {
      _generatingUsername = false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String phoneNumber, {
    required DateTime birthDate,
    required String username,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? cookingSkillLevel,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.register(email, password);
      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        birthDate: birthDate,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        cookingSkillLevel: cookingSkillLevel,
        username: username,
      );
      await _userService.createUser(user);
      await _userService.claimUsername(username, uid);
      _userModel = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  AuthCredential? _pendingGoogleCredential;
  String? _pendingLinkEmail;
  String? get pendingLinkEmail => _pendingLinkEmail;

  Future<GoogleSignInOutcome> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential?.user == null) {
        // User dismissed the Google account picker — no-op, not an error.
        _isLoading = false;
        notifyListeners();
        return GoogleSignInOutcome.cancelled;
      }

      await _ensureUserProfile(credential!.user!);
      _isLoading = false;
      notifyListeners();
      return GoogleSignInOutcome.success;
    } on FirebaseAuthException catch (e) {
      // Same email already has a password account. Stash the Google
      // credential so we can link it once the user proves ownership.
      if (e.code == 'account-exists-with-different-credential' &&
          e.credential != null &&
          e.email != null) {
        _pendingGoogleCredential = e.credential;
        _pendingLinkEmail = e.email;
        _isLoading = false;
        notifyListeners();
        return GoogleSignInOutcome.needsPasswordLink;
      }
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return GoogleSignInOutcome.failed;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return GoogleSignInOutcome.failed;
    }
  }

  /// Completes a [GoogleSignInOutcome.needsPasswordLink] flow: signs into the
  /// existing password account and links the pending Google credential to it.
  Future<bool> linkPendingGoogleCredential(String password) async {
    final email = _pendingLinkEmail;
    final credential = _pendingGoogleCredential;
    if (email == null || credential == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.linkCredentialWithPassword(
        email,
        password,
        credential,
      );
      await _ensureUserProfile(userCredential.user!);
      cancelPendingLink();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void cancelPendingLink() {
    _pendingGoogleCredential = null;
    _pendingLinkEmail = null;
  }

  /// Ensures a Firestore profile exists for [fbUser]. First-time Google users
  /// get a minimal one; the username is auto-generated by the auth-state
  /// listener once the doc appears (see _onAuthStateChanged).
  Future<void> _ensureUserProfile(User fbUser) async {
    final existing = await _userService.getUser(fbUser.uid);
    if (existing == null) {
      final names = _splitDisplayName(fbUser.displayName);
      await _userService.createUser(UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        firstName: names.$1,
        lastName: names.$2,
        photoUrl: fbUser.photoURL,
        createdAt: DateTime.now(),
      ));
    }
  }

  (String, String) _splitDisplayName(String? displayName) {
    final parts = (displayName ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return ('', '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      _userModel = await _userService.getUser(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> isUsernameAvailable(String username) {
    return _userService.isUsernameAvailable(username);
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _error = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
