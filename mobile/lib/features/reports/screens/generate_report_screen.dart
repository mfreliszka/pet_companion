import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pets/providers/pet_providers.dart';

/// Screen to generate and download PDF health reports.
class GenerateReportScreen extends ConsumerStatefulWidget {
  const GenerateReportScreen({super.key, required this.familyId});
  final String familyId;

  @override
  ConsumerState<GenerateReportScreen> createState() =>
      _GenerateReportScreenState();
}

class _GenerateReportScreenState extends ConsumerState<GenerateReportScreen> {
  String? _selectedPetId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _generating = false;
  String? _downloadUrl;
  String? _error;

  Future<void> _generate() async {
    if (_selectedPetId == null) {
      setState(() => _error = 'Please select a pet');
      return;
    }

    setState(() {
      _generating = true;
      _error = null;
      _downloadUrl = null;
    });

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'generate_report',
      );
      final result = await callable.call({
        'petId': _selectedPetId,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
      });

      final data = result.data as Map<String, dynamic>;
      setState(() {
        _downloadUrl = data['downloadUrl'] as String?;
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() => _error = e.message ?? 'Failed to generate report');
    } catch (e) {
      setState(() => _error = 'An error occurred: $e');
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final petsAsync = ref.watch(familyPetsProvider(widget.familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Health Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Instructions ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf_rounded,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Generate PDF Report',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a comprehensive health report including journal entries, weight history, medications, and vaccinations.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Pet Selector ──
          petsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error loading pets: $e'),
            data: (pets) {
              return DropdownButtonFormField<String>(
                value: _selectedPetId,
                decoration: const InputDecoration(
                  labelText: 'Select Pet',
                  prefixIcon: Icon(Icons.pets_rounded),
                ),
                items: pets
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedPetId = v),
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Date Range ──
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded, size: 20),
                  title: const Text('From'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(_startDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: _endDate,
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded, size: 20),
                  title: const Text('To'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(_endDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Generate Button ──
          FilledButton.icon(
            onPressed: _generating ? null : _generate,
            icon: _generating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_rounded),
            label: Text(_generating ? 'Generating...' : 'Generate Report'),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
          ],

          if (_downloadUrl != null) ...[
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text('Report Ready!', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(_downloadUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download PDF'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
