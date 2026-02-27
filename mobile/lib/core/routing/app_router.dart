import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/pets/screens/pets_list_screen.dart';
import '../../features/pets/screens/add_pet_screen.dart';
import '../../features/pets/screens/pet_detail_screen.dart';
import '../../features/family/screens/family_list_screen.dart';
import '../../features/family/screens/create_family_screen.dart';
import '../../features/family/screens/join_family_screen.dart';
import '../../features/family/screens/family_detail_screen.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/layout/app_drawer.dart';

// ── Placeholder Screen ──────────────────────────────────────────

/// Stub screen for features not yet implemented.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shell with Drawer ───────────────────────────────────────────

/// Shell that wraps authenticated routes with [AppScaffold] + [AppDrawer].
class _AuthenticatedShell extends ConsumerWidget {
  const _AuthenticatedShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDoc = ref.watch(userDocProvider);
    final user = ref.watch(currentUserProvider);
    final currentLocation = GoRouterState.of(context).uri.toString();

    final displayName =
        userDoc.value?['displayName'] as String? ??
        user?.displayName ??
        'Pet Companion';
    final email = userDoc.value?['email'] as String? ?? user?.email;
    final photoUrl = userDoc.value?['photoUrl'] as String? ?? user?.photoURL;

    return AppScaffold(
      title: _titleForRoute(currentLocation),
      drawer: AppDrawer(
        userName: displayName,
        userEmail: email,
        userPhotoUrl: photoUrl,
        currentRoute: currentLocation,
        onNavigate: (route) => context.go(route),
        onSignOut: () async {
          await ref.read(authServiceProvider).signOut();
        },
      ),
      body: child,
    );
  }

  String _titleForRoute(String location) {
    return switch (location) {
      '/' => 'Home',
      '/profile' => 'Profile',
      '/pets' => 'My Pets',
      '/family' => 'Family',
      '/journal' => 'Journal',
      '/health' => 'Health',
      '/schedule' => 'Schedule',
      '/expenses' => 'Expenses',
      '/contacts' => 'Contacts',
      '/reports' => 'Reports',
      _ => 'Pet Companion',
    };
  }
}

// ── Router Provider ─────────────────────────────────────────────

/// GoRouter configured with auth redirect and drawer shell.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isOnSignIn = state.uri.toString() == '/sign-in';

      if (!isAuthenticated && !isOnSignIn) return '/sign-in';
      if (isAuthenticated && isOnSignIn) return '/';
      return null;
    },
    routes: [
      // ── Public route ──
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),

      // ── Authenticated routes (wrapped in shell with drawer) ──
      ShellRoute(
        builder: (context, state, child) {
          return _AuthenticatedShell(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/pets',
            builder: (context, state) => const PetsListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddPetScreen(),
              ),
              GoRoute(
                path: ':petId',
                builder: (context, state) {
                  final petId = state.pathParameters['petId']!;
                  return PetDetailScreen(petId: petId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/family',
            builder: (context, state) => const FamilyListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateFamilyScreen(),
              ),
              GoRoute(
                path: 'join',
                builder: (context, state) => const JoinFamilyScreen(),
              ),
              GoRoute(
                path: ':familyId',
                builder: (context, state) {
                  final familyId = state.pathParameters['familyId']!;
                  return FamilyDetailScreen(familyId: familyId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/journal',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Journal'),
          ),
          GoRoute(
            path: '/health',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Health'),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Schedule'),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Expenses'),
          ),
          GoRoute(
            path: '/contacts',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Contacts'),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Reports'),
          ),
        ],
      ),
    ],
  );
});
