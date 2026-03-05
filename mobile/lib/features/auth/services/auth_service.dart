import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Wraps Firebase Auth + Google Sign-In (v7 API).
///
/// On first sign-in, creates the user document in
/// `users/{uid}` per ARCHITECTURE.md schema.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Reference to the google_sign_in v7 singleton.
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // ── Public API ────────────────────────────────────────────────

  /// Reactive auth-state stream.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Currently signed-in user (or `null`).
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google and ensure a Firestore user document exists.
  ///
  /// On **web**: uses `FirebaseAuth.signInWithPopup` directly (the
  /// `google_sign_in` plugin does not support programmatic `authenticate()`
  /// on web — it requires `renderButton`, which doesn't fit our UI).
  ///
  /// On **mobile**: uses the google_sign_in v7 `authenticate()` flow.
  Future<UserCredential> signInWithGoogle() async {
    final UserCredential userCredential;

    if (kIsWeb) {
      // Web: use Firebase Auth popup flow directly.
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      userCredential = await _auth.signInWithPopup(provider);
    } else {
      // Mobile: use google_sign_in plugin.
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      userCredential = await _auth.signInWithCredential(credential);
    }

    final user = userCredential.user;
    if (user != null) {
      await _ensureUserDocument(user);
    }

    return userCredential;
  }

  /// Sign out of both Google and Firebase.
  Future<void> signOut() async {
    if (kIsWeb) {
      await _auth.signOut();
    } else {
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
    }
  }

  // ── Private helpers ───────────────────────────────────────────

  /// Create or update the Firestore user document.
  Future<void> _ensureUserDocument(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      // First sign-in — create full document per ARCHITECTURE.md schema.
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL,
        'familyIds': <String>[],
        'fcmTokens': <String>[],
        'isPremium': false,
        'premiumExpiresAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Returning user — bump updatedAt.
      await docRef.update({'updatedAt': FieldValue.serverTimestamp()});
    }
  }
}
