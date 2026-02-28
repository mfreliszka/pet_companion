# STATE.md — Project Memory

> **Last Updated**: 2026-02-28 23:45
> **Current Phase**: 5 — Expenses, Contacts, Reports & Premium
> **Status**: ✅ Complete

## Current Position
- **Phase**: 5 (complete)
- **Task**: All 4 plans executed across 3 waves
- **Next**: Phase 6 (if planned) or production readiness

## Phase History
| Phase | Status | Key Commits |
|-------|--------|-------------|
| 1: Auth & Scaffold | ✅ Complete | Design system, auth, navigation |
| 2: Pets & Family | ✅ Complete | Pet CRUD, R2 uploads, family system |
| 3: Journal & Health | ✅ Complete | Journal timeline, health hub, weight/meds/vax/records |
| 4: Schedules & Notifications | ✅ Complete | Events, routines, FCM, calendar, prefs |
| 5: Expenses, Contacts, Reports & Premium | ✅ Complete | Expenses, contacts, PDF reports, premium subscription |

## Phase 5 Commits
| Commit | Plan | Description |
|--------|------|-------------|
| `a7065c9` | 5.1 | Expense model, service, 3 screens |
| `4ad33ec` | 5.2 | Contact model, service, 2 screens |
| `57cf200` | 5.3 | Cloud Function PDF generator, report screen |
| `eecebbe` | 5.4 | Subscription model, paywall, PremiumGate widget |

## Architecture
- **Framework**: Flutter (Dart) + Python Cloud Functions
- **State**: Riverpod (providers per feature)
- **Routing**: GoRouter with ShellRoute
- **Backend**: Firebase Auth, Firestore, Cloud Functions Gen 2
- **Storage**: Cloudflare R2 via presigned URLs
- **Design**: Material 3 with custom AppTheme

## Key Patterns
- Models: Firestore serialization (fromMap/toMap)
- Services: Single-responsibility, injected via Riverpod
- Feature folders: models/, services/, providers/, screens/, widgets/
- Cloud Functions: Python, organized in src/ submodules
