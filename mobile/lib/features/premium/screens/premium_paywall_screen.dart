import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../providers/subscription_providers.dart';

/// Premium upgrade screen with feature comparison and activation.
class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  bool _activating = false;

  Future<void> _activateTrial() async {
    setState(() => _activating = true);
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(subscriptionServiceProvider).activatePremium(user.uid);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Premium activated! 🎉')));
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _activating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Hero ──
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock Premium Features',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get the most out of Pet Companion with advanced tools for your furry family.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Feature comparison ──
          Text('What\'s included', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          _featureRow(theme, 'Pet Profiles', true, true),
          _featureRow(theme, 'Health Tracking', true, true),
          _featureRow(theme, 'Journal & Timeline', true, true),
          _featureRow(theme, 'Schedules & Reminders', true, true),
          _featureRow(theme, 'Up to 3 Pets', true, false),
          _featureRow(theme, 'Unlimited Pets', false, true),
          _featureRow(theme, 'PDF Health Reports', false, true),
          _featureRow(theme, 'Expense Tracking', false, true),
          _featureRow(theme, 'Advanced Analytics', false, true),
          _featureRow(theme, 'Priority Support', false, true),

          const SizedBox(height: 24),

          // ── Current status ──
          subAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const SizedBox.shrink(),
            data: (sub) {
              if (sub.isPremium) {
                return Card(
                  color: theme.colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You\'re Premium! 🌟',
                                style: theme.textTheme.titleSmall,
                              ),
                              if (sub.expiresAt != null)
                                Text(
                                  'Expires ${_formatDate(sub.expiresAt!)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 16),

          // ── CTA ──
          subAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (sub) {
              if (sub.isPremium) return const SizedBox.shrink();
              return FilledButton.icon(
                onPressed: _activating ? null : _activateTrial,
                icon: _activating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch_rounded),
                label: Text(
                  _activating ? 'Activating...' : 'Start 30-Day Free Trial',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _featureRow(ThemeData theme, String name, bool free, bool premium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
          SizedBox(
            width: 60,
            child: Center(
              child: Icon(
                free
                    ? Icons.check_circle_rounded
                    : Icons.remove_circle_outline_rounded,
                color: free
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withAlpha(100),
                size: 20,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Center(
              child: Icon(
                premium
                    ? Icons.check_circle_rounded
                    : Icons.remove_circle_outline_rounded,
                color: premium
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.onSurfaceVariant.withAlpha(100),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
