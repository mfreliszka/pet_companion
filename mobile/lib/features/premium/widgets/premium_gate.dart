import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/subscription_providers.dart';
import '../models/subscription_model.dart';

/// Widget that gates content behind premium.
/// Shows the child if premium, or a lock overlay with upgrade prompt.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({super.key, required this.feature, required this.child});

  final GatedFeature feature;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) return child;

    final theme = Theme.of(context);

    return Stack(
      children: [
        // Blurred/faded content
        Opacity(opacity: 0.3, child: AbsorbPointer(child: child)),
        // Lock overlay
        Positioned.fill(
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feature.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This feature requires Premium',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push('/premium'),
                      icon: const Icon(Icons.workspace_premium_rounded),
                      label: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
