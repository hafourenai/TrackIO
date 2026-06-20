import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class DashboardData {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlySavings;
  final List<Transaction> recentTransactions;
  final Map<String, double> categoryExpenses;
  final List<double> weeklyExpenses;

  DashboardData({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySavings,
    required this.recentTransactions,
    required this.categoryExpenses,
    required this.weeklyExpenses,
  });
}

class GetDashboardData {
  final TransactionRepository repository;

  GetDashboardData(this.repository);

  Future<DashboardData> execute() async {
    final allTransactions = await repository.getAllTransactions();
    
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (final tx in allTransactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    
    final totalBalance = totalIncome - totalExpense;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthlyTransactions = allTransactions.where((tx) =>
        tx.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
        tx.date.isBefore(endOfMonth.add(const Duration(seconds: 1))));

    double monthlyIncome = 0;
    double monthlyExpense = 0;
    final Map<String, double> categoryExpenses = {};

    for (final tx in monthlyTransactions) {
      if (tx.type == 'income') {
        monthlyIncome += tx.amount;
      } else {
        monthlyExpense += tx.amount;
        categoryExpenses[tx.category] = (categoryExpenses[tx.category] ?? 0.0) + tx.amount;
      }
    }

    final monthlySavings = monthlyIncome - monthlyExpense;

    final recentTransactions = allTransactions.take(5).toList();

    final List<double> weeklyExpenses = List.filled(4, 0.0);
    for (final tx in monthlyTransactions) {
      if (tx.type == 'expense') {
        final day = tx.date.day;
        final weekIndex = ((day - 1) / 7).floor().clamp(0, 3);
        weeklyExpenses[weekIndex] += tx.amount;
      }
    }

    return DashboardData(
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      monthlySavings: monthlySavings,
      recentTransactions: recentTransactions,
      categoryExpenses: categoryExpenses,
      weeklyExpenses: weeklyExpenses,
    );
  }
}
