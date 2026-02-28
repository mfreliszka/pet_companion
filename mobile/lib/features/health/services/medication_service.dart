import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medication_model.dart';

/// Firestore CRUD for `/pets/{petId}/medications`.
class MedicationService {
  MedicationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _medsRef(String petId) =>
      _firestore.collection('pets').doc(petId).collection('medications');

  // ── Create ────────────────────────────────────────────────────

  Future<String> createMedication(String petId, Medication med) async {
    final docRef = await _medsRef(petId).add(med.toMap());
    return docRef.id;
  }

  // ── Read ──────────────────────────────────────────────────────

  /// Stream active medications ordered by name.
  Stream<List<Medication>> streamActiveMedications(String petId) {
    return _medsRef(petId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Medication.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  /// Stream all medications ordered by name.
  Stream<List<Medication>> streamAllMedications(String petId) {
    return _medsRef(petId)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Medication.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // ── Update ────────────────────────────────────────────────────

  Future<void> updateMedication(
    String petId,
    String medId,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _medsRef(petId).doc(medId).update(data);
  }

  // ── Deactivate ────────────────────────────────────────────────

  /// Set isActive = false and endDate = now.
  Future<void> deactivateMedication(String petId, String medId) async {
    await _medsRef(petId).doc(medId).update({
      'isActive': false,
      'endDate': Timestamp.fromDate(DateTime.now()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
