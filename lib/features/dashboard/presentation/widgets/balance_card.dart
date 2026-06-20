import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlySavings;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySavings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Saldo',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(totalBalance),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  context,
                  label: 'Pemasukan',
                  amount: monthlyIncome,
                  color: Colors.teal,
                  icon: Icons.arrow_upward_rounded,
                ),
                _buildSummaryItem(
                  context,
                  label: 'Pengeluaran',
                  amount: monthlyExpense,
                  color: Colors.red,
                  icon: Icons.arrow_downward_rounded,
                ),
                _buildSummaryItem(
                  context,
                  label: 'Tabungan',
                  amount: monthlySavings,
                  color: Colors.teal.shade300,
                  icon: Icons.savings_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormatter.format(amount),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
