import 'package:flutter/material.dart';

import '../data/transaction_repository.dart';
import '../models/expense_transaction.dart';
import '../utils/formatters.dart';
import 'add_edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.repository,
    required this.transaction,
  });

  final TransactionRepository repository;
  final ExpenseTransaction transaction;

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late ExpenseTransaction _transaction;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _editTransaction() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(
          repository: widget.repository,
          transaction: _transaction,
        ),
      ),
    );

    if (changed != true || !mounted) return;

    final transactions = await widget.repository.getAllTransactions();
    final updated = transactions.where((item) => item.id == _transaction.id);
    if (!mounted || updated.isEmpty) return;

    setState(() => _transaction = updated.first);
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text(
          'Are you sure you want to delete "${_transaction.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD84C55),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final id = _transaction.id;
      if (id != null) await widget.repository.deleteTransaction(id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the transaction. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _transaction.type == TransactionType.income;
    final accent = isIncome ? const Color(0xFF16865B) : const Color(0xFFD84C55);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFECEEF3)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 29,
                    backgroundColor: accent.withValues(alpha: 0.10),
                    child: Icon(
                      isIncome
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      color: accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _transaction.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isIncome ? '+' : '−'}${formatCurrency(_transaction.amount)}',
                    style: TextStyle(
                      color: accent,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _transaction.type.label,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Transaction information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _detailRow(
              'Category',
              _transaction.category,
              Icons.category_outlined,
            ),
            _detailRow(
              'Date',
              formatDate(_transaction.date),
              Icons.calendar_month_outlined,
            ),
            _detailRow(
              'Transaction type',
              _transaction.type.label,
              Icons.swap_vert_rounded,
            ),
            if (_transaction.id != null)
              _detailRow(
                'Transaction ID',
                '#${_transaction.id}',
                Icons.tag_rounded,
              ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: _editTransaction,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Transaction'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 11),
            OutlinedButton.icon(
              onPressed: _isDeleting ? null : _deleteTransaction,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(_isDeleting ? 'Deleting...' : 'Delete Transaction'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD84C55),
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: Color(0xFFF0C8CC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECEEF3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF727B8C), size: 19),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF818897)),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
