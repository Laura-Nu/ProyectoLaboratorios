import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/Servicios/Patient/CreatePatient.dart';
import 'package:laboratorios/Servicios/Patient/UpdatePatient.dart';
import 'package:laboratorios/Servicios/Patient/DeletePatient.dart';
import 'package:laboratorios/Widgets/menu.dart';

class GestionPatient extends StatefulWidget {
  
  final String userId;

  const GestionPatient({Key? key, required this.userId}) : super(key: key);


  @override
  _GestionPatientState createState() => _GestionPatientState();
}

class _GestionPatientState extends State<GestionPatient> {
  List<Map<String, dynamic>> pacientes = [];
  List<Map<String, dynamic>> pacientesFiltrados = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPacientesFromFirebase();
    searchController.addListener(_filtrarPacientes);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchPacientesFromFirebase() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('pacientes').get();
    final fetchedPacientes = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;

      if (data['fechaNacimiento'] is Timestamp) {
        data['fechaNacimiento'] =
            (data['fechaNacimiento'] as Timestamp).toDate();
      }

      return data;
    }).toList();

    setState(() {
      pacientes = fetchedPacientes;
      pacientesFiltrados = fetchedPacientes;
    });
  }

  void _filtrarPacientes() {
    String query = searchController.text.toLowerCase();

    setState(() {
      pacientesFiltrados = pacientes.where((paciente) {
        return paciente.entries.any((entry) {
          if (entry.value is String) {
            return entry.value.toLowerCase().contains(query);
          } else if (entry.value is DateTime) {
            final fecha = entry.value as DateTime;
            return '${fecha.day}/${fecha.month}/${fecha.year}'.contains(query);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('GESTIÓN DE PACIENTES'),
      ),
      drawer: Menu(userId: widget.userId),
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
                    final newPatient = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreatePatient(userId: widget.userId,)),
                    );

                    if (newPatient != null) {
                      setState(() {
                      //  pacientes.add(newPatient);
                        pacientesFiltrados.add(newPatient);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Agregar Paciente'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  DataTable(
                    columnSpacing: 20,
                    dataRowHeight: 60,
                    headingRowHeight: 50,
                    columns: [
                      DataColumn(
                        label: Text(
                          'NOMBRES',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'APELLIDO PATERNO',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'APELLIDO MATERNO',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'DIRECCIÓN',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'TELÉFONO',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'EMAIL',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'FECHA NACIMIENTO',
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
                    rows: pacientesFiltrados.map<DataRow>((paciente) {
                      return DataRow(cells: [
                        DataCell(Container(
                            width: 100, child: Text(paciente['nombre'] ?? ''))),
                        DataCell(
                          Container(
                            width: 100,
                            child: Text(
                              paciente['apellido'] ?? '',
                              textAlign: TextAlign.start,
                              softWrap: true,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 100,
                            child: Text(
                              paciente['apellidoMaterno'] ?? '',
                              textAlign: TextAlign.start,
                              softWrap: true,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 100,
                            child: Text(
                              paciente['direccion'] ?? '',
                              textAlign: TextAlign.start,
                              softWrap: true,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 100,
                            child: Text(
                              paciente['telefono'] ?? '',
                              textAlign: TextAlign.start,
                              softWrap: true,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 100,
                            child: Text(
                              paciente['email'] ?? '',
                              textAlign: TextAlign.start,
                              softWrap: true,
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              paciente['fechaNacimiento'] != null
                                  ? '${paciente['fechaNacimiento'].day}/${paciente['fechaNacimiento'].month}/${paciente['fechaNacimiento'].year}'
                                  : '',
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final updatedPatient = await showDialog(
                                    context: context,
                                    builder: (context) => UpdatePatient(
                                      userId: widget.userId,
                                      patientId: paciente['id'],
                                      patientData: paciente,
                                    ),
                                  );

                                  if (updatedPatient != null) {
                                    setState(() {
                                      final index = pacientes.indexWhere((p) =>
                                          p['id'] == updatedPatient['id']);
                                      if (index != -1) {
                                        pacientes[index] = updatedPatient;
                                        _filtrarPacientes();
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
                                    builder: (context) => DeletePatient(
                                      patientId: paciente['id'],
                                      onDelete: () {
                                        setState(() {
                                          pacientes.removeWhere((item) =>
                                              item['id'] == paciente['id']);
                                          _filtrarPacientes();
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