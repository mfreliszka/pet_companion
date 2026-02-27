import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/media/user_avatar.dart';
import '../../../core/widgets/buttons/secondary_button.dart';

/// Profile screen — displays user info and provides sign out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userDoc = ref.watch(userDocProvider);
    final user = ref.watch(currentUserProvider);

    final displayName =
        userDoc.value?['displayName'] as String? ?? user?.displayName ?? '';
    final email = userDoc.value?['email'] as String? ?? user?.email ?? '';
    final photoUrl = userDoc.value?['photoUrl'] as String? ?? user?.photoURL;
    final isPremium = userDoc.value?['isPremium'] as bool? ?? false;

    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.paddingAllLg,
        child: Column(
          children: [
            AppSpacing.verticalGapLg,

            // ── Avatar ──
            UserAvatar(
              imageUrl: photoUrl,
              name: displayName,
              radius: AppSpacing.avatarXl / 2,
            ),
            AppSpacing.verticalGapLg,

            // ── Name ──
            Text(
              displayName,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapXs,

            // ── Email ──
            Text(
              email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalGapSm,

            // ── Premium badge ──
            if (isPremium)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: AppSpacing.iconSm,
                      color: AppColors.secondary,
                    ),
                    AppSpacing.horizontalGapXs,
                    Text(
                      'Premium',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // ── Settings List ──
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_rounded),
                    title: const Text('App Settings'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      // Placeholder — expand in later phase
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Pet Companion',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(
                          Icons.pets_rounded,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Sign Out ──
            SecondaryButton(
              label: 'Sign Out',
              icon: Icons.logout_rounded,
              isExpanded: true,
              foregroundColor: AppColors.error,
              borderColor: AppColors.error,
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
