import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Google Sign-In (v7 API — must be called once before use).
  await GoogleSignIn.instance.initialize();

  runApp(const ProviderScope(child: PetCompanionApp()));
}

/// Root application widget.
class PetCompanionApp extends ConsumerWidget {
  const PetCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Pet Companion',
      debugShowCheckedModeBanner: false,

      // Dark mode default (ADR-10).
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,

      routerConfig: router,
    );
  }
}
