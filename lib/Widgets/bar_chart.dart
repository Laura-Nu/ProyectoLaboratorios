import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final List<double> analysisCounts;
  final double maxY;
  final List<String> analysisNamesList;

  const BarChartWidget({
    Key? key,
    required this.analysisCounts,
    required this.maxY,
    required this.analysisNamesList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    int numberOfBars = analysisCounts.length;
    double dynamicWidth = (containerWidth / numberOfBars) * 0.4;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: analysisCounts.asMap().entries.map((entry) {
          int index = entry.key;
          double value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                width: dynamicWidth,
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index < analysisNamesList.length) {
                  return Transform.rotate(
                    angle: -0.3, 
                    child: Text(
                      analysisNamesList[index],
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
