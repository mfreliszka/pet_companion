import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/expense_providers.dart';

/// Full details of an expense with edit/delete.
class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({
    super.key,
    required this.expenseId,
    required this.familyId,
  });

  final String expenseId;
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expensesAsync = ref.watch(familyExpensesProvider(familyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Expense?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(expenseServiceProvider).deleteExpense(expenseId);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          final expense = expenses.where((e) => e.id == expenseId).firstOrNull;
          if (expense == null) {
            return const Center(child: Text('Expense not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Header ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          expense.category.icon,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        expense.title,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Details ──
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.category_rounded),
                      title: const Text('Category'),
                      subtitle: Text(expense.category.displayName),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_rounded),
                      title: const Text('Date'),
                      subtitle: Text(
                        DateFormat('EEEE, MMM d, yyyy').format(expense.date),
                      ),
                    ),
                    if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notes_rounded),
                        title: const Text('Notes'),
                        subtitle: Text(expense.notes!),
                      ),
                    ],
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.access_time_rounded),
                      title: const Text('Added'),
                      subtitle: Text(
                        DateFormat(
                          'MMM d, yyyy · h:mm a',
                        ).format(expense.createdAt),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
