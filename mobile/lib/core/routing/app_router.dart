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
import '../../features/journal/screens/journal_timeline_screen.dart';
import '../../features/journal/screens/add_journal_entry_screen.dart';
import '../../features/health/screens/health_hub_screen.dart';
import '../../features/health/screens/weight_chart_screen.dart';
import '../../features/health/screens/medications_screen.dart';
import '../../features/health/screens/add_medication_screen.dart';
import '../../features/health/screens/vaccinations_screen.dart';
import '../../features/health/screens/add_vaccination_screen.dart';
import '../../features/health/screens/medical_records_screen.dart';
import '../../features/health/screens/add_medical_record_screen.dart';
import '../../features/schedule/screens/events_screen.dart';
import '../../features/schedule/screens/add_event_screen.dart';
import '../../features/schedule/screens/event_detail_screen.dart';
import '../../features/schedule/screens/routines_screen.dart';
import '../../features/schedule/screens/add_routine_screen.dart';
import '../../features/schedule/screens/routine_detail_screen.dart';
import '../../features/schedule/screens/care_calendar_screen.dart';
import '../../features/schedule/screens/notification_preferences_screen.dart';
import '../../features/expenses/screens/expenses_screen.dart';
import '../../features/expenses/screens/add_expense_screen.dart';
import '../../features/expenses/screens/expense_detail_screen.dart';
import '../../features/contacts/screens/contacts_screen.dart';
import '../../features/contacts/screens/add_contact_screen.dart';
import '../../features/reports/screens/generate_report_screen.dart';
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
    if (location.contains('/journal')) return 'Journal';
    if (location.contains('/health/weight')) return 'Weight';
    if (location.contains('/health/medications')) return 'Medications';
    if (location.contains('/health/vaccinations')) return 'Vaccinations';
    if (location.contains('/health/records')) return 'Medical Records';
    if (location.contains('/health')) return 'Health';
    if (location.contains('/events')) return 'Events';
    return switch (location) {
      '/' => 'Home',
      '/profile' => 'Profile',
      '/pets' => 'My Pets',
      '/family' => 'Family',
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
                routes: [
                  GoRoute(
                    path: 'journal',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return JournalTimelineScreen(petId: petId);
                    },
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          return AddJournalEntryScreen(petId: petId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'health',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return HealthHubScreen(petId: petId);
                    },
                    routes: [
                      GoRoute(
                        path: 'weight',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          return WeightChartScreen(petId: petId);
                        },
                      ),
                      GoRoute(
                        path: 'medications',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          return MedicationsScreen(petId: petId);
                        },
                        routes: [
                          GoRoute(
                            path: 'add',
                            builder: (context, state) {
                              final petId = state.pathParameters['petId']!;
                              return AddMedicationScreen(petId: petId);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'vaccinations',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          return VaccinationsScreen(petId: petId);
                        },
                        routes: [
                          GoRoute(
                            path: 'add',
                            builder: (context, state) {
                              final petId = state.pathParameters['petId']!;
                              return AddVaccinationScreen(petId: petId);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'records',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          return MedicalRecordsScreen(petId: petId);
                        },
                        routes: [
                          GoRoute(
                            path: 'add',
                            builder: (context, state) {
                              final petId = state.pathParameters['petId']!;
                              return AddMedicalRecordScreen(petId: petId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'events',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return EventsScreen(petId: petId);
                    },
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          final familyId =
                              state.uri.queryParameters['familyId'] ?? '';
                          return AddEventScreen(
                            petId: petId,
                            familyId: familyId,
                          );
                        },
                      ),
                      GoRoute(
                        path: ':eventId',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          final eventId = state.pathParameters['eventId']!;
                          return EventDetailScreen(
                            petId: petId,
                            eventId: eventId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
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
            builder: (context, state) => const PlaceholderScreen(
              title: 'Journal\nSelect a pet to view their journal',
            ),
          ),
          GoRoute(
            path: '/health',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Health\nSelect a pet to view their health data',
            ),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const PlaceholderScreen(
              title:
                  'Schedule\nSelect a pet to view events, or view routines below',
            ),
            routes: [
              GoRoute(
                path: 'routines',
                builder: (context, state) {
                  final familyId = state.uri.queryParameters['familyId'] ?? '';
                  return RoutinesScreen(familyId: familyId);
                },
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) {
                      final familyId =
                          state.uri.queryParameters['familyId'] ?? '';
                      return AddRoutineScreen(familyId: familyId);
                    },
                  ),
                  GoRoute(
                    path: ':routineId',
                    builder: (context, state) {
                      final routineId = state.pathParameters['routineId']!;
                      return RoutineDetailScreen(routineId: routineId);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'calendar',
                builder: (context, state) {
                  final familyId = state.uri.queryParameters['familyId'] ?? '';
                  return CareCalendarScreen(familyId: familyId);
                },
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) =>
                    const NotificationPreferencesScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) {
              final familyId = state.uri.queryParameters['familyId'] ?? '';
              return ExpensesScreen(familyId: familyId);
            },
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final familyId = state.uri.queryParameters['familyId'] ?? '';
                  return AddExpenseScreen(familyId: familyId);
                },
              ),
              GoRoute(
                path: ':expenseId',
                builder: (context, state) {
                  final expenseId = state.pathParameters['expenseId']!;
                  final familyId = state.uri.queryParameters['familyId'] ?? '';
                  return ExpenseDetailScreen(
                    expenseId: expenseId,
                    familyId: familyId,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/contacts',
            builder: (context, state) {
              final familyId = state.uri.queryParameters['familyId'] ?? '';
              return ContactsScreen(familyId: familyId);
            },
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final familyId = state.uri.queryParameters['familyId'] ?? '';
                  return AddContactScreen(familyId: familyId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) {
              final familyId = state.uri.queryParameters['familyId'] ?? '';
              return GenerateReportScreen(familyId: familyId);
            },
          ),
        ],
      ),
    ],
  );
});
