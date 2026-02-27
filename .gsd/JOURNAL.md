# JOURNAL.md — Session Log

## Session: 2026-02-27 20:15–20:39

### Objective
Resume from pause, complete Plan 1.3 (Auth + Navigation + Screens), verify on Android.

### Accomplished
- **Firebase Config**: Committed `flutterfire configure` output (google-services.json, firebase_options.dart, etc.)
- **Plan 1.3 Task 1**: Auth service (google_sign_in v7 API), Riverpod providers, Firestore user doc creation
- **Plan 1.3 Task 2**: GoRouter with auth redirect, ShellRoute + AppDrawer, placeholder screens for all features
- **Plan 1.3 Task 3**: Sign-in, home, and profile screens using design system components
- **SHA-1 Fix**: Added Android debug SHA-1 fingerprint to Firebase project (was causing Credential Manager failure)
- **Verified**: Google Sign-In works on Android device, user approved

### Deviations
- google_sign_in v7: Rewrote auth for singleton `GoogleSignIn.instance` / `.authenticate()` API (no more constructor + `.signIn()`)
- riverpod 3.1: `valueOrNull` removed, replaced with `.value`
- SHA-1 fingerprint: Had to add debug cert to Firebase for Android Credential Manager to work

### Verification
- [x] `flutter analyze lib/` — 0 errors
- [x] `flutter run -d 192.168.1.148:5555` — Sign-in screen renders, Google Sign-In works
- [ ] Firestore user doc read — PERMISSION_DENIED (rules not deployed yet)

### Known Issues
- Firestore security rules not deployed → user doc read fails with PERMISSION_DENIED
- Fix: `cd firebase && firebase deploy --only firestore:rules --project=pet-companion-app`

### Handoff Notes
- Phase 1 complete, 10 commits total
- Next: `/plan 2` for Phase 2 (Pet Profiles & Family System)
- Firestore rules deployment needed before Phase 2

---

## Session: 2026-02-27 16:00–17:50

### Objective
Initialize GSD project, plan Phase 1, and begin Phase 1 execution.

### Accomplished
- **Project Init**: Created SPEC.md, ARCHITECTURE.md, ROADMAP.md, DECISIONS.md, REQUIREMENTS.md, STACK.md
- **Phase 1 Discussion** (`/discuss-phase 1`): Resolved scope decisions — Firebase/R2 creation in Phase 1, full design system, drawer nav, dark mode default, web support, deferred onboarding
- **Phase 1 Planning** (`/plan 1`): Created 3 plans across 3 waves (8 tasks total)
- **Phase 1 Execution** (`/execute 1`):
  - ✅ Plan 1.1 Task 1: Flutter project at `mobile/`, 153 dependencies resolved
  - ✅ Plan 1.1 Task 3: Firestore rules, indexes, Cloud Functions skeleton
  - ✅ Plan 1.2 Task 1: Design tokens (colors, typography, spacing, theme)
  - ✅ Plan 1.2 Task 2: 15 reusable widget components
  - ⏸ Plan 1.1 Task 2: Firebase project creation (checkpoint — user action needed)

### Decisions Made (this session)
- ADR-07: Default currency PLN
- ADR-08: 5-minute notification lead time
- ADR-09: Full custom design system with component library
- ADR-10: Dark mode default
- ADR-11: Drawer navigation
- ADR-12: Flutter web support for UI testing

### Verification
- [x] `flutter pub get` — 153 dependencies resolved
- [x] `flutter analyze lib/core/` — 0 errors (2 info-level suggestions)

### Paused Because
Firebase project creation is a human-action checkpoint.

### Handoff Notes
- Git is clean (no uncommitted changes, 4 commits ahead of origin)
- Plan 1.3 is next: auth service → GoRouter nav → screens
