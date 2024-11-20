import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io' as io;
import 'dart:html' as html; // Solo se usará en web.
import 'package:flutter/foundation.dart';

class ViewAnalisis extends StatefulWidget {
  final String ventaId;
  final String pacienteId;
  final String userId;

  ViewAnalisis({required this.ventaId, required this.pacienteId, required this.userId});

  @override
  _ViewAnalisisState createState() => _ViewAnalisisState();
}

class _ViewAnalisisState extends State<ViewAnalisis> {
  String nombrePaciente = '';
  String sexo = 'Desconocido';
  String fechaNacimiento = '';
  String medico = 'Desconocido';
  String ordenLaboratorio = '';
  String fechaRecepcion = '';
  String fechaEntrega = '';
  List<Map<String, dynamic>> analisisList = [];
  double subtotal = 0.0;
  double total = 0.0;
  double importePagado = 0.0; // Declaración del importe pagado
  double saldo = 0.0; // Declaración del saldo
  int numeroOrden = 1;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

Future<void> cargarDatos() async {
  try {
    // Obtener datos del paciente
    DocumentSnapshot pacienteSnapshot = await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(widget.pacienteId)
        .get();

    if (pacienteSnapshot.exists) {
      var pacienteData = pacienteSnapshot.data() as Map<String, dynamic>;
      setState(() {
        nombrePaciente =
            '${pacienteData["nombre"] ?? "Desconocido"} ${pacienteData["apellido"] ?? ""}';
        fechaNacimiento = pacienteData['fechaNacimiento'] != null
            ? DateFormat('dd/MM/yyyy').format((pacienteData['fechaNacimiento'] as Timestamp).toDate())
            : 'Desconocida';
        sexo = pacienteData['sexo'] ?? 'Desconocido';
      });
    } else {
      print('No se encontró el paciente con ID: ${widget.pacienteId}');
    }

    // Obtener datos del médico
    DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.userId)
        .get();

    if (usuarioSnapshot.exists) {
      var usuarioData = usuarioSnapshot.data() as Map<String, dynamic>;
      setState(() {
        medico = '${usuarioData["nombre"] ?? "Desconocido"} ${usuarioData["apellido"] ?? ""}';
      });
    } else {
      print('No se encontró el médico con ID: ${widget.userId}');
    }

    // Configurar fechas
    setState(() {
      fechaRecepcion = DateFormat('dd/MM/yyyy').format(DateTime.now());
      fechaEntrega = DateFormat('dd/MM/yyyy')
          .format(DateTime.now().add(Duration(days: 1)));
    });

    // Generar el número de orden basado en la cantidad de ventas
    QuerySnapshot ventasSnapshot = await FirebaseFirestore.instance.collection('ventas').get();
    int numeroDeVentas = ventasSnapshot.size; // Cantidad de documentos en la colección
    String nuevoOrdenLaboratorio = (numeroDeVentas + 1).toString().padLeft(10, '0'); // Generar número con 10 dígitos

    setState(() {
      ordenLaboratorio = nuevoOrdenLaboratorio; // Actualizar el número de orden
    });

    // Obtener detalle de la venta
    DocumentSnapshot ventaSnapshot = await FirebaseFirestore.instance
        .collection('ventas')
        .doc(widget.ventaId)
        .get();

    if (ventaSnapshot.exists) {
      final ventaData = ventaSnapshot.data() as Map<String, dynamic>;

      // Cargar total e importe pagado
      double tempTotal = ventaData['total'] ?? 0.0;
      double tempImportePagado = ventaData['importePagado'] ?? tempTotal; // Asumimos que se pagó todo si no está definido
      double tempSaldo = tempTotal - tempImportePagado;

      // Actualizar totales en el estado
      setState(() {
        total = tempTotal;
        importePagado = tempImportePagado;
        saldo = tempSaldo;
      });

      // Obtener resultados y análisis
      List<dynamic> resultadosList = ventaData['resultados'] ?? [];
      QuerySnapshot detalleVentaQuery = await FirebaseFirestore.instance
          .collection('detalleventa')
          .where('idVenta', isEqualTo: widget.ventaId)
          .get();

      if (detalleVentaQuery.docs.isNotEmpty) {
        DocumentSnapshot detalleVentaSnapshot = detalleVentaQuery.docs.first;

        var detalleData = detalleVentaSnapshot.data() as Map<String, dynamic>;
        List<dynamic> idAnalisisList = detalleData['idAnalisis'] ?? [];

        List<Map<String, dynamic>> analisisTempList = [];
        for (var codigo in idAnalisisList) {
          QuerySnapshot analisisSnapshot = await FirebaseFirestore.instance
              .collection('analisis')
              .where('codigo', isEqualTo: codigo.toString())
              .get();

          if (analisisSnapshot.docs.isNotEmpty) {
            var analisisData = analisisSnapshot.docs.first.data() as Map<String, dynamic>;

            // Buscar si hay un resultado asociado
            final resultadoExistente = resultadosList.firstWhere(
              (resultado) => resultado['analisis'] == analisisData['nombre'],
              orElse: () => null,
            );

            // Validar el rango
            double rango = analisisData['rango'] ?? double.infinity;
            double? resultado = double.tryParse(resultadoExistente?['resultado'] ?? '');

            analisisTempList.add({
              'nombre': analisisData['nombre'] ?? 'Análisis Desconocido',
              'precio': analisisData['precio'] ?? 0.0,
              'resultado': resultado ?? '',
              'fueraDeRango': resultado != null && resultado > rango, // Indicador si excede el rango
            });
          } else {
            analisisTempList.add({
              'nombre': 'Análisis Desconocido',
              'precio': 0.0,
              'resultado': '',
              'fueraDeRango': false,
            });
          }
        }

        setState(() {
          analisisList = analisisTempList;
        });
      }
    } else {
      print('No se encontró la venta con ID: ${widget.ventaId}');
    }
  } catch (e) {
    print('Error al cargar datos: $e');
  }
}

  Future<void> _generarPDF() async {
    final pdf = pw.Document();
    print("Generando PDF...");

    try {
      final regularFontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
      final regularFont = pw.Font.ttf(regularFontData.buffer.asByteData());
      final boldFont = pw.Font.ttf(boldFontData.buffer.asByteData());

      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
          margin: pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LABORATORIO CLÍNICO',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Datos del Paciente:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Nombre: ${nombrePaciente.isNotEmpty ? nombrePaciente : 'Desconocido'}'),
                pw.Text('Sexo: ${sexo.isNotEmpty ? sexo : 'Desconocido'}'),
                pw.Text('Fecha de Nacimiento: ${fechaNacimiento.isNotEmpty ? fechaNacimiento : 'Desconocida'}'),
                pw.SizedBox(height: 16),
                pw.Text('Datos del Médico:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Médico: ${medico.isNotEmpty ? medico : 'Desconocido'}'),
                pw.SizedBox(height: 16),
                pw.Text('Información del Análisis:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Orden de Laboratorio: ${ordenLaboratorio.isNotEmpty ? ordenLaboratorio : '0000000001'}'),
                pw.Text('Fecha de Recepción: ${fechaRecepcion.isNotEmpty ? fechaRecepcion : 'No especificada'}'),
                pw.Text('Fecha de Entrega: ${fechaEntrega.isNotEmpty ? fechaEntrega : 'No especificada'}'),
                pw.SizedBox(height: 16),
                pw.Text('Detalles de los Análisis:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Table.fromTextArray(
                  headers: ['Análisis', 'Resultado', 'Importe'],
                  data: analisisList.map((analisis) {
                    return [
                      analisis['nombre'] ?? 'Análisis Desconocido',
                      pw.Text(
                        analisis['resultado'].toString(),
                        style: pw.TextStyle(
                          color: analisis['fueraDeRango'] ? PdfColors.red : PdfColors.black,
                        ),
                      ),
                      '\$${(analisis['precio'] ?? 0.0).toStringAsFixed(2)}',
                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Resumen:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Total: \$${total.toStringAsFixed(2)}'),
                pw.Text('Importe Pagado: \$${total.toStringAsFixed(2)}'),
                pw.Text('Saldo: \$0.00'),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      print("PDF generado con éxito.");

      // Verificación de plataforma para guardar o descargar el archivo
      if (kIsWeb) {
        // Descargar en la web
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "ReporteLaboratorio.pdf")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Guardar en dispositivos móviles
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/ReporteLaboratorio.pdf');
        await file.writeAsBytes(pdfBytes);
        await OpenFile.open(file.path);
      }
    } catch (e) {
      print('Error al generar PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 325,
            child: Text(
              'LABORATORIO CLÍNICO',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 325,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nombre:', nombrePaciente),
                _buildDetailRow('Sexo:', sexo),
                _buildDetailRow('Médico:', medico),
                _buildDetailRow('Fecha de Nacimiento:', fechaNacimiento),
              ],
            ),
          ),
          Positioned(
            top: 80,
            right: 295,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Orden de laboratorio: $ordenLaboratorio'),
                Text('Fecha de Recepción: $fechaRecepcion'),
                Text('Fecha de Entrega: $fechaEntrega'),
              ],
            ),
          ),
          Positioned(
            top: 220,
            left: 325,
            child: Container(
              width: 550,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 40.0,
                  headingRowHeight: 50,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  columns: [
                    DataColumn(label: Text('ANÁLISIS')),
                    DataColumn(label: Text('RESULTADO')),
                    DataColumn(label: Text('IMPORTE')),
                  ],
                  rows: analisisList.map<DataRow>((analisis) {
                    return DataRow(cells: [
                      DataCell(Text(analisis['nombre'] ?? 'Análisis Desconocido')),
                      DataCell(
                        Text(
                          analisis['resultado'].toString(),
                          style: TextStyle(
                            color: analisis['fueraDeRango'] ? Colors.red : Colors.black,
                          ),
                        ),
                      ),
                      DataCell(Text('\$${analisis['precio'].toStringAsFixed(2)}')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            right: 290,
            child: Container(
              width: 350,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Total', total.toStringAsFixed(2)),
                    _buildDetailRow('Importe Pagado', total.toStringAsFixed(2)), // Usamos el total para ambos
                    _buildDetailRow('Saldo', '0.00'), // Saldo fijo como 0 si todo está pagado
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 40,
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B7FCE),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'VOLVER',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B7FCE),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  ),
                  onPressed: _generarPDF,
                  child: Text(
                    'GENERAR PDF',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
