import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../models/routine_template_model.dart';
import '../providers/schedule_providers.dart';

/// Care schedule calendar view — shows events and routines for a selected day.
class CareCalendarScreen extends ConsumerStatefulWidget {
  const CareCalendarScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<CareCalendarScreen> createState() => _CareCalendarScreenState();
}

class _CareCalendarScreenState extends ConsumerState<CareCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(familyEventsProvider(widget.familyId));
    final routinesAsync = ref.watch(familyRoutinesProvider(widget.familyId));

    return Scaffold(
      body: Column(
        children: [
          // ── Month Header ──
          _buildMonthHeader(theme),

          // ── Day Grid ──
          _buildDayGrid(theme),

          const Divider(height: 1),

          // ── Selected Day Content ──
          Expanded(child: _buildDayContent(theme, eventsAsync, routinesAsync)),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildDayGrid(ThemeData theme) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstWeekday = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    ).weekday; // 1=Mon, 7=Sun
    final today = DateTime.now();

    // Day-of-week labels
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: dayLabels
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 4),

        // Calendar grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: daysInMonth + firstWeekday - 1,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox(); // Empty slot
              }
              final day = index - firstWeekday + 2;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, today);

              return InkWell(
                onTap: () => setState(() => _selectedDate = date),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isToday
                        ? theme.colorScheme.primaryContainer
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isToday
                          ? theme.colorScheme.primary
                          : null,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w600
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDayContent(
    ThemeData theme,
    AsyncValue<List<Event>> eventsAsync,
    AsyncValue<List<RoutineTemplate>> routinesAsync,
  ) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isToday ? 'Today' : DateFormat('EEEE, MMM d').format(_selectedDate),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),

        // ── One-time events for this day ──
        eventsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (events) {
            final dayEvents = events.where((e) {
              if (e.isCyclic) return false;
              if (e.oneTimeDate == null) return false;
              return _isSameDay(e.oneTimeDate!, _selectedDate);
            }).toList();

            if (dayEvents.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Events',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                ...dayEvents.map(
                  (event) => Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          event.type.icon,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        event.title,
                        style: theme.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        event.type.displayName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),

        // ── Routines for this day ──
        routinesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (routines) {
            if (routines.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No routines to show',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Routines',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                ...routines.map((routine) {
                  final logKey = '${routine.id}|$dateStr';
                  final logAsync = ref.watch(dailyLogProvider(logKey));

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                routine.timeOfDay.icon,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                routine.name,
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          logAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (log) {
                              final completed = routine.tasks
                                  .where((t) => log.isTaskCompleted(t.id))
                                  .length;
                              final total = routine.tasks.length;
                              final progress = total > 0
                                  ? completed / total
                                  : 0.0;

                              return Column(
                                children: [
                                  LinearProgressIndicator(
                                    value: progress,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$completed / $total completed',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
