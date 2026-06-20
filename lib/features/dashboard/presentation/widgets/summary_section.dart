import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class SummarySection extends StatelessWidget {
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlySavings;

  const SummarySection({
    super.key,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySavings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Keuangan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              label: 'Pemasukan bulan ini',
              value: CurrencyFormatter.format(monthlyIncome),
              color: Colors.teal,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              label: 'Pengeluaran bulan ini',
              value: CurrencyFormatter.format(monthlyExpense),
              color: Colors.red,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              label: 'Sisa saldo',
              value: CurrencyFormatter.format(monthlySavings),
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
