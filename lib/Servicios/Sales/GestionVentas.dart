import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/Servicios/Sales/UpdateAnalisis.dart';
import 'package:laboratorios/Servicios/Sales/CreateAnalisis.dart';
import 'package:laboratorios/Servicios/Sales/ViewAnalisis.dart';
import 'package:laboratorios/Widgets/menu.dart';

class GestionVentas extends StatefulWidget {
  final String userId;

  const GestionVentas({Key? key, required this.userId}) : super(key: key);

  @override
  _GestionVentasState createState() => _GestionVentasState();
}

class _GestionVentasState extends State<GestionVentas> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> ventas = [];
  List<Map<String, dynamic>> filteredVentas = [];

  Map<String, String> pacientesCache = {};
  Map<String, String> analisisCache = {};

  @override
  void initState() {
    super.initState();
    loadSalesData();
    searchController.addListener(_onSearchChanged);
  }

Future<void> loadSalesData() async {
  try {
    print("Iniciando carga de datos...");

    // Cargar datos de pacientes y análisis en caché
    print("Cargando cachés de pacientes y análisis...");
    await Future.wait([_loadPacientesCache(), _loadAnalisisCache()]);
    print("Cachés cargados: ${pacientesCache.length} pacientes, ${analisisCache.length} análisis.");

    // Cargar todas las ventas en batch
    print("Consultando datos de 'ventas'...");
    QuerySnapshot<Map<String, dynamic>> ventasSnapshot = await FirebaseFirestore.instance
        .collection('ventas')
        .where('estadoPago', isEqualTo: true)
        .get();
    Map<String, Map<String, dynamic>> ventasMap = {
      for (var venta in ventasSnapshot.docs) venta.id: venta.data()
    };
    print("Ventas cargadas: ${ventasMap.length}");

    // Consultar datos de 'detalleventa'
    print("Consultando datos de 'detalleventa'...");
    QuerySnapshot<Map<String, dynamic>> detalleVentasSnapshot = await FirebaseFirestore.instance
        .collection('detalleventa')
        .get();
    print("Documentos encontrados en 'detalleventa': ${detalleVentasSnapshot.docs.length}");

    // Procesar datos
    List<Map<String, dynamic>> salesList = [];
    for (var detalleDoc in detalleVentasSnapshot.docs) {
      final Map<String, dynamic> detalleData = detalleDoc.data();

      // Obtener idVenta y verificar que exista en el mapa de ventas
      String? idVenta = detalleData['idVenta'];
      if (idVenta != null && ventasMap.containsKey(idVenta)) {
        String pacienteId = detalleData['idPaciente'] ?? '';
        List<dynamic> idAnalisisList = detalleData['idAnalisis'] ?? [];
        double subtotal = detalleData['subtotal'] ?? 0.0;

        // Obtener nombres desde la caché
        String pacienteNombreCompleto = pacientesCache[pacienteId] ?? 'Desconocido';
        List<String> analisisList = idAnalisisList
            .map((codigo) => analisisCache[codigo.toString()] ?? 'Análisis Desconocido')
            .toList();

        salesList.add({
          'nombre': pacienteNombreCompleto,
          'analisis': analisisList.join(', '),
          'total': subtotal,
          'ventaId': idVenta,
          'pacienteId': pacienteId,
        });
      }
    }

    // Actualizar el estado con los datos procesados
    setState(() {
      ventas = salesList;
      filteredVentas = ventas;
    });
    print("Datos cargados correctamente: ${ventas.length} ventas.");
  } catch (e) {
    print('Error al cargar datos de ventas: $e');
  }
}

  Future<void> _loadPacientesCache() async {
    try {
      QuerySnapshot pacientesSnapshot =
          await FirebaseFirestore.instance.collection('pacientes').get();
      for (var doc in pacientesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          String nombreCompleto =
              '${data['nombre']} ${data['apellido'] ?? ''}'.trim();
          pacientesCache[doc.id] = nombreCompleto;
        }
      }
    } catch (e) {
      print('Error al cargar pacientes: $e');
    }
  }

  Future<void> _loadAnalisisCache() async {
    try {
      QuerySnapshot analisisSnapshot =
          await FirebaseFirestore.instance.collection('analisis').get();
      for (var doc in analisisSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          analisisCache[data['codigo']] = data['nombre'] ?? 'Desconocido';
        }
      }
    } catch (e) {
      print('Error al cargar análisis: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      String searchQuery = searchController.text.toLowerCase();
      filteredVentas = ventas.where((venta) {
        return venta['nombre'].toLowerCase().contains(searchQuery) ||
            venta['analisis'].toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _deleteVenta(String ventaId) async {
    try {
      await FirebaseFirestore.instance.collection('ventas').doc(ventaId).update({
        'estadoPago': false,
      });
      print('Venta eliminada correctamente');
      await loadSalesData();
    } catch (e) {
      print('Error al eliminar la venta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GESTION DE VENTAS',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Color(0xFF5B7FCE),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: Menu(userId: widget.userId),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 960,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5B7FCE),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAnalisis(userId: widget.userId),
                        ),
                      );
                    },
                    child: Text(
                      'CREAR DATOS',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: 1100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 24.0,
                    headingRowHeight: 50,
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    columns: [
                      DataColumn(
                        label: Center(
                          child: Text('NOMBRES'),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Center(
                            child: Text('ANÁLISIS'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text('TOTAL'),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('ACCIONES'),
                          ),
                        ),
                      ),
                    ],
                    rows: filteredVentas.map((venta) {
                      return DataRow(
                        cells: [
                          DataCell(Text(venta['nombre'] ?? '')),
                          DataCell(Text(
                            venta['analisis'].length > 50
                                ? '${venta['analisis'].substring(0, 50)}...'
                                : venta['analisis'],
                          )),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('\$${venta['total']}'),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.blue,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateAnalisis(
                                            ventaId: venta['ventaId'],
                                            userId: widget.userId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _showDeleteConfirmationModal(context, venta['ventaId']);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.picture_as_pdf),
                                    color: Colors.green,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewAnalisis(
                                            ventaId: venta['ventaId'],
                                            pacienteId: venta['pacienteId'],
                                            userId: widget.userId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationModal(BuildContext context, String ventaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'ELIMINACIÓN DE DATOS',
                style: TextStyle(
                  color: Color(0xFF54595E),
                ),
              ),
            ],
          ),
          content: Text(
            '¿ESTÁS SEGURO DE ELIMINAR ESTOS DATOS?',
            style: TextStyle(
              color: Color(0xFF54595E),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B7FCE),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVenta(ventaId);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}