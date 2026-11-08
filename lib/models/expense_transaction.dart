enum TransactionType { income, expense }

extension TransactionTypeLabel on TransactionType {
  String get databaseValue => name;

  String get label => this == TransactionType.income ? 'Income' : 'Expense';
}

class ExpenseTransaction {
  const ExpenseTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  final int? id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;

  ExpenseTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    TransactionType? type,
    DateTime? date,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.databaseValue,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.parse(map['date'] as String),
    );
  }
}

class TransactionSummary {
  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
  });

  final double totalIncome;
  final double totalExpense;

  double get currentBalance => totalIncome - totalExpense;

  factory TransactionSummary.fromTransactions(
    Iterable<ExpenseTransaction> transactions,
  ) {
    var income = 0.0;
    var expense = 0.0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return TransactionSummary(totalIncome: income, totalExpense: expense);
  }
}
