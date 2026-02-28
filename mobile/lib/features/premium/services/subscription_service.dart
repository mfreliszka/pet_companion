import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/subscription_model.dart';

/// Service for managing premium subscriptions.
class SubscriptionService {
  SubscriptionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _subscriptionsRef =>
      _firestore.collection('subscriptions');

  /// Stream the subscription for a user (returns free if none exists).
  Stream<Subscription> streamSubscription(String userId) {
    return _subscriptionsRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return Subscription.free(userId);
          final doc = snap.docs.first;
          return Subscription.fromMap(doc.data(), doc.id);
        });
  }

  /// Activate premium subscription (placeholder — real implementation
  /// would integrate with RevenueCat / Play Billing / StoreKit).
  Future<void> activatePremium(String userId) async {
    final now = DateTime.now();
    final expires = now.add(const Duration(days: 30)); // 1-month trial

    // Upsert subscription doc
    final existing = await _subscriptionsRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    final data = Subscription(
      id: '',
      userId: userId,
      tier: SubscriptionTier.premium,
      expiresAt: expires,
      createdAt: now,
      updatedAt: now,
    ).toMap();

    if (existing.docs.isEmpty) {
      await _subscriptionsRef.add(data);
    } else {
      await _subscriptionsRef.doc(existing.docs.first.id).update(data);
    }
  }

  /// Check if a specific feature is available for the user.
  Future<bool> isFeatureAvailable(String userId, GatedFeature feature) async {
    final snap = await _subscriptionsRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return false;
    final sub = Subscription.fromMap(
      snap.docs.first.data(),
      snap.docs.first.id,
    );
    return sub.isPremium;
  }
}
