# STATE.md — Project Memory

> **Last Updated**: 2026-02-28 23:15
> **Current Phase**: 4 — Schedules, Notifications & Routines
> **Status**: ✅ Complete

## Current Position
- **Phase**: 4 (complete)
- **Task**: All 4 plans executed across 3 waves
- **Status**: Build verified, committed

## Last Session Summary
Phase 4 complete (4 plans, 4 commits). Full schedule system implemented:
- Events: model, service, add/list/detail screens, router
- Routines: template model, daily log system, reorderable task builder, detail screen
- FCM: NotificationService with token management, Cloud Function crons (event + vaccination reminders)
- Calendar: custom month grid, per-day event + routine progress view, notification preferences

### Known Issue (from Phase 1)
Firestore security rules not yet deployed → `PERMISSION_DENIED` when reading user doc. Run:
```bash
cd firebase && firebase deploy --only firestore:rules --project=pet-companion-app
```

## Plans Status
| Plan | Wave | Name | Status |
|------|------|------|--------|
| 1.1 | 1 | Project Scaffold + Firebase Setup | ✅ Complete |
| 1.2 | 2 | Design System + Component Library | ✅ Complete |
| 1.3 | 3 | Auth + Navigation + Screens | ✅ Complete |
| 2.1 | 1 | Pet Model, Service & CRUD Screens | ✅ Complete |
| 2.2 | 2 | Pet Photo Upload (R2 + Cloud Function) | ✅ Complete |
| 2.3 | 3 | Family System (CRUD, Invitation, Roles) | ✅ Complete |
| 3.1 | 1 | Journal Entry Model, Service & Timeline | ✅ Complete |
| 3.2 | 1 | Weight Tracking & Medication Management | ✅ Complete |
| 3.3 | 2 | Vaccinations, Medical Records & Health Hub | ✅ Complete |
| 4.1 | 1 | Event Model, Service & Scheduling Screens | ✅ Complete |
| 4.2 | 1 | Daily Routine Templates & Task Assignments | ✅ Complete |
| 4.3 | 2 | FCM Setup & Cloud Function Notification Crons | ✅ Complete |
| 4.4 | 3 | Calendar View, Notification Prefs & Auto-Dismiss | ✅ Complete |

## Next Steps
1. Phase 5 planning — TBD (Expenses, Contacts, Premium features, etc.)
