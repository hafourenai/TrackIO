import '../../../domain/entities/transaction.dart';

class RecommendationInsight {
  final String title;
  final String description;
  final String recommendation;
  final bool isWarning;

  RecommendationInsight({
    required this.title,
    required this.description,
    required this.recommendation,
    required this.isWarning,
  });
}

class RecommendationEngine {
  static List<RecommendationInsight> generateInsights(
    List<Transaction> allTransactions,
    double monthlyIncome,
    double monthlyExpense,
    Map<String, double> categoryExpenses,
  ) {
    final List<RecommendationInsight> insights = [];

    if (allTransactions.isEmpty) {
      insights.add(
        RecommendationInsight(
          title: 'Belum Ada Transaksi',
          description: 'Anda belum mencatat transaksi apa pun.',
          recommendation: 'Mulailah mencatat pemasukan dan pengeluaran harian Anda agar AI dapat menganalisis kebiasaan finansial Anda.',
          isWarning: false,
        ),
      );
      return insights;
    }

    final totalExpense = categoryExpenses.values.fold(0.0, (sum, val) => sum + val);

    if (totalExpense > 0) {
      String largestCategory = '';
      double largestAmount = 0.0;

      categoryExpenses.forEach((cat, amt) {
        if (amt > largestAmount) {
          largestAmount = amt;
          largestCategory = cat;
        }
      });

      final pct = (largestAmount / totalExpense) * 100;
      final displayCategory = largestCategory[0].toUpperCase() + largestCategory.substring(1);

      if (largestCategory == 'makan' && pct > 30) {
        insights.add(
          RecommendationInsight(
            title: 'Pengeluaran Makan Tinggi',
            description: 'Pengeluaran makan Anda mencapai ${pct.toStringAsFixed(0)}% dari total pengeluaran bulan ini.',
            recommendation: 'Disarankan untuk mengurangi pengeluaran makan sebesar 10% dengan memasak di rumah atau merencanakan makan mingguan.',
            isWarning: true,
          ),
        );
      } else if (largestCategory == 'belanja' && pct > 20) {
        insights.add(
          RecommendationInsight(
            title: 'Pengeluaran Belanja Tinggi',
            description: 'Pengeluaran belanja Anda mencapai ${pct.toStringAsFixed(0)}% dari total pengeluaran bulan ini.',
            recommendation: 'Disarankan membatasi belanja non-primer sebesar 10% dan membuat daftar belanja yang ketat sebelum pergi.',
            isWarning: true,
          ),
        );
      } else if (largestCategory == 'hiburan' && pct > 15) {
        insights.add(
          RecommendationInsight(
            title: 'Biaya Hiburan Tinggi',
            description: 'Pengeluaran hiburan Anda mencapai ${pct.toStringAsFixed(0)}% dari total pengeluaran bulan ini.',
            recommendation: 'Disarankan mencari alternatif hiburan gratis atau menetapkan batas anggaran hiburan bulanan yang lebih rendah.',
            isWarning: true,
          ),
        );
      } else if (largestAmount > 0) {
        insights.add(
          RecommendationInsight(
            title: 'Kategori Pengeluaran Terbesar',
            description: 'Kategori pengeluaran terbesar Anda bulan ini adalah $displayCategory sebesar ${pct.toStringAsFixed(0)}% dari total.',
            recommendation: 'Cobalah untuk mengevaluasi kembali pos anggaran $displayCategory agar dapat menghemat hingga 10% di bulan depan.',
            isWarning: false,
          ),
        );
      }
    }

    if (monthlyIncome > 0) {
      final savingsRate = (monthlyIncome - monthlyExpense) / monthlyIncome;
      if (savingsRate < 0.10) {
        final targetSavings = monthlyIncome * 0.20;
        final formattedTarget = "Rp${_formatNumber(targetSavings)}";
        insights.add(
          RecommendationInsight(
            title: 'Rasio Tabungan Rendah',
            description: 'Tabungan Anda bulan ini berada di bawah 10% dari total pemasukan.',
            recommendation: 'Disarankan menyisihkan uang di awal bulan. Target tabungan ideal Anda untuk bulan depan adalah $formattedTarget (20% dari pemasukan).',
            isWarning: true,
          ),
        );
      } else {
        final targetSavings = monthlyIncome * 0.25;
        final formattedTarget = "Rp${_formatNumber(targetSavings)}";
        insights.add(
          RecommendationInsight(
            title: 'Kondisi Keuangan Sehat',
            description: 'Bagus! Anda berhasil menabung lebih dari 10% dari pemasukan bulan ini.',
            recommendation: 'Pertahankan kebiasaan ini. Untuk mempercepat pencapaian finansial Anda, coba tingkatkan target tabungan bulan depan menjadi $formattedTarget.',
            isWarning: false,
          ),
        );
      }
    } else {
      insights.add(
        RecommendationInsight(
          title: 'Catat Pemasukan Anda',
          description: 'Belum ada catatan pemasukan untuk bulan ini.',
          recommendation: 'Segera catat pemasukan Anda agar sistem dapat menganalisis rasio tabungan dan menyusun rencana anggaran yang ideal.',
          isWarning: false,
        ),
      );
    }

    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

    final lastMonthExpenses = allTransactions
        .where((tx) =>
            tx.type == 'expense' &&
            tx.date.isAfter(lastMonthStart.subtract(const Duration(seconds: 1))) &&
            tx.date.isBefore(lastMonthEnd.add(const Duration(seconds: 1))))
        .fold(0.0, (sum, tx) => sum + tx.amount);

    if (lastMonthExpenses > 0) {
      if (monthlyExpense > lastMonthExpenses) {
        final increase = ((monthlyExpense - lastMonthExpenses) / lastMonthExpenses) * 100;
        insights.add(
          RecommendationInsight(
            title: 'Kenaikan Pengeluaran',
            description: 'Pengeluaran Anda naik sebesar ${increase.toStringAsFixed(0)}% dibandingkan bulan lalu.',
            recommendation: 'Waspadai pengeluaran impulsif. Tinjau kembali catatan transaksi Anda untuk mengidentifikasi pembengkakan pengeluaran.',
            isWarning: true,
          ),
        );
      } else {
        final decrease = ((lastMonthExpenses - monthlyExpense) / lastMonthExpenses) * 100;
        insights.add(
          RecommendationInsight(
            title: 'Penurunan Pengeluaran',
            description: 'Luar biasa! Pengeluaran Anda hemat ${decrease.toStringAsFixed(0)}% dibandingkan bulan lalu.',
            recommendation: 'Pertahankan disiplin belanja ini. Sisa dana dapat Anda alokasikan langsung ke rekening tabungan atau dana darurat.',
            isWarning: false,
          ),
        );
      }
    }

    return insights;
  }

  static String _formatNumber(double val) {
    final str = val.toStringAsFixed(0);
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}
