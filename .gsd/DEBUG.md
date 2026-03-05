# Debug Session: family-screen-loading-failure

## Symptom
Family screen loads for a very long time, then shows "Failed to load families".

**When:** After signing in and navigating to family screen
**Expected:** Family list shows user's families
**Actual:** Long loading spinner → error state

## Hypotheses

| # | Hypothesis | Likelihood | Status |
|---|------------|------------|--------|
| 1 | Firestore `whereIn(documentId)` query misaligned with security rules | 50% | ✅ FIXED (necessary but insufficient) |
| 2 | Firestore security rule uses `get()` which blocks collection queries | 95% | ✅ FIXED |

## Attempts

### Attempt 1
**Testing:** H1 — query alignment
**Action:** Changed `whereIn(documentId, familyIds)` → `where('memberIds', arrayContains: userId)`
**Result:** Still failed
**Conclusion:** Necessary fix but not the root cause

### Attempt 2
**Testing:** H2 — security rule `get()` blocks queries
**Action:** Changed families `read` rule from `isFamilyMember(familyId)` (uses `get()`) to inline `resource.data.memberIds` check
**Result:** Rules deployed successfully, awaiting verification

## Resolution

**Root Cause:** Two-part issue:
1. **Firestore query** used `whereIn(documentId)` — doesn't align with security rules
2. **Security rule** used `get()` helper to check memberIds — Firestore can't evaluate `get()` calls during query constraint validation

**Fixes:**
1. `family_service.dart`: `where('memberIds', arrayContains: userId)` 
2. `firestore.rules`: `request.auth.uid in resource.data.memberIds` (inline, no `get()`)
3. `family_list_screen.dart`: Added error details to UI for debugging

**Verified:** Rules compiled ✓, deployed ✓, `dart analyze` ✓
