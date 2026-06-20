import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/repositories/transaction_repository_impl.dart';
import '../../../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_picker.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final int? transactionId;

  const AddEditTransactionScreen({
    super.key,
    this.transactionId,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _type = 'expense';
  String _category = 'makan';
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    setState(() => _isLoading = true);
    final repo = ref.read(transactionRepositoryProvider);
    final tx = await repo.getTransactionById(widget.transactionId!);
    if (tx != null) {
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note ?? '';
      setState(() {
        _type = tx.type;
        _category = tx.category;
        _date = tx.date;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CategoryPicker(
          selectedCategory: _category,
          transactionType: _type,
          onCategorySelected: (cat) {
            setState(() {
              _category = cat;
            });
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih besar dari 0')),
      );
      return;
    }

    final tx = Transaction(
      id: widget.transactionId,
      title: _titleController.text.trim(),
      date: _date,
      type: _type,
      category: _category,
      amount: amount,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() => _isLoading = true);
    if (widget.transactionId == null) {
      await ref.read(transactionControllerProvider).addTransaction(tx);
    } else {
      await ref.read(transactionControllerProvider).updateTransaction(tx);
    }
    setState(() => _isLoading = false);
    
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.transactionId != null;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Transaksi' : 'Tambah Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Pengeluaran'),
                  icon: Icon(Icons.arrow_downward_rounded, color: Colors.red),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Pemasukan'),
                  icon: Icon(Icons.arrow_upward_rounded, color: Colors.teal),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (val) {
                setState(() {
                  _type = val.first;
                  _category = _type == 'income'
                      ? CategoryConstants.incomeCategories.first
                      : CategoryConstants.expenseCategories.first;
                });
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nama Transaksi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_rounded),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (val) => val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_rounded),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (val) => val == null || val.trim().isEmpty ? 'Nominal wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: const Icon(Icons.calendar_month_rounded),
              title: const Text('Tanggal'),
              subtitle: Text(DateFormatter.formatFull(_date)),
              trailing: const Icon(Icons.arrow_drop_down_rounded),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: CircleAvatar(
                backgroundColor: CategoryConstants.getColor(_category).withValues(alpha: 0.15),
                child: Icon(
                  CategoryConstants.getIcon(_category),
                  color: CategoryConstants.getColor(_category),
                ),
              ),
              title: const Text('Kategori'),
              subtitle: Text(_category[0].toUpperCase() + _category.substring(1)),
              trailing: const Icon(Icons.arrow_drop_down_rounded),
              onTap: _showCategoryPicker,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_rounded),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
