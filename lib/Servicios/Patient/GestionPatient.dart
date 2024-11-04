import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore
import 'package:laboratorios/Servicios/Patient/CreatePatient.dart';
import 'package:laboratorios/Servicios/Patient/UpdatePatient.dart';
import 'package:laboratorios/Servicios/Patient/DeletePatient.dart';
import 'package:laboratorios/Widgets/menu.dart';

class GestionPatient extends StatefulWidget {
  @override
  _GestionPatientState createState() => _GestionPatientState();
}

class _GestionPatientState extends State<GestionPatient> {
  List<Map<String, dynamic>> pacientes = [];

  @override
  void initState() {
    super.initState();
    _fetchPacientes(); // Cargar los pacientes al iniciar
  }

  Future<void> _fetchPacientes() async {
    // Obtener datos de Firebase Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('pacientes').get();
    setState(() {
      // Mapear documentos y añadirlos a la lista de pacientes
      pacientes = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'nombre': doc['nombre'],
                'apellido_paterno': doc['apellido'],
                'direccion': doc['direccion'],
                'telefono': doc['telefono'],
                'email': doc['email'],
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Pacientes'),
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
                  'Gestión de Pacientes',
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
                    final newPatient = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreatePatient()),
                    );

                    if (newPatient != null) {
                      setState(() {
                        pacientes.add(newPatient);
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
                    columns: [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Apellido')),
                      DataColumn(label: Text('Dirección')),
                      DataColumn(label: Text('Teléfono')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: pacientes.map<DataRow>((paciente) {
                      return DataRow(cells: [
                        DataCell(Text(paciente['nombre'])),
                        DataCell(Text(paciente['apellido'])),
                        DataCell(Text(paciente['direccion'])),
                        DataCell(Text(paciente['telefono'])),
                        DataCell(Text(paciente['email'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => UpdatePatient(
                                      patientId: paciente['id'],
                                      patientData: paciente,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => DeletePatient(
                                      patientId: paciente['id'],
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
