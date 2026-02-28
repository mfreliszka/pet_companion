import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';

/// Notification preferences screen — per-user FCM settings.
class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  bool _eventReminders = true;
  bool _vaccinationReminders = true;
  bool _routineReminders = true;
  bool _familyUpdates = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final prefs =
            doc.data()?['notificationPreferences'] as Map<String, dynamic>?;
        if (prefs != null) {
          setState(() {
            _eventReminders = prefs['eventReminders'] ?? true;
            _vaccinationReminders = prefs['vaccinationReminders'] ?? true;
            _routineReminders = prefs['routineReminders'] ?? true;
            _familyUpdates = prefs['familyUpdates'] ?? true;
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'notificationPreferences': {
        'eventReminders': _eventReminders,
        'vaccinationReminders': _vaccinationReminders,
        'routineReminders': _routineReminders,
        'familyUpdates': _familyUpdates,
      },
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preferences saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Push Notifications',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose which notifications you receive',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Toggles ──
          _buildToggle(
            icon: Icons.event_rounded,
            title: 'Event Reminders',
            subtitle: 'Get notified before scheduled events',
            value: _eventReminders,
            onChanged: (v) => setState(() => _eventReminders = v),
          ),
          _buildToggle(
            icon: Icons.vaccines_rounded,
            title: 'Vaccination Reminders',
            subtitle: 'Upcoming vaccination due dates',
            value: _vaccinationReminders,
            onChanged: (v) => setState(() => _vaccinationReminders = v),
          ),
          _buildToggle(
            icon: Icons.playlist_add_check_rounded,
            title: 'Routine Reminders',
            subtitle: 'Daily routine task reminders',
            value: _routineReminders,
            onChanged: (v) => setState(() => _routineReminders = v),
          ),
          _buildToggle(
            icon: Icons.family_restroom_rounded,
            title: 'Family Updates',
            subtitle: 'When family members complete tasks',
            value: _familyUpdates,
            onChanged: (v) => setState(() => _familyUpdates = v),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _savePreferences,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Preferences'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
