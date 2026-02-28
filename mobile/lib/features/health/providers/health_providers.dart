import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journal/services/journal_service.dart';
import '../models/medical_record_model.dart';
import '../models/medication_model.dart';
import '../models/vaccination_model.dart';
import '../models/weight_entry_model.dart';
import '../services/medication_service.dart';
import '../services/medical_record_service.dart';
import '../services/vaccination_service.dart';
import '../services/weight_service.dart';

// ── Weight providers ────────────────────────────────────────────

final weightServiceProvider = Provider<WeightService>((ref) {
  return WeightService(journalService: JournalService());
});

final weightHistoryProvider = StreamProvider.family<List<WeightEntry>, String>((
  ref,
  petId,
) {
  return ref.watch(weightServiceProvider).streamWeightHistory(petId);
});

// ── Medication providers ────────────────────────────────────────

final medicationServiceProvider = Provider<MedicationService>((ref) {
  return MedicationService();
});

final activeMedicationsProvider =
    StreamProvider.family<List<Medication>, String>((ref, petId) {
      return ref
          .watch(medicationServiceProvider)
          .streamActiveMedications(petId);
    });

final allMedicationsProvider = StreamProvider.family<List<Medication>, String>((
  ref,
  petId,
) {
  return ref.watch(medicationServiceProvider).streamAllMedications(petId);
});

// ── Vaccination providers ───────────────────────────────────────

final vaccinationServiceProvider = Provider<VaccinationService>((ref) {
  return VaccinationService();
});

final vaccinationsProvider = StreamProvider.family<List<Vaccination>, String>((
  ref,
  petId,
) {
  return ref.watch(vaccinationServiceProvider).streamVaccinations(petId);
});

final upcomingVaccinationsProvider =
    StreamProvider.family<List<Vaccination>, String>((ref, petId) {
      return ref
          .watch(vaccinationServiceProvider)
          .streamUpcomingVaccinations(petId);
    });

// ── Medical Record providers ────────────────────────────────────

final medicalRecordServiceProvider = Provider<MedicalRecordService>((ref) {
  return MedicalRecordService();
});

final medicalRecordsProvider =
    StreamProvider.family<List<MedicalRecord>, String>((ref, petId) {
      return ref.watch(medicalRecordServiceProvider).streamRecords(petId);
    });
