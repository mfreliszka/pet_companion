import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/medical_record_model.dart';
import '../providers/health_providers.dart';

/// Form to add a new medical record.
class AddMedicalRecordScreen extends ConsumerStatefulWidget {
  const AddMedicalRecordScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<AddMedicalRecordScreen> createState() =>
      _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState
    extends ConsumerState<AddMedicalRecordScreen> {
  final _titleController = TextEditingController();
  final _vetController = TextEditingController();
  final _clinicController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();
  MedicalRecordType _type = MedicalRecordType.vetVisit;
  DateTime _date = DateTime.now();
  DateTime? _nextFollowUp;
  final List<String> _tags = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _vetController.dispose();
    _clinicController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medical Record'),
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Type selector
            Text('Record Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MedicalRecordType.values.map((t) {
                return ChoiceChip(
                  avatar: Icon(t.icon, size: 18),
                  label: Text(t.displayName),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Date
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text('Date: ${dateFormat.format(_date)}'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _vetController,
              decoration: const InputDecoration(
                labelText: 'Veterinarian (optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clinicController,
              decoration: const InputDecoration(
                labelText: 'Clinic (optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _treatmentController,
              decoration: const InputDecoration(
                labelText: 'Treatment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost (optional)',
                prefixText: 'PLN ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
            const SizedBox(height: 16),

            // Next follow-up
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _nextFollowUp ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _nextFollowUp = picked);
                      }
                    },
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: Text(
                      _nextFollowUp != null
                          ? 'Follow-up: ${dateFormat.format(_nextFollowUp!)}'
                          : 'Next Follow-up (optional)',
                    ),
                  ),
                ),
                if (_nextFollowUp != null)
                  IconButton(
                    onPressed: () => setState(() => _nextFollowUp = null),
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Tags
            Text('Tags', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._tags.map(
                  (tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add tag',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          _tags.add(value.trim());
                          _tagController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final record = MedicalRecord(
        title: _titleController.text.trim(),
        type: _type,
        date: _date,
        veterinarian: _vetController.text.isEmpty
            ? null
            : _vetController.text.trim(),
        clinic: _clinicController.text.isEmpty
            ? null
            : _clinicController.text.trim(),
        diagnosis: _diagnosisController.text.isEmpty
            ? null
            : _diagnosisController.text.trim(),
        treatment: _treatmentController.text.isEmpty
            ? null
            : _treatmentController.text.trim(),
        cost: double.tryParse(_costController.text),
        nextFollowUp: _nextFollowUp,
        tags: _tags,
        notes: _notesController.text.isEmpty
            ? null
            : _notesController.text.trim(),
        createdBy: user.uid,
      );

      await ref
          .read(medicalRecordServiceProvider)
          .createRecord(widget.petId, record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record added'),
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
