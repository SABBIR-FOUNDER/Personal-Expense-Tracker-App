import 'package:flutter/material.dart';

import '../data/transaction_repository.dart';
import '../models/expense_transaction.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.repository});

  final TransactionRepository repository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ExpenseTransaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactions = await widget.repository.getAllTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load transactions. Please try again.';
      });
    }
  }

  Future<void> _addTransaction() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(repository: widget.repository),
      ),
    );
    if (mounted) await _loadTransactions();
  }

  Future<void> _openTransaction(ExpenseTransaction transaction) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(
          repository: widget.repository,
          transaction: transaction,
        ),
      ),
    );
    if (mounted) await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final summary = TransactionSummary.fromTransactions(_transactions);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, size: 23),
            SizedBox(width: 9),
            Text(
              'Expense Tracker',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh transactions',
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Row(
              children: [
                SummaryCard(
                  title: 'Total Income',
                  amount: summary.totalIncome,
                  icon: Icons.south_west_rounded,
                  color: const Color(0xFF16865B),
                  backgroundColor: const Color(0xFFE8F6EF),
                ),
                const SizedBox(width: 9),
                SummaryCard(
                  title: 'Total Expense',
                  amount: summary.totalExpense,
                  icon: Icons.north_east_rounded,
                  color: const Color(0xFFD84C55),
                  backgroundColor: const Color(0xFFFFECEE),
                ),
                const SizedBox(width: 9),
                SummaryCard(
                  title: 'Current Balance',
                  amount: summary.currentBalance,
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFF3559C7),
                  backgroundColor: const Color(0xFFEBF0FF),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${_transactions.length} total',
                  style: const TextStyle(
                    color: Color(0xFF818897),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addTransactionFab'),
        onPressed: _addTransaction,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add transaction'),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadTransactions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 10, 32, 70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 35,
                  color: Color(0xFF3559C7),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No transactions yet',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              const Text(
                'Add your first income or expense to see your financial summary here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF818897), height: 1.45),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        key: const Key('transactionList'),
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 100),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return TransactionTile(
            key: ValueKey(transaction.id ?? '${transaction.title}-$index'),
            transaction: transaction,
            onTap: () => _openTransaction(transaction),
          );
        },
      ),
    );
  }
}
