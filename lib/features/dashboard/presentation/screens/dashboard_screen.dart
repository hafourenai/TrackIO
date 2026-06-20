import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/income_expense_chart.dart';
import '../widgets/prediction_card.dart';
import '../widgets/score_card.dart';
import '../widgets/summary_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardDataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MoneyMind AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: dashboardDataAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardDataProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              BalanceCard(
                totalBalance: data.totalBalance,
                monthlyIncome: data.monthlyIncome,
                monthlyExpense: data.monthlyExpense,
                monthlySavings: data.monthlySavings,
              ),
              const SizedBox(height: 16),
              const ScoreCard(),
              const SizedBox(height: 12),
              const PredictionCard(),
              const SizedBox(height: 16),
              SummarySection(
                monthlyIncome: data.monthlyIncome,
                monthlyExpense: data.monthlyExpense,
                monthlySavings: data.monthlySavings,
              ),
              const SizedBox(height: 16),
              IncomeExpenseChart(weeklyExpenses: data.weeklyExpenses),
              const SizedBox(height: 16),
              CategoryPieChart(categoryExpenses: data.categoryExpenses),
              const SizedBox(height: 80),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
