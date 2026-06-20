import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/transaction_repository_impl.dart';
import '../../../../domain/usecases/get_dashboard_data.dart';

final dashboardDataProvider = StreamProvider<DashboardData>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions().asyncMap((_) async {
    final useCase = GetDashboardData(repository);
    return await useCase.execute();
  });
});
