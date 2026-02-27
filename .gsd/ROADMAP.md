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
**Status**: ⬜ Not Started
**Objective**: Flutter project scaffold, Firebase setup, Google Sign-In, user profile
**Requirements**: REQ-01, REQ-02
- Flutter project creation with folder structure
- Firebase project configuration (Auth, Firestore, FCM)
- Cloudflare R2 bucket setup
- Firestore security rules (initial)
- Google Sign-In flow
- User profile screen
- Basic app navigation (GoRouter)
- Theme and design system

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
