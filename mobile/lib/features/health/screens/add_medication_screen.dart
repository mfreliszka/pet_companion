import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/medication_model.dart';
import '../providers/health_providers.dart';

/// Form screen to add a new medication.
class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  MedicationFrequency _frequency = MedicationFrequency.daily;
  final List<String> _scheduledTimes = [];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Dosage
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage (e.g. "10mg" or "1 tablet")',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Frequency
            Text('Frequency', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MedicationFrequency.values.map((f) {
                return ChoiceChip(
                  label: Text(f.displayName),
                  selected: _frequency == f,
                  onSelected: (_) => setState(() => _frequency = f),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Scheduled times
            Text('Scheduled Times', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._scheduledTimes.map((time) {
                  return Chip(
                    label: Text(time),
                    onDeleted: () {
                      setState(() => _scheduledTimes.remove(time));
                    },
                  );
                }),
                ActionChip(
                  label: const Text('+ Add Time'),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (picked != null) {
                      setState(() {
                        _scheduledTimes.add(picked.format(context));
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Start date
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _startDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text('Start: ${dateFormat.format(_startDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // End date (optional)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate,
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _endDate = picked);
                      }
                    },
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: Text(
                      _endDate != null
                          ? 'End: ${dateFormat.format(_endDate!)}'
                          : 'End Date (optional)',
                    ),
                  ),
                ),
                if (_endDate != null)
                  IconButton(
                    onPressed: () => setState(() => _endDate = null),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Clear end date',
                  ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a medication name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final medication = Medication(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.isEmpty
            ? null
            : _dosageController.text.trim(),
        frequency: _frequency,
        scheduledTimes: _scheduledTimes,
        startDate: _startDate,
        endDate: _endDate,
        createdBy: user.uid,
      );

      await ref
          .read(medicationServiceProvider)
          .createMedication(widget.petId, medication);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication added'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
