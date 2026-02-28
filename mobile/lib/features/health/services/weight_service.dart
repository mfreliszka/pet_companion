import 'package:cloud_firestore/cloud_firestore.dart';

import '../../journal/models/journal_entry_model.dart';
import '../../journal/services/journal_service.dart';
import '../models/weight_entry_model.dart';

/// Firestore CRUD for `/pets/{petId}/weightHistory`.
///
/// Also syncs `pets/{petId}.currentWeight` and creates
/// cross-reference journal entries of type `weight`.
class WeightService {
  WeightService({FirebaseFirestore? firestore, JournalService? journalService})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _journalService = journalService ?? JournalService();

  final FirebaseFirestore _firestore;
  final JournalService _journalService;

  CollectionReference<Map<String, dynamic>> _historyRef(String petId) =>
      _firestore.collection('pets').doc(petId).collection('weightHistory');

  // ── Add weight ────────────────────────────────────────────────

  /// Adds a weight entry, updates pet.currentWeight, and creates
  /// a journal entry of type [JournalEntryType.weight].
  Future<String> addWeight(
    String petId,
    WeightEntry entry, {
    String? createdByName,
  }) async {
    // 1. Add to weightHistory subcollection
    final docRef = await _historyRef(petId).add(entry.toMap());

    // 2. Update pet.currentWeight
    await _firestore.collection('pets').doc(petId).update({
      'currentWeight': entry.weightKg,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3. Create cross-reference journal entry
    final journalEntry = JournalEntry(
      type: JournalEntryType.weight,
      timestamp: entry.date,
      createdBy: entry.createdBy,
      createdByName: createdByName ?? 'Unknown',
      data: {'weightKg': entry.weightKg, 'unit': entry.unit},
    );
    await _journalService.createEntry(petId, journalEntry);

    return docRef.id;
  }

  // ── Stream ────────────────────────────────────────────────────

  /// Stream weight history ordered by date ASC (for charting).
  Stream<List<WeightEntry>> streamWeightHistory(
    String petId, {
    int limit = 100,
  }) {
    return _historyRef(petId)
        .orderBy('date', descending: false)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => WeightEntry.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // ── Delete ────────────────────────────────────────────────────

  /// Delete a weight entry. Recalculates pet.currentWeight from
  /// the most recent remaining entry.
  Future<void> deleteWeight(String petId, String entryId) async {
    await _historyRef(petId).doc(entryId).delete();

    // Recalculate currentWeight from latest remaining entry
    final latest = await _historyRef(
      petId,
    ).orderBy('date', descending: true).limit(1).get();

    final newWeight = latest.docs.isNotEmpty
        ? (latest.docs.first.data()['weightKg'] as num?)?.toDouble()
        : null;

    await _firestore.collection('pets').doc(petId).update({
      'currentWeight': newWeight,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
