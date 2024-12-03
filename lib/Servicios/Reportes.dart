import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';
import 'package:laboratorios/Login.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String selectedRange = 'Día';
  List<String> timeRanges = ['Día', 'Semana', 'Mes'];
  double totalSales = 0.0;
  int totalAnalysis = 0;
  List<double> analysisCounts = [];
  double maxY = 10.0;
  int totalRegisteredPatients = 0;

  String selectedPatientId = '';
  String selectedPatientName = '';
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  String searchQuery = '';
  List<String> analysisNamesList = [];

  @override
  void initState() {
    super.initState();
    loadData();
    loadPatients();
    fetchAnalysisCounts();
    loadRegisteredPatients();
  }
Future<void> loadPatients() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('pacientes').get();
  patients = snapshot.docs.where((doc) {
    var data = doc.data() as Map<String, dynamic>;
    return data['nombre'] != null && data['nombre'] != '' &&
           data['apellido'] != null && data['apellido'] != '';
  }).map((doc) {
    var data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      'nombre': data['nombre'],
      'apellido': data['apellido'],
      'telefono': data['telefono'],
      'direccion': data['direccion'],
    };
  }).toList();
  filteredPatients = patients;
  setState(() {});
}


  Future<void> loadRegisteredPatients() async {
    DateTime now = DateTime.now();
    DateTime startDate;

    if (selectedRange == 'Día') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (selectedRange == 'Semana') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    } else if (selectedRange == 'Mes') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = now; 
    }

    Timestamp firebaseStartDate = Timestamp.fromDate(startDate);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('pacientes')
        .where('fechaRegistro', isGreaterThanOrEqualTo: firebaseStartDate)
        .get();

    setState(() {
      totalRegisteredPatients = snapshot.size;
    });
  }

  void filterPatients(String query) {
    setState(() {
      searchQuery = query;
      filteredPatients = patients.where((patient) {
        final fullName =
            '${patient['nombre']} ${patient['apellido']}'.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> fetchAnalysisCounts() async {
  QuerySnapshot detalleSnapshot =
      await FirebaseFirestore.instance.collection('detalleventa').get();

  Map<String, int> analysisCountMap = {};

  for (var doc in detalleSnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    List<dynamic> idAnalisisList = data['idAnalisis'] as List<dynamic>? ?? [];

    for (var idAnalisis in idAnalisisList) {
      String idAnalisisStr = idAnalisis?.toString() ?? ''; 
      if (idAnalisisStr.isNotEmpty) {
        if (analysisCountMap.containsKey(idAnalisisStr)) {
          analysisCountMap[idAnalisisStr] =
              analysisCountMap[idAnalisisStr]! + 1;
        } else {
          analysisCountMap[idAnalisisStr] = 1;
        }
      }
    }
  }

  Map<String, String> analysisNames = {};
  QuerySnapshot analysisSnapshot =
      await FirebaseFirestore.instance.collection('analisis').get();
  for (var doc in analysisSnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    String codigo = data['codigo'] ?? ''; 
    String nombre = data['nombre'] ?? 'Desconocido';
    if (codigo.isNotEmpty) { 
      analysisNames[codigo] = nombre;
    }
  }

  List<double> counts = [];
  List<String> names = [];
  for (var id in analysisCountMap.keys) {
    counts.add(analysisCountMap[id]?.toDouble() ?? 0.0); 
    names.add(analysisNames[id] ?? 'Desconocido'); 
  }

  double maxValue =
      counts.isNotEmpty ? counts.reduce((a, b) => a > b ? a : b) : 0;
  double scaleFactor =
      maxValue > 10 ? (maxValue / 10).ceilToDouble() * 10 : 10;

  setState(() {
    analysisCounts = counts;
    analysisNamesList = names;
    maxY = scaleFactor;
  });
}


  Widget buildBarChart() {
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
                String title = index < analysisNamesList.length
                    ? analysisNamesList[index]
                    : '';
                return Text(title, style: TextStyle(fontSize: 10));
              },
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

void loadData() async {
  DateTime now = DateTime.now();
  DateTime startDate;

  //inicio del rango 
  if (selectedRange == 'Día') {
    startDate = DateTime(now.year, now.month, now.day);
  } else if (selectedRange == 'Semana') {
    startDate = now.subtract(Duration(days: now.weekday - 1)); 
  } else if (selectedRange == 'Mes') {
    startDate = DateTime(now.year, now.month, 1);
  } else {
    startDate = now; 
  }

  Timestamp firebaseStartDate = Timestamp.fromDate(startDate);

  try {
  
    QuerySnapshot ventasSnapshot = await FirebaseFirestore.instance
        .collection('ventas')
        .where('fechaVenta', isGreaterThanOrEqualTo: firebaseStartDate)
        .get();

    double totalIngresos = 0.0;
    int totalAnalisis = 0;
    Map<String, int> analysisCountMap = {};

    for (var ventaDoc in ventasSnapshot.docs) {
      var ventaData = ventaDoc.data() as Map<String, dynamic>;
      String idVenta = ventaDoc.id;
      double ventaTotal = (ventaData['total'] ?? 0).toDouble();

      totalIngresos += ventaTotal;

      //contar los análisis individualmente
      QuerySnapshot detalleVentaSnapshot = await FirebaseFirestore.instance
          .collection('detalleventa')
          .where('idVenta', isEqualTo: idVenta)
          .get();

      for (var detalleDoc in detalleVentaSnapshot.docs) {
        var detalleData = detalleDoc.data() as Map<String, dynamic>;
        List<dynamic> idAnalisisList = detalleData['idAnalisis'] ?? [];

        for (var idAnalisis in idAnalisisList) {
          String idAnalisisStr = idAnalisis.toString();

          // Cuenta cada análisis individualmente
          if (analysisCountMap.containsKey(idAnalisisStr)) {
            analysisCountMap[idAnalisisStr] =
                analysisCountMap[idAnalisisStr]! + 1;
          } else {
            analysisCountMap[idAnalisisStr] = 1;
          }
        }
      }
    }
    totalAnalisis = analysisCountMap.values.fold(0, (sum, count) => sum + count);

    setState(() {
      this.totalAnalysis = totalAnalisis;
      this.totalSales = totalIngresos;
    });
  } catch (e) {
    print('Error al cargar datos: $e');
  }
}

  Future<void> generatePatientReport(
      String patientId, String patientName) async {
    if (patientId.isEmpty) {
      print('Por favor selecciona un paciente');
      return;
    }

    final pdf = pw.Document();
    final reportContent = await _buildReportContent(patientId);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Reporte de Ventas - $patientName',
                  style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              ...reportContent,
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'reporte_paciente.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<List<pw.Widget>> _buildReportContent(String patientId) async {
    List<pw.Widget> content = [];
    QuerySnapshot ventasSnapshot = await FirebaseFirestore.instance
        .collection('ventas')
        .where('idPaciente', isEqualTo: patientId)
        .get();

    for (var ventaDoc in ventasSnapshot.docs) {
      var ventaData = ventaDoc.data() as Map<String, dynamic>;
      DateTime? fechaVenta = (ventaData['fechaVenta'] as Timestamp?)?.toDate();
      double total = ventaData['total']?.toDouble() ?? 0.0;
      List<String> nombresAnalisis = [];

      QuerySnapshot detalleSnapshot = await FirebaseFirestore.instance
          .collection('detalleventa')
          .where('idVenta', isEqualTo: ventaDoc.id)
          .get();

      for (var detalleDoc in detalleSnapshot.docs) {
        var detalleData = detalleDoc.data() as Map<String, dynamic>;
        List<dynamic> idAnalisisList = detalleData['idAnalisis'] ?? [];

        for (var idAnalisis in idAnalisisList) {
          QuerySnapshot analisisSnapshot = await FirebaseFirestore.instance
              .collection('analisis')
              .where('codigo', isEqualTo: idAnalisis.toString())
              .get();

          if (analisisSnapshot.docs.isNotEmpty) {
            var analisisData =
                analisisSnapshot.docs.first.data() as Map<String, dynamic>;
            String nombreAnalisis = analisisData['nombre'] ?? 'Desconocido';
            nombresAnalisis.add(nombreAnalisis);
          }
        }
      }

      content.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Fecha: ${fechaVenta ?? 'Fecha desconocida'}'),
            pw.Text('Total: $total Bs.'),
            pw.Text('Análisis Realizados:'),
            ...nombresAnalisis
                .map((nombre) => pw.Bullet(text: nombre))
                .toList(),
            pw.Divider(),
          ],
        ),
      );
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text('Rango de Tiempo:'),
                DropdownButton<String>(
                  value: selectedRange,
                  onChanged: (newValue) {
                    setState(() {
                      selectedRange = newValue!;
                      loadData();
                      loadRegisteredPatients(); // Llama a la función aquí
                    });
                  },
                  items: timeRanges.map((range) {
                    return DropdownMenuItem(value: range, child: Text(range));
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatisticCard('$totalAnalysis', 'Análisis Realizados',
                    Icons.analytics, Colors.purple),
                _buildStatisticCard(
                    '$totalSales', 'Ingresos', Icons.attach_money, Colors.teal),
                _buildStatisticCard(
                    '$totalRegisteredPatients',
                    'Pacientes Registrados',
                    Icons.person,
                    Colors.blue), // Nueva tarjeta
              ],
            ),

            SizedBox(height: 30),
            // Título y gráfico de barras
            Text(
              'Estadísticas de Análisis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300, 
              padding: EdgeInsets.all(16),
              child:
                  buildBarChart(), 
            ),
            SizedBox(height: 30),
            Text(
              'Lista de Pacientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o apellido',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: filterPatients,
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Apellido')),
                    DataColumn(label: Text('Teléfono')),
                    DataColumn(label: Text('Dirección')),
                    DataColumn(label: Text('Generar Reporte')),
                  ],
                  rows: filteredPatients.map((patient) {
                    return DataRow(cells: [
                      DataCell(Text(patient['nombre'])),
                      DataCell(Text(patient['apellido'])),
                      DataCell(Text(patient['telefono'] ?? '')),
                      DataCell(Text(patient['direccion'] ?? '')),
                      DataCell(
                        ElevatedButton(
                          onPressed: () => generatePatientReport(patient['id'],
                              '${patient['nombre']} ${patient['apellido']}'),
                          child: Text('Generar PDF'),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard(
      String value, String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
} 