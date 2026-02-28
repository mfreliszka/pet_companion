import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense_model.dart';

/// Service for managing expenses in top-level `/expenses` collection.
class ExpenseService {
  ExpenseService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection('expenses');

  // ── CRUD ────────────────────────────────────────────────────

  Future<String> addExpense(Expense expense) async {
    final doc = await _expensesRef.add(expense.toMap());
    return doc.id;
  }

  Future<void> updateExpense(Expense expense) async {
    await _expensesRef.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesRef.doc(expenseId).delete();
  }

  // ── Streams ─────────────────────────────────────────────────

  Stream<List<Expense>> streamPetExpenses(String petId) {
    return _expensesRef
        .where('petId', isEqualTo: petId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Expense.fromMap(d.data(), d.id)).toList(),
        );
  }

  Stream<List<Expense>> streamFamilyExpenses(String familyId) {
    return _expensesRef
        .where('familyId', isEqualTo: familyId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Expense.fromMap(d.data(), d.id)).toList(),
        );
  }

  // ── Aggregates ──────────────────────────────────────────────

  Future<double> getTotalForPeriod(
    String familyId,
    DateTime start,
    DateTime end,
  ) async {
    final snap = await _expensesRef
        .where('familyId', isEqualTo: familyId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    double total = 0;
    for (final doc in snap.docs) {
      total += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }
}
