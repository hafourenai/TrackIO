import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/ocr_service.dart';

class OcrResultCard extends StatefulWidget {
  final OcrResult result;
  final ValueChanged<Map<String, dynamic>> onConfirmed;

  const OcrResultCard({
    super.key,
    required this.result,
    required this.onConfirmed,
  });

  @override
  State<OcrResultCard> createState() => _OcrResultCardState();
}

class _OcrResultCardState extends State<OcrResultCard> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late DateTime _date;
  late String _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.result.storeName);
    _amountController = TextEditingController(text: widget.result.totalAmount.toStringAsFixed(0));
    _date = widget.result.date;
    _category = 'belanja';
  }

  @override
  void didUpdateWidget(covariant OcrResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result != widget.result) {
      _titleController.text = widget.result.storeName;
      _amountController.text = widget.result.totalAmount.toStringAsFixed(0);
      setState(() {
        _date = widget.result.date;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Hasil Pemindaian Struk',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!widget.result.isSure)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Deteksi data kurang yakin. Silakan periksa & koreksi bidang di bawah.',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Toko / Transaksi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama toko wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Total Belanja (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => val == null || val.trim().isEmpty ? 'Total belanja wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_month_rounded),
                title: const Text('Tanggal Struk'),
                subtitle: Text(DateFormatter.formatFull(_date)),
                trailing: const Icon(Icons.arrow_drop_down_rounded),
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori Pengeluaran',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: CategoryConstants.expenseCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat[0].toUpperCase() + cat.substring(1)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _category = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onConfirmed({
                        'title': _titleController.text.trim(),
                        'amount': double.tryParse(_amountController.text) ?? 0.0,
                        'date': _date,
                        'category': _category,
                      });
                    }
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Konfirmasi & Simpan Transaksi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
