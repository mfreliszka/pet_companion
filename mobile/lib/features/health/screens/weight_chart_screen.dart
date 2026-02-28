import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/weight_entry_model.dart';
import '../providers/health_providers.dart';

/// Weight chart screen with fl_chart line chart and entry list.
class WeightChartScreen extends ConsumerStatefulWidget {
  const WeightChartScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<WeightChartScreen> createState() => _WeightChartScreenState();
}

class _WeightChartScreenState extends ConsumerState<WeightChartScreen> {
  _TimeRange _selectedRange = _TimeRange.threeMonths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(weightHistoryProvider(widget.petId));

    return Scaffold(
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          if (entries.isEmpty) return _buildEmptyState(theme);

          final filtered = _filterEntries(entries);
          final latest = entries.last;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Latest weight ──
                _LatestWeightCard(entry: latest),
                const SizedBox(height: 16),

                // ── Time range selector ──
                _TimeRangeSelector(
                  selected: _selectedRange,
                  onChanged: (r) => setState(() => _selectedRange = r),
                ),
                const SizedBox(height: 16),

                // ── Chart ──
                if (filtered.length >= 2)
                  SizedBox(height: 220, child: _WeightChart(entries: filtered))
                else
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: Text(
                      'Need at least 2 entries to show chart',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // ── Entry list ──
                Text('History', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...List.generate(
                  filtered.length,
                  (i) => _WeightEntryTile(
                    entry: filtered[filtered.length - 1 - i],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWeightSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Weight'),
      ),
    );
  }

  List<WeightEntry> _filterEntries(List<WeightEntry> all) {
    final now = DateTime.now();
    final cutoff = switch (_selectedRange) {
      _TimeRange.oneMonth => now.subtract(const Duration(days: 30)),
      _TimeRange.threeMonths => now.subtract(const Duration(days: 90)),
      _TimeRange.sixMonths => now.subtract(const Duration(days: 180)),
      _TimeRange.oneYear => now.subtract(const Duration(days: 365)),
      _TimeRange.all => DateTime(2020),
    };
    return all.where((e) => e.date.isAfter(cutoff)).toList();
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monitor_weight_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text('No weight entries yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Start tracking your pet\'s weight',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddWeightSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log First Weight'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddWeightSheet(petId: widget.petId, ref: ref),
    );
  }
}

// ── Time Range ──────────────────────────────────────────────────

enum _TimeRange {
  oneMonth('1M'),
  threeMonths('3M'),
  sixMonths('6M'),
  oneYear('1Y'),
  all('All');

  const _TimeRange(this.label);
  final String label;
}

class _TimeRangeSelector extends StatelessWidget {
  const _TimeRangeSelector({required this.selected, required this.onChanged});

  final _TimeRange selected;
  final ValueChanged<_TimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_TimeRange>(
      segments: _TimeRange.values
          .map((r) => ButtonSegment(value: r, label: Text(r.label)))
          .toList(),
      selected: {selected},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}

// ── Latest Weight Card ──────────────────────────────────────────

class _LatestWeightCard extends StatelessWidget {
  const _LatestWeightCard({required this.entry});

  final WeightEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
                Icons.monitor_weight_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Weight',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  entry.displayWeight,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              DateFormat('MMM d').format(entry.date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weight Chart ────────────────────────────────────────────────

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weightKg);
    }).toList();

    final minY =
        entries.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY =
        entries.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b) * 1.05;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          horizontalInterval: (maxY - minY) / 4,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (entries.length / 5).ceilToDouble().clamp(1, 100),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('M/d').format(entries[idx].date),
                    style: theme.textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: theme.textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: entries.length <= 20),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final entry = entries[spot.spotIndex];
                return LineTooltipItem(
                  '${entry.displayWeight}\n${DateFormat('MMM d').format(entry.date)}',
                  TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

// ── Weight Entry Tile ───────────────────────────────────────────

class _WeightEntryTile extends StatelessWidget {
  const _WeightEntryTile({required this.entry});

  final WeightEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.monitor_weight_outlined,
        color: theme.colorScheme.primary,
      ),
      title: Text(entry.displayWeight),
      subtitle: Text(DateFormat('MMM d, yyyy').format(entry.date)),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

// ── Add Weight Bottom Sheet ─────────────────────────────────────

class _AddWeightSheet extends StatefulWidget {
  const _AddWeightSheet({required this.petId, required this.ref});

  final String petId;
  final WidgetRef ref;

  @override
  State<_AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends State<_AddWeightSheet> {
  final _weightController = TextEditingController();
  String _unit = 'kg';
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log Weight', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  autofocus: true,
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'kg', label: Text('kg')),
                  ButtonSegment(value: 'lbs', label: Text('lbs')),
                ],
                selected: {_unit},
                onSelectionChanged: (v) => setState(() => _unit = v.first),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(DateFormat('MMM d, yyyy').format(_date)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final weightValue = double.tryParse(_weightController.text);
    if (weightValue == null || weightValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // Convert lbs to kg for storage
      final weightKg = _unit == 'lbs' ? weightValue / 2.20462 : weightValue;

      final entry = WeightEntry(
        weightKg: weightKg,
        unit: _unit,
        date: _date,
        createdBy: user.uid,
      );

      await widget.ref
          .read(weightServiceProvider)
          .addWeight(widget.petId, entry, createdByName: user.displayName);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
