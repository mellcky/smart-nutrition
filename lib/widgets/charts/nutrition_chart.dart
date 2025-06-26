import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../utils/progress_analyzer.dart';

class NutritionChart extends StatelessWidget {
  final List<NutritionSummary> data;
  final String selectedMetric;
  final TimePeriod period;
  final Function(DateTime)? onBarTapped;

  const NutritionChart({
    super.key,
    required this.data,
    required this.selectedMetric,
    required this.period,
    this.onBarTapped,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = _getMaxYValue();
    final minY = _getMinYValue();
    final interval = _getInterval();

    return BarChart(
      BarChartData(
        minY: minY,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (response != null && response.spot != null) {
              final index = response.spot!.touchedBarGroupIndex;
              if (index >= 0 && index < data.length && onBarTapped != null) {
                onBarTapped!(data[index].date);
              }
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length)
                  return const SizedBox.shrink();
                final date = data[value.toInt()].date;

                // For weekly view, ensure we start from Monday
                if (period == TimePeriod.weekly) {
                  // If it's Monday, show "Mon", otherwise just the day initial
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt() == 0
                          ? 'Mon'
                          : DateFormat('E').format(date)[0],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM dd').format(date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getYLabel(value),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                );
              },
              interval: interval,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1, // Will be overridden by the interval
        ),
        barGroups:
            data.asMap().entries.map((e) {
              final index = e.key;
              final summary = e.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: _getMetricValue(summary),
                    color: _getColor(selectedMetric),
                    width: period == TimePeriod.weekly ? 16 : 12,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: Colors.grey[100],
                    ),
                  ),
                ],
              );
            }).toList(),
        alignment: BarChartAlignment.spaceAround,
      ),
    );
  }

  double _getMetricValue(NutritionSummary summary) {
    switch (selectedMetric) {
      case 'calories':
        return summary.calories;
      case 'protein':
        return summary.protein;
      case 'carbs':
        return summary.carbs;
      case 'fats':
        return summary.fats;
      case 'sugar':
        return summary.sugar;
      case 'sodium':
        return summary.sodium;
      case 'saturatedFat':
        return summary.saturatedFat;
      default:
        return summary.calories;
    }
  }

  String _getYLabel(double value) {
    if (selectedMetric == 'calories') return '${value.toInt()}';
    if (selectedMetric == 'sodium')
      return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  double _getInterval() {
    switch (selectedMetric) {
      case 'calories':
        return 500;
      case 'protein':
        return 20;
      case 'carbs':
        return 30;
      case 'fats':
        return 15;
      case 'sugar':
        return 10;
      case 'sodium':
        return 1000;
      case 'saturatedFat':
        return 5;
      default:
        return 100;
    }
  }

  double _getMaxYValue() {
    double maxValue = 0;
    for (var summary in data) {
      final value = _getMetricValue(summary);
      if (value > maxValue) maxValue = value;
    }

    // Add 25% padding and round up to nearest interval
    final interval = _getInterval();
    return (maxValue * 1.25).ceilToDouble() + interval;
  }

  double _getMinYValue() {
    // For most metrics, min should be 0, but for some we might want negative values
    return 0;
  }

  Color _getColor(String metric) {
    switch (metric) {
      case 'protein':
        return const Color(0xFF4285F4); // Blue
      case 'carbs':
        return const Color(0xFFFBBC05); // Yellow
      case 'fats':
        return const Color(0xFFEA4335); // Red
      case 'sugar':
        return const Color(0xFFF538B1); // Pink
      case 'sodium':
        return const Color(0xFF34A853); // Green
      case 'saturatedFat':
        return const Color(0xFF673AB7); // Purple
      default:
        return const Color(0xFF4285F4); // Blue
    }
  }
}
