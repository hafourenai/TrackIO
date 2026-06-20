import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/prediction_provider.dart';
import '../widgets/prediction_chart.dart';

class PredictionScreen extends ConsumerWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(predictionFutureProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediksi Saldo Akhir Bulan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: predictionAsync.when(
        data: (report) => RefreshIndicator(
          onRefresh: () => ref.refresh(predictionFutureProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimasi Saldo Akhir Bulan',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(report.predictedEndBalance),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: report.predictedEndBalance < 0 
                              ? Colors.red[800] 
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        report.trendMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metrik Proyeksi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricRow(
                        context,
                        label: 'Saldo Saat Ini',
                        value: CurrencyFormatter.format(report.currentBalance),
                      ),
                      const Divider(),
                      _buildMetricRow(
                        context,
                        label: 'Rata-rata Pengeluaran / Hari',
                        value: CurrencyFormatter.format(report.averageDailyExpense),
                      ),
                      const Divider(),
                      _buildMetricRow(
                        context,
                        label: 'Sisa Pengeluaran Diproyeksikan',
                        value: CurrencyFormatter.format(report.estimatedRemainingExpense),
                        color: Colors.orange[800],
                      ),
                      const Divider(),
                      _buildMetricRow(
                        context,
                        label: 'Total Estimasi Pengeluaran',
                        value: CurrencyFormatter.format(report.totalEstimatedExpense),
                        color: Colors.red[800],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PredictionChart(dailyExpenses: report.dailyExpenses),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
