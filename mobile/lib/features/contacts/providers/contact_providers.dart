import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contact_model.dart';
import '../services/contact_service.dart';

final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService();
});

final familyContactsProvider = StreamProvider.family<List<PetContact>, String>((
  ref,
  familyId,
) {
  return ref.watch(contactServiceProvider).streamFamilyContacts(familyId);
});
