import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/transaction_repository_impl.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/recommendation_engine.dart';

final recommendationsFutureProvider = FutureProvider<List<RecommendationInsight>>((ref) async {
  final dashboard = await ref.watch(dashboardDataProvider.future);
  final repository = ref.watch(transactionRepositoryProvider);
  final all = await repository.getAllTransactions();
  return RecommendationEngine.generateInsights(
    all,
    dashboard.monthlyIncome,
    dashboard.monthlyExpense,
    dashboard.categoryExpenses,
  );
});
