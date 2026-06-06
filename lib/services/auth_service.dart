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

    // `authenticate()` is unsupported on some platforms (e.g. web, where the
    // documented flow is renderButton). Fail with a typed, friendly error
    // rather than letting a raw UnsupportedError reach the user.
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw FirebaseAuthException(
        code: 'google-signin-unsupported',
        message: 'Google sign-in is not available on this platform.',
      );
    }

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    // In google_sign_in v7 the ID token is nullable and is the only token
    // available at sign-in. A null here means a misconfigured client id; keep
    // it on the typed error path instead of tripping the
    // GoogleAuthProvider.credential assert (debug) / opaque failure (release).
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-google-id-token',
        message: 'Google did not return an ID token. '
            'Check the serverClientId / Web client ID configuration.',
      );
    }
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
