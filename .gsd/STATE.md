# STATE.md — Project Memory

> **Last Updated**: 2026-03-01 12:15
> **Current Phase**: 7 — API Key Security
> **Status**: ✅ Complete

## Current Position
- **Phase**: 7 (complete)
- **Task**: All tasks verified
- **Next**: Production readiness or new features

## Phase History
| Phase | Status | Key Commits |
|-------|--------|-------------|
| 1: Auth & Scaffold | ✅ Complete | Design system, auth, navigation |
| 2: Pets & Family | ✅ Complete | Pet CRUD, R2 uploads, family system |
| 3: Journal & Health | ✅ Complete | Journal timeline, health hub, weight/meds/vax/records |
| 4: Schedules & Notifications | ✅ Complete | Events, routines, FCM, calendar, prefs |
| 5: Expenses, Contacts, Reports & Premium | ✅ Complete | Expenses, contacts, PDF reports, premium subscription |
| 6: Family Feature Fixes | ✅ Complete | Auto-create family, join without password, invitation system |
| 7: API Key Security | ✅ Complete | Remove Firebase configs from git, secrets audit |

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
