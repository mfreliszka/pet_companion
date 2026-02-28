import 'package:cloud_firestore/cloud_firestore.dart';

// ── Subscription Tier ─────────────────────────────────────────

enum SubscriptionTier {
  free,
  premium;

  static SubscriptionTier fromString(String value) => switch (value) {
    'premium' => SubscriptionTier.premium,
    _ => SubscriptionTier.free,
  };

  String toFirestore() => name;
}

// ── Subscription Model ────────────────────────────────────────

class Subscription {
  const Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPremium =>
      tier == SubscriptionTier.premium &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  factory Subscription.free(String userId) {
    final now = DateTime.now();
    return Subscription(
      id: '',
      userId: userId,
      tier: SubscriptionTier.free,
      expiresAt: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Subscription.fromMap(Map<String, dynamic> map, String id) {
    return Subscription(
      id: id,
      userId: map['userId'] as String? ?? '',
      tier: SubscriptionTier.fromString(map['tier'] as String? ?? ''),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'tier': tier.toFirestore(),
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}

// ── Gated Features ────────────────────────────────────────────

/// Features that require a premium subscription.
enum GatedFeature {
  pdfReports('PDF Health Reports'),
  expenseTracking('Expense Tracking'),
  unlimitedPets('Unlimited Pets (>3)'),
  advancedAnalytics('Advanced Analytics');

  const GatedFeature(this.displayName);
  final String displayName;
}
