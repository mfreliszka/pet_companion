import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/loading/shimmer_loading.dart';
import '../models/family_model.dart';
import '../providers/family_providers.dart';

/// Screen listing the user's families.
class FamilyListScreen extends ConsumerWidget {
  const FamilyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familiesAsync = ref.watch(userFamiliesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: familiesAsync.when(
        loading: () => const ShimmerLoading(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              AppSpacing.verticalGapMd,
              Text('Failed to load families', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        data: (families) {
          if (families.isEmpty) {
            return _EmptyState(theme: theme);
          }

          return ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: families.length,
            itemBuilder: (context, index) {
              final family = families[index];
              return _FamilyCard(family: family);
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'join',
            onPressed: () => context.push('/family/join'),
            child: const Icon(Icons.group_add),
          ),
          AppSpacing.verticalGapSm,
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () => context.push('/family/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create Family'),
          ),
        ],
      ),
    );
  }
}

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
              Icons.family_restroom_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            AppSpacing.verticalGapLg,
            Text('No families yet', style: theme.textTheme.headlineSmall),
            AppSpacing.verticalGapSm,
            Text(
              'Create a family to share pet care with others, or join an existing one.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapXl,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push('/family/join'),
                  icon: const Icon(Icons.group_add),
                  label: const Text('Join'),
                ),
                AppSpacing.horizontalGapMd,
                ElevatedButton.icon(
                  onPressed: () => context.push('/family/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({required this.family});
  final Family family;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push('/family/${family.id}'),
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.paddingAllLg,
          child: Row(
            children: [
              CircleAvatar(
                radius: AppSpacing.avatarMd / 2,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.home_rounded,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              AppSpacing.horizontalGapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      family.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalGapXs,
                    Text(
                      '${family.memberCount} member${family.memberCount != 1 ? 's' : ''} · ${family.petCount} pet${family.petCount != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
