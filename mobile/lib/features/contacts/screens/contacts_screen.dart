import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contact_model.dart';
import '../providers/contact_providers.dart';

/// Contact list grouped by type with phone dialer tap.
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key, required this.familyId});
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final contactsAsync = ref.watch(familyContactsProvider(familyId));

    return Scaffold(
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.contacts_rounded,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add vets, groomers, and other pet contacts',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          // Group by type
          final grouped = <ContactType, List<PetContact>>{};
          for (final c in contacts) {
            grouped.putIfAbsent(c.type, () => []).add(c);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.expand((entry) {
              return [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        entry.key.icon,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key.displayName,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map(
                  (contact) => Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          contact.type.icon,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        contact.name,
                        style: theme.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        [
                          contact.phone,
                          contact.email,
                        ].where((s) => s != null && s.isNotEmpty).join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: contact.phone != null
                          ? IconButton(
                              icon: const Icon(Icons.phone_rounded),
                              onPressed: () {
                                // url_launcher integration deferred
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ];
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add — wired via router
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
