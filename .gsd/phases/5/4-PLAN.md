---
phase: 5
plan: 4
wave: 3
---

# Plan 5.4: Premium Subscription & Feature Gating + Final Polish

## Objective
Implement premium subscription management with client-side and server-side feature gating. Add Firestore-based premium status tracking, a subscription management screen, and gate specific features behind premium. Final polish pass: performance optimization, caching, and UX improvements.

## Context
- .gsd/SPEC.md — "Premium feature gating works end-to-end"
- mobile/lib/features/premium/ (empty scaffold)
- mobile/lib/features/auth/providers/auth_providers.dart (existing user model)
- firebase/functions/main.py (server-side validation)

## Tasks

<task type="auto">
  <name>Premium model, gating service, and subscription screen</name>
  <files>
    mobile/lib/features/premium/models/premium_model.dart
    mobile/lib/features/premium/services/premium_service.dart
    mobile/lib/features/premium/providers/premium_providers.dart
    mobile/lib/features/premium/screens/premium_screen.dart
    mobile/lib/features/premium/widgets/premium_gate.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    1. Create PremiumTier enum (free, premium) with feature lists
    2. Create PremiumFeature enum (pdf_reports, expense_export, unlimited_pets, priority_notifications, custom_themes)
    3. Create PremiumService:
       - isPremium(userId) — checks user doc isPremium + premiumExpiresAt
       - hasFeature(userId, feature) — checks if feature available for tier
       - Stream<bool> streamPremiumStatus(userId)
    4. Create Riverpod providers: premiumServiceProvider, isPremiumProvider, premiumStatusStreamProvider
    5. Create PremiumGate widget — wraps child content, shows upgrade prompt if not premium
    6. Create PremiumScreen:
       - Current plan display (Free / Premium)
       - Feature comparison table
       - "Upgrade" button (placeholder — RevenueCat/Stripe integration later)
       - Premium expiry date if subscribed
    7. Wire /premium route in app_router.dart
    
    Note: Actual payment processing is OUT OF SCOPE. This is the gating infrastructure.
    The user doc already has isPremium and premiumExpiresAt fields from Phase 1.
  </action>
  <verify>flutter build web 2>&1 | tail -3</verify>
  <done>Premium gating works, PremiumGate widget blocks/shows features, screen renders — build passes</done>
</task>

<task type="auto">
  <name>Final polish — performance, caching, and UX</name>
  <files>
    mobile/lib/main.dart
    mobile/lib/core/routing/app_router.dart
    mobile/lib/features/home/screens/home_screen.dart
  </files>
  <action>
    1. Add Riverpod keepAlive to critical providers (user, family, pets) for offline-first feel
    2. Add error boundaries to all stream-based screens (consistent error UI)
    3. Update home screen with quick-access cards:
       - Today's events count
       - Incomplete routines
       - Recent expenses total
       - Premium upsell card if free tier
    4. Add _titleForRoute entries for all new routes (expenses, contacts, reports, premium)
    5. Ensure all placeholder routes are replaced with actual screens
    
    Focus on making the app feel polished and complete as a v1.
  </action>
  <verify>flutter build web 2>&1 | tail -3</verify>
  <done>No placeholder screens remain, home dashboard shows data cards, keepAlive on key providers — build passes</done>
</task>

## Success Criteria
- [ ] Premium gating infrastructure with PremiumGate widget
- [ ] Premium screen with feature comparison
- [ ] Server-side premium check possible via user doc
- [ ] Home screen shows actionable dashboard cards
- [ ] All placeholder routes replaced
- [ ] flutter build web succeeds with 0 errors
