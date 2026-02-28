import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_model.dart';
import '../services/expense_service.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

final petExpensesProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  petId,
) {
  return ref.watch(expenseServiceProvider).streamPetExpenses(petId);
});

final familyExpensesProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  familyId,
) {
  return ref.watch(expenseServiceProvider).streamFamilyExpenses(familyId);
});
