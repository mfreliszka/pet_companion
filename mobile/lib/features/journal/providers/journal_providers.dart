import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry_model.dart';
import '../services/journal_service.dart';

/// Singleton provider for [JournalService].
final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService();
});

/// Stream all journal entries for a pet (most recent first).
final journalEntriesProvider =
    StreamProvider.family<List<JournalEntry>, String>((ref, petId) {
      final service = ref.watch(journalServiceProvider);
      return service.streamEntries(petId);
    });

/// Stream journal entries for a pet filtered by type.
/// Parameter is a record: (petId, typeFilter).
final filteredJournalEntriesProvider =
    StreamProvider.family<List<JournalEntry>, (String, JournalEntryType?)>((
      ref,
      params,
    ) {
      final (petId, typeFilter) = params;
      final service = ref.watch(journalServiceProvider);
      return service.streamEntries(petId, typeFilter: typeFilter);
    });
