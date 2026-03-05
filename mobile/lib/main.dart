import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler — NOT supported on web.
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Initialize Google Sign-In (v7 API) — only on mobile.
  // On web, we use FirebaseAuth.signInWithPopup() directly,
  // so we skip GIS initialization (it causes spurious FedCM popups).
  if (!kIsWeb) {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint('GoogleSignIn.initialize() failed: $e');
    }
  }

  // Initialize notification service.
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationService.initialize() failed: $e');
  }

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
