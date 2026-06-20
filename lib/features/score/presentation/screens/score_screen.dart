import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';
import '../widgets/score_breakdown.dart';
import '../widgets/score_gauge.dart';

class ScoreScreen extends ConsumerWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreReportAsync = ref.watch(financialScoreFutureProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skor Kesehatan Keuangan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: scoreReportAsync.when(
        data: (report) => RefreshIndicator(
          onRefresh: () => ref.refresh(financialScoreFutureProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 16),
              Center(
                child: ScoreGauge(
                  score: report.totalScore,
                  status: report.status,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisis Finansial',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ScoreBreakdown(
                savingScore: report.savingScore,
                expenseScore: report.expenseScore,
                consistencyScore: report.consistencyScore,
                stabilityScore: report.stabilityScore,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
