# ROADMAP.md

> **Current Phase**: Not started
> **Milestone**: v1.0 — Core Pet Companion

## Must-Haves (from SPEC)
- [ ] Google Sign-In authentication
- [ ] Pet profiles with photo upload and compression
- [ ] Family system (create, invite, roles, shared pets)
- [ ] Pet journal (mood, symptoms, appetite, energy, weight, behavior, medications, vet records)
- [ ] Push notifications for scheduled events with auto-dismissal
- [ ] Daily routine templates with family member assignments
- [ ] Expense tracking with monthly/yearly totals
- [ ] PDF health report generation
- [ ] Premium feature gating

## Phases

### Phase 1: Project Foundation & Authentication
**Status**: ✅ Complete
**Objective**: Flutter project scaffold, Firebase setup, Google Sign-In, user profile, design system
**Requirements**: REQ-01, REQ-02
- Flutter project creation with folder structure (`mobile/`)
- Firebase project creation from scratch (Auth, Firestore)
- Cloudflare R2 bucket provisioning
- Firestore security rules (initial)
- Full custom design system (colors, typography, spacing, reusable component library)
- Light + Dark theme (dark mode default)
- Drawer navigation with GoRouter
- Google Sign-In flow
- User document creation in Firestore on first sign-in
- Basic user profile screen (name, email, photo, sign out)
- Ensure Flutter web builds work for rapid UI testing

### Phase 2: Pet Profiles & Family System
**Status**: ⬜ Not Started
**Objective**: Pet CRUD with photo upload, family creation/invitation, role management
**Requirements**: REQ-03, REQ-04
- Pet model and Firestore CRUD
- Pet photo capture, crop (face-center), compress, upload to R2
- Cloud Function: R2 signed URL generation
- Family creation and management
- Family invitation (by email and by code+password)
- Admin role management
- Family member list screen
- Assign pets to families

### Phase 3: Pet Journal & Health Tracking
**Status**: ⬜ Not Started
**Objective**: Build the core journal timeline with all entry types, weight chart, medical records
**Requirements**: REQ-05, REQ-06
- Journal entry model (mood, symptom, appetite, energy, weight, behavior, note, medication, care_record, walk, grooming)
- Journal timeline screen with filtering
- Journal entry creation forms (per type)
- Photo attachment to journal entries
- Weight history tracking with line chart
- Vaccination records
- Medical records storage with document upload
- Microchip information
- Behavior incident log

### Phase 4: Schedules, Notifications & Routines
**Status**: ⬜ Not Started
**Objective**: Events, cyclic events, push notifications with dismissal, daily routines, task assignments
**Requirements**: REQ-07, REQ-08
- Event model (one-time and cyclic)
- Event creation and management screens
- FCM setup (Android + iOS)
- Cloud Functions: scheduled notification cron jobs
- Event completion with auto-dismiss notifications
- Medication reminders
- Vaccination due date reminders
- Daily routine templates
- Family member task assignments
- Care schedule calendar view
- User notification preferences (mute specific events)
- Admin notification settings per member

### Phase 5: Expenses, Contacts, Reports & Premium
**Status**: ⬜ Not Started
**Objective**: Expense tracking, service contacts, PDF reports, premium subscription
**Requirements**: REQ-09, REQ-10, REQ-11
- Expense tracking CRUD
- Expense category filtering and totals
- Monthly/yearly expense summaries
- Pet service contact list
- PDF report generation (Cloud Function)
- PDF sharing
- Premium subscription management
- Feature gating (client-side + server-side)
- Final polish, performance optimization, caching

---

### Phase 6: Family Feature Fixes
**Status**: ✅ Complete
**Objective**: Fix pet creation without family, join-by-code without password, invitation delivery
**Depends on**: Phase 2

**Tasks**:
- [x] Auto-create personal family when adding pet without one
- [x] Fix join-family-by-code without password
- [x] In-app invitation delivery system

---

### Phase 7: API Key Security
**Status**: ✅ Complete
**Objective**: Remove exposed Firebase API keys from git tracking, restrict keys, audit for secrets
**Depends on**: Phase 1

**Tasks**:
- [ ] Remove tracked Firebase config files from git index
- [ ] Restrict API keys in Google Cloud Console
- [ ] Verify no other hardcoded secrets in codebase
- [ ] (Optional) Scrub git history with filter-repo

**Verification**:
- `git ls-files --cached` shows no Firebase config files
- API keys restricted in GCP Console
- App builds successfully with untracked config files
