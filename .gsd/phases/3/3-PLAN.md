---
phase: 3
plan: 3
wave: 2
---

# Plan 3.3: Vaccinations, Medical Records & Health Hub

## Objective
Complete the health tracking feature set with vaccination records (with next-due tracking), medical records storage (with document upload), and a unified Health Hub screen that ties together weight, medications, vaccinations, and medical records. Update routing to replace the `/health` placeholder.

## Context
- .gsd/ARCHITECTURE.md (lines 326-366 for vaccinations and medicalRecords schemas)
- mobile/lib/features/health/ (from Plan 3.2 — weight and medications already in place)
- mobile/lib/services/storage_service.dart (R2 upload for document attachments)
- mobile/lib/core/routing/app_router.dart (replace /health and /journal placeholders)

## Tasks

<task type="auto">
  <name>Vaccination and Medical Records models, services, and screens</name>
  <files>
    mobile/lib/features/health/models/vaccination_model.dart
    mobile/lib/features/health/models/medical_record_model.dart
    mobile/lib/features/health/services/vaccination_service.dart
    mobile/lib/features/health/services/medical_record_service.dart
    mobile/lib/features/health/screens/vaccinations_screen.dart
    mobile/lib/features/health/screens/add_vaccination_screen.dart
    mobile/lib/features/health/screens/medical_records_screen.dart
    mobile/lib/features/health/screens/add_medical_record_screen.dart
    mobile/lib/features/health/providers/health_providers.dart (update)
  </files>
  <action>
    1. **Vaccination model** matching `/pets/{petId}/vaccinations/{vaccinationId}`:
       - Fields: name, dateAdministered, nextDueDate, veterinarian, clinic, batchNumber, documentUrl, reminderSent, createdBy, createdAt, id
       - fromMap/toMap/copyWith pattern

    2. **VaccinationService** — CRUD for `/pets/{petId}/vaccinations`:
       - `createVaccination(String petId, Vaccination vac)` → add doc
       - `streamVaccinations(String petId)` → ordered by dateAdministered DESC
       - `streamUpcomingVaccinations(String petId)` → where nextDueDate != null, ordered by nextDueDate ASC
       - `updateVaccination(String petId, String vacId, Map<String, dynamic> data)`
       - `deleteVaccination(String petId, String vacId)`

    3. **MedicalRecord model** matching `/pets/{petId}/medicalRecords/{recordId}`:
       - Fields: title, type (enum: vet_visit, test_result, prescription, imaging, other), date, veterinarian, clinic, diagnosis, treatment, cost, nextFollowUp, documentUrls (List<String>), tags (List<String>), notes, createdBy, createdAt, id
       - Enum `MedicalRecordType` with displayName and icon

    4. **MedicalRecordService** — CRUD for `/pets/{petId}/medicalRecords`:
       - `createRecord(String petId, MedicalRecord record)` → add doc
       - `streamRecords(String petId, {MedicalRecordType? typeFilter})` → ordered by date DESC
       - `updateRecord(String petId, String recordId, Map<String, dynamic> data)`
       - `deleteRecord(String petId, String recordId)`

    5. **Providers**: Add to health_providers.dart:
       - `vaccinationServiceProvider`, `vaccinationsProvider(String petId)`, `upcomingVaccinationsProvider(String petId)`
       - `medicalRecordServiceProvider`, `medicalRecordsProvider(String petId)`

    6. **VaccinationsScreen**: List of vaccinations showing name, date, next due date (highlighted if overdue). FAB to add. Each card expandable to show vet, clinic, batch number.

    7. **AddVaccinationScreen**: Form with: name (required), date administered (date picker), next due date, veterinarian, clinic, batch number. Optional document upload via StorageService (pet photo upload pattern).

    8. **MedicalRecordsScreen**: List of records with type icon, title, date. Filter by type chips. FAB to add.

    9. **AddMedicalRecordScreen**: Form with: title (required), type selector, date, vet, clinic, diagnosis, treatment, cost, next follow-up, tags (chip input), document upload (multiple files via StorageService).
  </action>
  <verify>flutter analyze mobile/lib/features/health/ && flutter build web --no-pub</verify>
  <done>Vaccination and medical record CRUD works. Screens render lists with add forms. Document upload uses StorageService. Build succeeds.</done>
</task>

<task type="auto">
  <name>Health Hub screen and router integration</name>
  <files>
    mobile/lib/features/health/screens/health_hub_screen.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    1. **HealthHubScreen** — Unified health dashboard per pet:
       - Takes `petId` as required parameter
       - Sections displayed as cards/tiles:
         - **Weight**: Latest weight + mini sparkline chart + "View History" link → navigates to WeightChartScreen
         - **Medications**: Count of active medications + "View All" link → MedicationsScreen
         - **Vaccinations**: Next upcoming vaccination with due date (highlighted if overdue) + "View All" link → VaccinationsScreen
         - **Medical Records**: Recent record count + "View All" link → MedicalRecordsScreen
       - Use design system cards (InfoCard, ListTileCard) for consistent look

    2. **Router integration**:
       - Replace `/health` PlaceholderScreen:
         - `/health` → pet picker (if no pet selected) or redirect to `/pets/:petId/health`
         - `/pets/:petId/health` → HealthHubScreen
         - `/pets/:petId/health/weight` → WeightChartScreen
         - `/pets/:petId/health/medications` → MedicationsScreen
         - `/pets/:petId/health/medications/add` → AddMedicationScreen
         - `/pets/:petId/health/vaccinations` → VaccinationsScreen
         - `/pets/:petId/health/vaccinations/add` → AddVaccinationScreen
         - `/pets/:petId/health/records` → MedicalRecordsScreen
         - `/pets/:petId/health/records/add` → AddMedicalRecordScreen
       - Verify `/journal` routes from Plan 3.1 are also properly sub-routed under pets
       - Update AppDrawer title mapping for new routes
  </action>
  <verify>flutter build web --no-pub</verify>
  <done>Health Hub screen shows summary cards for weight, medications, vaccinations, medical records. All sub-routes navigate correctly. Full web build succeeds with 0 errors.</done>
</task>

## Success Criteria
- [ ] Vaccination CRUD with next-due-date tracking works
- [ ] Medical records CRUD with document upload integration works
- [ ] Health Hub screen provides a unified dashboard per pet
- [ ] All routes properly integrated under `/pets/:petId/health/*`
- [ ] `flutter build web` succeeds with 0 errors
