import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IncomeExpenseChart extends StatelessWidget {
  final List<double> weeklyExpenses;

  const IncomeExpenseChart({
    super.key,
    required this.weeklyExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengeluaran Mingguan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (weeklyExpenses.every((w) => w == 0))
              const SizedBox(
                height: 200,
                child: Center(
                  child: Text('Belum ada data pengeluaran mingguan'),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            );
                            Widget text;
                            switch (value.toInt()) {
                              case 0:
                                text = const Text('W1', style: style);
                                break;
                              case 1:
                                text = const Text('W2', style: style);
                                break;
                              case 2:
                                text = const Text('W3', style: style);
                                break;
                              case 3:
                                text = const Text('W4', style: style);
                                break;
                              default:
                                text = const Text('', style: style);
                                break;
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: text,
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(4, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyExpenses[i],
                            color: theme.colorScheme.primary,
                            width: 18,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (final val in weeklyExpenses) {
      if (val > max) max = val;
    }
    return max == 0 ? 100000 : max * 1.2;
  }
}
