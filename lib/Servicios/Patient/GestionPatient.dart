import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firebase Firestore
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
    fetchPacientesFromFirebase(); // Llama a la función para obtener los datos de Firebase
  }

  // Función para obtener los pacientes de Firebase y asignarlos a la lista 'pacientes'
  void fetchPacientesFromFirebase() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('pacientes').get();
    final fetchedPacientes = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] =
          doc.id; // Guarda el ID del documento para futuras referencias

      // Convertimos 'fechaNacimiento' de Timestamp a DateTime
      if (data['fechaNacimiento'] is Timestamp) {
        data['fechaNacimiento'] =
            (data['fechaNacimiento'] as Timestamp).toDate();
      }

      return data;
    }).toList();

    setState(() {
      pacientes = fetchedPacientes;
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
                  '                     ',
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
                      DataColumn(label: Text('Fecha de Nacimiento')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: pacientes.map<DataRow>((paciente) {
                      return DataRow(cells: [
                        DataCell(Text(paciente['nombre'] ?? '')),
                        DataCell(Text(paciente['apellido'] ?? '')),
                        DataCell(Text(paciente['direccion'] ?? '')),
                        DataCell(Text(paciente['telefono'] ?? '')),
                        DataCell(Text(paciente['email'] ?? '')),
                        DataCell(Text(paciente['fechaNacimiento'] != null
                            ? '${paciente['fechaNacimiento'].day}/${paciente['fechaNacimiento'].month}/${paciente['fechaNacimiento'].year}'
                            : '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final updatedPatient = await showDialog(
                                    context: context,
                                    builder: (context) => UpdatePatient(
                                      patientId: paciente['id'],
                                      patientData: paciente,
                                    ),
                                  );

                                  // Actualiza la lista de pacientes si se devuelve un paciente actualizado
                                  if (updatedPatient != null) {
                                    setState(() {
                                      final index = pacientes.indexWhere((p) =>
                                          p['id'] == updatedPatient['id']);
                                      if (index != -1) {
                                        pacientes[index] = updatedPatient;
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
