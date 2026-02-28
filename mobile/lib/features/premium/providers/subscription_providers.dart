import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final subscriptionProvider = StreamProvider<Subscription>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(Subscription.free(''));
  return ref.watch(subscriptionServiceProvider).streamSubscription(user.uid);
});

final isPremiumProvider = Provider<bool>((ref) {
  final sub = ref.watch(subscriptionProvider);
  return sub.value?.isPremium ?? false;
});
