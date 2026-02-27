import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../core/widgets/loading/loading_spinner.dart';
import '../models/pet_model.dart';
import '../providers/pet_providers.dart';
import 'pets_list_screen.dart';

/// Detail screen for a single pet with view/edit/delete.
class PetDetailScreen extends ConsumerStatefulWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends ConsumerState<PetDetailScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  // Edit controllers — initialized once pet loads.
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _microchipIdController;
  late TextEditingController _microchipRegistryController;
  late TextEditingController _microchipContactController;
  PetSpecies? _editSpecies;
  PetGender? _editGender;
  DateTime? _editDateOfBirth;

  bool _controllersInitialized = false;

  void _initControllers(Pet pet) {
    if (_controllersInitialized) return;
    _nameController = TextEditingController(text: pet.name);
    _breedController = TextEditingController(text: pet.breed ?? '');
    _microchipIdController = TextEditingController(text: pet.microchipId ?? '');
    _microchipRegistryController = TextEditingController(
      text: pet.microchipRegistry ?? '',
    );
    _microchipContactController = TextEditingController(
      text: pet.microchipContactInfo ?? '',
    );
    _editSpecies = pet.species;
    _editGender = pet.gender;
    _editDateOfBirth = pet.dateOfBirth;
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    if (_controllersInitialized) {
      _nameController.dispose();
      _breedController.dispose();
      _microchipIdController.dispose();
      _microchipRegistryController.dispose();
      _microchipContactController.dispose();
    }
    super.dispose();
  }

  Future<void> _saveEdits(Pet pet) async {
    setState(() => _isSaving = true);

    try {
      final updates = <String, dynamic>{};

      if (_nameController.text.trim() != pet.name) {
        updates['name'] = _nameController.text.trim();
      }
      if (_editSpecies != pet.species) {
        updates['species'] = _editSpecies!.name;
      }
      final newBreed = _breedController.text.trim();
      if (newBreed != (pet.breed ?? '')) {
        updates['breed'] = newBreed.isEmpty ? null : newBreed;
      }
      if (_editGender != pet.gender) {
        updates['gender'] = _editGender!.name;
      }
      if (_editDateOfBirth != pet.dateOfBirth) {
        updates['dateOfBirth'] = _editDateOfBirth;
      }
      final newChipId = _microchipIdController.text.trim();
      if (newChipId != (pet.microchipId ?? '')) {
        updates['microchipId'] = newChipId.isEmpty ? null : newChipId;
      }
      final newRegistry = _microchipRegistryController.text.trim();
      if (newRegistry != (pet.microchipRegistry ?? '')) {
        updates['microchipRegistry'] = newRegistry.isEmpty ? null : newRegistry;
      }
      final newContact = _microchipContactController.text.trim();
      if (newContact != (pet.microchipContactInfo ?? '')) {
        updates['microchipContactInfo'] = newContact.isEmpty
            ? null
            : newContact;
      }

      if (updates.isNotEmpty) {
        await ref.read(petServiceProvider).updatePet(pet.id!, updates);
      }

      if (mounted) setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deletePet(Pet pet) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${pet.name}?',
      message:
          'This will permanently delete ${pet.name} and all their records. This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(petServiceProvider).deletePet(pet.id!, pet.familyId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petDetailProvider(widget.petId));

    return petAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Pet Details')),
        body: const LoadingSpinner(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Pet Details')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (pet) {
        if (pet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pet Details')),
            body: const Center(child: Text('Pet not found')),
          );
        }

        _initControllers(pet);

        return Scaffold(
          appBar: AppBar(
            title: Text(pet.name),
            actions: [
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isEditing = false),
                )
              else
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => setState(() => _isEditing = true),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') _deletePet(pet);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete Pet'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _isEditing
              ? _EditBody(
                  pet: pet,
                  nameController: _nameController,
                  breedController: _breedController,
                  microchipIdController: _microchipIdController,
                  microchipRegistryController: _microchipRegistryController,
                  microchipContactController: _microchipContactController,
                  species: _editSpecies!,
                  gender: _editGender!,
                  dateOfBirth: _editDateOfBirth,
                  isSaving: _isSaving,
                  onSpeciesChanged: (v) => setState(() => _editSpecies = v),
                  onGenderChanged: (v) => setState(() => _editGender = v),
                  onDateChanged: (v) => setState(() => _editDateOfBirth = v),
                  onSave: () => _saveEdits(pet),
                )
              : _ViewBody(pet: pet),
        );
      },
    );
  }
}

// ── View Body ───────────────────────────────────────────────────

class _ViewBody extends StatelessWidget {
  const _ViewBody({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy');

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // ── Hero section ──
        Center(
          child: Column(
            children: [
              PetAvatar(pet: pet, size: AppSpacing.avatarXxl),
              AppSpacing.verticalGapLg,
              Text(
                pet.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalGapXs,
              Text(
                '${pet.species.displayName}${pet.breed != null ? ' · ${pet.breed}' : ''}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalGapXxl,

        // ── Info section ──
        _InfoSection(
          title: 'Basic Information',
          items: [
            _InfoItem(label: 'Species', value: pet.species.displayName),
            if (pet.breed != null) _InfoItem(label: 'Breed', value: pet.breed!),
            _InfoItem(label: 'Gender', value: pet.gender.displayName),
            if (pet.dateOfBirth != null)
              _InfoItem(
                label: 'Date of Birth',
                value: dateFormat.format(pet.dateOfBirth!),
              ),
            if (pet.currentWeight != null)
              _InfoItem(
                label: 'Weight',
                value: '${pet.currentWeight!.toStringAsFixed(1)} kg',
              ),
          ],
        ),

        if (_hasMicrochipInfo(pet)) ...[
          AppSpacing.verticalGapLg,
          _InfoSection(
            title: 'Microchip',
            items: [
              if (pet.microchipId != null)
                _InfoItem(label: 'ID', value: pet.microchipId!),
              if (pet.microchipRegistry != null)
                _InfoItem(label: 'Registry', value: pet.microchipRegistry!),
              if (pet.microchipContactInfo != null)
                _InfoItem(label: 'Contact', value: pet.microchipContactInfo!),
            ],
          ),
        ],
      ],
    );
  }

  bool _hasMicrochipInfo(Pet pet) {
    return pet.microchipId != null ||
        pet.microchipRegistry != null ||
        pet.microchipContactInfo != null;
  }
}

// ── Edit Body ───────────────────────────────────────────────────

class _EditBody extends StatelessWidget {
  const _EditBody({
    required this.pet,
    required this.nameController,
    required this.breedController,
    required this.microchipIdController,
    required this.microchipRegistryController,
    required this.microchipContactController,
    required this.species,
    required this.gender,
    required this.dateOfBirth,
    required this.isSaving,
    required this.onSpeciesChanged,
    required this.onGenderChanged,
    required this.onDateChanged,
    required this.onSave,
  });

  final Pet pet;
  final TextEditingController nameController;
  final TextEditingController breedController;
  final TextEditingController microchipIdController;
  final TextEditingController microchipRegistryController;
  final TextEditingController microchipContactController;
  final PetSpecies species;
  final PetGender gender;
  final DateTime? dateOfBirth;
  final bool isSaving;
  final ValueChanged<PetSpecies> onSpeciesChanged;
  final ValueChanged<PetGender> onGenderChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.pets),
          ),
        ),
        AppSpacing.verticalGapLg,
        DropdownButtonFormField<PetSpecies>(
          value: species,
          decoration: const InputDecoration(
            labelText: 'Species',
            prefixIcon: Icon(Icons.category_rounded),
          ),
          items: PetSpecies.values.map((s) {
            return DropdownMenuItem(value: s, child: Text(s.displayName));
          }).toList(),
          onChanged: (v) {
            if (v != null) onSpeciesChanged(v);
          },
        ),
        AppSpacing.verticalGapLg,
        TextField(
          controller: breedController,
          decoration: const InputDecoration(
            labelText: 'Breed',
            prefixIcon: Icon(Icons.info_outline),
          ),
        ),
        AppSpacing.verticalGapLg,
        DropdownButtonFormField<PetGender>(
          value: gender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.wc_rounded),
          ),
          items: PetGender.values.map((g) {
            return DropdownMenuItem(value: g, child: Text(g.displayName));
          }).toList(),
          onChanged: (v) {
            if (v != null) onGenderChanged(v);
          },
        ),
        AppSpacing.verticalGapLg,
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: const Icon(Icons.cake_rounded),
            hintText: dateOfBirth != null
                ? DateFormat('d/M/yyyy').format(dateOfBirth!)
                : 'Tap to select',
          ),
          controller: TextEditingController(
            text: dateOfBirth != null
                ? DateFormat('d/M/yyyy').format(dateOfBirth!)
                : '',
          ),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: dateOfBirth ?? now,
              firstDate: DateTime(now.year - 30),
              lastDate: now,
            );
            if (picked != null) onDateChanged(picked);
          },
        ),
        AppSpacing.verticalGapXl,
        TextField(
          controller: microchipIdController,
          decoration: const InputDecoration(
            labelText: 'Microchip ID',
            prefixIcon: Icon(Icons.memory_rounded),
          ),
        ),
        AppSpacing.verticalGapMd,
        TextField(
          controller: microchipRegistryController,
          decoration: const InputDecoration(
            labelText: 'Registry',
            prefixIcon: Icon(Icons.domain_rounded),
          ),
        ),
        AppSpacing.verticalGapMd,
        TextField(
          controller: microchipContactController,
          decoration: const InputDecoration(
            labelText: 'Contact Info',
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        ),
        AppSpacing.verticalGapXxl,
        ElevatedButton.icon(
          onPressed: isSaving ? null : onSave,
          icon: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Save Changes'),
        ),
        AppSpacing.verticalGapXl,
      ],
    );
  }
}

// ── Info Display Widgets ────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.items});

  final String title;
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.paddingAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.verticalGapMd,
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(item.value, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;
}
