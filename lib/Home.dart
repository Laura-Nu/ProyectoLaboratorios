import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/widgets/statistic_card.dart';
import 'package:laboratorios/widgets/bar_chart.dart';
import 'package:laboratorios/widgets/patient_table.dart';
import 'package:laboratorios/widgets/menu.dart';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Widgets/line_chart_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedRange = 'Día';
  DateTime? selectedDate;
  List<String> timeRanges = ['Día', 'Semana', 'Mes'];
  double totalSales = 0.0;
  int totalAnalysis = 0;
  List<double> analysisCounts = [];
  double maxY = 10.0;
  int totalRegisteredPatients = 0;
  String viewOption = 'Total';

  String selectedPatientId = '';
  String selectedPatientName = '';
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  String searchQuery = '';
  List<String> analysisNamesList = [];
  String patientViewOption = 'Total';
  List<double> patientCounts = [];
  List<String> timeLabels = [];
  double maxYPatients = 10.0;

  @override
  void initState() {
    super.initState();
    loadData();
    loadPatients();
    fetchAnalysisCounts();
    loadRegisteredPatients();
    fetchPatientRegistrationCounts();
  }

 Future<void> fetchPatientRegistrationCounts() async {
  DateTime now = DateTime.now();
  DateTime startDate = selectedDate ?? now;
  DateTime endDate = now;

  Map<String, int> countMap = {};

  if (patientViewOption == 'Tiempo') {
    if (selectedRange == 'Día') {
      for (int i = 6; i <= 24; i += 3) {
        String hourLabel = '${i % 24 == 0 ? '12am' : '${i % 12} ${i < 12 ? 'am' : 'pm'}'}';
        countMap[hourLabel] = 0;
      }
      endDate = startDate.add(Duration(days: 1));
    } else if (selectedRange == 'Semana') {
      List<String> days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      for (var day in days) {
        countMap[day] = 0;
      }
      startDate = startDate.subtract(Duration(days: startDate.weekday - 1));
      endDate = startDate.add(Duration(days: 7));
    } else if (selectedRange == 'Mes') {
      for (int i = 1; i <= 4; i++) {
        countMap['Semana $i'] = 0;
      }
      startDate = DateTime(startDate.year, startDate.month, 1);
      endDate = DateTime(startDate.year, startDate.month + 1).subtract(Duration(days: 1));
    }
  } else {
    List<String> months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    for (var month in months) {
      countMap[month] = 0;
    }
    startDate = DateTime(now.year, 1, 1);
    endDate = DateTime(now.year, 12, 31);
  }

  Timestamp firebaseStartDate = Timestamp.fromDate(startDate);
  Timestamp firebaseEndDate = Timestamp.fromDate(endDate);

  try {
    QuerySnapshot pacientesSnapshot = await FirebaseFirestore.instance
        .collection('pacientes')
        .where('fechaRegistro', isGreaterThanOrEqualTo: firebaseStartDate)
        .where('fechaRegistro', isLessThan: firebaseEndDate)
        .get();

    for (var doc in pacientesSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime fechaRegistro = (data['fechaRegistro'] as Timestamp).toDate();

      String label;
      if (patientViewOption == 'Tiempo') {
        if (selectedRange == 'Día') {
          label = '${(fechaRegistro.hour / 3).floor() * 3}:00 ${fechaRegistro.hour < 12 ? 'am' : 'pm'}';
        } else if (selectedRange == 'Semana') {
          label = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'][fechaRegistro.weekday - 1];
        } else {
          int weekNumber = ((fechaRegistro.day - 1) / 7).floor() + 1;
          label = 'Semana $weekNumber';
        }
      } else {
        label = [
          'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
          'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
        ][fechaRegistro.month - 1];
      }

      if (countMap.containsKey(label)) {
        countMap[label] = countMap[label]! + 1;
      } else {
        countMap[label] = 1;
      }
    }

    // Generar etiquetas sin repeticiones
    List<double> counts = [];
    List<String> labels = [];
    countMap.forEach((label, count) {
      counts.add(count.toDouble());
      labels.add(label);
    });

    double maxValue = counts.isNotEmpty ? counts.reduce((a, b) => a > b ? a : b) : 0;
    double scaleFactor = maxValue > 10 ? (maxValue / 10).ceilToDouble() * 10 : 10;

    setState(() {
      patientCounts = counts;
      timeLabels = labels;
      maxYPatients = scaleFactor;
    });
  } catch (e) {
    print("Error al obtener registros de pacientes: $e");
  }
}

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        loadData();
        if (viewOption == 'Tiempo') fetchAnalysisCounts();
      });
    }
  }

  Future<void> loadData() async {
    DateTime now = DateTime.now();
    DateTime startDate = selectedDate ?? now;

    if (selectedRange == 'Día') {
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (selectedRange == 'Semana') {
      startDate = startDate.subtract(Duration(days: startDate.weekday - 1));
    } else if (selectedRange == 'Mes') {
      startDate = DateTime(startDate.year, startDate.month, 1);
    }

    Timestamp firebaseStartDate = Timestamp.fromDate(startDate);
    Timestamp firebaseEndDate = Timestamp.fromDate(
      selectedRange == 'Día'
          ? startDate.add(Duration(days: 1))
          : selectedRange == 'Semana'
              ? startDate.add(Duration(days: 7))
              : DateTime(startDate.year, startDate.month + 1)
                  .subtract(Duration(days: 1)),
    );

    try {
      QuerySnapshot ventasSnapshot = await FirebaseFirestore.instance
          .collection('ventas')
          .where('fechaVenta', isGreaterThanOrEqualTo: firebaseStartDate)
          .where('fechaVenta', isLessThan: firebaseEndDate)
          .get();

      double totalIngresos = 0.0;
      int totalAnalisis = 0;
      Map<String, int> analysisCountMap = {};

      for (var ventaDoc in ventasSnapshot.docs) {
        var ventaData = ventaDoc.data() as Map<String, dynamic>;
        String idVenta = ventaDoc.id;
        double ventaTotal = (ventaData['total'] ?? 0).toDouble();

        totalIngresos += ventaTotal;

        QuerySnapshot detalleVentaSnapshot = await FirebaseFirestore.instance
            .collection('detalleventa')
            .where('idVenta', isEqualTo: idVenta)
            .get();

        for (var detalleDoc in detalleVentaSnapshot.docs) {
          var detalleData = detalleDoc.data() as Map<String, dynamic>;
          List<dynamic> idAnalisisList = detalleData['idAnalisis'] ?? [];

          for (var idAnalisis in idAnalisisList) {
            String idAnalisisStr = idAnalisis.toString();

            if (analysisCountMap.containsKey(idAnalisisStr)) {
              analysisCountMap[idAnalisisStr] =
                  analysisCountMap[idAnalisisStr]! + 1;
            } else {
              analysisCountMap[idAnalisisStr] = 1;
            }
          }
        }
      }
      totalAnalisis =
          analysisCountMap.values.fold(0, (sum, count) => sum + count);

      setState(() {
        this.totalAnalysis = totalAnalisis;
        this.totalSales = totalIngresos;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<void> generateGeneralReport() async {
    if (selectedDate == null) {
      print('Por favor selecciona una fecha');
      return;
    }

    final pdf = pw.Document();
    final reportContent = await _buildGeneralReportContent();

    final formattedStartDate = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final formattedEndDate = selectedRange == 'Día'
        ? formattedStartDate
        : DateFormat('dd/MM/yyyy').format(
            selectedRange == 'Semana'
                ? selectedDate!.add(Duration(days: 6))
                : DateTime(selectedDate!.year, selectedDate!.month + 1, 0),
          );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Reporte General - $formattedStartDate a $formattedEndDate',
                style: pw.TextStyle(fontSize: 24),
              ),
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
      ..setAttribute('download', 'reporte_general.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<List<pw.Widget>> _buildGeneralReportContent() async {
    List<pw.Widget> content = [];

    DateTime startDate = selectedDate!;
    DateTime endDate = selectedRange == 'Día'
        ? startDate.add(Duration(days: 1))
        : selectedRange == 'Semana'
            ? startDate.add(Duration(days: 7))
            : DateTime(startDate.year, startDate.month + 1, 0);

    Timestamp firebaseStartDate = Timestamp.fromDate(startDate);
    Timestamp firebaseEndDate = Timestamp.fromDate(endDate);

    QuerySnapshot ventasSnapshot = await FirebaseFirestore.instance
        .collection('ventas')
        .where('fechaVenta', isGreaterThanOrEqualTo: firebaseStartDate)
        .where('fechaVenta', isLessThan: firebaseEndDate)
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

    content.add(pw.SizedBox(height: 20));
    content.add(
      pw.Text(
        'Resumen del Rango Seleccionado:',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
    );
    content.add(pw.Text('Ventas Totales: ${ventasSnapshot.size}'));
    content.add(pw.Text('Análisis Realizados Totales: $totalAnalysis'));
    content.add(pw.Text('Pacientes Registrados: $totalRegisteredPatients'));

    return content;
  }

  Future<void> loadRegisteredPatients() async {
    DateTime startDate = selectedDate ?? DateTime.now();

    if (selectedRange == 'Día') {
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (selectedRange == 'Semana') {
      startDate = startDate.subtract(Duration(days: startDate.weekday - 1));
    } else if (selectedRange == 'Mes') {
      startDate = DateTime(startDate.year, startDate.month, 1);
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

  Future<void> loadPatients() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('pacientes').get();
    patients = snapshot.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return data['nombre'] != null &&
          data['nombre'] != '' &&
          data['apellido'] != null &&
          data['apellido'] != '';
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

  Future<void> fetchAnalysisCounts() async {
    DateTime now = DateTime.now();
    DateTime startDate = selectedDate ?? now;
    DateTime endDate = now;

    if (viewOption == 'Tiempo') {
      if (selectedRange == 'Día') {
        endDate = startDate.add(Duration(days: 1));
      } else if (selectedRange == 'Semana') {
        startDate = startDate.subtract(Duration(days: startDate.weekday - 1));
        endDate = startDate.add(Duration(days: 7));
      } else if (selectedRange == 'Mes') {
        startDate = DateTime(startDate.year, startDate.month, 1);
        endDate = DateTime(startDate.year, startDate.month + 1)
            .subtract(Duration(days: 1));
      }
    } else {
      startDate = DateTime(2000);
      endDate = now;
    }

    Timestamp firebaseStartDate = Timestamp.fromDate(startDate);
    Timestamp firebaseEndDate = Timestamp.fromDate(endDate);

    Map<String, int> analysisCountMap = {};

    try {
      QuerySnapshot ventasSnapshot = await FirebaseFirestore.instance
          .collection('ventas')
          .where('fechaVenta', isGreaterThanOrEqualTo: firebaseStartDate)
          .where('fechaVenta', isLessThan: firebaseEndDate)
          .get();

      for (var ventaDoc in ventasSnapshot.docs) {
        String idVenta = ventaDoc.id;

        QuerySnapshot detalleSnapshot = await FirebaseFirestore.instance
            .collection('detalleventa')
            .where('idVenta', isEqualTo: idVenta)
            .get();

        for (var detalleDoc in detalleSnapshot.docs) {
          var data = detalleDoc.data() as Map<String, dynamic>;
          List<dynamic> idAnalisisList = data['idAnalisis'] ?? [];

          for (var idAnalisis in idAnalisisList) {
            String idAnalisisStr = idAnalisis.toString();
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
    } catch (e) {
      print("Error al obtener análisis: $e");
    }
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
      Future<void> selectDate(BuildContext context) async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            selectedDate = picked;
            loadData();
            if (viewOption == 'Tiempo') fetchAnalysisCounts();
          });
        }
      }
      Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
  );
  if (picked != null && picked != selectedDate) {
    setState(() {
      selectedDate = picked;
      loadData();
      loadRegisteredPatients();
      fetchAnalysisCounts();
      fetchPatientRegistrationCounts();  // Actualiza también los datos de pacientes
    });
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
    appBar: AppBar(
      title: Text('LIA - LAB'),
      backgroundColor: Colors.blue,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    ),
    drawer: Menu(),
    backgroundColor: Colors.grey[100],
    body: SingleChildScrollView(
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
                    if (viewOption == 'Tiempo') {
                      fetchAnalysisCounts();
                    }
                    fetchPatientRegistrationCounts(); // Actualiza el gráfico de pacientes
                  });
                },
                items: timeRanges.map((range) {
                  return DropdownMenuItem(value: range, child: Text(range));
                }).toList(),
              ),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => selectDate(context),
              ),
              if (selectedDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate!),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              TextButton(
                onPressed: generateGeneralReport,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                ),
                child: Text(
                  "Generar Reporte General",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatisticCard(
                value: '$totalAnalysis',
                title: 'Análisis Realizados',
                icon: Icons.analytics,
                color: Colors.purple,
              ),
              StatisticCard(
                value: '$totalSales',
                title: 'Ingresos',
                icon: Icons.attach_money,
                color: Colors.teal,
              ),
              StatisticCard(
                value: '$totalRegisteredPatients',
                title: 'Pacientes Registrados',
                icon: Icons.person,
                color: Colors.blue,
              ),
            ],
          ),
          SizedBox(height: 30),
          Text(
            'Estadísticas de Análisis y Pacientes Registrados',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      padding: EdgeInsets.all(16),
                      child: BarChartWidget(
                        analysisCounts: analysisCounts,
                        maxY: maxY,
                        analysisNamesList: analysisNamesList,
                      ),
                    ),
                    Row(
                      children: [
                        Text("Mostrar datos en base a: "),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Total',
                              groupValue: viewOption,
                              onChanged: (value) {
                                setState(() {
                                  viewOption = value!;
                                  fetchAnalysisCounts();
                                });
                              },
                            ),
                            Text("Total Histórico"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Tiempo',
                              groupValue: viewOption,
                              onChanged: (value) {
                                setState(() {
                                  viewOption = value!;
                                  fetchAnalysisCounts();
                                });
                              },
                            ),
                            Text("Rango de tiempo"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      padding: EdgeInsets.all(16),
                      child: LineChartWidget(
                        dataPoints: patientCounts,
                        labels: timeLabels,
                        maxY: maxYPatients,
                        rotateLabels: true, // Activa la rotación
                        labelRotationAngle: 45.0, // Ángulo de rotación
                      ),
                    ),
                    Row(
                      children: [
                        Text("Mostrar datos de pacientes en base a: "),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Total',
                              groupValue: patientViewOption,
                              onChanged: (value) {
                                setState(() {
                                  patientViewOption = value!;
                                  fetchPatientRegistrationCounts();
                                });
                              },
                            ),
                            Text("Total Histórico"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Tiempo',
                              groupValue: patientViewOption,
                              onChanged: (value) {
                                setState(() {
                                  patientViewOption = value!;
                                  fetchPatientRegistrationCounts();
                                });
                              },
                            ),
                            Text("Rango de tiempo"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
          Container(
            height: 300,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: PatientTable(
                filteredPatients: filteredPatients,
                onGenerateReport: (id, name) =>
                    generatePatientReport(id, name),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

