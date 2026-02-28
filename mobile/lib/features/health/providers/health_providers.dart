import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journal/services/journal_service.dart';
import '../models/weight_entry_model.dart';
import '../services/weight_service.dart';
import '../services/medication_service.dart';
import '../models/medication_model.dart';

// ── Weight providers ────────────────────────────────────────────

/// Singleton [WeightService] provider.
final weightServiceProvider = Provider<WeightService>((ref) {
  return WeightService(
    journalService: ref.watch(Provider((r) => JournalService())),
  );
});

/// Stream weight history for a pet (ordered ASC for charting).
final weightHistoryProvider = StreamProvider.family<List<WeightEntry>, String>((
  ref,
  petId,
) {
  final service = ref.watch(weightServiceProvider);
  return service.streamWeightHistory(petId);
});

// ── Medication providers ────────────────────────────────────────

/// Singleton [MedicationService] provider.
final medicationServiceProvider = Provider<MedicationService>((ref) {
  return MedicationService();
});

/// Stream active medications for a pet.
final activeMedicationsProvider =
    StreamProvider.family<List<Medication>, String>((ref, petId) {
      final service = ref.watch(medicationServiceProvider);
      return service.streamActiveMedications(petId);
    });

/// Stream all medications for a pet.
final allMedicationsProvider = StreamProvider.family<List<Medication>, String>((
  ref,
  petId,
) {
  final service = ref.watch(medicationServiceProvider);
  return service.streamAllMedications(petId);
});
