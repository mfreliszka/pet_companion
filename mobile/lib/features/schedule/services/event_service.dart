import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../models/event_completion_model.dart';

/// Service for managing events in top-level `/events` collection.
class EventService {
  EventService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('events');

  // ── CRUD ────────────────────────────────────────────────────

  Future<String> addEvent(Event event) async {
    final doc = await _eventsRef.add(event.toMap());
    return doc.id;
  }

  Future<void> updateEvent(Event event) async {
    await _eventsRef.doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsRef.doc(eventId).delete();
  }

  Future<void> deactivateEvent(String eventId) async {
    await _eventsRef.doc(eventId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Streams ─────────────────────────────────────────────────

  /// Stream all active events for a family.
  Stream<List<Event>> streamFamilyEvents(String familyId) {
    return _eventsRef
        .where('familyId', isEqualTo: familyId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Event.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// Stream all active events for a specific pet.
  Stream<List<Event>> streamPetEvents(String petId) {
    return _eventsRef
        .where('petId', isEqualTo: petId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Event.fromMap(d.data(), d.id)).toList(),
        );
  }

  // ── Completions ─────────────────────────────────────────────

  /// Mark an event as completed.
  Future<void> completeEvent(String eventId, EventCompletion completion) async {
    await _eventsRef
        .doc(eventId)
        .collection('completions')
        .add(completion.toMap());
  }

  /// Stream completion history for an event.
  Stream<List<EventCompletion>> streamCompletions(String eventId) {
    return _eventsRef
        .doc(eventId)
        .collection('completions')
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => EventCompletion.fromMap(d.data(), d.id))
              .toList(),
        );
  }
}
