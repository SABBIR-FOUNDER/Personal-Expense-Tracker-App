import 'package:flutter/material.dart';

import 'app.dart';
import 'data/sqflite_transaction_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ExpenseTrackerApp(repository: SqfliteTransactionRepository()));
}
