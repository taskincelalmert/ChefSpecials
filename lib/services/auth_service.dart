import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/google_auth_config.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    // Best-effort: clear the cached Google account so the picker reappears
    // next time. Never let this block the Firebase sign-out.
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: googleServerClientId);
    _googleInitialized = true;
  }

  /// Triggers the native Google account picker and signs the user into
  /// Firebase with the resulting credential.
  ///
  /// Returns `null` if the user dismisses the picker (treated as a no-op, not
  /// an error). Throws [FirebaseAuthException] for real auth failures.
  Future<UserCredential?> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return await _auth.signInWithCredential(credential);
  }

  /// Signs into the existing email/password account and links [credential]
  /// (the pending Google credential) onto it, so the user ends up with a
  /// single account exposing both sign-in methods.
  Future<UserCredential> linkCredentialWithPassword(
    String email,
    String password,
    AuthCredential credential,
  ) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      await userCredential.user!.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Already linked is fine — they're signed into the correct account.
      if (e.code != 'provider-already-linked' &&
          e.code != 'credential-already-in-use') {
        rethrow;
      }
    }
    return userCredential;
  }
}
