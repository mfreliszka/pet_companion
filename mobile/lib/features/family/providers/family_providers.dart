import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/family_model.dart';
import '../models/invitation_model.dart';
import '../services/family_service.dart';

// ── Service Provider ────────────────────────────────────────────

/// Singleton [FamilyService] instance.
final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService();
});

// ── Family Stream Providers ─────────────────────────────────────

/// Streams all families the current user belongs to.
final userFamiliesProvider = StreamProvider<List<Family>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return ref.watch(familyServiceProvider).streamUserFamilies(user.uid);
});

/// Streams a single family by ID.
final familyDetailProvider = StreamProvider.family<Family?, String>((
  ref,
  familyId,
) {
  return ref.watch(familyServiceProvider).streamFamily(familyId);
});

/// Streams invitations for a family.
final familyInvitationsProvider =
    StreamProvider.family<List<Invitation>, String>((ref, familyId) {
      return ref.watch(familyServiceProvider).streamInvitations(familyId);
    });

/// Whether the current user is admin of a given family.
final isAdminProvider = Provider.family<bool, String>((ref, familyId) {
  final family = ref.watch(familyDetailProvider(familyId)).value;
  final user = ref.watch(currentUserProvider);
  if (family == null || user == null) return false;
  return family.isAdmin(user.uid);
});

/// Streams pending invitations for the current user's email.
final pendingInvitationsProvider = StreamProvider<List<Invitation>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.email == null) return Stream.value([]);

  return ref.watch(familyServiceProvider).streamPendingInvitations(user.email!);
});

// ── Member Profile Provider ─────────────────────────────────────

/// Fetches a member's basic profile (displayName, email, photoUrl) by UID.
final memberProfileProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snap) => snap.data());
    });
