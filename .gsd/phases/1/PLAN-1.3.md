---
phase: 1
plan: 3
wave: 3
depends_on: [1.1, 1.2]
files_modified:
  - mobile/lib/main.dart
  - mobile/lib/core/routing/app_router.dart
  - mobile/lib/features/auth/services/auth_service.dart
  - mobile/lib/features/auth/providers/auth_providers.dart
  - mobile/lib/features/auth/screens/sign_in_screen.dart
  - mobile/lib/features/home/screens/home_screen.dart
  - mobile/lib/features/auth/screens/profile_screen.dart
  - mobile/lib/services/firebase_service.dart
autonomous: false

must_haves:
  truths:
    - "User can sign in with Google and see their name/email/photo"
    - "User document is created in Firestore on first sign-in"
    - "Unauthenticated users are redirected to sign-in screen"
    - "Drawer navigation works and routes to placeholder screens"
    - "Sign out returns user to sign-in screen"
    - "Auth state persists across app restart"
    - "App uses dark theme by default with correct design tokens"
  artifacts:
    - "mobile/lib/features/auth/services/auth_service.dart wrapping Firebase Auth"
    - "mobile/lib/core/routing/app_router.dart with GoRouter + auth redirect"
    - "mobile/lib/features/auth/screens/sign_in_screen.dart"
    - "mobile/lib/features/auth/screens/profile_screen.dart"
    - "mobile/lib/features/home/screens/home_screen.dart"
---

# Plan 1.3: Authentication + Navigation + Screens

<objective>
Implement Google Sign-In with Riverpod providers, set up GoRouter with drawer navigation and auth guards, and create the home screen and basic profile screen.

Purpose: Delivers the first usable user experience — sign in, navigate, view profile, sign out. This validates that Firebase Auth, Firestore, Riverpod state, GoRouter, and the design system all work together end-to-end.
Output: Working auth flow, drawer navigation to stub screens, profile screen with user data from Firestore.
</objective>

<context>
Load for context:
- .gsd/SPEC.md (auth requirements, user stories)
- .gsd/ARCHITECTURE.md (Firestore users collection schema, routing structure)
- .gsd/DECISIONS.md (drawer nav, dark mode default)
- mobile/lib/core/theme/app_theme.dart (for theme integration)
- mobile/lib/core/widgets/layout/app_drawer.dart (for drawer integration)
- mobile/lib/core/widgets/layout/app_scaffold.dart (for screen scaffolding)
- mobile/lib/firebase_options.dart (for Firebase config)
</context>

<tasks>

<task type="auto">
  <name>Implement auth service, Riverpod providers, and Firestore user creation</name>
  <files>
    mobile/lib/features/auth/services/auth_service.dart
    mobile/lib/features/auth/providers/auth_providers.dart
    mobile/lib/services/firebase_service.dart
  </files>
  <action>
    1. Create firebase_service.dart:
       - FirebaseService class as a singleton or Riverpod provider
       - Helper methods for Firestore operations (getDoc, setDoc, updateDoc)
       - Reference to FirebaseFirestore.instance

    2. Create auth_service.dart:
       - AuthService class wrapping FirebaseAuth
       - Methods:
         - signInWithGoogle(): Uses GoogleSignIn + Firebase Auth credential
         - signOut(): Signs out of both Google and Firebase
         - getCurrentUser(): Returns current FirebaseAuth.User
         - authStateChanges(): Stream<User?> for reactive auth state
       - On successful sign-in, check if user doc exists in Firestore:
         - If NOT exists: Create user document in `users/{uid}` with:
           uid, email, displayName, photoUrl, familyIds: [], fcmTokens: [],
           isPremium: false, premiumExpiresAt: null, createdAt: now, updatedAt: now
         - If exists: Update updatedAt timestamp
       AVOID: Don't store the password anywhere — Google Sign-In is OAuth, no passwords.
       AVOID: Don't handle FCM tokens yet — Phase 4.

    3. Create auth_providers.dart:
       - authServiceProvider: Provider for AuthService instance
       - authStateProvider: StreamProvider wrapping authStateChanges()
       - currentUserProvider: Provider that reads authStateProvider
       - userDocProvider: FutureProvider or StreamProvider that reads the user's Firestore document
       Use flutter_riverpod patterns (not riverpod_generator for now, keep it simple)
  </action>
  <verify>
    `cd mobile && flutter analyze` — no errors in auth/ and services/ directories
    Auth providers compile and type-check correctly
  </verify>
  <done>
    AuthService wraps Google Sign-In + Firebase Auth.
    User document created in Firestore on first sign-in.
    Riverpod providers expose auth state reactively.
  </done>
</task>

<task type="auto">
  <name>Set up GoRouter with drawer navigation and auth guards</name>
  <files>
    mobile/lib/core/routing/app_router.dart
    mobile/lib/main.dart
    mobile/lib/core/widgets/layout/app_drawer.dart (update with actual routes)
  </files>
  <action>
    1. Create app_router.dart:
       - Define a goRouterProvider (Riverpod) that watches authStateProvider
       - Routes:
         - /sign-in → SignInScreen (public, no drawer)
         - / → HomeScreen (authenticated, with drawer)
         - /profile → ProfileScreen (authenticated, with drawer)
         - /pets → PlaceholderScreen("My Pets") (authenticated, stub)
         - /family → PlaceholderScreen("Family") (authenticated, stub)
         - /journal → PlaceholderScreen("Journal") (authenticated, stub)
         - /health → PlaceholderScreen("Health") (authenticated, stub)
         - /schedule → PlaceholderScreen("Schedule") (authenticated, stub)
         - /expenses → PlaceholderScreen("Expenses") (authenticated, stub)
         - /contacts → PlaceholderScreen("Contacts") (authenticated, stub)
         - /reports → PlaceholderScreen("Reports") (authenticated, stub)
       - Auth redirect logic:
         - If not authenticated → redirect to /sign-in
         - If authenticated and on /sign-in → redirect to /
       - Create a PlaceholderScreen widget that shows the feature name + "Coming soon"
       - Uses ShellRoute with AppScaffold to provide drawer on authenticated routes

    2. Update main.dart:
       - PetCompanionApp uses MaterialApp.router with GoRouter
       - Set theme: AppTheme.dark() as default
       - Set darkTheme: AppTheme.dark()
       - Set themeMode: ThemeMode.dark (dark by default)
       - Provide GoRouter from the Riverpod provider

    3. Update AppDrawer to use actual GoRouter navigation:
       - On item tap, call context.go(route)
       - Close drawer after navigation
       - Highlight current route using GoRouter state
       AVOID: Don't use Navigator.push — use GoRouter declarative routing only.
       AVOID: Don't create separate scaffold per screen — use ShellRoute with AppScaffold.
  </action>
  <verify>
    `cd mobile && flutter analyze` — no errors
    GoRouter compiles with all routes defined
    AppDrawer wired to actual route paths
  </verify>
  <done>
    GoRouter configured with auth guard, drawer navigation, and placeholder screens.
    main.dart uses MaterialApp.router with dark theme default.
    All drawer items navigate to the correct routes.
  </done>
</task>

<task type="checkpoint:human-verify">
  <name>Create sign-in, home, and profile screens</name>
  <files>
    mobile/lib/features/auth/screens/sign_in_screen.dart
    mobile/lib/features/home/screens/home_screen.dart
    mobile/lib/features/auth/screens/profile_screen.dart
  </files>
  <action>
    1. Create sign_in_screen.dart:
       - Clean, branded sign-in page using dark theme
       - App logo/icon area at top (placeholder icon for now — paw print 🐾)
       - App name "Pet Companion" in Nunito heading
       - Tagline: "Your pet's health, organized"
       - "Sign in with Google" button using PrimaryButton with Google icon
       - Uses authServiceProvider to call signInWithGoogle()
       - Shows LoadingSpinner while signing in
       - Error handling with SnackBar

    2. Create home_screen.dart:
       - Welcome message: "Hello, {displayName}!" using AppTypography
       - Empty state message: "Add your first pet to get started" with a paw print icon
       - Uses AppScaffold with drawer
       - Reads user data from userDocProvider
       - This screen will be expanded in Phase 2+ with pet cards, upcoming events, etc.

    3. Create profile_screen.dart:
       - UserAvatar at top (large, from Google photo or initials)
       - Display name, email
       - "Premium" badge if isPremium (from Firestore doc)
       - ListTileCards for:
         - App Settings (placeholder)
         - Theme toggle (light/dark) — reads and writes ThemeMode
         - About
       - Sign Out button (SecondaryButton, red tint)
       - Uses userDocProvider to display data

    4. Run `flutter run -d chrome` and verify:
       - Sign-in screen renders with Google Sign-In button
       - After sign-in, user lands on home screen with drawer
       - Drawer shows all navigation items
       - Profile screen shows user info
       - Sign out returns to sign-in screen
    AVOID: Don't over-design these screens — they're functional foundations, not final UI.
    NOTE: Theme toggle can use a simple Riverpod StateProvider for now.
  </action>
  <verify>
    `cd mobile && flutter run -d chrome` — full auth flow works:
    1. Sign-in screen appears
    2. Google Sign-In completes
    3. Home screen shows with drawer
    4. Profile screen displays user info
    5. Sign out works
    User document visible in Firebase console
  </verify>
  <done>
    Complete auth flow: sign-in → home → drawer nav → profile → sign out.
    User document created in Firestore on first sign-in.
    Dark theme applied by default, all screens use design system components.
    Drawer navigates to all placeholder screens.
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] Google Sign-In works end-to-end (sign in → Firestore doc → home screen)
- [ ] Auth redirect: unauthenticated → /sign-in, authenticated → /
- [ ] Drawer opens and navigates to all routes (placeholder screens for future features)
- [ ] Profile screen shows user name, email, photo from Firestore
- [ ] Sign out clears auth state and returns to sign-in screen
- [ ] Dark theme is applied by default
- [ ] `flutter run -d chrome` works without errors
- [ ] Auth state persists across app refresh
</verification>

<success_criteria>
- [ ] All tasks verified
- [ ] Must-haves confirmed
- [ ] Phase 1 is complete — ready for Phase 2 (Pet Profiles + Family System)
</success_criteria>
