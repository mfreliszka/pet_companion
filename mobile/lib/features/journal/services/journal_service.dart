import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/journal_entry_model.dart';

/// Firestore CRUD service for journal entries.
///
/// Manages `/pets/{petId}/journalEntries` subcollection.
class JournalService {
  JournalService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _entriesRef(String petId) =>
      _firestore.collection('pets').doc(petId).collection('journalEntries');

  // ── Create ────────────────────────────────────────────────────

  /// Creates a journal entry and returns the new document ID.
  Future<String> createEntry(String petId, JournalEntry entry) async {
    final docRef = await _entriesRef(petId).add(entry.toMap());
    return docRef.id;
  }

  // ── Read ──────────────────────────────────────────────────────

  /// Stream journal entries, optionally filtered by type.
  Stream<List<JournalEntry>> streamEntries(
    String petId, {
    JournalEntryType? typeFilter,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _entriesRef(petId);

    if (typeFilter != null) {
      query = query.where('type', isEqualTo: typeFilter.firestoreValue);
    }

    query = query.orderBy('timestamp', descending: true).limit(limit);

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.data(), id: doc.id))
          .toList(),
    );
  }

  /// Get a single journal entry by ID.
  Future<JournalEntry?> getEntry(String petId, String entryId) async {
    final snap = await _entriesRef(petId).doc(entryId).get();
    if (!snap.exists || snap.data() == null) return null;
    return JournalEntry.fromMap(snap.data()!, id: snap.id);
  }

  // ── Update ────────────────────────────────────────────────────

  /// Update specific fields on a journal entry.
  Future<void> updateEntry(
    String petId,
    String entryId,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _entriesRef(petId).doc(entryId).update(data);
  }

  // ── Delete ────────────────────────────────────────────────────

  /// Delete a journal entry.
  Future<void> deleteEntry(String petId, String entryId) async {
    await _entriesRef(petId).doc(entryId).delete();
  }
}
