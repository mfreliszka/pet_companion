import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/event_model.dart';
import '../models/event_completion_model.dart';
import '../providers/schedule_providers.dart';

/// Detail screen for a single event — shows info, allows completion, shows history.
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({
    super.key,
    required this.petId,
    required this.eventId,
  });

  final String petId;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(petEventsProvider(petId));
    final completionsAsync = ref.watch(eventCompletionsProvider(eventId));
    final theme = Theme.of(context);

    return eventsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (events) {
        final event = events.where((e) => e.id == eventId).firstOrNull;
        if (event == null) {
          return Scaffold(
            body: Center(
              child: Text('Event not found', style: theme.textTheme.bodyLarge),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(event.title),
            actions: [
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'deactivate') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Deactivate Event?'),
                        content: const Text(
                          'This event will no longer appear in your schedule.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Deactivate'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await ref
                          .read(eventServiceProvider)
                          .deactivateEvent(eventId);
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Text('Deactivate'),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Event Info Card ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              event.type.icon,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.type.displayName,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  event.title,
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (event.description != null) ...[
                        const SizedBox(height: 12),
                        Text(event.description!),
                      ],
                      const Divider(height: 24),

                      // Schedule info
                      if (event.isOneTime && event.oneTimeDate != null)
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date',
                          value: DateFormat(
                            'EEEE, MMM d, y · h:mm a',
                          ).format(event.oneTimeDate!),
                        ),
                      if (event.isCyclic && event.schedule != null)
                        _InfoRow(
                          icon: Icons.repeat_rounded,
                          label: 'Schedule',
                          value: event.schedule!.displaySummary,
                        ),
                      _InfoRow(
                        icon: Icons.notifications_rounded,
                        label: 'Reminder',
                        value: event.reminderMinutesBefore == 0
                            ? 'None'
                            : '${event.reminderMinutesBefore} min before',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Mark Complete Button ──
              FilledButton.icon(
                onPressed: () => _completeEvent(context, ref, event),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Mark as Completed'),
              ),
              const SizedBox(height: 24),

              // ── Completion History ──
              Text('Completion History', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              completionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (completions) {
                  if (completions.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No completions yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: completions.map((c) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(c.completedByName),
                          subtitle: Text(
                            DateFormat(
                              'MMM d, y · h:mm a',
                            ).format(c.completedAt),
                          ),
                          trailing: c.notes != null
                              ? Tooltip(
                                  message: c.notes!,
                                  child: const Icon(Icons.notes_rounded),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeEvent(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final completion = EventCompletion(
      id: '',
      scheduledAt: event.oneTimeDate ?? DateTime.now(),
      completedAt: DateTime.now(),
      completedBy: user.uid,
      completedByName: user.displayName ?? 'Unknown',
    );

    try {
      await ref.read(eventServiceProvider).completeEvent(eventId, completion);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event marked as completed!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
