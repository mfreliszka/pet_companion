import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';
import '../providers/expense_providers.dart';

/// Expense list with monthly totals and category filtering.
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key, required this.familyId});
  final String familyId;

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  ExpenseCategory? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expensesAsync = ref.watch(familyExpensesProvider(widget.familyId));

    return Scaffold(
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          final filtered = _filterCategory == null
              ? expenses
              : expenses.where((e) => e.category == _filterCategory).toList();

          // Monthly total
          final now = DateTime.now();
          final monthStart = DateTime(now.year, now.month, 1);
          final monthExpenses = expenses
              .where((e) => e.date.isAfter(monthStart))
              .toList();
          final monthTotal = monthExpenses.fold<double>(
            0,
            (sum, e) => sum + e.amount,
          );

          return Column(
            children: [
              // ── Summary Card ──
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(now),
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '\$${monthTotal.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Category Filter Chips ──
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterCategory == null,
                      onSelected: (_) => setState(() => _filterCategory = null),
                    ),
                    const SizedBox(width: 8),
                    ...ExpenseCategory.values.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Icon(c.icon, size: 16),
                          label: Text(c.displayName),
                          selected: _filterCategory == c,
                          onSelected: (_) =>
                              setState(() => _filterCategory = c),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Expense List ──
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No expenses yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final expense = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Icon(
                                  expense.category.icon,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                expense.title,
                                style: theme.textTheme.titleSmall,
                              ),
                              subtitle: Text(
                                '${expense.category.displayName} · ${DateFormat('MMM d').format(expense.date)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                // Navigate to detail — to be wired
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add — to be wired
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
