import '../../../domain/entities/transaction.dart';

class FinancialHealthReport {
  final double totalScore;
  final String status; // 'Buruk', 'Cukup', 'Baik', 'Sangat Baik'
  final String description;
  final double savingScore;
  final double expenseScore;
  final double consistencyScore;
  final double stabilityScore;

  FinancialHealthReport({
    required this.totalScore,
    required this.status,
    required this.description,
    required this.savingScore,
    required this.expenseScore,
    required this.consistencyScore,
    required this.stabilityScore,
  });
}

class ScoreCalculator {
  static FinancialHealthReport calculate(
    List<Transaction> allTransactions,
    double monthlyIncome,
    double monthlyExpense,
  ) {
    if (allTransactions.isEmpty) {
      return FinancialHealthReport(
        totalScore: 0,
        status: 'Buruk',
        description: 'Belum ada data keuangan untuk dinilai. Silakan catat transaksi Anda.',
        savingScore: 0,
        expenseScore: 0,
        consistencyScore: 0,
        stabilityScore: 0,
      );
    }

    double savingScore = 0.0;
    if (monthlyIncome > 0) {
      final savings = monthlyIncome - monthlyExpense;
      final savingRatio = savings / monthlyIncome;
      if (savingRatio >= 0.20) {
        savingScore = 30.0;
      } else if (savingRatio > 0) {
        savingScore = (savingRatio / 0.20) * 30.0;
      }
    }

    double expenseScore = 0.0;
    if (monthlyIncome > 0) {
      final expenseRatio = monthlyExpense / monthlyIncome;
      if (expenseRatio <= 0.50) {
        expenseScore = 25.0;
      } else if (expenseRatio < 1.0) {
        expenseScore = 25.0 * (1 - (expenseRatio - 0.50) / 0.50);
      }
    } else {
      if (monthlyExpense > 0) {
        expenseScore = 0.0;
      } else {
        expenseScore = 25.0;
      }
    }

    double consistencyScore = 0.0;
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    final twoMonthsAgoStart = DateTime(now.year, now.month - 2, 1);

    final hasCurrentIncome = allTransactions.any((tx) =>
        tx.type == 'income' &&
        tx.date.isAfter(currentMonthStart.subtract(const Duration(seconds: 1))));
    
    final hasPrevIncome = allTransactions.any((tx) =>
        tx.type == 'income' &&
        tx.date.isAfter(prevMonthStart.subtract(const Duration(seconds: 1))) &&
        tx.date.isBefore(currentMonthStart));

    final hasTwoMonthsAgoIncome = allTransactions.any((tx) =>
        tx.type == 'income' &&
        tx.date.isAfter(twoMonthsAgoStart.subtract(const Duration(seconds: 1))) &&
        tx.date.isBefore(prevMonthStart));

    var incomeMonthsCount = 0;
    if (hasCurrentIncome) incomeMonthsCount++;
    if (hasPrevIncome) incomeMonthsCount++;
    if (hasTwoMonthsAgoIncome) incomeMonthsCount++;

    if (incomeMonthsCount == 3) {
      consistencyScore = 25.0;
    } else if (incomeMonthsCount == 2) {
      consistencyScore = 18.0;
    } else if (incomeMonthsCount == 1) {
      consistencyScore = 10.0;
    } else {
      consistencyScore = 0.0;
    }

    double stabilityScore = 0.0;
    final savings = monthlyIncome - monthlyExpense;
    if (savings > 0) {
      stabilityScore = 20.0;
    } else if (savings == 0) {
      stabilityScore = 10.0;
    } else {
      stabilityScore = 0.0;
    }

    final totalScore = savingScore + expenseScore + consistencyScore + stabilityScore;

    String status;
    String description;

    if (totalScore >= 90) {
      status = 'Sangat Baik';
      description = 'Luar biasa! Pengelolaan keuangan Anda sangat sehat. Anda memiliki tabungan yang tinggi, pengeluaran terkontrol, dan stabilitas finansial yang sangat kuat. Pertahankan disiplin ini!';
    } else if (totalScore >= 70) {
      status = 'Baik';
      description = 'Kondisi keuangan Anda dalam keadaan baik dan sehat. Anda mampu menabung dan mengendalikan pengeluaran dengan cukup baik. Cobalah untuk lebih konsisten atau meningkatkan porsi tabungan Anda.';
    } else if (totalScore >= 40) {
      status = 'Cukup';
      description = 'Kondisi keuangan Anda cukup stabil namun perlu waspada. Anda mungkin memiliki pengeluaran yang hampir mendekati pemasukan, sehingga sisa saldo untuk ditabung sangat minim.';
    } else {
      status = 'Buruk';
      description = 'Perhatian! Kesehatan keuangan Anda dalam kondisi kurang baik. Pengeluaran Anda melebihi atau menyamai pemasukan, atau Anda belum mencatatkan pemasukan yang cukup. Segera kurangi pengeluaran non-primer.';
    }

    return FinancialHealthReport(
      totalScore: totalScore,
      status: status,
      description: description,
      savingScore: savingScore,
      expenseScore: expenseScore,
      consistencyScore: consistencyScore,
      stabilityScore: stabilityScore,
    );
  }
}
