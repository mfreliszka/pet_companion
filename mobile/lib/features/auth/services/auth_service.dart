import 'package:firebase_auth/firebase_auth.dart';
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
  /// Uses the google_sign_in v7 API:
  ///   1. `GoogleSignIn.instance.authenticate()` triggers an interactive flow.
  ///   2. The returned account provides an `idToken` for Firebase credential.
  Future<UserCredential> signInWithGoogle() async {
    // 1. Trigger Google Sign-In interactive flow.
    final GoogleSignInAccount account = await _googleSignIn.authenticate();

    // 2. Build Firebase credential from the id token.
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    // 3. Sign in to Firebase.
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      await _ensureUserDocument(user);
    }

    return userCredential;
  }

  /// Sign out of both Google and Firebase.
  Future<void> signOut() async {
    await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
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
