import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vaccination_model.dart';

/// Firestore CRUD for `/pets/{petId}/vaccinations`.
class VaccinationService {
  VaccinationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _vacsRef(String petId) =>
      _firestore.collection('pets').doc(petId).collection('vaccinations');

  Future<String> createVaccination(String petId, Vaccination vac) async {
    final docRef = await _vacsRef(petId).add(vac.toMap());
    return docRef.id;
  }

  /// Stream all vaccinations ordered by dateAdministered DESC.
  Stream<List<Vaccination>> streamVaccinations(String petId) {
    return _vacsRef(petId)
        .orderBy('dateAdministered', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Vaccination.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  /// Stream upcoming vaccinations (nextDueDate != null) ordered ASC.
  Stream<List<Vaccination>> streamUpcomingVaccinations(String petId) {
    return _vacsRef(petId)
        .where('nextDueDate', isNull: false)
        .orderBy('nextDueDate')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Vaccination.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> updateVaccination(
    String petId,
    String vacId,
    Map<String, dynamic> data,
  ) async {
    await _vacsRef(petId).doc(vacId).update(data);
  }

  Future<void> deleteVaccination(String petId, String vacId) async {
    await _vacsRef(petId).doc(vacId).delete();
  }
}
