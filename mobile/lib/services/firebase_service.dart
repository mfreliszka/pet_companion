import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin wrapper around [FirebaseFirestore] for common operations.
///
/// Provides typed helpers so feature services don't repeat
/// boilerplate (e.g. `.withConverter`, error handling).
class FirebaseService {
  FirebaseService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Root Firestore instance (for advanced queries).
  FirebaseFirestore get firestore => _firestore;

  // ── Document helpers ──────────────────────────────────────────

  /// Get a single document as a [Map].
  /// Returns `null` if the document does not exist.
  Future<Map<String, dynamic>?> getDoc(String path) async {
    final snap = await _firestore.doc(path).get();
    return snap.data();
  }

  /// Set (create or overwrite) a document.
  Future<void> setDoc(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    await _firestore.doc(path).set(data, SetOptions(merge: merge));
  }

  /// Update fields on an existing document.
  Future<void> updateDoc(String path, Map<String, dynamic> data) async {
    await _firestore.doc(path).update(data);
  }

  /// Delete a document.
  Future<void> deleteDoc(String path) async {
    await _firestore.doc(path).delete();
  }

  // ── Stream helpers ────────────────────────────────────────────

  /// Stream a single document as a [Map].
  Stream<Map<String, dynamic>?> streamDoc(String path) {
    return _firestore.doc(path).snapshots().map((snap) => snap.data());
  }

  // ── Collection helpers ────────────────────────────────────────

  /// Return a [CollectionReference] for building queries.
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }
}
