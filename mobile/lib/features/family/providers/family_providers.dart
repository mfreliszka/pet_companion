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
  final userDoc = ref.watch(userDocProvider).value;
  if (userDoc == null) return Stream.value([]);

  final familyIds = List<String>.from(userDoc['familyIds'] ?? []);
  if (familyIds.isEmpty) return Stream.value([]);

  return ref.watch(familyServiceProvider).streamUserFamilies(familyIds);
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
