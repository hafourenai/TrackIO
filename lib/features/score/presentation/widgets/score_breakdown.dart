import 'package:flutter/material.dart';

class ScoreBreakdown extends StatelessWidget {
  final double savingScore;
  final double expenseScore;
  final double consistencyScore;
  final double stabilityScore;

  const ScoreBreakdown({
    super.key,
    required this.savingScore,
    required this.expenseScore,
    required this.consistencyScore,
    required this.stabilityScore,
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
              'Rincian Penilaian',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildComponentRow(
              context,
              label: 'Rasio Tabungan (Savings)',
              value: savingScore,
              max: 30,
              color: Colors.blue,
            ),
            const Divider(height: 24),
            _buildComponentRow(
              context,
              label: 'Rasio Pengeluaran (Expense)',
              value: expenseScore,
              max: 25,
              color: Colors.green,
            ),
            const Divider(height: 24),
            _buildComponentRow(
              context,
              label: 'Konsistensi Pemasukan',
              value: consistencyScore,
              max: 25,
              color: Colors.teal,
            ),
            const Divider(height: 24),
            _buildComponentRow(
              context,
              label: 'Kestabilan Saldo',
              value: stabilityScore,
              max: 20,
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentRow(
    BuildContext context, {
    required String label,
    required double value,
    required double max,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final percent = value / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} / ${max.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
