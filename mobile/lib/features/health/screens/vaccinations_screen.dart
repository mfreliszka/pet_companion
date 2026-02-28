import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/vaccination_model.dart';
import '../providers/health_providers.dart';
import 'add_vaccination_screen.dart';

/// Vaccination list screen with overdue highlighting.
class VaccinationsScreen extends ConsumerWidget {
  const VaccinationsScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vacsAsync = ref.watch(vaccinationsProvider(petId));

    return Scaffold(
      appBar: AppBar(title: const Text('Vaccinations')),
      body: vacsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (vacs) {
          if (vacs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.vaccines_rounded,
                      size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No vaccination records',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _navigateToAdd(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Vaccination'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vacs.length,
            itemBuilder: (context, index) =>
                _VaccinationCard(vaccination: vacs[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Vaccination'),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddVaccinationScreen(petId: petId)),
    );
  }
}

class _VaccinationCard extends StatefulWidget {
  const _VaccinationCard({required this.vaccination});

  final Vaccination vaccination;

  @override
  State<_VaccinationCard> createState() => _VaccinationCardState();
}

class _VaccinationCardState extends State<_VaccinationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final vac = widget.vaccination;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
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
                      color: _statusColor(theme).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.vaccines_rounded,
                      color: _statusColor(theme),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vac.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          dateFormat.format(vac.dateAdministered),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (vac.nextDueDate != null) ...[
                    _DueDateChip(vaccination: vac),
                  ],
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_expanded) ...[
                const Divider(height: 24),
                if (vac.veterinarian != null)
                  _DetailRow('Veterinarian', vac.veterinarian!),
                if (vac.clinic != null) _DetailRow('Clinic', vac.clinic!),
                if (vac.batchNumber != null)
                  _DetailRow('Batch #', vac.batchNumber!),
                if (vac.nextDueDate != null)
                  _DetailRow('Next Due', dateFormat.format(vac.nextDueDate!)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(ThemeData theme) {
    if (widget.vaccination.isOverdue) return theme.colorScheme.error;
    if (widget.vaccination.isDueSoon) return Colors.orange;
    return theme.colorScheme.primary;
  }
}

class _DueDateChip extends StatelessWidget {
  const _DueDateChip({required this.vaccination});

  final Vaccination vaccination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = vaccination.isOverdue;
    final isDueSoon = vaccination.isDueSoon;

    Color bg;
    Color fg;
    String label;

    if (isOverdue) {
      bg = theme.colorScheme.errorContainer;
      fg = theme.colorScheme.onErrorContainer;
      label = 'Overdue';
    } else if (isDueSoon) {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade900;
      label = 'Due Soon';
    } else {
      bg = theme.colorScheme.primaryContainer;
      fg = theme.colorScheme.onPrimaryContainer;
      label = DateFormat('MMM d').format(vaccination.nextDueDate!);
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
