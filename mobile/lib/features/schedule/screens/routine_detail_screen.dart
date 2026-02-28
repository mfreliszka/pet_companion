import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/routine_template_model.dart';
import '../providers/schedule_providers.dart';

/// Detail screen showing today's task checklist for a routine template.
class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Find the routine from family routines — we need to get familyId from somewhere.
    // We'll use a query approach: watch all routines (the user must have at least one family).
    // For simplicity, we search across the list.

    return Scaffold(
      appBar: AppBar(title: const Text('Routine')),
      body: _RoutineDetailBody(routineId: routineId, dateString: today),
    );
  }
}

class _RoutineDetailBody extends ConsumerStatefulWidget {
  const _RoutineDetailBody({required this.routineId, required this.dateString});

  final String routineId;
  final String dateString;

  @override
  ConsumerState<_RoutineDetailBody> createState() => _RoutineDetailBodyState();
}

class _RoutineDetailBodyState extends ConsumerState<_RoutineDetailBody> {
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.dateString;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dailyLogAsync = ref.watch(
      dailyLogProvider('${widget.routineId}|$_selectedDate'),
    );

    return FutureBuilder<RoutineTemplate?>(
      future: _fetchRoutine(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final routine = snapshot.data;
        if (routine == null) {
          return const Center(child: Text('Routine not found'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Routine Header ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        routine.timeOfDay.icon,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(routine.name, style: theme.textTheme.titleLarge),
                          Text(
                            '${routine.timeOfDay.displayName} · ${routine.tasks.length} tasks',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Date Selector ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    final date = DateTime.parse(_selectedDate);
                    setState(() {
                      _selectedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(date.subtract(const Duration(days: 1)));
                    });
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(_selectedDate),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = DateFormat('yyyy-MM-dd').format(date);
                      });
                    }
                  },
                  child: Text(
                    _selectedDate == widget.dateString
                        ? 'Today'
                        : DateFormat(
                            'MMM d, y',
                          ).format(DateTime.parse(_selectedDate)),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: _selectedDate == widget.dateString
                      ? null
                      : () {
                          final date = DateTime.parse(_selectedDate);
                          setState(() {
                            _selectedDate = DateFormat(
                              'yyyy-MM-dd',
                            ).format(date.add(const Duration(days: 1)));
                          });
                        },
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Task Checklist ──
            dailyLogAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (dailyLog) {
                return Column(
                  children: routine.tasks.map((task) {
                    final isCompleted = dailyLog.isTaskCompleted(task.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: CheckboxListTile(
                        value: isCompleted,
                        onChanged: (checked) =>
                            _toggleTask(task.id, checked ?? false),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        subtitle: isCompleted
                            ? Text(
                                'Completed',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : task.assignedTo != null
                            ? Text('Assigned', style: theme.textTheme.bodySmall)
                            : null,
                        secondary: Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<RoutineTemplate?> _fetchRoutine() async {
    return ref.read(routineServiceProvider).getTemplate(widget.routineId);
  }

  Future<void> _toggleTask(String taskId, bool complete) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final service = ref.read(routineServiceProvider);
      if (complete) {
        await service.markTaskComplete(
          widget.routineId,
          _selectedDate,
          taskId,
          user.uid,
        );
      } else {
        await service.unmarkTaskComplete(
          widget.routineId,
          _selectedDate,
          taskId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
