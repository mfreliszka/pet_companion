import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/expense_model.dart';
import '../providers/expense_providers.dart';

/// Form to create a new expense.
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, required this.familyId});
  final String familyId;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.other;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final now = DateTime.now();
    final expense = Expense(
      id: '',
      petId: '',
      familyId: widget.familyId,
      title: _titleCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text.trim()) ?? 0,
      category: _category,
      date: _date,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      receiptKey: null,
      createdBy: user.uid,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await ref.read(expenseServiceProvider).addExpense(expense);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money_rounded),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final amt = double.tryParse(v.trim());
                if (amt == null || amt <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Category ──
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: ExpenseCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 18),
                          const SizedBox(width: 8),
                          Text(c.displayName),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            // ── Date ──
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Date'),
              subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_date)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
