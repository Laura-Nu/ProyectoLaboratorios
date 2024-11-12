import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> dataPoints;
  final List<String> labels;
  final double maxY;
  final bool rotateLabels;
  final double labelRotationAngle;

  const LineChartWidget({
    Key? key,
    required this.dataPoints,
    required this.labels,
    required this.maxY,
    this.rotateLabels = false,
    this.labelRotationAngle = 45.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Transform.rotate(
                    angle: rotateLabels ? labelRotationAngle * (3.14159 / 180) : 0,
                    child: Text(
                      labels[index],
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              interval: 1,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Oculta los títulos superiores
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints.asMap().entries.map((entry) {
              int index = entry.key;
              double value = entry.value;
              return FlSpot(index.toDouble(), value);
            }).toList(),
            isCurved: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        gridData: FlGridData(show: true),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 1),
        ),
      ),
    );
  }
}
