import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/event_model.dart';
import '../providers/schedule_providers.dart';

/// Screen for creating a new event (one-time or cyclic).
class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({
    super.key,
    required this.petId,
    required this.familyId,
  });

  final String petId;
  final String familyId;

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  EventType _selectedType = EventType.feeding;
  bool _isCyclic = false;
  int _reminderMinutes = 5;

  // One-time fields
  DateTime _oneTimeDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _oneTimeTime = TimeOfDay.now();

  // Cyclic fields
  List<String> _scheduleTimes = ['08:00'];
  List<int>? _selectedDays;
  DateTime _startDate = DateTime.now();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Title ──
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title *',
                hintText: 'e.g. Morning Feeding',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // ── Type ──
            Text('Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: EventType.values.map((type) {
                return ChoiceChip(
                  selected: _selectedType == type,
                  onSelected: (_) => setState(() => _selectedType = type),
                  avatar: Icon(type.icon, size: 18),
                  label: Text(type.displayName),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Description ──
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // ── One-time vs Cyclic ──
            SwitchListTile(
              title: const Text('Recurring Event'),
              subtitle: Text(
                _isCyclic
                    ? 'Repeats on a schedule'
                    : 'Happens once at a specific time',
              ),
              value: _isCyclic,
              onChanged: (v) => setState(() => _isCyclic = v),
            ),
            const SizedBox(height: 16),

            if (!_isCyclic) ..._buildOneTimeFields(theme),
            if (_isCyclic) ..._buildCyclicFields(theme),

            const SizedBox(height: 16),

            // ── Reminder ──
            Text('Reminder', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('None')),
                ButtonSegment(value: 5, label: Text('5m')),
                ButtonSegment(value: 15, label: Text('15m')),
                ButtonSegment(value: 30, label: Text('30m')),
                ButtonSegment(value: 60, label: Text('1h')),
              ],
              selected: {_reminderMinutes},
              onSelectionChanged: (s) =>
                  setState(() => _reminderMinutes = s.first),
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOneTimeFields(ThemeData theme) {
    return [
      Text('Date & Time', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _oneTimeDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (date != null) setState(() => _oneTimeDate = date);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                '${_oneTimeDate.day}/${_oneTimeDate.month}/${_oneTimeDate.year}',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _oneTimeTime,
                );
                if (time != null) setState(() => _oneTimeTime = time);
              },
              icon: const Icon(Icons.access_time_rounded, size: 18),
              label: Text(_oneTimeTime.format(context)),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildCyclicFields(ThemeData theme) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return [
      Text('Schedule Times', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          ..._scheduleTimes.asMap().entries.map((entry) {
            return Chip(
              label: Text(entry.value),
              onDeleted: _scheduleTimes.length > 1
                  ? () => setState(() => _scheduleTimes.removeAt(entry.key))
                  : null,
            );
          }),
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: const Text('Add Time'),
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _scheduleTimes.add(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  );
                });
              }
            },
          ),
        ],
      ),
      const SizedBox(height: 16),

      Text('Repeat On', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 4,
        children: List.generate(7, (i) {
          final day = i + 1;
          final isSelected = _selectedDays?.contains(day) ?? false;
          return FilterChip(
            selected: isSelected,
            label: Text(dayNames[i]),
            onSelected: (selected) {
              setState(() {
                _selectedDays ??= [];
                if (selected) {
                  _selectedDays!.add(day);
                } else {
                  _selectedDays!.remove(day);
                }
                if (_selectedDays!.isEmpty) _selectedDays = null;
              });
            },
          );
        }),
      ),
      const SizedBox(height: 8),
      Text(
        _selectedDays == null ? 'No days selected = Daily' : '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      final now = DateTime.now();

      DateTime? oneTimeDate;
      EventSchedule? schedule;

      if (_isCyclic) {
        schedule = EventSchedule(
          times: _scheduleTimes,
          daysOfWeek: _selectedDays,
          startDate: _startDate,
        );
      } else {
        oneTimeDate = DateTime(
          _oneTimeDate.year,
          _oneTimeDate.month,
          _oneTimeDate.day,
          _oneTimeTime.hour,
          _oneTimeTime.minute,
        );
      }

      final event = Event(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        petId: widget.petId,
        familyId: widget.familyId,
        type: _selectedType,
        isCyclic: _isCyclic,
        schedule: schedule,
        oneTimeDate: oneTimeDate,
        createdBy: user!.uid,
        isActive: true,
        reminderMinutesBefore: _reminderMinutes,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(eventServiceProvider).addEvent(event);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
