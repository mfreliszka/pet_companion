import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/journal_entry_model.dart';
import '../providers/journal_providers.dart';
import 'add_journal_entry_screen.dart';

/// Main journal timeline showing all entries for a pet,
/// with filter chips for entry types.
class JournalTimelineScreen extends ConsumerStatefulWidget {
  const JournalTimelineScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<JournalTimelineScreen> createState() =>
      _JournalTimelineScreenState();
}

class _JournalTimelineScreenState extends ConsumerState<JournalTimelineScreen> {
  JournalEntryType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(
      filteredJournalEntriesProvider((widget.petId, _selectedFilter)),
    );

    return Scaffold(
      body: Column(
        children: [
          // ── Filter chips ──────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedFilter == null,
                  onSelected: () => setState(() => _selectedFilter = null),
                ),
                const SizedBox(width: 8),
                ...JournalEntryType.values.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: type.displayName,
                      icon: type.icon,
                      color: type.color,
                      selected: _selectedFilter == type,
                      onSelected: () => setState(() => _selectedFilter = type),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Entry list ────────────────────────────────────────
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading entries: $error',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return _EmptyState(
                    filter: _selectedFilter,
                    onAddEntry: () => _navigateToAddEntry(context),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      _JournalEntryCard(entry: entries[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEntry(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Entry'),
      ),
    );
  }

  void _navigateToAddEntry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddJournalEntryScreen(petId: widget.petId),
      ),
    );
  }
}

// ── Filter Chip ─────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? null : color),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor:
          color?.withValues(alpha: 0.2) ?? theme.colorScheme.primaryContainer,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.filter, required this.onAddEntry});

  final JournalEntryType? filter;
  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter?.icon ?? Icons.book_rounded,
              size: 64,
              color:
                  filter?.color ??
                  theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              filter != null
                  ? 'No ${filter!.displayName.toLowerCase()} entries yet'
                  : 'No journal entries yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your pet\'s health and activities',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddEntry,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log First Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Journal Entry Card ──────────────────────────────────────────

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: entry.type.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(entry.type.icon, color: entry.type.color, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type + time
                  Row(
                    children: [
                      Text(
                        entry.type.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeFormat.format(entry.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Date
                  Text(
                    dateFormat.format(entry.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Summary
                  Text(
                    entry.summary,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Notes (if different from summary)
                  if (entry.notes != null &&
                      entry.notes!.isNotEmpty &&
                      entry.type != JournalEntryType.note) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Photos indicator
                  if (entry.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.photo_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.photoUrls.length} photo${entry.photoUrls.length > 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Created by
                  const SizedBox(height: 4),
                  Text(
                    'by ${entry.createdByName}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
