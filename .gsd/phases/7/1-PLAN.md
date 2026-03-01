---
phase: 7
plan: 1
wave: 1
title: Remove Firebase Config Files from Git Tracking
goal: Ensure no Firebase API keys or secrets are tracked in git
---

# Plan 7.1: Remove Firebase Config Files from Git Tracking

## Goal
Remove all Firebase configuration files containing API keys from git tracking, verify `.gitignore` coverage, and audit the full codebase for hardcoded secrets.

## Must-Haves
- [ ] `GoogleService-Info.plist` and `google-services.json` removed from git index
- [ ] `.gitignore` covers all sensitive files
- [ ] No hardcoded API keys, secrets, or credentials anywhere in tracked codebase
- [ ] App still builds with config files on disk (untracked)

## Tasks

### Task 1: Remove tracked Firebase config files
**Actions:**
```bash
git rm --cached mobile/ios/Runner/GoogleService-Info.plist
git rm --cached mobile/android/app/google-services.json
```

**Verify:**
```bash
git ls-files --cached | grep -E "(GoogleService|google-services|firebase_options)" | wc -l
# Expected: 0
```

### Task 2: Verify .gitignore coverage
**Actions:**
- Confirm `.gitignore` has entries for:
  - `**/firebase_options.dart`
  - `**/GoogleService-Info.plist`
  - `**/google-services.json`
  - `.env`

**Verify:**
```bash
grep -c "firebase_options\|GoogleService-Info\|google-services\|\.env" .gitignore
# Expected: >= 4
```

### Task 3: Full secrets audit
**Actions:**
- Search for API key patterns (`AIzaSy...`)
- Search for hardcoded credentials, tokens, passwords
- Verify R2 secrets only in `.env` (gitignored)

**Verify:**
```bash
# No API keys in tracked files
git ls-files | xargs grep -l "AIzaSy" 2>/dev/null | wc -l
# Expected: 0
```

### Task 4: Commit
```bash
git add -A
git commit -m "security: remove Firebase config files from git tracking"
```
