import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar Firebase
import 'package:laboratorios/Servicios/analysis/CreateAnalysis.dart';
import 'package:laboratorios/Servicios/analysis/DeleteAnalysis.dart';
import 'package:laboratorios/Servicios/analysis/UpdateAnalysis.dart';
import 'package:laboratorios/Widgets/menu.dart';

class GestionAnalysis extends StatefulWidget {
  @override
  _GestionAnalisisState createState() => _GestionAnalisisState();
}

class _GestionAnalisisState extends State<GestionAnalysis> {
  List<Map<String, dynamic>> analisisList = [];

  @override
  void initState() {
    super.initState();
    fetchAnalisisData(); // Obtener datos al iniciar
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
      });
    } catch (e) {
      print('Error al obtener datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Análisis'),
      ),
      drawer: const Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '                  ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
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
                      MaterialPageRoute(builder: (context) => CreateAnalysis()),
                    );

                    if (newAnalisis != null) {
                      setState(() {
                        analisisList.add(newAnalisis);
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
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  DataTable(
                    columns: [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Descripción')),
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Código')),
                      DataColumn(label: Text('Precio')),
                      DataColumn(label: Text('Rango')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: analisisList.map<DataRow>((analisis) {
                      return DataRow(cells: [
                        DataCell(Text(analisis['nombre'])),
                        DataCell(Text(analisis['descripcion'])),
                        DataCell(Text(analisis['estado'])),
                        DataCell(Text(analisis['codigo'].toString())),
                        DataCell(Text('\$${analisis['precio']}')),
                        DataCell(Text('${analisis['rango']}')),
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
