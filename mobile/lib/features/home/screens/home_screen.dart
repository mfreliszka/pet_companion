import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../../core/theme/app_spacing.dart';

/// Home screen — landing page for authenticated users.
///
/// Shows a welcome message; in later phases this becomes
/// the dashboard with pet cards, upcoming events, etc.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userDoc = ref.watch(userDocProvider);

    final displayName = userDoc.value?['displayName'] as String? ?? 'there';
    final firstName = displayName.split(' ').first;

    return SafeArea(
      child: Padding(
        padding: AppSpacing.paddingAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome ──
            Text('Hello, $firstName! 👋', style: theme.textTheme.headlineLarge),
            AppSpacing.verticalGapSm,
            Text(
              'Welcome to Pet Companion',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),

            // ── Empty state ──
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  ),
                  AppSpacing.verticalGapLg,
                  Text(
                    'Add your first pet to get started',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.verticalGapSm,
                  Text(
                    'Tap "My Pets" in the drawer to begin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
