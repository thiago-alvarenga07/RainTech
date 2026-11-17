import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Gráfico de barras verticais para valores por categoria ou por dia.
class CategoryBarChart extends StatelessWidget {
  const CategoryBarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.formatValue,
    this.barColors,
    this.threshold,
  });

  final List<String> labels;
  final List<double> values;
  final String Function(double value) formatValue;

  final List<Color>? barColors;

  final double? threshold;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant);
    final barWidth = values.length > 10 ? 8.0 : 22.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: colors.outlineVariant, strokeWidth: 0.6),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (threshold != null)
              HorizontalLine(
                y: threshold!,
                color: colors.error,
                strokeWidth: 1.2,
                dashArray: [6, 4],
              ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(formatValue(value), style: labelStyle),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final everyOther = labels.length > 10 && index.isOdd;
                if (index < 0 || index >= labels.length || everyOther) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(labels[index], style: labelStyle),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colors.inverseSurface,
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${labels[group.x]}: ${formatValue(rod.toY)}',
              TextStyle(color: colors.onInverseSurface, fontSize: 12),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: barWidth,
                  color: barColors?[i] ?? colors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}