import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Expense Category ────────────────────────────────────────────

enum ExpenseCategory {
  food('Food', Icons.restaurant_rounded),
  medication('Medication', Icons.medication_rounded),
  vetVisit('Vet Visit', Icons.local_hospital_rounded),
  grooming('Grooming', Icons.content_cut_rounded),
  supplies('Supplies', Icons.shopping_bag_rounded),
  insurance('Insurance', Icons.shield_rounded),
  other('Other', Icons.receipt_long_rounded);

  const ExpenseCategory(this.displayName, this.icon);
  final String displayName;
  final IconData icon;

  static ExpenseCategory fromString(String value) => switch (value) {
    'food' => ExpenseCategory.food,
    'medication' => ExpenseCategory.medication,
    'vetVisit' => ExpenseCategory.vetVisit,
    'grooming' => ExpenseCategory.grooming,
    'supplies' => ExpenseCategory.supplies,
    'insurance' => ExpenseCategory.insurance,
    _ => ExpenseCategory.other,
  };

  String toFirestore() => name;
}

// ── Expense Model ───────────────────────────────────────────────

class Expense {
  const Expense({
    required this.id,
    required this.petId,
    required this.familyId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.receiptKey,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String petId;
  final String familyId;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? notes;
  final String? receiptKey;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      petId: map['petId'] as String? ?? '',
      familyId: map['familyId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.fromString(map['category'] as String? ?? ''),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'] as String?,
      receiptKey: map['receiptKey'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'petId': petId,
    'familyId': familyId,
    'title': title,
    'amount': amount,
    'category': category.toFirestore(),
    'date': Timestamp.fromDate(date),
    'notes': notes,
    'receiptKey': receiptKey,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Expense copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? notes,
    String? receiptKey,
    String? petId,
  }) {
    return Expense(
      id: id,
      petId: petId ?? this.petId,
      familyId: familyId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      receiptKey: receiptKey ?? this.receiptKey,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
