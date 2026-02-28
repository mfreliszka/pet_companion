import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/vaccination_model.dart';
import '../providers/health_providers.dart';

/// Form to add a new vaccination record.
class AddVaccinationScreen extends ConsumerStatefulWidget {
  const AddVaccinationScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<AddVaccinationScreen> createState() =>
      _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends ConsumerState<AddVaccinationScreen> {
  final _nameController = TextEditingController();
  final _vetController = TextEditingController();
  final _clinicController = TextEditingController();
  final _batchController = TextEditingController();
  DateTime _dateAdministered = DateTime.now();
  DateTime? _nextDueDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _vetController.dispose();
    _clinicController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vaccination'),
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Vaccine Name *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dateAdministered,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _dateAdministered = picked);
                }
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text('Date: ${dateFormat.format(_dateAdministered)}'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _nextDueDate ??
                            DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _nextDueDate = picked);
                      }
                    },
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: Text(
                      _nextDueDate != null
                          ? 'Next Due: ${dateFormat.format(_nextDueDate!)}'
                          : 'Next Due Date (optional)',
                    ),
                  ),
                ),
                if (_nextDueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _nextDueDate = null),
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
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
              controller: _batchController,
              decoration: const InputDecoration(
                labelText: 'Batch Number (optional)',
                border: OutlineInputBorder(),
              ),
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
          content: Text('Please enter a vaccine name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final vac = Vaccination(
        name: _nameController.text.trim(),
        dateAdministered: _dateAdministered,
        nextDueDate: _nextDueDate,
        veterinarian: _vetController.text.isEmpty
            ? null
            : _vetController.text.trim(),
        clinic: _clinicController.text.isEmpty
            ? null
            : _clinicController.text.trim(),
        batchNumber: _batchController.text.isEmpty
            ? null
            : _batchController.text.trim(),
        createdBy: user.uid,
      );

      await ref
          .read(vaccinationServiceProvider)
          .createVaccination(widget.petId, vac);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination added'),
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
