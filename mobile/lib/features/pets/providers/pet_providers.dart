import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';

// ── Service Provider ────────────────────────────────────────────

/// Singleton [PetService] instance.
final petServiceProvider = Provider<PetService>((ref) {
  return PetService();
});

// ── Pet Stream Providers ────────────────────────────────────────

/// Streams all pets for a specific family.
final familyPetsProvider = StreamProvider.family<List<Pet>, String>((
  ref,
  familyId,
) {
  return ref.watch(petServiceProvider).streamPetsForFamily(familyId);
});

/// Streams a single pet by ID.
final petDetailProvider = StreamProvider.family<Pet?, String>((ref, petId) {
  return ref.watch(petServiceProvider).streamPet(petId);
});

/// Streams all pets across the current user's families.
///
/// Derives family IDs from the user document, then queries all
/// pets belonging to those families.
final userPetsProvider = StreamProvider<List<Pet>>((ref) {
  final userDoc = ref.watch(userDocProvider).value;
  if (userDoc == null) return Stream.value([]);

  final familyIds = List<String>.from(userDoc['familyIds'] ?? []);
  if (familyIds.isEmpty) return Stream.value([]);

  return ref.watch(petServiceProvider).streamPetsForFamilies(familyIds);
});
