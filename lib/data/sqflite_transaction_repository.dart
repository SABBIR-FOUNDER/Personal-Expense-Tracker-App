import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/expense_transaction.dart';
import 'transaction_repository.dart';

class SqfliteTransactionRepository implements TransactionRepository {
  late final Future<Database> _database = _openDatabase();

  Future<Database> _openDatabase() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath = path.join(databaseDirectory, 'expense_tracker.db');

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL CHECK (amount > 0),
            category TEXT NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<ExpenseTransaction>> getAllTransactions() async {
    final database = await _database;
    final rows = await database.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );

    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  @override
  Future<int> insertTransaction(ExpenseTransaction transaction) async {
    final database = await _database;
    return database.insert('transactions', transaction.toMap());
  }

  @override
  Future<int> updateTransaction(ExpenseTransaction transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw ArgumentError('A transaction ID is required for an update.');
    }

    final database = await _database;
    return database.update(
      'transactions',
      transaction.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteTransaction(int id) async {
    final database = await _database;
    return database.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
