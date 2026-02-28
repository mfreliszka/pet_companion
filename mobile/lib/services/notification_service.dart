import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles FCM token management and message routing.
///
/// This service:
/// 1. Requests notification permissions
/// 2. Saves FCM tokens to the user's Firestore document
/// 3. Handles foreground & background messages
///
/// Note: flutter_local_notifications is NOT used on web (guarded by kIsWeb).
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  /// Initialize FCM — call once after Firebase.initializeApp().
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Request permission (no-op on web, shows dialog on iOS/Android)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle tap on notification that opened the app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Get FCM token and persist it to the user's Firestore document.
  Future<void> getAndSaveFcmToken(String userId) async {
    try {
      String? token;

      if (kIsWeb) {
        // Web requires a VAPID key — for now, skip if not configured
        // To enable: pass vapidKey to getToken()
        token = await _messaging.getToken();
      } else {
        token = await _messaging.getToken();
      }

      if (token != null) {
        await _saveToken(userId, token);
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        _saveToken(userId, newToken);
      });
    } catch (e) {
      debugPrint('NotificationService: Failed to get FCM token: $e');
    }
  }

  /// Remove FCM token from user doc (call on sign-out).
  Future<void> removeFcmToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
    } catch (e) {
      debugPrint('NotificationService: Failed to remove token: $e');
    }
  }

  // ── Private helpers ─────────────────────────────────────────

  Future<void> _saveToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      'NotificationService: Foreground message: ${message.notification?.title}',
    );
    // On mobile, this would show a local notification.
    // On web, the browser handles it natively.
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('NotificationService: Message opened app: ${message.data}');
    // Navigation can be wired here via data payload:
    // e.g. message.data['route'] → GoRouter.go(route)
  }
}

/// Top-level background message handler (must be a top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    'NotificationService: Background message: ${message.notification?.title}',
  );
}
