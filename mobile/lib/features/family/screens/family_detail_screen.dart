import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/loading/loading_spinner.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/family_model.dart';
import '../providers/family_providers.dart';

/// Detail screen for a family with members, invitations, and settings.
class FamilyDetailScreen extends ConsumerWidget {
  const FamilyDetailScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyDetailProvider(familyId));
    final isAdmin = ref.watch(isAdminProvider(familyId));

    return familyAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Family')),
        body: const LoadingSpinner(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Family')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (family) {
        if (family == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Family')),
            body: const Center(child: Text('Family not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(family.name),
            actions: [
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Delete ${family.name}?',
                        message:
                            'This will permanently delete the family and remove all members.',
                        confirmLabel: 'Delete',
                        isDestructive: true,
                      );
                      if (confirmed == true) {
                        await ref
                            .read(familyServiceProvider)
                            .deleteFamily(family.id!, family.memberIds);
                        if (context.mounted) context.pop();
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete Family'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              // ── Overview card ──
              _OverviewCard(family: family),
              AppSpacing.verticalGapLg,

              // ── Members section ──
              _SectionHeader(title: 'Members (${family.memberCount})'),
              AppSpacing.verticalGapSm,
              ...family.memberIds.map(
                (memberId) => _MemberTile(
                  memberId: memberId,
                  isAdmin: family.isAdmin(memberId),
                  canRemove: isAdmin && memberId != family.createdBy,
                  onRemove: () async {
                    await ref
                        .read(familyServiceProvider)
                        .removeMember(family.id!, memberId);
                  },
                ),
              ),
              AppSpacing.verticalGapLg,

              // ── Invite section ──
              if (isAdmin) ...[
                _SectionHeader(title: 'Invite Members'),
                AppSpacing.verticalGapSm,
                _InviteSection(familyId: family.id!),
              ],

              AppSpacing.verticalGapXl,

              // ── Leave button ──
              if (!isAdmin || family.adminIds.length > 1)
                OutlinedButton.icon(
                  onPressed: () async {
                    final user = ref.read(currentUserProvider);
                    if (user == null) return;
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: 'Leave ${family.name}?',
                      message:
                          'You will no longer have access to this family\'s pets and records.',
                      confirmLabel: 'Leave',
                      isDestructive: true,
                    );
                    if (confirmed == true) {
                      await ref
                          .read(familyServiceProvider)
                          .leaveFamily(family.id!, user.uid);
                      if (context.mounted) context.pop();
                    }
                  },
                  icon: const Icon(Icons.exit_to_app, color: AppColors.error),
                  label: const Text('Leave Family'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Overview Card ───────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.family});
  final Family family;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.paddingAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: AppSpacing.avatarLg / 2,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.home_rounded,
                    size: AppSpacing.iconXl,
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (family.familyCode != null) ...[
                        AppSpacing.verticalGapXs,
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: family.familyCode!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Family code copied!'),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.key,
                                size: AppSpacing.iconSm,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              AppSpacing.horizontalGapXs,
                              Text(
                                family.familyCode!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpacing.horizontalGapXs,
                              Icon(
                                Icons.copy,
                                size: AppSpacing.iconSm,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapLg,
            Row(
              children: [
                _StatChip(
                  icon: Icons.people,
                  label: '${family.memberCount} members',
                ),
                AppSpacing.horizontalGapMd,
                _StatChip(icon: Icons.pets, label: '${family.petCount} pets'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppSpacing.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconSm),
          AppSpacing.horizontalGapXs,
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ── Member Tile ─────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.memberId,
    required this.isAdmin,
    required this.canRemove,
    required this.onRemove,
  });

  final String memberId;
  final bool isAdmin;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        child: Text(memberId.substring(0, 2).toUpperCase()),
      ),
      title: Text(
        memberId,
        style: theme.textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAdmin)
            Chip(
              label: Text(
                'Admin',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          if (canRemove)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              iconSize: AppSpacing.iconMd,
              color: AppColors.error,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

// ── Invite Section ──────────────────────────────────────────────

class _InviteSection extends ConsumerStatefulWidget {
  const _InviteSection({required this.familyId});
  final String familyId;

  @override
  ConsumerState<_InviteSection> createState() => _InviteSectionState();
}

class _InviteSectionState extends ConsumerState<_InviteSection> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref
          .read(familyServiceProvider)
          .sendInvitation(
            familyId: widget.familyId,
            email: email,
            invitedBy: user.uid,
          );
      _emailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitation sent!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'member@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendInvite(),
          ),
        ),
        AppSpacing.horizontalGapSm,
        IconButton.filled(onPressed: _sendInvite, icon: const Icon(Icons.send)),
      ],
    );
  }
}

// ── Section Header ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
