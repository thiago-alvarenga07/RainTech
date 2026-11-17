import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.series,
    required this.formatValue,
    this.minY,
    this.maxY,
    this.thresholds = const [],
    this.color,
  });

  final List<(DateTime, double)> series;
  final String Function(double value) formatValue;
  final double? minY;
  final double? maxY;
  final List<double> thresholds;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lineColor = color ?? colors.primary;
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant);

    if (series.length < 2) {
      return Center(
        child: Text('Histórico insuficiente para o gráfico.', style: labelStyle),
      );
    }

    final spots = [
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].$2),
    ];
    final step = (series.length / 4).ceilToDouble();

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: colors.outlineVariant, strokeWidth: 0.6),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
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
              interval: step,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= series.length) {
                  return const SizedBox.shrink();
                }
                final date = series[index].$1;
                return SideTitleWidget(
                  meta: meta,
                  child: Text('${date.day}/${date.month}', style: labelStyle),
                );
              },
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            for (final y in thresholds)
              HorizontalLine(
                y: y,
                color: colors.error,
                strokeWidth: 1.2,
                dashArray: [6, 4],
              ),
          ],
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => colors.inverseSurface,
            getTooltipItems: (touched) => touched.map((spot) {
              final date = series[spot.x.toInt()].$1;
              return LineTooltipItem(
                '${date.day}/${date.month}: ${formatValue(spot.y)}',
                TextStyle(color: colors.onInverseSurface, fontSize: 12),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: lineColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}