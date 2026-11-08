import '../models/expense_transaction.dart';

abstract interface class TransactionRepository {
  Future<List<ExpenseTransaction>> getAllTransactions();

  Future<int> insertTransaction(ExpenseTransaction transaction);

  Future<int> updateTransaction(ExpenseTransaction transaction);

  Future<int> deleteTransaction(int id);
}
