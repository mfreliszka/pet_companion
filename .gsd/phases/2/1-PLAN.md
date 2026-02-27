---
phase: 2
plan: 1
wave: 1
---

# Plan 2.1: Pet Model, Service & CRUD Screens

## Objective
Implement the Pet data model, Firestore CRUD service, Riverpod providers, and the core pet screens (list, add, detail/edit). Replace the `/pets` placeholder route with real screens.

## Context
- .gsd/SPEC.md
- .gsd/ARCHITECTURE.md (pets collection schema)
- mobile/lib/features/auth/services/auth_service.dart (service pattern)
- mobile/lib/features/auth/providers/auth_providers.dart (provider pattern)
- mobile/lib/services/firebase_service.dart (Firestore helpers)
- mobile/lib/core/routing/app_router.dart (router to update)

## Tasks

<task type="auto">
  <name>Create Pet model</name>
  <files>mobile/lib/features/pets/models/pet_model.dart</files>
  <action>
    Create a `Pet` class matching the ARCHITECTURE.md `/pets/{petId}` schema exactly:
    - Fields: name, species, breed, gender, dateOfBirth, photoUrl, photoThumbnailUrl, microchipId, microchipRegistry, microchipContactInfo, currentWeight, familyId, createdBy, createdAt, updatedAt
    - `fromMap(Map<String, dynamic>)` factory constructor
    - `toMap()` method
    - `copyWith()` method
    - Species enum: dog, cat, bird, rabbit, fish, reptile, other
    - Gender enum: male, female, unknown
    - Do NOT use json_serializable — keep manual map conversion for Firestore Timestamps
  </action>
  <verify>flutter analyze mobile/lib/features/pets/models/pet_model.dart</verify>
  <done>Pet model compiles with all ARCHITECTURE.md fields, fromMap, toMap, copyWith</done>
</task>

<task type="auto">
  <name>Create PetService and Riverpod providers</name>
  <files>
    mobile/lib/features/pets/services/pet_service.dart
    mobile/lib/features/pets/providers/pet_providers.dart
  </files>
  <action>
    PetService — follows AuthService pattern:
    - Constructor takes optional FirebaseFirestore for DI
    - `createPet(Pet pet) → Future<String>` — add to /pets, returns docId
    - `updatePet(String petId, Map<String, dynamic> data) → Future<void>`
    - `deletePet(String petId) → Future<void>`
    - `streamPetsForFamily(String familyId) → Stream<List<Pet>>`
    - `getPet(String petId) → Future<Pet?>`
    - On create: also update the family doc's `petIds` array (arrayUnion)
    - On delete: also update the family doc's `petIds` array (arrayRemove)

    Providers (in pet_providers.dart):
    - `petServiceProvider` — Provider<PetService>
    - `familyPetsProvider(String familyId)` — StreamProvider<List<Pet>> using streamPetsForFamily
    - `petDetailProvider(String petId)` — FutureProvider<Pet?> using getPet
    - `userPetsProvider` — derives pets from current user's familyIds (watches userDocProvider)
  </action>
  <verify>flutter analyze mobile/lib/features/pets/</verify>
  <done>PetService CRUD works, providers compile, streamPetsForFamily queries by familyId</done>
</task>

<task type="auto">
  <name>Create Pet screens and wire routes</name>
  <files>
    mobile/lib/features/pets/screens/pets_list_screen.dart
    mobile/lib/features/pets/screens/add_pet_screen.dart
    mobile/lib/features/pets/screens/pet_detail_screen.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    PetsListScreen:
    - Uses design system components (AppCard, AppButton, etc.)
    - Lists all pets for the user's families (from userPetsProvider)
    - Each pet shown as a card with avatar (or placeholder icon by species), name, breed, species
    - FAB to navigate to AddPetScreen
    - Tap card → navigate to PetDetailScreen

    AddPetScreen:
    - Form with: name (required), species dropdown, breed (optional), gender dropdown, dateOfBirth picker, microchip fields
    - Photo selection placeholder (tap avatar area → shows snackbar "Photo upload coming in Plan 2.2")
    - Requires familyId — if user has no family, show prompt to create one first
    - Save button calls petService.createPet()
    - On success: navigate back to PetsListScreen

    PetDetailScreen:
    - Reads petDetailProvider(petId)
    - Displays all pet info in a scrollable layout
    - Edit button → inline edit mode or navigate to edit form
    - Delete button with confirmation dialog

    Router updates:
    - Replace `/pets` PlaceholderScreen with PetsListScreen
    - Add `/pets/add` → AddPetScreen
    - Add `/pets/:petId` → PetDetailScreen
  </action>
  <verify>flutter build web --no-tree-shake-icons</verify>
  <done>Pet list shows user's pets, add pet form creates Firestore doc, detail screen shows info, routes work</done>
</task>

## Success Criteria
- [ ] Pet model matches ARCHITECTURE.md schema exactly
- [ ] CRUD operations (create, read, update, delete) work against Firestore
- [ ] `/pets` route shows list of pets for current user's families
- [ ] `/pets/add` creates a new pet in Firestore
- [ ] `/pets/:petId` shows pet details with edit/delete capability
- [ ] App compiles for web and Android without errors
