import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/loading/shimmer_loading.dart';
import '../models/invitation_model.dart';
import '../providers/family_providers.dart';

/// Screen showing pending invitations for the current user.
class PendingInvitationsScreen extends ConsumerWidget {
  const PendingInvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationsAsync = ref.watch(pendingInvitationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Invitations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: invitationsAsync.when(
        loading: () => const ShimmerLoading(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (invitations) {
          if (invitations.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.paddingAllXl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 80,
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    AppSpacing.verticalGapLg,
                    Text(
                      'No pending invitations',
                      style: theme.textTheme.headlineSmall,
                    ),
                    AppSpacing.verticalGapSm,
                    Text(
                      'When someone invites you to their family, it will appear here.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              return _InvitationCard(invitation: invitation);
            },
          );
        },
      ),
    );
  }
}

class _InvitationCard extends ConsumerStatefulWidget {
  const _InvitationCard({required this.invitation});
  final Invitation invitation;

  @override
  ConsumerState<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends ConsumerState<_InvitationCard> {
  bool _isLoading = false;

  Future<void> _accept() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(familyServiceProvider)
          .acceptInvitation(widget.invitation.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${widget.invitation.familyName}!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _decline() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(familyServiceProvider)
          .declineInvitation(widget.invitation.id!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inv = widget.invitation;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: AppSpacing.paddingAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.family_restroom_rounded,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                AppSpacing.horizontalGapLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.familyName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.verticalGapXs,
                      Text(
                        'You\'ve been invited to join this family',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isLoading ? null : _decline,
                  child: const Text('Decline'),
                ),
                AppSpacing.horizontalGapMd,
                FilledButton(
                  onPressed: _isLoading ? null : _accept,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
