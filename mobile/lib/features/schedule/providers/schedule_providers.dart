import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_model.dart';
import '../models/event_completion_model.dart';
import '../models/routine_template_model.dart';
import '../services/event_service.dart';
import '../services/routine_service.dart';

// ── Event Providers ─────────────────────────────────────────────

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

/// Stream all active events for a family.
final familyEventsProvider = StreamProvider.family<List<Event>, String>((
  ref,
  familyId,
) {
  return ref.watch(eventServiceProvider).streamFamilyEvents(familyId);
});

/// Stream all active events for a specific pet.
final petEventsProvider = StreamProvider.family<List<Event>, String>((
  ref,
  petId,
) {
  return ref.watch(eventServiceProvider).streamPetEvents(petId);
});

/// Stream completions for an event.
final eventCompletionsProvider =
    StreamProvider.family<List<EventCompletion>, String>((ref, eventId) {
      return ref.watch(eventServiceProvider).streamCompletions(eventId);
    });

// ── Routine Providers ───────────────────────────────────────────

final routineServiceProvider = Provider<RoutineService>((ref) {
  return RoutineService();
});

/// Stream all active routine templates for a family.
final familyRoutinesProvider =
    StreamProvider.family<List<RoutineTemplate>, String>((ref, familyId) {
      return ref.watch(routineServiceProvider).streamFamilyRoutines(familyId);
    });

/// Parameterized by "templateId|dateString".
final dailyLogProvider = StreamProvider.family<DailyLog, String>((ref, key) {
  final parts = key.split('|');
  final templateId = parts[0];
  final dateString = parts.length > 1 ? parts[1] : '';
  return ref
      .watch(routineServiceProvider)
      .streamDailyLog(templateId, dateString);
});
