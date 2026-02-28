---
phase: 5
plan: 1
wave: 1
---

# Plan 5.1: Expense Tracking — Model, Service & CRUD Screens

## Objective
Implement full expense tracking: model with category enum, Firestore CRUD service, Riverpod providers, and three screens (expense list with filtering/totals, add expense, expense detail). This is the foundation for financial tracking per pet/family.

## Context
- .gsd/SPEC.md — "Expense tracking with monthly/yearly totals"
- .gsd/ARCHITECTURE.md
- mobile/lib/features/expenses/ (empty scaffold)
- mobile/lib/features/schedule/ (established pattern: model → service → providers → screens)
- mobile/lib/core/routing/app_router.dart

## Tasks

<task type="auto">
  <name>Expense model, service, and providers</name>
  <files>
    mobile/lib/features/expenses/models/expense_model.dart
    mobile/lib/features/expenses/services/expense_service.dart
    mobile/lib/features/expenses/providers/expense_providers.dart
  </files>
  <action>
    1. Create ExpenseCategory enum (food, medication, vet_visit, grooming, supplies, insurance, other) with displayName and icon
    2. Create Expense model (id, petId, familyId, title, amount (double), category, date, notes, receiptKey (R2 path), createdBy, createdAt, updatedAt) with full Firestore serialization
    3. Create ExpenseService with:
       - addExpense, updateExpense, deleteExpense
       - streamPetExpenses(petId) — ordered by date desc
       - streamFamilyExpenses(familyId) — ordered by date desc
       - getTotalForPeriod(familyId, start, end) — aggregate query
    4. Create Riverpod providers: expenseServiceProvider, petExpensesProvider, familyExpensesProvider
    
    Follow the exact same patterns used in event_model.dart and event_service.dart.
  </action>
  <verify>flutter build web 2>&1 | tail -3</verify>
  <done>Models compile, service methods exist, providers configured — build passes</done>
</task>

<task type="auto">
  <name>Expense screens and router integration</name>
  <files>
    mobile/lib/features/expenses/screens/expenses_screen.dart
    mobile/lib/features/expenses/screens/add_expense_screen.dart
    mobile/lib/features/expenses/screens/expense_detail_screen.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    1. ExpensesScreen: displays expenses for a pet/family with:
       - Monthly total summary card at top
       - Category filter chips
       - ListView of expense cards (icon, title, amount, date)
       - FAB to add expense
    2. AddExpenseScreen: form with title, amount (currency input), category selector, date picker, notes, optional receipt upload
    3. ExpenseDetailScreen: shows full expense details, edit/delete actions
    4. Wire routes in app_router.dart:
       - /expenses (replace placeholder) with familyId query param
       - /expenses/add
       - /expenses/:expenseId
    
    Match the visual patterns from events_screen.dart / add_event_screen.dart.
  </action>
  <verify>flutter build web 2>&1 | tail -3</verify>
  <done>All 3 screens render, routes functional, expense CRUD complete — build passes</done>
</task>

## Success Criteria
- [ ] Expense model with 7 categories and full Firestore serialization
- [ ] CRUD service with period-based totals
- [ ] 3 screens with filtering, summary card, and receipt upload support
- [ ] Routes wired at /expenses/*
- [ ] flutter build web succeeds with 0 errors
