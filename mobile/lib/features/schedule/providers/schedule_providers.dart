import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_model.dart';
import '../models/event_completion_model.dart';
import '../services/event_service.dart';

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
