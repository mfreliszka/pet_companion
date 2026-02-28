import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/medication_model.dart';
import '../providers/health_providers.dart';
import 'add_medication_screen.dart';

/// Medication list screen with Active / History tabs.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medications'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MedicationList(petId: petId, activeOnly: true),
            _MedicationList(petId: petId, activeOnly: false),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddMedicationScreen(petId: petId),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Medication'),
        ),
      ),
    );
  }
}

class _MedicationList extends ConsumerWidget {
  const _MedicationList({required this.petId, required this.activeOnly});

  final String petId;
  final bool activeOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = activeOnly
        ? ref.watch(activeMedicationsProvider(petId))
        : ref.watch(allMedicationsProvider(petId));

    final theme = Theme.of(context);

    return medsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (meds) {
        // For history tab, show only inactive
        final filtered = activeOnly
            ? meds
            : meds.where((m) => !m.isActive).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medication_rounded,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activeOnly
                        ? 'No active medications'
                        : 'No medication history',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _MedicationCard(
            medication: filtered[index],
            petId: petId,
            showDeactivate: activeOnly,
          ),
        );
      },
    );
  }
}

class _MedicationCard extends ConsumerWidget {
  const _MedicationCard({
    required this.medication,
    required this.petId,
    this.showDeactivate = false,
  });

  final Medication medication;
  final String petId;
  final bool showDeactivate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: medication.isActive
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: medication.isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (medication.dosage != null &&
                          medication.dosage!.isNotEmpty)
                        Text(
                          medication.dosage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (showDeactivate && medication.id != null)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'deactivate') {
                        _confirmDeactivate(context, ref);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Text('Stop Medication'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _InfoChip(
                  icon: Icons.repeat_rounded,
                  label: medication.frequency.displayName,
                ),
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: 'From ${dateFormat.format(medication.startDate)}',
                ),
                if (medication.endDate != null)
                  _InfoChip(
                    icon: Icons.event_rounded,
                    label: 'Until ${dateFormat.format(medication.endDate!)}',
                  ),
                if (medication.scheduledTimes.isNotEmpty)
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: medication.scheduledTimes.join(', '),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Stop Medication?'),
        content: Text(
          'Mark "${medication.name}" as stopped? This will set the end date to today.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(medicationServiceProvider)
                  .deactivateMedication(petId, medication.id!);
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
