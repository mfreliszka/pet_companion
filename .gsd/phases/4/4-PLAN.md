---
phase: 4
plan: 4
wave: 3
---

# Plan 4.4: Calendar View, Notification Preferences & Event Completion Auto-Dismiss

## Objective
Build the care schedule calendar view, implement user + admin notification preference screens, and wire up event completion → auto-dismiss notification logic. This plan ties together the events, routines, and notifications into a polished user experience.

## Context
- .gsd/SPEC.md — Calendar view, notification preferences, auto-dismissal requirements
- .gsd/ARCHITECTURE.md — notificationPreferences subcollection, notificationSettings subcollection
- mobile/lib/features/schedule/ — Events + routines from Plans 4.1–4.2
- mobile/lib/services/notification_service.dart — FCM from Plan 4.3

## Tasks

<task type="auto">
  <name>Care schedule calendar view</name>
  <files>
    mobile/lib/features/schedule/screens/schedule_calendar_screen.dart
    mobile/lib/core/routing/app_router.dart (update)
  </files>
  <action>
    1. Add dependency: table_calendar (pub.dev) for calendar widget

    2. Create ScheduleCalendarScreen at mobile/lib/features/schedule/screens/schedule_calendar_screen.dart:
       - Uses table_calendar for month/week view toggle
       - Shows dots/markers on days with events
       - Selected day shows list of events below calendar
       - Event cards link to event detail
       - Filter by pet (dropdown) or show all
       - Includes both one-time events AND computed cyclic event occurrences for visible date range
       - Tab or toggle to also show routine completion status for each day

    3. Update app_router.dart:
       - Wire /schedule route to ScheduleCalendarScreen (replacing placeholder)
       - The calendar is family-scoped (reads from familyEventsProvider)
       - Add imports, update _titleForRoute
  </action>
  <verify>cd mobile && flutter build web 2>&1 | tail -3</verify>
  <done>Calendar renders with event markers, day selection shows event list, build passes</done>
</task>

<task type="auto">
  <name>Notification preferences and event completion auto-dismiss</name>
  <files>
    mobile/lib/features/notifications/models/notification_preferences_model.dart
    mobile/lib/features/notifications/services/notification_preferences_service.dart
    mobile/lib/features/notifications/screens/notification_settings_screen.dart
    mobile/lib/features/notifications/providers/notification_providers.dart (update)
    firebase/functions/src/notifications/on_event_completed.py
    firebase/functions/main.py (update)
  </files>
  <action>
    1. Create NotificationPreferences model:
       - User prefs: familyId, mutedEventIds, enablePush, updatedAt
       - fromMap/toMap following ARCHITECTURE.md schema

    2. Create NotificationPreferencesService:
       - Reads/writes to /users/{userId}/notificationPreferences/{familyId}
       - togglePush(userId, familyId, enabled)
       - muteEvent(userId, familyId, eventId) / unmuteEvent

    3. Create NotificationSettingsScreen:
       - Master push toggle per family
       - List of active events with mute toggle per event
       - Toggle animations for a polished feel

    4. Create on_event_completed.py Cloud Function:
       - Trigger: Firestore onCreate on /events/{eventId}/completions/{completionId}
       - Action: Send FCM notification to all family members of the event's family
       - Message: "{completedByName} completed {eventTitle}"
       - Include data payload with eventId for navigation
       - This IS the "auto-dismiss" — when one member completes, others are notified
       - Skip sending to the person who completed it

    5. Update main.py — register on_event_completed function
    6. Update notification_providers.dart with preferences providers
    7. Update app_router.dart — add /settings/notifications route
  </action>
  <verify>cd mobile && flutter build web 2>&1 | tail -3</verify>
  <done>Notification settings screen renders, auto-dismiss Cloud Function registered, build passes</done>
</task>

## Success Criteria
- [ ] Calendar shows events with day markers
- [ ] Notification preferences persist to Firestore
- [ ] Event completion triggers notification to other family members
- [ ] flutter build web passes with 0 errors
