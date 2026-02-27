import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/family_providers.dart';

/// Screen for creating a new family.
class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  ConsumerState<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _usePassword = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isCreating = true);

    try {
      await ref
          .read(familyServiceProvider)
          .createFamily(
            name: name,
            userId: user.uid,
            password: _usePassword ? _passwordController.text.trim() : null,
          );

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create family: $e')));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Family'),
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
              Icons.family_restroom_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          AppSpacing.verticalGapXl,
          AppTextField(
            controller: _nameController,
            label: 'Family Name',
            hint: 'e.g. The Johnsons',
            prefixIcon: Icons.home_rounded,
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.verticalGapXl,
          SwitchListTile(
            title: Text(
              'Password Protection',
              style: theme.textTheme.titleSmall,
            ),
            subtitle: Text(
              'Require a password to join this family',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: _usePassword,
            onChanged: (v) => setState(() => _usePassword = v),
          ),
          if (_usePassword) ...[
            AppSpacing.verticalGapMd,
            AppTextField(
              controller: _passwordController,
              label: 'Join Password',
              hint: 'Others will need this to join',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
          ],
          AppSpacing.verticalGapXxl,
          PrimaryButton(
            label: 'Create Family',
            onPressed: _create,
            isLoading: _isCreating,
            isExpanded: true,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}
