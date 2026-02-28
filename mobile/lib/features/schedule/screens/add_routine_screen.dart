import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/routine_template_model.dart';
import '../providers/schedule_providers.dart';

/// Screen for creating a new routine template with tasks.
class AddRoutineScreen extends ConsumerStatefulWidget {
  const AddRoutineScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends ConsumerState<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taskController = TextEditingController();

  TimeOfDaySlot _timeOfDay = TimeOfDaySlot.morning;
  final List<RoutineTask> _tasks = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Routine')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Name ──
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Routine Name *',
                hintText: 'e.g. Morning Care',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // ── Time of Day ──
            Text('Time of Day', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<TimeOfDaySlot>(
              segments: TimeOfDaySlot.values
                  .map(
                    (slot) => ButtonSegment(
                      value: slot,
                      label: Text(slot.displayName),
                      icon: Icon(slot.icon, size: 18),
                    ),
                  )
                  .toList(),
              selected: {_timeOfDay},
              onSelectionChanged: (s) => setState(() => _timeOfDay = s.first),
            ),
            const SizedBox(height: 24),

            // ── Tasks ──
            Text('Tasks', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),

            if (_tasks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No tasks added yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tasks.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _tasks.removeAt(oldIndex);
                    _tasks.insert(newIndex, item);
                    // Re-order
                    for (var i = 0; i < _tasks.length; i++) {
                      _tasks[i] = _tasks[i].copyWith(order: i);
                    }
                  });
                },
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    key: ValueKey(task.id),
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle_rounded),
                      ),
                      title: Text(task.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() => _tasks.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),

            // Add task input
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'New task title',
                      isDense: true,
                    ),
                    onFieldSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            FilledButton.icon(
              onPressed: _isSubmitting || _tasks.isEmpty ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Create Routine'),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _tasks.add(
        RoutineTask(id: const Uuid().v4(), title: title, order: _tasks.length),
      );
      _taskController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tasks.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      final now = DateTime.now();

      final template = RoutineTemplate(
        id: '',
        familyId: widget.familyId,
        name: _nameController.text.trim(),
        timeOfDay: _timeOfDay,
        tasks: _tasks,
        isActive: true,
        createdBy: user!.uid,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(routineServiceProvider).addTemplate(template);
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
