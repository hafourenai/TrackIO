import '../../../domain/entities/transaction.dart';

class PredictionReport {
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double averageDailyExpense;
  final double estimatedRemainingExpense;
  final double totalEstimatedExpense;
  final double predictedEndBalance;
  final String trendMessage;
  final List<double> dailyExpenses;

  PredictionReport({
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.averageDailyExpense,
    required this.estimatedRemainingExpense,
    required this.totalEstimatedExpense,
    required this.predictedEndBalance,
    required this.trendMessage,
    required this.dailyExpenses,
  });
}

class PredictionEngine {
  static PredictionReport predict(
    List<Transaction> allTransactions,
    double currentBalance,
    double monthlyIncome,
    double monthlyExpense,
  ) {
    final now = DateTime.now();
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final elapsedDays = now.day;

    final avgDailyExpense = elapsedDays > 0 ? monthlyExpense / elapsedDays : 0.0;
    final remainingDays = totalDaysInMonth - elapsedDays;
    final estimatedRemainingExpense = avgDailyExpense * remainingDays;
    final totalEstimatedExpense = monthlyExpense + estimatedRemainingExpense;
    
    final predictedEndBalance = currentBalance - estimatedRemainingExpense;

    final List<double> dailyExpenses = List.filled(totalDaysInMonth, 0.0);
    final currentMonthStart = DateTime(now.year, now.month, 1);
    
    for (final tx in allTransactions) {
      if (tx.type == 'expense' && 
          tx.date.isAfter(currentMonthStart.subtract(const Duration(seconds: 1)))) {
        final dayIndex = tx.date.day - 1;
        if (dayIndex >= 0 && dayIndex < totalDaysInMonth) {
          dailyExpenses[dayIndex] += tx.amount;
        }
      }
    }

    String trendMessage = '';
    if (predictedEndBalance < 0) {
      trendMessage = 'Peringatan: Saldo akhir bulan Anda diproyeksikan minus. Segera kurangi pengeluaran harian Anda!';
    } else if (predictedEndBalance < currentBalance * 0.5) {
      trendMessage = 'Waspada: Saldo Anda diproyeksikan menurun lebih dari 50% di akhir bulan.';
    } else {
      trendMessage = 'Aman: Saldo akhir bulan Anda diproyeksikan dalam kondisi stabil dan terkendali.';
    }

    return PredictionReport(
      currentBalance: currentBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      averageDailyExpense: avgDailyExpense,
      estimatedRemainingExpense: estimatedRemainingExpense,
      totalEstimatedExpense: totalEstimatedExpense,
      predictedEndBalance: predictedEndBalance,
      trendMessage: trendMessage,
      dailyExpenses: dailyExpenses,
    );
  }
}
