import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final List<double> analysisCounts;
  final double maxY;
  final List<String> analysisNamesList;
  final bool isLoading;  // Agregar propiedad para verificar si los datos están cargando

  const BarChartWidget({
    Key? key,
    required this.analysisCounts,
    required this.maxY,
    required this.analysisNamesList,
    this.isLoading = false,  // Por defecto, el indicador de carga es falso
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Mostrar el CircularProgressIndicator si está cargando
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // Si no está cargando, mostrar el gráfico de barras
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
                    angle: -0.0,
                    child: Text(
                      analysisNamesList[index],
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
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