import 'package:expense_tracker/models/expense_transaction.dart';
import 'package:expense_tracker/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionSummary', () {
    test('calculates income, expense and current balance', () {
      final transactions = [
        ExpenseTransaction(
          id: 1,
          title: 'Salary',
          amount: 30000,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2026, 11, 1),
        ),
        ExpenseTransaction(
          id: 2,
          title: 'Groceries',
          amount: 2500,
          category: 'Food',
          type: TransactionType.expense,
          date: DateTime(2026, 11, 2),
        ),
        ExpenseTransaction(
          id: 3,
          title: 'Freelance',
          amount: 5000,
          category: 'Business',
          type: TransactionType.income,
          date: DateTime(2026, 11, 3),
        ),
      ];

      final summary = TransactionSummary.fromTransactions(transactions);

      expect(summary.totalIncome, 35000);
      expect(summary.totalExpense, 2500);
      expect(summary.currentBalance, 32500);
    });

    test('returns zero totals for an empty transaction list', () {
      final summary = TransactionSummary.fromTransactions([]);

      expect(summary.totalIncome, 0);
      expect(summary.totalExpense, 0);
      expect(summary.currentBalance, 0);
    });
  });

  test('serializes and restores a transaction', () {
    final original = ExpenseTransaction(
      id: 7,
      title: 'Bus fare',
      amount: 50.5,
      category: 'Transport',
      type: TransactionType.expense,
      date: DateTime(2026, 11, 8),
    );

    final restored = ExpenseTransaction.fromMap(original.toMap());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.amount, original.amount);
    expect(restored.category, original.category);
    expect(restored.type, original.type);
    expect(restored.date, original.date);
  });

  test('formats currency with two decimals and grouping', () {
    expect(formatCurrency(1234567.5), '৳ 1,234,567.50');
  });
}
