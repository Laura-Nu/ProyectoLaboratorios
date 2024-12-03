import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar Firebase
import 'package:laboratorios/Servicios/analysis/CreateAnalysis.dart';
import 'package:laboratorios/Servicios/analysis/DeleteAnalysis.dart';
import 'package:laboratorios/Servicios/analysis/UpdateAnalysis.dart';
import 'package:laboratorios/Widgets/menu.dart';

class GestionAnalysis extends StatefulWidget {

  final String userId;

  const GestionAnalysis({Key? key, required this.userId}) : super(key: key);

  @override
  _GestionAnalisisState createState() => _GestionAnalisisState();
}

class _GestionAnalisisState extends State<GestionAnalysis> {
  List<Map<String, dynamic>> analisisList = [];
  List<Map<String, dynamic>> filteredList = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAnalisisData(); // Obtener datos al iniciar
    searchController
        .addListener(_filterAnalisis); // Escuchar cambios en el buscador
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Función para obtener datos de Firebase Firestore
  Future<void> fetchAnalisisData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('analisis').get();
      List<Map<String, dynamic>> fetchedData = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      setState(() {
        analisisList = fetchedData;
        filteredList = fetchedData; // Inicialmente, mostrar todos los datos
      });
    } catch (e) {
      print('Error al obtener datos: $e');
    }
  }

  // Función para filtrar análisis
  void _filterAnalisis() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredList = analisisList.where((analisis) {
        return analisis.entries.any((entry) {
          if (entry.value is String) {
            return entry.value.toLowerCase().contains(query);
          } else if (entry.value is num) {
            return entry.value.toString().contains(query);
          }
          return false;
        });
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var userId;
    return Scaffold(
      appBar: AppBar(
        title: Text('GESTIÓN DE ANÁLISIS'),
      ),
      drawer: Menu(userId: userId,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newAnalisis = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAnalysis(userId: userId,)),
                    );

                    if (newAnalisis != null) {
                      setState(() {
                        analisisList.add(newAnalisis);
                        filteredList
                            .add(newAnalisis); // Actualizar lista filtrada
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Agregar Análisis'),
                ),
              ],
            ),
            SizedBox(height: 25),
            Expanded(
              child: ListView(
                children: [
                  DataTable(
                    columnSpacing: 20,
                    dataRowHeight: 60,
                    columns: [
                      DataColumn(
                        label: Text(
                          'NOMBRE',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'DESCRIPCIÓN',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'ESTADO',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'PRECIO',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'RANGO INICIO',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'RANGO FIN',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'RANGO',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'ACCIONES',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    rows: filteredList.map<DataRow>((analisis) {
                      return DataRow(cells: [
                        DataCell(Text(analisis['nombre'] ?? '')),
                        DataCell(
                          SizedBox(
                            width: 180, // Ancho fijo para evitar desbordes
                            child: Text(
                              analisis['descripcion'] ?? '',
                              softWrap: true,
                            ),
                          ),
                        ),
                        DataCell(Text(analisis['estado'] ?? '')),
                        DataCell(
                            Text('Bs${analisis['precio']?.toString() ?? '0'}')),
                        DataCell(Text(
                            analisis['rango_inicio']?.toString() ?? 'N/A')),
                        DataCell(
                            Text(analisis['rango_fin']?.toString() ?? 'N/A')),
                        DataCell(Text(analisis['rango']?.toString() ?? 'N/A')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final updatedAnalysis = await showDialog(
                                    context: context,
                                    builder: (context) => UpdateAnalysis(
                                      AnalysisId: analisis['id'],
                                      AnalysisData: analisis,
                                    ),
                                  );

                                  if (updatedAnalysis != null) {
                                    setState(() {
                                      final index = analisisList.indexWhere(
                                          (p) =>
                                              p['id'] == updatedAnalysis['id']);
                                      if (index != -1) {
                                        analisisList[index] = updatedAnalysis;
                                        _filterAnalisis(); // Actualizar la lista filtrada
                                      }
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => DeleteAnalysis(
                                      analisisId: analisis['id'],
                                      onDelete: () {
                                        setState(() {
                                          analisisList.removeWhere((item) =>
                                              item['id'] == analisis['id']);
                                          _filterAnalisis(); // Actualizar la lista filtrada
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}