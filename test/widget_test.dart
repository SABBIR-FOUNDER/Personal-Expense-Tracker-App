import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/data/transaction_repository.dart';
import 'package:expense_tracker/models/expense_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTransactionRepository implements TransactionRepository {
  final List<ExpenseTransaction> _transactions = [];
  var _nextId = 1;

  @override
  Future<List<ExpenseTransaction>> getAllTransactions() async {
    final result = [..._transactions]
      ..sort((a, b) {
        final dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) return dateComparison;
        return (b.id ?? 0).compareTo(a.id ?? 0);
      });
    return result;
  }

  @override
  Future<int> insertTransaction(ExpenseTransaction transaction) async {
    final id = _nextId++;
    _transactions.add(transaction.copyWith(id: id));
    return id;
  }

  @override
  Future<int> updateTransaction(ExpenseTransaction transaction) async {
    final index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) return 0;
    _transactions[index] = transaction;
    return 1;
  }

  @override
  Future<int> deleteTransaction(int id) async {
    final before = _transactions.length;
    _transactions.removeWhere((item) => item.id == id);
    return before - _transactions.length;
  }
}

void main() {
  testWidgets('shows the dashboard and saves a new income transaction', (
    tester,
  ) async {
    final repository = FakeTransactionRepository();

    await tester.pumpWidget(ExpenseTrackerApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('No transactions yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('addTransactionFab')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('titleField')),
      'Monthly salary',
    );
    await tester.enterText(find.byKey(const Key('amountField')), '25000');

    await tester.tap(find.byKey(const Key('categoryDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salary').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('incomeChip')));

    final saveButton = find.byKey(const Key('saveTransactionButton'));
    await tester.scrollUntilVisible(
      saveButton,
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Monthly salary'), findsOneWidget);
    expect(find.textContaining('25,000.00'), findsWidgets);
    expect(find.text('1 total'), findsOneWidget);
  });

  testWidgets('validates required fields before saving', (tester) async {
    final repository = FakeTransactionRepository();

    await tester.pumpWidget(ExpenseTrackerApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addTransactionFab')));
    await tester.pumpAndSettle();

    final saveButton = find.byKey(const Key('saveTransactionButton'));
    await tester.scrollUntilVisible(
      saveButton,
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Title cannot be empty.'), findsOneWidget);
    expect(find.text('Amount is required.'), findsOneWidget);
    expect(find.text('Please select a category.'), findsOneWidget);
    expect(find.text('Please select income or expense.'), findsOneWidget);
    expect(await repository.getAllTransactions(), isEmpty);
  });
}
