import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String selectedRange = 'Día'; 
  List<String> timeRanges = ['Día', 'Semana', 'Mes'];
  double totalSales = 0.0;
  int totalAnalysis = 0;

  String selectedPatientId = '';
  String selectedPatientName = '';
  List<Map<String, String>> patients = [];

  @override
  void initState() {
    super.initState();
    loadData();
    loadPatients();
  }

  // Cargar la lista de pacientes (nombre y apellido) desde Firebase
  Future<void> loadPatients() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('pacientes').get();
    patients = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': '${data['nombre']} ${data['apellido']}'
      };
    }).toList();
    setState(() {});
  }
void loadData() async {
  DateTime now = DateTime.now();
  DateTime startDate = DateTime.now();

// Determina el rango de fechas según el rango seleccionado
if (selectedRange == 'Día') {
  startDate = DateTime(now.year, now.month, now.day); 
} else if (selectedRange == 'Semana') {
  startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1)); 
} else if (selectedRange == 'Mes') {
  startDate = DateTime(now.year, now.month, 1); 
}

Timestamp firebaseStartDate = Timestamp.fromDate(startDate);

  try {
    // Consulta la colección de ventas en función del rango de fechas
    QuerySnapshot ventasSnapshot = await FirebaseFirestore.instance
        .collection('ventas')
        .where('fechaVenta', isGreaterThanOrEqualTo: firebaseStartDate)
        .get();

    double totalIngresos = 0.0;
    int totalAnalisis = 0;

    for (var ventaDoc in ventasSnapshot.docs) {
      var ventaData = ventaDoc.data() as Map<String, dynamic>;
      String idVenta = ventaDoc.id;
      totalIngresos += ventaData['total'];

      // Consulta en detalleventa usando el idVenta
      QuerySnapshot detalleVentaSnapshot = await FirebaseFirestore.instance
          .collection('detalleventa')
          .where('idVenta', isEqualTo: idVenta)
          .get();

      for (var detalleDoc in detalleVentaSnapshot.docs) {
        var detalleData = detalleDoc.data() as Map<String, dynamic>;
        totalAnalisis += (detalleData['idAnalisis'] as List).length;
      }
    }

    setState(() {
      this.totalAnalysis = totalAnalisis;
      this.totalSales = totalIngresos;
    });
  } catch (e) {
    print('Error al cargar datos: $e');
  }
}


Future<void> generatePatientReport(String patientId, String patientName) async {
  if (patientId.isEmpty) {
    print('Por favor selecciona un paciente');
    return;
  }

  final pdf = pw.Document();

  try {
    // Consultar las ventas del paciente seleccionado
    QuerySnapshot ventasSnapshot = await FirebaseFirestore.instance
        .collection('ventas')
        .where('idPaciente', isEqualTo: patientId)
        .get();

    if (ventasSnapshot.docs.isEmpty) {
      print('No se encontraron ventas para este paciente.');
      return;
    }

    List<Map<String, dynamic>> reportData = [];

    // Recorrer cada venta del paciente
    for (var ventaDoc in ventasSnapshot.docs) {
      var ventaData = ventaDoc.data() as Map<String, dynamic>? ?? {};
      String ventaId = ventaDoc.id;
      DateTime? fechaVenta = (ventaData['fechaVenta'] as Timestamp?)?.toDate();
      double total = ventaData['total']?.toDouble() ?? 0.0;

      if (fechaVenta == null) {
        print('Datos faltantes en la fecha de la venta.');
        continue; // Omitir esta venta si faltan datos de fecha
      }

      // Consultar el detalle de la venta en `detalleventa`
      QuerySnapshot detalleSnapshot = await FirebaseFirestore.instance
          .collection('detalleventa')
          .where('idVenta', isEqualTo: ventaId)
          .get();

      List<String> nombresAnalisis = [];
      double subtotal = 0;

      for (var detalleDoc in detalleSnapshot.docs) {
        var detalleData = detalleDoc.data() as Map<String, dynamic>? ?? {};
        List<dynamic>? idAnalisisList = detalleData['idAnalisis'] as List<dynamic>?;

        if (idAnalisisList == null) {
          print('Datos faltantes en el idAnalisis de detalle de venta.');
          continue;
        }

        subtotal += detalleData['subtotal'] != null ? detalleData['subtotal'] as double : 0.0;

        for (var idAnalisis in idAnalisisList) {

          QuerySnapshot analisisSnapshot = await FirebaseFirestore.instance
              .collection('analisis')
              .where('codigo', isEqualTo: idAnalisis)
              .get();

          if (analisisSnapshot.docs.isNotEmpty) {
            var analisisData = analisisSnapshot.docs.first.data() as Map<String, dynamic>? ?? {};
            String nombreAnalisis = analisisData['nombre'] ?? 'Desconocido';
            nombresAnalisis.add(nombreAnalisis);
          }
        }
      }

      reportData.add({
        'fechaVenta': fechaVenta.toString(), 
        'total': total,
        'subtotal': subtotal,
        'analisis': nombresAnalisis
      });
    }

    // Crear el contenido del PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reporte de Ventas - $patientName', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...reportData.map((venta) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Fecha: ${venta['fechaVenta']}'),
                  pw.Text('Total: ${venta['total']} Bs.'),
                  pw.Text('Subtotal: ${venta['subtotal']} Bs.'),
                  pw.Text('Análisis Realizados:'),
                  ...((venta['analisis'] as List).map((analisis) => pw.Bullet(text: analisis)).toList()),
                  pw.Divider(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  } catch (e) {
    print('Error al generar el reporte en PDF: $e');
  }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analisis',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Icon(Icons.person, color: Colors.blue),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Text(
                  'Rango de Tiempo:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedRange,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRange = newValue!;
                      loadData(); 
                    });
                  },
                  items: timeRanges.map((String range) {
                    return DropdownMenuItem<String>(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatisticCard(totalAnalysis.toString(), 'Análisis Realizados', Icons.analytics, Colors.purple),
                _buildStatisticCard(totalSales.toStringAsFixed(2), 'Ingresos', Icons.attach_money, Colors.teal),
              ],
            ),
            SizedBox(height: 30),

            Text(
              'Generar Reporte de Paciente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedPatientId.isEmpty ? null : selectedPatientId,
              hint: Text("Selecciona un paciente"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPatientId = newValue!;
                  selectedPatientName = patients.firstWhere((p) => p['id'] == selectedPatientId)['name']!;
                });
              },
              items: patients.map((patient) {
                return DropdownMenuItem<String>(
                  value: patient['id'],
                  child: Text(patient['name']!),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => generatePatientReport(selectedPatientId, selectedPatientName),
              child: Text('Generar Reporte'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard(String value, String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
