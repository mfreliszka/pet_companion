import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pet_model.dart';

/// Firestore CRUD service for pets.
///
/// Follows same pattern as [AuthService]. Manages `/pets` collection
/// and keeps the parent family's `petIds` array in sync.
class PetService {
  PetService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _petsRef =>
      _firestore.collection('pets');

  // ── Create ────────────────────────────────────────────────────

  /// Creates a pet document and adds its ID to the family's `petIds`.
  /// Returns the new document ID.
  Future<String> createPet(Pet pet) async {
    final docRef = await _petsRef.add(pet.toMap());

    // Keep family.petIds in sync.
    await _firestore.collection('families').doc(pet.familyId).update({
      'petIds': FieldValue.arrayUnion([docRef.id]),
    });

    return docRef.id;
  }

  // ── Read ──────────────────────────────────────────────────────

  /// Get a single pet by ID.
  Future<Pet?> getPet(String petId) async {
    final snap = await _petsRef.doc(petId).get();
    if (!snap.exists || snap.data() == null) return null;
    return Pet.fromMap(snap.data()!, id: snap.id);
  }

  /// Stream a single pet.
  Stream<Pet?> streamPet(String petId) {
    return _petsRef.doc(petId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Pet.fromMap(snap.data()!, id: snap.id);
    });
  }

  /// Stream all pets belonging to a family.
  Stream<List<Pet>> streamPetsForFamily(String familyId) {
    return _petsRef
        .where('familyId', isEqualTo: familyId)
        .orderBy('name')
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => Pet.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  /// Stream pets across multiple families (for a user's complete pet list).
  Stream<List<Pet>> streamPetsForFamilies(List<String> familyIds) {
    if (familyIds.isEmpty) return Stream.value([]);

    // Firestore `whereIn` supports max 30 values — sufficient for families.
    return _petsRef
        .where('familyId', whereIn: familyIds)
        .orderBy('name')
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => Pet.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // ── Update ────────────────────────────────────────────────────

  /// Update specific fields on a pet document.
  Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _petsRef.doc(petId).update(data);
  }

  // ── Delete ────────────────────────────────────────────────────

  /// Delete a pet and remove its ID from the family's `petIds`.
  Future<void> deletePet(String petId, String familyId) async {
    await _petsRef.doc(petId).delete();

    await _firestore.collection('families').doc(familyId).update({
      'petIds': FieldValue.arrayRemove([petId]),
    });
  }
}
