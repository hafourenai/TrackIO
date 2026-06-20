import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/transaction_repository_impl.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/prediction_engine.dart';

final predictionFutureProvider = FutureProvider<PredictionReport>((ref) async {
  final dashboard = await ref.watch(dashboardDataProvider.future);
  final repository = ref.watch(transactionRepositoryProvider);
  final all = await repository.getAllTransactions();
  
  return PredictionEngine.predict(
    all,
    dashboard.totalBalance,
    dashboard.monthlyIncome,
    dashboard.monthlyExpense,
  );
});
