---
phase: 2
plan: 3
wave: 3
---

# Plan 2.3: Family System (CRUD, Invitation, Roles)

## Objective
Implement family creation, management, invitation (by email + by code/password), admin/member roles, and the family screens. Replace the `/family` placeholder route.

## Context
- .gsd/ARCHITECTURE.md (families collection schema, invitations subcollection, notificationSettings subcollection)
- .gsd/phases/2/RESEARCH.md (invitation strategies)
- mobile/lib/features/auth/services/auth_service.dart (service pattern)
- mobile/lib/features/auth/providers/auth_providers.dart (provider pattern)
- mobile/lib/core/routing/app_router.dart (router to update)
- firebase/functions/main.py (add family Cloud Functions)

## Tasks

<task type="auto">
  <name>Family model, service, and providers</name>
  <files>
    mobile/lib/features/family/models/family_model.dart
    mobile/lib/features/family/models/invitation_model.dart
    mobile/lib/features/family/services/family_service.dart
    mobile/lib/features/family/providers/family_providers.dart
  </files>
  <action>
    FamilyModel — matches ARCHITECTURE.md `/families/{familyId}`:
    - Fields: name, familyCode, adminIds, memberIds, petIds, createdBy, createdAt, updatedAt
    - Do NOT include hashedPassword in client model (security — server-only)
    - fromMap/toMap/copyWith

    InvitationModel — matches `/families/{familyId}/invitations/{invitationId}`:
    - Fields: invitedEmail, invitedBy, status, createdAt, expiresAt
    - fromMap/toMap

    FamilyService:
    - `createFamily(String name, String userId) → Future<String>` 
      — Creates family doc, sets user as admin+member, generates familyCode (uuid short), updates user's familyIds
    - `streamFamily(String familyId) → Stream<Family?>`
    - `streamUserFamilies(List<String> familyIds) → Stream<List<Family>>`
    - `updateFamily(String familyId, Map<String, dynamic> data) → Future<void>`
    - `deleteFamily(String familyId) → Future<void>` (admin only)
    - `removeMember(String familyId, String userId) → Future<void>` (admin only)
    - `leaveFamily(String familyId, String userId) → Future<void>`
    - `sendInvitation(String familyId, String email, String invitedBy) → Future<void>` 
      — Creates doc in invitations subcollection
    - `streamInvitations(String familyId) → Stream<List<Invitation>>`
    - `joinByCode(String code, String password, String userId) → Future<void>`
      — Calls Cloud Function for server-side password verification

    Providers:
    - `familyServiceProvider` — Provider<FamilyService>
    - `userFamiliesProvider` — StreamProvider<List<Family>> derived from userDocProvider familyIds
    - `familyDetailProvider(String familyId)` — StreamProvider<Family?>
    - `familyInvitationsProvider(String familyId)` — StreamProvider<List<Invitation>>
    - `isAdminProvider(String familyId)` — Provider<bool> checks if current user is in adminIds
  </action>
  <verify>flutter analyze mobile/lib/features/family/</verify>
  <done>Family and Invitation models compile, FamilyService has all CRUD + invitation methods, providers wire up</done>
</task>

<task type="auto">
  <name>Cloud Function: Family invitation processing</name>
  <files>
    firebase/functions/src/family/__init__.py
    firebase/functions/src/family/invitation_handler.py
    firebase/functions/main.py
    firebase/functions/requirements.txt
  </files>
  <action>
    invitation_handler.py:
    - `join_family_by_code(code: str, password: str, user_id: str)`:
      - Query families collection where familyCode == code
      - Verify bcrypt hash of password against hashedPassword
      - Add user_id to memberIds (arrayUnion)
      - Update user's familyIds (arrayUnion)
      - Return family data
    - `create_family_with_password(name: str, password: str, user_id: str)`:
      - Generate familyCode (short uuid)
      - Hash password with bcrypt
      - Create family doc

    main.py — Add callable functions:
    - `join_family_by_code(req)` — auth required
    - `create_family(req)` — auth required (wraps create_family_with_password)

    requirements.txt — Add `bcrypt>=4.0.0`
  </action>
  <verify>cd firebase && python -c "from functions.src.family.invitation_handler import join_family_by_code; print('import ok')"</verify>
  <done>Cloud Functions for family creation (with password hashing) and join-by-code (with verification) are defined</done>
</task>

<task type="auto">
  <name>Family screens and route integration</name>
  <files>
    mobile/lib/features/family/screens/family_list_screen.dart
    mobile/lib/features/family/screens/create_family_screen.dart
    mobile/lib/features/family/screens/family_detail_screen.dart
    mobile/lib/features/family/screens/join_family_screen.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    FamilyListScreen:
    - Lists user's families (from userFamiliesProvider)
    - Each family as a card showing name, member count, pet count
    - FAB with two options: "Create Family" / "Join Family"
    - Tap card → FamilyDetailScreen

    CreateFamilyScreen:
    - Form: family name, optional password for code+password join
    - On create: calls Cloud Function create_family
    - Shows the generated familyCode to the user to share

    FamilyDetailScreen:
    - Shows family name, familyCode (copyable), member list
    - Admin actions: invite member (email), remove member, delete family
    - Member actions: leave family
    - Pet list belonging to this family
    - "Invite" button → text field for email

    JoinFamilyScreen:
    - Form: familyCode, password
    - On submit: calls Cloud Function join_family_by_code
    - Success → navigate to family detail

    Router updates:
    - Replace `/family` PlaceholderScreen with FamilyListScreen
    - Add `/family/create` → CreateFamilyScreen
    - Add `/family/join` → JoinFamilyScreen
    - Add `/family/:familyId` → FamilyDetailScreen
  </action>
  <verify>flutter build web --no-tree-shake-icons</verify>
  <done>Family screens render, create/join flows work, admin role actions visible only to admins, routes connected</done>
</task>

## Success Criteria
- [ ] User can create a family with name and optional password
- [ ] Family code is generated and displayed for sharing
- [ ] User can join a family by code + password
- [ ] Admin can invite members by email
- [ ] Admin can remove members; members can leave
- [ ] `/family` shows list of user's families
- [ ] Family detail shows members, pets, and admin actions
- [ ] App compiles for web and Android
