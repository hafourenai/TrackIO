import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/transaction_provider.dart';

class FilterWidget extends ConsumerWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(transactionTypeFilterProvider);
    final selectedCategory = ref.watch(transactionCategoryFilterProvider);
    final dateRange = ref.watch(transactionDateRangeProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          PopupMenuButton<String>(
            initialValue: selectedType,
            onSelected: (val) => ref.read(transactionTypeFilterProvider.notifier).state = val,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('Semua Tipe')),
              PopupMenuItem(value: 'income', child: Text('Pemasukan')),
              PopupMenuItem(value: 'expense', child: Text('Pengeluaran')),
            ],
            child: FilterChip(
              label: Text(
                selectedType == 'all'
                    ? 'Semua Tipe'
                    : (selectedType == 'income' ? 'Pemasukan' : 'Pengeluaran'),
              ),
              selected: selectedType != 'all',
              onSelected: (_) {},
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            initialValue: selectedCategory,
            onSelected: (val) => ref.read(transactionCategoryFilterProvider.notifier).state = val,
            itemBuilder: (context) {
              final list = ['all', ...CategoryConstants.incomeCategories, ...CategoryConstants.expenseCategories];
              return list.map((cat) {
                final display = cat == 'all' ? 'Semua Kategori' : cat[0].toUpperCase() + cat.substring(1);
                return PopupMenuItem(
                  value: cat,
                  child: Text(display),
                );
              }).toList();
            },
            child: FilterChip(
              label: Text(
                selectedCategory == 'all'
                    ? 'Semua Kategori'
                    : selectedCategory[0].toUpperCase() + selectedCategory.substring(1),
              ),
              selected: selectedCategory != 'all',
              onSelected: (_) {},
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              dateRange == null
                  ? 'Semua Tanggal'
                  : '${DateFormatter.formatShort(dateRange.start)} - ${DateFormatter.formatShort(dateRange.end)}',
            ),
            selected: dateRange != null,
            onSelected: (_) async {
              if (dateRange != null) {
                ref.read(transactionDateRangeProvider.notifier).state = null;
                return;
              }
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: dateRange,
              );
              if (picked != null) {
                ref.read(transactionDateRangeProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
    );
  }
}
