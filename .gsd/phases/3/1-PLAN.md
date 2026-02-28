---
phase: 3
plan: 1
wave: 1
---

# Plan 3.1: Journal Entry Model, Service & Timeline Screen

## Objective
Build the core journal system: the `JournalEntry` model matching `/pets/{petId}/journalEntries` in ARCHITECTURE.md, a `JournalService` for Firestore CRUD, Riverpod providers, and the journal timeline screen with entry creation forms. This is the single most important deliverable of Phase 3 — the unified pet timeline.

## Context
- .gsd/SPEC.md
- .gsd/ARCHITECTURE.md (lines 246-277 for journalEntries schema, lines 263-277 for `data` field structure)
- mobile/lib/features/pets/models/pet_model.dart (pattern: enum + model with fromMap/toMap/copyWith)
- mobile/lib/features/pets/services/pet_service.dart (pattern: Firestore CRUD service)
- mobile/lib/features/pets/providers/pet_providers.dart (pattern: Riverpod providers)
- mobile/lib/core/routing/app_router.dart (router — replace /journal placeholder)

## Tasks

<task type="auto">
  <name>Journal entry model and enums</name>
  <files>
    mobile/lib/features/journal/models/journal_entry_model.dart
  </files>
  <action>
    Create `JournalEntry` model matching ARCHITECTURE.md `/pets/{petId}/journalEntries/{entryId}`:
    - Enum `JournalEntryType` with values: mood, symptom, appetite, energy, weight, behavior, note, medication, care_record, walk, grooming. Each has a `displayName` and an `icon` (IconData getter).
    - Enum helpers for type-specific data: `MoodLevel` (happy, sad, anxious, energetic, calm), `SymptomSeverity` (mild, moderate, severe), `AppetiteLevel` (ate_well, ate_some, didnt_eat), `EnergyLevel` (low, normal, high), `BehaviorIncident` (barking, jumping, accidents, aggression, anxiety, other), `GroomingType` (bath, nails, brushing, haircut, other).
    - Class `JournalEntry` with all fields from ARCHITECTURE.md: type, timestamp, createdBy, createdByName, notes, photoUrls, data (Map<String, dynamic>), createdAt, updatedAt, plus optional `id` and `petId`.
    - `fromMap(Map<String, dynamic>, {String? id})` factory constructor.
    - `toMap()` method — use FieldValue.serverTimestamp() for createdAt/updatedAt.
    - `copyWith()` method.
    - Static helper `_timestampToDateTime()` matching Pet model pattern.
    - Follow exact same class structure as pet_model.dart.
    - Do NOT use freezed or json_serializable — manual fromMap/toMap like existing models.
  </action>
  <verify>flutter analyze mobile/lib/features/journal/models/</verify>
  <done>JournalEntry model compiles with 0 errors. All 11 entry types represented. Data map structure matches ARCHITECTURE.md schema.</done>
</task>

<task type="auto">
  <name>Journal service, providers, and timeline screen</name>
  <files>
    mobile/lib/features/journal/services/journal_service.dart
    mobile/lib/features/journal/providers/journal_providers.dart
    mobile/lib/features/journal/screens/journal_timeline_screen.dart
    mobile/lib/features/journal/screens/add_journal_entry_screen.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    1. **JournalService** — Firestore CRUD for `/pets/{petId}/journalEntries`:
       - `createEntry(String petId, JournalEntry entry)` → adds doc, returns ID
       - `streamEntries(String petId, {JournalEntryType? typeFilter, int limit = 50})` → stream ordered by timestamp DESC, with optional type filter
       - `getEntry(String petId, String entryId)` → single doc fetch
       - `updateEntry(String petId, String entryId, Map<String, dynamic> data)` → partial update with updatedAt
       - `deleteEntry(String petId, String entryId)` → delete doc
       - Follow PetService pattern exactly (constructor with optional FirebaseFirestore).

    2. **Riverpod Providers** — Follow pet_providers.dart pattern:
       - `journalServiceProvider` → Provider that creates JournalService
       - `journalEntriesProvider(String petId)` → StreamProvider.family using streamEntries
       - `filteredJournalEntriesProvider((String petId, JournalEntryType? filter))` → StreamProvider.family with type filter

    3. **JournalTimelineScreen** — The main journal view:
       - Takes `petId` as required parameter
       - Filter chips at top for entry types (horizontal scrollable row)
       - ListView.builder showing entries in reverse chronological order
       - Each entry as a Card using design system components (ListTileCard or custom)
       - Entry card shows: type icon + color, timestamp (formatted with intl), createdByName, notes preview, thumbnail if photoUrls
       - Empty state with illustration/icon when no entries
       - FAB to navigate to add entry screen

    4. **AddJournalEntryScreen** — Entry creation form:
       - Takes `petId` as required parameter
       - Step 1: Select entry type (grid of type chips/cards with icons)
       - Step 2: Type-specific form fields based on selection:
         - mood: mood selector (5 emoji-style options) + scale slider 1-5
         - symptom: multi-select chips for symptoms + severity selector
         - appetite: 3-option selector + optional food type + amount fields
         - energy: 3-option selector
         - weight: number input (kg) with unit toggle
         - behavior: incident selector + context text field
         - note: just the notes field (large text area)
         - medication: medication name + dosage + administered checkbox
         - care_record: vet, clinic, diagnosis, treatment, cost, next due date fields
         - walk: duration (minutes) + distance (km) number inputs
         - grooming: grooming type selector
       - Common fields: notes (text area), timestamp (defaults to now, editable)
       - Save button calls JournalService.createEntry
       - On success, pop back to timeline

    5. **Router update**: Replace `/journal` PlaceholderScreen with JournalTimelineScreen. Since journal is per-pet, update route to `/pets/:petId/journal` as a sub-route of pets, AND keep `/journal` as a "select pet first" screen that redirects to the first pet's journal or shows a pet picker. Add `/pets/:petId/journal/add` route for AddJournalEntryScreen.
  </action>
  <verify>flutter analyze mobile/lib/features/journal/ && flutter build web --no-pub</verify>
  <done>Journal timeline screen renders with filter chips, entry cards, and FAB. Add entry screen has type selection and type-specific forms. Routes work. Build succeeds with 0 errors.</done>
</task>

## Success Criteria
- [ ] JournalEntry model covers all 11 types with proper data field structure
- [ ] JournalService provides CRUD + filtered streaming for journalEntries subcollection
- [ ] Timeline screen shows entries in reverse chronological order with type filtering
- [ ] Add entry screen has type-specific forms for all 11 entry types
- [ ] `flutter build web` succeeds with 0 errors
