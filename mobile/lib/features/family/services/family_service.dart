import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:uuid/uuid.dart';

import '../models/family_model.dart';
import '../models/invitation_model.dart';

/// Firestore CRUD service for families and invitations.
class FamilyService {
  FamilyService({FirebaseFirestore? firestore, FirebaseFunctions? functions})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _familiesRef =>
      _firestore.collection('families');

  // ── Create ────────────────────────────────────────────────────

  /// Create a family via Cloud Function (handles password hashing server-side).
  ///
  /// Returns the new family ID.
  Future<String> createFamily({
    required String name,
    required String userId,
    String? password,
  }) async {
    if (password != null && password.isNotEmpty) {
      // Use Cloud Function for server-side password hashing
      final callable = _functions.httpsCallable('create_family');
      final result = await callable.call({'name': name, 'password': password});
      final data = Map<String, dynamic>.from(result.data as Map);
      return data['familyId'] as String;
    }

    // No password — create directly
    final familyCode = const Uuid().v4().substring(0, 8).toUpperCase();
    final docRef = await _familiesRef.add({
      'name': name,
      'familyCode': familyCode,
      'adminIds': [userId],
      'memberIds': [userId],
      'petIds': <String>[],
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update user's familyIds
    await _firestore.collection('users').doc(userId).update({
      'familyIds': FieldValue.arrayUnion([docRef.id]),
    });

    return docRef.id;
  }

  // ── Read ──────────────────────────────────────────────────────

  /// Stream a single family.
  Stream<Family?> streamFamily(String familyId) {
    return _familiesRef.doc(familyId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Family.fromMap(snap.data()!, id: snap.id);
    });
  }

  /// Stream multiple families by ID list.
  Stream<List<Family>> streamUserFamilies(List<String> familyIds) {
    if (familyIds.isEmpty) return Stream.value([]);

    return _familiesRef
        .where(FieldPath.documentId, whereIn: familyIds)
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => Family.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  /// Stream invitations for a family.
  Stream<List<Invitation>> streamInvitations(String familyId) {
    return _familiesRef
        .doc(familyId)
        .collection('invitations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => Invitation.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // ── Update ────────────────────────────────────────────────────

  /// Update family fields.
  Future<void> updateFamily(String familyId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _familiesRef.doc(familyId).update(data);
  }

  // ── Invitation ────────────────────────────────────────────────

  /// Send an email invitation to join a family.
  Future<void> sendInvitation({
    required String familyId,
    required String email,
    required String invitedBy,
  }) async {
    final expiresAt = DateTime.now().add(const Duration(days: 7));
    final invitation = Invitation(
      invitedEmail: email,
      invitedBy: invitedBy,
      status: InvitationStatus.pending,
      expiresAt: expiresAt,
    );

    await _familiesRef
        .doc(familyId)
        .collection('invitations')
        .add(invitation.toMap());
  }

  /// Join a family by code + password (via Cloud Function).
  Future<void> joinByCode({
    required String code,
    required String password,
  }) async {
    final callable = _functions.httpsCallable('join_family_by_code');
    await callable.call({'code': code, 'password': password});
  }

  // ── Member management ─────────────────────────────────────────

  /// Remove a member (admin only).
  Future<void> removeMember(String familyId, String userId) async {
    await _familiesRef.doc(familyId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'adminIds': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(userId).update({
      'familyIds': FieldValue.arrayRemove([familyId]),
    });
  }

  /// Leave a family (self).
  Future<void> leaveFamily(String familyId, String userId) async {
    await removeMember(familyId, userId);
  }

  // ── Delete ────────────────────────────────────────────────────

  /// Delete a family (admin only).
  Future<void> deleteFamily(String familyId, List<String> memberIds) async {
    // Remove familyId from all members
    final batch = _firestore.batch();
    for (final uid in memberIds) {
      batch.update(_firestore.collection('users').doc(uid), {
        'familyIds': FieldValue.arrayRemove([familyId]),
      });
    }
    batch.delete(_familiesRef.doc(familyId));
    await batch.commit();
  }
}
