import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../providers/family_providers.dart';

/// Screen for joining an existing family by code (+ optional password).
class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isJoining = true);

    try {
      final password = _passwordController.text.trim();
      await ref
          .read(familyServiceProvider)
          .joinByCode(code: code, password: password.isEmpty ? null : password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined family!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to join: $e')));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Family'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Center(
            child: Icon(
              Icons.group_add_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          AppSpacing.verticalGapLg,
          Text(
            'Enter the family code shared with you\nby a family member.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.verticalGapXl,
          AppTextField(
            controller: _codeController,
            label: 'Family Code',
            hint: 'e.g. A1B2C3D4',
            prefixIcon: Icons.key_rounded,
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.verticalGapLg,
          AppTextField(
            controller: _passwordController,
            label: 'Password (if required)',
            hint: 'Leave empty if no password set',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _join(),
          ),
          AppSpacing.verticalGapXxl,
          PrimaryButton(
            label: 'Join Family',
            onPressed: _join,
            isLoading: _isJoining,
            isExpanded: true,
            icon: Icons.group_add,
          ),
        ],
      ),
    );
  }
}
