---
phase: 3
plan: 2
wave: 1
---

# Plan 3.2: Weight Tracking & Medication Management

## Objective
Build the weight history tracking system with a line chart, and the medication management system (active medications with scheduling). These extend the journal system from Plan 3.1 — weight entries also write to the dedicated `weightHistory` subcollection, and medication entries reference the `medications` subcollection.

## Context
- .gsd/ARCHITECTURE.md (lines 281-312 for weightHistory and medications schemas)
- mobile/lib/features/journal/models/journal_entry_model.dart (from Plan 3.1)
- mobile/lib/features/journal/services/journal_service.dart (from Plan 3.1)
- mobile/lib/features/pets/services/pet_service.dart (CRUD pattern)
- mobile/pubspec.yaml (fl_chart already included)

## Tasks

<task type="auto">
  <name>Weight tracking model, service, and chart screen</name>
  <files>
    mobile/lib/features/health/models/weight_entry_model.dart
    mobile/lib/features/health/services/weight_service.dart
    mobile/lib/features/health/providers/health_providers.dart
    mobile/lib/features/health/screens/weight_chart_screen.dart
  </files>
  <action>
    1. **WeightEntry model** matching `/pets/{petId}/weightHistory/{entryId}`:
       - Fields: weightKg (double), unit (String: "kg" or "lbs"), date (DateTime), createdBy (String), createdAt (DateTime), id (String?)
       - fromMap/toMap/copyWith pattern matching Pet model
       - Helper: `displayWeight` getter that formats based on unit

    2. **WeightService** — Firestore CRUD for `/pets/{petId}/weightHistory`:
       - `addWeight(String petId, WeightEntry entry)` → adds doc, ALSO updates `pets/{petId}.currentWeight`
       - `streamWeightHistory(String petId, {int limit = 100})` → stream ordered by date ASC (for charting)
       - `deleteWeight(String petId, String entryId)` → delete + recalculate currentWeight from latest entry
       - On addWeight, also create a journal entry of type `weight` via JournalService (cross-reference)

    3. **Health providers**:
       - `weightServiceProvider` → Provider
       - `weightHistoryProvider(String petId)` → StreamProvider.family

    4. **WeightChartScreen** — fl_chart line chart:
       - Takes `petId` as required parameter
       - LineChart showing weight over time (x-axis = date, y-axis = weight in kg)
       - Use `fl_chart` package (already in pubspec)
       - Show latest weight prominently at top
       - Time range selector (1 month, 3 months, 6 months, 1 year, all)
       - List of weight entries below chart with date and value
       - FAB or button to add new weight entry (opens a bottom sheet with weight input + date picker)
       - Use AppColors for chart line color, gradient fill under line
  </action>
  <verify>flutter analyze mobile/lib/features/health/ && flutter build web --no-pub</verify>
  <done>Weight chart renders with fl_chart, weight history streams correctly, adding weight updates both weightHistory and pet.currentWeight. Build succeeds.</done>
</task>

<task type="auto">
  <name>Medication model, service, and list screen</name>
  <files>
    mobile/lib/features/health/models/medication_model.dart
    mobile/lib/features/health/services/medication_service.dart
    mobile/lib/features/health/screens/medications_screen.dart
    mobile/lib/features/health/screens/add_medication_screen.dart
  </files>
  <action>
    1. **Medication model** matching `/pets/{petId}/medications/{medicationId}`:
       - Fields: name, dosage, frequency (enum: daily, twice_daily, weekly, as_needed), scheduledTimes (List<String>), startDate, endDate, isActive, createdBy, createdAt, updatedAt, id
       - Enum `MedicationFrequency` with displayName
       - fromMap/toMap/copyWith pattern

    2. **MedicationService** — Firestore CRUD for `/pets/{petId}/medications`:
       - `createMedication(String petId, Medication med)` → add doc
       - `streamActiveMedications(String petId)` → query where isActive == true, ordered by name
       - `streamAllMedications(String petId)` → all medications ordered by name
       - `updateMedication(String petId, String medId, Map<String, dynamic> data)` → partial update
       - `deactivateMedication(String petId, String medId)` → set isActive = false, endDate = now
       - Add `medicationServiceProvider` and `activeMedicationsProvider(String petId)` to health_providers.dart

    3. **MedicationsScreen** — List of medications:
       - Takes `petId` as required parameter
       - Tab bar: Active | Inactive/History
       - Each medication as a card showing: name, dosage, frequency, scheduled times
       - Swipe to deactivate (with confirmation dialog)
       - FAB to add new medication

    4. **AddMedicationScreen** — Creation form:
       - Fields: medication name (required), dosage, frequency selector, scheduled times (time pickers), start date, end date (optional)
       - Save creates medication doc
       - Pop back on success
  </action>
  <verify>flutter analyze mobile/lib/features/health/ && flutter build web --no-pub</verify>
  <done>Medication list screen shows active/inactive tabs, add medication form works, service correctly manages isActive state. Build succeeds.</done>
</task>

## Success Criteria
- [ ] Weight history streams sorted by date, chart renders with fl_chart
- [ ] Adding weight updates both weightHistory subcollection and pet.currentWeight
- [ ] Medication CRUD works with active/inactive state management
- [ ] `flutter build web` succeeds with 0 errors
