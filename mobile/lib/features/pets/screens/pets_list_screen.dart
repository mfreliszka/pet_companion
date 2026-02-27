import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/loading/shimmer_loading.dart';
import '../models/pet_model.dart';
import '../providers/pet_providers.dart';

/// Screen listing all pets across the current user's families.
class PetsListScreen extends ConsumerWidget {
  const PetsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(userPetsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: petsAsync.when(
        loading: () => const ShimmerLoading(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              AppSpacing.verticalGapMd,
              Text('Failed to load pets', style: theme.textTheme.bodyLarge),
              AppSpacing.verticalGapSm,
              Text(
                e.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (pets) {
          if (pets.isEmpty) {
            return _EmptyState(theme: theme);
          }

          return ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return _PetCard(pet: pet);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pets/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            AppSpacing.verticalGapLg,
            Text('No pets yet', style: theme.textTheme.headlineSmall),
            AppSpacing.verticalGapSm,
            Text(
              'Add your first pet to start tracking their health and wellbeing.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapXl,
            ElevatedButton.icon(
              onPressed: () => context.push('/pets/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Pet'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pet Card ────────────────────────────────────────────────────

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push('/pets/${pet.id}'),
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.paddingAllLg,
          child: Row(
            children: [
              // Pet avatar
              _PetAvatar(pet: pet, size: AppSpacing.avatarLg),
              AppSpacing.horizontalGapLg,
              // Pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalGapXs,
                    Row(
                      children: [
                        Icon(
                          _speciesIcon(pet.species),
                          size: AppSpacing.iconSm,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        AppSpacing.horizontalGapXs,
                        Text(
                          pet.species.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (pet.breed != null && pet.breed!.isNotEmpty) ...[
                          Text(
                            ' · ${pet.breed}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pet Avatar ──────────────────────────────────────────────────

class PetAvatar extends StatelessWidget {
  const PetAvatar({super.key, required this.pet, this.size = 40});

  final Pet pet;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _PetAvatar(pet: pet, size: size);
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.pet, required this.size});

  final Pet pet;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (pet.photoThumbnailUrl != null || pet.photoUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(pet.photoThumbnailUrl ?? pet.photoUrl!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Icon(
        _speciesIcon(pet.species),
        size: size * 0.5,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────

IconData _speciesIcon(PetSpecies species) {
  return switch (species) {
    PetSpecies.dog => Icons.pets_rounded,
    PetSpecies.cat => Icons.pets_rounded,
    PetSpecies.bird => Icons.flutter_dash_rounded,
    PetSpecies.rabbit => Icons.cruelty_free_rounded,
    PetSpecies.fish => Icons.water_rounded,
    PetSpecies.reptile => Icons.bug_report_rounded,
    PetSpecies.other => Icons.pets_rounded,
  };
}
