import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';

/// Sign-in screen — the app entry point for unauthenticated users.
///
/// Dark-themed branded page with Google Sign-In.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _isSigningIn = false;

  Future<void> _handleSignIn() async {
    setState(() => _isSigningIn = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // GoRouter redirect will automatically navigate to home.
    } on GoogleSignInException catch (e) {
      debugPrint(
        'GoogleSignInException: code=${e.code}, desc=${e.description}',
      );
      if (!mounted) return;
      // Cancelled sign-in is not an error.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        setState(() => _isSigningIn = false);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: ${e.description ?? e.code}')),
      );
    } on FirebaseAuthException catch (e) {
      // Web popup dismissed by user — treat as cancellation, not error.
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        debugPrint('Sign-in popup dismissed by user');
        if (mounted) setState(() => _isSigningIn = false);
        return;
      }
      debugPrint('FirebaseAuthException: ${e.code} — ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: ${e.message ?? e.code}')),
      );
    } catch (e, stack) {
      debugPrint('Sign-in error: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.paddingHorizontalXl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo area ──
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                AppSpacing.verticalGapXl,

                // ── App name ──
                Text(
                  'Pet Companion',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.verticalGapSm,

                // ── Tagline ──
                Text(
                  "Your pet's health, organized",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // ── Sign-in button ──
                PrimaryButton(
                  label: 'Sign in with Google',
                  icon: Icons.login_rounded,
                  isLoading: _isSigningIn,
                  isExpanded: true,
                  onPressed: _isSigningIn ? null : _handleSignIn,
                ),
                AppSpacing.verticalGapLg,

                // ── Terms ──
                Text(
                  'By signing in you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
