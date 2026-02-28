import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/routine_template_model.dart';
import '../providers/schedule_providers.dart';

/// Displays routine templates for a family, grouped by time-of-day.
class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(familyRoutinesProvider(familyId));
    final theme = Theme.of(context);

    return Scaffold(
      body: routinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (routines) {
          if (routines.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.playlist_add_check_rounded,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text('No routines yet', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Create a routine to organize daily tasks',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          // Group by time-of-day slot
          final grouped = <TimeOfDaySlot, List<RoutineTemplate>>{};
          for (final slot in TimeOfDaySlot.values) {
            final matching = routines
                .where((r) => r.timeOfDay == slot)
                .toList();
            if (matching.isNotEmpty) grouped[slot] = matching;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        entry.key.icon,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map(
                  (routine) =>
                      _RoutineCard(routine: routine, familyId: familyId),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.go('/schedule/routines/add?familyId=$familyId'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Routine'),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine, required this.familyId});

  final RoutineTemplate routine;
  final String familyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.go('/schedule/routines/${routine.id}'),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            routine.timeOfDay.icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(routine.name, style: theme.textTheme.titleSmall),
        subtitle: Text(
          '${routine.tasks.length} task${routine.tasks.length == 1 ? '' : 's'}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
