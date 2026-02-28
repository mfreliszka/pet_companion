---
phase: 5
plan: 2
wave: 1
---

# Plan 5.2: Pet Service Contacts — Model, Service & Screens

## Objective
Implement a per-family pet service contact directory: model, Firestore CRUD service, providers, and screens (contacts list, add/edit contact). Stores vet clinics, groomers, pet sitters, emergency contacts.

## Context
- .gsd/SPEC.md — "Pet service contact list"
- mobile/lib/features/contacts/ (empty scaffold)
- mobile/lib/features/expenses/ (parallel Wave 1 pattern)
- mobile/lib/core/routing/app_router.dart

## Tasks

<task type="auto">
  <name>Contact model, service, and providers</name>
  <files>
    mobile/lib/features/contacts/models/contact_model.dart
    mobile/lib/features/contacts/services/contact_service.dart
    mobile/lib/features/contacts/providers/contact_providers.dart
  </files>
  <action>
    1. Create ContactType enum (veterinarian, groomer, pet_sitter, emergency, pharmacy, trainer, other) with displayName and icon
    2. Create PetContact model (id, familyId, name, type, phone, email, address, notes, createdBy, createdAt, updatedAt) with Firestore serialization
    3. Create ContactService with:
       - addContact, updateContact, deleteContact
       - streamFamilyContacts(familyId) — ordered by name asc
    4. Create Riverpod providers: contactServiceProvider, familyContactsProvider
  </action>
  <verify>flutter build web 2>&1 | tail -3</verify>
  <done>Models compile, service methods exist, providers configured — build passes</done>
</task>

<task type="auto">
  <name>Contact screens and router integration</name>
  <files>
    mobile/lib/features/contacts/screens/contacts_screen.dart
    mobile/lib/features/contacts/screens/add_contact_screen.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    1. ContactsScreen: displays contacts for a family:
       - Grouped by ContactType (sections)
       - Contact cards showing name, phone, type icon
       - Tap to open phone dialer (url_launcher)
       - FAB to add contact
    2. AddContactScreen: form with name, type selector, phone, email, address, notes
       - Reuse for editing (pass existing contact)
    3. Wire routes in app_router.dart:
       - /contacts (replace placeholder) with familyId query param
       - /contacts/add
    
    Use ListTile with leading CircleAvatar for contact type icon.
  </action>
  <verify>flutter build web 2>&1 | tail -3</verify>
  <done>Contact list renders, add/edit functional, phone tap works — build passes</done>
</task>

## Success Criteria
- [ ] PetContact model with 7 contact types and Firestore serialization
- [ ] CRUD service with family streaming
- [ ] 2 screens (list grouped by type, add/edit form)
- [ ] Routes wired at /contacts/*
- [ ] flutter build web succeeds with 0 errors
