import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medical_record_model.dart';

/// Firestore CRUD for `/pets/{petId}/medicalRecords`.
class MedicalRecordService {
  MedicalRecordService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _recordsRef(String petId) =>
      _firestore.collection('pets').doc(petId).collection('medicalRecords');

  Future<String> createRecord(String petId, MedicalRecord record) async {
    final docRef = await _recordsRef(petId).add(record.toMap());
    return docRef.id;
  }

  /// Stream records ordered by date DESC, optionally filtered by type.
  Stream<List<MedicalRecord>> streamRecords(
    String petId, {
    MedicalRecordType? typeFilter,
  }) {
    Query<Map<String, dynamic>> query = _recordsRef(petId);

    if (typeFilter != null) {
      query = query.where('type', isEqualTo: typeFilter.firestoreValue);
    }

    query = query.orderBy('date', descending: true);

    return query.snapshots().map(
      (snap) => snap.docs
          .map((doc) => MedicalRecord.fromMap(doc.data(), id: doc.id))
          .toList(),
    );
  }

  Future<void> updateRecord(
    String petId,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    await _recordsRef(petId).doc(recordId).update(data);
  }

  Future<void> deleteRecord(String petId, String recordId) async {
    await _recordsRef(petId).doc(recordId).delete();
  }
}
