import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/health_providers.dart';

/// Unified health dashboard per pet.
class HealthHubScreen extends ConsumerWidget {
  const HealthHubScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WeightSummaryCard(petId: petId),
            const SizedBox(height: 12),
            _MedicationsSummaryCard(petId: petId),
            const SizedBox(height: 12),
            _VaccinationsSummaryCard(petId: petId),
            const SizedBox(height: 12),
            _MedicalRecordsSummaryCard(petId: petId),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Weight Summary ──────────────────────────────────────────────

class _WeightSummaryCard extends ConsumerWidget {
  const _WeightSummaryCard({required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weightAsync = ref.watch(weightHistoryProvider(petId));

    return Card(
      child: InkWell(
        onTap: () => context.go('/pets/$petId/health/weight'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monitor_weight_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text('Weight', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    'View History',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              weightAsync.when(
                loading: () => const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const Text('Unable to load'),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Text(
                      'No weight recorded yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }

                  final latest = entries.last;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest.displayWeight,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (entries.length >= 2)
                        SizedBox(
                          height: 50,
                          child: _MiniSparkline(
                            values: entries.map((e) => e.weightKg).toList(),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Medications Summary ─────────────────────────────────────────

class _MedicationsSummaryCard extends ConsumerWidget {
  const _MedicationsSummaryCard({required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final medsAsync = ref.watch(activeMedicationsProvider(petId));

    return Card(
      child: InkWell(
        onTap: () => context.go('/pets/$petId/health/medications'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication_rounded,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Medications', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    medsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const Text('Unable to load'),
                      data: (meds) => Text(
                        meds.isEmpty
                            ? 'No active medications'
                            : '${meds.length} active medication${meds.length > 1 ? 's' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Vaccinations Summary ────────────────────────────────────────

class _VaccinationsSummaryCard extends ConsumerWidget {
  const _VaccinationsSummaryCard({required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final upcomingAsync = ref.watch(upcomingVaccinationsProvider(petId));

    return Card(
      child: InkWell(
        onTap: () => context.go('/pets/$petId/health/vaccinations'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vaccines_rounded,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vaccinations', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    upcomingAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const Text('Unable to load'),
                      data: (vacs) {
                        if (vacs.isEmpty) {
                          return Text(
                            'No upcoming vaccinations',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        }
                        final next = vacs.first;
                        final isOverdue = next.isOverdue;
                        return Text(
                          isOverdue
                              ? '${next.name} — OVERDUE'
                              : '${next.name} — ${DateFormat('MMM d').format(next.nextDueDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isOverdue ? FontWeight.w600 : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Medical Records Summary ─────────────────────────────────────

class _MedicalRecordsSummaryCard extends ConsumerWidget {
  const _MedicalRecordsSummaryCard({required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recordsAsync = ref.watch(medicalRecordsProvider(petId));

    return Card(
      child: InkWell(
        onTap: () => context.go('/pets/$petId/health/records'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Medical Records', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    recordsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const Text('Unable to load'),
                      data: (records) => Text(
                        records.isEmpty
                            ? 'No records yet'
                            : '${records.length} record${records.length > 1 ? 's' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
