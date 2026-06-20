import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/category_constants.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryExpenses;

  const CategoryPieChart({
    super.key,
    required this.categoryExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalExpense = categoryExpenses.values.fold(0.0, (sum, val) => sum + val);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengeluaran Berdasarkan Kategori',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (totalExpense == 0)
              const SizedBox(
                height: 150,
                child: Center(
                  child: Text('Belum ada data pengeluaran bulan ini'),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 150,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 35,
                          sections: _buildPieSections(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryExpenses.entries.map((entry) {
                        final percentage = totalExpense > 0
                            ? (entry.value / totalExpense) * 100
                            : 0.0;
                        final color = CategoryConstants.getColor(entry.key);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key[0].toUpperCase() + entry.key.substring(1),
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return categoryExpenses.entries.map((entry) {
      final color = CategoryConstants.getColor(entry.key);
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '',
        radius: 40,
      );
    }).toList();
  }
}
