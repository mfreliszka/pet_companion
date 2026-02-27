import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/pet_model.dart';
import '../providers/pet_providers.dart';

/// Screen for adding a new pet.
class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _microchipIdController = TextEditingController();
  final _microchipRegistryController = TextEditingController();
  final _microchipContactController = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  PetGender _gender = PetGender.unknown;
  DateTime? _dateOfBirth;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _microchipIdController.dispose();
    _microchipRegistryController.dispose();
    _microchipContactController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final userDoc = ref.read(userDocProvider).value;
    final user = ref.read(currentUserProvider);
    if (userDoc == null || user == null) return;

    final familyIds = List<String>.from(userDoc['familyIds'] ?? []);
    if (familyIds.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create or join a family first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Use the first family for now — a family picker can be added later.
      final pet = Pet(
        name: _nameController.text.trim(),
        species: _species,
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        microchipId: _microchipIdController.text.trim().isEmpty
            ? null
            : _microchipIdController.text.trim(),
        microchipRegistry: _microchipRegistryController.text.trim().isEmpty
            ? null
            : _microchipRegistryController.text.trim(),
        microchipContactInfo: _microchipContactController.text.trim().isEmpty
            ? null
            : _microchipContactController.text.trim(),
        familyId: familyIds.first,
        createdBy: user.uid,
      );

      await ref.read(petServiceProvider).createPet(pet);

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add pet: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // ── Photo placeholder ──
            Center(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo upload coming in Phase 2.2'),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: AppSpacing.avatarXl / 2,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: AppSpacing.iconXl,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            AppSpacing.verticalGapXl,

            // ── Name ──
            AppTextField(
              controller: _nameController,
              label: 'Pet Name',
              hint: 'Enter your pet\'s name',
              prefixIcon: Icons.pets,
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.verticalGapLg,

            // ── Species ──
            DropdownButtonFormField<PetSpecies>(
              value: _species,
              decoration: const InputDecoration(
                labelText: 'Species',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: PetSpecies.values.map((s) {
                return DropdownMenuItem(value: s, child: Text(s.displayName));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _species = v);
              },
            ),
            AppSpacing.verticalGapLg,

            // ── Breed ──
            AppTextField(
              controller: _breedController,
              label: 'Breed (Optional)',
              hint: 'e.g. Golden Retriever',
              prefixIcon: Icons.info_outline,
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.verticalGapLg,

            // ── Gender ──
            DropdownButtonFormField<PetGender>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc_rounded),
              ),
              items: PetGender.values.map((g) {
                return DropdownMenuItem(value: g, child: Text(g.displayName));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
            AppSpacing.verticalGapLg,

            // ── Date of Birth ──
            AppTextField(
              label: 'Date of Birth (Optional)',
              hint: 'Tap to select',
              prefixIcon: Icons.cake_rounded,
              readOnly: true,
              onTap: _pickDateOfBirth,
              controller: TextEditingController(
                text: _dateOfBirth != null
                    ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                    : '',
              ),
            ),
            AppSpacing.verticalGapXl,

            // ── Microchip Section ──
            Text(
              'Microchip Information',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalGapMd,
            AppTextField(
              controller: _microchipIdController,
              label: 'Microchip ID (Optional)',
              hint: 'e.g. 123456789012345',
              prefixIcon: Icons.memory_rounded,
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.verticalGapMd,
            AppTextField(
              controller: _microchipRegistryController,
              label: 'Registry (Optional)',
              prefixIcon: Icons.domain_rounded,
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.verticalGapMd,
            AppTextField(
              controller: _microchipContactController,
              label: 'Contact Info (Optional)',
              prefixIcon: Icons.phone_rounded,
              textInputAction: TextInputAction.done,
            ),
            AppSpacing.verticalGapXxl,

            // ── Save Button ──
            PrimaryButton(
              label: 'Add Pet',
              onPressed: _savePet,
              isLoading: _isSaving,
              isExpanded: true,
              icon: Icons.check,
            ),
            AppSpacing.verticalGapXl,
          ],
        ),
      ),
    );
  }
}
