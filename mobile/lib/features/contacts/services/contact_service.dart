import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/contact_model.dart';

/// Service for managing pet service contacts in `/contacts` collection.
class ContactService {
  ContactService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _contactsRef =>
      _firestore.collection('contacts');

  // ── CRUD ────────────────────────────────────────────────────

  Future<String> addContact(PetContact contact) async {
    final doc = await _contactsRef.add(contact.toMap());
    return doc.id;
  }

  Future<void> updateContact(PetContact contact) async {
    await _contactsRef.doc(contact.id).update(contact.toMap());
  }

  Future<void> deleteContact(String contactId) async {
    await _contactsRef.doc(contactId).delete();
  }

  // ── Streams ─────────────────────────────────────────────────

  Stream<List<PetContact>> streamFamilyContacts(String familyId) {
    return _contactsRef
        .where('familyId', isEqualTo: familyId)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => PetContact.fromMap(d.data(), d.id)).toList(),
        );
  }
}
