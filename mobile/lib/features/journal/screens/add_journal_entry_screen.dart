import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/journal_entry_model.dart';
import '../providers/journal_providers.dart';

/// Screen for creating a new journal entry.
///
/// Step 1: Select entry type.
/// Step 2: Fill in type-specific form fields + common fields.
class AddJournalEntryScreen extends ConsumerStatefulWidget {
  const AddJournalEntryScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<AddJournalEntryScreen> createState() =>
      _AddJournalEntryScreenState();
}

class _AddJournalEntryScreenState extends ConsumerState<AddJournalEntryScreen> {
  JournalEntryType? _selectedType;
  bool _isSaving = false;
  DateTime _timestamp = DateTime.now();

  // Common fields
  final _notesController = TextEditingController();

  // Mood fields
  MoodLevel _mood = MoodLevel.happy;
  int _moodScale = 3;

  // Symptom fields
  final Set<String> _selectedSymptoms = {};
  SymptomSeverity _severity = SymptomSeverity.mild;

  // Appetite fields
  AppetiteLevel _appetiteLevel = AppetiteLevel.ateWell;
  final _foodTypeController = TextEditingController();
  final _amountController = TextEditingController();

  // Energy fields
  EnergyLevel _energyLevel = EnergyLevel.normal;

  // Weight fields
  final _weightController = TextEditingController();
  String _weightUnit = 'kg';

  // Behavior fields
  BehaviorIncident _behaviorIncident = BehaviorIncident.other;
  final _behaviorContextController = TextEditingController();

  // Medication fields
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  bool _administered = true;

  // Care record fields
  final _veterinarianController = TextEditingController();
  final _clinicController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _costController = TextEditingController();

  // Walk fields
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();

  // Grooming fields
  GroomingType _groomingType = GroomingType.bath;

  @override
  void dispose() {
    _notesController.dispose();
    _foodTypeController.dispose();
    _amountController.dispose();
    _weightController.dispose();
    _behaviorContextController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _veterinarianController.dispose();
    _clinicController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _costController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedType == null
              ? 'New Journal Entry'
              : _selectedType!.displayName,
        ),
        actions: [
          if (_selectedType != null)
            TextButton(
              onPressed: _isSaving ? null : _saveEntry,
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
      body: _selectedType == null
          ? _buildTypeSelector(theme)
          : _buildEntryForm(theme),
    );
  }

  // ── Type Selector (Step 1) ────────────────────────────────────

  Widget _buildTypeSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to log?',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: JournalEntryType.values.length,
              itemBuilder: (context, index) {
                final type = JournalEntryType.values[index];
                return _TypeCard(
                  type: type,
                  onTap: () => setState(() => _selectedType = type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Entry Form (Step 2) ───────────────────────────────────────

  Widget _buildEntryForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp selector
          _DateTimePicker(
            timestamp: _timestamp,
            onChanged: (dt) => setState(() => _timestamp = dt),
          ),
          const SizedBox(height: 16),

          // Type-specific fields
          ..._buildTypeSpecificFields(theme),

          const SizedBox(height: 16),

          // Common notes field
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

          const SizedBox(height: 80), // Space for FAB/save button
        ],
      ),
    );
  }

  List<Widget> _buildTypeSpecificFields(ThemeData theme) {
    return switch (_selectedType!) {
      JournalEntryType.mood => _buildMoodFields(theme),
      JournalEntryType.symptom => _buildSymptomFields(theme),
      JournalEntryType.appetite => _buildAppetiteFields(theme),
      JournalEntryType.energy => _buildEnergyFields(theme),
      JournalEntryType.weight => _buildWeightFields(theme),
      JournalEntryType.behavior => _buildBehaviorFields(theme),
      JournalEntryType.note => [],
      JournalEntryType.medication => _buildMedicationFields(theme),
      JournalEntryType.careRecord => _buildCareRecordFields(theme),
      JournalEntryType.walk => _buildWalkFields(theme),
      JournalEntryType.grooming => _buildGroomingFields(theme),
    };
  }

  // ── Mood ──────────────────────────────────────────────────────

  List<Widget> _buildMoodFields(ThemeData theme) {
    return [
      Text('How is your pet feeling?', style: theme.textTheme.titleSmall),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: MoodLevel.values.map((mood) {
          final selected = _mood == mood;
          return ChoiceChip(
            label: Text('${mood.emoji} ${mood.displayName}'),
            selected: selected,
            onSelected: (_) => setState(() => _mood = mood),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      Text('Intensity (1-5)', style: theme.textTheme.titleSmall),
      Slider(
        value: _moodScale.toDouble(),
        min: 1,
        max: 5,
        divisions: 4,
        label: _moodScale.toString(),
        onChanged: (v) => setState(() => _moodScale = v.round()),
      ),
    ];
  }

  // ── Symptom ───────────────────────────────────────────────────

  List<Widget> _buildSymptomFields(ThemeData theme) {
    return [
      Text('Select symptoms', style: theme.textTheme.titleSmall),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: SymptomOptions.all.map((symptom) {
          final selected = _selectedSymptoms.contains(symptom);
          return FilterChip(
            label: Text(SymptomOptions.displayName(symptom)),
            selected: selected,
            onSelected: (sel) => setState(() {
              if (sel) {
                _selectedSymptoms.add(symptom);
              } else {
                _selectedSymptoms.remove(symptom);
              }
            }),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      Text('Severity', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      SegmentedButton<SymptomSeverity>(
        segments: SymptomSeverity.values
            .map((s) => ButtonSegment(value: s, label: Text(s.displayName)))
            .toList(),
        selected: {_severity},
        onSelectionChanged: (v) => setState(() => _severity = v.first),
      ),
    ];
  }

  // ── Appetite ──────────────────────────────────────────────────

  List<Widget> _buildAppetiteFields(ThemeData theme) {
    return [
      Text('How did they eat?', style: theme.textTheme.titleSmall),
      const SizedBox(height: 12),
      SegmentedButton<AppetiteLevel>(
        segments: AppetiteLevel.values
            .map(
              (a) => ButtonSegment(
                value: a,
                label: Text(a.displayName),
                icon: Icon(a.icon),
              ),
            )
            .toList(),
        selected: {_appetiteLevel},
        onSelectionChanged: (v) => setState(() => _appetiteLevel = v.first),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _foodTypeController,
        decoration: const InputDecoration(
          labelText: 'Food type (optional)',
          border: OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _amountController,
        decoration: const InputDecoration(
          labelText: 'Amount (optional)',
          border: OutlineInputBorder(),
        ),
      ),
    ];
  }

  // ── Energy ────────────────────────────────────────────────────

  List<Widget> _buildEnergyFields(ThemeData theme) {
    return [
      Text('Energy level', style: theme.textTheme.titleSmall),
      const SizedBox(height: 12),
      SegmentedButton<EnergyLevel>(
        segments: EnergyLevel.values
            .map(
              (e) => ButtonSegment(
                value: e,
                label: Text(e.displayName),
                icon: Icon(e.icon),
              ),
            )
            .toList(),
        selected: {_energyLevel},
        onSelectionChanged: (v) => setState(() => _energyLevel = v.first),
      ),
    ];
  }

  // ── Weight ────────────────────────────────────────────────────

  List<Widget> _buildWeightFields(ThemeData theme) {
    return [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'kg', label: Text('kg')),
              ButtonSegment(value: 'lbs', label: Text('lbs')),
            ],
            selected: {_weightUnit},
            onSelectionChanged: (v) => setState(() => _weightUnit = v.first),
          ),
        ],
      ),
    ];
  }

  // ── Behavior ──────────────────────────────────────────────────

  List<Widget> _buildBehaviorFields(ThemeData theme) {
    return [
      Text('Incident type', style: theme.textTheme.titleSmall),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: BehaviorIncident.values.map((b) {
          return ChoiceChip(
            label: Text(b.displayName),
            selected: _behaviorIncident == b,
            onSelected: (_) => setState(() => _behaviorIncident = b),
          );
        }).toList(),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _behaviorContextController,
        decoration: const InputDecoration(
          labelText: 'Context / details (optional)',
          border: OutlineInputBorder(),
        ),
        maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
      ),
    ];
  }

  // ── Medication ────────────────────────────────────────────────

  List<Widget> _buildMedicationFields(ThemeData theme) {
    return [
      TextField(
        controller: _medicationNameController,
        decoration: const InputDecoration(
          labelText: 'Medication name *',
          border: OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.words,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _dosageController,
        decoration: const InputDecoration(
          labelText: 'Dosage (optional)',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      SwitchListTile(
        title: const Text('Administered'),
        subtitle: const Text('Was the medication given?'),
        value: _administered,
        onChanged: (v) => setState(() => _administered = v),
        contentPadding: EdgeInsets.zero,
      ),
    ];
  }

  // ── Care Record ───────────────────────────────────────────────

  List<Widget> _buildCareRecordFields(ThemeData theme) {
    return [
      TextField(
        controller: _veterinarianController,
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      ),
    ];
  }

  // ── Walk ──────────────────────────────────────────────────────

  List<Widget> _buildWalkFields(ThemeData theme) {
    return [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _distanceController,
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // ── Grooming ──────────────────────────────────────────────────

  List<Widget> _buildGroomingFields(ThemeData theme) {
    return [
      Text('Grooming type', style: theme.textTheme.titleSmall),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: GroomingType.values.map((g) {
          return ChoiceChip(
            label: Text(g.displayName),
            selected: _groomingType == g,
            onSelected: (_) => setState(() => _groomingType = g),
          );
        }).toList(),
      ),
    ];
  }

  // ── Save ──────────────────────────────────────────────────────

  Future<void> _saveEntry() async {
    if (_selectedType == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Build type-specific data map
    final data = _buildDataMap();

    // Validate required fields
    if (!_validateFields()) return;

    setState(() => _isSaving = true);

    try {
      final entry = JournalEntry(
        type: _selectedType!,
        timestamp: _timestamp,
        createdBy: user.uid,
        createdByName: user.displayName ?? 'Unknown',
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        data: data,
      );

      await ref.read(journalServiceProvider).createEntry(widget.petId, entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedType!.displayName} entry saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, dynamic> _buildDataMap() {
    return switch (_selectedType!) {
      JournalEntryType.mood => {'mood': _mood.name, 'scale': _moodScale},
      JournalEntryType.symptom => {
        'symptoms': _selectedSymptoms.toList(),
        'severity': _severity.name,
      },
      JournalEntryType.appetite => {
        'level': _appetiteLevel.firestoreValue,
        'foodType': _foodTypeController.text.isEmpty
            ? null
            : _foodTypeController.text,
        'amount': _amountController.text.isEmpty
            ? null
            : _amountController.text,
      },
      JournalEntryType.energy => {'level': _energyLevel.name},
      JournalEntryType.weight => {
        'weightKg': double.tryParse(_weightController.text) ?? 0,
        'unit': _weightUnit,
      },
      JournalEntryType.behavior => {
        'incident': _behaviorIncident.name,
        'context': _behaviorContextController.text.isEmpty
            ? null
            : _behaviorContextController.text,
      },
      JournalEntryType.note => <String, dynamic>{},
      JournalEntryType.medication => {
        'medicationName': _medicationNameController.text,
        'dosage': _dosageController.text.isEmpty
            ? null
            : _dosageController.text,
        'administered': _administered,
      },
      JournalEntryType.careRecord => {
        'veterinarian': _veterinarianController.text.isEmpty
            ? null
            : _veterinarianController.text,
        'clinic': _clinicController.text.isEmpty
            ? null
            : _clinicController.text,
        'diagnosis': _diagnosisController.text.isEmpty
            ? null
            : _diagnosisController.text,
        'treatment': _treatmentController.text.isEmpty
            ? null
            : _treatmentController.text,
        'cost': double.tryParse(_costController.text),
      },
      JournalEntryType.walk => {
        'durationMinutes': int.tryParse(_durationController.text),
        'distanceKm': double.tryParse(_distanceController.text),
      },
      JournalEntryType.grooming => {'grooming_type': _groomingType.name},
    };
  }

  bool _validateFields() {
    switch (_selectedType!) {
      case JournalEntryType.symptom:
        if (_selectedSymptoms.isEmpty) {
          _showValidationError('Please select at least one symptom');
          return false;
        }
      case JournalEntryType.weight:
        if (_weightController.text.isEmpty ||
            double.tryParse(_weightController.text) == null) {
          _showValidationError('Please enter a valid weight');
          return false;
        }
      case JournalEntryType.medication:
        if (_medicationNameController.text.isEmpty) {
          _showValidationError('Please enter a medication name');
          return false;
        }
      default:
        break;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ── Type Selection Card ─────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type, required this.onTap});

  final JournalEntryType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: type.color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                type.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Date Time Picker ────────────────────────────────────────────

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({required this.timestamp, required this.onChanged});

  final DateTime timestamp;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: timestamp,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                onChanged(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    timestamp.hour,
                    timestamp.minute,
                  ),
                );
              }
            },
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(dateFormat.format(timestamp)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(timestamp),
              );
              if (time != null) {
                onChanged(
                  DateTime(
                    timestamp.year,
                    timestamp.month,
                    timestamp.day,
                    time.hour,
                    time.minute,
                  ),
                );
              }
            },
            icon: const Icon(Icons.access_time_rounded, size: 18),
            label: Text(timeFormat.format(timestamp)),
          ),
        ),
      ],
    );
  }
}
