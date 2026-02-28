import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/event_model.dart';
import '../providers/schedule_providers.dart';

/// Displays events for a pet, split into Upcoming and Recurring tabs.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(petEventsProvider(petId));

    return Scaffold(
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (events) {
          final upcoming = events.where((e) => e.isOneTime).toList()
            ..sort(
              (a, b) => (a.oneTimeDate ?? DateTime.now()).compareTo(
                b.oneTimeDate ?? DateTime.now(),
              ),
            );
          final recurring = events.where((e) => e.isCyclic).toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Upcoming (${upcoming.length})'),
                    Tab(text: 'Recurring (${recurring.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _EventList(
                        events: upcoming,
                        emptyMessage: 'No upcoming events',
                        petId: petId,
                      ),
                      _EventList(
                        events: recurring,
                        emptyMessage: 'No recurring events',
                        petId: petId,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/pets/$petId/events/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Event'),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.events,
    required this.emptyMessage,
    required this.petId,
  });

  final List<Event> events;
  final String emptyMessage;
  final String petId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(emptyMessage, style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _EventCard(event: event, petId: petId);
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.petId});

  final Event event;
  final String petId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Determine subtitle
    String subtitle;
    bool isOverdue = false;

    if (event.isOneTime && event.oneTimeDate != null) {
      subtitle = DateFormat('MMM d, y · h:mm a').format(event.oneTimeDate!);
      isOverdue = event.oneTimeDate!.isBefore(now);
    } else if (event.schedule != null) {
      subtitle = event.schedule!.displaySummary;
    } else {
      subtitle = event.type.displayName;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.go('/pets/$petId/events/${event.id}'),
        leading: CircleAvatar(
          backgroundColor: isOverdue
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          child: Icon(
            event.type.icon,
            color: isOverdue
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(event.title, style: theme.textTheme.titleSmall),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverdue
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: event.assignedTo != null
            ? Chip(
                label: const Text('Assigned'),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )
            : null,
      ),
    );
  }
}
