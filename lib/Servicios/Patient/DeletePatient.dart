import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeletePatient extends StatelessWidget {
  final String patientId;
  final VoidCallback onDelete; // Callback para actualizar la pantalla

  DeletePatient({required this.patientId, required this.onDelete});

  Future<void> _deletePatient(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(patientId)
        .delete();
    onDelete(); // Llamar a la función callback para actualizar la pantalla
    Navigator.pop(context); // Cerrar el diálogo
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Eliminar Paciente'),
      content: Text('¿Está seguro de que desea eliminar este paciente?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => _deletePatient(context),
          child: Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}