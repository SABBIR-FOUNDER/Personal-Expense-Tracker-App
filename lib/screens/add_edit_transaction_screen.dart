import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/transaction_repository.dart';
import '../models/expense_transaction.dart';
import '../utils/formatters.dart';

const transactionCategories = <String>[
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Health',
  'Education',
  'Entertainment',
  'Salary',
  'Business',
  'Gift',
  'Investment',
  'Other',
];

class AddEditTransactionScreen extends StatefulWidget {
  const AddEditTransactionScreen({
    super.key,
    required this.repository,
    this.transaction,
  });

  final TransactionRepository repository;
  final ExpenseTransaction? transaction;

  bool get isEditing => transaction != null;

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  String? _category;
  TransactionType? _type;
  late DateTime _selectedDate;
  bool _showTypeError = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(
      text: transaction == null ? '' : transaction.amount.toStringAsFixed(2),
    );
    _category = transaction?.category;
    _type = transaction?.type;
    final now = DateTime.now();
    _selectedDate = transaction?.date ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select transaction date',
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _saveTransaction() async {
    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTypeError = _type == null);

    if (!isFormValid || _type == null) return;

    final amount = double.parse(_amountController.text.trim());
    final transaction = ExpenseTransaction(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      category: _category!,
      type: _type!,
      date: _selectedDate,
    );

    setState(() => _isSaving = true);
    try {
      if (widget.isEditing) {
        await widget.repository.updateTransaction(transaction);
      } else {
        await widget.repository.insertTransaction(transaction);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the transaction. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              const Text(
                'Transaction information',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the details below. Your transaction is saved on this device.',
                style: TextStyle(color: Color(0xFF818897), height: 1.4),
              ),
              const SizedBox(height: 22),
              TextFormField(
                key: const Key('titleField'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Monthly salary or Grocery shopping',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('amountField'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount (৳)',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required.';
                  }
                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Enter a valid amount greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('categoryDropdown'),
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: transactionCategories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Please select a category.' : null,
              ),
              const SizedBox(height: 22),
              const Text(
                'Transaction type',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _typeChoice(
                      key: const Key('incomeChip'),
                      type: TransactionType.income,
                      icon: Icons.south_west_rounded,
                      color: const Color(0xFF16865B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _typeChoice(
                      key: const Key('expenseChip'),
                      type: TransactionType.expense,
                      icon: Icons.north_east_rounded,
                      color: const Color(0xFFD84C55),
                    ),
                  ),
                ],
              ),
              if (_showTypeError) ...[
                const SizedBox(height: 7),
                const Text(
                  'Please select income or expense.',
                  style: TextStyle(color: Color(0xFFB3261E), fontSize: 12),
                ),
              ],
              const SizedBox(height: 22),
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 9),
              OutlinedButton.icon(
                key: const Key('datePickerButton'),
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(formatDate(_selectedDate)),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: Color(0xFFDDE1EA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                key: const Key('saveTransactionButton'),
                onPressed: _isSaving ? null : _saveTransaction,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(isEditing ? 'Save Changes' : 'Save Transaction'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChoice({
    required Key key,
    required TransactionType type,
    required IconData icon,
    required Color color,
  }) {
    final selected = _type == type;
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() {
        _type = type;
        _showTypeError = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFFDDE1EA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              type.label,
              style: TextStyle(
                color: selected ? color : const Color(0xFF4F5665),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
