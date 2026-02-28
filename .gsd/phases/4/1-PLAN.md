---
phase: 4
plan: 1
wave: 1
---

# Plan 4.1: Event Model, Service & Scheduling Screens

## Objective
Build the event system's Flutter layer — model, Firestore service, Riverpod providers, and screens for creating and managing one-time and cyclic (recurring) events. This is the foundation for notifications and routines.

## Context
- .gsd/SPEC.md
- .gsd/ARCHITECTURE.md — `/events/{eventId}` + `/events/{eventId}/completions/{completionId}` schemas
- mobile/lib/features/health/models/ — Established model pattern (fromMap/toMap/copyWith)
- mobile/lib/features/health/services/ — Established service pattern
- mobile/lib/features/health/providers/ — Established provider pattern
- mobile/lib/core/routing/app_router.dart — GoRouter config

## Tasks

<task type="auto">
  <name>Event model, service, and providers</name>
  <files>
    mobile/lib/features/schedule/models/event_model.dart
    mobile/lib/features/schedule/models/event_completion_model.dart
    mobile/lib/features/schedule/services/event_service.dart
    mobile/lib/features/schedule/providers/schedule_providers.dart
  </files>
  <action>
    1. Create EventModel at mobile/lib/features/schedule/models/event_model.dart:
       - `EventType` enum: feeding, medication, walk, grooming, vet_appointment, reminder, custom (with displayName + icon)
       - `EventSchedule` class: times (List<String>), daysOfWeek (List<int>?), intervalDays (int?), startDate, endDate
       - `Event` class: id, title, description, petId, familyId, type, isCyclic, schedule, oneTimeDate, assignedTo, createdBy, isActive, reminderMinutesBefore
       - fromMap/toMap/copyWith + computed `isOneTime` getter
       - Follow ARCHITECTURE.md schema exactly

    2. Create EventCompletionModel at mobile/lib/features/schedule/models/event_completion_model.dart:
       - Fields: id, scheduledAt, completedAt, completedBy, completedByName, notes, medicationAdded
       - fromMap/toMap

    3. Create EventService at mobile/lib/features/schedule/services/event_service.dart:
       - Top-level `/events` collection (NOT subcollection of pets)
       - addEvent, updateEvent, deleteEvent
       - streamFamilyEvents(familyId) — where familyId == familyId, isActive == true, ordered by createdAt desc
       - streamPetEvents(petId) — where petId == petId, isActive == true
       - completeEvent(eventId, completion) — add to /events/{eventId}/completions subcollection
       - streamCompletions(eventId) — ordered by scheduledAt desc

    4. Create providers at mobile/lib/features/schedule/providers/schedule_providers.dart:
       - eventServiceProvider (Provider)
       - familyEventsProvider (StreamProvider.family<List<Event>, String>)
       - petEventsProvider (StreamProvider.family<List<Event>, String>)
       - eventCompletionsProvider (StreamProvider.family<List<EventCompletion>, String>)
  </action>
  <verify>cd mobile && flutter analyze 2>&1 | tail -3</verify>
  <done>Models serialize correctly, service compiles, providers registered — 0 analysis errors</done>
</task>

<task type="auto">
  <name>Event list screen, create event screen, and router integration</name>
  <files>
    mobile/lib/features/schedule/screens/events_screen.dart
    mobile/lib/features/schedule/screens/add_event_screen.dart
    mobile/lib/features/schedule/screens/event_detail_screen.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    1. Create EventsScreen at mobile/lib/features/schedule/screens/events_screen.dart:
       - Takes petId parameter
       - Tabs: "Upcoming" (one-time + next occurrence of cyclic), "Recurring"
       - Event cards showing title, type icon, pet name, time/schedule info, assigned member
       - Overdue/upcoming visual indicators
       - FAB to add new event

    2. Create AddEventScreen at mobile/lib/features/schedule/screens/add_event_screen.dart:
       - Toggle: one-time vs cyclic
       - Fields: title, type selector (EventType chips), description, assign to member (optional)
       - One-time: date + time picker
       - Cyclic: schedule builder (times of day, days of week checkboxes or interval input, start/end date)
       - Reminder minutes selector (0, 5, 10, 15, 30, 60)
       - petId and familyId passed as parameters

    3. Create EventDetailScreen at mobile/lib/features/schedule/screens/event_detail_screen.dart:
       - Shows event details (type, schedule, assigned member)
       - "Mark Complete" button → creates completion record
       - Completion history list (from streamCompletions)
       - Deactivate/delete event actions

    4. Update app_router.dart:
       - Add routes: /pets/:petId/events, /pets/:petId/events/add, /pets/:petId/events/:eventId
       - Update _titleForRoute
       - Add imports
  </action>
  <verify>cd mobile && flutter build web 2>&1 | tail -3</verify>
  <done>Event screens render, routes work, build passes with 0 errors</done>
</task>

## Success Criteria
- [ ] Event model covers all ARCHITECTURE.md fields
- [ ] Cyclic + one-time events can be created from the UI
- [ ] Event detail screen shows completion history
- [ ] flutter build web passes with 0 errors
