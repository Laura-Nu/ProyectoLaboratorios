import 'package:flutter/material.dart';
import 'package:laboratorios/Servicios/analysis/CreateAnalysis.dart';
import 'package:laboratorios/Servicios/analysis/DeleteAnalysis.dart';
import 'package:laboratorios/Servicios/analysis/UpdateAnalysis.dart';
import 'package:laboratorios/Widgets/menu.dart';

class GestionAnalysis extends StatefulWidget {
  @override
  _GestionAnalisisState createState() => _GestionAnalisisState();
}

class _GestionAnalisisState extends State<GestionAnalysis> {
  List<Map<String, dynamic>> analisisList =
      []; // Lista para almacenar los datos de los análisis

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
                  'Gestión de Análisis',
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
                    // Esperar los datos del análisis devueltos desde CreateAnalisis
                    final newAnalisis = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAnalysis()),
                    );

                    // Si newAnalisis no es nulo, añadirlo a la lista y actualizar el estado
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
                      DataColumn(label: Text('Código')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Descripción')),
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Precio')),
                      DataColumn(label: Text('Rango')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: analisisList.map<DataRow>((analisis) {
                      return DataRow(cells: [
                        DataCell(Text(analisis['codigo'].toString())),
                        DataCell(Text(analisis['nombre'])),
                        DataCell(Text(analisis['descripcion'])),
                        DataCell(Text(analisis['estado'])),
                        DataCell(Text('\$${analisis['precio']}')),
                        DataCell(Text('${analisis['rango']}')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => UpdateAnalysis(
                                      analisisId: analisis['codigo'],
                                      analisisData: analisis,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => DeleteAnalysis(
                                      analisisId: analisis['codigo'],
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
