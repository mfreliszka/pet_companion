---
phase: 4
plan: 3
wave: 2
---

# Plan 4.3: FCM Setup & Cloud Function Notification Crons

## Objective
Wire up Firebase Cloud Messaging on the Flutter client (Android + iOS + Web), implement local notification service, and create Python Cloud Functions for scheduled notification delivery (event reminders, medication reminders, vaccination due date reminders).

## Context
- .gsd/SPEC.md — Push notifications requirement
- .gsd/ARCHITECTURE.md — Cloud Functions table, FCM tokens in user doc
- mobile/pubspec.yaml — Need to add firebase_messaging + flutter_local_notifications
- firebase/functions/main.py — Existing Cloud Functions entry point
- mobile/lib/features/schedule/ — Event system from Plan 4.1

## Tasks

<task type="auto">
  <name>Flutter FCM client setup and notification service</name>
  <files>
    mobile/lib/services/notification_service.dart
    mobile/lib/features/notifications/providers/notification_providers.dart
    mobile/pubspec.yaml (update — add firebase_messaging, flutter_local_notifications)
    mobile/lib/main.dart (update — init notification service)
  </files>
  <action>
    1. Add dependencies to pubspec.yaml:
       - firebase_messaging
       - flutter_local_notifications

    2. Create NotificationService at mobile/lib/services/notification_service.dart:
       - initialize() — request permissions, configure foreground/background handlers
       - getAndSaveFcmToken(userId) — get FCM token, save to users/{userId}.fcmTokens array
       - onTokenRefresh(userId) — listen for token changes, update Firestore
       - handleForegroundMessage() — show local notification when app is in foreground
       - handleBackgroundMessage() — static handler for background messages
       - handleMessageOpenedApp() — navigate to relevant screen when notification tapped
       - Do NOT use flutter_local_notifications on web (guard with kIsWeb)

    3. Create notification_providers.dart:
       - notificationServiceProvider

    4. Update main.dart:
       - Call NotificationService.initialize() after Firebase.initializeApp()
       - Set up background message handler
       - After auth state changes to authenticated, call getAndSaveFcmToken
  </action>
  <verify>cd mobile && flutter build web 2>&1 | tail -3</verify>
  <done>FCM service compiles, token saved to Firestore, foreground notifications work — web build passes</done>
</task>

<task type="auto">
  <name>Cloud Functions — notification crons and dispatch</name>
  <files>
    firebase/functions/src/notifications/send_reminders.py
    firebase/functions/src/notifications/helpers.py
    firebase/functions/main.py (update)
    firebase/functions/requirements.txt (update)
  </files>
  <action>
    1. Create helpers.py at firebase/functions/src/notifications/helpers.py:
       - send_fcm_notification(token, title, body, data) — wrapper around Firebase Admin SDK messaging
       - get_family_member_tokens(family_id) — fetch all fcmTokens for family members
       - Should handle token errors (unregistered tokens → remove from user doc)

    2. Create send_reminders.py at firebase/functions/src/notifications/send_reminders.py:
       - send_event_reminder (Cloud Scheduler, runs every 5 min):
         - Query events where isActive == true
         - For cyclic events: compute next occurrence, check if reminderMinutesBefore matches current time window
         - For one-time events: check if oneTimeDate - reminderMinutesBefore is within current 5-min window
         - Send FCM to assigned member (or all family members if unassigned)
       - send_medication_reminder (Cloud Scheduler, runs every 15 min):
         - Query active medications across all pets
         - Check scheduledTimes against current time window
         - Send FCM to all family members of the pet's family
       - send_vaccination_reminder (daily at 09:00):
         - Query vaccinations where nextDueDate is within 7 days
         - Send reminder to all family members if reminderSent == false
         - Set reminderSent = true after sending

    3. Update main.py — register new scheduled functions
    4. Update requirements.txt if needed (firebase-admin should already be there)

    Note: Cloud Scheduler functions use @scheduler_fn decorator.
    Note: These are Gen 2 Python functions.
    Avoid over-engineering — keep queries simple, handle errors gracefully.
  </action>
  <verify>cd firebase/functions && python -c "import main" 2>&1</verify>
  <done>Cloud Functions import cleanly, scheduled functions registered in main.py</done>
</task>

## Success Criteria
- [ ] FCM permission flow works on mobile platforms
- [ ] FCM token persists to user document
- [ ] Cloud Functions crons compile and register
- [ ] flutter build web passes with 0 errors
