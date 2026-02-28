---
phase: 4
plan: 2
wave: 1
---

# Plan 4.2: Daily Routine Templates & Task Assignments

## Objective
Build the routine system — templates with ordered task lists, family member assignments, and daily completion tracking. This lets families coordinate recurring care activities (morning feeding, evening walk, etc.) with clear ownership.

## Context
- .gsd/SPEC.md
- .gsd/ARCHITECTURE.md — `/routineTemplates/{templateId}` + `/routineTemplates/{templateId}/dailyLogs/{dateString}` schemas
- mobile/lib/features/schedule/ — Event system from Plan 4.1
- mobile/lib/features/family/providers/ — Family member data for assignment dropdown

## Tasks

<task type="auto">
  <name>Routine template model, service, and providers</name>
  <files>
    mobile/lib/features/schedule/models/routine_template_model.dart
    mobile/lib/features/schedule/services/routine_service.dart
    mobile/lib/features/schedule/providers/schedule_providers.dart (update)
  </files>
  <action>
    1. Create RoutineTemplateModel at mobile/lib/features/schedule/models/routine_template_model.dart:
       - `TimeOfDaySlot` enum: morning, afternoon, evening, custom (with display name + icon)
       - `RoutineTask` class: id, title, assignedTo, order — fromMap/toMap
       - `RoutineTemplate` class: id, familyId, petId, name, timeOfDay, tasks (List<RoutineTask>), isActive, createdBy, createdAt, updatedAt
       - fromMap/toMap/copyWith

    2. Create DailyLogModel at same file or separate:
       - `DailyLog` class: date (DateTime), completedTasks (Map<String, CompletedTaskInfo>)
       - `CompletedTaskInfo`: completedBy, completedAt
       - fromMap/toMap

    3. Create RoutineService at mobile/lib/features/schedule/services/routine_service.dart:
       - Collection: `/routineTemplates` (top-level, NOT subcollection)
       - addTemplate, updateTemplate, deleteTemplate
       - streamFamilyRoutines(familyId) — where familyId == familyId, isActive == true
       - markTaskComplete(templateId, dateString, taskId, userId) — set in dailyLogs subcollection
       - unmarkTaskComplete(templateId, dateString, taskId) — remove from completedTasks map
       - streamDailyLog(templateId, dateString) — single doc stream

    4. Update schedule_providers.dart:
       - routineServiceProvider
       - familyRoutinesProvider (StreamProvider.family)
       - dailyLogProvider (StreamProvider.family parameterized by templateId + dateString)
  </action>
  <verify>cd mobile && flutter analyze 2>&1 | tail -3</verify>
  <done>Routine models compile, service CRUD works, providers registered — 0 analysis errors</done>
</task>

<task type="auto">
  <name>Routine screens and router integration</name>
  <files>
    mobile/lib/features/schedule/screens/routines_screen.dart
    mobile/lib/features/schedule/screens/add_routine_screen.dart
    mobile/lib/features/schedule/screens/routine_detail_screen.dart
    mobile/lib/core/routing/app_router.dart (update)
  </files>
  <action>
    1. Create RoutinesScreen at mobile/lib/features/schedule/screens/routines_screen.dart:
       - Takes familyId parameter
       - Groups templates by timeOfDay (morning → evening)
       - Each card shows: name, pet (if scoped), task count, time slot chip
       - Today's completion progress bar per routine
       - FAB to add new routine

    2. Create AddRoutineScreen at mobile/lib/features/schedule/screens/add_routine_screen.dart:
       - Fields: name, timeOfDay selector, optional pet selector
       - Reorderable task list builder: add task (title + optional member assignment), drag to reorder, swipe to delete
       - Family member dropdown for assignment (from family providers)

    3. Create RoutineDetailScreen at mobile/lib/features/schedule/screens/routine_detail_screen.dart:
       - Shows template name, time slot, pet (if any)
       - Today's task checklist with checkboxes — each shows assigned member avatar, completed-by info
       - Tapping checkbox calls markTaskComplete/unmarkTaskComplete
       - Date picker to view other days' completion logs
       - Edit/delete routine actions

    4. Update app_router.dart:
       - Add routes under /schedule: /schedule/routines, /schedule/routines/add, /schedule/routines/:routineId
       - Do NOT nest under /pets since routines are family-scoped
       - Add imports, update _titleForRoute
  </action>
  <verify>cd mobile && flutter build web 2>&1 | tail -3</verify>
  <done>Routine screens render with task checklist, routes work, build passes</done>
</task>

## Success Criteria
- [ ] Routine templates follow ARCHITECTURE.md schema exactly
- [ ] Tasks can be assigned to family members
- [ ] Daily completion tracking works (check/uncheck)
- [ ] flutter build web passes with 0 errors
